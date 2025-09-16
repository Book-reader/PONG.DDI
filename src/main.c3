module example_c3;
import fixed_point;
import liblbos;
import font;

alias lbos = module liblbos;
// import std::core::mem::allocator @public;
// import std::math::nolibc;


alias Fp32 = FixedPoint {uint, 21};
// TODO: once inference is in the master branch this isn't needed
alias to_fp32 = fixed_point::from {uint, 21};
fn isz _start() @extern("_start") @nostrip
{
	// This doesn't work because thread_allocator is tlocal
	// allocator::thread_allocator = &VORE_ALLOCATOR;
	// allocator::temp_base_allocator = &VORE_ALLOCATOR;
	FrameBuffer fb = lbos::get_fb();
	KeyState keys;
	fb.reset();
	lbos::println("Pong!");
	lbos::println("use arrow keys to move up and down");
	lbos::println("\npress space to continue...");

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

	const Colour PLAYER_COL = GREEN;
	const Colour BOT_COL = RED;
	const Colour BALL_COL = BLUE;

	Rect player = {0, 0, PADDLE_WIDTH, PADDLE_HEIGHT};
	Rect bot = {0, 0, PADDLE_WIDTH, PADDLE_HEIGHT};
	Rect ball = {0, 0, BALL_SIZE, BALL_SIZE};
	HorizonalDirection ball_horizontal_dir = LEFT;
	VerticalDirection ball_vertical_dir = DOWN;

	fb.clear(BG_COLOUR);
	player.update(fb, PLAYER_COL, PADDLE_XOFF, PADDLE_START_Y);
	bot.update(fb, BOT_COL, SCREEN_WIDTH - PADDLE_WIDTH - PADDLE_XOFF, PADDLE_START_Y);
	ball.update(fb, BALL_COL, SCREEN_WIDTH / 2 - BALL_SIZE / 2, SCREEN_HEIGHT / 2 - BALL_SIZE / 2);

	const TARGET_FPS = 120;
	const long TIME_DELAY = (long)((1000.0f / TARGET_FPS) * 1000 * 1000);
	long prev_time;
	while (running)
	{
		long time = get_time();
		if (time - prev_time < TIME_DELAY) continue;
		usz diff = (usz)(time - prev_time);
		char[10] buf;
		// printlns("FPS:", (to_fp32(1000) / ((to_fp32(diff) / 1000) / 1000)).to_string(&buf));
		font::draw_text(/*"FPS: "*/ (to_fp32(1000) / ((diff / 1000) / 1000)).to_string(&buf), 20, 20, fb, RED, clear_bg: true);
		// font::draw_text(itoa(&buf, 1000 / ((diff / 1000) / 1000)), 20, 20, fb, RED, clear_bg: true);
		// lbos::printlns("FPS: ", (to_fp32(1000) / ((diff / 1000) / 1000)).to_string(&buf));
		prev_time = time;
		keys.update();
		if (keys.delta.up_arrow && player.y > 0) player.update(fb, PLAYER_COL, player.x, max(player.y, PADDLE_SPEED) - PADDLE_SPEED);
		if (keys.delta.down_arrow && player.y + PADDLE_HEIGHT < SCREEN_HEIGHT) player.update(fb, PLAYER_COL, player.x, min(player.y, SCREEN_HEIGHT - PADDLE_SPEED) + PADDLE_SPEED);

		ushort ball_x;
		ushort ball_y;
		if (ball_vertical_dir == DOWN)
		{
			ball_y = min(ball.y, SCREEN_HEIGHT - BALL_SPEED - BALL_SIZE) + BALL_SPEED;
			if (ball_y + BALL_SIZE == SCREEN_HEIGHT) ball_vertical_dir = UP;
		}
		else
		{
			ball_y = max(ball.y, BALL_SPEED) - BALL_SPEED;
			if (ball_y == 0) ball_vertical_dir = DOWN;
		}
		if (ball_horizontal_dir == RIGHT)
		{
			ball_x = min(ball.x, SCREEN_WIDTH - BALL_SPEED - BALL_SIZE) + BALL_SPEED;
			if (ball_x + BALL_SIZE == SCREEN_WIDTH)
			{
				// ball.update(fb, BALL_COL, SCREEN_WIDTH / 2 - BALL_SIZE / 2, SCREEN_HEIGHT / 2 - BALL_SIZE / 2);
				ball_x = SCREEN_WIDTH / 2 - BALL_SIZE / 2;
				ball_y = SCREEN_HEIGHT / 2 - BALL_SIZE / 2;
				ball_horizontal_dir = LEFT;
			}
		}
		else
		{
			ball_x = max(ball.x, BALL_SPEED) - BALL_SPEED;
			if (ball_x == 0)
			{
				ball_x = SCREEN_WIDTH / 2 - BALL_SIZE / 2;
				ball_y = SCREEN_HEIGHT / 2 - BALL_SIZE / 2;
				ball_horizontal_dir = RIGHT;
			}
		}

		// TODO: update pos here, then redraw below the collision detection so it cannot visually overlap the other object
		ball.update(fb, BALL_COL, ball_x, ball_y);
		foreach (obj : (Rect[]){player, bot})
		{
			Intersection in = ball.intersects(obj);
			switch (in)
			{
				// TODO: double check all these changes to ball_x & ball_y
				case LEFT:
					ball_horizontal_dir = RIGHT;
					ball_x = obj.x + obj.width + 1;
				case RIGHT:
					ball_horizontal_dir = LEFT;
					ball_x = obj.x - BALL_SIZE - 1;
				case TOP:
					ball_vertical_dir = DOWN;
					ball_y = obj.y + obj.height + 1;
				case BOTTOM:
					ball_vertical_dir = UP;
					ball_y = obj.y - BALL_SIZE - 1;
				case ALL:
					if (ball_horizontal_dir == LEFT)
					{
						ball_horizontal_dir = RIGHT;
						ball_x = obj.x + obj.width + 1;
					}
					else
					{
						ball_horizontal_dir = LEFT;
						ball_x = obj.x - 1;
					}
				case NONE:
					continue;
			}
			break;
		}
		ball.update(fb, BALL_COL, ball_x, ball_y);
	}
	return 0;
}

enum HorizonalDirection : const char {LEFT, RIGHT}
enum VerticalDirection : const char {UP, DOWN}

const BALL_SIZE = 6; // Probably should be divisible by 2
const BALL_SPEED = 2;

const PADDLE_SPEED = 3;
const PADDLE_XOFF = 3;
const PADDLE_START_Y = SCREEN_HEIGHT / 2 - PADDLE_HEIGHT / 2;
const PADDLE_WIDTH = 5;
const PADDLE_HEIGHT = 50;
const Colour BG_COLOUR = {255, 200, 200, 200};

fn long get_time()
{
	const uptr RTC_LOC = 0x101000;
	uint time_low = $$volatile_load((uint*)RTC_LOC);
	int time_high = $$volatile_load((int*)(RTC_LOC + uint.sizeof));

	return ((long)time_low) | (((long)time_high) << 32);
}

struct Rect
{
	ushort x;
	ushort y;
	ushort width;
	ushort height;
}

fn void Rect.update(&self, FrameBuffer fb, Colour col, ushort new_x, ushort new_y)
{
	// if (new_x != self.x || new_y != self.y)
	{
		fb.fill_rect(self.x, self.y, self.width, self.height, BG_COLOUR, flush: false);
		fb.fill_rect(new_x, new_y, self.width, self.height, col, flush: false);
		// TODO: this is required because of an OS bug
		fb.flush(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

		self.x = new_x;
		self.y = new_y;
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
fn Intersection Rect.intersects(self, Rect other)
{
	bool bottom_below_top = self.y + self.height >= other.y;
	bool top_above_bottom = self.y <= other.y + other.height;
	bool right_greater_left = self.x + self.width >= other.x;
	bool left_lesser_right = self.x <= other.x + other.width;

	bool bottom_below_bottom = self.y + self.height >= other.y + other.height;
	bool top_above_top = self.y <= other.y;
	bool right_greater_right = self.x + self.width >= other.x + other.width;
	bool left_lesser_left = self.x <= other.x;
	// if (bottom_below_top && top_above_bottom && right_greater_left && left_lesser_right) return LEFT;


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
	if ((top_above_bottom && !top_above_top) || (bottom_below_top && !bottom_below_bottom))
	{
		// Right: ([self][other])
		if (left_lesser_left && right_greater_left) { return RIGHT; }
		// Left: ([other][self])
		else if (right_greater_right && left_lesser_right) { return LEFT; }
	}
	if (top_above_bottom && bottom_below_top && left_lesser_right && right_greater_left) return ALL;
	return NONE;
}

macro min(a, b) => a > b ? ($typeof(a))b : ($typeof(a))a;
macro max(a, b) => a > b ? ($typeof(a))a : ($typeof(a))b;

struct Ball
{
	ushort x;
	ushort y;
}

alias PanicFn = fn void(String, String, String, uint);
PanicFn panic = fn void (message, file, function, line)
{
	lbos::printlns("Panic: \"", message, "\" in \"", file, "\":\"", function, "\"");
	while (true);
};

fn void* memset(int* s, int c, usz n) @extern("memset") @nostrip
{
	s[:n] = c;
	return s;
}

module std::core::builtin;

fn String itoa(char[] buf, usz num) @builtin => xtoa(buf, num);
fn String ltoa(char[] buf, long num) @builtin => xtoa(buf, num);

fn String itob(usz num) @builtin
{
	static char[usz.sizeof * 8] buf;

	for (usz i = 0; i < usz.sizeof * 8; i++)
	{
		buf[i] = (num & (1 << i)) == 0 ? '0' : '1';
	}

	return (String)&buf;
}

macro xtoa(char[] buf, num) @builtin
{
	if (num == 0)
	{
		buf[0] = '0';
		return (String)buf[:1];
	}
	usz len = 0;

	bool neg = num < 0;

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
	for (usz j = 0, usz k = len - 1; j < k; j++, k--) {
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
