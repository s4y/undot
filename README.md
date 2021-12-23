# undot

Quick hack to hide the full screen microphone dot on macOS 12.

## Usage

To build:

```sh
git clone https://github.com/s4y/undot
cd undot
swiftc undot.swift
```

To run:

```sh
while :; do ./undot; sleep 1; done
```

The first time you run it, you might need to allow accessibility API access in System Preferences. Do this. You can ignore the message asking you to restart your terminal.
