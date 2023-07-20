args = { ... }
os.loadAPI("wgetAPI")

print("This is a test")
local filename = args[1]
local base_url = "https://raw.githubusercontent.com/CryoViking/TurtleCodeFump/master/"
print(base_url .. filename)
wget.downloadFile(base_url .. filename, filename)
--
--wget()
