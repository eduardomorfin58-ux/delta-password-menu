-- Versión para ejecutor (Delta): todo corre en el cliente, sin script de servidor.
-- Pega este script completo en Delta y ejecútalo.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ⚠️ CAMBIA ESTO
local PASSWORD = "57"
local VIDEO_URL = "https://raw.githubusercontent.com/eduardomorfin58-ux/delta-password-menu/main/fondo.mp4"
local VIDEO_FILE = "delta_fondo.mp4"

-- Descarga el video una vez y lo usa como fondo (necesita writefile/getcustomasset en Delta)
local function resolveVideo()
	local ok, asset = pcall(function()
		if not isfile(VIDEO_FILE) then
			writefile(VIDEO_FILE, game:HttpGet(VIDEO_URL))
		end
		return getcustomasset(VIDEO_FILE)
	end)
	if ok and asset then return asset end
	warn("[PasswordMenu] No se pudo cargar el video:", asset)
	return ""
end

local gui = Instance.new("ScreenGui")
gui.Name = "PasswordMenu"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
local okParent = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not okParent or not gui.Parent then gui.Parent = playerGui end

-- Video de fondo (pantalla completa, en bucle)
local video = Instance.new("VideoFrame")
video.Size = UDim2.fromScale(1, 1)
video.BackgroundColor3 = Color3.new(0, 0, 0)
video.Looped = true
video.Volume = 0.5
video.ZIndex = 1
video.Parent = gui

-- El video se descarga aparte para que el menú aparezca al instante
task.spawn(function()
	local asset = resolveVideo()
	if asset ~= "" and video.Parent then
		video.Video = asset
		video:Play()
	end
end)

-- Panel del menú
local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(340, 190)
panel.BackgroundColor3 = Color3.fromRGB(10, 20, 18)
panel.BackgroundTransparency = 0.25
panel.ZIndex = 2
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(150, 255, 60)
stroke.Thickness = 1.5

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(0, 14)
title.Size = UDim2.new(1, 0, 0, 28)
title.Font = Enum.Font.Code
title.Text = "CONTRASEÑA"
title.TextSize = 24
title.TextColor3 = Color3.fromRGB(150, 255, 60)
title.ZIndex = 3
title.Parent = panel

local box = Instance.new("TextBox")
box.AnchorPoint = Vector2.new(0.5, 0)
box.Position = UDim2.new(0.5, 0, 0, 56)
box.Size = UDim2.new(1, -40, 0, 40)
box.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
box.BackgroundTransparency = 0.4
box.Font = Enum.Font.Code
box.PlaceholderText = "Escribe la contraseña..."
box.PlaceholderColor3 = Color3.fromRGB(120, 140, 120)
box.Text = ""
box.TextSize = 20
box.TextColor3 = Color3.new(1, 1, 1)
box.ClearTextOnFocus = false
box.ZIndex = 3
box.Parent = panel
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

local button = Instance.new("TextButton")
button.AnchorPoint = Vector2.new(0.5, 0)
button.Position = UDim2.new(0.5, 0, 0, 108)
button.Size = UDim2.new(1, -40, 0, 38)
button.BackgroundColor3 = Color3.fromRGB(150, 255, 60)
button.Font = Enum.Font.Code
button.Text = "ENTRAR"
button.TextSize = 20
button.TextColor3 = Color3.fromRGB(10, 20, 18)
button.ZIndex = 3
button.Parent = panel
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

local msg = Instance.new("TextLabel")
msg.BackgroundTransparency = 1
msg.Position = UDim2.fromOffset(0, 154)
msg.Size = UDim2.new(1, 0, 0, 24)
msg.Font = Enum.Font.Code
msg.Text = ""
msg.TextSize = 16
msg.TextColor3 = Color3.fromRGB(255, 90, 90)
msg.ZIndex = 3
msg.Parent = panel

-- Ocultar lo escrito con asteriscos (Roblox no tiene TextBox de contraseña)
local real = ""
local updating = false
box:GetPropertyChangedSignal("Text"):Connect(function()
	if updating then return end
	local t = box.Text
	if #t > #real then
		real = real .. t:sub(#real + 1)
	else
		real = real:sub(1, #t)
	end
	updating = true
	box.Text = string.rep("*", #real)
	updating = false
end)

local busy = false
local function submit()
	if busy or #real == 0 then return end
	busy = true
	msg.TextColor3 = Color3.fromRGB(200, 200, 200)
	msg.Text = "Comprobando..."
	local ok = (real == PASSWORD)
	if ok then
		-- Cierra el menú y el video con un fundido
		for _, o in ipairs({ panel, video }) do
			TweenService:Create(o, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
		end
		task.wait(0.5)
		video:Pause()
		gui:Destroy()
	else
		msg.TextColor3 = Color3.fromRGB(255, 90, 90)
		msg.Text = "Contraseña incorrecta"
		real = ""
		updating = true
		box.Text = ""
		updating = false
		busy = false
	end
end

button.Activated:Connect(submit)
box.FocusLost:Connect(function(enter) if enter then submit() end end)
