module example_c3;
// import std::core::mem::allocator @public;
// import std::math::nolibc;

int x = 6;
// fn isz _start() @extern("main") => main();
fn isz _start() @extern("_start") @nostrip
{
	// This doesn't work because thread_allocator is tlocal
	// allocator::thread_allocator = &VORE_ALLOCATOR;
	// allocator::temp_base_allocator = &VORE_ALLOCATOR;
	println("Hello from C3 a!");

	enable_fb();
	FrameBuffer fb = get_fb();
	fb.fill_rect(10, 10, 50, 50, RED, flush: true);
	while (true);
	return 0;
}

alias PanicFn = fn void(String, String, String, uint);
PanicFn panic = fn void (message, file, function, line)
{
	write_terminal("Panic with message \"");
	write_terminal(message);
	write_terminal("\" in file \"");
	write_terminal(file);
	write_terminal("\" in function \"");
	write_terminal(function);
	write_terminal("\"");
	while (true);
};


enum Syscall : const usz
{
	WRITE_TERMINAL = 6,
	ALLOC_BLOCKS = 7,
	FREE_BLOCKS = 8,
	DISABLE_FB_CONSOLE = 15,
	ENABLE_FB_CONSOLE = 16,
	FB_POINTER = 17,
	FLUSH_FB = 18,
}

const FB_WIDTH = 320;
const FB_HEIGHT = 240;

typedef FrameBuffer = void*;
struct _Colour @packed
{
	// Will be RGB888 on the actual hardware
	char a;
	char r;
	char g;
	char b;
}
enum Colour : const _Colour
{
	WHITE = {255, 255, 255, 255},
	BLACK = {255, 0, 0, 0},
	RED = {255, 255, 0, 0},
	GREEN = {255, 0, 255, 0},
	BLUE = {255, 0, 0, 255},
}
/*<*
 @require x + width <= FB_WIDTH
 @require y + height <= FB_HEIGHT
*>*/
fn void FrameBuffer.fill_rect(self, usz x, usz y, usz width, usz height, Colour col, bool flush = false)
{
	for (usz i = y; i < y + height; i++)
	{
		((Colour*)self)[i * FB_WIDTH + x:width] = col;
	}
	if (flush) self.flush(x, y, width, height);
}
fn void FrameBuffer.draw_rect(self, usz x, usz y, usz width, usz height, Colour col, usz outline_width = 1, bool flush = false)
{
	// for (usz xc = x; xc < x + width; xc ++)
	// {
	//((Colour*)self)[y - outline_width / 2]
	// }
}
/*<*
 @require x + width <= FB_WIDTH
 @require y + height <= FB_HEIGHT
*>*/
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

fn void println(String str)
{
	write_terminal(str);
	write_terminal("\n");
}


fn usz syscall(Syscall syscall, usz a1 = 0, usz a2 = 0, usz a3 = 0, usz a4 = 0, usz a5 = 0, usz a6 = 0) @naked
{
	asm
	(`
		ecall;
		ret;
	`);
}

/*
const VoreAllocator VORE_ALLOCATOR = {};
struct VoreAllocator (Allocator)
{
	void* dummy;
}

// TODO: this is *really* *really* bad since alloc_blocks allocates in, well, blocks not bytes (and each block afaict is 512 bytes)
fn void*? VoreAllocator.acquire(&self, usz size, AllocInitType init_type, usz alignment = 0) @dynamic
{
	// assert(ceil(size, 512) == 1);
	println("acquiring block");
	assert (size < 512);
	void* data = alloc_blocks(/*ceil(size, 512)*/1);
	if (data == null) return mem::OUT_OF_MEMORY?;
	return data;
}

fn void*? VoreAllocator.resize(&self, void* ptr, usz new_size, usz alignment = 0) @dynamic
{
	println("resizing block");
	assert (new_size < 512);
	// return mem::OUT_OF_MEMORY?;
	return ptr;
}

fn void VoreAllocator.release(&self, void* ptr, bool aligned) @dynamic
{
	println("freeing block");
	free_blocks(ptr, 1);
}

/*macro ceil(a, b) => 1 + div(a - 1, b);

macro div(a, b) => a / b;*/
/*fn usz div(usz a, usz b) @naked
{
	asm
	(`
		divu ra, a0, a1;
		ret;
	`);
}
