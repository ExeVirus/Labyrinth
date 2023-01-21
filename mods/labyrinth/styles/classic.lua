--  _____  _                   _
-- /  __ \| |                 (_)
-- | /  \/| |  __ _  ___  ___  _   ___
-- | |    | | / _` |/ __|/ __|| | / __|
-- | \__/\| || (_| |\__ \\__ \| || (__
--  \____/|_| \__,_||___/|___/|_| \___|

-- Node Registrations

minetest.register_node("labyrinth:classic_ground",
{
  description = "Ground Block",
  tiles = {"classic_ground.png"},
  light_source = 11,
})

minetest.register_node("labyrinth:classic_wall",
{
  description = "Ground Block",
  tiles = {"classic_wall.png"},
  light_source = 11,
})

local function map_function(maze, player)
    local loc_maze = maze
    width = loc_maze.width
    height = loc_maze.height

    --Copy to the map
    local vm         = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map({x=0,y=0,z=0}, {x=height+1,y=4,z=width+1})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local ground =   minetest.get_content_id("labyrinth:classic_ground")
    local wall =     minetest.get_content_id("labyrinth:classic_wall")
    local invisble = minetest.get_content_id("labyrinth:inv")
    local air =      minetest.get_content_id("air")
    
    --Set up the level itself
    for z=1, width do --z
        for x=1, height do --x
            if loc_maze[x][z] == 1 then
                data[a:index(x, 0, z)] = ground
            else
                for y=1,4 do
                    data[a:index(x, y, z)] = wall
                end
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)
    
    --player target coords
    player_x = math.floor(height/2)+(math.floor(height/2)+1)%2
    player_z = math.floor(width/2)+(math.floor(width/2)+1)%2
    
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
    local emin, emax = vm:read_from_map({x=0,y=0,z=0}, {x=height+1,y=4,z=width+1})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local ground =   minetest.get_content_id("labyrinth:classic_ground")
    local wall =     minetest.get_content_id("labyrinth:classic_wall")
    local invisble = minetest.get_content_id("labyrinth:inv")
    local air =      minetest.get_content_id("air")
    
    --Generally a good idea to zero it out
    for z=0, width+1 do --z
        for y=0,4 do --
            for x=0, height+1 do --x
                data[a:index(x, y, z)] = air
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)
    
    --player target coords
    player_x = math.floor(height/2)+(math.floor(height/2)+1)%2
    player_z = math.floor(width/2)+(math.floor(width/2)+1)%2
    
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

laby_register_style("classic","classic", map_function, cleanup)