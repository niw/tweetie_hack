SRC_DIR=..
OUTPUT_DIR=build
DISK_IMG_DIR=$(OUTPUT_DIR)/DiskImage
RELEASE_NAME=TweetieHack
BUILDSTYLE=Release
BUILD_DIR=$(SRC_DIR)/build/$(BUILDSTYLE)
RELEASE_PACKAGE=$(RELEASE_NAME).bundle
BUILDFLAGS="BUILDCONFIGURATION=$(BUILDSTYLE)"

all: release

clean:
	rm -rf $(OUTPUT_DIR)
	$(MAKE) $(BUILDFLAGS) -C ./openUp clean

openUp:
	$(MAKE) $(BUILDFLAGS) -C ./openUp

release: openUp
	rm -rf $(OUTPUT_DIR)
	mkdir $(OUTPUT_DIR)
	mkdir $(DISK_IMG_DIR)
	cp -R $(BUILD_DIR)/$(RELEASE_PACKAGE) $(DISK_IMG_DIR)
	cp -R SIMBL.pkg $(DISK_IMG_DIR)
	find $(OUTPUT_DIR) -name ".svn" -type d -exec rm -rf {} \; -prune
	find $(OUTPUT_DIR) \( -name "*~" -or -name .DS_Store -or -name classes.nib -or -name info.nib \) -type f -delete
	mkdir $(DISK_IMG_DIR)/.background
	cp background.png $(DISK_IMG_DIR)/.background
	./make-diskimage.sh $(OUTPUT_DIR)/$(RELEASE_NAME).dmg $(DISK_IMG_DIR) $(RELEASE_NAME) alignment.scpt
