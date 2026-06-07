all: pinpong
	qemu-system-i386 pinpong

pingpong: pingpong.asm
	nasm pingpong.asm -o pingpong
