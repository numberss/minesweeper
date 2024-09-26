local Cell = {
	colours = {
		["-1"] = Color3.fromRGB(100, 100, 100),
		[""] = Color3.fromRGB(103, 103, 103),
		["X"] = Color3.fromRGB(255, 0, 0),
		["F"] = Color3.fromRGB(112, 40, 40),
		[" "] = Color3.fromRGB(255, 252, 244),
		["1"] = Color3.fromRGB(255, 224, 202),
		["2"] = Color3.fromRGB(255, 208, 160),
		["3"] = Color3.fromRGB(255, 190, 147),
		["4"] = Color3.fromRGB(255, 186, 129),
		["5"] = Color3.fromRGB(255, 172, 117),
		["6"] = Color3.fromRGB(255, 147, 114),
		["7"] = Color3.fromRGB(255, 133, 96),
		["8"] = Color3.fromRGB(255, 112, 112)
	}
}

local minefield = workspace:WaitForChild("Minefield"):WaitForChild("SurfaceGui"):WaitForChild("Minefield")

function Cell.GetSurroundingMines(button : TextButton, w : number, h : number)
	if not button then return false end	
	local mines = 0
	local x = tonumber(string.split(button.Name, "|")[1])
	local y = tonumber(string.split(button.Name, "|")[2])
	
	for i = x-1, x+1 do
		for j = y-1, y+1 do
			if i < 1 or j < 1 or i > w or j > h then continue end
			local surroundingButton = button.Parent:FindFirstChild(i.."|"..j)

			if surroundingButton:GetAttribute("Mine") then
				mines += 1
			end
			if surroundingButton:GetAttribute("Flagged") then
				mines -= 1
			end

		end
	end
	button:SetAttribute("NearbyMines", mines)
	return true
end


function Cell.SurroundingCells(button : TextButton, w : number, h : number)
	local cellTable = {}
	local x0 = tonumber(string.split(button.Name, "|")[1])
	local y0 = tonumber(string.split(button.Name, "|")[2])
	local x1 = x0 + 1
	local x2 = x0 - 1
	if x1 > w then
		x1 = x0
	end
	if x2 < 1 then
		x2 = x0
	end
	
	local y1 = y0 + 1
	local y2 = y0 - 1
	if y1 > h then
		y1 = y0
	end
	if y2 < 1 then
		y2 = y0
	end
	
	-- going clockwise from 12 oclock
	table.insert(cellTable, button.Parent:FindFirstChild(tostring(x1).."|"..tostring(y1)))
	table.insert(cellTable, button.Parent:FindFirstChild(tostring(x1).."|"..tostring(y0)))
	table.insert(cellTable, button.Parent:FindFirstChild(tostring(x1).."|"..tostring(y2)))
	table.insert(cellTable, button.Parent:FindFirstChild(tostring(x0).."|"..tostring(y2)))
	table.insert(cellTable, button.Parent:FindFirstChild(tostring(x2).."|"..tostring(y2)))
	table.insert(cellTable, button.Parent:FindFirstChild(tostring(x2).."|"..tostring(y0)))
	table.insert(cellTable, button.Parent:FindFirstChild(tostring(x2).."|"..tostring(y1)))
	
	for _,cell in pairs(cellTable) do
		if cell then
			Cell.Reveal(cell)
			if cell:GetAttribute("Mine") and cell:GetAttribute("Revealed") then
				Cell.Lose(w, h)
			end
		end
	end
end


function Cell.DiscoverBoard(w : number, h : number, flag : boolean)
	for i=1, w do
		for j=1, h do
			local button = minefield:FindFirstChild(i.."|"..j)
			Cell.GetSurroundingMines(button, w, h)
			if button:GetAttribute("Revealed") then
				Cell.Reveal(button)
			end
			if button:GetAttribute("NearbyMines") == 0 and not flag then
				Cell.SurroundingCells(button, w, h)
			end
		end
	end
end


function Cell.Reveal(button : TextButton)
	if button:GetAttribute("Flagged") then return true end
	if button:GetAttribute("Mine") then
		button.Text = "X"
	else
		if button:GetAttribute("NearbyMines") == 0 then
			button.Text = " "
		else
			button.Text = tostring(button:GetAttribute("NearbyMines"))
		end
	end
	if Cell.colours[button.Text] then
		button.BackgroundColor3 = Cell.colours[button.Text]
	else
		button.BackgroundColor3 = Cell.colours["-1"]
	end
	button:SetAttribute("Revealed", true)
	if button.Text == "X" then
		return false
	else
		return true
	end
end


function Cell.Flag(button : TextButton)
	if button:GetAttribute("Revealed") then return end
	if button:GetAttribute("Flagged") then
		button.Text = ""
		button:SetAttribute("Flagged", false)
	else
		button.Text = "F"
		button:SetAttribute("Flagged", true)
	end
	button.BackgroundColor3 = Cell.colours[button.Text]
end


function Cell.CheckWin(w : number, h : number)
	for i=1, w do
		for j=1, h do
			local button = minefield:FindFirstChild(i.."|"..j)
			if not button:GetAttribute("Revealed") and not button:GetAttribute("Mine") then
				return false
			end
		end
	end
	Cell.Win(w, h)	
end


function Cell.Win(w : number, h : number)
	minefield.BackgroundColor3 = Color3.fromRGB(66, 204, 75)
	for i=1, w do
		for j=1, h do
			local button : TextButton = minefield:FindFirstChild(i.."|"..j)
			button:SetAttribute("NearbyMines", 0)
			if button:GetAttribute("Mine") and not button:GetAttribute("Flagged") then
				button.Text = "F"
				button.BackgroundColor3 = Color3.fromRGB(50, 107, 55)
			elseif not button:GetAttribute("Mine") and not button:GetAttribute("Flagged") then
				Cell.Reveal(button)
			elseif button:GetAttribute("Flagged") then
				button.BackgroundColor3 = Color3.fromRGB(50, 107, 55)
			end
		end
	end
end


function Cell.Lose(w : number, h : number)
	minefield.BackgroundColor3 = Color3.fromRGB(204, 24, 24)
	for i=1, w do
		for j=1, h do
			local button : TextButton = minefield:FindFirstChild(i.."|"..j)
			if button:GetAttribute("Mine") and button:GetAttribute("Flagged") then
				button.BackgroundColor3 = Color3.fromRGB(50, 107, 55)
			elseif button:GetAttribute("Mine") then
				Cell.Reveal(button)
			end
		end
	end
end

return Cell
