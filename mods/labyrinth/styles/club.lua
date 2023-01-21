-- _________  .__         ___.
-- \_   ___ \ |  |   __ __\_ |__
-- /    \  \/ |  |  |  |  \| __ \
-- \     \____|  |__|  |  /| \_\ \
--  \______  /|____/|____/ |___  /
--         \/                  \/

-- Node Registrations

minetest.register_node("labyrinth:club_ground",
{
  description = "Club Ground",
  tiles = {"club_ground.png"},
})

minetest.register_node("labyrinth:club_walkway",
{
  description = "Club Walkway",
  tiles = {"club_walkway.png"},
})

minetest.register_node("labyrinth:club_wall",
{
  description = "Club Wall",
  tiles = {"club_wall.png"},
  drawtype = "nodebox",
  node_box = {
                      type = "fixed",
                      fixed = {-0.5,-0.499,-0.5,0.5,1.14,0.5},
                  },
  selection_box = {0,0,0,0.01,0.01,0.01},
})

minetest.register_node("labyrinth:club_ceiling",
{
  description = "Club ceiling",
  tiles = {"club_ceiling.png"},
})

minetest.register_node("labyrinth:club_edge",
{
  description = "Club Edge",
  tiles = {"club_edge.png"},
  walkable = false,
})

minetest.register_node("labyrinth:club_light",
{
  description = "Club light",
  tiles = {"club_light.png"},
  light_source = 12,
})

local particleID = {}

local baseParticleDef = {
    amount = 50,
    time = 0,
    minpos = {x=1, y=1, z=1},
    minvel = {x=-0.5, y=-0.5, z=-0.5},
    maxvel = {x= 0.5, y= 0.2, z= 0.5},
    minexptime = 5,
    maxexptime = 5,
    minsize = 0.5,
    maxsize = 1.0,
    collisiondetection = false,
    collision_removal = false,
    object_collision = false,
    glow = 13,
}

local playerParticleDef = {
        amount = 5,
        time = 0,
        minpos = {x=-0.2, y=0.01, z=-0.2},
        maxpos = {x=0.2, y=0.05, z=0.2},
        minvel = {x=0, y=0, z=0},
        maxvel = {x=0, y=0, z=0},
        texture = "red.png",
        minexptime = 3,
        maxexptime = 3,
        minsize = 0.4,
        maxsize = 0.8,
        collisiondetection = false,
        collision_removal = false,
        object_collision = false,
        glow = 13,
}

local function map_function(maze, player)
    local loc_maze = maze
    width = loc_maze.width
    height = loc_maze.height

    baseParticleDef.amount = math.floor(width*height/98) --rouhgly good :)
    --Copy to the map
    local vm         = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map({x=0,y=0,z=0}, {x=height*2,y=10,z=width*2})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local club_ground  = minetest.get_content_id("labyrinth:club_ground")
    local club_wall    = minetest.get_content_id("labyrinth:club_wall")
    local club_ceiling = minetest.get_content_id("labyrinth:club_ceiling")
    local club_light   = minetest.get_content_id("labyrinth:club_light")
    local club_walkway = minetest.get_content_id("labyrinth:club_walkway")
    local club_edge    = minetest.get_content_id("labyrinth:club_edge")
    local air    =   minetest.get_content_id("air")

    minetest.set_timeofday(0.8)

    --player target coords
    player_x = (math.floor(height/2)+(math.floor(height/2)+1)%2)*2
    player_z = (math.floor(width/2)+(math.floor(width/2)+1)%2)*2
    --Finally, move  the player
    player:set_physics_override({gravity=0})
    player:set_physics_override({gravity=0})
    player:set_velocity({x=0,y=0,z=0})
    player:set_pos({x=player_x,y=1.5,z=player_z})

    --Set up the level itself
    for z=1, width do --z
        for x=1, height do --x
            if loc_maze[x][z] == 1 then
                data[a:index(x*2, 0, z*2)]     = club_walkway
                data[a:index(x*2+1, 0, z*2)]   = club_walkway
                data[a:index(x*2+1, 0, z*2+1)] = club_walkway
                data[a:index(x*2, 0, z*2+1)]   = club_walkway
            else
                data[a:index(x*2, 0, z*2)]     = club_ground
                data[a:index(x*2+1, 0, z*2)]   = club_ground
                data[a:index(x*2+1, 0, z*2+1)] = club_ground
                data[a:index(x*2, 0, z*2+1)]   = club_ground

                data[a:index(x*2,   1, z*2)]   = club_wall
                data[a:index(x*2+1, 1, z*2)]   = club_wall
                data[a:index(x*2+1, 1, z*2+1)] = club_wall
                data[a:index(x*2,   1, z*2+1)] = club_wall
            end
            data[a:index(x*2,   10, z*2)]   = club_light
            data[a:index(x*2+1, 10, z*2)]   = club_ceiling
            data[a:index(x*2+1, 10, z*2+1)] = club_ceiling
            data[a:index(x*2,   10, z*2+1)] = club_ceiling
        end
    end
    for z=1, width do
        for y=3,9 do
            data[a:index(1, y, z*2)] = club_ceiling
            data[a:index(1, y, z*2+1)] = club_ceiling
            data[a:index(height*2+1, y, z*2)] = club_ceiling
            data[a:index(height*2+1, y, z*2+1)] = club_ceiling
        end
        for y=0,2 do
            data[a:index(1, y, z*2)] = club_edge
            data[a:index(1, y, z*2+1)] = club_edge
            data[a:index(height*2+1, y, z*2)] = club_edge
            data[a:index(height*2+1, y, z*2+1)] = club_edge
        end
    end
    for x=1, height do
        for y=3,9 do
            data[a:index(x*2, y, 1)] = club_ceiling
            data[a:index(x*2+1, y, 1)] = club_ceiling
            data[a:index(x*2, y, width*2+1)] = club_ceiling
            data[a:index(x*2+1, y, width*2+1)] = club_ceiling
        end
        for y=0,2 do
            data[a:index(x*2, y, 1)] = club_edge
            data[a:index(x*2+1, y, 1)] = club_edge
            data[a:index(x*2, y, width*2+1)] = club_edge
            data[a:index(x*2+1, y, width*2+1)] = club_edge
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)
    --Add the particle spawners
    baseParticleDef.maxpos  = {x=height*2, y=9, z=width*2}
    baseParticleDef.texture = "red.png"
    particleID[1] = minetest.add_particlespawner(baseParticleDef)
    baseParticleDef.texture = "blue.png"
    particleID[2] = minetest.add_particlespawner(baseParticleDef)
    baseParticleDef.texture = "green.png"
    particleID[3] = minetest.add_particlespawner(baseParticleDef)
    baseParticleDef.texture = "yellow.png"
    particleID[4] = minetest.add_particlespawner(baseParticleDef)

    playerParticleDef.attached = player
    particleID[5] = minetest.add_particlespawner(playerParticleDef)
    playerParticleDef.texture = "blue.png"
    particleID[6] = minetest.add_particlespawner(playerParticleDef)
    playerParticleDef.texture = "green.png"
    particleID[7] = minetest.add_particlespawner(playerParticleDef)
    playerParticleDef.texture = "yellow.png"
    particleID[8] = minetest.add_particlespawner(playerParticleDef)
    minetest.after(1, function() player:set_physics_override({gravity=1}) end)
end

local function cleanup(width, height)
    --Delete the particle spawners
    minetest.delete_particlespawner(particleID[1])
    minetest.delete_particlespawner(particleID[2])
    minetest.delete_particlespawner(particleID[3])
    minetest.delete_particlespawner(particleID[4])
    minetest.delete_particlespawner(particleID[5])
    minetest.delete_particlespawner(particleID[6])
    minetest.delete_particlespawner(particleID[7])
    minetest.delete_particlespawner(particleID[8])

    --Delete the map
    local vm         = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map({x=0,y=0,z=0}, {x=height*2+1,y=10,z=width*2+1})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local air = minetest.get_content_id("air")

    --zero it out
    for z=0, width*2+1 do --z
        for y=0,10 do --
            for x=0, height*2+1 do --x
                data[a:index(x, y, z)] = air
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)
    minetest.set_timeofday(0.5)
end

laby_register_style("club","club", map_function, cleanup)
