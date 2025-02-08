# Platformer Starter Library for DragonRuby

|           Example 1            |            Example 2             |
|:------------------------------:|:--------------------------------:|
| ![](/screenshots/features.gif) | ![](/screenshots/features_2.gif) |

[Try the web demo](https://lyniat.github.io/platformer-physics/) (but please keep in mind that web builds can have bad performance)

# About
Sadly there are way too many platformers out there which especially suck by having bad controls and/or physics.
This repository tries to fix this problem by offering a template based on successful implementations.

The main physics concept relies on Maddy Thorson's (known for [Towerfall](http://www.towerfall-game.com), [Celeste](http://www.celestegame.com)) [algorithm](https://maddymakesgames.com/articles/celeste_and_towerfall_physics/index.html).
Additional concepts are based on [this blog article](http://higherorderfun.com/blog/2012/05/20/the-guide-to-implementing-2d-platformers/) by Rodrigo Monteiro.

To keep development as easy as possible, without learning how to handle a complex game engine, this library uses [DragonRuby Toolkit](https://dragonruby.org/toolkit/game) as base.
You need at least the [DragonRuby standard license](https://dragonruby.itch.io/dragonruby-gtk/purchase) for development.

If you are new to game development or get stuck in development, you are always welcome to join the [official DragonRuby Discord server](discord.dragonruby.org) to ask for help.
For the case that you do not like the easy way, don't want to learn a new engine or don't like Ruby as programming language, you might port this code to any other engine or software.
If you do so, it would be cool to let me know and/or give credits to me in your product, although this is not necessary. [see license](#License)

I also really appreciate help improving this library and fixing bugs. [see support](#Support)

Finally, if you want to learn how to make great platformers by exclusion principle, have a look at some of James Rolfe's [videos](https://www.youtube.com/AngryNintendoNerd/featured).

# Get Started
## Basics
The repository is separated into two parts, the lib folder and the game folder.

The lib folder contains all the basic stuff like actor and solid handling, logic simulation, drawing and level management.
You can just keep the code as it is, if you don't want to change fundamental stuff or break things.

The game folder keeps all your game specific code and features.
To get you started fast, it includes a basic player implementation which you can adopt to your needs or delete it and write something completely new.

## Maps
The lib folder contains a *map.rb* file. It's kept as generic as possible to support different types of maps and implementations.
You can find a *map_loader.rb* file in the game's folder, which loads a csv formated (export from Tiled) map.

Since Tiled's maps have the coordinate's origin in the upper left and DragonRuby in the lower left, this code swaps the tiles coordinates to fit the generic maps coordinates.
Depending on your specific map format, you might also have to change some of the maps information to fit the generic map loader's needs.
Additionally the generic map loader needs some tile meta information to handle collisions.

It currently supports following types of tiles:
- EMPTY (they will be just drawn in background)
- SOLID
- JUMP THROUGH (you can jump through them but stay on the top)
To give the library the needed meta information, you have to store them in the *tiles.json* file.
This will probably change in future to some easier way.

## Debugging
Beside DragonRuby's debugging tools, you can press *Esc* in the sample game to show some debugging information.
Please keep in mind that these additional draw calls might reduce performance.

# Features
- pixel perfect physics and collisions based on a *solid and actor* system
- moving platforms (solids) you can stay on or climb on (without glitching through anything)
- services to time events without getting lost in counting frames
- tile based maps with a generic map importer which you can extend to import maps in every format you like
- multiple levels at the same time (calculate events, enemies, etc. without drawing them on screen)
- example player implementation which can move, jump, climb obstacles and shoot arrows
- "jump through" tiles (you can jump upwards through them and stay on top after you passed them)
- squish detection
- pixel perfect drawing
- a camera which follows any actor you like

# Planned Features / WIP
- ladder tiles which you can climb on
- liquid tiles for swimming and diving
- slopes
- half tiles
- event tiles (solids) which have an impact on actors (as the well known [Super Mario Jump Block](https://mario.fandom.com/wiki/Jump_Block))
- controller support
- camera effects like shaking
- global physics controlling (eg. have a "moon level" where everything has less gravity acceleration)
- basic pathfinding (without killing your FPS)
- physics performance mode which reduces accuracy for faster calculations
- optional z-sorting for sprites

## Known Bugs
- player's direction is sometimes wrong when climbing
- mouse position wrong depending on render size
- shift key (climbing) not working in web build

# Support
Beside reporting bugs, you can help me by suggesting new features. Keep in mind that this is a generic library.
Everything that only has rare or special use cases might fit better into your game than in this library.
However it might be worth implementing it as example.

Also worth mentioning is, that performance might suck depending on your hardware, especially the web builds.
Although there is not much space improving the physics algorithm, there might be some code parts which can be optimized.

You can reach me by creating an issue on GitHub or writing in this project related channel on the [DragonRuby Discord server](discord.dragonruby.org).
Since I'm not an english native speaker, there might be more or less misspellings in this repository.
So if something is absolutely nonsense, let me also know. 😉

# Further information and recommendations
**Tilemap editors**
- [Tiled](https://www.mapeditor.org)
- [LDtk](https://ldtk.io)

**Sprite editors**
- [Aseprite](https://www.aseprite.org)

**Sound editors**
- [Audacity](https://www.audacityteam.org)

**Collections of assets (free and paid)**
- [OpenGameArt](https://opengameart.org)
- [freesound](https://freesound.org/)
- [itch.io](https://itch.io/game-assets)

# License
- Tileset ["Adve"](https://egordorichev.itch.io/adve) by [egordorichev](https://egordorichev.itch.io) released under [CC0](https://creativecommons.org/share-your-work/public-domain/cc0/)
- code by Laurin Muth aka. lyniat released under [MIT License](/LICENSE)
- Panda sprite by [Lea Muth](https://github.com/WauWauGirly)

# Appendix
Something you always have to remember: Bad physics and controls ruin every platformer, but having good ones does not automatically mean you have a good game.
Games are more than just good code. See [Celeste](http://www.celestegame.com) as an example. Of course, physics and controls feel fantastic in this game but it offers a lot more.
Great detailed art, a brilliant soundtrack and also a profound story. This library tries to help you getting the basic gameplay done but to achieve a great game, a lot still relies on you.

