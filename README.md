# Realistic Reactors Reborn — MasterShogo Fork

An independent Factorio 2.1 compatibility fork of Realistic Reactors Reborn by OwnlyMe and IngoKnieto. Original credits and licenses are retained. This build adds direct adoption; complete script-state handoff is not implemented yet.

## Switch an existing factory

Back up your save. Install this ZIP, disable RealisticReactorsReborn and enable RealisticReactorsReborn_MasterShogoFork together before loading. Do not load/save with both mods disabled in between. The two mods are declared incompatible so only one reactor simulation runs.

Existing buildings and items retain their prototype names. Reactors are adopted in place and stopped. Physical inventories, quality, modules, circuit connections, fuel progress, coolant and core temperatures are retained. Missing reactor helpers are created. Cooling towers, ruins, sarcophagi and existing fallout clouds are registered. Derived networks and GUI are rebuilt.

Custom reactor names, timers, historical graphs, fractional bonuses and items held only in the previous mod's private hidden inventories cannot be recovered by direct adoption. Ruin timing uses fresh defaults. This path prioritizes retaining a usable factory, rather than exact operating state.

The adoption dialog offers **Enable reactor controls** and **Keep stopped**. Enabling controls permits existing START circuit signals to restart the reactors. Use `/rrr-adoption` to reopen the dialog. Multiplayer acknowledgement requires an administrator. The lock persists across saves. Physical core temperatures are not reset; hot plants still need cooling.

Save under a new name after checking your plant. You do not need to rebuild it. New games operate normally.
