-- R.Script Demo Script
-- Purpose: Verify that the loadstring pipeline works end-to-end.
-- It shows a notification and a small on-screen window, then cleans up.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    return -- Not running on the client; abort quietly
end

-- 1. Show a native Roblox notification (works in most executors)
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "R.Script",
        Text = "Demo script loaded successfully!",
        Duration = 5,
    })
end)

-- 2. Clean up any previous demo GUI (so re-running doesn't stack)
local existing = LocalPlayer:FindFirstChild("RScriptDemoGui")
if existing then
    existing:Destroy()
end

-- 3. Create a small draggable window using ScreenGui + Frame
local gui = Instance.new("ScreenGui")
gui.Name = "RScriptDemoGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "DemoFrame"
frame.Size = UDim2.new(0, 260, 0, 110)
frame.Position = UDim2.new(0.5, -130, 0.5, -55)
frame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true -- Built-in dragging, no extra code needed
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(56, 189, 248)
stroke.Thickness = 2
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Text = "R.Script — Demo"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(56, 189, 248)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local body = Instance.new("TextLabel")
body.Size = UDim2.new(1, -20, 0, 40)
body.Position = UDim2.new(0, 10, 0, 42)
body.BackgroundTransparency = 1
body.Text = "Loadstring worked!\nThis window closes in 8 seconds."
body.Font = Enum.Font.Gotham
body.TextSize = 14
body.TextColor3 = Color3.fromRGB(226, 232, 240)
body.TextWrapped = true
body.TextXAlignment = Enum.TextXAlignment.Left
body.TextYAlignment = Enum.TextYAlignment.Top
body.Parent = frame

local timerBar = Instance.new("Frame")
timerBar.Size = UDim2.new(1, 0, 0, 3)
timerBar.Position = UDim2.new(0, 0, 1, -3)
timerBar.BackgroundColor3 = Color3.fromRGB(56, 189, 248)
timerBar.BorderSizePixel = 0
timerBar.Parent = frame

-- Animate a "countdown bar" so it's obvious the script is alive
local tween = TweenService:Create(
    timerBar,
    TweenInfo.new(8, Enum.EasingStyle.Linear),
    { Size = UDim2.new(0, 0, 0, 3) }
)
tween:Play()

-- 4. Auto-cleanup after 8 seconds
task.delay(8, function()
    if gui and gui.Parent then
        gui:Destroy()
    end
end)

print("[R.Script] Demo script executed at " .. os.date("%H:%M:%S"))