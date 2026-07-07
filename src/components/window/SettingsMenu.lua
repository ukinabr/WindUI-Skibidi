local UserInputService = game:GetService("UserInputService")

local Creator = require("../../modules/Creator")
local Motion = require("../../modules/Motion")
local New = Creator.New

local SettingsMenu = {}

local function GetImageTarget(Icon)
	if typeof(Icon) ~= "Instance" then
		return nil
	end

	if Icon:IsA("ImageLabel") or Icon:IsA("ImageButton") then
		return Icon
	end

	return Icon:FindFirstChildWhichIsA("ImageLabel") or Icon:FindFirstChildWhichIsA("ImageButton")
end

local function ContainsPoint(Object, Position)
	if typeof(Object) ~= "Instance" or not Object.Visible then
		return false
	end

	local AbsolutePosition = Object.AbsolutePosition
	local AbsoluteSize = Object.AbsoluteSize

	return Position.X >= AbsolutePosition.X
		and Position.X <= AbsolutePosition.X + AbsoluteSize.X
		and Position.Y >= AbsolutePosition.Y
		and Position.Y <= AbsolutePosition.Y + AbsoluteSize.Y
end

local function GetThemeList(WindUI)
	local Themes = {}

	for Key, Theme in next, WindUI:GetThemes() or {} do
		table.insert(Themes, {
			Key = Key,
			Name = Theme.Name or Key,
		})
	end

	table.sort(Themes, function(A, B)
		return A.Name < B.Name
	end)

	return Themes
end

function SettingsMenu.New(Window, WindUI, Config)
	local SettingsConfig = typeof(Window.Settings) == "table" and Window.Settings or {}
	local DefaultConfigName = SettingsConfig.DefaultConfig or "default"
	local Menu = {
		Open = false,
		Button = nil,
		Token = 0,
		UIElements = {},
		ThemeButtons = {},
	}

	local function Notify(Title, Content, Icon)
		if WindUI.Notify then
			WindUI:Notify({
				Title = Title,
				Content = Content,
				Icon = Icon,
			})
		end
	end

	local function CreateText(Parent, Text, Size, Weight, Transparency)
		return New("TextLabel", {
			BackgroundTransparency = 1,
			Text = Text or "",
			TextSize = Size or 14,
			TextTransparency = Transparency or 0,
			TextWrapped = true,
			TextXAlignment = "Left",
			AutomaticSize = "Y",
			Size = UDim2.new(1, 0, 0, 0),
			Parent = Parent,
			FontFace = Font.new(Creator.Font, Weight or Enum.FontWeight.Medium),
			ThemeTag = {
				TextColor3 = "Text",
			},
		})
	end

	local function CreateCard(Parent)
		return Creator.NewRoundFrame(Window.ElementConfig.UICorner, "Squircle", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = "Y",
			ImageTransparency = 0.94,
			Parent = Parent,
			ThemeTag = {
				ImageColor3 = "ElementBackground",
			},
		}, {
			New("UIPadding", {
				PaddingTop = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
			}),
			New("UIListLayout", {
				Padding = UDim.new(0, 8),
				FillDirection = "Vertical",
				HorizontalAlignment = "Left",
			}),
		})
	end

	local function CreateIcon(IconName, Parent, Size)
		local Icon = Creator.Image(IconName, IconName, 0, Window.Folder, "SettingsMenu", true, true, "Icon")
		Icon.Size = UDim2.new(0, Size or 16, 0, Size or 16)
		Icon.Parent = Parent
		return Icon
	end

	local function CreateActionButton(Parent, Title, IconName, Variant, Callback)
		local Button = Creator.NewRoundFrame(14, "Squircle", {
			Size = UDim2.new(1, 0, 0, 34),
			ImageTransparency = Variant == "Primary" and 0 or 0.92,
			ThemeTag = {
				ImageColor3 = Variant == "Primary" and "Primary" or "ElementBackground",
			},
			Parent = Parent,
		}, {
			New("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),
			New("UIListLayout", {
				Padding = UDim.new(0, 7),
				FillDirection = "Horizontal",
				VerticalAlignment = "Center",
				HorizontalAlignment = "Center",
			}),
			IconName and CreateIcon(IconName, nil, 15) or nil,
			New("TextLabel", {
				BackgroundTransparency = 1,
				Text = Title,
				TextSize = 13,
				FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
				TextColor3 = Variant == "Primary" and Color3.new(1, 1, 1) or nil,
				ThemeTag = {
					TextColor3 = Variant ~= "Primary" and "Text" or nil,
				},
			}),
		}, true)

		Motion.AttachPress(Button, Creator, {
			Amount = 0.97,
		})

		Creator.AddSignal(Button.MouseButton1Click, function()
			Creator.SafeCallback(Callback)
		end)

		return Button
	end

	local Root = Creator.NewRoundFrame(Window.ElementConfig.UICorner, "Squircle", {
		Name = "SettingsDropdown",
		Size = UDim2.new(0, SettingsConfig.Width or 322, 0, 0),
		AutomaticSize = "Y",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -Window.UIPadding, 0, Window.Topbar.Height + 8),
		ImageTransparency = 1,
		Visible = false,
		Active = false,
		ZIndex = 10000,
		Parent = Window.UIElements.Main.Main,
		ThemeTag = {
			ImageColor3 = "Background",
		},
	}, {
		New("UIScale", {
			Name = "Scale",
			Scale = 0.98,
		}),
		New("UIPadding", {
			PaddingTop = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 12),
		}),
		New("UIListLayout", {
			Padding = UDim.new(0, 10),
			FillDirection = "Vertical",
			HorizontalAlignment = "Left",
		}),
	})

	Menu.UIElements.Root = Root
	Menu.UIElements.Scale = Root.Scale

	local Header = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = "Y",
		BackgroundTransparency = 1,
		Parent = Root,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 10),
			FillDirection = "Horizontal",
			VerticalAlignment = "Center",
		}),
	})

	local HeaderGlyph = CreateIcon("settings", nil, 17)
	local HeaderIcon = Creator.NewRoundFrame(999, "Squircle", {
		Size = UDim2.new(0, 34, 0, 34),
		ImageTransparency = 0.9,
		ThemeTag = {
			ImageColor3 = "Primary",
		},
		Parent = Header,
	}, {
		HeaderGlyph,
	})
	HeaderGlyph.Position = UDim2.new(0.5, 0, 0.5, 0)
	HeaderGlyph.AnchorPoint = Vector2.new(0.5, 0.5)

	local HeaderTexts = New("Frame", {
		Size = UDim2.new(1, -44, 0, 0),
		AutomaticSize = "Y",
		BackgroundTransparency = 1,
		Parent = Header,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 2),
			FillDirection = "Vertical",
		}),
	})
	CreateText(HeaderTexts, "Settings", 16, Enum.FontWeight.Bold, 0)
	CreateText(HeaderTexts, "Config and theme controls", 12, Enum.FontWeight.Medium, 0.42)

	local ConfigCard = CreateCard(Root)
	CreateText(ConfigCard, "Config", 13, Enum.FontWeight.Bold, 0.08)

	local NameBoxContainer = Creator.NewRoundFrame(12, "Squircle", {
		Size = UDim2.new(1, 0, 0, 34),
		ImageTransparency = 0.92,
		ThemeTag = {
			ImageColor3 = "ElementBackground",
		},
		Parent = ConfigCard,
	}, {
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}),
	})

	local ConfigNameBox = New("TextBox", {
		Name = "ConfigName",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		Text = DefaultConfigName,
		PlaceholderText = "default",
		TextSize = 13,
		TextXAlignment = "Left",
		FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
		Parent = NameBoxContainer,
		ThemeTag = {
			TextColor3 = "Text",
			PlaceholderColor3 = "Placeholder",
		},
	})

	local ConfigMeta = CreateText(ConfigCard, "No saved configs", 12, Enum.FontWeight.Medium, 0.45)

	local ConfigActions = New("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Parent = ConfigCard,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 8),
			FillDirection = "Horizontal",
			HorizontalAlignment = "Center",
			VerticalAlignment = "Center",
		}),
	})

	local function GetConfigName()
		local Name = tostring(ConfigNameBox.Text or "")
		Name = string.gsub(Name, "^%s+", "")
		Name = string.gsub(Name, "%s+$", "")
		return Name ~= "" and Name or DefaultConfigName
	end

	local function RefreshConfigMeta()
		local Manager = Window.ConfigManager
		if not Manager or typeof(Manager) ~= "table" then
			ConfigMeta.Text = "Config is unavailable in this environment"
			return
		end

		local Success, Configs = pcall(function()
			return Manager:AllConfigs()
		end)
		local Count = Success and #Configs or 0
		ConfigMeta.Text = Count == 1 and "1 saved config" or tostring(Count) .. " saved configs"
	end

	CreateActionButton(ConfigActions, "Save", "save", "Primary", function()
		local Manager = Window.ConfigManager
		if not Manager or typeof(Manager) ~= "table" then
			Notify("Config unavailable", "Config save needs file access.", "triangle-alert")
			return
		end

		local Name = GetConfigName()
		local Success, Result = pcall(function()
			local ConfigModule = Manager:Config(Name)
			ConfigModule:Set("theme", WindUI:GetCurrentTheme())
			return ConfigModule:Save()
		end)

		if Success and Result then
			RefreshConfigMeta()
			Notify("Config saved", "Saved '" .. Name .. "'.", "check")
		else
			Notify("Config save failed", tostring(Result), "triangle-alert")
		end
	end).Size = UDim2.new(0.5, -4, 1, 0)

	CreateActionButton(ConfigActions, "Load", "download", "Secondary", function()
		local Manager = Window.ConfigManager
		if not Manager or typeof(Manager) ~= "table" then
			Notify("Config unavailable", "Config load needs file access.", "triangle-alert")
			return
		end

		local Name = GetConfigName()
		local Success, Result = pcall(function()
			local ConfigModule = Manager:Config(Name)
			local Data = ConfigModule:Load()
			if Data and Data.theme then
				WindUI:SetTheme(Data.theme)
			end
			return Data
		end)

		if Success and Result then
			Notify("Config loaded", "Loaded '" .. Name .. "'.", "refresh-cw")
		else
			Notify("Config load failed", tostring(Result), "triangle-alert")
		end
	end).Size = UDim2.new(0.5, -4, 1, 0)

	local ThemeCard = CreateCard(Root)
	CreateText(ThemeCard, "Theme", 13, Enum.FontWeight.Bold, 0.08)

	local ThemeList = New("ScrollingFrame", {
		Name = "ThemeList",
		Size = UDim2.new(1, 0, 0, SettingsConfig.ThemeListHeight or 116),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		AutomaticCanvasSize = "Y",
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = ThemeCard,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 6),
			FillDirection = "Vertical",
			HorizontalAlignment = "Left",
		}),
	})

	local function UpdateThemeButtons()
		local CurrentTheme = WindUI:GetCurrentTheme()
		for Key, Data in next, Menu.ThemeButtons do
			local Selected = Key == CurrentTheme
			Motion.Play(Data.Button, "Switch", { ImageTransparency = Selected and 0.84 or 0.94 }, nil, nil, "Theme")
			Motion.Play(Data.Label, "Switch", { TextTransparency = Selected and 0 or 0.24 }, nil, nil, "Theme")
			Motion.Play(Data.Check, "Switch", { ImageTransparency = Selected and 0 or 1 }, nil, nil, "Theme")
		end
	end

	for _, Theme in next, GetThemeList(WindUI) do
		local CheckIcon = CreateIcon("check", nil, 14)
		local ThemeButton = Creator.NewRoundFrame(12, "Squircle", {
			Size = UDim2.new(1, 0, 0, 30),
			ImageTransparency = 0.94,
			ThemeTag = {
				ImageColor3 = "Primary",
			},
			Parent = ThemeList,
		}, {
			New("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),
			New("UIListLayout", {
				FillDirection = "Horizontal",
				Padding = UDim.new(0, 8),
				VerticalAlignment = "Center",
			}),
			New("TextLabel", {
				Name = "Title",
				Size = UDim2.new(1, -22, 1, 0),
				BackgroundTransparency = 1,
				Text = Theme.Name,
				TextSize = 13,
				TextXAlignment = "Left",
				TextTruncate = "AtEnd",
				FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
				ThemeTag = {
					TextColor3 = "Text",
				},
			}),
			CheckIcon,
		}, true)

		local CheckTarget = GetImageTarget(CheckIcon)
		if CheckTarget then
			CheckTarget.ImageTransparency = 1
		end

		Menu.ThemeButtons[Theme.Key] = {
			Button = ThemeButton,
			Label = ThemeButton.Title,
			Check = CheckTarget,
		}

		Motion.AttachPress(ThemeButton, Creator, {
			Amount = 0.985,
		})

		Creator.AddSignal(ThemeButton.MouseButton1Click, function()
			WindUI:SetTheme(Theme.Key)
			UpdateThemeButtons()
		end)
	end

	function Menu:SetButton(Button)
		Menu.Button = Button
	end

	function Menu:OpenMenu()
		if Menu.Open then
			return
		end

		Menu.Open = true
		Menu.Token = Menu.Token + 1
		RefreshConfigMeta()
		UpdateThemeButtons()
		Root.Visible = true
		Root.Active = true
		Root.ImageTransparency = 1
		Menu.UIElements.Scale.Scale = 0.98
		Motion.Play(Root, "DropdownOpen", { ImageTransparency = 0 }, nil, nil, "Settings")
		Motion.Play(Menu.UIElements.Scale, "DropdownOpen", { Scale = 1 }, nil, nil, "SettingsScale")
	end

	function Menu:CloseMenu()
		if not Menu.Open then
			return
		end

		Menu.Open = false
		Menu.Token = Menu.Token + 1
		local Token = Menu.Token
		Root.Active = false
		Motion.Play(Root, "DropdownClose", { ImageTransparency = 1 }, nil, nil, "Settings")
		Motion.Play(Menu.UIElements.Scale, "DropdownClose", { Scale = 0.98 }, nil, nil, "SettingsScale")
		task.delay(Motion.GetDuration("DropdownClose"), function()
			if Token == Menu.Token then
				Root.Visible = false
			end
		end)
	end

	function Menu:Toggle()
		if Menu.Open then
			Menu:CloseMenu()
		else
			Menu:OpenMenu()
		end
	end

	Creator.AddSignal(UserInputService.InputBegan, function(Input)
		if not Menu.Open then
			return
		end
		if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		if ContainsPoint(Root, Input.Position) or ContainsPoint(Menu.Button, Input.Position) then
			return
		end

		Menu:CloseMenu()
	end)

	RefreshConfigMeta()
	UpdateThemeButtons()

	return Menu
end

return SettingsMenu
