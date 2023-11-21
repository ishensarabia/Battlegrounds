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
		Build = "rbxassetid://14399306154"
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
		Sleep = "rbxassetid://5375125612",
		Club_Dance = "rbxassetid://13937073595",
		Boneless = "rbxassetid://14001884975",
		Feet_Clap = "rbxassetid://14023662289",
		Dab = "rbxassetid://14023813953",
		Cosita = "rbxassetid://14023896850",
		The_Twist = "rbxassetid://14026838589",
		Zombiller = "rbxassetid://14026892525",
		Worming = "rbxassetid://14027219860",
		Hype = "rbxassetid://14032019287",
		Fresh = "rbxassetid://14034445225",
		Take_The_L = "rbxassetid://14044815170",
		The_Robot = "rbxassetid://14834257724",
		Ballin = "rbxassetid://15105435828",
		Slitherin = emotes.Slitherin.animation,
		Rider = emotes.Rider.animation,
	}
}
