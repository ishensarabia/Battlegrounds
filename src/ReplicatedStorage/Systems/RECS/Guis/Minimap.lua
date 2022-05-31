local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local ToggleMapEvent = ReplicatedStorage.Events.ToggleMapEvent
--local EnableToggleMapButtonEvent = ReplicatedStorage.Events.EnableToggleMapButtonEvent

local Conf = require(ReplicatedFirst.Configurations.MainConfiguration)
local Util = require(ReplicatedStorage.Packages.Util)
local RECS = require(ReplicatedStorage.Packages.RECS)

local _playerIndicator = nil
local _map = nil
local _mapFrame = nil

local _setupFinished = false

local _mapTags = {}
local _mapIndicators = {}

local _minimapZoom = Conf.minimap_zoom or 3
local _worldmapZoom = Conf.worldmap_zoom or 1

local _unitUp = Vector3.FromAxis(Enum.Axis.Y)
local _unitForward = Vector3.FromAxis(Enum.Axis.Z)
local _unitRight = Vector3.FromAxis(Enum.Axis.X)

local MinimapGui = RECS.System:extend("MinimapGui")

local _mapView = {
	focus_x = 0,
	focus_y = 0,
	scale = _minimapZoom
}

local _mapSize = Conf.map_size or 512 -- map is 12k x 12k studs
local _minimapWidth = Conf.minimap_width or 0.3
local _minimapHeight = Conf.minimap_height or 0.3
local _worldmapWidth = Conf.worldmap_width or 0.9
local _worldmapHeight = Conf.worldmap_height or 0.9
local _isCurrentlyMinimap = true

local function _updateMapFocus()
	if _isCurrentlyMinimap then

		local character = Util.getClientFocus()

		if not character or not character.PrimaryPart then
			Util.setClientFocus(game.Players.LocalPlayer.Character)
			return
		end

		local root = character.PrimaryPart
		local pos = root.Position

		-- Update focus point
		_mapView.focus_x = pos.X + _mapSize / 2 -- the center of our map is at 0,0, so need to offset player position to be in [0, mapsize] range
		_mapView.focus_y = pos.Z + _mapSize / 2 -- the center of our map is at 0,0, so need to offset player position to be in [0, mapsize] range
	else
		-- Set focus point to middle of map for worldmap view
		_mapView.focus_x = _mapSize / 2
		_mapView.focus_y = _mapSize / 2
	end

	-- Panning/scaling of viewport/map
	-- Note:  We use Offsets here to maintain the correct aspect ratio for the map inside the map frame (which may be arbitrarily sized)
	-- TODO:  Currently this assumes a square map
	_map.Size = UDim2.new(0, _mapFrame.AbsoluteSize.X * _mapView.scale,
						  0, _mapFrame.AbsoluteSize.X * _mapView.scale)

	-- Get the viewport position of the map focus point and adjust the map position accordingly.
	local relativeFocus = Vector2.new(_mapView.focus_x / _mapSize,
									  _mapView.focus_y / _mapSize)

	_map.Position = UDim2.new(0, _mapFrame.AbsoluteSize.X * 0.5 - _map.Size.X.Offset * relativeFocus.X,
							  0, _mapFrame.AbsoluteSize.Y * 0.5 - _map.Size.Y.Offset * relativeFocus.Y)
end

function MinimapGui.worldToMap(pos)
	local mapSize = _map.Size
	local mapPos = _map.Position
	local x = (pos.X + _mapSize / 2) / _mapSize * mapSize.X.Offset + mapPos.X.Offset
	local y = (pos.Z + _mapSize / 2) / _mapSize * mapSize.Y.Offset + mapPos.Y.Offset
	return UDim2.new(0, x, 0, y)
end

function MinimapGui._getOrCreateIndicator(icon, tag, index)
	local indicator = _mapIndicators[tag][index]
	
	if not indicator then
		indicator = icon:Clone()
		
		indicator.Parent = _mapFrame
		_mapIndicators[tag][index] = indicator
	end
	
	indicator.Visible = true
	
	return indicator	
end

function MinimapGui:step(dt)
	_updateMapFocus()
	
	local markerFolder = ReplicatedStorage:FindFirstChild("MapMarkers")
	
	for tag, icon in pairs(_mapTags) do
		local count = 0
		
		-- Explicit map locations
		if markerFolder then
			local markers = markerFolder:FindFirstChild(tag)
			if markers then
				for _, markerObj in ipairs(markers:GetChildren()) do
					count = count + 1
					local indicator = MinimapGui._getOrCreateIndicator(icon, tag, count)
					indicator.Position = MinimapGui.worldToMap(markerObj.Value)
				end
			end
		end
		
		for _, model in ipairs(CollectionService:GetTagged(tag)) do
			if model.PrimaryPart then
				count = count + 1
				
				-- TODO:  May need an actual unique identifier
				local indicator = MinimapGui._getOrCreateIndicator(icon, tag, count)

				local root = model.PrimaryPart
				local pos = root.Position
				local partCFrame = root.CFrame

				-- NOTE: We determine whether the forward vector for this part should be its look or up vectors by checking LookVector against up
				-- .That vector is then flattened along the x/y plane and normalized
				-- .The angle is calculated, converted into degrees, and used to rotate the indicator

				local forward = Vector3.new(partCFrame.LookVector.X, 0, partCFrame.LookVector.Z).Unit
				local lookDot = partCFrame.LookVector:Dot(_unitUp)
				
				-- NOTE: not sure what this was for in RBR1, but it makes rotation screw up when you are in a vehicle going on slopes
--				if math.abs(lookDot) > 0.5 then
--					forward = Vector3.new(partCFrame.UpVector.X, 0, partCFrame.UpVector.Z).Unit
--				end

				local rotation = math.acos(forward:Dot(_unitForward)) * 57.2958

				if forward:Dot(_unitRight) < 0 then
					rotation = 360 - rotation
				end

				indicator.Position = MinimapGui.worldToMap(pos)

				-- HACK:  This extra inversion and 180 degree rotation could probably be factored out, but it was taking more time than appropriate to fix.
				indicator.Rotation = 360 - (rotation + 180) % 360
			end
		end

		-- Destroy any unused indicators based on count
		local existingIndicatorCount = #_mapIndicators[tag]

		if count < existingIndicatorCount then
			for i = count, existingIndicatorCount do
				local indicator = _mapIndicators[tag][i]

				if indicator then
					indicator:Destroy()
				end

				_mapIndicators[tag][i] = nil
			end
		end
	end
end

local function toggleMap()
	if _isCurrentlyMinimap then -- change to worldmap
		_mapFrame.Size = UDim2.new(_worldmapWidth, 0, _worldmapHeight, 0)
		_mapFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		_mapFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		_mapView.scale = _worldmapZoom
		_isCurrentlyMinimap = false
	else -- change to minimap
		_mapFrame.Size = UDim2.new(_minimapWidth, 0, _minimapHeight, 0)
		_mapFrame.AnchorPoint = Vector2.new(1, 0)
		_mapFrame.Position = UDim2.new(1, 0, 0, 0)
		_mapView.scale = _minimapZoom
		_isCurrentlyMinimap = true
	end

	return _isCurrentlyMinimap
end

local function onInputBegan(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.M or input.KeyCode == Enum.KeyCode.DPadUp then
		toggleMap()
	end
end

local function onCharacterAdded(character)
	if not _setupFinished then
		local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

		local container = ReplicatedStorage.Assets.GuiObjects.minimap:Clone()
		container.ResetOnSpawn = false

		_mapFrame = container:WaitForChild("mapframe")
		_mapFrame.Size = UDim2.new(_minimapWidth, 0, _minimapHeight, 0)

		_map = _mapFrame:WaitForChild("map")
		_playerIndicator = _mapFrame:WaitForChild("PlayerLocation")

		-- Hide minimap since match hasn't started yet
		_playerIndicator.Visible = false
		_mapFrame.Visible = false

		container.Enabled = true
		container.Parent = PlayerGui

		_setupFinished = true
	elseif not _isCurrentlyMinimap then
		-- Make sure map is mini when player respawns
		toggleMap()
	end
end

function MinimapGui:init()
	if Players.LocalPlayer.Character then
		onCharacterAdded(Players.LocalPlayer.Character)
	end
	Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
	
	while not _setupFinished do
		task.wait()
	end

	MinimapGui.addMapTag(Util._clientFocusTag, "LocalPlayerLocation")
	MinimapGui.addMapTag("Player")
	MinimapGui.addMapTag("POI", "POI")	
	
	ToggleMapEvent.OnInvoke = toggleMap

	UserInputService.InputBegan:Connect(onInputBegan)

	_isCurrentlyMinimap = false
	toggleMap() -- ensures minimap size + position + anchor will be the same regardless of values set in studio

	_mapFrame.Visible = true
	
	-- NOTE: this can eventually be used for mobile UI to toggle minimap/worldmap
--	EnableToggleMapButtonEvent:Fire(true, _isCurrentlyMinimap)
end

function MinimapGui.addMapTag(tag, icon)
	local tagIndicatorTemplate

	if not icon then
		tagIndicatorTemplate = _playerIndicator

	elseif type(icon) == "string" then
		tagIndicatorTemplate = _mapFrame:FindFirstChild(icon) or _playerIndicator

	else
		tagIndicatorTemplate = icon
	end

	_mapTags[tag] = tagIndicatorTemplate

	if not _mapIndicators[tag] then
		_mapIndicators[tag] = {}
	else
		-- TODO:  Handle possibly switching to a different icon
	end
end

function MinimapGui.removeMapTag(tag)
	local indicators = _mapIndicators[tag]

	if indicators then
		for _, icon in ipairs(indicators) do
		end
	end
end

function MinimapGui.isCurrentlyMinimap()
	return _isCurrentlyMinimap
end

function MinimapGui.isEnabled()
	return _mapFrame and _mapFrame.Visible
end

-------------
return MinimapGui
