local Creator = require("../modules/Creator")
local Motion = require("../modules/Motion")
local New = Creator.New

local Utils = require("./DisplayElementUtils")

local Element = {}

function Element:New(Config)
	local TabBox = {
		__type = "TabBox",
		Title = Config.Title or "Tabs",
		Desc = Config.Desc,
		Tabs = {},
		Selected = nil,
		UIElements = {},
	}

	TabBox.TabBoxFrame = require("../components/window/Element")({
		Title = TabBox.Title,
		Desc = TabBox.Desc,
		Parent = Config.Parent,
		TextOffset = 0,
		Hover = Config.Hover == true,
		Tab = Config.Tab,
		Index = Config.Index,
		Window = Config.Window,
		ElementTable = TabBox,
		ParentConfig = Config,
		Tags = Config.Tags,
	})

	TabBox.UIElements.Tabs = New("ScrollingFrame", {
		Name = "Tabs",
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		ScrollingDirection = "X",
		AutomaticCanvasSize = "X",
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ElasticBehavior = "Never",
		Parent = TabBox.TabBoxFrame.UIElements.Container,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 6),
			FillDirection = "Horizontal",
			VerticalAlignment = "Center",
			HorizontalAlignment = "Left",
			SortOrder = "LayoutOrder",
		}),
	})

	TabBox.UIElements.Pages = New("Frame", {
		Name = "Pages",
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		Parent = TabBox.TabBoxFrame.UIElements.Container,
	})

	local function UpdateTabVisuals()
		for Index, Page in next, TabBox.Tabs do
			local Selected = TabBox.Selected == Index
			Motion.Play(Page.Button, "Switch", { ImageTransparency = Selected and 0.82 or 0.94 }, nil, nil, "State")
			Motion.Play(Page.TitleLabel, "Switch", { TextTransparency = Selected and 0 or 0.25 }, nil, nil, "State")
			if Page.IconTarget then
				Motion.Play(Page.IconTarget, "Switch", { ImageTransparency = Selected and 0 or 0.35 }, nil, nil, "State")
			end
		end
	end

	local function GetPageHeight(Page)
		local Layout = Page.UIElements.Container.UIListLayout
		local Padding = Config.Window.ElementConfig.UIPadding / 2
		local Height = Layout.AbsoluteContentSize.Y / Config.UIScale + Padding
		return math.max(Height, Padding)
	end

	local function UpdatePageHeight(Page)
		if not Page or not Page.UIElements.Container then
			return
		end

		local Height = GetPageHeight(Page)
		Page.UIElements.Container.Size = UDim2.new(1, 0, 0, Height)
		TabBox.UIElements.Pages.Size = UDim2.new(1, 0, 0, Height)
		return Height
	end

	local function QueuePageHeightUpdate(Page, Index)
		task.defer(function()
			if TabBox.Selected == Index and Page and Page.UIElements.Container.Parent then
				UpdatePageHeight(Page)
			end
		end)
	end

	function TabBox:Select(Index)
		local Page = TabBox.Tabs[Index]
		if not Page then
			return nil
		end

		TabBox.Selected = Index
		for PageIndex, OtherPage in next, TabBox.Tabs do
			local IsSelected = PageIndex == Index
			OtherPage.UIElements.Container.Visible = IsSelected
			OtherPage.UIElements.Container.Active = IsSelected
			OtherPage.UIElements.Container.GroupTransparency = 1
		end

		UpdatePageHeight(Page)
		Motion.Play(Page.UIElements.Container, "Switch", { GroupTransparency = 0 }, nil, nil, "Page")
		QueuePageHeightUpdate(Page, Index)
		UpdateTabVisuals()
		return Page
	end

	function TabBox:GetSelected()
		return TabBox.Selected and TabBox.Tabs[TabBox.Selected] or nil
	end

	function TabBox:Tab(TabConfig)
		TabConfig = TabConfig or {}
		local Index = #TabBox.Tabs + 1
		local Page = {
			__type = "TabBoxPage",
			Title = TabConfig.Title or ("Tab " .. tostring(Index)),
			Value = TabConfig.Value or TabConfig.Id or Index,
			Icon = TabConfig.Icon,
			Elements = {},
			UIElements = {},
			Gap = Config.Tab and Config.Tab.Gap or 6,
		}

		local Icon = Utils.CreateIcon(Creator, Page.Icon, Config.Window.Folder, "TabBox", true, "TabBoxIcon")
		if Icon then
			Icon.Size = UDim2.new(0, 15, 0, 15)
		end
		local IconTarget = Utils.GetImageTarget(Icon)

		local Title = New("TextLabel", {
			Name = "Title",
			BackgroundTransparency = 1,
			Text = Page.Title,
			TextSize = 13,
			TextTruncate = "AtEnd",
			AutomaticSize = "X",
			FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
			ThemeTag = {
				TextColor3 = "Text",
			},
		})

		local Button = Creator.NewRoundFrame(999, "Squircle", {
			Name = "Tab",
			LayoutOrder = Index,
			Size = UDim2.new(0, math.max(72, string.len(Page.Title) * 7 + (Icon and 38 or 24)), 0, 30),
			ImageTransparency = 0.94,
			ThemeTag = {
				ImageColor3 = "TabBoxTabBackground",
			},
			Parent = TabBox.UIElements.Tabs,
		}, {
			New("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),
			New("UIListLayout", {
				Padding = UDim.new(0, 6),
				FillDirection = "Horizontal",
				VerticalAlignment = "Center",
				HorizontalAlignment = "Center",
			}),
			Icon,
			Title,
		}, true)

		local Container = New("CanvasGroup", {
			Name = "Page",
			LayoutOrder = Index,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			GroupTransparency = 1,
			Visible = false,
			Active = false,
			Parent = TabBox.UIElements.Pages,
		}, {
			New("UIPadding", {
				PaddingTop = UDim.new(0, Config.Window.ElementConfig.UIPadding / 2),
			}),
			New("UIListLayout", {
				Padding = UDim.new(0, Page.Gap),
				FillDirection = "Vertical",
				VerticalAlignment = "Top",
				HorizontalAlignment = "Left",
				SortOrder = "LayoutOrder",
			}),
		})

		Page.Button = Button
		Page.TitleLabel = Title
		Page.Icon = Icon
		Page.IconTarget = IconTarget
		Page.ElementFrame = Container
		Page.UIElements.Container = Container
		Page.UIElements.Title = Title

		Config.ElementsModule.Load(
			Page,
			Container,
			Config.ElementsModule.Elements,
			Config.Window,
			Config.WindUI,
			function()
				QueuePageHeightUpdate(Page, Index)
			end,
			Config.ElementsModule,
			Config.UIScale,
			Config.Tab
		)

		function Page:Select()
			return TabBox:Select(Index)
		end

		function Page:Destroy()
			Button:Destroy()
			Container:Destroy()
			table.remove(TabBox.Tabs, Index)
			if TabBox.Selected == Index then
				TabBox.Selected = nil
				if TabBox.Tabs[1] then
					TabBox:Select(1)
				end
			end
		end

		TabBox.Tabs[Index] = Page

		Motion.AttachPress(Button, Creator, {
			Amount = 0.97,
		})

		Creator.AddSignal(Button.MouseButton1Click, function()
			TabBox:Select(Index)
		end)

		Creator.AddSignal(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			QueuePageHeightUpdate(Page, Index)
		end)

		if not TabBox.Selected or TabConfig.Selected == true or TabConfig.Value == Config.Value then
			TabBox:Select(Index)
		else
			UpdateTabVisuals()
		end

		if typeof(TabConfig.Elements) == "function" then
			task.defer(function()
				Creator.SafeCallback(TabConfig.Elements, Page)
			end)
		end

		return Page
	end

	function TabBox:CreateTab(TabConfig)
		return TabBox:Tab(TabConfig)
	end

	for _, TabConfig in next, Config.Tabs or {} do
		TabBox:Tab(TabConfig)
	end

	return TabBox.__type, TabBox
end

return Element
