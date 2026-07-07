local WindUI = require("../src/Init")

local Window = WindUI:CreateWindow({
	Title = "Modern Controls Test",
	NewElements = true,
})

local Tab = Window:Tab({
	Title = "Modern Controls",
})

local Radio = Tab:RadioGroup({
	Title = "Radio group",
	Options = { "Low", "Medium", "High" },
	Value = "Medium",
})

assert(Radio:Get() == "Medium")
Radio:Select("High", false)
assert(Radio:Get() == "High")

local Checks = Tab:CheckboxGroup({
	Title = "Checkbox group",
	Options = { "ESP", "Aimbot", "Fly" },
	Value = { "ESP" },
})

assert(#Checks:Get() == 1)
Checks:Toggle("Fly", false)
assert(#Checks:Get() == 2)

local Segmented = Tab:SegmentedControl({
	Title = "Segmented control",
	Options = { "Legit", "Rage", "Visual" },
	Value = "Legit",
})

assert(Segmented:Get() == "Legit")
Segmented:Select("Visual", false)
assert(Segmented:Get() == "Visual")

local TextArea = Tab:TextArea({
	Title = "Text area",
	Value = "hello",
})

assert(TextArea:Get() == "hello")
TextArea:Set("world", false)
assert(TextArea:Get() == "world")

local Stepper = Tab:Stepper({
	Title = "Stepper",
	Value = {
		Min = 1,
		Max = 5,
		Default = 3,
		Increment = 1,
	},
})

assert(Stepper:Get() == 3)
Stepper:Set(10, false)
assert(Stepper:Get() == 5)

Tab:Callout({
	Title = "Callout",
	Desc = "Static visual message",
	Variant = "Success",
})
