-- ██╗      █████╗ ██████╗ ██╗   ██╗██████╗ ██╗███╗   ██╗████████╗██╗  ██╗
-- ██║     ██╔══██╗██╔══██╗╚██╗ ██╔╝██╔══██╗██║████╗  ██║╚══██╔══╝██║  ██║
-- ██║     ███████║██████╔╝ ╚████╔╝ ██████╔╝██║██╔██╗ ██║   ██║   ███████║
-- ██║     ██╔══██║██╔══██╗  ╚██╔╝  ██╔══██╗██║██║╚██╗██║   ██║   ██╔══██║
-- ███████╗██║  ██║██████╔╝   ██║   ██║  ██║██║██║ ╚████║   ██║   ██║  ██║
-- ╚══════╝╚═╝  ╚═╝╚═════╝    ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝
-- Ascii art font: ANSI Shadow, All acii art from patorjk.com/software/taag/
--
-- The code for labyrinth is licensed as follows:
-- MIT License, ExeVirus (c) 2021
--
-- Please see the LICENSE file for texture licenses


--Settings Changes --
--BE VERY CAREFUL WHEN PLAYING WITH OTHER PEOPLES SETTINGS--
minetest.settings:set("enable_damage","false")
local max_block_send_distance = minetest.settings:get("max_block_send_distance")
local block_send_optimize_distance = minetest.settings:get("block_send_optimize_distance")
if max_block_send_distance == 31 then -- no one would set these to 31, so it must have been a crash,
    max_block_send_distance = 8       -- and we should revert to defaults on proper shutdown
end
if block_send_optimize_distance == 31 then
    block_send_optimize_distance = 4
end
minetest.settings:set("max_block_send_distance","30")
minetest.settings:set("block_send_optimize_distance","30")
minetest.register_on_shutdown(function()
    minetest.settings:set("max_block_send_distance",tostring(max_block_send_distance))
    minetest.settings:set("block_send_optimize_distance",tostring(block_send_optimize_distance))
end)
--End Settings Changes--

--Load our Settings--
local function handleColor(settingtypes_name, default)
    return minetest.settings:get(settingtypes_name) or default
end
local primary_c              = handleColor("laby_primary_c",              "#06EF")
local hover_primary_c        = handleColor("laby_hover_primary_c",        "#79B1FD")
local on_primary_c           = handleColor("laby_on_primary_c",           "#FFFF")
local secondary_c            = handleColor("laby_secondary_c",            "#FFFF")
local hover_secondary_c      = handleColor("laby_hover_secondary_c",      "#AAAF")
local on_secondary_c         = handleColor("laby_on_secondary_c",         "#000F")
local background_primary_c   = handleColor("laby_background_primary_c",   "#F0F0F0FF")
local background_secondary_c = handleColor("laby_background_secondary_c", "#D0D0D0FF")
--End Settings Load

local modpath = minetest.get_modpath("labyrinth")

local DefaultGenerateMaze = dofile(modpath .. "/maze.lua")
local GenMaze = DefaultGenerateMaze

-- Set mapgen to singlenode if not already

minetest.set_mapgen_params('mgname', 'singlenode', true)


-- Compatibility aliases

for _, node in ipairs({
	"inv",
	"cave_ground", "cave_torch", "cave_rock",
	"classic_ground", "classic_wall",
	"club_walkway", "club_wall", "club_ceiling", "club_edge", "club_light", "club_ground",
	"glass_glass",
	"grassy_dirt", "grassy_hedge", "grassy_grass",
}) do
	minetest.register_alias("game:" .. node, "labyrinth:" .. node)
end


--Style registrations

local numStyles = 0
local styles = {}
local music = nil

-------------------
-- Global function laby_register_style(name, music_name, map_from_maze, cleanup, genMaze)
--
-- name: text in lowercase, typically, of the map style
-- music_name: music file name
-- map_from_maze = function(maze, player)
--   maze is from GenMaze() above, an input
--   player is the player_ref to place them at the start of the maze
-- cleanup = function (maze_w, maze_h) -- should replace maze with air
-- genMaze is an optional arguement to provide your own algorithm for this style to generate maps with
--
function laby_register_style(name, music_name, map_from_maze, cleanup, genMaze)
    numStyles = numStyles + 1
    styles[numStyles] = {}
    styles[numStyles].name = name
    styles[numStyles].music = music_name
    styles[numStyles].gen_map = map_from_maze
    styles[numStyles].cleanup = cleanup
    styles[numStyles].genMaze = genMaze
end

--Common node between styles, used for hidden floor to fall onto
minetest.register_node("labyrinth:inv",
{
  description = "Ground Block",
  drawtype = "airlike",
  tiles = {"blank.png"},
  light_source = 11,
})

--Override the default hand
minetest.register_item(":", {
	type = "none",
	wield_image = "blank.png",
	groups = {not_in_creative_inventory=1},
	range = 0
})

--Style Registrations
dofile(modpath .. "/styles/classic.lua")
dofile(modpath .. "/styles/grassy.lua")
dofile(modpath .. "/styles/glass.lua")
dofile(modpath .. "/styles/cave.lua")
dofile(modpath .. "/styles/club.lua")

local restart = styles[1].gen_map
local cleanup = styles[1].cleanup
local gwidth = 57
local gheight = 42
local gscroll = 0
local selectedStyle = 1
local first_load = false
local function setup(player)
    if styles[selectedStyle].genMaze ~= nil and type(styles[selectedStyle].genMaze) == "function" then
        GenMaze = styles[selectedStyle].genMaze
    else
        GenMaze = DefaultGenerateMaze
    end
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

--used to make this formspec easier to read
local function table_concat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

--Main_Menu formspec function for Labyrinth
local function main_menu(width_in, height_in, scroll_in)
    local width  = width_in or gwidth
    local height  = height_in or gheight
    local scroll = scroll_in or 0

    --Main Menu Formspec "r"
    local r = {
        "formspec_version[3]",
        "size[11,11]",
        "position[0.5,0.5]",
        "anchor[0.5,0.5]",
        "no_prepend[]",
        "bgcolor[",background_primary_c,";both;#AAAAAA40]",
        "box[0,0;11,1;",primary_c,"]",
        "style_type[button;border=false;bgimg=back.png^[multiply:",secondary_c,";bgimg_middle=10,3;textcolor=",on_secondary_c,"]",
        "style_type[button:hovered;bgcolor=",hover_secondary_c,"]",
        "hypertext[1,0.08;9,5;;<global halign=center color=",on_primary_c," size=36 font=Regular>Labyrinth]",
        "hypertext[0.5,1.2;9,5;;<global halign=left color=",on_secondary_c," size=24 font=Regular>Level style:]\n",
        "button[7.5,0.15;3.3,0.7;labyexit;Quit Labyrinth]",
        "box[0.5,1.9;10,2.1;",background_secondary_c,"]",
        "scroll_container[0.5,2;10,2;scroll;horizontal;0.2]",
    }
    --for each set, output the icon and set_name as a button
    for i=1, numStyles, 1 do
        if selectedStyle == i then
            table.insert(r,"box["..((i-1)*2+0.1)..",0.0;1.8,1.8;#0B35]") --hardcoded color, sorry
        end
        local name = styles[i].name
        table.insert(r,"image_button["..((i-1)*2+0.25)..",0.15;1.5,1.5;"..name..".png;style"..i..";"..name.."]")
    end
    table.insert(r,"scroll_container_end[]")
    table.insert(r,"scrollbaroptions[max="..tostring((numStyles - 5) * 10)..";thumbsize="..tostring((numStyles - 5) * 2.5).."]")
    local r2 = {
        "scrollbar[0.5,4;10,0.5;horizontal;scroll;",tostring(scroll),"]",
        "style_type[button;border=false;bgimg=back.png^[multiply:",primary_c,";bgimg_middle=10,10;textcolor=",on_primary_c,"]",
        "style_type[button:hovered;bgimg=back.png^[multiply:",hover_primary_c,";bgcolor=#FFF]",
        "button_exit[3.5,4.75;4,1;easy;Easy (40x40)]",
        "button_exit[3.5,6;4,1;medium;Medium (70x70)]",
        "button_exit[3.5,7.25;4,1;hard;Hard (120x120)]",
        "box[0.5,8.75;10,0.1;",background_secondary_c,"]",
        "style_type[field;border=false;font_size=16;textcolor=",on_secondary_c,"]",
        "style_type[label;textcolor=",on_secondary_c,"]",
        "box[0.5,9.4;2,0.6;",background_secondary_c,"]",
        "box[0.5,9.93;2,0.07;",primary_c,"]",
        "label[0.5,9.2;Width]",
        "field[0.55,9.5;2,0.5;custom_w;;",width,"]",
        "label[2.67,9.75;x]",
        "box[3,9.4;2,0.6;",background_secondary_c,"]",
        "box[3,9.93;2,0.07;",primary_c,"]",
        "label[3,9.2;Height]",
        "field[3.05,9.5;2,0.5;custom_h;;",height,"]",
        "field_close_on_enter[custom_w;false]",
        "field_close_on_enter[custom_h;false]",
        "button_exit[5.5,9.3;4,0.8;custom;Custom]",
    }
    table_concat(r,r2)
    return table.concat(r);
end

local function pause_menu()
    local r = {
        "formspec_version[3]",
        "size[8,8]",
        "position[0.5,0.5]",
        "anchor[0.5,0.5]",
        "no_prepend[]",
        "bgcolor[",background_primary_c,";both;#AAAAAA40]",
        "style_type[button;border=false;bgimg=back.png^[multiply:",primary_c,";bgimg_middle=10,10;textcolor=",on_primary_c,"]",
        "style_type[button:hovered;bgimg=back.png^[multiply:",hover_primary_c,";bgcolor=#FFF]",
        "button_exit[0.6,0.5;6.8,1;game_menu;Quit to Game Menu]",
        "button_exit[0.6,2;6.8,1;restart;Restart with new Map]",
        "hypertext[2,3.5;4,4.25;;<global halign=center color=",primary_c," size=32 font=Regular>Credits<global halign=center color=",on_secondary_c," size=16 font=Regular>\n",
        "Original Game by ExeVirus\n",
        "Source code is MIT License, 2021\n",
        "Media/Music is:\nCC-BY-SA, ExeVirus 2021\n",
        "Music coming soon to Spotify and other streaming services!]",
    }
    return table.concat(r)
end

local function to_game_menu(player)
    first_load = false
    minetest.show_formspec(player:get_player_name(), "labyrinth:main", main_menu())
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
    if formname ~= "labyrinth:main" and formname ~= "" then return end
    if formname == "" then --process the inventory formspec
        if fields.game_menu then
            minetest.after(0.15, function() to_game_menu(player) end)
        elseif fields.restart then
            cleanup(gwidth, gheight)
            local maze = GenMaze(math.floor(gwidth/2)*2+((gwidth+1)%2),math.floor(gheight/2)*2+(gheight+1)%2)
            restart(maze, player)
        end
        return
    end

    local scroll_in = 0
    local width_in = 39
    local height_in = 74
    if fields.scroll then
        scroll_in = tonumber(minetest.explode_scrollbar_event(fields.scroll).value)
    end
    if fields.custom_h then
        height_in = tonumber(fields.custom_h)
    end
    if fields.custom_w then
        width_in = tonumber(fields.custom_w)
    end

    --Loop through all fields for level selected
    for name,_ in pairs(fields) do
        if string.sub(name,1,5) == "style" then
            local newStyle = tonumber(string.sub(name,6,-1))
            if newStyle ~= selectedStyle then --load level style
                selectedStyle = newStyle
                minetest.show_formspec(player:get_player_name(), "labyrinth:main", main_menu(width_in, height_in, scroll_in))
            end
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
            local var = math.max(math.min(tonumber(fields.custom_w), 125),5)
            gwidth = var
        end
        if tonumber(fields.custom_h) then
            local var = math.max(math.min(tonumber(fields.custom_h), 125),5)
            gheight  = var
        end
        setup(player)
    elseif fields.quit then
        minetest.after(0.10, function() minetest.show_formspec(player:get_player_name(), "labyrinth:main", main_menu(width_in, height_in, scroll_in)) end)
        return
    elseif fields.labyexit then
        minetest.request_shutdown("Thanks for playing!")
        return
    else
        --minetest.show_formspec(player:get_player_name(), "labyrinth:main", main_menu(width_in, height_in, scroll_in))
    end
end

minetest.register_on_player_receive_fields(onRecieveFields)

local function safe_clear(w, l)
    local vm         = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map({x=-10,y=-11,z=-10}, {x=w,y=10,z=l})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local invisible = minetest.get_content_id("labyrinth:inv")
    local air = minetest.get_content_id("air")

    for z=0, l-10 do --z
        for y=0,10 do --y
            for x=0, w-10 do --x
                data[a:index(x, y, z)] = air
            end
        end
    end

    for z=-10, l do --z
        for x=-10, w do --x
            data[a:index(x, -11, z)] = invisible
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)
end

minetest.register_on_joinplayer(
function(player)
    safe_clear(300,300)
    player:set_properties({
			textures = {"blank.png", "blank.png"},
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
    minetest.show_formspec(player:get_player_name(), "labyrinth:main", main_menu())
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
            minetest.chat_send_all(minetest.colorize(primary_c,"Congrats on finishing ".. styles[selectedStyle].name).. "!")
            to_game_menu(player)
        end
    end
end
)
