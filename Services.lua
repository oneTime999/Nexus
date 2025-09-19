-- Services.lua - Centralização dos serviços do Roblox

local Services = {}

Services.Players = game:GetService("Players")
Services.ReplicatedStorage = game:GetService("ReplicatedStorage")
Services.Workspace = game:GetService("Workspace")
Services.UserInputService = game:GetService("UserInputService")
Services.TweenService = game:GetService("TweenService")

Services.LocalPlayer = Services.Players.LocalPlayer

return Services
