module font;
import liblbos;

const FONT_WIDTH = 5;
const FONT_HEIGHT = 6;
const FONT_SPACING = 1;

bitstruct Character : uint
{
	char p00 : 0..0;
	char p01 : 1..1;
	char p02 : 2..2;
	char p03 : 3..3;
	char p04 : 4..4;

	char p10 : 5..5;
	char p11 : 6..6;
	char p12 : 7..7;
	char p13 : 8..8;
	char p14 : 9..9;

	char p20 : 10..10;
	char p21 : 11..11;
	char p22 : 12..12;
	char p23 : 13..13;
	char p24 : 14..14;

	char p30 : 15..15;
	char p31 : 16..16;
	char p32 : 17..17;
	char p33 : 18..18;
	char p34 : 19..19;

	char p40 : 20..20;
	char p41 : 21..21;
	char p42 : 22..22;
	char p43 : 23..23;
	char p44 : 24..24;

	char p50 : 25..25;
	char p51 : 26..26;
	char p52 : 27..27;
	char p53 : 28..28;
	char p54 : 29..29;

}

fn void draw_text(String str, ushort x, ushort y, FrameBuffer fb, Colour font_colour, bool clear_bg = false/*, bool flush = false*/)
{
	ushort total_x_off = 0;
	foreach (c : str)
	{
		switch (c)
		{
			case '-':
				draw_char(HYPHEN, x + total_x_off, y, fb, font_colour, clear_bg);
			case '0':
				draw_char(ZERO, x + total_x_off, y, fb, font_colour, clear_bg);
			case '1':
				draw_char(ONE, x + total_x_off, y, fb, font_colour, clear_bg);
			case '2':
				draw_char(TWO, x + total_x_off, y, fb, font_colour, clear_bg);
			case '3':
				draw_char(THREE, x + total_x_off, y, fb, font_colour, clear_bg);
			case '4':
				draw_char(FOUR, x + total_x_off, y, fb, font_colour, clear_bg);
			case '5':
				draw_char(FIVE, x + total_x_off, y, fb, font_colour, clear_bg);
			case '6':
				draw_char(SIX, x + total_x_off, y, fb, font_colour, clear_bg);
			case '7':
				draw_char(SEVEN, x + total_x_off, y, fb, font_colour, clear_bg);
			case '8':
				draw_char(EIGHT, x + total_x_off, y, fb, font_colour, clear_bg);
			case '9':
				draw_char(NINE, x + total_x_off, y, fb, font_colour, clear_bg);
			case '.':
				draw_char(PERIOD, x + total_x_off, y, fb, font_colour, clear_bg);
			case ' ':
				draw_char(SPACE, x + total_x_off, y, fb, font_colour, clear_bg);
			default:
				draw_char(UNKNOWN, x + total_x_off, y, fb, font_colour, clear_bg);
		}
		total_x_off += FONT_WIDTH + FONT_SPACING;
	}
	// if (flush) fb.flush(x, y, total_x_off + FONT_WIDTH, FONT_HEIGHT);
}

fn void draw_char(Character c, ushort x, ushort y, FrameBuffer fb, Colour font_colour, bool clear_bg)
{
	foreach (ushort i, pix : (char[*]){c.p00, c.p01, c.p02, c.p03, c.p04, c.p10, c.p11, c.p12, c.p13, c.p14, c.p20, c.p21, c.p22, c.p23, c.p24, c.p30, c.p31, c.p32, c.p33, c.p34, c.p40, c.p41, c.p42, c.p43, c.p44, c.p50, c.p51, c.p52, c.p53, c.p54})
	{
		if (pix != 0) { fb.set_pixel(x + (i % FONT_WIDTH), y + (i / FONT_WIDTH), font_colour); }
		else if (clear_bg) { fb.set_pixel(x + (i % FONT_WIDTH), y + (i / FONT_WIDTH), {255, 255, 255, 255}); }
	}
}


const Character SPACE = {};

const Character UNKNOWN = {
	1,1,1,1,1,
	1,1,1,1,1,
	1,1,1,1,1,
	1,1,1,1,1,
	1,1,1,1,1,
	1,1,1,1,1,
};

const Character PERIOD = {
	0,0,0,0,0,
	0,0,0,0,0,
	0,0,0,0,0,
	0,0,0,0,0,
	0,1,1,0,0,
	0,1,1,0,0,
};

const Character ZERO = {
	0,1,1,1,0,
	1,0,0,1,1,
	1,0,1,0,1,
	1,0,1,0,1,
	1,1,0,0,1,
	0,1,1,1,0,
};

const Character ONE = {
	0,1,1,0,0,
	1,0,1,0,0,
	0,0,1,0,0,
	0,0,1,0,0,
	0,0,1,0,0,
	0,1,1,1,0,
};

const Character TWO = {
	0,1,1,1,0,
	1,0,0,0,1,
	0,0,1,1,0,
	0,0,1,0,0,
	0,1,0,0,0,
	1,1,1,1,1,
};

const Character THREE = {
	1,1,1,1,0,
	0,0,0,0,1,
	0,0,0,0,1,
	0,1,1,1,0,
	0,0,0,0,1,
	1,1,1,1,0,
};

const Character FOUR = {
	0,0,0,1,0,
	0,0,1,1,0,
	0,1,0,1,0,
	1,1,1,1,1,
	0,0,0,1,0,
	0,0,0,1,0,
};

const Character FIVE = {
	1,1,1,1,0,
	1,0,0,0,0,
	1,1,1,0,0,
	0,0,0,1,0,
	0,0,0,1,0,
	1,1,1,0,0,
};

const Character SIX = {
	0,0,1,1,0,
	0,1,0,0,0,
	1,0,0,0,0,
	1,1,1,1,0,
	1,0,0,0,1,
	0,1,1,1,0,
};

const Character SEVEN = {
	0,1,1,1,1,
	0,0,0,0,1,
	0,0,0,1,0,
	0,0,1,0,0,
	0,0,1,0,0,
	0,0,1,0,0,
};

const Character EIGHT = {
	0,1,1,1,0,
	1,0,0,0,1,
	0,1,1,1,0,
	1,0,0,0,1,
	1,0,0,0,1,
	0,1,1,1,0,
};

const Character NINE = {
	0,1,1,1,0,
	1,0,0,0,1,
	1,0,0,0,1,
	0,1,1,1,1,
	0,0,0,0,1,
	0,0,0,0,1,
};

const Character HYPHEN = {
	0,0,0,0,0,
	0,0,0,0,0,
	1,1,1,1,1,
	0,0,0,0,0,
	0,0,0,0,0,
	0,0,0,0,0,
};
