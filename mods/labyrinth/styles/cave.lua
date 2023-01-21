--  ██████  █████  ██    ██ ███████
-- ██      ██   ██ ██    ██ ██
-- ██      ███████ ██    ██ █████
-- ██      ██   ██  ██  ██  ██
--  ██████ ██   ██   ████   ███████

-- Node Registrations

minetest.register_node("labyrinth:cave_rock",
{
    description = "Rock Block",
    drawtype = "mesh",
    mesh = "round.obj",
    paramtype = "light",
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
    tiles = {{name = "cave_stone.png", backface_culling=true}},
})

minetest.register_node("labyrinth:cave_ground",
{
    description = "Ground Rock",
    drawtype = "mesh",
    mesh = "glove.obj",
    paramtype = "light",
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
    tiles = {{name = "cave_stone.png", backface_culling=true}},
})

minetest.register_node("labyrinth:cave_torch",
{
    drawtype = "mesh",
    mesh = "torch.obj",
    tiles = {{
            name = "cave_torch.png",
            animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
    }},
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    light_source = 12,
    selection_box = {
        type = "wallmounted",
        wall_side = {-1/2, -1/2, -1/8, -1/8, 1/8, 1/8},
    },
    on_rotate = false,
    use_texture_alpha = "clip"
})

local clock = os.clock
local function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end

local function map_function(maze, player)
    local loc_maze = maze
    width = math.floor(loc_maze.width/2) + math.floor(loc_maze.width/2+1)%2
    height = math.floor(loc_maze.height/2) + math.floor(loc_maze.height/2+1)%2
    --Copy to the map
    local vm         = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map({x=0,y=0,z=0}, {x=height*3+3,y=5,z=width*3+3})
    local data = vm:get_data()
    local param2s = vm:get_param2_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local wall =   minetest.get_content_id("labyrinth:cave_rock")
    local ground   =   minetest.get_content_id("labyrinth:cave_ground")
    local torch  =   minetest.get_content_id("labyrinth:cave_torch")
    local air =      minetest.get_content_id("air")

     --player target coords
    player_x = (math.floor(height/2)+(math.floor(height/2)+1)%2)*3+1
    player_z = (math.floor(width/2)+(math.floor(width/2)+1)%2)*3+1
    --Finally, move  the player
    player:set_physics_override({gravity=0})
    player:set_velocity({x=0,y=0,z=0})
    player:set_pos({x=player_x,y=1,z=player_z})

    --Set up the level itself
    local torch_count = 0
    for z=1, width do --z
        for x=1, height do --x
            if loc_maze[x][z] == 1 then
                for q = 0, 2 do
                    for r = 0, 2 do
                        data[a:index(x*3+q, 0, z*3+r)] = ground
                        param2s[a:index(x*3+q, 0, z*3+r)]  = math.random(0,23)
                    end
                end
                torch_count = torch_count + 1
                if torch_count == 4 then
                    torch_count = 0
                    local xof = math.random(0,2)
                    local zof = math.random(0,2)
                    data[a:index(x*3+xof, 4, z*3+zof)] = torch
                end
            else
                for y=0,4 do
                    for q = 0, 2 do
                        for r = 0, 2 do
                            data[a:index(x*3+q, y, z*3+r)]     = wall
                            param2s[a:index(x*3+q, y, z*3+r)]  = math.random(0,23)
                        end
                    end
                end
            end
            for q = 0, 2 do
                for r = 0, 2 do
                    data[a:index(x*3+q, 5, z*3+r)]     = wall
                    param2s[a:index(x*3+q, 5, z*3+r)]  = math.random(0,23)
                end
            end
        end
    end
    vm:set_data(data)
    vm:set_param2_data(param2s)
    vm:write_to_map(true)
    minetest.after(1, function() player:set_physics_override({gravity=1}) end)
end

local function cleanup(width, height)
    --Copy to the map
    local vm         = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map({x=0,y=0,z=0}, {x=height*3+1,y=5,z=width*3+1})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local air = minetest.get_content_id("air")

    --zero it out
    for z=0, width*3+1 do --z
        for y=0,5 do --
            for x=0, height*3+1 do --x
                data[a:index(x, y, z)] = air
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)
end

laby_register_style("cave","cave", map_function, cleanup)
