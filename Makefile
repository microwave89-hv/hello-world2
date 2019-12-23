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
	sync
	sudo diskutil unmount $(MNTDEV)
