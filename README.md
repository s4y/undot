# undot

Quick hack to hide the full screen microphone dot on macOS 12.

## Usage

To build:

```sh
git clone https://github.com/s4y/undot
cd undot
make
open .
```

You'll end up with Undot.app in the window that shows up.

1. Go ahead and launch it.
2. Click "Open System Preferences" in the dialog box that appears, then put a checkmark next to "Undot" in the list.
3. Open Undot.app one more time. It won't be visible in the Dock or menu bar, but it'll be doing its job.

The easiest way to quit it is via Activity Monitor (find it and click the "Quit" button), or by running `killall Undot` in a terminal window.

You can add it to your Login Items if you'd like, too.
