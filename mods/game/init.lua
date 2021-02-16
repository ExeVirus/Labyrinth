--
--
--
--   Labyrinth Core Game
--
--
--

local GenMaze = dofile(minetest.get_modpath("game") .. "/maze.lua")

--Style registrations

local numStyles = 0
local styles = {}
local music = nil
-------------------
-- Global function register_style(name, map_from_maze)
--
-- name: text in lowercase, typically, of the map style
-- map_from_maze = function(maze, player)
--   maze is from GenMaze() above, an input
--   player is the player_ref to place them at the start of the maze
--   map_from_maze turns on the music for the maze
-- cleanup = function (maze_w, maze_h) -- should replace maze with air
--
function register_style(name, map_from_maze, cleanup)
    numStyles = numStyles + 1
    styles[numStyles] = {}
    styles[numStyles].name = name
    styles[numStyles].gen_map = map_from_maze
    styles[numStyles].cleanup = cleanup
end

--Common node between styles
minetest.register_node("game:inv",
{
  description = "Ground Block",
  drawtype = "airlike",
  tiles = {"inv.png"},
  light_source = 11,
})

--classic style registration
dofile(minetest.get_modpath("game") .. "/styles/classic.lua")
dofile(minetest.get_modpath("game") .. "/styles/classic.lua")
dofile(minetest.get_modpath("game") .. "/styles/classic.lua")
dofile(minetest.get_modpath("game") .. "/styles/classic.lua")
dofile(minetest.get_modpath("game") .. "/styles/classic.lua")
dofile(minetest.get_modpath("game") .. "/styles/classic.lua")


local restart = styles[1].gen_map
local cleanup = styles[1].cleanup
local gwidth = 61
local gheight = 61
local gscroll = 0
local selectedStyle = 1
local first_load = false
local function setup(player)
    --Load up the level
    local maze = GenMaze(math.floor(gwidth/2)+math.floor(gwidth/2)%2+1,math.floor(gheight/2)+math.floor(gheight/2)%2+1)
    restart = styles[selectedStyle].gen_map
    cleanup = styles[selectedStyle].cleanup
    restart(maze, player)
    if music then
        minetest.sound_fade(music, 0.5, 0)
    end
    music = minetest.sound_play(styles[selectedStyle].name, {
        gain = 1.0,   -- default
        fade = 0.5,   -- default, change to a value > 0 to fade the sound in
        loop = true,
    })
    first_load = true
end

--------- GUI ------------

--Main_Menu formspec for Labyrinth
local function main_menu(width_in, height_in, scroll_in)
local width  = width_in or 57
local height  = height_in or 42
local scroll = scroll_in or 0
--Header
local r = {
    "formspec_version[3]",
    "size[11,11]",
    "position[0.5,0.5]",
    "anchor[0.5,0.5]",
    "no_prepend[]",
    "bgcolor[#DFE0EDD0;both;#00000080]",
    "box[0.5,1;10,9.5;#DDD7]",
}
--title
table.insert(r,"hypertext[1,0.1;9,2;;")
table.insert(r,"<global halign=center color=#03A size=32 font=Regular>")
table.insert(r,"Labyrinth")
table.insert(r,"<global halign=left color=#000 size=24 font=Regular>\n\n")
table.insert(r,"Level style:]")
--Scroll container containing setnames with icons:
table.insert(r,"scroll_container[0.5,2;10,2;scroll;horizontal;0.1]")
--for each set, output the icon and set_name as a button
for i=1, numStyles, 1 do
    if selectedStyle == i then
        table.insert(r,"box["..((i-1)*2+0.1)..",0.0;1.8,1.8;#0B35]")
    end
    local name = styles[i].name
    table.insert(r,"image_button["..((i-1)*2+0.25)..",0.15;1.5,1.5;"..name..".png;style"..i..";"..name.."]")
end
table.insert(r,"scroll_container_end[]")
table.insert(r,"scrollbaroptions[max="..(numStyles*20)..";thumbsize="..(numStyles*10).."]")
table.insert(r,"scrollbar[1,4;9,0.5;horizontal;scroll;"..scroll.."]")

table.insert(r,"button_exit[2,5.5;2,1;easy;Easy (40x40)]")
table.insert(r,"button_exit[6,5.5;2,1;medium;Medium (70x70)]")
table.insert(r,"button_exit[2,7;2,1;hard;Hard (120x120)]")

table.insert(r,"field[6,6.9;2,0.5;custom_w;"..minetest.colorize("#000","Width")..";"..width.."]")
table.insert(r,"field[6,7.9;2,0.5;custom_h;"..minetest.colorize("#000","Height")..";"..height.."]")
table.insert(r,"field_close_on_enter[custom_w;false]")
table.insert(r,"field_close_on_enter[custom_h;false]")
table.insert(r,"button_exit[6,8.5;2,1;custom;Custom]")

return table.concat(r);
end

----------------------------------------------------------
--
-- onRecieveFields(player, formname, fields)
--
-- player: player object 
-- formname: use provided form name
-- fields: standard recieve fields
-- Callback for on_recieve fields
----------------------------------------------------------
local function onRecieveFields(player, formname, fields)
    if formname ~= "game:main" then return end
    
    local scroll_in = 0
    local width_in = 39
    local height_in = 74
    if fields.scroll then
        scroll_in = tonumber(fields.scroll)
    end
    if fields.custom_h then
        height_in = tonumber(fields.custom_h)
    end
    if fields.custom_w then
        width_in = tonumber(fields.custom_w)
    end

    --Loop through all fields
    for name,_ in pairs(fields) do
        if string.sub(name,1,5) == "style" then
            selectedStyle = tonumber(string.sub(name,6,-1))
            --load level style
        end
    end
    if fields.easy then
        gheight = 41
        gwidth = 41
        setup(player)
    elseif fields.medium then
        gheight = 71
        gwidth = 71
        setup(player)
    elseif fields.hard then
        gheight = 121
        gwidth = 121
        setup(player)
    --If after all that, nothing is set, they used escape to quit.
    elseif fields.quit then
        minetest.after(0.05, function() minetest.show_formspec(player:get_player_name(), "game:main", main_menu(width_in, height_in, scroll_in)) end)
        return
    else
        minetest.show_formspec(player:get_player_name(), "game:main", main_menu(width_in, height_in, scroll_in))
    end
end

minetest.register_on_player_receive_fields(onRecieveFields)

local function safe_clear()
    local vm         = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map({x=0,y=0,z=0}, {x=400,y=4,z=400})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local air = minetest.get_content_id("air")
    
    --Generally a good idea to zero it out
    for z=0, 400 do --z
        for y=0,8 do --
            for x=0, 400 do --x
                data[a:index(x, y, z)] = air
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)
    
    local vm         = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map({x=0,y=-20,z=0}, {x=400,y=-20,z=400})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local invisible = minetest.get_content_id("game:inv")
    
    --Generally a good idea to zero it out
    for z=0, 400 do --z
        for x=0, 400 do --x
            data[a:index(x, -20, z)] = invisible
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)
end


minetest.register_on_joinplayer(
function(ObjectRef)
    safe_clear()
    minetest.show_formspec(ObjectRef:get_player_name(), "game:main", main_menu())
    music = minetest.sound_play("main", {
        gain = 1.0,   -- default
        fade = 0.5,   -- default, change to a value > 0 to fade the sound in
        loop = true,
    })
    
    --reset(ObjectRef)
    --ObjectRef:set_pos({x=31,y=20,z=31})
    --minetest.chat_send_all(minetest.colorize("#0F0","Escape the maze to win!"))
end
)

minetest.register_globalstep(
function(dtime)
    local player = minetest.get_player_by_name("singleplayer")
    if player and first_load then
        local pos = player:get_pos()
        if pos.y < -10 then
            minetest.sound_play("win")
            first_load = false
            minetest.show_formspec(player:get_player_name(), "game:main", main_menu())
            cleanup(gwidth, gheight)
            if music then
                minetest.sound_fade(music, 0.5, 0)
            end
            music = minetest.sound_play("main", {
                gain = 1.0,   -- default
                fade = 0.5,   -- default, change to a value > 0 to fade the sound in
                loop = true,
            })
        end
    end
end
)


