-- Global variables that should really be constants but hey...
-- It's lua
ENDER_CHEST = "enderchests:ender_chest"
COAL = "minecraft:coal"

X_COORD = -1
Y_COORD = -1
Z_COORD = -1

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

DIRECTION = Compass.UNDEFINED

TERMINATE_FLAG = false

-- Function for terminating the program for a specific reason
local function terminate(reason)
	print("Program is terminating for the following reason: ")
	print(reason)
end

-- Function to find an item in the inventory and return it's slot number
local function findItem(name)
	for slot=1, 16 do
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
	for slot=1, 16 do
		if slot == coalSlot then
			goto continue
		end
		turtle.drop()
	    ::continue::
	end
end

-- function to rotate 180 degrees
local function turnAround()
	turtle.turnLeft()
	turtle.turnLeft()
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

FORWARD_DIRECTION = true

-- function to move to the next column
local function moveColumn()
	if FORWARD_DIRECTION == true then
		FORWARD_DIRECTION = false
		turtle.turnRight() 				-- Deal with hitting AllTheModium here
		turtle.dig()
		turtle.forward()
		turtle.turnRight()
	else
		FORWARD_DIRECTION = true
		turtle.turnLeft() 				-- Deal with hitting AllTheModium here
		turtle.dig()
		turtle.forward()
		turtle.turnLeft()
	end
end

-- function to update location of where the turtle is.
local function updateLocation()
	if DIRECTION == Compass.NORTH then
		Z_COORD = Z_COORD - 1
	elseif DIRECTION == Compass.SOUTH then
		Z_COORD = Z_COORD + 1
	elseif DIRECTION == Compass.EAST then
		X_COORD = X_COORD + 1
	elseif DIRECTION == Compass.WEST then
		X_COORD = X_COORD - 1
	elseif DIRECTION == Compass.UP then
		Y_COORD = Y_COORD + 1
	elseif DIRECTION == Compass.DOWN then
		Y_COORD = Y_COORD - 1
	end
end

-- function to swap ordinal directions
local function swapDirection()
	if DIRECTION == Compass.NORTH then				-- North ->  South
		DIRECTION = Compass.SOUTH
	elseif DIRECTION == Compass.SOUTH then			-- South -> North
		DIRECTION = Compass.NORTH
	elseif DIRECTION == Compass.WEST then			-- West -> East
		DIRECTION = Compass.EAST
	elseif DIRECTION == Compass.EAST then			-- East -> West
		DIRECTION = Compass.WEST
	elseif DIRECTION == Compass.DOWN then			-- Down -> Up
		DIRECTION = Compass.UP
	elseif DIRECTION == Compass.UP then				-- Up -> Down
		DIRECTION = Compass.DOWN
	end
end

-- function to handle not being able to dig the block
local function handleNonMinableDig(direction)
	if direction == DigDirection.UP then
		local success, data = turtle.inspectUp()
		if success then										-- TODO: HTTP request
			print("Block name:      ", data.name)
			print("Block metadata: ", data.metadata)
		end
	elseif direction == DigDirection.DOWN then
		local success, data = turtle.inspectDown()
		if success then										-- TODO: HTTP request
			print("Block name:      ", data.name)
			print("Block metadata: ", data.metadata)
		end
	elseif direction == DigDirection.FORWARD then
		local success, data = turtle.inspect()
		if success then										-- TODO: HTTP request
			print("Block name:      ", data.name)
			print("Block metadata: ", data.metadata)
		end
	end
end

-- function to dig up down or forward
local function digDirection(direction)
	if direction == DigDirection.UP then
		if turtle.detect() then
			local success, reason = turtle.digUp()
			if not success then						-- Block could not be mined.
				handleNonMinableDig(direction)
			end
		end
	elseif direction == DigDirection.DOWN then
		if turtle.detect() then
			local success, reason = turtle.digDown()
			if not success then						-- Block could not be mined.
				handleNonMinableDig(direction)
			end
		end
	elseif direction == DigDirection.FORWARD then
		if turtle.detect() then
			local success, reason = turtle.dig()
			if not success then						-- Block could not be mined.
				handleNonMinableDig(direction)
			end
		end

	end
end

-- function to handle dig logic for blocks that it can't mine
local function properDig(direction)
	if direction == Compass.UP then
		print("Digging Up")

		turtle.digDown()
	elseif direction == Compass.DOWN then
		print("Digging Down")
		turtle.digUp()
	else -- Handle all the forward logic because the relative cube is forward-right-down so how the
		 -- turtle handles navigating around a block it can't mine is relative to each direction
		if direction == Compass.NORTH then
			print("Digging North")
			turtle.dig()
		elseif direction == Compass.EAST then
			print("Digging East")
			turtle.dig()
		elseif direction == Compass.SOUTH then
			print("Digging South")
			turtle.dig()
		elseif direction == Compass.WEST then
			print("Digging West")
			turtle.dig()
		end
	end
end

-- function to move down a layer
local function moveDownALayer()
		
end

-- function that drives the main dig function
local function beginDig(x, y, z, initDirection, mX, mY, mZ)
	DIRECTION = initDirection
	for currY=1, mY do
		for currZ=1, mZ do
			for cuurX=1, mX do
				turtle.dig()			-- Deal with hitting AllTheModium here
				turtle.forward()
				updateLocation()		-- This is definitely wrong
			end
			moveColumn()
			swapDirection()
			updateLocation()			-- This is definitely wrong
		end
		turtle.digDown()
		turtle.down()
		turnAround()
		DIRECTION = Compass.DOWN
		updateLocation()
	end
end


args = { ... }

if ()

maxX = args[1]
maxY = args[2]
maxZ = args[3]
