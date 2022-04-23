local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddControllers(game.StarterPlayer.StarterPlayerScripts.Source.Controllers)

Knit.Start():catch(warn)