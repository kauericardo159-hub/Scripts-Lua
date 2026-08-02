local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local ears = {}
local counter = 0

-- ### Configurações das Orelhas ###
local SETTINGS = {
IDLE_SPEED = 2.0,        -- Velocidade do movimento parado (respiração)
IDLE_AMPLITUDE = 0.05,   -- Movimento bem suave (orelhas atentas)
BOUNCE_SPEED = 14.0,     -- Frequência do "quique" ao andar/correr
BOUNCE_AMPLITUDE = 0.15, -- Força do balanço a cada passo
FALL_DRAG = 0.02,        -- Resistência do ar ao pular ou cair
LERP_SPEED = 0.18        -- Suavidade (orelhas geralmente são mais "rápidas" que caudas)
}

local function scanEars()
    ears = {}
    for _, item in ipairs(character:GetDescendants()) do
        local name = string.lower(item.Name)
        -- Procura por "ear" ou "orelha" no nome do item
        if string.find(name, "ear") or string.find(name, "orelha") then
            local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
            if part then
                -- Previne o mesmo bug da água e de peso extra no personagem
                part.CanCollide = false
                part.Massless = true 
                part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
                
                local weld = part:FindFirstChild("AccessoryWeld") or part:FindFirstChildWhichIsA("Weld")
                if weld then
                    -- Detecta se é orelha esquerda ou direita para não balançarem de forma idêntica (como um limpador de para-brisa)
                    local isLeft = string.find(name, "left") or string.find(name, "esquerda")
                    local dir = isLeft and 1 or -1
                    
                    table.insert(ears, {weld = weld, originalC1 = weld.C1, direction = dir})
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function(dt)
    local root = character:FindFirstChild("HumanoidRootPart")
    if #ears == 0 or not root or not humanoid then return end
    
    local velocity = root.AssemblyLinearVelocity
    -- Pega apenas a velocidade horizontal (X e Z) para o andar/correr
    local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
    
    counter = counter + dt
    
    -- 1. Inativo (Idle): Leve tremor/respiração
    local idleSway = math.sin(counter * SETTINGS.IDLE_SPEED) * SETTINGS.IDLE_AMPLITUDE
    
    -- 2. Andar / Correr (Bounce):
    -- Usamos math.abs para criar um efeito de "quique" (sempre valor positivo) que simula os passos batendo no chão
    local walkBounce = 0
    if horizontalSpeed > 0.5 then
        -- O peso do bounce aumenta de acordo com a velocidade do player
        local speedFactor = math.clamp(horizontalSpeed / 16, 0, 1.5) 
        walkBounce = math.abs(math.sin(counter * SETTINGS.BOUNCE_SPEED)) * SETTINGS.BOUNCE_AMPLITUDE * speedFactor
    end
    
    -- 3. Pular / Cair (Inércia e Resistência do Ar):
    -- Quando sobe (Y positivo), o vento empurra as orelhas para trás. Quando cai (Y negativo), empurra para frente/cima.
    local fallDrag = math.clamp(velocity.Y * SETTINGS.FALL_DRAG, -0.5, 0.5)
    
    -- Rotação no eixo X (inclinação para frente/trás)
    local targetPitch = fallDrag - walkBounce + idleSway
    
    for _, data in ipairs(ears) do
        if data.weld and data.weld.Parent then
            -- Rotação no eixo Z (inclinação para os lados) dá um charme usando a direção da orelha
            local targetRoll = idleSway * 0.5 * data.direction
            
            local targetRotation = CFrame.Angles(targetPitch, 0, targetRoll)
            data.weld.C1 = data.weld.C1:Lerp(data.originalC1 * targetRotation, SETTINGS.LERP_SPEED)
        end
    end
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    task.wait(1)
    scanEars()
end)

task.spawn(scanEars)
