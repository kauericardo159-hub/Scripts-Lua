-- ========================================== --
--  Script desenvolvido por: kauetheprotogen  --
--  Créditos: kauetheprotogen - GitHub/Roblox --
-- ========================================== --

-- SCRIPT DE RESTAURAÇÃO TOTAL
local L = game:GetService('Lighting')
L:ClearAllChildren()
 
-- Aplicando Propriedades Globais
local o = L
o.Ambient = Color3.new(0.29411765933036804, 0.18431372940540314, 0.0784313753247261)
o.Brightness = 3.134999990463257
o.ColorShift_Bottom = Color3.new(0, 0, 0)
o.ColorShift_Top = Color3.new(1, 0.6509804129600525, 0)
o.OutdoorAmbient = Color3.new(0.5882353186607361, 0.5882353186607361, 0.5882353186607361)
o.ShadowSoftness = 0.20000000298023224
o.GeographicLatitude = -16.732999801635742
o.ExposureCompensation = 0
o.FogColor = Color3.new(0.7529411911964417, 0.7529411911964417, 0.7529411911964417)
o.FogEnd = 100000
o.FogStart = 0
o.EnvironmentDiffuseScale = 1
o.EnvironmentSpecularScale = 1
o.GlobalShadows = true
 
-- Restaurando: Shader-Field
local o = Instance.new('DepthOfFieldEffect', L)
o.Name = 'Shader-Field'
 
-- Restaurando: Shader-SunRays
local o = Instance.new('SunRaysEffect', L)
o.Name = 'Shader-SunRays'
o.Intensity = 0.10300000011920929
 
-- Restaurando: Shader-Atmosphere
local o = Instance.new('Atmosphere', L)
o.Name = 'Shader-Atmosphere'
o.Color = Color3.new(0.29411765933036804, 0.18431372940540314, 0.11372549086809158)
o.Density = 0.4189999997615814
o.Offset = 0
o.Glare = 0
o.Haze = 0
 
-- Restaurando: Shader-Correction
local o = Instance.new('ColorCorrectionEffect', L)
o.Name = 'Shader-Correction'
o.Brightness = -0.10000000149011612
o.Contrast = 0.30000001192092896
o.Saturation = 0
 
-- Restaurando: Day
local o = Instance.new('Sky', L)
o.Name = 'Sky'
o.SkyboxBk = [[rbxassetid://591058823]]
o.SkyboxDn = [[rbxassetid://591059876]]
o.SkyboxFt = [[rbxassetid://591058104]]
o.SkyboxLf = [[rbxassetid://591057861]]
o.SkyboxRt = [[rbxassetid://591057625]]
o.SkyboxUp = [[rbxassetid://591059642]]
o.SunAngularSize = 10
o.MoonAngularSize = 0
o.SunTextureId = [[rbxasset://sky/sun.jpg]]
o.MoonTextureId = [[rbxasset://sky/moon.jpg]]
o.StarCount = 3000
 
