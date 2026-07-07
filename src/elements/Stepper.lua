local Creator = require("../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local Utils = require("./ModernControlUtils")

local Element = {}

local function ReadValueConfig(Config)
	local ValueConfig = typeof(Config.Value) == "table" and Config.Value or {}
	local Min = Utils.ToFiniteNumber(ValueConfig.Min) or Utils.ToFiniteNumber(Config.Min) or 0
	local Max = Utils.ToFiniteNumber(ValueConfig.Max) or Utils.ToFiniteNumber(Config.Max) or 100

	if Min > Max then
		Min, Max = Max, Min
	end

	local Default = typeof(Config.Value) == "number" and Config.Value
		or Utils.ToFiniteNumber(ValueConfig.Default)
		or Utils.ToFiniteNumber(Config.Default)
		or Min
	local Increment = Utils.ToFiniteNumber(ValueConfig.Increment) or Utils.ToFiniteNumber(Config.Increment) or 1

	return Min, Max, math.clamp(Utils.ToFiniteNumber(Default) or Min, Min, Max), math.max(math.abs(Increment), 0.0001)
end

function Element:New(Config)
	local Min, Max, Default, Increment = ReadValueConfig(Config)

	local Stepper = {
		__type = "Stepper",
		Title = Config.Title or "Stepper",
		Desc = Config.Desc or nil,
		Locked = Config.Locked or false,
		LockedTitle = Config.LockedTitle,
		Value = {
			Min = Min,
			Max = Max,
			Default = Default,
			Increment = Increment,
		},
		Callback = Config.Callback or function() end,
		Format = Config.Format,
		UIElements = {},

		Width = math.max(Utils.ToFiniteNumber(Config.Width) or Utils.ToFiniteNumber(Config.ControlWidth) or 150, 128),
	}

	local CanCallback = true

	Stepper.StepperFrame = require("../components/window/Element")({
		Title = Stepper.Title,
		Desc = Stepper.Desc,
		Parent = Config.Parent,
		TextOffset = Stepper.Width + 14,
		Hover = false,
		Tab = Config.Tab,
		Index = Config.Index,
		Window = Config.Window,
		ElementTable = Stepper,
		ParentConfig = Config,
		Tags = Config.Tags,
	})

	local function FormatValue(Value)
		if typeof(Stepper.Format) == "function" then
			local Success, Result = pcall(Stepper.Format, Value, Stepper.Value.Min, Stepper.Value.Max)
			if Success and Result ~= nil then
				return tostring(Result)
			end
		end

		return Utils.FormatNumber(Value)
	end

	local function CreateIconButton(Name, IconName)
		local IconInfo = Creator.Icon(IconName)
		local Icon = New("ImageLabel", {
			Name = "Icon",
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = IconInfo[1],
			ImageRectOffset = IconInfo[2].ImageRectPosition,
			ImageRectSize = IconInfo[2].ImageRectSize,
			ThemeTag = {
				ImageColor3 = "StepperIcon",
			},
		})

		local Button = Creator.NewRoundFrame(11, "Squircle", {
			Name = Name,
			Size = UDim2.new(0, 34, 0, 34),
			ImageTransparency = 0.9,
			ThemeTag = {
				ImageColor3 = "StepperButton",
			},
		}, {
			Icon,
		}, true)

		return Button, Icon
	end

	local MinusButton, MinusIcon = CreateIconButton("Minus", "minus")
	local PlusButton, PlusIcon = CreateIconButton("Plus", "plus")

	Stepper.UIElements.ValueLabel = New("TextLabel", {
		Name = "Value",
		Size = UDim2.new(1, -78, 0, 34),
		BackgroundTransparency = 1,
		Text = FormatValue(Stepper.Value.Default),
		TextSize = 14,
		TextTruncate = "AtEnd",
		FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
		ThemeTag = {
			TextColor3 = "StepperText",
		},
	})

	local ValueBackground = Creator.NewRoundFrame(11, "Squircle", {
		Name = "ValueBackground",
		Size = UDim2.new(1, -78, 0, 34),
		ImageTransparency = 0.94,
		ThemeTag = {
			ImageColor3 = "StepperValueBackground",
		},
	}, {
		Stepper.UIElements.ValueLabel,
	})

	Stepper.UIElements.Container = New("Frame", {
		Name = "Stepper",
		Size = UDim2.new(0, Stepper.Width, 0, 36),
		Position = UDim2.new(1, 0, Config.Window.NewElements and 0 or 0.5, 0),
		AnchorPoint = Vector2.new(1, Config.Window.NewElements and 0 or 0.5),
		BackgroundTransparency = 1,
		Parent = Stepper.StepperFrame.UIElements.Main,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 5),
			FillDirection = "Horizontal",
			HorizontalAlignment = "Right",
			VerticalAlignment = "Center",
		}),
		MinusButton,
		ValueBackground,
		PlusButton,
	})

	local function UpdateButtonStates(IsAnimated)
		local AtMin = Stepper.Value.Default <= Stepper.Value.Min
		local AtMax = Stepper.Value.Default >= Stepper.Value.Max
		local MinusTransparency = AtMin and 0.7 or 0
		local PlusTransparency = AtMax and 0.7 or 0

		if IsAnimated then
			Tween(MinusIcon, 0.1, { ImageTransparency = MinusTransparency }):Play()
			Tween(PlusIcon, 0.1, { ImageTransparency = PlusTransparency }):Play()
		else
			MinusIcon.ImageTransparency = MinusTransparency
			PlusIcon.ImageTransparency = PlusTransparency
		end
	end

	local function UpdateValue(Value, IsCallback)
		local Number = Utils.ToFiniteNumber(Value)
		if Number == nil then
			return Stepper.Value.Default
		end

		Stepper.Value.Default = math.clamp(Number, Stepper.Value.Min, Stepper.Value.Max)
		Stepper.UIElements.ValueLabel.Text = FormatValue(Stepper.Value.Default)
		UpdateButtonStates(true)

		if CanCallback and IsCallback ~= false then
			Creator.SafeCallback(Stepper.Callback, Stepper.Value.Default)
		end

		return Stepper.Value.Default
	end

	function Stepper:Lock()
		Stepper.Locked = true
		CanCallback = false
		return Stepper.StepperFrame:Lock(Stepper.LockedTitle)
	end
	function Stepper:Unlock()
		Stepper.Locked = false
		CanCallback = true
		return Stepper.StepperFrame:Unlock()
	end

	function Stepper:Get()
		return Stepper.Value.Default
	end

	function Stepper:Set(Value, IsCallback)
		return UpdateValue(Value, IsCallback)
	end

	function Stepper:SetRange(NewMin, NewMax)
		NewMin = Utils.ToFiniteNumber(NewMin)
		NewMax = Utils.ToFiniteNumber(NewMax)

		if NewMin == nil or NewMax == nil then
			return Stepper.Value.Min, Stepper.Value.Max
		end

		if NewMin > NewMax then
			NewMin, NewMax = NewMax, NewMin
		end

		Stepper.Value.Min = NewMin
		Stepper.Value.Max = NewMax
		UpdateValue(Stepper.Value.Default, false)

		return Stepper.Value.Min, Stepper.Value.Max
	end

	function Stepper:SetMin(NewMin)
		Stepper:SetRange(NewMin, math.max(Utils.ToFiniteNumber(NewMin) or Stepper.Value.Min, Stepper.Value.Max))
		return Stepper.Value.Min
	end

	function Stepper:SetMax(NewMax)
		Stepper:SetRange(math.min(Stepper.Value.Min, Utils.ToFiniteNumber(NewMax) or Stepper.Value.Max), NewMax)
		return Stepper.Value.Max
	end

	Creator.AddSignal(MinusButton.MouseButton1Click, function()
		Stepper:Set(Stepper.Value.Default - Stepper.Value.Increment)
	end)
	Creator.AddSignal(PlusButton.MouseButton1Click, function()
		Stepper:Set(Stepper.Value.Default + Stepper.Value.Increment)
	end)

	UpdateButtonStates(false)

	if Stepper.Locked then
		Stepper:Lock()
	end

	return Stepper.__type, Stepper
end

return Element
