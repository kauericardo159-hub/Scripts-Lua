local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
 
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
 
local tails = {}
local counter = 0
local lastRootRotation = CFrame.new()
 
-- ### Configurações de "Elite" ###
local SETTINGS = {
SWAY_SPEED = 4.5,           -- Velocidade do balanço ocioso
SWAY_AMPLITUDE = 0.15,      -- Amplitude do balanço parado (suave)
LERP_SPEED = 0.12,          -- Reação da "mola" (menor = mais pesado)
DRAG_RESISTANCE = 0.05,     -- O quanto a cauda "fica para trás" ao correr
CURVE_INERTIA = 1.5,        -- Força centrífuga em curvas
MAX_TILT = 0.8,             -- Limite para não bugar a rotação
 
-- [NOVIDADES ADICIONADAS]
RUN_WAG_MULTIPLIER = 0.4,   -- O quanto o balanço acelera enquanto o player anda/corre
SWIM_AMPLITUDE = 0.6        -- Movimento mais largo e sinuoso quando está nadando
}
 
local function scanTails()
    tails = {}
    for _, item in ipairs(character:GetDescendants()) do
        if string.find(string.lower(item.Name), "tail") then
            local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
            if part then
                -- [CORREÇÃO DA ÁGUA]: Tirar a colisão e a massa da cauda impede que ela afunde o player
                part.CanCollide = false
                part.Massless = true 
                part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
                
                local weld = part:FindFirstChild("AccessoryWeld") or part:FindFirstChildWhichIsA("Weld")
                if weld then
                    table.insert(tails, {weld = weld, originalC1 = weld.C1})
                end
            end
        end
    end
end
 
RunService.RenderStepped:Connect(function(dt)
    local root = character:FindFirstChild("HumanoidRootPart")
    if #tails == 0 or not root or not humanoid then return end
    
    -- 1. Captura de Dados de Movimento
    local velocity = root.AssemblyLinearVelocity
    local localVel = root.CFrame:VectorToObjectSpace(velocity)
    local rootRotation = root.CFrame
    
    local rotationDiff = (rootRotation:VectorToObjectSpace(lastRootRotation.LookVector)).X
    lastRootRotation = rootRotation
    
    -- Detecta se o jogador está na água
    local isSwimming = humanoid:GetState() == Enum.HumanoidStateType.Swimming
    
    -- [NOVIDADE 1]: Velocidade dinâmica do balanço baseada na velocidade do movimento
    local speedMagnitude = math.clamp(localVel.Magnitude, 0, 30)
    local currentSwaySpeed = SETTINGS.SWAY_SPEED + (speedMagnitude * SETTINGS.RUN_WAG_MULTIPLIER)
    
    -- Aumenta o contador com a nova velocidade dinâmica
    counter = counter + (dt * currentSwaySpeed)
    
    -- [NOVIDADE 2]: Amplitude fluida para natação vs Ocioso
    local currentAmplitude = isSwimming and SETTINGS.SWIM_AMPLITUDE or SETTINGS.SWAY_AMPLITUDE
    local activeSway = math.sin(counter) * currentAmplitude
    
    -- 3. Efeito de Arrasto (Correr para frente faz a cauda subir/recuar)
    local dragX = math.clamp(localVel.Z * SETTINGS.DRAG_RESISTANCE * 0.1, -SETTINGS.MAX_TILT, SETTINGS.MAX_TILT)
    
    -- 4. Força Centrífuga (Curvas)
    local curveForce = math.clamp(rotationDiff * SETTINGS.CURVE_INERTIA, -SETTINGS.MAX_TILT, SETTINGS.MAX_TILT)
    
    -- 5. Influência de Salto/Queda/Mergulho
    local fallInfluence = 0
    if isSwimming then
        -- Na água, o eixo Y do pulo afeta a cauda suavemente como um leme
        fallInfluence = math.clamp(localVel.Y * 0.03, -0.4, 0.4)
    else
        -- No ar/chão
        fallInfluence = math.clamp(-velocity.Y * 0.02, -0.5, 0.5)
    end
    
    -- Mistura final de movimentos
    local targetRotation = CFrame.Angles(
    fallInfluence + dragX, 
    activeSway + curveForce, 
    curveForce * 0.5 
    )
    
    -- 6. Aplicação Suavizada com Lerp Dinâmico
    for _, data in ipairs(tails) do
        if data.weld and data.weld.Parent then
            data.weld.C1 = data.weld.C1:Lerp(data.originalC1 * targetRotation, SETTINGS.LERP_SPEED)
        end
    end
end)
 
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    task.wait(1)
    scanTails()
end)
 
task.spawn(scanTails)
