local full = true
for slot = 1, 16 do
	if turtle.getItemCount(slot) == 0 then
		full = false
	end
end
print(full)
