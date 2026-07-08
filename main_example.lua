local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/article-hub-studio/WindUI-Skibidi/main/dist/main.lua"))()

WindUI:SetMotionPreset("Liquid")

local Window = WindUI:CreateWindow({
	Title = ".ftgs hub | WindUI Full Example",
	Folder = "WindUIFullExample",
	Icon = "sparkles",
	NewElements = true,
	ElementTransparency = 0.18,
	ElementGap = 8,
	LiquidGlass = true,
	ToggleKey = Enum.KeyCode.RightShift,
	KeyBindMenu = {
		DefaultKey = "RightShift",
		QuickKeys = { "RightShift", "F", "LeftControl" },
		Scrim = false,
		BackgroundTransparency = 0.52,
		Compact = true,
		UseWindowBackground = true,
	},
	Watermark = {
		Title = "WindUI",
		Desc = "liquid build",
		Icon = "sparkles",
		Position = "BottomRight",
		Transparency = 0.2,
		Draggable = true,
	},
	Settings = {
		DefaultConfig = "full-example",
		Width = 360,
		Height = 410,
		ScrimTransparency = 0.76,
	},
	Motion = {
		Preset = "Liquid",
		Reduced = false,
	},
	Topbar = {
		Height = 44,
		ButtonsType = "Mac",
	},
	OpenButton = {
		Title = "Open WindUI",
		Icon = "sparkles",
		Glass = true,
		Enabled = true,
		Draggable = true,
		OnlyMobile = false,
		Scale = 0.55,
		Position = "TopCenter",
		Height = 46,
		IconSize = 20,
		BackgroundTransparency = 0.42,
		StrokeTransparency = 0.34,
		Color = ColorSequence.new(Color3.fromHex("#30FF6A"), Color3.fromHex("#E7FF2F")),
	},
	BackgroundColor = Color3.fromHex("#08111A"),
	BackgroundGradient = WindUI:Gradient({
		["0"] = { Color = Color3.fromHex("#08111A"), Transparency = 0.06 },
		["45"] = { Color = Color3.fromHex("#12352F"), Transparency = 0.3 },
		["100"] = { Color = Color3.fromHex("#24172D"), Transparency = 0.54 },
	}, {
		Rotation = 118,
	}),
	BackgroundOverlayTransparency = 0.47,
})

local OverviewTab = Window:Tab({
	Title = "Overview",
	Icon = "home",
})

OverviewTab:Callout({
	Title = "WindUI Full Example",
	Desc = "Full example loaded from GitHub with loadstring.",
	Variant = "Info",
})

local OverviewStats = OverviewTab:HStack({
	MinChildWidth = 220,
})
OverviewStats:StatusCard({
	Title = "Build",
	Status = "Success",
	Value = "Ready",
})
OverviewStats:StatCard({
	Title = "Elements",
	Value = "Modern",
	SubValue = "Tabs + Discord + Settings",
})

OverviewTab:Path2D({
	Title = "Path 2D",
	Desc = "Animated route drawing with a moving marker.",
	Height = 132,
	Duration = 1.15,
	Points = {
		{ 0.08, 0.68 },
		{ 0.26, 0.34 },
		{ 0.48, 0.52 },
		{ 0.68, 0.22 },
		{ 0.9, 0.42 },
	},
	Labels = {
		{ Point = 1, Text = "Start" },
		{ Point = 3, Text = "Sync" },
		{ Point = 5, Text = "Done" },
	},
})

OverviewTab:KeyValue({
	Title = "Runtime",
	Items = {
		{ Title = "Loader", Value = "loadstring" },
		{ Title = "Theme", Value = WindUI:GetCurrentTheme() },
		{ Title = "Topbar", Value = "Mac + Settings Gear" },
	},
})

local SettingsTab = Window:Tab({
	Title = "Settings",
	Icon = "settings",
})

SettingsTab:Button({
	Title = "Open Settings Panel",
	Icon = "settings",
	Keybind = "G",
	Callback = function()
		if Window.SettingsMenu then
			Window.SettingsMenu:Toggle()
		end
	end,
})

SettingsTab:Toggle({
	Title = "Mobile Boost",
	Desc = "Shown inside the mobile keybind menu.",
	Value = true,
	Keybind = "T",
})

SettingsTab:SegmentedControl({
	Title = "Demo Mode",
	Options = { "Clean", "Dense", "Glass" },
	Value = "Glass",
})

SettingsTab:Slider({
	Title = "Background Overlay",
	Value = {
		Min = 0.25,
		Max = 0.75,
		Default = 0.47,
		Increment = 0.01,
	},
	Callback = function(Value)
		Window:SetBackgroundOverlayTransparency(Value)
	end,
})

SettingsTab:ChipList({
	Title = "Theme Tags",
	Options = { "Glass", "Mobile", "Motion" },
	Value = { "Glass", "Mobile" },
})

SettingsTab:Dropdown({
	Title = "Full Width Dropdown",
	Desc = "Auto chooses up or down and matches the trigger width.",
	Values = { "Auto", "Down", "Up" },
	Value = "Auto",
	FullWidth = true,
	Direction = "Auto",
	Side = "Left",
})

local DropdownRow = SettingsTab:HStack({
	MinChildWidth = 180,
})
DropdownRow:Dropdown({
	Title = "Open Left",
	Values = { "Alpha", "Beta", "Gamma" },
	Value = "Alpha",
	Direction = "Left",
	MenuWidth = 170,
})
DropdownRow:Dropdown({
	Title = "Open Right",
	Values = { "North", "East", "South", "West" },
	Value = "East",
	Direction = "Right",
	MenuWidth = 170,
})

SettingsTab:Slider({
	Title = "Element Transparency",
	Value = {
		Min = 0,
		Max = 0.65,
		Default = 0.18,
		Increment = 0.01,
	},
	Callback = function(Value)
		Window:SetElementTransparency(Value)
	end,
})

local PremiumTab = Window:Tab({
	Title = "Premium",
	Icon = "crown",
	Golden = true,
	Desc = "Golden tab and button effects",
})

PremiumTab:Callout({
	Title = "Golden Components",
	Desc = "Use Golden = true or Premium = true on tabs and buttons.",
	Variant = "Info",
	Icon = "sparkles",
})

PremiumTab:Button({
	Title = "Golden Action",
	Desc = "Premium button with sheen and sparkle animation.",
	Icon = "sparkles",
	Golden = true,
	Callback = function()
		WindUI:Notify({
			Title = "Premium",
			Content = "Golden button callback fired.",
			Icon = "crown",
		})
	end,
})

local PremiumRow = PremiumTab:HStack({
	MinChildWidth = 150,
})
PremiumRow:Button({
	Title = "Reward",
	Icon = "gem",
	Premium = true,
})
PremiumRow:Button({
	Title = "Boost",
	Icon = "zap",
	Golden = true,
})

PremiumTab:KeyValue({
	Title = "Premium API",
	Items = {
		{ Title = "Tab", Value = "Golden = true" },
		{ Title = "Button", Value = "Premium = true" },
		{ Title = "Motion", Value = "Sheen + sparkle" },
	},
})

local LinkedTab = Window:Tab({
	Title = "Linked Corners",
	Icon = "combine",
	LinkCorners = true,
	Gap = 1,
})

LinkedTab:Callout({
	Title = "Linked Element Stack",
	Desc = "This tab uses LinkCorners = true, so nearby elements share only the outside corners.",
	Variant = "Info",
})

LinkedTab:Button({
	Title = "Top Action",
	Icon = "mouse-pointer-click",
	Callback = function()
		WindUI:Notify({
			Title = "Linked corners",
			Content = "Top element keeps only top corners rounded.",
			Icon = "combine",
		})
	end,
})

LinkedTab:Toggle({
	Title = "Middle Toggle",
	Desc = "Middle element stays square while linked.",
	Value = true,
})

LinkedTab:Slider({
	Title = "Bottom Slider",
	Value = {
		Min = 0,
		Max = 100,
		Default = 64,
		Increment = 1,
	},
})

LinkedTab:Space()

local LinkedRow = LinkedTab:HStack({
	LinkCorners = true,
	MinChildWidth = 72,
})
LinkedRow:Button({
	Title = "Left",
	Icon = "arrow-left",
})
LinkedRow:Button({
	Title = "Center",
	Icon = "minus",
})
LinkedRow:Button({
	Title = "Right",
	Icon = "arrow-right",
})

LinkedTab:Space()

LinkedTab:KeyValue({
	Title = "Corner Mode",
	Items = {
		{ Title = "Tab", Value = "LinkCorners" },
		{ Title = "Gap", Value = "1px" },
		{ Title = "Nested row", Value = "Left / Center / Right" },
	},
})

local DiscordTab = Window:Tab({
	Title = "Discord",
	Icon = "message-circle",
})

local InviteCard = DiscordTab:DiscordCard({
	Title = "WindUI Community",
	Desc = "Copy the invite or run a custom callback from one card.",
	Invite = "ftgs-development-hub-1300692552005189632",
	Members = "10k+",
	Online = "Live",
	Callback = function(Url)
		WindUI:Notify({
			Title = "Discord callback",
			Content = Url,
			Icon = "external-link",
		})
	end,
})

local DiscordActions = DiscordTab:HStack()
DiscordActions:Button({
	Title = "Copy",
	Icon = "copy",
	Callback = function()
		InviteCard:Copy()
	end,
})
DiscordActions:Button({
	Title = "Highlight",
	Icon = "scan",
	Callback = function()
		InviteCard:Highlight()
	end,
})

DiscordTab:Timeline({
	Title = "Invite Flow",
	Items = {
		{ Title = "URL normalized", Value = InviteCard:GetUrl() },
		{ Title = "Copy fallback", Value = "Notify" },
		{ Title = "Join callback", Value = "Enabled" },
	},
})

local MotionTab = Window:Tab({
	Title = "Motion",
	Icon = "sparkles",
})

local SectionBox = MotionTab:Section({
	Title = "Section Box Tabs",
	Desc = "TabBox keeps page height synced after nested elements mount.",
	Icon = "folder-kanban",
	Box = true,
	BoxBorder = true,
	Opened = true,
})

local BoxTabs = SectionBox:TabBox({
	Title = "Animated Pages",
	Desc = "Nested controls with page switch animation",
})

local Overview = BoxTabs:Tab({
	Title = "Overview",
	Icon = "badge-check",
})
Overview:StatusCard({
	Title = "Renderer",
	Status = "Success",
	Value = "Ready",
})
Overview:ProgressBar({
	Title = "Load",
	Value = 72,
})

local Controls = BoxTabs:Tab({
	Title = "Controls",
	Icon = "sliders-horizontal",
})
local ControlRow = Controls:HStack()
ControlRow:Stepper({
	Title = "Amount",
	Value = {
		Min = 1,
		Max = 10,
		Default = 4,
		Increment = 1,
	},
})
ControlRow:Toggle({
	Title = "Pulse",
	Value = true,
})
Controls:ChipList({
	Title = "Filters",
	Options = { "Motion", "Mobile", "Glass" },
	Value = { "Motion", "Glass" },
})
Controls:Path2D({
	Title = "Control Path",
	Desc = "Replayable 2D path animation.",
	Height = 118,
	Duration = 0.95,
	Points = {
		{ 0.1, 0.5 },
		{ 0.32, 0.22 },
		{ 0.58, 0.68 },
		{ 0.86, 0.34 },
	},
	Labels = {
		{ Point = 1, Text = "A" },
		{ Point = 4, Text = "B" },
	},
})

local Logs = BoxTabs:Tab({
	Title = "Logs",
	Icon = "history",
})
Logs:Timeline({
	Title = "Events",
	Items = {
		{ Title = "Window opened", Value = "Done" },
		{ Title = "TabBox measured", Value = "Done" },
		{ Title = "Animations active", Value = "Live" },
	},
})

MotionTab:Accordion({
	Title = "Motion Notes",
	OpenIndex = 1,
	Items = {
		{ Title = "Switch", Desc = "TabBox fades pages and updates height after layout changes." },
		{ Title = "Press", Desc = "Buttons and cards keep compact touch feedback." },
	},
})
