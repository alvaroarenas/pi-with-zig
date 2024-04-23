all: install

i install: build
	cp kernel.img /Volumes/PIBOOT
	diskutil eject /dev/disk4
	echo "done"

b build:
	zig build dump-bin --summary all

clean:
	rm -rf zig-cache zig-out

cleanall: clean
	rm kernel.img
