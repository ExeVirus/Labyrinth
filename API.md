# Labyrinth API

## Overview

Labyrinth is a very short game, with really only two core files:

- **init.lua** `returns a single function called GenMaze (init.lua name)`
- **maze.lua** `game formspecs, global style registration function, win functions, map cleanup`

The 5 styles that come with the game are in the `styles/` folder, and provide examples for how to generate your own mazes using the API.

## maze.lua 

maze.lua implements my own version of Wilson's algorithm. This maze generation algorithm is randomly slow (statistically impossible, but it could run indefinitely), but generates truly random mazes that always have a solution, hence my selection of it.

This file purely defines the core GenMaze() function provided to init.lua. This cannot be overwritten, but should you want to use your own map generation algorithm, you can provide one when you register your style

## init.lua 

Here's everything init.lua does:

1. override the player look and hand
2. Registers an invisible block for the player to land on when they win a maze or are in the main menu
3. Defines the global style registration function `laby_register_style`
4. Loads the 5 default `styles/files.lua`
5. defines a player setup function that calls `GenMaze()`, and sets the `cleanup()` function for the selected style, then fades the music appropriately
6. Defines the `main_menu()` formspec (not overridable)
7. Defines the `pause_menu()` formspec (technically overridable as it's the player_inventory formspec, which is only set in the on_join_player at startup)
8. Defines the `OnReceiveFields()` to handle the two formspecs
9. Defines a `safe_clear()` function for cleaning up any old map data when the game is first loaded from the Minetest main menu
10. Registers an `on_joinplayer` to call the normal menu formspec and other housekeeping
11. Registers a globalstep that allows the player to win when they reach any height below -10. (which calls cleanup, and shows the normal menu)

That's it, thats the entire game functionality. Now, lets talk about actually registering your own style, which is probably why you are here:

# Registering Your Own Style

There is a single global function provided by this game: `laby_register_style`, which takes five parameters:

- **name** the name of your style
- **music_name**: music file name
- **map_from_maze** => function(maze, player)
    - *maze* is a table generated from GenMaze()
    - *player* is the player_ref to allow you to place them at the start of the maze
- **cleanup** => function(maze_w, maze_h) you must provide a function to cleanup the map, maze_w and maze_h are provided from the main menu selection screen
- **genMaze** is an optional arguement to provide your own algorithm for this style to generate maps with instead of the default GenMaze. See maze.lua for example

#### Notes about the default genMaze
It will return a table like below:
```lua
{
    ["width"]  = gwidth --global based on main menu values rounded up to the nearest odd number, see init.lua
    ["height"] = gheight
    [1] = {0,1,0,1,0},
    [2] = {0,1,0,1,0},
    [3] = {0,1,0,1,0},
    [n] = {0,1,0,1,0},
}
---Where 1's are for path and 0's for walls.
```
Note that my GenMaze function can only handle odd numbered sizes. I'm sure you'll notice that if you attempt different small custom sizes.
*Feel free to fix it for me ;) and make a PR.*

To see how maps are generated and cleaned up, use `styles/glass.lua` as an example, it is the simplest and has a lot of comments to explain the process

