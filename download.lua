args = { ... }

local filename = args[1]
local base_url = "https://raw.githubusercontent.com/CryoViking/TurtleCodeFump/master/"

print("Checking if File exists: " .. filename)
if fs.exists(filename) then
	print("File exists... deleting")
	fs.delete(filename)
	print("Deleted")
end
print("Downloading" .. base_url .. filename)
shell.run("wget", base_url .. filename, filename)
--
--wget()
