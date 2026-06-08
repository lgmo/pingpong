all: pingpong
	qemu-system-i386 build/pingpong

pingpong: pingpong.asm
	nasm pingpong.asm -o build/pingpong
