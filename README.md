# Brainstorm Plus

An unofficial fork of [Brainstorm](https://github.com/OceanRamen/Brainstorm) by OceanRamen, a quality-of-life mod for Balatro. This fork is not made or endorsed by OceanRamen. All credit for the original mod goes to its author and contributors.

Based on Brainstorm v1.1.0-alpha (the `master` branch). Licensed under the Mozilla Public License 2.0, like the original (see `LICENSE`). `nativefs.lua` keeps its own MIT notice.

## What this fork changes

**Fixes**
- Auto-reroll now uses the same tag pool as the game. With the Multiplayer mod installed, Brainstorm counted that mod's tags, which the game removes from the pool, so most seeds it stopped on did not have the tag you asked for.
- The Soul check now stops at the first Soul in a pack, as the game does, so a second-Soul search reads the right rolls.

**New auto-reroll options**
- **Tag Count**: find the same tag on both Ante 1 skips.
- **First and Second Soul Legendary**: choose which Legendary each Soul gives. Two different picks count in either order.
- **Rare Tag Joker**: find a seed where a Rare Tag on an Ante 1 skip gives a chosen Joker (Blueprint or Brainstorm).

**Changed default**: the search pack now starts on None.

## Limits

- Rare Tag Joker is ignored when Tag Count is 2, because both skips are then taken by the search tag.
- A locked Joker can't come from the Rare Tag, so the search stops with a message.
- Stickers on Jokers at higher stakes are not predicted.
- Search Pack looks at the shop only, not at packs from tags.
- Other mods that change the tag or Joker pools can make predictions wrong. Only the Multiplayer mod's changes are handled.
- Long searches, such as two chosen Legendaries, can take a while.
- Tested on macOS with the Steam version, Steamodded and Multiplayer 0.5.5. Not yet tested on Windows.

Seed searching is meant for solo runs. Don't use it to get an edge over other players.

Provided as is. Issues are welcome, but updates are not guaranteed.

## Requirements
- [Lovely](https://github.com/ethangreen-dev/lovely-injector) injector -- Get it here: https://github.com/ethangreen-dev/lovely-injector/releases

## Installation

1. Install [Lovely](https://github.com/ethangreen-dev/lovely-injector) and follow the manual installation instructions.

### Windows

2. Download the [latest release](https://github.com/fredmorinmibu/Brainstorm/releases/) of Brainstorm Plus.
3. Remove any existing Brainstorm folder, then unzip the file, and place it in `.../%appdata%/balatro/mods` -- The folder must be named `Brainstorm`
4. Reload the game to activate the mod.

### Macos

2. Download the [latest release](https://github.com/fredmorinmibu/Brainstorm/releases/) of Brainstorm Plus.
3. Remove any existing Brainstorm folder from `/Users/$USER/Library/Application Support/Balatro/Mods`, then unzip the file there.
4. Check that the new folder's name is `Brainstorm`, and that there is only one copy. If you see `Brainstorm 2`, the old folder is still there. Two copies crash the game.
5. Reload the game to activate the mod.

## Features
### Save-States
Brainstorm has the capability to save up to 5 save-states through the use of in-game key binds. 
> To create a save-state: Hold `z + 1-5`
> To load a save-state:	Hold `x + 1-5`

Each number from 0 - 5 corresponds to a save slot. To overwrite an old save, simply create a new save-state in it's slot. 

### Fast Rerolling
Brainstorm allows for super-fast rerolling through the use of an in-game key bind. 
> To fast-roll:	Press `Ctrl + t`

### Auto-Rerolling
Brainstorm can automatically reroll for parameters as specified by the user.
You can edit the Auto-Reroll parameters in the Brainstorm in-game settings page.
> To Auto-Reroll:	Press `Ctrl + a`
