-- ========================================== --
--  Script desenvolvido por: kauetheprotogen  --
--  Créditos: kauetheprotogen - GitHub/Roblox --
-- ========================================== --

-- SCRIPT DE RESTAURAÇÃO TOTAL
local L = game:GetService('Lighting')
L:ClearAllChildren()

-- Aplicando Propriedades Globais
local o = L
o.Ambient = Color3.new(0.29411765933036804, 0.18431372940540314, 0.11372549086809158)
o.Brightness = 1.2000000476837158
o.ColorShift_Bottom = Color3.new(0, 0, 0)
o.ColorShift_Top = Color3.new(1, 0.6509804129600525, 0)
o.OutdoorAmbient = Color3.new(0.27450981736183167, 0.27450981736183167, 0.27450981736183167)
o.ShadowSoftness = 0.4000000059604645
o.GeographicLatitude = 0
o.ExposureCompensation = 0
o.FogColor = Color3.new(0.7529412508010864, 0.7529412508010864, 0.7529412508010864)
o.FogEnd = 1000
o.FogStart = 0
o.EnvironmentDiffuseScale = 0.10000000149011612
o.EnvironmentSpecularScale = 0.5
o.GlobalShadows = true

-- Restaurando: Bloom
local o = Instance.new('BloomEffect', L)
o.Name = 'Bloom'
o.Size = 56
o.Threshold = 0.800000011920929
o.Intensity = 1

-- Restaurando: Blur
local o = Instance.new('BlurEffect', L)
o.Name = 'Blur'
o.Size = 2

-- Restaurando: ColorCorrection
local o = Instance.new('ColorCorrectionEffect', L)
o.Name = 'ColorCorrection'
o.Brightness = 0
o.Contrast = 0
o.Saturation = 0.5

-- Restaurando: DepthOfField
local o = Instance.new('DepthOfFieldEffect', L)
o.Name = 'DepthOfField'

-- Restaurando: SunRays
local o = Instance.new('SunRaysEffect', L)
o.Name = 'SunRays'
o.Intensity = 0.10300000011920929

-- Restaurando: Sky
local o = Instance.new('Sky', L)
o.Name = 'Sky'
o.SkyboxBk = [[rbxassetid://600830446]]
o.SkyboxDn = [[rbxassetid://600831635]]
o.SkyboxFt = [[rbxassetid://600832720]]
o.SkyboxLf = [[rbxassetid://600886090]]
o.SkyboxRt = [[rbxassetid://600833862]]
o.SkyboxUp = [[rbxassetid://600835177]]
o.SunAngularSize = 11
o.MoonAngularSize = 11
o.SunTextureId = [[rbxasset://sky/sun.jpg]]
o.MoonTextureId = [[rbxassetid://102013024637283]]
o.StarCount = 3000

-- Restaurando: Atmosphere
local o = Instance.new('Atmosphere', L)
o.Name = 'Atmosphere'
o.Color = Color3.new(0.29411765933036804, 0.18431372940540314, 0.11372549086809158)
o.Density = 0.4189999997615814
o.Offset = 0
o.Glare = 1
o.Haze = 0

