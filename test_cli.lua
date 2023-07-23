local args = { ... }

print("Number of args: " .. #args)

if #args ~= 8 then
	print("Usage:")
	print("roam.lua x y z <NORTH|EAST|SOUTH|WEST> length width height")
end
