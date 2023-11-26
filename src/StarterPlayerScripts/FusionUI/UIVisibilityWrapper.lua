--[=[
	Hello World!

	@class UIVisibilityWrapper

	UIVisibilityWrapper(state, UI_NAME)
]=]
local StarterPlayer = game:GetService("StarterPlayer")


local UIStateManager = require(StarterPlayer.StarterPlayerScripts.Source.FusionUI.UIStateManager)

local function setVisibilityBasedOnState(fusionState, uiName)
	local state = UIStateManager:GetState()
	local uiState = state.MainUIs

	if uiState[uiName] == nil then
		UIStateManager:Dispatch(UIStateManager.Actions.AddMainUI(uiName))
	end
	local isVisible = uiState[uiName]

	fusionState:set(isVisible)
end

local function setModalVisibilityBasedOnState(fusionState)
	local state = UIStateManager:GetState()
	local isVisible = state.ModalUIsVisible

	fusionState:set(isVisible)
end

local function setupModal(fusionState)
	setModalVisibilityBasedOnState(fusionState)
	UIStateManager:Subscribe(function()
		setModalVisibilityBasedOnState(fusionState)
	end)
end

local function setupMainUI(fusionState, uiName)
	setVisibilityBasedOnState(fusionState, uiName)
	UIStateManager:Subscribe(function()
		setVisibilityBasedOnState(fusionState, uiName)
	end)
end

return function(fusionState, uiName)
	if uiName then
		setupMainUI(fusionState, uiName)
	else
		setupModal(fusionState)
	end
end
