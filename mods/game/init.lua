--
--
--
--   Labyrinth Core Game
--
--
--

minetest.settings:set("enable_damage","false")

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
--   map_from_maze should turn on the music for the maze
-- cleanup = function (maze_w, maze_h) -- should replace maze with air
--
function register_style(name, music_name, map_from_maze, cleanup)
    numStyles = numStyles + 1
    styles[numStyles] = {}
    styles[numStyles].name = name
    styles[numStyles].music = music_name
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

--Override the default hand
minetest.register_item(":", {
	type = "none",
	wield_image = "inv.png",
	groups = {not_in_creative_inventory=1},
})



--Style Registrations
dofile(minetest.get_modpath("game") .. "/styles/classic.lua")
dofile(minetest.get_modpath("game") .. "/styles/grassy.lua")

local restart = styles[1].gen_map
local cleanup = styles[1].cleanup
local gwidth = 61
local gheight = 61
local gscroll = 0
local selectedStyle = 1
local first_load = false
local function setup(player)
    --Load up the level
    local maze = GenMaze(math.floor(gwidth/2)*2+((gwidth+1)%2),math.floor(gheight/2)*2+(gheight+1)%2)
    restart = styles[selectedStyle].gen_map
    cleanup = styles[selectedStyle].cleanup
    restart(maze, player)
    if music then
        minetest.sound_fade(music, 0.5, 0)
    end
    music = minetest.sound_play(styles[selectedStyle].music, {
        gain = 1.0,   -- default
        fade = 0.5,   -- default, change to a value > 0 to fade the sound in
        loop = true,
    })
    minetest.after(2, function() first_load = true end)
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
--quit game button
table.insert(r,"button[8,0.15;2,0.7;labyexit;Quit Labyrinth]")
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

--table.insert(r,"field[6,6.9;2,0.5;custom_w;"..minetest.colorize("#000","Width")..";"..width.."]")
--table.insert(r,"field[6,7.9;2,0.5;custom_h;"..minetest.colorize("#000","Height")..";"..height.."]")
--table.insert(r,"field_close_on_enter[custom_w;false]")
--table.insert(r,"field_close_on_enter[custom_h;false]")
--table.insert(r,"button_exit[6,8.5;2,1;custom;Custom]")

return table.concat(r);
end

local function pause_menu()
    local r = {
        "formspec_version[3]",
        "size[8,8]",
        "position[0.5,0.5]",
        "anchor[0.5,0.5]",
        "no_prepend[]",
        "bgcolor[#DFE0EDD0;both;#00000080]",
    }
    table.insert(r,"button_exit[2,0.5;4,1;game_menu;Quit to Game Menu]")
    table.insert(r,"button_exit[2,2;4,1;restart;Restart with new Map]")
    table.insert(r,"hypertext[2,3.5;4,4.25;;")
    table.insert(r,"<global halign=center color=#03A size=32 font=Regular>")
    table.insert(r,"Credits")
    table.insert(r,"<global halign=center color=#000 size=16 font=Regular>\n")
    table.insert(r,"Original Game by ExeVirus\n")
    table.insert(r,"Source code is MIT License, 2021\n")
    table.insert(r,"Media/Music is:\nCC-BY-SA, ExeVirus 2021\n")
    table.insert(r,"Music coming soon to Spotify and other streaming services!\n]")
    return table.concat(r);
end

local function to_game_menu(player)
    first_load = false
    minetest.show_formspec(player:get_player_name(), "game:main", main_menu())
    cleanup(gwidth, gheight)
    if music then
        minetest.sound_fade(music, 0.5, 0)
    end
    music = minetest.sound_play("main", {
        gain = 1.0,   -- default
        fade = 0.8,   -- default, change to a value > 0 to fade the sound in
        loop = true,
    })
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
    if formname ~= "game:main" and formname ~= "" then return end
    if formname == "" then --process the inventory formspec
        if fields.game_menu then
            minetest.after(0.05, function() to_game_menu(player) end)
        elseif fields.restart then
            local maze = GenMaze(math.floor(gwidth/2)*2+((gwidth+1)%2),math.floor(gheight/2)*2+(gheight+1)%2)
            restart(maze, player)
        end
        return
    end
    
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
    elseif fields.custom then
        if tonumber(fields.custom_w) then
            local var = math.max(math.min(tonumber(fields.custom_w), 150),5)
            gwidth = math.floor(var/2)*2+1
            minetest.chat_send_all(gwidth)
        end
        if tonumber(fields.custom_h) then
            local var = math.max(math.min(tonumber(fields.custom_h), 150),5)
            gheight  = math.floor(var/2)*2+1
        end
        setup(player)
    elseif fields.quit then
        minetest.after(0.05, function() minetest.show_formspec(player:get_player_name(), "game:main", main_menu(width_in, height_in, scroll_in)) end)
        return
    elseif fields.labyexit then
        minetest.request_shutdown("Thanks for playing!")
        return
    else
        minetest.show_formspec(player:get_player_name(), "game:main", main_menu(width_in, height_in, scroll_in))
    end
end

minetest.register_on_player_receive_fields(onRecieveFields)

local function safe_clear()
    local vm         = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map({x=0,y=0,z=0}, {x=200,y=40,z=200})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local air = minetest.get_content_id("air")
    
    --Generally a good idea to zero it out
    for z=0, 200 do --z
        for y=0,50 do --
            for x=0, 200 do --x
                data[a:index(x, y, z)] = air
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)
    
    local vm         = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map({x=-50,y=-20,z=-50}, {x=250,y=-20,z=250})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local invisible = minetest.get_content_id("game:inv")
    
    --Generally a good idea to zero it out
    for z=-50, 250 do --z
        for x=-50, 250 do --x
            data[a:index(x, -20, z)] = invisible
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)
end

minetest.register_on_joinplayer(
function(player)
    safe_clear()
    player:set_properties({
			textures = {"inv.png", "inv.png"},
			visual = "upright_sprite",
			collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.75, 0.3},
			stepheight = 0.6,
			eye_height = 1.625,
		})
    player:hud_set_flags(
        {
            hotbar = false,
            healthbar = false,
            crosshair = false,
            wielditem = false,
            breathbar = false,
            minimap = false,
            minimap_radar = false,
        }
    )
    player:set_inventory_formspec(pause_menu())
    minetest.show_formspec(player:get_player_name(), "game:main", main_menu())
    music = minetest.sound_play("main", {
        gain = 1.0,   -- default
        fade = 0.8,   -- default, change to a value > 0 to fade the sound in
        loop = true,
    })
end
)

minetest.register_globalstep(
function(dtime)
    local player = minetest.get_player_by_name("singleplayer")
    if player and first_load then
        local pos = player:get_pos()
        if pos.y < -10 then
            minetest.sound_play("win")
            to_game_menu(player)
        end
    end
end
)


