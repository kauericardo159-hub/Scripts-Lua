-- ========================================== --
--  Script desenvolvido por: kauetheprotogen  --
--  Créditos: kauetheprotogen - GitHub/Roblox --
-- ========================================== --

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
 
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
 
local tails = {}
local counter = 0
local lastRootRotation = CFrame.new()
 
-- Configurações de Física Dinâmica
local SETTINGS = {
LERP_SPEED = 0.1, -- Suavidade geral da mola (quanto menor, mais pesada e fluida)
MAX_TILT = 0.6, -- Limite de inclinação para evitar deformações feias
 
-- Balanço base (Parado)
IDLE_SWAY_SPEED = 3.5,
IDLE_SWAY_AMP = 0.1,
 
-- Movimento no Chão (Andar / Correr)
MOVE_SWAY_SPEED = 7.0,
MOVE_SWAY_AMP = 0.22,
DRAG_PITCH = 0.008, -- O quanto a cauda estica para trás ao correr
 
-- Curvas / Rotação
TURN_INERTIA = 1.8, -- Força centrífuga ao virar o personagem
 
-- Física Vertical (Ajustada)
JUMP_PITCH = 0.45, -- Pular: Cauda aponta para BAIXO (resistência)
FALL_PITCH = -0.55, -- Cair: Vento empurra a cauda para CIMA
CLIMB_SWAY_SPEED = 5.0,
CLIMB_SWAY_AMP = 0.15,
 
-- Natação
SWIM_SWAY_SPEED = 5.5,
SWIM_SWAY_AMP = 0.45,
}
 
-- Mapeia e reseta o peso das partes da cauda
local function scanTails()
    tails = {}
    if not character then return end
    
    for _, item in ipairs(character:GetDescendants()) do
        if string.find(string.lower(item.Name), "tail") then
            local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
            if part then
                part.CanCollide = false
                part.Massless = true
                part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                
                local weld = part:FindFirstChild("AccessoryWeld") or part:FindFirstChildWhichIsA("Weld")
                if weld then
                    table.insert(tails, { weld = weld, originalC1 = weld.C1 })
                end
            end
        end
    end
end
 
RunService.RenderStepped:Connect(function(dt)
    local root = character:FindFirstChild("HumanoidRootPart")
    if #tails == 0 or not root or not humanoid or humanoid.Health <= 0 then return end
    
    -- 1. Captura de Dados Espaciais
    local velocity = root.AssemblyLinearVelocity
    local localVel = root.CFrame:VectorToObjectSpace(velocity)
    local state = humanoid:GetState()
    
    -- Detecção de rotação (Curvas)
    local rootRotation = root.CFrame
    local rotationDiff = rootRotation:VectorToObjectSpace(lastRootRotation.LookVector).X
    lastRootRotation = rootRotation
    
    -- 2. Máquina de Estados (Determina a dinâmica por ação)
    local targetPitch = 0 -- Reclinamento vertical (X)
    local targetYaw = 0 -- Balanço lateral (Y)
    local targetRoll = 0 -- Torção da curva (Z)
    
    local swaySpeed = SETTINGS.IDLE_SWAY_SPEED
    local swayAmp = SETTINGS.IDLE_SWAY_AMP
    
    local horizontalSpeed = Vector3.new(localVel.X, 0, localVel.Z).Magnitude
    
    -- ESTADO: Nadando
    if state == Enum.HumanoidStateType.Swimming then
        swaySpeed = SETTINGS.SWIM_SWAY_SPEED
        swayAmp = SETTINGS.SWIM_SWAY_AMP
        targetPitch = math.clamp(-localVel.Y * 0.02, -0.3, 0.3)
        
        -- ESTADO: Escalando
    elseif state == Enum.HumanoidStateType.Climbing then
        swaySpeed = SETTINGS.CLIMB_SWAY_SPEED
        swayAmp = SETTINGS.CLIMB_SWAY_AMP
        targetPitch = 0.25 -- Levemente para baixo contra a parede
        
        -- ESTADO: Ar (Pulo / Queda)
    elseif state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
        swaySpeed = 2.0
        swayAmp = 0.05 -- Pouco balanço no ar
        
        if velocity.Y > 1 then
            -- PULAR: Cauda vai para BAIXO (X positivo no CFrame local da cauda)
            targetPitch = SETTINGS.JUMP_PITCH
        elseif velocity.Y < -1 then
            -- CAIR: Cauda vai para CIMA devido ao vento (X negativo)
            targetPitch = SETTINGS.FALL_PITCH
        end
        
        -- ESTADO: Chão (Parado / Andar / Correr)
    else
        if horizontalSpeed > 1 then
            -- Transição suave de ritmo dependendo da velocidade (Andar vs Correr)
            local speedRatio = math.clamp(horizontalSpeed / 16, 0, 1)
            swaySpeed = math.clamp(SETTINGS.MOVE_SWAY_SPEED * speedRatio, SETTINGS.IDLE_SWAY_SPEED, 10)
            swayAmp = math.clamp(SETTINGS.MOVE_SWAY_AMP * speedRatio, SETTINGS.IDLE_SWAY_AMP, 0.35)
            
            -- Arrasto ao correr (Cauda reclina suavemente para trás)
            targetPitch = math.clamp(localVel.Z * SETTINGS.DRAG_PITCH, -SETTINGS.MAX_TILT, SETTINGS.MAX_TILT)
        else
            -- Parado (Idle)
            swaySpeed = SETTINGS.IDLE_SWAY_SPEED
            swayAmp = SETTINGS.IDLE_SWAY_AMP
        end
    end
    
    -- 3. Cálculo do Balanço e Força Centrífuga
    counter = counter + (dt * swaySpeed)
    local activeSway = math.sin(counter) * swayAmp
    
    -- Força ao girar o personagem em movimento
    local curveForce = math.clamp(rotationDiff * SETTINGS.TURN_INERTIA, -SETTINGS.MAX_TILT, SETTINGS.MAX_TILT)
    
    -- Combinação final dos eixos
    targetPitch = math.clamp(targetPitch, -SETTINGS.MAX_TILT, SETTINGS.MAX_TILT)
    targetYaw = activeSway + curveForce
    targetRoll = curveForce * 0.4
    
    local targetRotation = CFrame.Angles(targetPitch, targetYaw, targetRoll)
    
    -- 4. Interpolação (Lerp) Suave em todas as instâncias de cauda
    for _, data in ipairs(tails) do
        if data.weld and data.weld.Parent then
            data.weld.C1 = data.weld.C1:Lerp(data.originalC1 * targetRotation, SETTINGS.LERP_SPEED)
        end
    end
end)
 
-- Recarrega o rastreamento ao renascer
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    task.wait(0.5)
    scanTails()
end)
 
task.spawn(scanTails)
