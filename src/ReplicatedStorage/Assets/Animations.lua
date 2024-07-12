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
		Slide = "rbxassetid://13884788134",
		Crouch = "rbxassetid://18389522899",
		Sprinting = "rbxassetid://15407280617",
	},
	Emotes = {
		-- Sleep = emotes.Sleep.animation,
		Club_Dance = emotes.Club_Dance.animation,
		Boneless = emotes.Boneless.animation,
		Feet_Clap = emotes.Feet_Clap.animation,
		Dab = emotes.Dab.animation,
		Cosita = emotes.Cosita.animation,
		The_Twist = emotes.The_Twist.animation,
		Zombiller = emotes.Zombiller.animation,
		Worming = emotes.Worming.animation,
		Hype = emotes.Hype.animation,
		Fresh = emotes.Fresh.animation,
		Take_The_L = emotes.Take_The_L.animation,
		The_Robot = emotes.The_Robot.animation,
		Ballin = emotes.Ballin.animation,
		Slitherin = emotes.Slitherin.animation,
		Rider = emotes.Rider.animation,
		Bandit_Dance = emotes.Bandit_Dance.animation,
		Eagling = emotes.Eagling.animation,
	},
}
