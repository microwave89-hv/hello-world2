# Notes:
# Only tested on High Sierra 13.6!
# Only tested with nasm 2.14.02! (obtained by brew install nasm)
# The -p switch to mkdir might not be available on your OS.
# Your OS might prevent you from messing with the mount directory.
# Your OS might prevent you from messing with the EFI partition.

TARGET	= hello-world2.efi
SRC	= main.asm

AS=nasm
ASFLAGS+= \
	-w+all \

all: $(TARGET)

hello-world2.efi:
	$(AS) -o hello-world2.efi $(ASFLAGS) main.asm

.PHONY: clean install

clean:
	rm ./*.efi

MNTDIR = /Volumes/EFIMOUNT/
TARGETDIR = /Volumes/EFIMOUNT/EFI/MyApps/
MNTDEV = /dev/disk0s1

install:
	sudo mkdir -p $(MNTDIR)
	sudo diskutil mount -mountPoint $(MNTDIR) $(MNTDEV)
	sudo mkdir -p $(TARGETDIR)
	cp $(TARGET) $(TARGETDIR)
	sync # From https://github.com/o-gs/DJI_FC_Patcher, step 4
	sudo diskutil unmount $(MNTDEV)
