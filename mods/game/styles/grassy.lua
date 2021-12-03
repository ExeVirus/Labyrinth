--    ___
--   / _ \ _ __  __ _  ___  ___  _   _
--  / /_\/| '__|/ _` |/ __|/ __|| | | |
-- / /_\\ | |  | (_| |\__ \\__ \| |_| |
-- \____/ |_|   \__,_||___/|___/ \__, |
--                               |___/

-- Node Registrations

minetest.register_node("game:grassy_grass",
{
  description = "Ground Block",
  tiles = {"grassy_grass.png"},
  light_source = 12,
})

minetest.register_node("game:grassy_dirt",
{
  description = "Ground Block",
  tiles = {"grassy_dirt.png"},
  light_source = 12,
})

minetest.register_node("game:grassy_hedge",
{
  description = "Ground Block",
  drawtype = "allfaces",
  tiles = {"grassy_hedge.png"},
  light_source = 12,
})

--Global Variable
local wall_width = 2  ---------------------------------------------ChangeME for testing

local function map_function(maze, player)
    local loc_maze = maze
    width = loc_maze.width
    height = loc_maze.height

    --Copy to the map
    local vm         = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map({x=0,y=0,z=0}, {x=height*wall_width,y=5,z=width*wall_width})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local grass =   minetest.get_content_id("game:grassy_grass")
    local dirt   =   minetest.get_content_id("game:grassy_dirt")
    local hedge  =   minetest.get_content_id("game:grassy_hedge")
    local invisble = minetest.get_content_id("game:inv")
    local air =      minetest.get_content_id("air")
    
    --Set up the level itself
    for z=1, width do --z
        for x=1, height do --x
            if loc_maze[x][z] == 1 then
                for off_z=0, wall_width-1 do 
                    for off_x=0, wall_width-1 do
                        data[a:index(x*wall_width+off_x, 0, z*wall_width+off_z)]     = grass
                    end
                end
            else
                for off_z=0, wall_width-1 do 
                    for off_x=0, wall_width-1 do
                        data[a:index(x*wall_width+off_x, 0, z*wall_width+off_z)]     = dirt
                    end
                end
                for y=1,4 do
                    for off_z=0, wall_width-1 do 
                        for off_x=0, wall_width-1 do
                            data[a:index(x*wall_width+off_x, y, z*wall_width+off_z)]     = hedge
                        end
                    end
                end
            end
            -------------------------------------------------------Adds a roof
            for off_z=0, wall_width-1 do 
                for off_x=0, wall_width-1 do
                    data[a:index(x*wall_width+off_x, 5, z*wall_width+off_z)]     = hedge
                end
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)
    
    --player target coords
    player_x = (math.floor(height/2)+(math.floor(height/2)+1)%2)*wall_width
    player_z = (math.floor(width/2)+(math.floor(width/2)+1)%2)*wall_width
    
    --Lets now overwrite the channel for the player to fall into:
    local emin, emax = vm:read_from_map({x=player_x-1,y=4,z=player_z-1}, {x=player_x+1,y=32,z=player_z+1})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    for y=5,32 do
        for x=player_x-1, player_x+1 do
            for z=player_z-1, player_z+1 do
                data[a:index(x, y, z)] = air
            end
        end
        --Add the invisible channel
        data[a:index(player_x-1, y, player_z)] = invisble
        data[a:index(player_x+1, y, player_z)] = invisble
        data[a:index(player_x, y, player_z-1)] = invisble
        data[a:index(player_x, y, player_z+1)] = invisble
    end
    vm:set_data(data)
    vm:write_to_map(true)
    
    --Finally, move  the player
    player:set_velocity({x=0,y=0,z=0})
    player:set_pos({x=player_x,y=32,z=player_z})
end

local function cleanup(width, height)
    --Copy to the map
    local vm         = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map({x=0,y=0,z=0}, {x=height*wall_width+1,y=4,z=width*wall_width+1})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local air = minetest.get_content_id("air")
    
    --zero it out
    for z=0, width*wall_width+1 do --z
        for y=0,4 do --
            for x=0, height*wall_width+1 do --x
                data[a:index(x, y, z)] = air
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)
    
    --player target coords
    player_x = (math.floor(height/2)+(math.floor(height/2)+1)%2)*wall_width
    player_z = (math.floor(width/2)+(math.floor(width/2)+1)%2)*wall_width
    
    --Lets now overwrite the channel for the player to fall into:
    local emin, emax = vm:read_from_map({x=player_x-1,y=4,z=player_z-1}, {x=player_x+1,y=32,z=player_z+1})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    for y=5,32 do
        for x=player_x-1, player_x+1 do
            for z=player_z-1, player_z+1 do
                data[a:index(x, y, z)] = air
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)
end

laby_register_style("grassy","grassy", map_function, cleanup)
