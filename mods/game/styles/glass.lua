-- Node Registrations

minetest.register_node("game:glass_glass",
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
-- Node Registrations

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
    local glass =   minetest.get_content_id("game:glass_glass")
    local air =      minetest.get_content_id("air")
    
    --Set up the level itself
    for z=1, width do --z
        for x=1, height do --x
            if loc_maze[x][z] == 1 then
                data[a:index(x, 0, z)] = glass
            else
                for y=0,4 do
                    data[a:index(x, y, z)] = glass
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
    
    --Finally, move  the player
    player:set_velocity({x=0,y=0,z=0})
    player:set_pos({x=player_x,y=3,z=player_z})
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
end

register_style("glass","glass", map_function, cleanup)