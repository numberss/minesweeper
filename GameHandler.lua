local GUI = workspace:WaitForChild("Minefield"):WaitForChild("SurfaceGui")

local minefield = GUI:WaitForChild("Minefield")
local startButton = GUI:WaitForChild("Configuration"):WaitForChild("StartButton")
local squareInput = GUI:WaitForChild("Configuration"):WaitForChild("SquareButton")
local widthInput = GUI:WaitForChild("Configuration"):WaitForChild("Width")
local heightInput = GUI:WaitForChild("Configuration"):WaitForChild("Height")
local minesInput = GUI:WaitForChild("Configuration"):WaitForChild("Mines")

local lost = false
local won = false

local Generate = require(game:GetService("ReplicatedStorage"):WaitForChild("Generate"))
local Cell = require(game:GetService("ReplicatedStorage"):WaitForChild("Cells"))

-- default values
local width = 10
widthInput.Text = width
local height = 10
heightInput.Text = height
local totalMines = 10
minesInput.Text = totalMines
local square = true
squareInput.Text = "X"


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
		square = false
		width = tonumber(widthInput.Text)
		height = tonumber(heightInput.Text)
	else
		squareInput.Text = "X"
		square = true
		width = math.max(width, height)
		height = width
	end
	print(square)
end)


startButton.MouseButton1Up:Connect(function()
	Generate.SetupGrid(totalMines, width, height)
end)

local db = true

minefield.ChildAdded:Connect(function()
	for _,button in pairs(minefield:GetChildren()) do
		if not button:IsA("TextButton") then continue end
		
		-- Revealing
		button.MouseButton1Up:Connect(function()
			if db == true then
				db = false
				
				if not Cell.Reveal(button) then
					Cell.Lose(width, height)
				end
				Cell.DiscoverBoard(width, height, false)
				Cell.CheckWin(width, height)

				task.wait(.1)
				db = true
			else
				return false;
			end
		end)
		
		-- Flagging
		button.MouseButton2Up:Connect(function()
			if db == true then
				db = false
				
				Cell.Flag(button)
				Cell.DiscoverBoard(width, height, true)

				task.wait(.1)
				db = true
			else
				return false;
			end
		end)
	end
end)
