# Realistic Reactors Reborn — MasterShogo Fork

An independent Factorio 2.1 compatibility fork of Realistic Reactors Reborn by OwnlyMe and IngoKnieto. Original credits and licenses are retained except I added my name for the 2.1 upgrade so as not to tarnish their reputation with my mistakes.

**AI and quality disclaimer:**
This upgrade was written entirely with OpenAI Codex (GPT-6.1 Sol and GPT-6 Astra). I am a long-time professional software developer, but I do not know LUA and I have never done a Factorio mod before. I also don't have time to actually do this myself and have not done significant code review yet. So use this with that understanding. Once I'm happy that I have a stable upgrade working, I do plan to dig through the code and ensure that I'm happy with everything there, but the point here is to get this thing working with 2.1 ASAP and it looks like it is working fine for that so far.

**Compatiblity:**
It has been tested with Factorio v2.1.23 and 2.1.24 witha new Space Age game and an existing save file from Factorio v2.0, and v1 before that. That older save had Realistic Reactors, but also Space Exploration, Krastorio 2, Rampant Fixed, and a bunch of other mods. I have not encountered any errors yet. Please feel free to post about problems, though, and we can work through fixing them as I have the time.

See the original mod page for additional information about Realistic Reactors, which is a really fun mod for people who want their reactors to be more difficult and controllable:

https://mods.factorio.com/mod/RealisticReactorsReborn

See my github page for the repo and earlier builds:

https://github.com/dylanmcsweeney/RealisticReactorsReborn_MasterShogoFork


## Switch an existing factory

Besides starting with a new save, this mod is designed to work with saves with Realistic Reactors Reborn in Factorio 2.1 or earlier alpha versions of my fork in Factorio 2.0. It currently has one save file migration path.

When the save file is loaded, the mod scans the existing entities and takes ownership of RRR entities it finds, stopping them. However, some existing internal state for these entities will be lost. The mod will pop up a window explaining that you need to acknowledge that the reactors will restart if they had a start signal before and it give you the options to **Enable reactor controls** or **Keep stopped**. You can either enable that or keep it stopped and continue the game with the reactors disabled. While the game is running, you can reenable them by typing `/rrr-adoption` to reopen the dialog.

Existing buildings and items retain their prototype names. Reactors are adopted in place and stopped. Physical inventories, quality, modules, circuit connections, fuel progress, coolant and core temperatures are retained. Missing reactor helpers are created. Cooling towers, ruins, sarcophagi and existing fallout clouds are registered. Derived networks and GUI are rebuilt.

Custom reactor names, timers, historical graphs, fractional bonuses and items held only in the previous mod's private hidden inventories cannot be recovered by direct adoption. Ruin timing uses fresh defaults. This path prioritizes retaining a usable factory, rather than exact operating state. If someone would like to have their save file migrated forward with state intact, let me know and I can implement Sol's more extensive migration plan, but that will take a little more effort. I won't be writing the code, but GPT will and it was eager to do so. If no one cares, though, then I wont spend the tokens.

Save under a new name after checking your plant. New games operate normally.


## Long term intent of mod

I am happy to continue cleaning this mod up and making sure it works correctly. However, if OwnlyMe decides to upgrade it then I will happily shut down my mod. More specifically, I will ensure that the mod I have is in a state such that it can be easily migrated back to the original. Likewise, while it is not up to me anyways, anyone is totally fine to take this mod and make changes or clean things up themselves. This is all just in service of keeping a great mod alive in what will probably be the final versions of Factorio.

Feel free to ask me questions, and may the Factory grow into eternity.
