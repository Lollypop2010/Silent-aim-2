-- Silent Aim Script with FOV Circle for Roblox

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- FOV Settings
local FOV_RADIUS = 200 -- Radius of the FOV circle
local FOV_COLOR = Color3.fromRGB(255,20,147) -- Color of the FOV circle
local FOV_VISIBLE = true -- Toggle FOV circle visibility

-- Create FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Radius = FOV_RADIUS
fovCircle.Color = FOV_COLOR
fovCircle.Thickness = 1
fovCircle.Transparency = 1 -- Fully transparent

local function updateFOVCircle()
    if FOV_VISIBLE then
        fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
end

-- Function to get the closest target within FOV
local function getClosestTarget()
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local targetPosition, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            local distance = (Vector2.new(targetPosition.X, targetPosition.Y) - Vector2.new(mouse.X, mouse.Y)).magnitude

            -- Check if the player is within FOV
            if onScreen and distance < FOV_RADIUS then
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = v
                end
            end
        end
    end
    return closestPlayer
end

-- Silent aim function
local function silentAim()
    local target = getClosestTarget()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        -- Raycast to the target
        local bulletOrigin = player.Character.HumanoidRootPart.Position
        local bulletDirection = (target.Character.HumanoidRootPart.Position - bulletOrigin).unit * 1000 -- Extend the ray

        local raycastResult = workspace:Raycast(bulletOrigin, bulletDirection)
        if raycastResult and raycastResult.Instance and raycastResult.Instance.Parent == target.Character then
            -- This is where you would handle the shooting logic
            -- For example, if you have a gun equipped, you can fire it here
            print("Silent Aim hit:", target.Name)
        end
    end
end

-- Main loop
RunService.RenderStepped:Connect(function()
    updateFOVCircle()
    silentAim()
end)

-- Optional: Toggle FOV circle visibility
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
        FOV_VISIBLE = not FOV_VISIBLE
    end
end)

-- Cleanup
game:GetService("Players").PlayerRemoving:Connect(function(removedPlayer)
    if removedPlayer == player then
        fovCircle:Remove()
    end
end)
