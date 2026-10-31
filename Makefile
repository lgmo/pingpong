all: pingpong
	qemu-system-i386 build/pingpong

pingpong: pingpong.asm
	nasm pingpong.asm -o build/pingpong

pingpong.debug:
	nasm -f bin -l build/pingpong.lst pingpong.asm -o build/pingpong.debug

gdb: pingpong.debug
	# -S: don't start cpu execution at startup
	#  -s: abbreviation of -gdb tcp::1234
	qemu-system-i386 build/pingpong.debug -S -s

