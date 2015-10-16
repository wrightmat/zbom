This package contains the data files of the quest Zelda: Book of Mudora.
This quest is a free, open-source game that works with Solarus,
an open-source Zelda-like 2D game engine.
To play this game, you need Solarus. The compiled engine is included for Windows and Linux.

The game is currently in version 0.47 (01-SEP-15, Solarus v1.4.4)

To run:
  Windows: execute "solarus.exe"
  Linux: download executable or compile source available at http://www.solarus-games.org (see compile instruction below)
  Mac: download executable or compile source available at http://www.solarus-games.org

To play: Default button mapping:
  "X" to use/assign left grey circle item and "V" to use/assign right grey circle item.
  "C" for green circle (sword or skip in dialogs).
  "Space" for blue circle (action or back in dialogs).
  "D" for Pause menu (or to exit pause). Left or right arrows to scroll between items and submenus.
  Buttons can be remapped (to other keys or joypad buttons) from within the Options submenu.
  Control key allows you to pan the camera slightly.

See our website http://sites.google.com/site/zeldabom for more information.

Enjoy!

VERSION 0.49, released 16-OCT-15
  - Credits sequence implemented
  - Interloper Sanctum basement is fully playable - may still be bugs to work out
  - Final boss is working, but there may be tweaks in the next version
  - Improvements to main font to allow for non-English translation (more to come)

VERSION 0.48, released 06-OCT-15
  - New dialog box styles for wooden and stone signs
  - Improved ocarina warp points which include visual indication of discovery
  - Simpler map for North Hyrule (LttP style)
  - A lot of work on the final dungeon - almost done!
  - Starting work on final bosses and closing sequence
  - Opening (dream) sequence implemented
  - Add minigame before monkey will give back Book page
  - HUD icons for hero conditions (exhaustion, cursed, poison, etc.)
  - Hints and fixes


VERSION 0.47 released 01-SEP-15
  - Work on last two dungeons - Tower of Winds is fully playable, Interloper Sanctum is not
  - Allow ice cane to freeze water as well as lava
  - Enabled more waterway swimming and added a few secrets
  - Corrected behavior of ice cane and creating/pushing ice blocks (could still use a little tweaking)
  - Fully scripted bow/arrows to allow two different types of arrows and better behavior
  - Fully scripted hookshot to allow more configurable behavior
  - Starting to add more Hylian NPCs for North Hyrule and a few other areas

VERSION 0.46 released 17-AUG-15
  - Show temporary HUD popup when collectible is picked
  - Fully implemented red and blue tunics
  - Finished advanced maps for last two dungeons
  - Dynamically determine Book variant to give so dungeons can be truly done in any order
  - Implement shovel and soft soil
  - Implement ability to make and buy advanced potions
  - Additional or improved enemies
  - Additional heart pieces
  - Begin implementation of hammer
  - Optimization of scripts and sprites
  - Implement camera movement with control key

VERSION 0.45 released 16-JUL-15
  - Added dungeon exploration mechanic and advanced compass (with secret chime) [still in progress]
  - Display clouds when in North Hyrule or Subrosia without upgraded map, added map for Subrosia
  - Updated dungeon maps for Sewers and Grove to correctly show doors and rooms
  - Added content to second floor of Hyrule Castle
  - Fixed night overlay not displaying correctly and updated other overlay code
  - Added capability to have color text dialogs and starting colorizing existing dialogs [still in progress]
  - Added enemies to North Hyrule field in order to discourage early exploration

VERSION 0.44 released 2-JUL-15:
  - core path of wind tower finish - able to obtain book
  - additional warp points
  - short cut added to Pyramid
  - additional player direction from NPCs, including new attendant in council office
  - trading sequence finished - able to obtain feather
  - lost woods expanded
  - dialog font replaced and dialog line breaks redone to utilize additional space
  - sprite, tile and script fixes thoughout

VERSION 0.43 released 17-JUN-15:
  - added NPC dialogs, signs and other markers to assist player
  - additional enemy types and overworld bosses
  - additional warp points, heart pieces, and trading sequence
  - mapping of north hyrule and wind tower
  - bug fixes

VERSION 0.42 released 21-MAY-15:
  - migration to Solarus v1.4.2
  - big fixes to the engine

VERSION 0.40 released 03-MAY-15:
  - migration to Solarus v1.4
  - mapping of more areas
  - Stamina system implemented (similar to magic bar, but decreases on any action performed)
  - Somaria cane creates ice blocks which actually act like ice
  - more fixes to map transitions and general bugs

VERSION 0.32 released 24-MAR-15:
  - expansion of trading sequence and Great Fairy quests
  - mapping of more areas
  - finished fifth and sixth dungeons
  - multiple fixes to map transitions, general bugs

VERSION 0.31 released 2-FEB-15:
  - multiple map fixes to prevent getting stuck in trees during map transitions - some still to fix
  - fixes to intro to prevent hero from being able to visit other maps


--------
Contents
--------

1  Play directly
2  Installation instructions
  2.1  Default settings
  2.2  Change the install directory

----------------
1  Play directly
----------------

You need to specify to the solarus binary the path of the quest data files to
use. solarus accepts two forms of quest paths:
- a directory having a subdirectory named "data" with all data inside,
- a directory having an archive "data.solarus" with all data inside.

Thus, to run zbom, if the current directory is the one that
contains the "data" subdirectory (and this readme), you can type

$ solarus .

or without arguments:

$ solarus

if solarus was compiled with the default quest set to ".".

--------------------
2  Install the quest
--------------------

2.1  Default settings
----------------------

If you want to install zbom, cmake and zip are recommended.
Just type

$ cmake .
$ make

This generates the "data.solarus" archive that contains all data files
of the quest. You can then install it with

# make install

This installs the following files (assuming that the install directory
is /usr/local):
- the quest data archive ("data.solarus") in /usr/local/share/solarus/zbom/
- a script called "zbom" in /usr/local/bin/

The zbom script launches solarus with the appropriate command-line argument
to specify the quest path.
This means that you can launch the zbom quest with the command:

$ zbom

which is equivalent to:

$ solarus /usr/local/share/solarus/zbom

3.2  Change the install directory
---------------------------------

You may want to install zbom in another directory
(e.g. so that no root access is necessary). You can specify this directory
as a parameter of cmake:

$ cmake -D CMAKE_INSTALL_PREFIX=/home/your_directory .
$ make
$ make install

This installs the files described above, with the
/usr/local prefix replaced by the one you specified.
The script generated runs solarus with the appropriate quest path.
