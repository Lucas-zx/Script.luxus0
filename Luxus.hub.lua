-- Luxus Hub - Versão única (compacta)
if not game:IsLoaded() then game.Loaded:Wait() end

-- ====== CONFIGURAÇÕES INICIAIS ======
local HttpService = game:GetService("HttpService")
local VirtualInput = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local Config = {
    Key = "lucasz",
    Translator = true,
    AutoFarm = true,
    AutoQuest = true,
    AutoHaki = true,
    FastAttack = true,
    AutoEquip = true,
    Language = "PT"
}

-- ====== ARQUIVO DE SALVAMENTO LOCAL ======
local fileName = "luxus_config.json"
if isfile(fileName) then
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(fileName))
    end)
    if ok and typeof(data) == "table" then
        for k, v in pairs(data) do Config[k] = v end
    end
end

local function SaveConfig()
    if writefile then
        writefile(fileName, HttpService:JSONEncode(Config))
    end
end

-- Salvar automaticamente a cada 5s
spawn(function()
    while wait(5) do
        SaveConfig()
    end
end)

-- ====== AUTO EQUIP ======
local function autoEquipBest()
    local inv = LocalPlayer.Backpack
    for _, item in pairs(inv:GetChildren()) do
        if item:IsA("Tool") and (item.Name:match("Sword") or item.Name:match("Fruit")) then
            item.Parent = LocalPlayer.Character
            print("[AutoEquip] Equipado: " .. item.Name)
            break
        end
    end
end

-- ====== TWEEN PARA PONTOS ======
local function tweenTo(cf)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local tween = TweenService:Create(hrp, TweenInfo.new(1.2), {CFrame = cf})
    tween:Play()
    tween.Completed:Wait()
end

-- ====== FARM POR LEVEL (ADAPTATIVO) ======
local function getMobByLevel()
    local lvl = LocalPlayer.Data.Level.Value
    local list = {
        {min = 0, max = 15, name = "Bandit", quest = "BanditQuest1", pos = CFrame.new(1060,17,1548)},
        {min = 16, max = 30, name = "Monkey", quest = "JungleQuest", pos = CFrame.new(-1600, 40, 150)},
        {min = 31, max = 60, name = "Gorilla", quest = "GorillaQuest", pos = CFrame.new(-1230, 50, 450)},
        {min = 61, max = 90, name = "Pirate", quest = "BuggyQuest1", pos = CFrame.new(-1150, 15, 3650)},
    }
    for _, data in ipairs(list) do
        if lvl >= data.min and lvl <= data.max then
            return data
        end
    end
    return nil
end

local function getNearestEnemy(name)
    local closest, dist = nil, math.huge
    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        if mob.Name:find(name) and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            local myhrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and myhrp then
                local d = (hrp.Position - myhrp.Position).Magnitude
                if d < dist then
                    closest = mob
                    dist = d
                end
            end
        end
    end
    return closest
end

-- ====== EXECUÇÃO DE FUNÇÕES ======
spawn(function()
    while wait(0.5) do
        local info = getMobByLevel()
        if info then
            -- Auto Quest
            if Config.AutoQuest then
                pcall(function()
                    tweenTo(info.pos)
                    wait(0.5)
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("ClickDetector") and v.Parent and v.Parent.Name:find("Quest") then
                            fireclickdetector(v)
                            break
                        end
                    end
                end)
            end

            -- Auto Farm
            if Config.AutoFarm then
                local enemy = getNearestEnemy(info.name)
                if enemy then
                    tweenTo(enemy.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0))
                    repeat
                        pcall(function()
                            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(11)
                            if Config.AutoEquip then autoEquipBest() end
                            if Config.FastAttack then
                                VirtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                            end
                            enemy.Humanoid:TakeDamage(5)
                        end)
                        wait(0.15)
                    until not enemy or enemy.Humanoid.Health <= 0 or not Config.AutoFarm
                end
            end
        end
    end
end)

-- ====== AUTO HAKI ======
spawn(function()
    while wait(1) do
        if Config.AutoHaki then
            VirtualInput:SendKeyEvent(true, "J", false, game)
            wait(0.2)
            VirtualInput:SendKeyEvent(false, "J", false, game)
        end
    end
end)

-- ====== GUI DE LOGIN ======
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "LuxusLogin"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 160)
frame.Position = UDim2.new(0.5, -150, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1, 0, 0, 30)
label.Text = "🔐 Digite a senha"
label.TextColor3 = Color3.new(1,1,1)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.TextSize = 16

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0.9, 0, 0, 30)
input.Position = UDim2.new(0.05, 0, 0.4, 0)
input.PlaceholderText = "Senha padrão: lucasz"
input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
input.TextColor3 = Color3.new(1,1,1)
input.Font = Enum.Font.Gotham
input.TextSize = 14

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(0.8, 0, 0, 30)
button.Position = UDim2.new(0.1, 0, 0.75, 0)
button.Text = "✅ Entrar"
button.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
button.TextColor3 = Color3.new(1,1,1)
button.Font = Enum.Font.GothamBold
button.TextSize = 14

button.MouseButton1Click:Connect(function()
    if input.Text == Config.Key then
        frame:Destroy()
        if Config.AutoEquip then autoEquipBest() end
    else
        label.Text = "❌ Senha inválida!"
        label.TextColor3 = Color3.new(1, 0, 0)
    end
end)# Script.luxus0
