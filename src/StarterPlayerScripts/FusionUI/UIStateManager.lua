--[=[
	Hello World!

	@class SiloController

]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")


local Silo = require(ReplicatedStorage.Packages.Silo)
local Table = require(ReplicatedStorage.Packages.TableUtil)

local UIStateManager = Silo.new({
	-- Initial state:
	MainUIs = {},
	ModalUIsVisible = true,
}, {
	-- Modifiers are functions that modify the state:
	SetUIVisibility = function(state, action)
		local uiName = action.uiName
		local visible = action.visible
		local newUIVisibility = Table.Copy(state.MainUIs)

		local modalUIVisibility = true

		for name in newUIVisibility do
			local isVisible = name == uiName and visible
			newUIVisibility[name] = isVisible

			if isVisible then
				modalUIVisibility = false
			end
		end

		state.ModalUIsVisible = modalUIVisibility

		newUIVisibility[uiName] = visible -- in case its not in the default table

		state.MainUIs = newUIVisibility
	end,
	AddMainUI = function(state, name)
		local newUIVisibility = Table.Copy(state.MainUIs)
		newUIVisibility[name] = false
		state.MainUIs = newUIVisibility
	end,
})

return UIStateManager
