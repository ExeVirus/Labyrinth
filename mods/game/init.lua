--
--
--
--   Labyrinth Core Game
--
--
--

local GenMaze = dofile(minetest.get_modpath("game") .. "/maze.lua")
dofile(minetest.get_modpath("game") .. "/registrations.lua")

local function reset(player)
	--Load up the level
	local maze = GenMaze(61,61)

	--Copy to the map
	local vm         = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map({x=1,y=1,z=1}, {x=62,y=4,z=62})
	local data = vm:get_data()
	local a = VoxelArea:new{
		MinEdge = emin,
		MaxEdge = emax
	}
	local ground = minetest.get_content_id("game:g1")
	local wall = minetest.get_content_id("game:w1")
	local air = minetest.get_content_id("air")
	
	
	for z=1, 61 do --z
		for y=1,4 do --
			for x=1, 61 do --x
				data[a:index(x, y, z)] = air
			end
		end
	end
	
	for z=1, 61 do --z
		for x=1, 61 do --x
			if maze[x][z] == 1 then
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

	--Move Player
	player:set_pos({x=31,y=5,z=31})
end

minetest.register_on_joinplayer(
function(ObjectRef)
	reset(ObjectRef)
	ObjectRef:set_pos({x=31,y=20,z=31})
	minetest.chat_send_all(minetest.colorize("#0F0","Escape the maze to win!"))
end
)

minetest.register_globalstep(
function(dtime)
	local player = minetest.get_player_by_name("singleplayer")
	if player then
		local pos = player:get_pos()
		if pos.y < -25 then
			minetest.sound_play("win")
			reset(player)
		end
	end
end
)

