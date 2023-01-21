--  ______  _
-- / _____)| |
--| /  ___ | |  ____   ___   ___
--| | (___)| | / _  | /___) /___)
--| \____/|| |( ( | ||___ ||___ |
-- \_____/ |_| \_||_|(___/ (___/

---- Node Registrations ----
minetest.register_node("labyrinth:glass_glass",
{
    description = "Glass",
    drawtype = "allfaces",
    nodebox = {
        type = "fixed",
        fixed = { -0.499,-0.499,-0.499,0.499,0.499,0.499 },
    },
    tiles = {"glass_glass.png"},
    light_source = 12,
})
---- End Node Registrations ----

local function map_function(maze, player)
    local loc_maze = maze
    --- Read the desired sizes of the maze
    width  = loc_maze.width
    height = loc_maze.height

    --Get a Lua Voxel Manip of that size 
    --see https://rubenwardy.com/minetest_modding_book/en/advmap/lvm.html for help understanding
    local vm         = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map({x=0,y=0,z=0}, {x=height+1,y=4,z=width+1})
    local data       = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    -- All nodes are stored as a 16-bit content ID in the map
    -- We need those exact numbers to manipulate the voxel manip
    local glass = minetest.get_content_id("labyrinth:glass_glass")
    local air = minetest.get_content_id("air")
    
    --Set up the level itself
    -- always go z->y->x for fastest access times (computer memory stuff)
    -- except in this case, we need to know if we're on a wall or ground section
    for z=1, width do --z
        for x=1, height do --x
            if loc_maze[x][z] == 1 then
                data[a:index(x, 0, z)] = glass --walkable maze section
            else
                for y=0,4 do
                    data[a:index(x, y, z)] = glass --wall section
                end
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)
    ---- Done making the maze ----

    --Now we need to place the player in the center of the new maze:
    
    --player target coords
    player_x = math.floor(height/2)+(math.floor(height/2)+1)%2
    player_z = math.floor(width/2)+(math.floor(width/2)+1)%2
    
    --NOTE: This is an important gotcha: slow computers
    -- Can't build the map super fast and if you don't set the player to no velocity,
    -- they could have a lot of downforce and they fall right past the not finished map and "win" instantly.
    player:set_velocity({x=0,y=0,z=0}) 
    
    --Now we can safely place the player in the maze
    player:set_pos({x=player_x,y=3,z=player_z})
end

local function cleanup(width, height)
    --Grab our voxel manip again
    local vm         = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map({x=0,y=0,z=0}, {x=height+1,y=4,z=width+1})
    local data       = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    --We only need to erase with air
    local air = minetest.get_content_id("air")
    
    --Set everything in that size to air
    for z=0, width+1 do --z
        for y=0,4 do --
            for x=0, height+1 do --x
                data[a:index(x, y, z)] = air
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map(true) --Save the new map
end

--Actually register our style with explicitly no GenMaze override 
--------------------  name  - music  -    GenMap()  - Clean() - GenMaze overide()
laby_register_style("glass" ,"glass" , map_function , cleanup ,      nil          )