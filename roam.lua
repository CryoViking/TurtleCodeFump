-- VERSION 010

-- Global variables that should really be constants but hey...
-- It's lua
Blocks = {
	ENDER_CHEST = "enderchests:ender_chest",
	SPRUCE_CHEST = "quark:spruce_chest",
	COAL = "minecraft:coal",
	COAL_BLOCK = "minecraft:coal_block",
	ALLTHEMODIUM_SLATE_ORE = "allthemodium:allthemodium_slate_ore",
}

-- ENUMS
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

XDirection = {
	POSITIVE = "1",
	NEGATIVE = "2",
	UNDEFINED = "9999999999",
}

-- STATE TRACKING
World = {
	Y = -1,
	Z = -1,
	X = -1,
	DIRECTION = Compass.UNDEFINED,
}

Relative = {
	Y_DIRECTION = YDirection.POSITIVE,
	Z_DIRECTION = ZDirection.POSITIVE,
	X_DIRECTION = XDirection.POSITIVE,
}

Region = {
	Y_BOUND = 0,
	Z_BOUND = 0,
	X_BOUND = 0,
	X_OVERSTEP = 0,
}

-- This code is to handle with relative positioning because to the turtle
-- Forwards, right and down are all positive directions from it's starting point
-- For example the relative north of the turtle starting point might not be true north
-- So this is to setup the original details for referencing later.
OriginalDetails = {
	Y_DIRECTION = Compass.DOWN,
	Z_DIRECTION = Compass.UNDEFINED,
	X_DIRECTION = Compass.UNDEFINED,
}

local function setOriginalDetails(direction)
	if direction == Compass.NORTH then
		OriginalDetails.X_DIRECTION = Compass.NORTH
		OriginalDetails.Z_DIRECTION = Compass.EAST
	elseif direction == Compass.EAST then
		OriginalDetails.X_DIRECTION = Compass.EAST
		OriginalDetails.Z_DIRECTION = Compass.SOUTH
	elseif direction == Compass.SOUTH then
		OriginalDetails.X_DIRECTION = Compass.SOUTH
		OriginalDetails.Z_DIRECTION = Compass.WEST
	elseif direction == Compass.WEST then
		OriginalDetails.X_DIRECTION = Compass.WEST
		OriginalDetails.Z_DIRECTION = Compass.NORTH
	end
end

-- WRAPPER FUNCTIONS
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
	if OriginalDetails.X_DIRECTION == forward then
		Relative.X_DIRECTION = XDirection.POSITIVE
		return true
	elseif OriginalDetails.X_DIRECTION == opposite(forward) then
		Relative.X_DIRECTION = XDirection.NEGATIVE
		return true
	end
	return false
end

local function updateZDirection(forward)
	if OriginalDetails.Z_DIRECTION == forward then
		Relative.Z_DIRECTION = ZDirection.POSITIVE
		return true
	elseif OriginalDetails.Z_DIRECTION == opposite(forward) then
		Relative.Z_DIRECTION = ZDirection.NEGATIVE
		return true
	end
	return false
end

local function updateDirection()
	if updateXDirection(World.DIRECTION) then
		updateZDirection(World.DIRECTION)
	end
end

-- ROTATING FUNCTIONS
local function turnRight()
	turtle.turnRight()
	if World.DIRECTION == Compass.NORTH then
		World.DIRECTION = Compass.EAST
	elseif World.DIRECTION == Compass.EAST then
		World.DIRECTION = Compass.SOUTH
	elseif World.DIRECTION == Compass.SOUTH then
		World.DIRECTION = Compass.WEST
	elseif World.DIRECTION == Compass.WEST then
		World.DIRECTION = Compass.NORTH
	end
	updateDirection()
end

local function turnLeft()
	turtle.turnLeft()
	if World.DIRECTION == Compass.NORTH then
		World.DIRECTION = Compass.WEST
	elseif World.DIRECTION == Compass.WEST then
		World.DIRECTION = Compass.SOUTH
	elseif World.DIRECTION == Compass.SOUTH then
		World.DIRECTION = Compass.EAST
	elseif World.DIRECTION == Compass.EAST then
		World.DIRECTION = Compass.NORTH
	end
	updateDirection()
end

-- function to rotate 180 degrees
local function turnAround()
	turnLeft()
	turnLeft()
end

-- MOVEMENT FUNCTIONS
local function forward()
	local result = turtle.forward()
	if result == true then
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
	return result
end

local function moveLeft()
	turnLeft()
	forward()
end

local function moveRight()
	turnRight()
	forward()
end

local function up()
	local result = turtle.up()
	if result == true then
		World.Y = World.Y + 1
	end
end

local function down()
	local result = turtle.down()
	if result == true then
		World.Y = World.Y - 1
	end
end

local function backward()
	turnAround()
	forward()
end

-- MINING/DIGGING FUNCTIONS
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
	local success, data = turtle.inspect()
	if success then
		if data.name == Blocks.ALLTHEMODIUM_SLATE_ORE then
			return false
		end
	end
	if turtle.detect() then
		local success, reason = turtle.dig()
		if not success then
			notifyNonMinableDig(DigDirection.FORWARD)
		end
		return success
	end
	return true
end

local function digLeft()
	turnLeft()
	return dig()
end

local function digRight()
	turnRight()
	return dig()
end

local function digBackwards()
	turnAround()
	return dig()
end

local function digUp()
	local success, data = turtle.inspectUp()
	if success then
		if data.name == Blocks.ALLTHEMODIUM_SLATE_ORE then
			return false
		end
	end
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
	local success, data = turtle.inspectDown()
	if success then
		if data.name == Blocks.ALLTHEMODIUM_SLATE_ORE then
			return false
		end
	end
	if turtle.detectDown() then
		local success, reason = turtle.digDown()
		if not success then
			notifyNonMinableDig(DigDirection.DOWN)
		end
		return success
	end
	return true
end

-- MINE AND MOVE FUNCTIONS
local function digAndMoveForward()
	if dig() then
		forward()
		return true
	end
	return false
end

local function digAndMoveLeft()
	if digLeft() then
		forward()
		return true
	end
	return false
end

local function digAndMoveRight()
	if digRight() then
		forward()
		return true
	end
	return false
end

local function digAndMoveBackwards()
	if digBackwards() then
		forward()
		return true
	end
	return false
end

local function digAndMoveDown()
	if digDown() then
		down()
		return true
	end
	return false
end

local function digAndMoveUp()
	if digUp() then
		up()
		return true
	end
	return false
end

-- INVENTORY FUNCTIONS

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

local function checkFullInventory()
	local full = true
	for slot = 1, 16 do
		if turtle.getItemCount(slot) == 0 then
			full = false
		end
	end
	return full
end

local function refuel()
	local coalSlot = findItem(Blocks.COAL)
	local coalBlockSlot = findItem(Blocks.COAL_BLOCK)
	if coalSlot == nil then
		if coalBlockSlot == nil then
			return false
		end
	end
	if coalSlot == nil then
		turtle.select(coalBlockSlot)
	else
		turtle.select(coalSlot)
	end
	return turtle.refuel() == false
end

-- function to empty inventory
local function emptyInventory(upDirection)
	local coalSlot = findItem(Blocks.COAL)
	if coalSlot == nil then
		coalSlot = -1
	end
	local coalBlockSlot = findItem(Blocks.COAL_BLOCK)
	if coalBlockSlot == nil then
		coalBlockSlot = -1
	end
	for slot = 1, 16 do
		if slot ~= coalSlot and slot ~= coalBlockSlot then
			turtle.select(slot)
			if upDirection == true then
				turtle.dropUp()
			else
				turtle.drop()
			end
		end
	end
end

-- function to place an ender chest from the inventory and interact with it
local function placeAndInteractWithEnderChest()
	local chestSlot = findItem(Blocks.ENDER_CHEST)
	if chestSlot then
		turnAround()
		if dig() == true then
			turtle.select(chestSlot)
			turtle.place()
			emptyInventory(false)
			dig()
		else
			digUp()
			turtle.select(chestSlot)
			turtle.placeUp()
			emptyInventory(true)
			digUp()
		end
		turnAround()
	end
end

-- ALGORITHM TO GET OVER UNBREAKABLE BLOCKS

local function goOver()
	local verticalDelta = 0 -- each time I go up, I increment, when I go down, I decrement
	local forwardDelta = 0 -- each time I go back, I increment, when I go forward, I decrement

	local function arrivedToSamePlane()
		return verticalDelta == 0
	end

	local function arrivedToForwardPoint()
		return forwardDelta == 2
	end

	local function backtrack()
		turnAround()
		forward()
		forwardDelta = forwardDelta - 1
		turnAround()
	end

	local function goUp()
		local ableToDigUp = digUp()
		if not ableToDigUp then
			backtrack()
		end
		up()
		verticalDelta = verticalDelta + 1
	end

	local function goForward()
		while not arrivedToForwardPoint() do
			local ableToDigFoward = dig()
			if not ableToDigFoward then
				goUp()
			end
			forward()
			forwardDelta = forwardDelta + 1
		end
	end

	local function goDown()
		while not arrivedToSamePlane() do
			local ableToDigDown = digDown()
			if not ableToDigDown then
				goForward()
			end
			down()
			verticalDelta = verticalDelta - 1
		end
	end

	goUp()
	goForward()
	goDown()
	return forwardDelta
end

-- PATHFINDING FUNCTIONS
local function returnHome()
	if Relative.X_DIRECTION == XDirection.POSITIVE then
		turnLeft()
		for i = 0, Region.Z_BOUND - 2 do
			if forward() == false then
				local progress = goOver()
				i = i + progress
			end
		end
		turnLeft()
		for i = 0, Region.X_BOUND - 2 do
			if forward() == false then
				local progress = goOver()
				i = i + progress
			end
		end
		turnAround()
		digAndMoveDown()
	else
		turnRight()
		for i = 0, Region.Z_BOUND - 2 do
			if forward() == false then
				local progress = goOver()
				i = i + progress
			end
		end
		turnRight()
		digAndMoveDown()
	end
end

local function moveColumn(resetOverstep, zValue)
	if zValue == resetOverstep then
		Region.X_OVERSTEP = 0
	end
	if zValue ~= 0 then
		if Relative.X_DIRECTION == XDirection.POSITIVE then
			digAndMoveRight()
			turnRight()
		else
			digAndMoveLeft()
			turnLeft()
		end
	end
end

-- MAIN DIGGING FUNCTION
-- function that drives the main dig functiona
local function beginDig()
	local currY = 0
	while currY < Region.Y_BOUND do
		if currY ~= 0 then
			-- Go back to relative 0,0,0
			returnHome()
		end
		local currZ = 0
		local resetOverstep = currZ
		while currZ < Region.Z_BOUND do
			-- Handle moving columns
			moveColumn(resetOverstep, currZ)

			-- Begin the dig forward for that column.
			local currX = 1
			while currX < (Region.X_BOUND + Region.X_OVERSTEP) do
				if checkFullInventory() == true then
					placeAndInteractWithEnderChest()
				end
				if turtle.getFuelLevel() <= 0 then
					refuel()
				end
				if dig() == true then
					forward()
					currX = currX + 1
				else
					local forwardDelta = goOver()
					currX = currX + forwardDelta
					if currX > Region.X_BOUND then
						Region.X_OVERSTEP = currX - Region.X_BOUND
						resetOverstep = currZ + 2
					end
				end
			end

			currZ = currZ + 1
		end
		currY = currY + 1
	end
end

-- SORTING OUT ARGS AND KICKING OFF THE PROGRAM
--
-- ENTRY POINT

local args = { ... }

if #args ~= 7 then
	print("Usage:")
	print("roam.lua x y z <NORTH|EAST|SOUTH|WEST> length width height")
	return -- Lmao forgot to exit the program
end

-- Set world values
World.X = tonumber(args[1])
World.Y = tonumber(args[2])
World.Z = tonumber(args[3])

-- set world direction
if args[4] == "NORTH" then
	World.DIRECTION = Compass.NORTH
	setOriginalDetails(Compass.NORTH)
elseif args[4] == "EAST" then
	World.DIRECTION = Compass.EAST
	setOriginalDetails(Compass.EAST)
elseif args[4] == "SOUTH" then
	World.DIRECTION = Compass.SOUTH
	setOriginalDetails(Compass.SOUTH)
elseif args[4] == "WEST" then
	World.DIRECTION = Compass.WEST
	setOriginalDetails(Compass.WEST)
end

-- Set Boundaries
Region.X_BOUND = tonumber(args[5])
Region.Z_BOUND = tonumber(args[6])
Region.Y_BOUND = tonumber(args[7])

-- BEGIN THE DIG
beginDig()
