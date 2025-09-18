module fixed_point {Container, DECIMAL_BITS};

typedef FixedPoint @structlike = Container;
const DECIMAL_MASK = (1 << DECIMAL_BITS) - 1;

macro FixedPoint from(Container num) => (FixedPoint)num << DECIMAL_BITS;

macro FixedPoint FixedPoint.add(self, FixedPoint other) @operator(+) => (FixedPoint)((Container)self + (Container)other);
macro FixedPoint FixedPoint.sub(self, FixedPoint other) @operator(-) => (FixedPoint)((Container)self - (Container)other);

macro FixedPoint FixedPoint.mul(self, FixedPoint other) @operator(*) => (FixedPoint)(((Container)self * (Container)other) >> DECIMAL_BITS);
macro FixedPoint FixedPoint.div(self, FixedPoint other) @operator(/) => (FixedPoint)((Container)self / ((Container)other >> DECIMAL_BITS));
macro FixedPoint FixedPoint.div_int(self, Container other) @operator(/) => (FixedPoint)((Container)self / other);

macro Container FixedPoint.to_int(self) => (Container)self >> DECIMAL_BITS;

macro String FixedPoint.to_string(self, char[] buf)
{
	String start = ctoa(buf, (Container)self >> DECIMAL_BITS);
	buf[start.len] = '.';
	const DECIMAL_PLACES = 7;
	String dec = ctoa(buf[start.len + 1..], (int128)(self & DECIMAL_MASK) * 1000000/*DECIMAL_PLACES*/ / (1 << DECIMAL_BITS));
	return (String)buf[:start.len + 1 + dec.len];
}

fn String ctoa(char[] buf, Container num) @private => xtoa(buf, num);
