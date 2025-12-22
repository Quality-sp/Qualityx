local ReplicatedStorage = game:GetService('ReplicatedStorage')
local HttpService = game:GetService('HttpService')
local PathfindingService = game:GetService('PathfindingService')
local UserInputService = game:GetService('UserInputService')
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local CurrentCamera = workspace.CurrentCamera
local Debris = game:GetService('Debris')

local Players, RunService, Camera, LocalPlayer, Mouse =
    game:GetService("Players"), game:GetService("RunService"),
    workspace.CurrentCamera, game.Players.LocalPlayer, game.Players.LocalPlayer:GetMouse()

local Net = require(ReplicatedStorage.Modules.Core.Net)
local CharModule = require(ReplicatedStorage.Modules.Core.Char)
local SprintModule = require(ReplicatedStorage.Modules.Game.Sprint)
local CrateController = require(ReplicatedStorage.Modules.Game.CrateSystem.Crate)

local Client = Players.LocalPlayer
local Character = Client.Character or Client.CharacterAdded:Wait()
local UserId = Client.UserId
local PlayerGui = Client.PlayerGui
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Backpack = Client:WaitForChild("Backpack")

Client.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
	Humanoid = Character:WaitForChild('Humanoid')
	RootPart = Character:WaitForChild('HumanoidRootPart')
	Backpack = Client:WaitForChild("Backpack")
end)	

local SteakHouseBro = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Tiles") and workspace.Map.Tiles:FindFirstChild("ShoppingTile") and workspace.Map.Tiles.ShoppingTile:FindFirstChild("SteakHouse")
local Puddles = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Tiles") and workspace.Map.Tiles:FindFirstChild("BurgerPlaceTile") and workspace.Map.Tiles.BurgerPlaceTile:FindFirstChild("BurgerPlace") and workspace.Map.Tiles.BurgerPlaceTile.BurgerPlace:FindFirstChild("Interior") and workspace.Map.Tiles.BurgerPlaceTile.BurgerPlace.Interior:FindFirstChild("Puddles")
local throwable = ReplicatedStorage.Items.throwable

local tasks = task
local cancel = tasks.cancel
local waits = tasks.wait
local get = ipairs
local getn = pairs
local number = tonumber
local CFrame_new = CFrame.new 
local Vector_new = Vector3.new
local TwoD_new = Vector2.new
local inserta = table.insert


local holdingJump = false

-- UI Initialization
local WindUI = loadstring(
    game:HttpGet(
        'https://github.com/Footagesus/WindUI/releases/latest/download/main.lua'
    )
)()

local Icons = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main.lua"))()

Icons.SetIconsType("lucide") -- lucide, craft and more...

local HouseIcon = Icons.Icon("house")

local ImageLabel = Instance.new("ImageLabel")
ImageLabel.Image = HouseIcon[1]
ImageLabel.ImageRectSize = HouseIcon[2].ImageRectSize
ImageLabel.ImageRectOffset = HouseIcon[2].ImageRectPosition

local Window = WindUI:CreateWindow({
	Title = "Kunlun's | Freemium",
	Icon = 'mountain-snow',
	Author = 'by #TBSkyen | discord.gg/NNY22NZ9rx',
	Folder = 'MySuperHub',
	Size = UDim2.fromOffset(400, 400),
	MinSize = Vector2.new(560, 350),
	MaxSize = Vector2.new(850, 560),
	Transparent = true,
	Theme = 'Dark',
	Resizable = true,
	SideBarWidth = 200,
	BackgroundImageTransparency = 0.42,
	HideSearchBar = false,
	ScrollBarEnabled = false,
	OpenButton = {
		Title = "Kunlun's",
		CornerRadius = UDim.new(1, 0),
		StrokeThickness = 3,
		Enabled = true,
		Draggable = true,
		OnlyMobile = false,
	},
})

Window:Tag({
	Title = 'v1.0.0',
	Color = Color3.fromHex('#30ff6a'),
	Radius = 13,
})

--====================================================
-- 🧍 MAIN TAB
--====================================================
local MainTab = Window:Tab({
	Title = 'General',
	Icon = 'globe',
})

MainTab:Section({
	Title = 'Infomation:'
})

--== Money Reader ==--
local Players = game:GetService('Players')
local Client = Players.LocalPlayer
local PlayerGui = Client:WaitForChild('PlayerGui')

local BankBalance =
    MainTab:Button({
	Title = '🏦 Bank Balance',
	Desc = 'N/A'
})
local HandBalance =
    MainTab:Button({
	Title = '💸 Hand Balance',
	Desc = 'N/A'
})

local function HandMoney()
	return tonumber(
        PlayerGui.TopRightHud.Holder.Frame.MoneyTextLabel.Text:match('%$(%d+)')
    )
end

local function ATMMoney()
	for _, v in ipairs(PlayerGui:GetDescendants()) do
		if v:IsA('TextLabel') and string.find(v.Text, 'Bank Balance') then
			return tonumber(v.Text:match('%$(%d+)'))
		end
	end
	return 0
end

task.spawn(function()
	while task.wait(0.2) do
		BankBalance:SetDesc(
            '<b><font color="#00FF00">$' .. (ATMMoney() or 0) .. '</font></b>'
        )
		HandBalance:SetDesc(
            '<b><font color="#00f2ff">$' .. (HandMoney() or 0) .. '</font></b>'
        )
	end
end)

--====================================================
-- ⚙️ Player Modifier Section
--====================================================
MainTab:Section({
	Title = 'Player Modifier:'
})

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- ประกาศตัวแปรทั้งหมดไว้ข้างนอก
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid
local RootPart

-- ตัวแปรควบคุม
local EnabledSpeed = false
local SpeedValue = 16

-- Function สำหรับ setup character
local function SetupCharacter(char)
	Character = char
	Humanoid = char:WaitForChild('Humanoid')
	RootPart = char:WaitForChild('HumanoidRootPart')
	
	-- รีเซ็ตค่าเมื่อ spawn ใหม่
	if EnabledSpeed then
		Humanoid.WalkSpeed = SpeedValue
	end
end

-- เชื่อมต่อครั้งเดียว
Player.CharacterAdded:Connect(SetupCharacter)

-- Setup ตัวละครปัจจุบัน (ถ้ามี)
if Player.Character then
	SetupCharacter(Player.Character)
end

-- Loop อัปเดตความเร็ว
task.spawn(function()
	while task.wait(0.05) do -- ลดเวลารอให้เร็วขึ้น
		if Humanoid and EnabledSpeed then
			Humanoid.WalkSpeed = SpeedValue
		end
	end
end)

-- Toggles & Sliders
MainTab:Toggle({
	Title = 'Walk Speed',
	Icon = 'check',
	Type = 'Checkbox',
	Value = false,
	Callback = function(Value)
		EnabledSpeed = Value
		if Humanoid then
			Humanoid.WalkSpeed = Value and SpeedValue or 16
		end
	end,
})

MainTab:Slider({
	Title = 'Speed Value',
	Step = 1,
	Value = {
		Min = 8,
		Max = 35,
		Default = 16
	},
	Callback = function(Value)
		SpeedValue = Value
		if Humanoid and EnabledSpeed then
			Humanoid.WalkSpeed = Value
		end
	end,
})
-- 🔹 ตัวแปรเก็บสถานะการเปิด Fly Jump
local EnabledFlyJump = false

MainTab:Toggle({
	Title = 'Fly Jump',
	Icon = 'check',
	Type = 'Checkbox',
	Value = false,
	Callback = function(Value)
		EnabledFlyJump = Value
	end,
})

-- 🔹 Event กด Space (กระโดด)
UserInputService.JumpRequest:Connect(function()
	if not EnabledFlyJump or not RootPart then
		return
	end
	holdingJump = true
	task.spawn(function()
		while holdingJump and EnabledFlyJump do
			RunService.Heartbeat:Wait()
			if RootPart then
				RootPart.Velocity =
                    Vector3.new(RootPart.Velocity.X, 30, RootPart.Velocity.Z)
			else
				break
			end
		end
	end)
end)

-- 🔹 Event ปล่อยปุ่ม Space (หยุดบินขึ้น)
UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Space then
		holdingJump = false
	end
end)

-- ตั้งค่าตัวแปรเริ่มต้น
EnabledInfiniteStamina = false

-- สร้าง toggle บนเมนู
MainTab:Toggle({
	Title = 'Infinite Stamina',
	Icon = 'check',
	Type = 'Checkbox',
	Value = false,
	Callback = function(Value)
		EnabledInfiniteStamina = Value
	end,
})

-- เก็บฟังก์ชันเดิมของ SprintBar.update ไว้
local OldUpdate = SprintBar.update

-- เขียนฟังก์ชันใหม่แทนที่
SprintBar.update = function(...)
	if EnabledInfiniteStamina then
        -- ถ้าเปิดโหมด Infinite Stamina ให้คืนค่าเต็ม (1)
		return 1
	else
        -- ถ้าปิด ให้ทำงานตามปกติ
		return OldUpdate(...)
	end
end

--====================================================
-- 🕶️ Utility
--====================================================
MainTab:Section({
	Title = 'Utility:'
})

local Hide = false

local function HideName()
	if Hide and Player.Character then
		local gui = Player.Character
            :WaitForChild('HumanoidRootPart')
            :FindFirstChild('CharacterBillboardGui')
		if gui then
			gui:Destroy()
		end
	end
end

Player.CharacterAdded:Connect(function(char)
	if Hide then
		HideName(char)
	end
end)

MainTab:Toggle({
	Title = 'Hide Name',
	Desc = 'Only client',
	Icon = 'check',
	Type = 'Checkbox',
	Value = false,
	Callback = function(v)
		Hide = v
		HideName()
	end,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Anti-Aim Variables
local AntiAimEnabled = false
local AntiAimConnection = nil
local SpinSpeed = 100 -- degrees per frame
local RandomizePattern = true

MainTab:Toggle({
	Title = "Anti Lock",
	Desc = "Prevent you from Aimlock",
	Icon = "check",
	Type = "Checkbox",
	Value = false,
	Callback = function(Value)
		AntiAimEnabled = Value
		
		-- Disconnect existing connection if any
		if AntiAimConnection then
			AntiAimConnection:Disconnect()
			AntiAimConnection = nil
		end
		
		if Value then
			AntiAimConnection = RunService.Heartbeat:Connect(function()
				local character = LocalPlayer.Character
				if not character then return end
				
				local hrp = character:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				
				-- Velocity manipulation
				local vel = hrp.Velocity
				hrp.Velocity = Vector3.new(0, 90, 0)
				RunService.RenderStepped:Wait()
				hrp.Velocity = vel
				
				-- CFrame rotation
				local rotationAngle = math.rad(SpinSpeed)
				
				-- Random direction
				if RandomizePattern and math.random() > 0.5 then
					rotationAngle = -rotationAngle
				end
				
				hrp.CFrame = hrp.CFrame * CFrame.Angles(0, rotationAngle, 0)
			end)
		end
	end
})

-- Add this near the top of your script where other func definitions are
local func = func or {}

-- Define the function BEFORE the toggle
func['AntiDied'] = function()
    while task.wait(0.25) do 
        if not c().AntiDied then break end
        
        local hum = CharModule.get_hum()
        if not hum then continue end
        
        if hum:GetAttribute('HasBeenDowned') then 
            if not hum:GetAttribute('IsDead') and Humanoid.Health > 0 then
                local deathscreen = PlayerGui:FindFirstChild("DeathScreen")
                if deathscreen then
                    deathscreen = deathscreen:FindFirstChild("DeathScreenHolder")
                    if deathscreen and not deathscreen.Visible then 
                        local Radius = (math.random(1, 100) <= 80) and math.random(-30, -1) or math.random(5, 55)
                        local Gan = math.random(-5, 5)
                        
                        RootPart.Anchored = false 
                        RootPart.CanCollide = false
                        RootPart.CFrame = RootPart.CFrame * CFrame.new(Gan, Radius, Gan)
                        
                        for _, v in pairs(Character:GetChildren()) do 
                            if v:IsA("BasePart") then 
                                v.CanCollide = false 
                                v.Anchored = false 
                                v.CFrame = v.CFrame * CFrame.new(Gan, Radius, Gan)
                            end
                        end
                        EverDown = true
                    end
                end
            else
                EverDown = false 
            end
        else 
            if EverDown and not hum:GetAttribute('IsInCombat') then 
                EverDown = false
            end
        end
    end
end

-- THEN create the toggle
MainTab:Toggle({
    Title = 'Anti Kill',
    Desc = 'Normal PLayer cant Finish',
    Icon = 'check',
    Type = 'Checkbox',
    Value = false,
    Callback = function(state)
        c().AntiDied = state
        
        if state then
            task.spawn(func['AntiDied'])
        end
    end
})

MainTab:Toggle({
	Title = 'Auto Mask',
	Desc = 'Equip Shiesty',
	Icon = 'check',
	Type = 'Checkbox',
	Callback = function(Value)
		if not Value then
			return
		end
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local Player = game.Players.LocalPlayer
		local PlayerGui = Player:WaitForChild("PlayerGui")
		local Net = require(ReplicatedStorage.Modules.Core.Net)
		function GetAllInfos(itemName)
			local infos = {}
			local Items = PlayerGui.Items
			local Holding = Items:FindFirstChild('ItemsHolder').ItemsScrollingFrame
			for _, v in ipairs(Holding:GetChildren()) do
				if v.Name ~= 'Folder' and v.Name ~= 'UIGridLayout' and v.Name ~= "ItemTemplate" then
					if v.ItemName.Text == itemName then
						table.insert(infos, {
							Uid = v.Name,
							Using = v:FindFirstChild('ItemEquipped').Visible,
							Drowning = v:FindFirstChild('DestroyedItemIcon').Visible
						})
					end
				end
			end
			return infos
		end
		function EquipAccessory(itemName)
			local infos = GetAllInfos(itemName)
			for _, info in ipairs(infos) do
				if not info.Using and not info.Drowning then
					Net.get("toggle_equip_item", info.Uid)
					repeat
						task.wait()
					until GetAllInfos(itemName)[1].Using
				end
			end
		end
		EquipAccessory("Shiesty")
	end
})


MainTab:Divider()

local EnabledSnapRunning = false
local SnapThread = nil
local YoffsetValue = 70

-- ⚙️ ฟังก์ชัน Snap
local func = {}

func['EnabledSnap'] = function()
	print('⚡ Snap system started.')
	local basePosition = RootPart.Position
	while EnabledSnapRunning do
		task.wait()
		if not EnabledSnapRunning then
			break
		end
		local currentY = RootPart.Position.Y
		local targetY = basePosition.Y - YoffsetValue
		local deltaY = targetY - currentY
		RootPart.CFrame = RootPart.CFrame * CFrame.new(0, deltaY, 0)
	end
	print('❌ Snap system stopped.')
end

-- 🔘 Toggle & Keybind Sync System
local function SetSnapState(value)
	if EnabledSnapRunning == value then
		return
	end -- ไม่ต้องทำซ้ำ
	EnabledSnapRunning = value
	print('📀 Underground:', value)
	if value then
		if not SnapThread then
			SnapThread = task.spawn(func['EnabledSnap'])
		end
	else
		SnapThread = nil
	end

    -- Sync UI Toggle ให้ตรงกับสถานะ
	MainTab:Get('UndergroundToggle'):SetValue(value)
end

-- 🧩 Toggle
MainTab:Toggle({
	Title = 'Underground',
	Icon = 'check',
	Type = 'Checkbox',
	Value = false,
	Flag = 'UndergroundToggle', -- ต้องมี flag เพื่อให้ sync ได้
	Callback = function(value)
		SetSnapState(value)
	end,
})

-- 🎹 Keybind
MainTab:Keybind({
	Title = 'Keybind',
	Value = 'G',
	Callback = function()
		SetSnapState(not EnabledSnapRunning)
	end,
})

-- 📏 Slider Snap Height
MainTab:Slider({
	Title = 'Snap Height',
	Step = 1,
	Value = {
		Min = 1,
		Max = 100,
		Default = 10,
	},
	Callback = function(value)
		YoffsetValue = value
		print('📏 Yoffset set to:', value)
	end,
})
local CombatTab = Window:Tab({
	Title = "Combat",
	Icon = "swords",
})

local SilentAimEnabled = false
local FOVRadius = 120
local CurrentTarget = nil
local WallbangEnabled = false          -- << NEW
local ShowFOVEnabled = false           -- << NEW

local SilentFOVCircle = Drawing.new("Circle")
SilentFOVCircle.Color = Color3.fromRGB(255, 255, 0)
SilentFOVCircle.Thickness = 1.5
SilentFOVCircle.NumSides = 64
SilentFOVCircle.Filled = false
SilentFOVCircle.Transparency = 1
SilentFOVCircle.Radius = FOVRadius
SilentFOVCircle.Visible = false

local Tracer = Drawing.new("Line")
Tracer.Thickness = 1.5
Tracer.Color = Color3.fromRGB(124, 252, 0)
Tracer.Transparency = 1
Tracer.Visible = false

-- -------------------------------------------------
-- Helper functions (unchanged)
-- -------------------------------------------------
local function getPing()
	local stats = LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("NetworkStats")
	if stats then
		local pingText = stats:FindFirstChild("PingLabel")
		if pingText then
			local ping = tonumber(pingText.Text:match("%d+"))
			return ping and ping / 1000 or 0.2
		end
	end
	return 0.2
end

local function getClosestTarget()
	local closest = nil
	local shortestDistance = math.huge
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			local head = player.Character.Head
			local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if onScreen then
				local screenPos = Vector2.new(pos.X, pos.Y)
				local distFromCenter = (screenPos - center).Magnitude
				if distFromCenter <= FOVRadius then
					local toTarget = (head.Position - Camera.CFrame.Position).Unit
					local forward = Camera.CFrame.LookVector
					local dot = forward:Dot(toTarget)
					if dot > 0.5 then
						local distance3D = (head.Position - LocalPlayer.Character.Head.Position).Magnitude
						if distance3D < shortestDistance then
							shortestDistance = distance3D
							closest = player
						end
					end
				end
			end
		end
	end
	return closest
end

local function predictPosition(head, hrp)
	local ping = getPing()
	local velocity = hrp and hrp.Velocity or Vector3.zero
	return head.Position + (velocity * ping * 1.15)
end

-- -------------------------------------------------
-- Render loop – now respects the new toggles
-- -------------------------------------------------
RunService.RenderStepped:Connect(function()
    -- FOV circle visibility
	SilentFOVCircle.Visible = SilentAimEnabled and ShowFOVEnabled
	SilentFOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	SilentFOVCircle.Radius = FOVRadius
	if SilentAimEnabled then
		CurrentTarget = getClosestTarget()
	else
		CurrentTarget = nil
	end
	if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") then
		local targetHead = CurrentTarget.Character.Head
		local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
		if myHead then
			local myScreenPos, myOnScreen = Camera:WorldToViewportPoint(myHead.Position)
			local targetScreenPos, targetOnScreen = Camera:WorldToViewportPoint(targetHead.Position)
			if myOnScreen and targetOnScreen then
				Tracer.Visible = true
				Tracer.From = Vector2.new(myScreenPos.X, myScreenPos.Y)
				Tracer.To = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
			else
				Tracer.Visible = false
			end
		end
	else
		Tracer.Visible = false
	end
end)

local oldFire
oldFire = hookfunction(game:GetService("ReplicatedStorage").Remotes.Send.FireServer, function(self, ...)
	local args = {
		...
	}
	if SilentAimEnabled and args[2] == "shoot_gun" and CurrentTarget then
		local head = CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head")
		local hrp = CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
		if head then
			local aimPos = predictPosition(head, hrp)

			args[4] = CFrame.new(LocalPlayer.Character.Head.Position, aimPos)
			args[4] = CFrame.new(math.huge, math.huge, math.huge)
			args[5] = {
				[1] = {
					[1] = {
						["Instance"] = head,
						["Normal"] = Vector3.new(0, 1, 0),
						["Position"] = aimPos
					}
				}
			}

			local beam = Instance.new("Part", workspace)
			beam.Anchored = true
			beam.CanCollide = false
			beam.Size = Vector3.new(0.15, 0.15, (aimPos - LocalPlayer.Character.Head.Position).Magnitude)
			beam.CFrame = CFrame.new(LocalPlayer.Character.Head.Position, aimPos) * CFrame.new(0, 0, -beam.Size.Z / 2)
			beam.Color = Color3.fromRGB(255, 50, 50)
			beam.Material = Enum.Material.Neon
			beam.Transparency = 0.25
			game:GetService("Debris"):AddItem(beam, 0.15)
		end
	end
	return oldFire(self, unpack(args))
end)


-- -------------------------------------------------
-- UI Controls
-- -------------------------------------------------
CombatTab:Toggle({
	Title = "Silent Aim",
	Desc = "bullet to the head",
	Icon = "check",
	Type = "Checkbox",
	Default = false,
	Callback = function(state)
		SilentAimEnabled = state
	end
})

CombatTab:Toggle({                     -- << NEW
	Title = "Show FOV",
	Desc = "Circle",
	Icon = "check",
	Type = "Checkbox",
	Default = false,
	Callback = function(state)
		ShowFOVEnabled = state
	end
})

CombatTab:Toggle({                     -- << NEW
	Title = "Wallbang",
	Desc = "No collide bullet",
	Icon = "check",
	Type = "Checkbox",
	Default = false,
	Callback = function(state)
		WallbangEnabled = state
	end
})

CombatTab:Slider({
	Title = "Fov Size: ",
	Step = 1,
	Value = {
		Min = 20,
		Max = 1000,
		Default = FOVRadius,
	},
	Callback = function(value)
		FOVRadius = tonumber(value) or 120
	end
})


local VisualTab = Window:Tab({
	Title = 'Visual',
	Icon = 'eye',
})

VisualTab:Section({
	Title = 'Players:',
})

-- 🎨 ค่าเริ่มต้นของ ESP Module
local ESPModule = {
	Settings = {
		Box = {
			Enabled = false,
			Color = Color3.fromRGB(255, 250, 250)
		},
		Name = {
			Enabled = false,
			Color = Color3.fromRGB(255, 250, 250)
		},
		Tracer = {
			Enabled = false,
			Color = Color3.fromRGB(255, 250, 250)
		},
		Distance = {
			Enabled = false,
			Color = Color3.fromRGB(255, 250, 250)
		},
		RGBEnabled = false, -- ✅ toggle เปิด/ปิด RGB
		Gradient = {
			From = Color3.fromRGB(255, 250, 250), -- เริ่มสี
		}
	},
	drawings = {},
}

function ESPModule.CreateDrawings(player)
	if ESPModule.drawings[player] then
		return
	end
	local drawings = {
		Box = Drawing.new('Square'),
		Name = Drawing.new('Text'),
		Tracer = Drawing.new('Line'),
		Distance = Drawing.new('Text'),
	}
	drawings.Box.Filled = false
	drawings.Box.Visible = false
	drawings.Name.Center = true
	drawings.Name.Outline = true
	drawings.Name.Visible = false
	drawings.Tracer.Visible = false
	drawings.Distance.Center = true
	drawings.Distance.Outline = true
	drawings.Distance.Visible = false
	ESPModule.drawings[player] = drawings
end

-- 🟩 Toggle Control
VisualTab:Toggle({
	Title = 'Box ESP',
	Default = false,
	Callback = function(Value)
		ESPModule.Settings.Box.Enabled = Value
	end,
})

VisualTab:Toggle({
	Title = 'Name ESP',
	Default = false,
	Callback = function(Value)
		ESPModule.Settings.Name.Enabled = Value
	end,
})

VisualTab:Toggle({
	Title = 'Tracer ESP',
	Default = false,
	Callback = function(Value)
		ESPModule.Settings.Tracer.Enabled = Value
	end,
})

VisualTab:Toggle({
	Title = 'Distance ESP',
	Default = false,
	Callback = function(Value)
		ESPModule.Settings.Distance.Enabled = Value
	end,
})

-- 🌈 เพิ่ม Toggle เปิด/ปิด RGB Effect
VisualTab:Toggle({
	Title = 'Enable RGB Color',
	Default = false,
	Callback = function(Value)
		ESPModule.Settings.RGBEnabled = Value
	end,
})

-- 🎨 Gradient สีแบบคงที่ (ตอน RGB ปิด)
VisualTab:Colorpicker({
	Title = 'Esp Color',
	Default = ESPModule.Settings.Gradient.From,
	Callback = function(Color)
		ESPModule.Settings.Gradient.From = Color
	end,
})

-- 🎥 วาด ESP
RunService.RenderStepped:Connect(function()
    -- ใช้สีคงที่ (จาก colour picker) หรือสี RGB ถ้าเปิด toggle
	local finalColor
	if ESPModule.Settings.RGBEnabled then
		local hue = (tick() % 5) / 5
		finalColor = Color3.fromHSV(hue, 1, 1)
	else
		finalColor = ESPModule.Settings.Gradient.From   -- ใช้สีเริ่มต้นของ gradient
	end
	for player, drawings in pairs(ESPModule.drawings) do
		if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = player.Character.HumanoidRootPart
			local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)

            -- Box
			if ESPModule.Settings.Box.Enabled and onScreen then
				drawings.Box.Visible = true
				drawings.Box.Color   = finalColor
				drawings.Box.Size    = Vector2.new(20, 30)
				drawings.Box.Position = Vector2.new(pos.X - 15, pos.Y - 20)
			else
				drawings.Box.Visible = false
			end

            -- Name
			if ESPModule.Settings.Name.Enabled and onScreen then
				drawings.Name.Visible = true
				drawings.Name.Text    = player.Name
				drawings.Name.Color   = finalColor
				drawings.Name.Position = Vector2.new(pos.X, pos.Y - 55)
			else
				drawings.Name.Visible = false
			end

            -- Tracer
			if ESPModule.Settings.Tracer.Enabled and onScreen then
				drawings.Tracer.Visible = true
				drawings.Tracer.From    = Vector2.new(CurrentCamera.ViewportSize.X / 2, 0)   -- จากด้านบนจอ
				drawings.Tracer.To      = Vector2.new(pos.X, pos.Y)
				drawings.Tracer.Color   = finalColor
			else
				drawings.Tracer.Visible = false
			end

            -- Distance
			if ESPModule.Settings.Distance.Enabled and onScreen then
				drawings.Distance.Visible = true
				local distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
				drawings.Distance.Text    = distance .. "m"
				drawings.Distance.Color   = finalColor
				drawings.Distance.Position = Vector2.new(pos.X, pos.Y + 40)
			else
				drawings.Distance.Visible = false
			end
		else
            -- Player ออฟสกรีนหรือตาย → ซ่อนทุกอย่าง
			for _, d in pairs(drawings) do
				d.Visible = false
			end
		end
	end
end)

-- สร้าง Drawings ให้ player ทุกคน
for _, plr in pairs(game.Players:GetPlayers()) do
	if plr ~= game.Players.LocalPlayer then
		ESPModule.CreateDrawings(plr)
	end
end

game.Players.PlayerAdded:Connect(ESPModule.CreateDrawings)
game.Players.PlayerRemoving:Connect(function(plr)
	if ESPModule.drawings[plr] then
		for _, d in pairs(ESPModule.drawings[plr]) do
			d:Remove()
		end
		ESPModule.drawings[plr] = nil
	end
end)


VisualTab:Toggle({
	Title = 'Inventory Viewer',
	Default = true,
	Callback = function(Value)
		_G.InventoryViewerEnabled = Value
		local Players = game:GetService('Players')
		local ReplicatedStorage = game:GetService('ReplicatedStorage')
		local Client = Players.LocalPlayer
		local function GetColorFromRarity(rarityName)
			local colors = {
				['Common'] = Color3.fromRGB(255, 255, 255),
				['UnCommon'] = Color3.fromRGB(99, 255, 52),
				['Rare'] = Color3.fromRGB(51, 170, 255),
				['Legendary'] = Color3.fromRGB(255, 150, 0),
				['Epic'] = Color3.fromRGB(237, 44, 255),
				['Omega'] = Color3.fromRGB(255, 20, 51),
			}
			return colors[rarityName] or Color3.fromRGB(255, 255, 255)
		end
		if Value then
			if not _G.ViewerRunning then
				_G.ViewerRunning = true
				task.spawn(function()
					while task.wait(0.2) do
						if not _G.InventoryViewerEnabled then
							continue
						end
						pcall(function()
							for _, v in pairs(Players:GetPlayers()) do
								if v ~= Client and v.Character and v.Character:FindFirstChild('HumanoidRootPart') then
									local root = v.Character.HumanoidRootPart
									local gui = root:FindFirstChild('ItemBillboard')
									if not gui then
										gui = Instance.new('BillboardGui')
										gui.Name = 'ItemBillboard'
										gui.AlwaysOnTop = true
										gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
										gui.Size = UDim2.new(0, 200, 0, 50)
										gui.StudsOffset = Vector3.new(0, -5, 0)
										gui.ExtentsOffset = Vector3.new(0, 1, 0)
										gui.LightInfluence = 1
										gui.Parent = root
										local bg = Instance.new('Frame')
										bg.Name = 'BG'
										bg.BackgroundTransparency = 1
										bg.Size = UDim2.new(1, 0, 1, 0)
										bg.AnchorPoint = Vector2.new(0.5, 0.5)
										bg.Position = UDim2.new(0.5, 0, 0.5, 0)
										bg.Parent = gui
										local layout = Instance.new('UIListLayout')
										layout.FillDirection = Enum.FillDirection.Horizontal
										layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
										layout.VerticalAlignment = Enum.VerticalAlignment.Center
										layout.Padding = UDim.new(0, 5)
										layout.Parent = bg
									end
									local bg = gui:FindFirstChild('BG')
									if not bg then
										continue
									end
									local Items = {}

                                    -- เคลียร์ของเก่าก่อน
									for _, child in pairs(bg:GetChildren()) do
										if child:IsA('Frame') then
											child:Destroy()
										end
									end

                                    -- loop item ใน backpack + character
									for _, container in pairs({
										v:FindFirstChild('Backpack'),
										v.Character
									}) do
										if container then
											for _, tool in pairs(container:GetChildren()) do
												if tool:IsA('Tool') and not tool:GetAttribute('JobTool') and not tool:GetAttribute('Locked') then
													local itemFolder = tool:GetAttribute('AmmoType') and ReplicatedStorage.Items.gun or ReplicatedStorage.Items.melee
													for _, z in pairs(itemFolder:GetChildren()) do
														if tool:GetAttribute('RarityName') == z:GetAttribute('RarityName') and tool:GetAttribute('RarityPrice') == z:GetAttribute('RarityPrice') then
															local imageId = z:GetAttribute('ImageId')
															if imageId then
																Items[z.Name] = true
																if not bg:FindFirstChild(z.Name .. '_bg') then
																	local iconBg = Instance.new('Frame')
																	iconBg.Name = z.Name .. '_bg'
																	iconBg.Size = UDim2.new(0, 34, 0, 34)
																	iconBg.BackgroundColor3 = GetColorFromRarity(z:GetAttribute('RarityName'))
																	iconBg.BackgroundTransparency = 1
																	iconBg.BorderSizePixel = 0
																	iconBg.Parent = bg
																	local bgImage = Instance.new('ImageLabel')
																	bgImage.Name = 'Background'
																	bgImage.Size = UDim2.new(1, 0, 1, 0)
																	bgImage.BackgroundTransparency = 1
																	bgImage.Image = 'rbxassetid://137066731814190'
																	bgImage.ImageColor3 = GetColorFromRarity(z:GetAttribute('RarityName'))
																	bgImage.ZIndex = 0
																	bgImage.Parent = iconBg
																	local corner = Instance.new('UICorner')
																	corner.CornerRadius = UDim.new(0.15, 0)
																	corner.Parent = iconBg
																	local icon = Instance.new('ImageLabel')
																	icon.Name = z.Name
																	icon.Image = imageId
																	icon.BackgroundTransparency = 1
																	icon.BorderSizePixel = 0
																	icon.Size = UDim2.new(0.85, 0, 0.85, 0)
																	icon.Position = UDim2.new(0.075, 0, 0.075, 0)
																	icon.Parent = iconBg
																	local corner2 = Instance.new('UICorner')
																	corner2.CornerRadius = UDim.new(0, 9)
																	corner2.Parent = icon
																end
															end
														end
													end
												end
											end
										end
									end
									gui.Enabled = _G.InventoryViewerEnabled
									for _, child in pairs(bg:GetChildren()) do
										if child:IsA('Frame') then
											local itemName = child.Name:gsub('_bg$', '')
											if not Items[itemName] then
												child:Destroy()
											end
										end
									end
								end
							end
						end)
					end
				end)
			end
		else
            -- ลบ GUI เมื่อปิด
			for _, v in pairs(Players:GetPlayers()) do
				if v.Character and v.Character:FindFirstChild('HumanoidRootPart') then
					local gui = v.Character.HumanoidRootPart:FindFirstChild('ItemBillboard')
					if gui then
						gui:Destroy()
					end
				end
			end
		end
	end  -- ปิด Callback function
})  -- ปิด table ของ Toggle


local MiscTab = Window:Tab({
	Title = 'Misc',
	Icon = 'circle-ellipsis',
})

local EnabledSkip = false

-- ปุ่ม Toggle
MiscTab:Toggle({
	Title = 'Skip Animation',
	Icon = 'check',
	Type = 'Checkbox',
	Value = false,
	Callback = function(Value)
		EnabledSkip = Value
	end,
})

-- วนตรวจสอบสถานะการเปิดใช้งาน
func['SkipSpinAnimation'] = function()
	while task.wait() do
		if EnabledSkip then
			if CrateController.spinning.get() then
				CrateController.skip_spin()
			end
		end
	end
end

-- เริ่มทำงานฟังก์ชันใน background
task.spawn(func['SkipSpinAnimation'])



local GraphicsTab = Window:Tab({
	Title = 'Graphic',
	Icon = 'monitor', -- optional
})

GraphicsTab:Button({
	Title = 'BoostFps',
	Desc = 'SuperVeryUltraLowPotato Graphic',
	Icon = "rocket",
	Locked = false,
	Callback = function()
		loadstring(game:HttpGet('https://pastefy.app/Pmu7jqMe/raw'))()
	end,
})

-- ตัวแปรเก็บสถานะ WhiteScreen
local WhiteScreenEnabled = false

GraphicsTab:Toggle({
	Title = 'White Screen',
	Desc = '<<<3',
	Locked = false,
	Callback = function(Value)
		WhiteScreenEnabled = Value -- เก็บสถานะ toggle
		local RunService = game:GetService("RunService")

        -- เปิด/ปิด rendering ตามสถานะ toggle
		RunService:Set3dRenderingEnabled(not WhiteScreenEnabled)
	end,
})


--====================================================
-- 🌐 SERVER TAB
--====================================================
local ServerTab = Window:Tab({
	Title = 'Server',
	Icon = 'server',
})

ServerTab:Section({
	Title = 'Server Information:',
})

-- ฟังก์ชันดึงรหัส Server
local function GetJobID()
	return game.JobId or "Unknown"
end

-- แสดง Server Code
local ServerCodeLabel = ServerTab:Code({
	Title = 'Current Server',
	Code = 'Server Code: ' .. GetJobID()
})

ServerTab:Divider()

ServerTab:Section({
	Title = 'Server Utilities:',
})

-- ช่องกรอกโค้ด Server
local ServerCode = ''

ServerTab:Input({
	Title = 'Enter Server Code',
	Placeholder = 'Paste server JobId here...',
	Callback = function(Value)
		ServerCode = Value
	end
})

-- ปุ่ม Join Server ด้วยโค้ด
ServerTab:Button({
	Title = 'Join by Code',
	Icon = 'log-in',
	Callback = function()
		if ServerCode == '' then
			warn('ใส่codeดิน้อง')
			return
		end
		local TeleportService = game:GetService('TeleportService')
		TeleportService:TeleportToPlaceInstance(game.PlaceId, ServerCode, game.Players.LocalPlayer)
	end
})


ServerTab:Button({
	Title = 'Rejoin Current Server',
	Icon = 'refresh-ccw',
	Callback = function()
		local TeleportService = game:GetService('TeleportService')
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
	end
})

ServerTab:Button({
	Title = 'Hop Server',
	Icon = 'shuffle',
	Callback = function()
		local HttpService = game:GetService('HttpService')
		local TeleportService = game:GetService('TeleportService')
		local servers = {}
		local req = game:HttpGet(
            string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)
        )
		local data = HttpService:JSONDecode(req)
		if data and data.data then
			for _, v in pairs(data.data) do
				if v.playing < v.maxPlayers then
					table.insert(servers, v.id)
				end
			end
		end
		if #servers > 0 then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], game.Players.LocalPlayer)
		end
	end
})
