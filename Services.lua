-- Services.lua - Módulo para gerenciar serviços do Roblox
-- Centraliza todos os serviços em um local

local Services = {}

-- Serviços do Roblox
Services.Players = game:GetService("Players")
Services.ReplicatedStorage = game:GetService("ReplicatedStorage")
Services.Workspace = game:GetService("Workspace")
Services.UserInputService = game:GetService("UserInputService")
Services.TweenService = game:GetService("TweenService")

-- Player local e GUI
Services.LocalPlayer = Services.Players.LocalPlayer
Services.playerGui = Services.LocalPlayer:WaitForChild("PlayerGui")

return Services
