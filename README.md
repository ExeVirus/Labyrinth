# Labyrinth
![screenshot](screenshot.jpg)
## An aMAZEing Minetest game

## VERSION 0.1

This is very much a work in progress, technically quite playable though. 

Just escape the maze to "win" and you'll be greeted with a new one to complete!


### Todo

1. Implement simple style registration system, allowing users to add more styles to the generated mazes (function for maze generation, name, music, and image to be used)

2. Implement Formspec-based main menu for when a player named "singleplayer" joins

    - Implement 4 sizes: Easy, Medium, Hard, Custom (with associated edit boxes for the size) (selectable)
    
    - Implement multiple styles in a side-scrolling selection, which is image abve the name. (selectable)
    
    - Add a "Play" button to the bottom, which will take the current settings and let you play.

3. Implement Formspec based pause menu (inventory formspec) for the player named "singleplayer"

4. Implement Win for "singleplayer" that will greet them with the main menu again, and clean up the last map.

5. Implement Main menu music.

6. Implement at least 4 default styles with their own music

7. Implement invisible nodes that channel a falling player into the map, for these styles, as that will allow them to safely see every map they fall in.

8. Add a way to let them provide their own seed in the main menu for the maze generation.
