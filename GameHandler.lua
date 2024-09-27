local minefield = workspace:WaitForChild("Minefield"):WaitForChild("SurfaceGui"):WaitForChild("Minefield")
local config = workspace:WaitForChild("Configuration"):WaitForChild("SurfaceGui")

local startButton = config:WaitForChild("StartButton")
local squareInput = config:WaitForChild("SquareButton")
local widthInput = config:WaitForChild("Width")
local heightInput = config:WaitForChild("Height")
local minesInput = config:WaitForChild("Mines")
local staticInput = config:WaitForChild("StaticButton")

local Generate = require(game:GetService("ReplicatedStorage"):WaitForChild("Generate"))
local Cell = require(game:GetService("ReplicatedStorage"):WaitForChild("Cells"))

-- default values
local width = 10
widthInput.Text = width
local height = 10
heightInput.Text = height
local totalMines = 30
minesInput.Text = totalMines
local square = true
squareInput.Text = "X"
local static = true
staticInput.Text = "X"

local ended = false


widthInput:GetPropertyChangedSignal("Text"):Connect(function()
	widthInput.Text = widthInput.Text:gsub('%D+', '')
	width = tonumber(widthInput.Text)
	if square then
		width = math.max(width, height)
		height = width
	end
end)
heightInput:GetPropertyChangedSignal("Text"):Connect(function()
	heightInput.Text = heightInput.Text:gsub('%D+', '')
	height = tonumber(heightInput.Text)
	if square then
		width = math.max(width, height)
		height = width
	end
end)
minesInput:GetPropertyChangedSignal("Text"):Connect(function()
	minesInput.Text = minesInput.Text:gsub('%D+', '')
	totalMines = tonumber(minesInput.Text)
end)

squareInput.MouseButton1Up:Connect(function()
	if square then
		squareInput.Text = ""
		width = tonumber(widthInput.Text)
		height = tonumber(heightInput.Text)
	else
		squareInput.Text = "X"
		width = math.max(width, height)
		height = width
	end
	square = not square
end)

staticInput.MouseButton1Up:Connect(function()
	if static then
		staticInput.Text = ""
	else
		staticInput.Text = "X"
	end
	static = not static
end)


startButton.MouseButton1Up:Connect(function()
	ended = false
	Generate.SetupGrid(totalMines, width, height, static)
end)

local db = true

minefield.ChildAdded:Connect(function()
--local function gameHandler()
	for _,button in pairs(minefield:GetChildren()) do
		if not button:IsA("TextButton") then continue end
		
		-- Revealing
		button.MouseButton1Up:Connect(function()
			if db and not ended then
				db = false
				
				if not Cell.UpdateCell(button, false) then Cell.Lose() ended = true end
				if Cell.CheckWin() then ended = true end

				task.wait(.1)
				db = true
			end
		end)
		
		-- Flagging
		button.MouseButton2Up:Connect(function()
			if db and not ended then
				db = false
				
				Cell.UpdateCell(button, true)
				if Cell.CheckWin() then ended = true end

				task.wait(.1)
				db = true
			end
		end)
	end
end)
