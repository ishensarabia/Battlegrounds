local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Constants = require(script.Parent.Parent.Constants)

local isServer = RunService:IsServer()

--------------------------------------
-- List of named places in the game
local _places = {}
local conf = {}
local _helpers = {}

local defaults = {
	default_profile = "Default",
	default_studio_profile = "Default",
	default_private_profile = "NoNPCs-Vehicles-50",

	map_size = 5000,

	admin_group_ids = {
		3958078, -- Reference Team
		4448406, -- Trapped in amber I
		--1200769, -- Roblox Admins
	},
	external_qa_group_ids = {
		4448406,
	},
	reference_games_user_ids = {
		377987375,
		7210880,
		782148096,
		628764692,
		613016484,
		671465276,
		169775909,
		402758067,
		366370235,
		688488720,
		550574694,
		315259569,
		1114780684,
		1144106728,
		1043064299,
		462128752,
		606075979,
		101107579,
		101134337,
		439546926,
		1298953044,
		959520514,
		1165799124,
		2245483,
	},
	npc_name_prefix = "rbxreftest",
	romark_player_name_prefix = "player",
	players_as_bots = {
	},
	outfits = {
		--[[
			Configure characters based on their type. Options:
			- Stored: Pick from outfits stored in ServerStorage.Assets.Outfits
			- Friends: Select a random friend and use their outfit. Source user is configured with user_id_friends's.
			- StaticFriends: Select a random friend and use their outfit. Friend's list is pre-generated and static.
			- Default: No override, use default avatar.
		]]
		characters = {
			npcs = "Stored",
			player_bots = "StaticFriends",
			players = "Default",
		},
		user_id_friends = 5116262,
		-- Override characters with these names. Specify an outfit ID or use -1 to ignore any outfit overrides.
		overrides = {
			Soldier = -1,
		},		
	},
	avatar_outfits = {
		680889488,
		441740226,
		723925014,
		810215407,
		864499159,
		862260912,
		895148395,
		943972626,
		965363933,
		1426384108,
		1026787390,
		1425874416,
		1061810393,
		1153193232,
		1295571555,
		1405375928,
		1405384123,
		525534957,
		525543725,
		661078277,
		680269921,
		320929398,
		597550835,
		597519851,
		597493475,
		597497519,
		342230531,
		342203958,
		373238586,
		404256664,
		426842155,
		441742685,
		441744096,
		441745631,
		441746285,
		615934704,
		489946079,
		489635259,
		703808863,
		742161851,
		765909730,
		786514132,
		786498560,
		786430795,
		895140665,
		919939396,
		919943562,
		965242919,
	},

	avatar_animations = {
	},

	enable_bt_debugging = true,
	enable_debugging_ui = false,

	day_night_cycle = {
		enabled = false,
		day_start_hour = 7,
		day_end_hour = 19,
		day_length_seconds = 600,
		night_length_seconds = 300,
	},

	regions = {
		city = {
			include = {
				"NPCSpawnCity",
				--				"NPCSoldierSpawn",
			},
		},

		city_vehicles = {
			roadway = {
				tag = "Road",
				count = 200,
				forward = true,
			},
		},

		country = {
			include = {
				"NPCSpawnRural",
			}
		},

		city_parks = {
			include = {
				"NPCSpawnPark",
			},
		},
	},

	romark_shutdown_logging = false,

	dataflow = {
		debug_mode = false,
		default_handlers = {
			--[[
				Core
			]]

			addPlayer = {
				handler = "CoreLibrary.addPlayer",
				server = Constants.PROCESS_AND_BROADCAST,
				client = Constants.PROCESS,
			},

			removePlayer = {
				handler = "CoreLibrary.removePlayer",
				server = Constants.PROCESS_AND_BROADCAST,
				client = Constants.PROCESS,
			},

			--[[
				General
			]]

			playSound = {
				handler = "GeneralLibrary.playSound",
				server = Constants.BROADCAST,
				client = Constants.PROCESS_AND_BROADCAST,
			},

			stopSound = {
				handler = "GeneralLibrary.stopSound",
				server = Constants.BROADCAST,
				client = Constants.PROCESS_AND_BROADCAST,
			},

			enableBeam = {
				handler = "GeneralLibrary.enableBeam",
				server = Constants.NONE,
				client = Constants.PROCESS,
			},

			disableBeam = {
				handler = "GeneralLibrary.disableBeam",
				server = Constants.NONE,
				client = Constants.PROCESS,
			},

			playAnimation = {
				handler = "GeneralLibrary.playAnimation",
				server = Constants.NONE,
				client = Constants.PROCESS,
			},

			stopAnimation = {
				handler = "GeneralLibrary.stopAnimation",
				server = Constants.NONE,
				client = Constants.PROCESS,
			},

			emitParticle = {
				handler = "GeneralLibrary.emitParticle",
				server = Constants.PROCESS,
				client = Constants.PROCESS,
			},

			--[[
				Weapons
			]]

			equipped = {
				handler = "WeaponsLibrary.equipped",
				server = Constants.PROCESS_AND_BROADCAST,
				client = Constants.PROCESS,
			},

			unequipped = {
				handler = "WeaponsLibrary.unequipped",
				server = Constants.PROCESS_AND_BROADCAST,
				client = Constants.PROCESS,
			},

			activate = {
				handler = "WeaponsLibrary.activate",
				server = Constants.NONE,
				client = Constants.PROCESS,
			},

			fire = {
				handler = "WeaponsLibrary.fire",
				server = Constants.NONE,
				client = Constants.PROCESS,
			},

			shot = {
				handler = "WeaponsLibrary.shot",
				server = Constants.NONE,
				client = Constants.PROCESS,
			},

			hitEffects = {
				handler = "WeaponsLibrary.hitEffects",
				server = Constants.NONE,
				client = Constants.PROCESS,
			},

			hit = {
				handler = "WeaponsLibrary.hit",
				server = Constants.PROCESS,
				client = Constants.BROADCAST,
			},

			reload = {
				handler = "WeaponsLibrary.reload",
				server = Constants.NONE,
				client = Constants.PROCESS,
			},

			bulletHole = {
				handler = "WeaponsLibrary.bulletHole",
				server = Constants.BROADCAST,
				client = Constants.PROCESS_AND_BROADCAST,
			},

			tracer = {
				handler = "WeaponsLibrary.tracer",
				server = Constants.BROADCAST,
				client = Constants.PROCESS_AND_BROADCAST,
			},

			sense = {
				handler = "WeaponsLibrary.sense",
				server = Constants.PROCESS,
				client = Constants.BROADCAST,
			},
		},
	},

	weapon_system = {
		debug_hitmarkers = false,
		weapon_tag = "NewWeapon",
		ignore_list_tag = "WeaponSystemRayIgnore",
		max_penetration_casts = 50,
		bullet_holes_fade = true,
		weapons = {
			NewPistol = {
				handlers = {},
				default_state = {
					ammo = 10,
					reloadStartTime = 0,
					lastFiredTime = 0,
				},
				config = {
					damage = 20,
					clip_capacity = 10,
					range = 500,
					reloadTimeLength = 2,
					firingDebounce = 0.15,
				}
			},
		},
	},

	keybindings = {
		Fire = { Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch, Enum.KeyCode.ButtonR1 },
		Reload = { Enum.KeyCode.R, Enum.KeyCode.ButtonX },
	},
}

--[[
	Config overrides
]]

local _profiles = {}

function _helpers.waitForOverride() -- waits for server to override conf with gamemode values
	while not conf.override do
		wait()
	end
end

--------------------------------------
function _tableHasValue(tbl, val)
	for k, v in pairs(tbl) do
		if v == val then
			return true
		end
	end
end

local function _clearTable(tbl)
	for k,v in pairs(tbl) do
		tbl[k] = nil
	end
end

-- cloneTable duplicated here to break the dependency on Util module
local function _cloneTable(tbl, dst)
	local new = dst or {}

	for k,v in pairs(tbl) do
		local t = type(v)

		if t == "table" then
			new[k] = _cloneTable(v)
		else
			new[k] = v
		end
	end

	return new
end

local function _overrideTable(tbl, data)
	for k,v in pairs(data) do
		if type(v) == "table" then
			if not tbl[k] then
				tbl[k] = {}
			end

			_overrideTable(tbl[k], v)

		else
			tbl[k] = v
		end
	end
end

function _helpers.createProfile(name, data)
	if _profiles[name] then
		print(string.format("Configuration profile %s already exists", name))
		return
	end

	_profiles[name] = data
end

local function _loadProfiles()
	for i, child in ipairs(script:GetChildren()) do
		local profile = require(child)
		_profiles[child.Name] = profile  

		-- Preprocess population data
		if profile.populations then
			local processedPopulations = {}

			for name, population in pairs(profile.populations) do
				processedPopulations[string.format("%s|%s", child.Name, name)] = population
			end

			profile.populations = processedPopulations
		end
	end
end

local function _applyConfiguration(data)
	_clearTable(conf)
	_cloneTable(data, conf)
	_cloneTable(_helpers, conf)

	if isServer then
		_helpers.configEvent:FireAllClients("PropagateConfig", conf)
	end

	_helpers.configChanged:Fire(conf)

	return conf
end

function _helpers.setProfile(name)
	-- Get override data and apply it
	local data = _profiles[name]

	if not data then
		error(string.format("Profile %s does not exist.", name))
		return false
	end

	print(string.format("Setting configuration profile %s", name))

	local newConfiguration = {}
	_cloneTable(defaults, newConfiguration)
	_overrideTable(newConfiguration, data)
	newConfiguration.current_profile = name

	_applyConfiguration(newConfiguration)

	return conf
end

function _helpers.getProfiles()
	return _profiles
end

if not isServer then
	_helpers.configEvent = ReplicatedStorage.Events:WaitForChild("ConfigEvent")
	_helpers.configEvent.OnClientEvent:Connect(function(cmd, newConf)
		if cmd == "PropagateConfig" then
			_applyConfiguration(newConf)
		end
	end)
else
	_helpers.configEvent = ReplicatedStorage:FindFirstChild("ConfigEvent")
	if _helpers.configEvent == nil then
		_helpers.configEvent = Instance.new("RemoteEvent", ReplicatedStorage)
		_helpers.configEvent.Name = "ConfigEvent"
	end

	Players.PlayerAdded:Connect(function(player)
		_helpers.configEvent:FireClient(player, "PropagateConfig", conf)
	end)
end

-- Set configuration defaults before anything tries to access it
_cloneTable(defaults, conf)
_cloneTable(_helpers, conf)

---- 
_helpers.configChanged = workspace:FindFirstChild("ConfigurationChanged")

if not _helpers.configChanged then
	_helpers.configChanged = Instance.new("BindableEvent")
	_helpers.configChanged.Name = "ConfigurationChanged"
	_helpers.configChanged.Parent = workspace
end

-- Set initial profile
_loadProfiles()

if isServer then
	local profile = defaults.default_profile

	if game.PrivateServerId ~= "" and _tableHasValue(defaults.reference_games_user_ids, game.PrivateServerOwnerId) then
		-- this is the roblox employee private server, no NPCs!
		print("Private Server: PrivateServerId:", game.PrivateServerId, "OwnerId:", game.PrivateServerOwnerId)
		profile = defaults.default_private_profile
	elseif RunService:IsStudio() then
		profile = defaults.default_studio_profile
	end

	_helpers.setProfile(profile)
end

print(string.format("Configuring place %s", game.PlaceId))

---------
_G.Conf = conf
return conf