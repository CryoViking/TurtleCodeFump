if turtle.detect() then
	local success, data = turtle.inspect()
	if success then
		print("Block name:      ", data.name)
		print("Blockm metadata: ", data.metadata)
	end
end
