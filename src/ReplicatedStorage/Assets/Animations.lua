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
		Build = "rbxassetid://14399306154",
	},
	Movement = {
		Forward_Dash = "rbxassetid://12432088961",
		Backwards_Dash = "rbxassetid://12432237836",
		Right_Dash = "rbxassetid://12432228382",
		Left_Dash = "rbxassetid://12432217627",
		Climb = "rbxassetid://13084101795",
		Climb_Up = "rbxassetid://13086372330",
		Slide = "rbxassetid://13884788134",
		Crouch = "rbxassetid://14449504194",
		Sprinting = "rbxassetid://15407280617",
	},
	Emotes = {
		Sleep = emotes.Sleep.animation,
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
	},
}
