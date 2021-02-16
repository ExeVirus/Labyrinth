# Labyrinth
![screenshot](screenshot.jpg)
## An aMAZEing Minetest game

## VERSION 0.1

This is very much a work in progress, technically quite playable though. 

Just escape the maze to "win" and you'll be greeted with a new one to complete!


### Todo

1. Implement simple style registration system, allowing users to add more styles to the generated mazes (function for maze generation, name, music, and image to be used)

2. Implement Formspec-based main menu for when a player named "singleplayer" joins
    
    - Implement multiple styles in a side-scrolling selection, which is image abve the name. (selectable)
    
    - Implement 4 sizes: Easy, Medium, Hard, Custom (with associated edit boxes for the size) (selectable)
    
3. Implement Formspec based pause menu (inventory formspec) for the player named "singleplayer"
    - restart
    - main menu
    - credits text

4. Implement Win for "singleplayer" (chat message + sound) that will greet them with the main menu again, and clean up the last map.

5. Implement Main menu music. (sunth base?)

6. Implement at least 4 default styles with their own music

7. Implement invisible nodes that channel a falling player into the map, for these styles, as that will allow them to safely see every map they fall in.

8. Override the default HUD

