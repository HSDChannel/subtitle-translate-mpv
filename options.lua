local mp = require 'mp'
local opt = require 'mp.options'

---@class ObserveGetter
---@field hook fun(): nil
---@field get fun(): string

---@param property string
---@return ObserveGetter
local function observe(property)
	local prop = mp.get_property(property)
	local function fn(value) prop = value end

	return {
		hook = function ()
			mp.observe_property(property, nil, fn)
		end,
		get = function () return prop end,
	}
end

local defineOptions = function (o)
	---@type table<string, fun(): string>
	local getters = {}

	opt.read_options(o, mp.get_script_name())

	-- Call hook on observable props if value not overriden from read_options.
	-- Getter is moved out of the table so __index fires and returns its current value.
	for k, v in pairs(o) do
		if type(v) == 'table' and v.hook ~= nil and v.get ~= nil then
			v.hook()
			getters[k] = v.get
			o[k] = nil
		end
	end

	return setmetatable(o, {
		__index = function (_, index)
			local getter = getters[index]
			if getter then return getter() end
		end,
	})
end

---@class (exact) ScriptOptions
---@field defaultDelay number
---@field translator string
---@field crowEngine string
---@field autoEnableTranslator boolean
---@field translatedOnly boolean
---@field primaryOriginal boolean
---@field fromLang string
---@field toLang string
---@field osdFont string
---@field osdFontSize number
---@field osdOriginalFontScale number
---@field overrideFonts boolean
---@field sensitivity number
---@field running boolean
---@field disabledManually boolean
---@field userDelay number
---@field actualDelay number
return defineOptions({
	defaultDelay = -0.5,
	translator = 'Console-Translate',
	crowEngine = 'google',
	autoEnableTranslator = false,
	translatedOnly = false,
	primaryOriginal = false,
	fromLang = 'en',
	toLang = 'ru',
	osdFont = observe('osd-font'),
	osdFontSize = observe('osd-font-size'),
	osdOriginalFontScale = 50,
	overrideFonts = true,
	sensitivity = 8,

	-- Mega Cringe
	running = false,
	disabledManually = false,
	userDelay = 0,
	actualDelay = 0,
})
