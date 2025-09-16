module font;
import liblbos;

const FONT_WIDTH = 5;
const FONT_HEIGHT = 6;
const FONT_SPACING = 1;
alias Character = CharRow[FONT_HEIGHT];

bitstruct CharRow : char
{
	char p1 : 0..0;
	char p2 : 1..1;
	char p3 : 2..2;
	char p4 : 3..3;
	char p5 : 4..4;
}

fn void draw_text(String str, ushort x, ushort y, FrameBuffer fb, Colour font_colour, bool clear_bg = false)
{
	ushort total_x_off = 0;
	foreach (c : str)
	{
		switch (c)
		{
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
			case '8':
			case '9':
				nextcase default;
			case '.':
				draw_char(PERIOD, x + total_x_off, y, fb, font_colour, clear_bg);
			case ' ':
				draw_char(SPACE, x + total_x_off, y, fb, font_colour, clear_bg);
			default:
				draw_char(UNKNOWN, x + total_x_off, y, fb, font_colour, clear_bg);
		}
		total_x_off += FONT_WIDTH + FONT_SPACING;
	}
	fb.flush(x, y, total_x_off + FONT_WIDTH, FONT_HEIGHT);
}

fn void draw_char(Character c, ushort x, ushort y, FrameBuffer fb, Colour font_colour, bool clear_bg)
{
	foreach (ushort y_off, cy : c)
	{
		foreach (ushort x_off, pix : (char[FONT_WIDTH]){cy.p1, cy.p2, cy.p3, cy.p4, cy.p5})
		{
			
			if (pix != 0) { fb.set_pixel(x + x_off, y + y_off, font_colour); }
			else if (clear_bg) { fb.set_pixel(x + x_off, y + y_off, {255, 255, 255, 255}); }
		}
	}
}


const Character SPACE = {};

const Character UNKNOWN = {
	{1,1,1,1,1},
	{1,1,1,1,1},
	{1,1,1,1,1},
	{1,1,1,1,1},
	{1,1,1,1,1},
	{1,1,1,1,1},
};

const Character PERIOD = {
	{0,0,0,0,0},
	{0,0,0,0,0},
	{0,0,0,0,0},
	{0,0,0,0,0},
	{0,1,1,0,0},
	{0,1,1,0,0},
};

const Character ZERO = {
	{0,1,1,1,0},
	{1,0,0,1,1},
	{1,0,1,0,1},
	{1,0,1,0,1},
	{1,1,0,0,1},
	{0,1,1,1,0},
};

const Character ONE = {
	{0,1,1,0,0},
	{1,0,1,0,0},
	{0,0,1,0,0},
	{0,0,1,0,0},
	{0,0,1,0,0},
	{0,1,1,1,0},
};

const Character TWO = {
	{0,1,1,1,0},
	{1,0,0,0,1},
	{0,0,1,1,0},
	{0,0,1,0,0},
	{0,1,0,0,0},
	{1,1,1,1,1},
};

const Character THREE = {
	{1,1,1,1,0},
	{0,0,0,0,1},
	{0,0,0,0,1},
	{0,1,1,1,0},
	{0,0,0,0,1},
	{1,1,1,1,0},
};

const Character FOUR = {
	{0,0,0,1,0},
	{0,0,1,1,0},
	{0,1,0,1,0},
	{1,1,1,1,1},
	{0,0,0,1,0},
	{0,0,0,1,0},
};

const Character FIVE = {
	{1,1,1,1,0},
	{1,0,0,0,0},
	{1,1,1,0,0},
	{0,0,0,1,0},
	{0,0,0,1,0},
	{1,1,1,0,0},
};

const Character SIX = {
	{0,0,1,1,0},
	{0,1,0,0,0},
	{1,0,0,0,0},
	{1,1,1,1,0},
	{1,0,0,0,1},
	{0,1,1,1,0},
};
