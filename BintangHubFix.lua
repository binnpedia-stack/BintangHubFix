-- BINTANGHUB V5.2 | Violence District
-- Full Body Highlight ESP (Chams) + Name | Auto Skillcheck

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    AutoSkill = false, AutoTrap = false,
    Fullbright = false, NoShadow = false, NoClip = false,
    ESP_Survivor = false, ESP_Killer = false, ESP_Gen = false, ESP_Trap = false,
    Color_Survivor = Color3.fromRGB(40, 255, 40),
    Color_Killer = Color3.fromRGB(255, 40, 40),
    Color_Gen = Color3.fromRGB(255, 165, 0),
    Color_Trap = Color3.fromRGB(200, 0, 0)
}

-- ==========================================
-- RAYFIELD UI
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "BINTANGHUB V5.2",
   LoadingTitle = "BINTANGHUB",
   LoadingSubtitle = "by Owner BintangHub",
   KeySystem = false, Theme = "Amethyst"
})

local TabMain = Window:CreateTab("Main", 4483362458)
local TabSurvivor = Window:CreateTab("Survivor", 4483362458)
local TabESP = Window:CreateTab("ESP", 4483362458)

TabMain:CreateToggle({Name = "Fullbright", CurrentValue = false, Callback = function(v) Config.Fullbright = v end})
TabMain:CreateToggle({Name = "No Clip", CurrentValue = false, Callback = function(v) Config.NoClip = v end})

TabSurvivor:CreateToggle({Name = "Auto Skillcheck (Gen)", CurrentValue = false, Callback = function(v) Config.AutoSkill = v end})
TabSurvivor:CreateToggle({Name = "Auto Trap Release", CurrentValue = false, Callback = function(v) Config.AutoTrap = v end})

TabESP:CreateToggle({Name = "ESP Survivor (Green Body)", CurrentValue = false, Callback = function(v) Config.ESP_Survivor = v end})
TabESP:CreateToggle({Name = "ESP Killer (Red Body)", CurrentValue = false, Callback = function(v) Config.ESP_Killer = v end})
TabESP:CreateToggle({Name = "ESP Generator", CurrentValue = false, Callback = function(v) Config.ESP_Gen = v end})
TabESP:CreateToggle({Name = "ESP Trap", CurrentValue = false, Callback = function(v) Config.ESP_Trap = v end})

-- ==========================================
-- ESP LOGIC (HIGHLIGHT / CHAMS)
-- ==========================================
local espCache = {}

local function CreateHighlight(char, color)
    local hl = Instance.new("Highlight")
    hl.Name = "BH_Highlight"
    hl.Adornee = char
    hl.FillColor = color
    hl.FillTransparency = 0.5 -- Transparansi biar agak tembus pandang
    hl.OutlineColor = color
    hl.OutlineTransparency = 0 -- Garis luarnya tebal
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Nembus dinding
    hl.Parent = char
    
    -- Teks Nama di atas kepala
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local b = Instance.new("BillboardGui")
        b.Name = "BH_Name"
        b.Size = UDim2.new(0, 100, 0, 50)
        b.StudsOffset = Vector3.new(0, 3, 0)
        b.AlwaysOnTop = true
        b.Parent = hrp
        
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, 0, 1, 0)
        t.BackgroundTransparency = 1
        t.Text = char.Name
        t.TextColor3 = color
        t.TextStrokeTransparency = 0
        t.Font = Enum.Font.GothamBold
        t.TextSize = 14
        t.Parent = b
    end
    return hl
end

local function UpdateESP()
    -- Player ESP
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local char = plr.Character
            local hum = char:FindFirstChild("Humanoid")
            
            if hum and hum.Health > 0 then
                local isKiller = char:FindFirstChildOfClass("Tool") ~= nil
                local active = (isKiller and Config.ESP_Killer) or (not isKiller and Config.ESP_Survivor)
                
                if active then
                    if not espCache[plr] or not espCache[plr].Parent then
                        local color = isKiller and Config.Color_Killer or Config.Color_Survivor
                        espCache[plr] = CreateHighlight(char, color)
                    end
                    espCache[plr].Enabled = true
                    espCache[plr].FillColor = isKiller and Config.Color_Killer or Config.Color_Survivor
                    espCache[plr].OutlineColor = isKiller and Config.Color_Killer or Config.Color_Survivor
                    
                    local nameTag = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("BH_Name")
                    if nameTag then
                        nameTag.TextLabel.TextColor3 = isKiller and Config.Color_Killer or Config.Color_Survivor
                        nameTag.TextLabel.Text = plr.Name
                    end
                else
                    if espCache[plr] then espCache[plr].Enabled = false end
                    local nameTag = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("BH_Name")
                    if nameTag then nameTag.Enabled = false end
                end
            end
        end
    end

    -- Object ESP (Text Only)
    for _, obj in pairs(workspace:GetDescendants()) do
        local n = obj.Name:lower()
        local isGen = Config.ESP_Gen and n:find("generator")
        local isTrap = Config.ESP_Trap and n:find("trap")
        
        if isGen or isTrap then
            if not espCache[obj] then
                local parentObj = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                if parentObj then
                    local b = Instance.new("BillboardGui")
                    b.Size = UDim2.new(0, 100, 0, 50)
                    b.StudsOffset = Vector3.new(0, 3, 0)
                    b.AlwaysOnTop = true
                    b.Parent = parentObj
                    local t = Instance.new("TextLabel")
                    t.Size = UDim2.new(1, 0, 1, 0)
                    t.BackgroundTransparency = 1
                    t.Text = isGen and "[ GEN ]" or "[ TRAP ]"
                    t.TextColor3 = isGen and Config.Color_Gen or Config.Color_Trap
                    t.TextStrokeTransparency = 0
                    t.Font = Enum.Font.GothamBold
                    t.TextSize = 14
                    t.Parent = b
                    espCache[obj] = b
                end
            end
            if espCache[obj] then espCache[obj].Enabled = true end
        elseif espCache[obj] and not (isGen or isTrap) then
            if espCache[obj]:IsA("BillboardGui") then espCache[obj].Enabled = false end
        end
    end
end

-- ==========================================
-- AUTO SKILLCHECK (GUI WATCHER)
-- ==========================================
local vim = game:GetService("VirtualInputManager")
local isHitting = false

local function CheckForSkillcheck()
    if isHitting then return end
    local guis = game:GetService("CoreGui"):GetDescendants()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then for _, v in pairs(pg:GetDescendants()) do table.insert(guis, v) end end

    for _, gui in pairs(guis) do
        if gui:IsA("Frame") or gui:IsA("ImageLabel") then
            local name = gui.Name:lower()
            if name:find("skill") or name:find("check") or name:find("minigame") then
                if gui.Visible then
                    isHitting = true
                    vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.05)
                    vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    task.wait(0.5)
                    isHitting = false
                    break
                end
            end
        end
    end
end

-- ==========================================
-- MAIN LOOPS
-- ==========================================
RunService.RenderStepped:Connect(function()
    UpdateESP()
    if Config.AutoSkill or Config.AutoTrap then CheckForSkillcheck() end
end)

task.spawn(function()
    while task.wait(0.1) do
        local char = LocalPlayer.Character
        if char then
            if Config.NoClip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        end
        if Config.Fullbright then Lighting.Brightness = 3; Lighting.ClockTime = 14; Lighting.GlobalShadows = false
        else Lighting.Brightness = 1; Lighting.GlobalShadows = true end
        if Config.NoShadow then for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.CastShadow = false end end end
    end
end)
