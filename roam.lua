-- Global variables that should really be constants but hey...
-- It's lua
ENDER_CHEST = "enderchests:ender_chest"
COAL = "minecraft:coal"

Compass = {
	NORTH = "1",
	SOUTH = "2",
	WEST = "3",
	EAST = "4",
	UP = "5",
	DOWN = "6",
	UNDEFINED = "9999999999",
}

DigDirection = {
	UP = "1",
	DOWN = "2",
	FORWARD = "3",
	UNDEFINED = "9999999999",
}

XDirection = {
	POSITIVE = "1",
	NEGATIVE = "2",
	UNDEFINED = "9999999999",
}

YDirection = {
	POSITIVE = "1",
	NEGATIVE = "2",
	UNDEFINED = "9999999999",
}

ZDirection = {
	POSITIVE = "1",
	NEGATIVE = "2",
	UNDEFINED = "9999999999",
}

World = {
	X = -1,
	Y = -1,
	Z = -1,
	World.DIRECTION = Compass.UNDEFINED,
}

Relative = {
	X_World.DIRECTION = XDirection.POSITIVE,
	Y_World.DIRECTION = YDirection.POSITIVE,
	Z_World.DIRECTION = ZDirection.POSITIVE,
}

-- This code is to handle with relative positioning because to the turtle
-- Forwards, right and down are all positive directions from it's starting point
-- For example the relative north of the turtle starting point might not be true north
-- So this is to setup the original details for referencing later.
OriginalDetails = {
	X_World.DIRECTION = Compass.UNDEFINED,
	Y_World.DIRECTION = Compass.DOWN,
	Z_World.DIRECTION = Compass.UNDEFINED,
}

local function setOriginalDetails(direction)
	if direction == Compass.NORTH then
		OriginalDetails.X_World.DIRECTION = Compass.NORTH
		OriginalDetails.Z_World.DIRECTION = Compass.EAST
	elseif direction == Compass.EAST then
		OriginalDetails.X_World.DIRECTION = Compass.EAST
		OriginalDetails.Z_World.DIRECTION = Compass.SOUTH
	elseif direction == Compass.SOUTH then
		OriginalDetails.X_World.DIRECTION = Compass.SOUTH
		OriginalDetails.Z_World.DIRECTION = Compass.WEST
	elseif direction == Compass.WEST then
		OriginalDetails.X_World.DIRECTION = Compass.WEST
		OriginalDetails.Z_World.DIRECTION = Compass.NORTH
	end
end

-- wrapper functions that involve changing directions and need to
-- update relative values

local function opposite(direction)
	if direction == Compass.NORTH then
		return Compass.SOUTH
	elseif direction == Compass.EAST then
		return Compass.WEST
	elseif direction == Compass.SOUTH then
		return Compass.NORTH
	elseif direction == Compass.WEST then
		return Compass.EAST
	end
end

local function updateXDirection(forward)
	if OriginalDetails.X_World.DIRECTION == forward then
		Relative.X_World.DIRECTION = XDirection.POSITIVE
		return true
	elseif OriginalDetails.X_World.DIRECTION == opposite(forward) then
		Relative.X_World.DIRECTION = XDirection.NEGATIVE
		return true
	end
	return false
end

local function updateZDirection(forward)
	if OriginalDetails.Z_World.DIRECTION == forward then
		Relative.Z_World.DIRECTION = ZDirection.POSITIVE
		return true
	elseif OriginalDetails.Z_World.DIRECTION == opposite(forward) then
		Relative.Z_World.DIRECTION = ZDirection.NEGATIVE
		return true
	end
	return false
end

local function turnRight()
	turtle.turnRight()
	if World.World.DIRECTION == Compass.NORTH then
		World.DIRECTION = Compass.EAST
		if updateXDirection(World.DIRECTION) then
			updateZDirection(World.DIRECTION)
		end
	elseif World.DIRECTION == Compass.EAST then
		World.DIRECTION = Compass.SOUTH
		if updateXDirection(World.DIRECTION) then
			updateZDirection(World.DIRECTION)
		end
	elseif World.DIRECTION == Compass.SOUTH then
		World.DIRECTION = Compass.WEST
		if updateXDirection(World.DIRECTION) then
			updateZDirection(World.DIRECTION)
		end
	elseif World.DIRECTION == Compass.WEST then
		World.DIRECTION = Compass.NORTH
		if updateXDirection(World.DIRECTION) then
			updateZDirection(World.DIRECTION)
		end
	end
end

local function turnLeft()
	turtle.turnLeft()
	if World.DIRECTION == Compass.NORTH then
		World.DIRECTION = Compass.WEST
		updateXDirection(World.DIRECTION)
		updateZDirection(World.DIRECTION)
	elseif World.DIRECTION == Compass.WEST then
		World.DIRECTION = Compass.SOUTH
		updateXDirection(World.DIRECTION)
		updateZDirection(World.DIRECTION)
	elseif World.DIRECTION == Compass.SOUTH then
		World.DIRECTION = Compass.EAST
		updateXDirection(World.DIRECTION)
		updateZDirection(World.DIRECTION)
	elseif World.DIRECTION == Compass.EAST then
		World.DIRECTION = Compass.NORTH
		updateXDirection(World.DIRECTION)
		updateZDirection(World.DIRECTION)
	end
end

local function forward()
	turtle.forward()
	if World.DIRECTION == Compass.NORTH then
		World.Z = World.Z - 1
	elseif World.DIRECTION == Compass.SOUTH then
		World.Z = World.Z + 1
	elseif World.DIRECTION == Compass.EAST then
		World.X = World.X + 1
	elseif World.DIRECTION == Compass.WEST then
		World.X = World.X - 1
	end
end

local function up()
	turtle.up()
	World.Y = World.Y + 1
end

local function down()
	turtle.down()
	World.Y = World.Y - 1
end

-- function to handle not being able to dig the block
local function notifyNonMinableDig(direction)
	if direction == DigDirection.UP then
		local success, data = turtle.inspectUp()
		if success then -- TODO: HTTP request
			print("Block name:     ", data.name)
			print("Block metadata: ", data.metadata)
		end
	elseif direction == DigDirection.DOWN then
		local success, data = turtle.inspectDown()
		if success then -- TODO: HTTP request
			print("Block name:     ", data.name)
			print("Block metadata: ", data.metadata)
		end
	elseif direction == DigDirection.FORWARD then
		local success, data = turtle.inspect()
		if success then -- TODO: HTTP request
			print("Block name:     ", data.name)
			print("Block metadata: ", data.metadata)
		end
	end
end

local function dig()
	if turtle.detect() then
		local success, reason = turtle.dig()
		if not success then
			notifyNonMinableDig(DigDirection.FORWARD)
		end
		return success
	end
	return true
end

local function digUp()
	if turtle.detectUp() then
		local success, reason = turtle.digUp()
		if not success then
			notifyNonMinableDig(DigDirection.UP)
		end
		return success
	end
	return true
end

local function digDown()
	if turtle.detectDown() then
		local success, reason = turtle.digDown()
		if not success then
			notifyNonMinableDig(DigDirection.DOWN)
		end
		return success
	end
	return true
end

TERMINATE_FLAG = false

-- Function for terminating the program for a specific reason
local function terminate(reason)
	print("Program is terminating for the following reason: ")
	print(reason)
end

-- Function to find an item in the inventory and return it's slot number
local function findItem(name)
	for slot = 1, 16 do
		local itemDetail = turtle.getItemDetail(slot)
		if itemDetail and itemDetail.name == name then
			return slot
		end
	end
	return nil
end

-- function to empty inventory
local function emptyInventory()
	local coalSlot = findItem(COAL)
	if coalSlot == nil then
		TERMINATE_FLAG = true
		coalSlot = -1
	end
	for slot = 1, 16 do
		if slot == coalSlot then
			goto continue
		end
		turtle.drop()
		::continue::
	end
end

-- function to rotate 180 degrees
local function turnAround()
	turnLeft()
	turnLeft()
end

-- function to place an ender chest from the inventory and interact with it
local function placeAndInteractWithEnderChest()
	local chestSlot = findItem(ENDER_CHEST)
	if chestSlot then
		turnAround()
		turtle.select(chestSlot)
		turtle.place()
		emptyInventory()
		turtle.dig()
		turnAround()
	end
end

-- function to move to the next column
local function moveColumn()
	if X_World.DIRECTION == XDirection.POSITIVE then
		turnRight() -- Deal with hitting AllTheModium here
		dig()
		forward()
		turnRight()
	else
		turnLeft() -- Deal with hitting AllTheModium here
		dig()
		forward()
		turnLeft()
	end
end

-- function to swap ordinal directions
local function swapDirection()
	if World.DIRECTION == Compass.NORTH then -- North ->  South
		World.DIRECTION = Compass.SOUTH
	elseif World.DIRECTION == Compass.SOUTH then -- South -> North
		World.DIRECTION = Compass.NORTH
	elseif World.DIRECTION == Compass.WEST then -- West -> East
		World.DIRECTION = Compass.EAST
	elseif World.DIRECTION == Compass.EAST then -- East -> West
		World.DIRECTION = Compass.WEST
	elseif World.DIRECTION == Compass.DOWN then -- Down -> Up
		World.DIRECTION = Compass.UP
	elseif World.DIRECTION == Compass.UP then -- Up -> Down
		World.DIRECTION = Compass.DOWN
	end
end

local function goOver()
	local arrived = false
	local goingUp = false
	local verticalDelta = 0 -- each time I go up, I increment, when I go down, I decrement
	local forwardDelta = 0 -- each time I go back, I increment, when I go forward, I decrement

	while not arrived do
		if digUp() == true then
		else
		end
	end
end

-- function that drives the main dig function
local function beginDig(x, y, z, initDirection, mX, mY, mZ)
	World.DIRECTION = initDirection
	for currY = 1, mY do
		for currZ = 1, mZ do
			for cuurX = 1, mX do
			end
		end
	end
end
