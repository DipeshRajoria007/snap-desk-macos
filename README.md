# SnapDesk

> Because apparently dragging windows around is the hardest part of my job.

## The Problem Nobody Asked Me About (But I'm Telling You Anyway)

You know what's fun? Spending the first 15 minutes of your workday arranging windows like you're playing Tetris — except nobody's impressed and there's no high score.

At the office, I've got my perfect setup: Slack on the left, browser on the right, terminal floating somewhere it shouldn't be. *Chef's kiss.* Life is good.

Then I go home. Different monitor. Different resolution. Different arrangement. Every. Single. Window. is piled on top of each other like a digital car crash. So I spend another 15 minutes dragging things around while questioning my life choices.

And then the next morning? Back at the office. Repeat the ritual. Drag. Resize. Snap. Cry a little.

Some days I switch monitors 2-3 times. That's 30-45 minutes of my life — gone. Not to debugging. Not to meetings. To **dragging rectangles across a screen.** My mood? Destroyed. My productivity? Somewhere under that pile of overlapping windows.

So I did what any sane developer would do: spent an entire evening building an app to solve a 15-minute problem. Totally worth it.

## What It Does

SnapDesk lives in your menubar (because it respects your Dock space, unlike some apps). It does exactly two things:

1. **Remembers** where your windows are — which screen, which position, which size
2. **Puts them back** when you tell it to

That's it. No AI. No subscription. No "syncing with the cloud." Just rectangles going where they belong.

## Features

- **Profiles** — Save layouts like "Office Setup", "Home Desk", "Pretending To Work"
- **Multi-monitor aware** — Knows the difference between your office ultrawide and your home monitor
- **Screen reconnection** — Plug your monitor back in, hit restore, windows teleport to where they belong
- **No UI** — Lives in the menubar. No dock icon. No main window. It's basically invisible until you need it
- **Skips gracefully** — App not running? Screen not connected? It just skips it instead of throwing a tantrum

## Installation

```bash
git clone https://github.com/DipeshRajoria007/snap-desk-macos.git
cd snap-desk-macos
./build.sh
open .build/release/SnapDesk.app
```

Or if you want it in Applications:

```bash
cp -r .build/release/SnapDesk.app /Applications/
```

### Requirements

- macOS 13.0+ (Ventura or later)
- Swift 5.9+
- **Accessibility permission** — The app will ask on first launch. Yes, you have to trust it. No, it's not spying on you. It literally just moves your windows.

## Usage

1. Click the SnapDesk icon in your menubar (the little rectangles icon)
2. Arrange your windows however you like
3. Click **"Save Current Layout..."** and give it a name
4. Later, when everything is a mess again (give it 5 minutes), click the profile name
5. Watch your windows snap back into place
6. Feel a brief moment of satisfaction before your next meeting

## Tech Stack

- Swift + SwiftUI
- Accessibility API (AXUIElement) — for bossing windows around
- CoreGraphics — for knowing which monitor is which
- JSON file storage — profiles saved at `~/.snapdesk/profiles.json`
- Zero dependencies — because `node_modules` has hurt me enough

## License

Do whatever you want with it. If it saves you even one window-dragging session, we're even.
