--    ___
--   / _ \ _ __  __ _  ___  ___  _   _
--  / /_\/| '__|/ _` |/ __|/ __|| | | |
-- / /_\\ | |  | (_| |\__ \\__ \| |_| |
-- \____/ |_|   \__,_||___/|___/ \__, |
--                               |___/

-- Node Registrations

minetest.register_node("labyrinth:grassy_grass",
{
  description = "Ground Block",
  tiles = {"grassy_grass.png"},
  light_source = 12,
})

minetest.register_node("labyrinth:grassy_dirt",
{
  description = "Ground Block",
  tiles = {"grassy_dirt.png"},
  light_source = 12,
})

minetest.register_node("labyrinth:grassy_hedge",
{
  description = "Ground Block",
  drawtype = "allfaces",
  tiles = {"grassy_hedge.png"},
  light_source = 12,
})

local function map_function(maze, player)
    local loc_maze = maze
    width = loc_maze.width
    height = loc_maze.height

    --Copy to the map
    local vm         = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map({x=0,y=0,z=0}, {x=height*2,y=4,z=width*2})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local grass =   minetest.get_content_id("labyrinth:grassy_grass")
    local dirt   =   minetest.get_content_id("labyrinth:grassy_dirt")
    local hedge  =   minetest.get_content_id("labyrinth:grassy_hedge")
    local invisble = minetest.get_content_id("labyrinth:inv")
    local air =      minetest.get_content_id("air")

    --Set up the level itself
    for z=1, width do --z
        for x=1, height do --x
            if loc_maze[x][z] == 1 then
                data[a:index(x*2, 0, z*2)]     = grass
                data[a:index(x*2+1, 0, z*2)]   = grass
                data[a:index(x*2+1, 0, z*2+1)] = grass
                data[a:index(x*2, 0, z*2+1)]   = grass
            else
                data[a:index(x*2, 0, z*2)]     = dirt
                data[a:index(x*2+1, 0, z*2)]   = dirt
                data[a:index(x*2+1, 0, z*2+1)] = dirt
                data[a:index(x*2, 0, z*2+1)]   = dirt
                for y=1,4 do
                    data[a:index(x*2,   y, z*2)]   = hedge
                    data[a:index(x*2+1, y, z*2)]   = hedge
                    data[a:index(x*2+1, y, z*2+1)] = hedge
                    data[a:index(x*2,   y, z*2+1)] = hedge
                end
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)

    --player target coords
    player_x = (math.floor(height/2)+(math.floor(height/2)+1)%2)*2
    player_z = (math.floor(width/2)+(math.floor(width/2)+1)%2)*2

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
    local emin, emax = vm:read_from_map({x=0,y=0,z=0}, {x=height*2+1,y=4,z=width*2+1})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local air = minetest.get_content_id("air")

    --zero it out
    for z=0, width*2+1 do --z
        for y=0,4 do --
            for x=0, height*2+1 do --x
                data[a:index(x, y, z)] = air
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)

    --player target coords
    player_x = (math.floor(height/2)+(math.floor(height/2)+1)%2)*2
    player_z = (math.floor(width/2)+(math.floor(width/2)+1)%2)*2

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
