# LootSounds

An addon that plays sounds when the player loots items, currency, tokens, or
other loot-worthy events. Each sound and event is configurable through an in
game interface. It comes bundled with a Zelda soundpack and easily extended by
additional addons.

## About

This was inspired by the wonderful ZeldaLoot addon that has been abandoned. My
goal was to create pluggable soundpacks with the hope that people would create
their own.

## Creating new packs

See the included LootSounds_Zelda addon for an example of how to create sound 
packs.

## TODO:

 * Should sound packs provide profile defaults
 * The sort order for sounds needs to be fixed
 * The core logic needs to be simplified where possible
 * Code needs to be commented much better
 * Should LibSharedMedia be used instead
  * Benefit from existing sounds
  * Lose customization of names, durations, etc.
