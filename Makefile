CFLAGS += -framework AppKit -Os

Undot.app: Makefile Info.plist undot
	mkdir -p Undot.app/Contents/MacOS/
	cp Info.plist Undot.app/Contents/
	cp undot Undot.app/Contents/MacOS/Undot
	codesign -s - Undot.app
