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

-- function that drives the main dig function
local function beginDig(x, y, z, mX, mY, mZ)
	for currY=1, mY do
		for currZ=1, mZ do
			for cuurX=1, mX do
				turtle.dig()			-- Deal with hitting AllTheModium here
				turtle.forward()
				updateLocation()		-- This is definitely wrong
			end
			moveColumn()
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
