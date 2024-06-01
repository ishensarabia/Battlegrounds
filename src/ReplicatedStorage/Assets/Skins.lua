local ReplicatedStorage = game:GetService("ReplicatedStorage")
local raritiesEnum = require(ReplicatedStorage.Source.Enums.RaritiesEnum)
local skins = {
    AlterEgo = {
        skinID = "rbxassetid://13643596771",
        rarity = raritiesEnum.Rare,
        name = "Alter-Ego",
    },
    Venomus = {
        skinID = "rbxassetid://358113752",
        rarity = raritiesEnum.Mythic,
        name = "Venomus",
    },
    AllSeeingEye = {
        skinID = "rbxassetid://358279560",
        rarity = raritiesEnum.Mythic,
        name = "All-Seeing Eye",
    },
    AbstractPeach = {
        skinID = "rbxassetid://13655041050",
        rarity = raritiesEnum.Legendary,
        name = "Abstract Peach",
    },
    RoyalOrnate = {
        skinID = "rbxassetid://13620123374",
        rarity = raritiesEnum.Epic,
        name = "Royal Ornate",
    },
    Pineapple = {
        skinID = "rbxassetid://13655576502",
        rarity = raritiesEnum.Common,
        name = "Pineapple",
    },
    Duckies = {
        skinID = "rbxassetid://358413518",
        rarity = raritiesEnum.Common,
        name = "Duckies",
    },
    Totopos = {
        skinID = "rbxassetid://358284720",
        rarity = raritiesEnum.Rare,
        name = "Totopos",
    },
    DigitalDisturbance = {
        skinID = "rbxassetid://358113994",
        rarity = raritiesEnum.Epic,
        name = "Digital Disturbance",
    },
    Connections = {
        skinID = "rbxassetid://358209640",
        rarity = raritiesEnum.Epic,
        name = "Connections",
    },
    PartyTime = {
        skinID = "rbxassetid://358113881",
        rarity = raritiesEnum.Rare,
        name = "Party Time",
    },
    Cherries = {
        skinID = "rbxassetid://13662981938",
        rarity = raritiesEnum.Common,
        name = "Cherries",
    },
    Steampunk = {
        skinID = "rbxassetid://13663622687",
        rarity = raritiesEnum.Rare,
        name = "Steampunk",
    },
    Darkness = {
        skinID = "rbxassetid://13664411385",
        rarity = raritiesEnum.Common,
        name = "Darkness",
    },
    VoidScars = {
        skinID = "rbxassetid://13664464931",
        rarity = raritiesEnum.Legendary,
        name = "Void Scars",
    },
    Constellation = {
        skinID = "rbxassetid://13664532889",
        rarity = raritiesEnum.Rare,
        name = "Constellation",
    },
    Bowies = {
        skinID = "rbxassetid://13664668442",
        rarity = raritiesEnum.Common,
        name = "Bowies",
    },
    IndustrialSpace = {
        skinID = "rbxassetid://13664822366",
        rarity = raritiesEnum.Rare,
        name = "Industrial Space",
    },
    CoffinsSkulls = {
        skinID = "rbxassetid://13665000362",
        rarity = raritiesEnum.Epic,
        name = "Coffins & Skulls",
    },
    RainbowBats = {
        skinID = "rbxassetid://13664947705",
        rarity = raritiesEnum.Rare,
        name = "Rainbow Bats",
    },
    SugarHaze = {
        skinID = "rbxassetid://13665979274",
        rarity = raritiesEnum.Epic,
        name = "Sugar-Haze",
    },
    ForestCamo = {
        skinID = "rbxassetid://13666123351",
        rarity = raritiesEnum.Common,
        name = "Forest Camo",
    },
    SnowCamo = {
        skinID = "rbxassetid://13667523981",
        rarity = raritiesEnum.Common,
        name = "Snow Camo",
    },
    DesertCamo = {
        skinID = "rbxassetid://13667570547",
        rarity = raritiesEnum.Common,
        name = "Desert Camo",
    },
    SharkCamo = {
        skinID = "rbxassetid://13667632021",
        rarity = raritiesEnum.Epic,
        name = "Shark Camo",
    },
    PunkSpirit = {
        skinID = "rbxassetid://13667613116",
        rarity = raritiesEnum.Legendary,
        name = "Punk Spirit",
    },
    GhostCamo = {
        skinID = "rbxassetid://13667665573",
        rarity = raritiesEnum.Legendary,
        name = "Ghost Camo",
    },
    Kraken = {
        skinID = "rbxassetid://390097022",
        rarity = raritiesEnum.Mythic,
        name = "Kraken",
    },
    MonkeyRage = {
        skinID = "rbxassetid://13667787552",
        rarity = raritiesEnum.Legendary,
        name = "Monkey Rage",
    },
    Dragonfruits = {
        skinID = "rbxassetid://13667938944",
        rarity = raritiesEnum.Rare,
        name = "Dragonfruits",
    },
	Melancoly = {
		skinID = "rbxassetid://13829565984",
		rarity = raritiesEnum.Legendary,
		name = "Melancoly",
	},
    MayanFigures = {
        skinID = "rbxassetid://13867946001",
        rarity = raritiesEnum.Mythic,
        name = "Mayan Figures",
    },
    SpiderSense = {
        skinID = "rbxassetid://13874149361",
        rarity = raritiesEnum.Epic,
        name = "Spider Sense",
    },
    SpiderSpirit = {
        skinID = "rbxassetid://13874336571",
        rarity = raritiesEnum.Legendary,
        name = "Spider Spirit",
    },
    SkullRoses = {
        skinID = "rbxassetid://15021618982",
        rarity = raritiesEnum.Epic,
        name = "Skull & Roses"
    },
    Tech = {
        skinID = "rbxassetid://15021666612",
        rarity = raritiesEnum.Rare,
        name = "Tech"
    }
    
}


return skins
