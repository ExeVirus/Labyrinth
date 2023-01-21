--[[
  __  __
 |  \/  |                    | |
 | \  / |  __ _  ____ ___    | | _   _   __ _
 | |\/| | / _` ||_  // _ \   | || | | | / _` |
 | |  | || (_| | / /|  __/ _ | || |_| || (_| |
 |_|  |_| \__,_|/___|\___|(_)|_| \__,_| \__,_|

MIT License, ExeVirus (c) 2021

Implements wilsons's algorithm in lua

Provides a simple function to do so:

Generate_Maze(width,height[,view=false])

where width and height are the dimensions and
view is a boolean allowing you to visualze with
ascii in realtime. Every 10th iteration, a rewdraw occurs

In the end, a table is returned:
table {
    {0,1,0,1,0},
    {0,1,0,1,0},
    {0,1,0,1,0},
}

which contains 1's for path and 0's for walls.

]]

local function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

local function findNextStarting(maze)
    for i=maze.height,1,-2 do
        for j=maze.width,1,-2 do
            if maze[i][j] == 0 then
                return { i, j }
            end
        end
    end
    return nil --we're done!
end

local function getNextPoint(current_point,height,width,last_dir)
    --keep trying till we get a valid direction
    while(1) do
        local dir = math.random(3)
        if last_dir == 3 then --east

            if dir == 1 then --north
                if current_point[1]-2 > 0 then
                    return {current_point[1]-2,current_point[2]}, 2
                end
            elseif dir == 2 then --east
                if current_point[2]+2 <= width then
                    return {current_point[1],current_point[2]+2}, 3
                end
            else --south
                if current_point[1]+2 <= height then
                    return {current_point[1]+2,current_point[2]}, 4
                end
            end
        elseif last_dir == 4 then --south
            if dir == 1 then --east
                if current_point[2]+2 <= width then
                    return {current_point[1],current_point[2]+2}, 3
                end
            elseif dir == 2 then --south
                if current_point[1]+2 <= height then
                    return {current_point[1]+2,current_point[2]}, 4
                end
            else --west
                if current_point[2]-2 > 0 then
                    return {current_point[1],current_point[2]-2}, 1
                end
            end
        elseif last_dir == 1 then --west
            if dir == 1 then --south
                if current_point[1]+2 <= height then
                    return {current_point[1]+2,current_point[2]}, 4
                end
            elseif dir == 2 then --west
                if current_point[2]-2 > 0 then
                    return {current_point[1],current_point[2]-2}, 1
                end
            else --north
                if current_point[1]-2 > 0 then
                    return {current_point[1]-2,current_point[2]}, 2
                end
            end
        else --north
            if dir == 1 then --west
                if current_point[2]-2 > 0 then
                    return {current_point[1],current_point[2]-2}, 1
                end
            elseif dir == 2 then --north
                if current_point[1]-2 > 0 then
                    return {current_point[1]-2,current_point[2]}, 2
                end
            else --east
                if current_point[2]+2 <= width then
                    return {current_point[1],current_point[2]+2}, 3
                end
            end
        end
    end
end

local function addChain(maze,chain,value)
    maze[chain[1][1]][chain[1][2]] = value
    local last_point = chain[1]
    if chain[2] then
        for i=1,#chain do
            maze[chain[i][1]][chain[i][2]] = value
            maze[(chain[i][1]+last_point[1])/2][(chain[i][2]+last_point[2])/2] = value
            last_point = chain[i]
        end
    end
    return maze
end

local function viewMaze(maze, chain)
    if not chain then
        for i=1,maze.height do
            print(table.concat(maze[i]," "))
        end
    else
        local show = copy(maze)
        show = addChain(show,chain,2)
        for i=1,show.height do
            print(table.concat(show[i]," "))
        end
    end
end

local function onChain(chain,point)
    for _,v in pairs(chain) do
        if point[1] == v[1] and point[2] == v[2] then return true end
    end
    return false
end

local function backTrack(chain, point)
    for i=#chain,1,-1 do
        if point[1] == chain[i][1] and point[2] == chain[i][2] then
            return point, chain
        else
            table.remove(chain,i)
        end
    end
    error("it was onChain, but not found....")
end

local clock = os.clock
local function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end

local function wilsonsAlgo(maze,view)
    local view_count_down = 1
    local current_point = findNextStarting(maze)
    local last_dir = 2 --1 = west, 2 = north, 3=east, 4=south
    local next_point = {}
    local chain = { current_point }
    while(1) do --exited with return statement
        next_point, last_dir = getNextPoint(current_point,maze.height,maze.width,last_dir)
        if onChain(chain,next_point) then
            current_point, chain = backTrack(chain,next_point)
        elseif maze[next_point[1]][next_point[2]] == 1 then
            table.insert(chain,next_point)
            maze = addChain(maze,chain,1) --maze is updated hopefully inside here
            current_point = findNextStarting(maze)
            last_dir = 2
            chain = { current_point }
            if current_point == nil then
                return --we're done!
            end
        else
            table.insert(chain,next_point)
            current_point = next_point
        end
        if view then
            view_count_down = view_count_down - 1
            if view_count_down == 0 then
                os.execute("cls")
                viewMaze(maze, chain)
                sleep(1)
                view_count_down = 5
            end
        end
    end
    --no need to return maze, it's overwritten for us
end

local function Generate_Maze(width, height, view)
--check for valid entries
    if not width or not height then
        PrintUsage()
        return {}
    end
--check for view boolean
    if not view then
        view = false
    else
        if     view == "false" then view = false
        elseif view == "true" then view = true end
    end
--Generate Empty maze
    local maze = {}
    maze.width  = tonumber(width) + (tonumber(width)-1)%2
    maze.height = tonumber(height) + (tonumber(height)-1)%2
    for i=1,maze.height do
        maze[i] = {}
        for j=1, maze.width do
            table.insert(maze[i], 0)
        end
    end

--initialize first point
    math.randomseed(os.time())
    local x = math.random(math.floor(maze.width/2)-1)*2+1
    local y = math.random(math.floor(maze.height/2)-1)*2+1
    --local spot = findNextStarting(maze)
    maze[y][x] = 1

--Execute Algorithm
    wilsonsAlgo(maze, view)

--return maze
    return maze
end

return Generate_Maze --return the generate Maze function
