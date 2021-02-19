-- Node Registrations

minetest.register_node("game:cave_rock",
{
    description = "Rock Block",
    drawtype = "mesh",
    mesh = "round.obj",
    paramtype2 = "facedir",
    collision_box = {
        type = "fixed", --Complicated Collision Boxes:
        fixed = {
                    {-0.18, -0.41, -0.8, 0.62, 0.39, -0.6},
                    {-0.6, -0.5, -0.6, 0.35, 0.5, 0.7},
                    {0.02, -0.21, -0.6, 0.77, 1.09, 0.7},
                    {-0.36, -0.35, 0.70, 0.49, 0.75, 1.02},
                    {-0.38, 0.5, -0.55, 0.02, 0.85, 0.85},
                }
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}, 
    },
    tiles = {"stone.png"},
    light_source = 2,
})

minetest.register_node("game:cave_torch",
{
    description = "Torch",
    tiles = {"grassy_dirt.png"},
    light_source = 12,
})

minetest.register_node("game:cave_ground",
{
    description = "Ground Rock",
    drawtype = "mesh",
    mesh = "glove.obj",
    paramtype2 = "facedir",
    collision_box = {
        type = "fixed",
        fixed = {
                    {-0.93, -0.25, -0.37, -0.23, 0.65, 0.58},
                    {-0.4, -0.36, -0.52, 0.8, 0.86, 0.48},
                    {-0.18, -0.30, -0.75, 0.72, 0.40, 0.85},
                    {-0.66, -0.24, 0.37, 0.44, 0.46, 0.87},
                    {-0.23, -0.33, 0.87, 0.47, 0.07, 1.05},
                }
    },
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    },
    tiles = {"stone.png"},
    light_source = 2,
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
    local grass =   minetest.get_content_id("game:grassy_grass")
    local dirt   =   minetest.get_content_id("game:grassy_dirt")
    local hedge  =   minetest.get_content_id("game:grassy_hedge")
    local invisble = minetest.get_content_id("game:inv")
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

register_style("grassy","grassy", map_function, cleanup)
