local storeConfig = {
    --Constants
	RESET_TIME_OFFSET = -60 * 60 * 4, -- Amount of time to offset from GMT
	REFRESH_RATE = 5, -- How often (seconds) to check for shop changes
	FEATURED_ITEMS_UPDATE_RATE = 60 * 60 * 0.01, -- How often (seconds) to update the store rotation
	DAILY_ITEMS_UPDATE_RATE = 60 * 60 * 0.01, -- How often (seconds) to update the store rotation
    DAILY_ITEMS_NUM = 6, -- Number of daily items to show

    Categories = {
        DailyItems = "DailyItems",
        Crates = "Crates",
        BattleGems = "BattleGems",
        BattleCoins = "BattleCoins",
        Prestige = "Prestige",
    },

    Subcategoires = {
        Prestige = {
            Skins = "Skins",
            Emotes = "Emotes"
        }
    },

    ItemTypes = {
        Skin = "Skin",
        Emote = "Emote",
        EmoteIcon = "EmoteIcon",
    },

    DailyItemTypesLimit = {
        Skin = 1,
        Emote = 2,
        EmoteIcon = 5,
    },
}

return storeConfig