local Generate = {}

local Cell = require(game:GetService("ReplicatedStorage"):WaitForChild("Cells"))

local minefield = workspace:WaitForChild("Minefield"):WaitForChild("SurfaceGui"):WaitForChild("Minefield")

function Generate.SetupGrid(totalMines : number, w : number, h : number)
	minefield:ClearAllChildren()
	local minefieldConstraint = Instance.new("UIAspectRatioConstraint", minefield)
	local minefieldCorner = Instance.new("UICorner", minefield)
	local minefieldStroke = Instance.new("UIStroke", minefield)
	minefieldStroke.Thickness = 10
	minefieldCorner.CornerRadius = UDim.new(0, 10)
	
	for i=1, h do
		for j=1, w do
			minefield.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			local button = Instance.new("TextButton")
			button.Name = i.."|"..j
			button.Size = UDim2.new(0.9/w, 0, 0.9/h, 0)
			button.Position = UDim2.new((j-0.95)/w, 0, (i-0.95)/h, 0)
			button.Font = Enum.Font.FredokaOne
			button.TextScaled = true
			button.Text = ""
			button.BackgroundColor3 = Color3.fromRGB(103, 103, 103)
			button:SetAttribute("Mine", false)
			button:SetAttribute("NearbyMines", 0)
			button:SetAttribute("Flagged", false)
			button:SetAttribute("Revealed", false)
			button.Parent = minefield
			local corner = Instance.new("UICorner", button)
			corner.CornerRadius = UDim.new(0.1,0)
			local stroke = Instance.new("UIStroke", button)
			stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			stroke.Thickness = 5
		end
	end
	Generate.PlaceMines(totalMines, w, h)
	Generate.FindFirstCell(w ,h)
end

function Generate.PlaceMines(totalMines : number, w : number, h : number)
	for i=1, totalMines do
		local x = math.random(1,w)
		local y = math.random(1,h)
		local button = minefield:FindFirstChild(x.."|"..y)
		if not button then continue end
		while button:GetAttribute("Mine") do
			x += 1
			if x > w then
				x = 1
				y += 1
				if y > h then
					y = 0
				end
			end
			button = minefield:FindFirstChild(x.."|"..y)
		end	
		button:SetAttribute("Mine", true)
	end
end

function Generate.FindFirstCell(w : number, h : number)
	Cell.DiscoverBoard(w, h, false)
	for i=1, w do
		for j=1, h do
			local button = minefield:FindFirstChild(i.."|"..j)
			if button:GetAttribute("NearbyMines") == 0 then
				--Cell.Reveal(button)
				print("FOUND")
				return
			end
		end
	end
end

return Generate
