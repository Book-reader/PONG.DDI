module liblbos;

enum Syscall : const usz
{
	DO_NOTHING = 0,
	KERNEL_INFO = 1,
	WRITE_TERMINAL = 6,
	ALLOC_BLOCKS = 7,
	FREE_BLOCKS = 8,
	DISABLE_FB_CONSOLE = 15,
	ENABLE_FB_CONSOLE = 16,
	FB_POINTER = 17,
	FLUSH_FB = 18,
	GET_CURRENT_KEYMAP = 19,
}

const SCREEN_WIDTH @builtin = 320;
const SCREEN_HEIGHT @builtin = 240;

typedef FrameBuffer = void*;
struct Colour @packed
{
	// Will be RGB888 on the actual hardware
	char a;
	char r;
	char g;
	char b;
}
// macro bool Colour.equals(self, Colour other) @operator(==) => self.a == other.a && self.r == other.r && self.g == other.g && self.b == other.b;

const Colour WHITE @builtin = {255, 255, 255, 255};
const Colour BLACK @builtin = {255, 0, 0, 0};
const Colour RED @builtin = {255, 255, 0, 0};
const Colour GREEN @builtin = {255, 0, 255, 0};
const Colour BLUE @builtin = {255, 0, 0, 255};

<*
 @require x + width <= SCREEN_WIDTH
 @require y + height <= SCREEN_HEIGHT
*>
fn void FrameBuffer.fill_rect(self, usz x, usz y, usz width, usz height, Colour col, bool flush = false)
{
	for (usz ys = y; ys < y + height; ys++)
	{
		((Colour*)self)[ys * SCREEN_WIDTH + x:width] = col;
	}
	if (flush) self.flush(x, y, width, height);
}
fn void FrameBuffer.trace_rect(self, usz x, usz y, usz width, usz height, Colour col, usz outline_width = 1, bool flush = false)
{
	// TODO: I could make this a lot more efficient
	self.fill_rect(x, y, width, outline_width, col, flush: flush); // @inline;
	self.fill_rect(x, y + height, width, outline_width, col, flush: flush); // @inline;
	self.fill_rect(x, y, outline_width, height + outline_width, col, flush: flush); // @inline;
	self.fill_rect(x + height, y, outline_width, height + outline_width, col, flush: flush); // @inline;
}

fn void FrameBuffer.set_pixel(self, ushort x, ushort y, Colour col, bool flush = false)
{
	((Colour*)self)[y * SCREEN_WIDTH + x] = col;
	if (flush) self.flush(x, y, 1, 1);
}
fn void FrameBuffer.reset(self) => enable_fb();
fn void FrameBuffer.clear(self, Colour col) => self.fill_rect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, col, flush: true);
// fn void FrameBuffer.clear_rect(self, usz x, usz y, usz width, usz height, bool flush = false) => self.fill_rect(x, y, width, height, WHITE, flush: flush);
<*
 @require x + width <= SCREEN_WIDTH
 @require y + height <= SCREEN_HEIGHT
*>
fn void FrameBuffer.flush(self, usz x, usz y, usz width, usz height) => flush_fb_rect(x, y, width, height);

fn void write_terminal(String str) => syscall(WRITE_TERMINAL, (usz)str.ptr, str.len);
fn void* alloc_blocks(usz num_blocks) => (void*)syscall(ALLOC_BLOCKS, num_blocks);
fn void free_blocks(void* block, usz num_blocks) => syscall(FREE_BLOCKS, (usz)block, num_blocks);
fn void disable_fb() => syscall(DISABLE_FB_CONSOLE);
fn void enable_fb() => syscall(ENABLE_FB_CONSOLE);
<*
 @ensure (void*)return != null : "Failed to get FrameBuffer pointer"
*>
fn FrameBuffer get_fb() => (FrameBuffer)syscall(FB_POINTER);
fn void flush_fb_rect(usz x, usz y, usz w, usz h) => syscall(FLUSH_FB, x, y, w, h);
fn void get_keymap(KeyState* state) => syscall(GET_CURRENT_KEYMAP, (usz)state);
fn void get_kernel_info(KernelInfo* info) => syscall(KERNEL_INFO, (usz)info);

fn void print(String str)
{
	write_terminal(str);
}

fn void println(String str)
{
	print(str);
	print("\n");
}

macro void printlns(String...)
{
	$for var $i = 0; $i < $vacount; $i++:
		print($vaarg[$i]);
	$endfor
	print("\n");
}

fn usz syscall(Syscall syscall, usz a1 = 0, usz a2 = 0, usz a3 = 0, usz a4 = 0, usz a5 = 0, usz a6 = 0) @naked @noinline
{
	asm
	(`
		ecall;
		ret;
	`);
}

struct KeyState
{
	KeyAlpha alpha;
	KeyBeta beta;
	KeyGamma gamma;
	KeyDelta delta;
}
fn void KeyState.update(&self) => get_keymap(self);

bitstruct KeyAlpha : ushort
{
	bool esc;
	bool key1;
	bool key2;
	bool key3;
	bool key4;
	bool key5;
	bool key6;
	bool key7;
	bool key8;
	bool key9;
	bool key0;
	bool minus;
	bool equal;
	bool backspace;
	bool tab;
	bool enter;
}

bitstruct KeyBeta : uint
{
	bool a;
	bool b;
	bool c;
	bool d;
	bool e;
	bool f;
	bool g;
	bool h;
	bool i;
	bool j;
	bool k;
	bool l;
	bool m;
	bool n;
	bool o;
	bool p;
	bool q;
	bool r;
	bool s;
	bool t;
	bool u;
	bool v;
	bool w;
	bool x;
	bool y;
	bool z;
}

bitstruct KeyGamma : ushort
{
	bool left_bracket;
	bool right_bracket;
	bool semicolon;
	bool apostrophe;
	bool grave;
	bool backslash;
	bool comma;
	bool dot;
	bool slash;
	bool space;
	bool control;
	bool shift;
	bool alt;
}

bitstruct KeyDelta : ushort
{
	bool up_arrow;
	bool down_arrow;
	bool left_arrow;
	bool right_arrow;
}

struct KernelInfo
{
	usz current_process_count;
	usz total_mem_blocks;
	usz free_mem_blocks;
}
