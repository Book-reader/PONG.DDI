module example_c3;
import std::core::mem::allocator @public;
import std::math::nolibc;

fn isz _start() @extern("_start") @nostrip
{
	// This errors because it tries to print to address 0x4 for some reason
	/*allocator::thread_allocator = &VORE_ALLOCATOR;
	allocator::temp_base_allocator = &VORE_ALLOCATOR;*/
	println("Hello from C3!");
	return 0;
}

enum Syscall : const usz
{
	WRITE_TERMINAL = 6,
	ALLOC_BLOCKS = 7,
	FREE_BLOCKS = 8,
}

fn usz syscall(Syscall syscall, usz a1 = 0, usz a2 = 0, usz a3 = 0, usz a4 = 0, usz a5 = 0, usz a6 = 0) @naked
{
	asm
	(`
		ecall;
		ret;
	`);
}
fn void write_terminal(String str) => syscall(WRITE_TERMINAL, (usz)str.ptr, str.len);
fn void* alloc_blocks(usz num_blocks) => (void*)syscall(ALLOC_BLOCKS, num_blocks);
fn void free_blocks(void* block, usz num_blocks) => syscall(FREE_BLOCKS, (usz)block, num_blocks);

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
