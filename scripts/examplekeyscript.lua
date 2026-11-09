-- R.Script Simple Mod Menu
-- Client-side only. For testing/educational purposes.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

-- Clean up previous instance
local oldGui = LocalPlayer.PlayerGui:FindFirstChild("RScriptModMenu")
if oldGui then oldGui:Destroy() end

-- State Variables
local states = {
    Noclip = false,
    Fly = false,
    InfiniteJump = false,
    WalkSpeed = 16
}

-- --- Feature Functions ---

-- Noclip
local function setNoclip(state)
    states.Noclip = state
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide ~= (not state) then
            part.CanCollide = not state
        end
    end
end

-- Fly
local flyConnection
local flySpeed = 50
local bodyVelocity, bodyGyro

local function stopFly()
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
end

local function startFly()
    stopFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = hrp

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 9e4
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp

    flyConnection = RunService.RenderStepped:Connect(function()
        if not bodyVelocity or not bodyGyro then return end
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0) end
        if moveDir.Magnitude > 0 then
            bodyVelocity.Velocity = moveDir.Unit * flySpeed
        else
            bodyVelocity.Velocity = Vector3.zero
        end
        bodyGyro.CFrame = cam.CFrame
    end)
end

-- Infinite Jump
local infJumpConnection
local function setInfiniteJump(state)
    states.InfiniteJump = state
    if infJumpConnection then infJumpConnection:Disconnect() infJumpConnection = nil end
    if state then
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
end

-- --- UI Creation ---
local gui = Instance.new("ScreenGui")
gui.Name = "RScriptModMenu"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 280)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "R.Script Mod Menu"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(56, 189, 248)
title.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 5)
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Parent = mainFrame
uiList.Parent = mainFrame

-- Helper to create buttons
local function createToggle(name, layoutOrder, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.Text = name .. ": OFF"
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.LayoutOrder = layoutOrder
    btn.Parent = mainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local toggled = false
    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        btn.Text = name .. ": " .. (toggled and "ON" or "OFF")
        btn.BackgroundColor3 = toggled and Color3.fromRGB(56, 189, 248) or Color3.fromRGB(45, 45, 55)
        btn.TextColor3 = toggled and Color3.fromRGB(25, 25, 30) or Color3.fromRGB(255, 255, 255)
        callback(toggled)
    end)
    return btn
end

-- Create Toggles
createToggle("Noclip", 1, setNoclip)
createToggle("Fly (WASD + Space/Ctrl)", 2, function(state)
    if state then startFly() else stopFly() end
end)
createToggle("Infinite Jump", 3, setInfiniteJump)

-- WalkSpeed Slider
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 20)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "WalkSpeed: 16"
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 12
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.LayoutOrder = 4
speedLabel.Parent = mainFrame

local speedSlider = Instance.new("TextButton") -- Simple button to cycle speeds
speedSlider.Size = UDim2.new(0.9, 0, 0, 25)
speedSlider.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
speedSlider.Text = "Cycle Speed (16 -> 50 -> 100)"
speedSlider.Font = Enum.Font.Gotham
speedSlider.TextSize = 12
speedSlider.LayoutOrder = 5
speedSlider.Parent = mainFrame
Instance.new("UICorner", speedSlider).CornerRadius = UDim.new(0, 6)

local speeds = {16, 50, 100}
local speedIndex = 1
speedSlider.MouseButton1Click:Connect(function()
    speedIndex = speedIndex % #speeds + 1
    local newSpeed = speeds[speedIndex]
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = newSpeed end
    end
    speedLabel.Text = "WalkSpeed: " .. newSpeed
    speedSlider.Text = "Cycle Speed (" .. table.concat(speeds, " -> ") .. ")"
end)

-- Ensure features reset when character respawns
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1) -- Wait for character to fully load
    if states.Noclip then setNoclip(true) end
    if states.InfiniteJump then setInfiniteJump(true) end
    -- Fly and WalkSpeed typically reset on respawn, which is expected
end)