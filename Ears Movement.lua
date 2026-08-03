-- ========================================== --
--  Script desenvolvido por: kauetheprotogen  --
--  Créditos: kauetheprotogen - GitHub/Roblox --
-- ========================================== --

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local ears = {}
local counter = 0
local lastRootRotation = CFrame.new()

-- Temporizadores para espasmos/tiques aleatórios das orelhas
local nextTwitchTime = 0
local currentTwitchPower = { left = 0, right = 0 }

-- Configurações de Física e Resposta das Orelhas
local SETTINGS = {
LERP_SPEED = 0.18, -- Velocidade de resposta da mola (orelhas são mais leves que caudas)
MAX_TILT = 0.5, -- Limite máximo de inclinação (em radianos)

-- Parado (Idle) & Espasmos
IDLE_SPEED = 2.0,
IDLE_AMPLITUDE = 0.03,
TWITCH_CHANCE = 0.3, -- Frequência dos tiques aleatórios de escuta

-- Passos e Quique (Bounce)
BOUNCE_SPEED = 14.0,
BOUNCE_AMPLITUDE = 0.08,

-- Movimento Longitudinal (Frente / Trás)
FORWARD_DRAG = 0.012, -- O quanto vão para trás ao andar/correr pra frente
BACKWARD_PITCH = -0.15, -- O quanto vão para frente ao andar para trás (suave)

-- Curvas / Strafe (Lados)
TURN_INERTIA = 1.2,
STRAFE_TILT = 0.01,

-- Física Vertical (Pulo / Queda)
JUMP_PITCH = 0.25, -- Pulo: Vento empurra orelhas para baixo/trás
FALL_PITCH = -0.35, -- Queda: Vento empurra orelhas para cima
}

-- Mapeia as partes das orelhas e define seu lado (Esquerda / Direita)
local function scanEars()
    ears = {}
    if not character then return end
    
    for _, item in ipairs(character:GetDescendants()) do
        local name = string.lower(item.Name)
        if string.find(name, "ear") or string.find(name, "orelha") then
            local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
            if part then
                part.CanCollide = false
                part.Massless = true
                part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                
                local weld = part:FindFirstChild("AccessoryWeld") or part:FindFirstChildWhichIsA("Weld")
                if weld then
                    local isLeft = string.find(name, "left") or string.find(name, "left") or string.find(name, "esq") or string.find(name, "l")
                    local isRight = string.find(name, "right") or string.find(name, "dir") or string.find(name, "r")
                    
                    -- Se não tiver nome explícito, tenta deduzir pela posição relativa
                    local sideDir = 1
                    if isLeft then
                        sideDir = 1
                    elseif isRight then
                        sideDir = -1
                    else
                        sideDir = part.Position.X >= 0 and 1 or -1
                    end
                    
                    table.insert(ears, { weld = weld, originalC1 = weld.C1, direction = sideDir })
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function(dt)
    local root = character:FindFirstChild("HumanoidRootPart")
    if #ears == 0 or not root or not humanoid or humanoid.Health <= 0 then return end
    
    counter = counter + dt
    
    -- 1. Captura de Vetores de Velocidade Locais
    local velocity = root.AssemblyLinearVelocity
    local localVel = root.CFrame:VectorToObjectSpace(velocity)
    local state = humanoid:GetState()
    
    local horizontalSpeed = Vector3.new(localVel.X, 0, localVel.Z).Magnitude
    
    -- Captura de Rotação (Curvas)
    local rootRotation = root.CFrame
    local rotationDiff = rootRotation:VectorToObjectSpace(lastRootRotation.LookVector).X
    lastRootRotation = rootRotation
    
    -- 2. Sistema de Tique Aleatório (Espasmos de atenção)
    if tick() > nextTwitchTime then
        nextTwitchTime = tick() + math.random(2, 6)
        if math.random() < SETTINGS.TWITCH_CHANCE then
            -- Escolhe uma orelha aleatória para dar um leve espasmo
            if math.random() > 0.5 then
                currentTwitchPower.left = math.random(15, 30) * 0.01
            else
                currentTwitchPower.right = math.random(15, 30) * 0.01
            end
        end
    end
    
    -- Decai o tique gradualmente
    currentTwitchPower.left = math.clamp(currentTwitchPower.left - (dt * 3), 0, 1)
    currentTwitchPower.right = math.clamp(currentTwitchPower.right - (dt * 3), 0, 1)
    
    -- 3. Cálculo de Movimento Longitudinal (Eixo Pitch / X)
    local pitchMove = 0
    
    if localVel.Z < -0.5 then
        -- Movimento para FRENTE (localVel.Z é negativo para frente no Roblox)
        -- Orelhas vão para TRÁS proporcionalmente à velocidade
        pitchMove = math.abs(localVel.Z) * SETTINGS.FORWARD_DRAG
    elseif localVel.Z > 0.5 then
        -- Movimento para TRÁS (localVel.Z é positivo)
        -- Orelhas vão um pouco para FRENTE (suave)
        pitchMove = SETTINGS.BACKWARD_PITCH * math.clamp(localVel.Z / 12, 0, 1)
    end
    
    -- 4. Efeito de Quique (Passos ao Andar/Correr)
    local walkBounce = 0
    if horizontalSpeed > 1 and state == Enum.HumanoidStateType.Running then
        local speedRatio = math.clamp(horizontalSpeed / 16, 0, 1.2)
        walkBounce = math.abs(math.sin(counter * SETTINGS.BOUNCE_SPEED)) * (SETTINGS.BOUNCE_AMPLITUDE * speedRatio)
    end
    
    -- 5. Física Vertical (Pulo e Queda)
    local verticalPitch = 0
    if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
        if velocity.Y > 1 then
            -- Pular: Orelhas vão levemente para BAIXO / TRÁS
            verticalPitch = SETTINGS.JUMP_PITCH
        elseif velocity.Y < -1 then
            -- Cair: Vento empurra orelhas para CIMA / FRENTE
            verticalPitch = SETTINGS.FALL_PITCH
        end
    end
    
    -- 6. Balanço Idle (Respiração)
    local idleSway = math.sin(counter * SETTINGS.IDLE_SPEED) * SETTINGS.IDLE_AMPLITUDE
    
    -- Combinando o Pitch Global (Inclinação frente/trás)
    local basePitch = pitchMove + verticalPitch + walkBounce + idleSway
    basePitch = math.clamp(basePitch, -SETTINGS.MAX_TILT, SETTINGS.MAX_TILT)
    
    -- Força lateral por curva ou movimento em strafe
    local curveForce = math.clamp(rotationDiff * SETTINGS.TURN_INERTIA, -0.3, 0.3)
    local strafeForce = math.clamp(-localVel.X * SETTINGS.STRAFE_TILT, -0.3, 0.3)
    
    -- 7. Aplicação Dinâmica por Orelha
    for _, data in ipairs(ears) do
        if data.weld and data.weld.Parent then
            local twitch = (data.direction == 1) and currentTwitchPower.left or currentTwitchPower.right
            
            -- Eixo Yaw (Rotação em Y - Virar a orelha para os lados)
            local targetYaw = (curveForce + strafeForce) * data.direction
            
            -- Eixo Roll (Rotação em Z - Inclinação de abertura)
            local targetRoll = (idleSway * 0.5 + twitch) * data.direction
            
            -- Ajusta Pitch individual somando o espasmo
            local finalPitch = basePitch + (twitch * 0.5)
            
            local targetRotation = CFrame.Angles(finalPitch, targetYaw, targetRoll)
            
            -- Interpolação suave (Lerp)
            data.weld.C1 = data.weld.C1:Lerp(data.originalC1 * targetRotation, SETTINGS.LERP_SPEED)
        end
    end
end)

-- Reconeta o rastreamento ao renascer
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    task.wait(0.5)
    scanEars()
end)

task.spawn(scanEars)
