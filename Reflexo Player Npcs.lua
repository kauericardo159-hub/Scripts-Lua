-- Configurações de Reflexo
local BODY_REFLECT = 0.3      -- Brilho do corpo do personagem
local ACCESSORY_REFLECT = 0.6 -- Brilho levemente maior nos acessórios
local TEXTURE_TRANS = 0.45    -- Transparência das texturas aplicadas sobre as peças
 
local function applyPlayerReflections(obj)
    -- Evita erros com scripts ou pastas
    if obj:IsA("LuaSourceContainer") or obj:IsA("Folder") then return end
    
    -- 1. IDENTIFICAÇÃO DE PLAYERS E BOTS
    -- Verifica se o objeto está dentro de um Modelo que possui um Humanoid
    local character = obj:FindFirstAncestorOfClass("Model")
    if character and character:FindFirstChildOfClass("Humanoid") then
        
        -- 2. APLICAÇÃO DE MATERIAIS E REFLEXOS
        if obj:IsA("BasePart") then
            -- Ignora Neon e ForceField para não quebrar efeitos de magia ou visores brilhantes
            if obj.Material ~= Enum.Material.Neon and obj.Material ~= Enum.Material.ForceField then
                
                -- Usa SmoothPlastic para refletir a luz ambiente definida no seu mapa
                obj.Material = Enum.Material.SmoothPlastic
                
                -- Separa a intensidade: Acessórios brilham um pouco mais que o corpo
                if obj:FindFirstAncestorOfClass("Accessory") then
                    obj.Reflectance = ACCESSORY_REFLECT
                else
                    obj.Reflectance = BODY_REFLECT
                end
            end
        end
        
        -- 3. AJUSTE DE CAMADAS (Texturas e Decals)
        -- Reduz a opacidade das imagens coladas nas peças para o brilho aparecer por baixo
        if obj:IsA("Texture") or obj:IsA("Decal") then
            -- Ignora o rosto para não apagar a expressão do personagem
            if obj.Name:lower() ~= "face" then
                obj.Transparency = TEXTURE_TRANS
            end
        end
    end
end
 
-- ==========================================
-- EXECUÇÃO E MONITORAMENTO (Apenas Personagens)
-- ==========================================
 
-- Varre o workspace em busca de partes de players/NPCs já existentes
for _, item in pairs(game.Workspace:GetDescendants()) do
    applyPlayerReflections(item)
end
 
-- Monitora a entrada de novos personagens ou itens equipados
game.Workspace.DescendantAdded:Connect(function(newItem)
    task.wait(0.1) -- Pequeno delay para garantir que o objeto foi carregado
    applyPlayerReflections(newItem)
end)
 
print("✨ Reflexos Ativados apenas em Players e NPCs (Sem alterações no Lighting).")
