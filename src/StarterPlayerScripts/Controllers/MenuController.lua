local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
--Widgets

--Module dependencies
local Knit = require(ReplicatedStorage.Packages.Knit)
--Controllers
local WidgetController
--Services
local LevelService

local MenuController = Knit.CreateController { Name = "MenuController" }
local Cutscenes = {
    MainMenu = function()
        
    end
}


function MenuController:KnitStart()
    WidgetController = Knit.GetController("WidgetController")

    warn(LevelService)
    --Connect level up signal
    LevelService.LevelUpSignal:Connect(function(newLevel)
        WidgetController.HUDWidget:LevelUp(newLevel)
    end)
end

function MenuController:startCutscene(cutscene : string)
    local cutsceneHandler = cutscene
    if cutsceneHandler then
        cutsceneHandler()
    end
end

function MenuController:Play()
    self._cameraController.isInMenu = false
    self.isInMenu = false
    self._cameraController:CancelActiveTween()
    self._cameraController:SetCameraType("Custom")
    self._cameraController:ChangeMode("Play")
    Knit.GetService("PlayerService"):SpawnCharacter()
    --Show HUD on spawn
    Players.LocalPlayer.CharacterAdded:Connect(function(character)
        WidgetController.HUDWidget:ShowHUD()
        --Hide HUD on death
        character:WaitForChild("Humanoid").Died:Connect(function()
            WidgetController.HUDWidget:HideHUD()
        end)
    end)
end

function MenuController:ShowMenu()
    if self.isInMenu then
        return
    end
    WidgetController.MainMenuWidget:ShowMenu()
    self.isInMenu = true
    self._cameraController:ChangeMode("Menu")
    -- WidgetController.MainMenuWidget:InitializeCameraTransition()
    
end

function MenuController:ShowPlayButton()
    if self.isInMenu then
        WidgetController.MainMenuWidget:ShowPlayButton()
    end
end

function MenuController:HidePlayButton()
    WidgetController.MainMenuWidget:HidePlayButton()
end

function MenuController:KnitInit()
    LevelService = Knit.GetService("LevelService")
    self._cameraController = Knit.GetController("CameraController")
    self.isInMenu = true

end


return MenuController
