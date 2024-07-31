local RewardTypesEnum = {
}
local CurrenciesEnum = require(game.ReplicatedStorage.Source.Enums.CurrenciesEnum)
--Reward types
local RewardTypes = {
    BattleCoins = "battleCoins",
    BattleGems = "battleGems",
    BattlepassExp = "battlepassExp",
    Experience = "Exp",
    Experience_Boost = "Experience_Boost",
    Crate = "Crate",
    Skin = "Skin",
    Emote = "Emote",
    Emote_Icon = "Emote_Icon",
    Knockout_Effect = "Knockout_Effect",
    Weapon = "Weapon",
}

--Reward descriptions
local RewardDescriptions = {
    [RewardTypes.BattleCoins] = "BattleCoins are the main currency of the game. You can use them to buy crates and more!",
    [RewardTypes.BattleGems] = "BattleGems are the premium currency of the game. You can use them to buy crates and more!",
    [RewardTypes.Experience_Boost] = "Experience Boost is a boost that will give you 2x experience for 1 hour!",
    [RewardTypes.Crate] = "Crate is a box that contains a random weapon, customization or boost!",
    [RewardTypes.Skin] = "Skin is a cosmetic that changes the appearance of your weapon!",
    [RewardTypes.Emote] = "An Emote is a signature move your player can do in your emote wheel!",
    [RewardTypes.Emote_Icon] = "An Emote Icon is a cosmetic that can be displayed alongside normal emotes or individually in your emote wheel!",
    [RewardTypes.Weapon] = "A weapon is a tool that can be used to wipe out your enemies!",
}

local Icons = {
    [RewardTypes.BattleCoins] = CurrenciesEnum.Icons.battleCoins,
    [RewardTypes.BattleGems] = CurrenciesEnum.Icons.battleGems,
    [RewardTypes.Experience_Boost] = "rbxassetid://123456",
    [RewardTypes.BattlepassExp] = "rbxassetid://15229974173",
    [RewardTypes.Experience] = "rbxassetid://15229974173",
}

RewardTypesEnum.RewardTypes = RewardTypes
RewardTypesEnum.RewardDescriptions = RewardDescriptions
RewardTypesEnum.Icons = Icons

return RewardTypesEnum
