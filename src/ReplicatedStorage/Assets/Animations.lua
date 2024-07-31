--****************************************************
-- File: Animations.lua
--
-- Purpose: Stores all animations IDs.
-- Note how to add emotes: add them to the emotes table and animation table
--
-- Written By: Ishen
--
--****************************************************
local emotes = require(game.ReplicatedStorage.Source.Assets.Emotes)

return {
	Building = {
		Build = "rbxassetid://18397012701",
	},
	Movement = {
		Forward_Dash = "rbxassetid://18367046937",
		Backwards_Dash = "rbxassetid://18367977406",
		Right_Dash = "rbxassetid://18368176329",
		Left_Dash = "rbxassetid://18368474907",
		Climb = "rbxassetid://18366906994",
		Climb_Up = "rbxassetid://18367374086",
		Slide = "rbxassetid://18508394821",
		Crouch = "rbxassetid://18389522899",
		Sprinting = "rbxassetid://15407280617",
	},
}
