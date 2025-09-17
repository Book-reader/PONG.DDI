module pong;
import fixed_point;
import liblbos;
import font;

alias lbos = module liblbos;
// import std::core::mem::allocator @public;
// import std::math::nolibc;


alias Fp32 = FixedPoint {uint, 21};

fn isz _start() @extern("_start") @nostrip
{
	/*char[50] t;
	KernelInfo kinfo;
	lbos::get_kernel_info(&kinfo);
	lbos::printlns("Total processes: ",     utoa(&t, kinfo.current_process_count));
	lbos::printlns("Total memory blocks: ", utoa(&t, kinfo.total_mem_blocks));
	lbos::printlns("Free memory blocks: ",  utoa(&t, kinfo.free_mem_blocks));*/
	// This doesn't work because thread_allocator is tlocal
	// allocator::thread_allocator = &VORE_ALLOCATOR;
	// allocator::temp_base_allocator = &VORE_ALLOCATOR;
	FrameBuffer fb = lbos::get_fb();
	KeyState keys;
	fb.reset();
	lbos::print("Pong!\n");
	lbos::print("use arrow keys to move up and down, q to quit\n");
	lbos::print("\npress space to continue...\n");

/*	char[100] buf;
	Fp32 a = fixed_point::from {uint, 21}(6);
	printlns("6: ", a.to_string(&buf));

	Fp32 b = fixed_point::from {uint, 21}(3);
	printlns("6/3: ", (a / b).to_string(&buf));

	a = fixed_point::from {uint, 21}(5);
	printlns("5/3: ", (a / b).to_string(&buf));

	a = fixed_point::from {uint, 21}(3);
	printlns("3/3: ", (a / b).to_string(&buf));*/

	do
	{
		keys.update();
	} while (!keys.gamma.space);

	fb.reset();
	bool running = true;

	usz cl;

	const Colour PLAYER_COL = {255, 20, 200, 20};
	const Colour BOT_COL = RED;
	const Colour BALL_COL = BLUE;

	Rect player = {PADDLE_WIDTH, PADDLE_HEIGHT, {PADDLE_XOFF, PADDLE_START_Y}, {0, 0}, PADDLE_MAX_VELOCITY, PADDLE_AIR_RESISTANCE};
	Rect bot = {PADDLE_WIDTH, PADDLE_HEIGHT, {SCREEN_WIDTH - PADDLE_WIDTH - PADDLE_XOFF, PADDLE_START_Y}, {0, 0}, PADDLE_MAX_VELOCITY, PADDLE_AIR_RESISTANCE};
	Rect ball = {BALL_SIZE, BALL_SIZE, BALL_START_POS, {0, 0}, BALL_MAX_VELOCITY, 0};
	ushort player_score = 0;
	ushort bot_score = 0;

	fb.clear(BG_COLOUR);
	player.update(fb, PLAYER_COL);
	bot.update(fb, BOT_COL);
	ball.update(fb, BALL_COL);
	ball.apply_force(BALL_START_VEL);

	const TARGET_FPS = 60;
	const long TIME_DELAY = (long)((1000.0f / TARGET_FPS) * 1000 * 1000);
	long prev_time;
	while (running)
	{
		long time = get_time();
		if (time - prev_time < TIME_DELAY) continue;
		usz diff = (usz)(time - prev_time);
		char[10] buf;
		// TODO: this causes a compiler assert:
		// lbos::printlns("FPS:", (to_fp32(1000) / ((to_fp32(diff) / 1000) / 1000)).to_string(&buf));
		Fp32 thousand = fixed_point::from(1000);
		font::draw_text(/*"FPS: "*/ (thousand / ((diff / 1000) / 1000)).to_string(&buf), 20, 20, fb, RED, clear_bg: true);

		font::draw_text(utoa(&buf, player_score), 10, 10, fb, BLACK, clear_bg: true);
		font::draw_text(utoa(&buf, bot_score), SCREEN_WIDTH - 40, 10, fb, BLACK, clear_bg: true);

		fb.fill_rect(50, 0, 30, font::FONT_HEIGHT * 2, WHITE);
		font::draw_text(itoa(&buf, ball.velocity.x), 50, 0, fb, BLACK, clear_bg: true);
		// fb.fill_rect(50, font::FONT_HEIGHT, 30, font::FONT_HEIGHT, WHITE);
		font::draw_text(itoa(&buf, ball.velocity.y), 50, font::FONT_HEIGHT, fb, BLACK, clear_bg: true);

		// font::draw_text(utoa(&buf, 1000 / ((diff / 1000) / 1000)), 20, 20, fb, RED, clear_bg: true);
		// lbos::printlns("FPS: ", (to_fp32(1000) / ((diff / 1000) / 1000)).to_string(&buf));
		prev_time = time;
		keys.update();
		// TODO: this causes a compiler assert (because of xtoa?):
		// lbos::printlns("Player velocity x: ", xtoa(&buf, player.velocity.x), "y: ", xtoa(&buf, player.velocity.y));
		if (keys.beta.q)
		{
			fb.reset();
			if (player_score == bot_score) { lbos::print("It was a draw!\n"); }
			else if (player_score > bot_score) { lbos::print("Player won!\n"); }
			else { lbos::print("Bot won :(\n"); }
			return 0;
		}

		if (keys.delta.up_arrow && player.pos.y > 0) player.apply_force({0, -PADDLE_ACCELERATION});
		if (keys.delta.down_arrow && player.pos.y + PADDLE_HEIGHT < SCREEN_HEIGHT) player.apply_force({0, PADDLE_ACCELERATION});

		if (ball.velocity.x > 0 && ball.pos.x > SCREEN_HEIGHT - (SCREEN_HEIGHT / 8) * 3)
		{
			if (ball.pos.y > bot.pos.y + PADDLE_HEIGHT / 2) { bot.apply_force({0, PADDLE_ACCELERATION}); }
			else if (ball.pos.y < bot.pos.y + PADDLE_HEIGHT / 2) { bot.apply_force({0, -PADDLE_ACCELERATION}); }
		}

		if (ball.pos.x + BALL_SIZE == SCREEN_WIDTH)
		{
			player_score ++;
			ball.set_pos(BALL_START_POS, fb, BALL_COL);
			ball.velocity = BALL_START_VEL;
		}
		else if (ball.pos.x == 0)
		{
			bot_score ++;
			ball.set_pos(BALL_START_POS, fb, BALL_COL);
			ball.velocity = {-BALL_START_VEL.x, BALL_START_VEL.y};
		}

		ball.handle_collides_any({player, bot}, fb, BALL_COL);

		// bot.set_pos({bot.pos.x, ball.pos.y - PADDLE_HEIGHT/2}, fb, BOT_COL);

		player.update(fb, PLAYER_COL);
		bot.update(fb, BOT_COL);
		ball.update(fb, BALL_COL);
		fb.flush(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
	}
	return 0;
}

enum HorizonalDirection : const char {LEFT, RIGHT}
enum VerticalDirection : const char {UP, DOWN}

const short[<2>] BALL_START_POS = {SCREEN_WIDTH / 2 - BALL_SIZE / 2, SCREEN_HEIGHT / 2 - BALL_SIZE / 2};
const BALL_SIZE = 6; // Probably should be divisible by 2
// const BALL_SPEED = 3;
const short[<2>] BALL_START_VEL = {-30, 30};
const ushort[<2>] BALL_MAX_VELOCITY = {80, 80};

// const PADDLE_SPEED = 3;
const PADDLE_ACCELERATION = 30;
const PADDLE_AIR_RESISTANCE = 2;
const ushort[<2>] PADDLE_MAX_VELOCITY = {0, 60};
const PADDLE_XOFF = 3;
const PADDLE_START_Y = SCREEN_HEIGHT / 2 - PADDLE_HEIGHT / 2;
const PADDLE_WIDTH = 5;
const PADDLE_HEIGHT = 50;
const Colour BG_COLOUR = {255, 200, 200, 200};

const VELOCITY_FACTOR = 10;
const DAMPING_FACTOR = 15;

// Macro because it saves some bytes
macro long get_time()
{
	const uptr RTC_LOC = 0x101000;
	uint time_low = $$volatile_load((uint*)RTC_LOC);
	int time_high = $$volatile_load((int*)(RTC_LOC + uint.sizeof));

	return ((long)time_low) | (((long)time_high) << 32);
}

// TODO: check if using `short pos_x, pos_y;` instead of vectors decreases the number of instructions
struct Rect
{
	ushort width;
	ushort height;
	short[<2>] pos;
	short[<2>] velocity;
	ushort[<2>] max_velocity;
	short air_resistance;
}

fn void Rect.apply_force(&self, short[<2>] force) @noinline
{
	// TODO: clamp within max_velocity
	// self.velocity += force;
	if ($$abs(self.velocity.x += force.x) > self.max_velocity.x)
	{
		if (self.velocity.x >= 0)
		{
			self.velocity.x = self.max_velocity.x;
		}
		else
		{
			self.velocity.x = -self.max_velocity.x;
		}
	}
	if ($$abs(self.velocity.y += force.y) > self.max_velocity.y)
	{
		if (self.velocity.y >= 0)
		{
			self.velocity.y = self.max_velocity.y;
		}
		else
		{
			self.velocity.y = -self.max_velocity.y;
		}
	}
}


fn void Rect.set_pos(&self, short[<2>] pos, FrameBuffer fb, Colour col)
{
	fb.fill_rect(...self.pos, self.width, self.height, BG_COLOUR/*, flush: false*/);
	self.pos = pos;
	fb.fill_rect(...self.pos, self.width, self.height, col/*, flush: false*/);
}

fn void Rect.update(&self, FrameBuffer fb, Colour col)
{
	short[<2>] orig_pos = self.pos;
	self.pos += self.velocity / VELOCITY_FACTOR;

	if (self.pos.x + self.width > SCREEN_WIDTH)
	{
		self.velocity.x = -self.velocity.x;
		self.pos.x = SCREEN_WIDTH - self.width;
	}
	else if (self.pos.x < 0)
	{
		self.velocity.x = -self.velocity.x;
		self.pos.x = 0;
	}
	if (self.pos.y + self.height > SCREEN_HEIGHT)
	{
		self.velocity.y = -self.velocity.y;
		self.pos.y = SCREEN_HEIGHT - self.height;
	}
	else if (self.pos.y < 0)
	{
		self.velocity.y = -self.velocity.y;
		self.pos.y = 0;
	}
	if (self.air_resistance != 0)
	{
		self.velocity -= self.velocity / self.air_resistance;
	}
	fb.fill_rect(...orig_pos, self.width, self.height, BG_COLOUR/*, flush: false*/);
	fb.fill_rect(...self.pos, self.width, self.height, col/*, flush: false*/);
	// TODO: this is required because of an OS bug
	// fb.flush(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
	// fb.flush(orig_x, orig_y, self.width, self.height);
	// fb.flush(new_x, new_y, self.width, self.height);
}

// Is a macro since it uses less instructions this way
macro void Rect.handle_collides_any(&self, Rect[] others, FrameBuffer fb, Colour col)
{
	foreach (obj: others)
	{
		Intersection in = self.intersects(obj);
		switch (in)
		{
			case LEFT:
				self.velocity.x = $$abs(self.velocity.x) + (short)(obj.max_velocity.y - $$abs(obj.velocity.y)) / DAMPING_FACTOR;
				self.velocity.y += obj.velocity.y / DAMPING_FACTOR;
				self.set_pos({obj.pos.x + obj.width + 1, self.pos.y}, fb, col);
			case RIGHT:
				self.velocity.x = $$neg(self.velocity.x) + (short)$$neg(obj.max_velocity.y - $$abs(obj.velocity.y)) / DAMPING_FACTOR;
				self.velocity.y += obj.velocity.y / DAMPING_FACTOR;
				self.set_pos({obj.pos.x - self.width - 1, self.pos.y}, fb, col);
			case TOP:
				self.velocity.y = $$neg(self.velocity.y) + (short)$$abs(obj.velocity.y) / DAMPING_FACTOR;
				self.set_pos({self.pos.x, obj.pos.y + obj.height + 1}, fb, col);
			case BOTTOM:
				self.velocity.y = $$abs(self.velocity.y) + (short)$$neg(obj.velocity.y) / DAMPING_FACTOR;
				self.set_pos({self.pos.x, obj.pos.y - self.height - 1}, fb, col);
			case ALL:
				if (self.velocity.x >= 0)
				{
					self.pos.x = obj.pos.x + obj.width + 1;
				}
				else
				{
					self.pos.x = obj.pos.x - 1;
				}
				self.velocity.x = -self.velocity.x;
			case NONE:
				continue;
		}
		break;
	}
}

enum Intersection : char
{
	NONE,
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
	ALL,
}

// The intersection it returns is which side of self intersects with other
// As a macro it uses less instructions somehow so I leave it like that
macro Intersection Rect.intersects(self, Rect other)
{
	bool bottom_below_top = self.pos.y + self.height >= other.pos.y;
	bool top_above_bottom = self.pos.y <= other.pos.y + other.height;
	bool right_greater_left = self.pos.x + self.width >= other.pos.x;
	bool left_lesser_right = self.pos.x <= other.pos.x + other.width;

	bool bottom_below_bottom = self.pos.y + self.height >= other.pos.y + other.height;
	bool top_above_top = self.pos.y <= other.pos.y;
	bool right_greater_right = self.pos.x + self.width >= other.pos.x + other.width;
	bool left_lesser_left = self.pos.x <= other.pos.x;


	if ((top_above_bottom && !top_above_top) || (bottom_below_top && !bottom_below_bottom))
	{
		// Right: ([self][other])
		if (left_lesser_left && right_greater_left) { return RIGHT; }
		// Left: ([other][self])
		else if (right_greater_right && left_lesser_right) { return LEFT; }
	}
	if ((left_lesser_right && !left_lesser_left) || (right_greater_left && !right_greater_right))
	{
		// Bottom:
		/*(
			[self]
			[other]
		)*/
		if (bottom_below_top && top_above_top) { return BOTTOM; }
		// Top:
		/*(
			[other]
			[self]
		)*/
		else if (top_above_bottom && bottom_below_bottom) { return TOP; }
	}
	if (top_above_bottom && bottom_below_top && left_lesser_right && right_greater_left) return ALL;
	return NONE;
}

macro min(a, b) => $$min(a, b);
macro max(a, b) => $$max(a, b);

struct Ball
{
	ushort x;
	ushort y;
}

alias PanicFn = fn void(String, String, String, uint);
PanicFn panic = &default_panic;
fn void default_panic(String message, String file, String function, uint line)
{
	// lbos::printlns("Panic: \"", message, "\" in \"", file, "\":\"", function, "\"");
	$if $$PANIC_MSG:
		lbos::printlns("PANIC!: ", message);
	$else
		lbos::println("PANIC!!!!");
	$endif
	while (true);
}

fn void* memset(int* s, int c, usz n) @extern("memset") @nostrip
{
	s[:n] = c;
	return s;
}

// module std::core::builtin;
// import liblbos;

// TODO: this breaks when inside the builtin module, probably a compiler bug
macro String itoa(char[] buf, isz num)  @builtin => xtoa(buf, num);
macro String utoa(char[] buf, usz num)  @builtin => xtoa(buf, num);
macro String ltoa(char[] buf, long num) @builtin => xtoa(buf, num);
module std::core::builtin;
fn String itob(char[] buf, usz num) @builtin
{
	// static char[usz.sizeof * 8] buf;

	for (usz i = 0; i < usz.sizeof * 8; i++)
	{
		buf[i] = (num & (1 << i)) == 0 ? '0' : '1';
	}

	return (String)buf;
}

macro xtoa(char[] buf, num) @builtin
{
	if (num == 0)
	{
		buf[0] = '0';
		return (String)buf[:1];
	}
	usz len = 0;

	// TODO: it could be a bug that `neg = num < 0` is both allowed & crashes(?) when passing an unsigned integer
	// TypeKind 2 is SIGNED_INT
	bool neg = $kindof(num) == (char)2 ???  num < 0 : false;// num < 0;
	num = $$abs(num);

	while (num > 0)
	{
		buf[len++] = (char)(num % 10) + '0';
		num /= 10;
	}
	if (neg) buf[len++] = '-';
	/*foreach (i, c : buf[:len / 2])
	{
		buf[i] = buf[len - i - 1];
		buf[len - i - 1] = c;
	}*/
	for (usz j = 0, usz k = len - 1; j < k; j++, k--)
	{
		char temp = buf[j];
		buf[j] = buf[k];
		buf[k] = temp;
	}
	return (String)buf[:len];
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
