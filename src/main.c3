module example_c3;

fn isz _start() @extern("_start")
{
	println("Hello from C3!");
	return 0;
}

enum Syscall : const usz
{
	WRITE_TERMINAL = 6,
}

fn usz syscall(Syscall syscall, usz a1, usz a2, usz a3, usz a4, usz a5, usz a6) @naked
{
	asm
	(`
		ecall;
		ret;
	`);
}
fn void write_terminal(String str)
{
	syscall(WRITE_TERMINAL, (usz)str.ptr, str.len, 0, 0, 0, 0);
}

fn void println(String str)
{
	write_terminal(str);
	write_terminal("\n");
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
