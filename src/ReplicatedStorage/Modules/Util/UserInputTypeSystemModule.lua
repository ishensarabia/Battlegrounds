local userInputService = game:GetService("UserInputService")
-- local InputTypeChangedRE = game.Workspace.RemoteEventsFolder.Inputs.InputTypeChanged

---

local UserInputTypeSystemModule = {
	inputTypes = {
		KeyboardAndMouse = "KeyboardAndMouse",
		Gamepad = "Gamepad",
		Touch = "Touch",
	},
	gamepadTypeFromNewestInput = "none",
	inputTypeThePlayerIsUsing = "KeyboardAndMouse", --keyboard mouse is default
	gamepadType = "none", -- "none" by default. Can be "Xbox" or "PlayStation"
}

local mouseInputType = {
	Enum.UserInputType.MouseButton1,
	Enum.UserInputType.MouseButton2,
	Enum.UserInputType.MouseButton3,
	Enum.UserInputType.MouseMovement,
	Enum.UserInputType.MouseWheel,
}

local GamepadInputsList = {
	Enum.KeyCode.ButtonA,
	Enum.KeyCode.ButtonB,
	Enum.KeyCode.ButtonX,
	Enum.KeyCode.ButtonY,

	Enum.KeyCode.ButtonL1,
	Enum.KeyCode.ButtonL2,
	Enum.KeyCode.ButtonL3,

	Enum.KeyCode.ButtonR1,
	Enum.KeyCode.ButtonR2,
	Enum.KeyCode.ButtonR3,

	Enum.KeyCode.ButtonStart,
	Enum.KeyCode.ButtonSelect,

	--

	Enum.KeyCode.DPadUp,
	Enum.KeyCode.DPadDown,
	Enum.KeyCode.DPadLeft,
	Enum.KeyCode.DPadRight,

	Enum.KeyCode.Thumbstick1,
	Enum.KeyCode.Thumbstick2,
}

local mobileInputType = Enum.UserInputType.Touch

---

local Xbox_ReturnValues_List = {

	"ButtonA", -- KeyCode.ButtonA
	"ButtonB", -- KeyCode.ButtonB
	"ButtonX", -- KeyCode.ButtonX
	"ButtonY", -- KeyCode.ButtonY
	"ButtonLB", -- KeyCode.ButtonL1
	"ButtonLT", -- KeyCode.ButtonL2
	"ButtonLS", -- KeyCode.ButtonL3
	"ButtonRB", -- KeyCode.ButtonR1
	"ButtonRT", -- KeyCode.ButtonR2
	"ButtonRS", -- KeyCode.ButtonR3
	"ButtonStart", -- KeyCode.ButtonStart
	"ButtonSelect", -- KeyCode.ButtonSelect
}

local PlayStation_ReturnValues_List = {

	"ButtonCross", -- KeyCode.ButtonA
	"ButtonCircle", -- KeyCode.ButtonB
	"ButtonSquare", -- KeyCode.ButtonX
	"ButtonTriangle", -- KeyCode.ButtonY
	"ButtonL1", -- KeyCode.ButtonL1
	"ButtonL2", -- KeyCode.ButtonL2
	"ButtonL3", -- KeyCode.ButtonL3
	"ButtonR1", -- KeyCode.ButtonR1
	"ButtonR2", -- KeyCode.ButtonR2
	"ButtonR3", -- KeyCode.ButtonR3
	"ButtonOptions", -- KeyCode.ButtonStart

	"ButtonTouchpad", -- KeyCode.ButtonSelect
	"ButtonShare", -- KeyCode.ButtonSelect
}


-- Note: Directional inputs have the same return value. This means, if a player presses a d-pad input, then the code knows it's a gamepad, but it doesn't know what type of gamepad. (PlayStation or Xbox, not sure.)

---

userInputService.InputBegan:Connect(function(input)
	--print(input.KeyCode)

	-- Keyboard & Mouse Input: --
	if input.UserInputType == Enum.UserInputType.Keyboard then -- Keyboard inputs --
		if
			UserInputTypeSystemModule.inputTypeThePlayerIsUsing == "Gamepad"
			or UserInputTypeSystemModule.inputTypeThePlayerIsUsing == "Touch"
		then
			print("New InputType detected: Keyboard and Mouse")
			UserInputTypeSystemModule.inputTypeThePlayerIsUsing = "KeyboardAndMouse"
			-- InputTypeChangedRE:FireServer(UserInputTypeSystemModule.inputTypeThePlayerIsUsing)
			userInputService.MouseIconEnabled = true
			return
		end
	end
	for i, mouseInputs in pairs(mouseInputType) do -- Mouse inputs --
		if input.UserInputType == mouseInputs then
			if UserInputTypeSystemModule.inputTypeThePlayerIsUsing ~= "KeyboardAndMouse" then
				print("New InputType detected: Keyboard and Mouse")
				UserInputTypeSystemModule.inputTypeThePlayerIsUsing = "KeyboardAndMouse"
				-- InputTypeChangedRE:FireServer(UserInputTypeSystemModule.inputTypeThePlayerIsUsing)
				userInputService.MouseIconEnabled = true
				return
			end
		end
	end
	----

	-- Gamepad Input: --

	for i, gamepadInput in pairs(GamepadInputsList) do -- Controller button inputs --
		if input.KeyCode == gamepadInput then
			if UserInputTypeSystemModule.inputTypeThePlayerIsUsing ~= "Gamepad" then
				print("New InputType detected: Gamepad")
				UserInputTypeSystemModule.inputTypeThePlayerIsUsing = "Gamepad"
				-- InputTypeChangedRE:FireServer(UserInputTypeSystemModule.inputTypeThePlayerIsUsing)
				userInputService.MouseIconEnabled = false
			end

			local stringForKeyCodePressed = userInputService:GetStringForKeyCode(gamepadInput)

            
			for i, returnValue_PlayStation in (PlayStation_ReturnValues_List) do
				if returnValue_PlayStation == stringForKeyCodePressed then
					--print(returnValue_PlayStation,stringForKeyCodePressed)
					UserInputTypeSystemModule.gamepadTypeFromNewestInput = "PlayStation"
				end
			end


			for i, retunValue_Xbox in (Xbox_ReturnValues_List) do
				if retunValue_Xbox == stringForKeyCodePressed then
					--print(retunValue_Xbox,stringForKeyCodePressed)
					UserInputTypeSystemModule.gamepadTypeFromNewestInput = "Xbox"
				end
			end


			if UserInputTypeSystemModule.gamepadTypeFromNewestInput ~= UserInputTypeSystemModule.gamepadType then
				-- player is now using a different type of gamepad than before

				UserInputTypeSystemModule.gamepadType = UserInputTypeSystemModule.gamepadTypeFromNewestInput
				-- InputTypeChangedRE:FireServer(UserInputTypeSystemModule.inputTypeThePlayerIsUsing)

				print(UserInputTypeSystemModule.gamepadType)
			end
		end
	end
	----

	-- Touchscreen input: --
	if input.UserInputType == Enum.UserInputType.Touch then
		if UserInputTypeSystemModule.inputTypeThePlayerIsUsing ~= "Touch" then -- if not mobile/touch input already, make it.
			UserInputTypeSystemModule.gamepadTypeFromNewestInput = "none"
			print("New InputType detected: Touch")
			UserInputTypeSystemModule.inputTypeThePlayerIsUsing = "Touch"
			-- InputTypeChangedRE:FireServer(UserInputTypeSystemModule.inputTypeThePlayerIsUsing)
			task.spawn(function()
				local JumpButton_Path = script.Parent:WaitForChild("TouchGui").TouchControlFrame:WaitForChild("JumpButton", 100)
				JumpButton_Path.Position = UDim2.fromScale(0.845, 0.715)
				--JumpButton_Path.Size = UDim2.new(JumpButton_Path.Size.X*1.2,JumpButton_Path.Size.Y*1.2)
	
				local ToggleMobileButton_RemoteEvent = game.Workspace.RemoteEventsFolder.UI.ToggleMobileButtons
				ToggleMobileButton_RemoteEvent.OnClientEvent:Connect(function(whatButtonShouldBeToggled, toggleState)
					if whatButtonShouldBeToggled == "JumpButton" then
						if toggleState == false then
							JumpButton_Path.Visible = false
							--print("Mobile Jump button toggled OFF")
						elseif toggleState == true then
							JumpButton_Path.Visible = true
							--print("Mobile Jump button toggled ON")
						end
					end
			end)

			end)

			return
		end
	end
	----
end)

return UserInputTypeSystemModule
