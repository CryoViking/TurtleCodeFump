local args = { ... }

print("Number of args: " .. #args)

if #args ~= 7 then
	print("Usage:")
	print("roam.lua x y z <NORTH|EAST|SOUTH|WEST> length width height")
end
