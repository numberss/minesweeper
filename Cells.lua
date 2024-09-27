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

function Cell.GetSurroundingMines(button : TextButton)
	local mines = 0
	local x = tonumber(string.split(button.Name, "|")[1])
	local y = tonumber(string.split(button.Name, "|")[2])
	
	for i = x-1, x+1 do
		for j = y-1, y+1 do
			if i < 1 or j < 1 or i > minefield:GetAttribute("Width") or j > minefield:GetAttribute("Height") then continue end
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
	return mines
end


function Cell.Flood(button : TextButton)
	if not button or button:GetAttribute("Mine") or button:GetAttribute("Revealed") then return end
	
	button:SetAttribute("Revealed", true)
	Cell.UpdateCell(button, false)
	local x = tonumber(string.split(button.Name, "|")[1])
	local y = tonumber(string.split(button.Name, "|")[2])
	
	if button:GetAttribute("NearbyMines") == 0 then
		Cell.Flood(button.Parent:FindFirstChild(tostring(x).."|"..tostring(y+1))) -- top
		Cell.Flood(button.Parent:FindFirstChild(tostring(x+1).."|"..tostring(y+1))) -- top right
		Cell.Flood(button.Parent:FindFirstChild(tostring(x+1).."|"..tostring(y))) -- right
		Cell.Flood(button.Parent:FindFirstChild(tostring(x+1).."|"..tostring(y-1))) -- bottom right
		Cell.Flood(button.Parent:FindFirstChild(tostring(x).."|"..tostring(y-1))) -- bottom
		Cell.Flood(button.Parent:FindFirstChild(tostring(x-1).."|"..tostring(y-1))) -- bottom left
		Cell.Flood(button.Parent:FindFirstChild(tostring(x-1).."|"..tostring(y))) -- left
		Cell.Flood(button.Parent:FindFirstChild(tostring(x-1).."|"..tostring(y+1))) -- top left
	end
end


function Cell.UpdateCell(button : TextButton, flag : boolean)
	if flag and not button:GetAttribute("Revealed") then
		if button:GetAttribute("Flagged") then
			button.Text = ""
		else
			button.Text = "F"			
		end
		button:SetAttribute("Flagged", not button:GetAttribute("Flagged")) 
	elseif not button:GetAttribute("Flagged") then
		if button:GetAttribute("Mine") then
			button.Text = "X"
		elseif button:GetAttribute("NearbyMines") == 0 then
			button.Text = " "
			Cell.Flood(button)
		else
			button.Text = tostring(button:GetAttribute("NearbyMines"))	
		end
		if not minefield:GetAttribute("Static") then
			
		end
		button:SetAttribute("Revealed", true)
	end
	if Cell.colours[button.Text] then
		button.BackgroundColor3 = Cell.colours[button.Text]
	else
		button.BackgroundColor3 = Cell.colours["-1"]
	end
	if button.Text == "X" then
		return false
	else
		return true
	end
end


function Cell.CheckWin()
	for i=1, minefield:GetAttribute("Width") do
		for j=1, minefield:GetAttribute("Height") do
			local button = minefield:FindFirstChild(i.."|"..j)
			if not button:GetAttribute("Revealed") and not button:GetAttribute("Mine") then
				return false
			end
		end
	end
	Cell.Win()	
	return true
end


function Cell.Win()
	minefield.BackgroundColor3 = Color3.fromRGB(66, 204, 75)
	for i=1, minefield:GetAttribute("Width") do
		for j=1, minefield:GetAttribute("Height") do
			local button : TextButton = minefield:FindFirstChild(i.."|"..j)
			if button:GetAttribute("Mine") and not button:GetAttribute("Flagged") then
				button.Text = "F"
				button.BackgroundColor3 = Color3.fromRGB(50, 107, 55)
			elseif not button:GetAttribute("Mine") and not button:GetAttribute("Flagged") then
				Cell.UpdateCell(button, false)
			elseif button:GetAttribute("Flagged") then
				button.BackgroundColor3 = Color3.fromRGB(50, 107, 55)
			end
		end
	end
end


function Cell.Lose()
	minefield.BackgroundColor3 = Color3.fromRGB(204, 24, 24)
	for i=1, minefield:GetAttribute("Width") do
		for j=1, minefield:GetAttribute("Height") do
			local button : TextButton = minefield:FindFirstChild(i.."|"..j)
			if button:GetAttribute("Mine") and button:GetAttribute("Flagged") then
				button.BackgroundColor3 = Color3.fromRGB(50, 107, 55)
			elseif button:GetAttribute("Mine") then
				Cell.UpdateCell(button, false)
			end
		end
	end
end

return Cell
