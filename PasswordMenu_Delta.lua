-- Menú de contraseña para Delta (todo corre en el cliente).
-- Sin pantalla negra: el juego se ve detrás y solo aparece el personaje animado + un panel pequeño.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- ⚠️ CONFIG
local PASSWORD = "67"
local BASE_URL = "https://raw.githubusercontent.com/eduardomorfin58-ux/delta-password-menu/main/frames/"
local VERSION = "v4" -- si cambias las imágenes, cambia este texto para que se vuelvan a bajar

-- Animación (sprite sheets con fondo transparente)
local SHEETS, PER_SHEET, COLS = 6, 16, 4
local FRAME_W, FRAME_H = 224, 228
local TOTAL_FRAMES, FPS = 96, 12

local gui = Instance.new("ScreenGui")
gui.Name = "PasswordMenu"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
local okParent = pcall(function()
	gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not okParent or not gui.Parent then
	gui.Parent = player:WaitForChild("PlayerGui")
end

-- Fondo gris suave (el juego se sigue viendo detrás)
local dim = Instance.new("Frame")
dim.Size = UDim2.fromScale(1, 1)
dim.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dim.BackgroundTransparency = 0.55
dim.BorderSizePixel = 0
dim.ZIndex = 0
dim.Parent = gui

-- Contenedor abajo al centro (no cubre el resto de la pantalla)
local holder = Instance.new("Frame")
holder.BackgroundTransparency = 1
holder.AnchorPoint = Vector2.new(0.5, 1)
holder.Position = UDim2.new(0.5, 0, 1, -8)
holder.Size = UDim2.fromOffset(300, 150)
holder.Parent = gui

-- Personaje animado (encima del panel)
local char = Instance.new("ImageLabel")
char.BackgroundTransparency = 1
char.AnchorPoint = Vector2.new(0.5, 1)
char.Position = UDim2.new(0.5, 0, 0, 0)
char.Size = UDim2.fromOffset(FRAME_W, FRAME_H)
char.ImageRectSize = Vector2.new(FRAME_W, FRAME_H)
char.ImageTransparency = 1
char.ZIndex = 1
char.Parent = holder
-- se adapta a pantallas pequeñas
local scale = Instance.new("UIScale")
scale.Parent = char
local cam = workspace.CurrentCamera
if cam then
	scale.Scale = math.clamp((cam.ViewportSize.Y - 175) / FRAME_H, 0.4, 1.4)
end

-- Panel
local panel = Instance.new("Frame")
panel.Size = UDim2.fromScale(1, 1)
panel.BackgroundColor3 = Color3.fromRGB(10, 20, 18)
panel.BackgroundTransparency = 0.3
panel.ZIndex = 2
panel.Parent = holder
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(150, 255, 60)
stroke.Thickness = 1.5

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(0, 6)
title.Size = UDim2.new(1, 0, 0, 22)
title.Font = Enum.Font.Code
title.Text = "CONTRASEÑA"
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(150, 255, 60)
title.ZIndex = 3
title.Parent = panel

local box = Instance.new("TextBox")
box.AnchorPoint = Vector2.new(0.5, 0)
box.Position = UDim2.new(0.5, 0, 0, 34)
box.Size = UDim2.new(1, -30, 0, 32)
box.BackgroundColor3 = Color3.new(0, 0, 0)
box.BackgroundTransparency = 0.4
box.Font = Enum.Font.Code
box.PlaceholderText = "Escribe la contraseña..."
box.PlaceholderColor3 = Color3.fromRGB(120, 140, 120)
box.Text = ""
box.TextSize = 18
box.TextColor3 = Color3.new(1, 1, 1)
box.ClearTextOnFocus = false
box.ZIndex = 3
box.Parent = panel
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

local button = Instance.new("TextButton")
button.AnchorPoint = Vector2.new(0.5, 0)
button.Position = UDim2.new(0.5, 0, 0, 74)
button.Size = UDim2.new(1, -30, 0, 32)
button.BackgroundColor3 = Color3.fromRGB(150, 255, 60)
button.Font = Enum.Font.Code
button.Text = "ENTRAR"
button.TextSize = 18
button.TextColor3 = Color3.fromRGB(10, 20, 18)
button.ZIndex = 3
button.Parent = panel
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

local msg = Instance.new("TextLabel")
msg.BackgroundTransparency = 1
msg.Position = UDim2.fromOffset(0, 114)
msg.Size = UDim2.new(1, 0, 0, 24)
msg.Font = Enum.Font.Code
msg.Text = ""
msg.TextSize = 14
msg.TextColor3 = Color3.fromRGB(255, 90, 90)
msg.ZIndex = 3
msg.Parent = panel

-- Ocultar lo escrito con asteriscos
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

local closed = false
local busy = false
local function submit()
	if busy or #real == 0 then return end
	if real == PASSWORD then
		closed = true
		for _, o in ipairs({ panel, box, button, title, msg }) do
			for _, p in ipairs({ "BackgroundTransparency", "TextTransparency" }) do
				pcall(function() TweenService:Create(o, TweenInfo.new(0.4), { [p] = 1 }):Play() end)
			end
		end
		TweenService:Create(char, TweenInfo.new(0.4), { ImageTransparency = 1 }):Play()
		TweenService:Create(dim, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
		task.wait(0.45)
		gui:Destroy()
	else
		busy = true
		msg.Text = "Contraseña incorrecta"
		real = ""
		updating = true
		box.Text = ""
		updating = false
		task.wait(1)
		msg.Text = ""
		busy = false
	end
end
button.Activated:Connect(submit)
box.FocusLost:Connect(function(enter) if enter then submit() end end)

-- Cargar y reproducir la animación en segundo plano (el menú ya está visible)
task.spawn(function()
	local assets = {}
	for i = 1, SHEETS do
		local file = ("pwmenu_%s_sheet%d.png"):format(VERSION, i)
		local ok, asset = pcall(function()
			if not isfile(file) then
				writefile(file, game:HttpGet(BASE_URL .. "sheet" .. i .. ".png"))
			end
			return getcustomasset(file)
		end)
		if not ok or not asset then
			warn("[PasswordMenu] No se pudo cargar la animación:", asset)
			return
		end
		assets[i] = asset
	end
	if closed then return end

	char.ImageTransparency = 0
	local f = 0
	while not closed and char.Parent do
		local sheet = f // PER_SHEET + 1
		local k = f % PER_SHEET
		char.Image = assets[sheet]
		char.ImageRectOffset = Vector2.new((k % COLS) * FRAME_W, (k // COLS) * FRAME_H)
		f = (f + 1) % TOTAL_FRAMES
		task.wait(1 / FPS)
	end
end)
