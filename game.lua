require 'player'
require 'projectile'
require 'explosion'

local game = {}

game.keys = {}
game.projectiles = {}
game.explosions = {}

-- Executed at startup
function game:load()
    self.map = ATL.Loader.load('test.tmx')
    self:spawnPlayer()
end

function game:spawnPlayer()
    local spawnIndex = math.random(#self.map.ol['Spawns'].objects)
    local spawnPoint = self.map.ol['Spawns'].objects[spawnIndex]
    local playerEnt = self.map.ol['Players']:newObject('player', 'Entity', spawnPoint.x, spawnPoint.y, 32, 64)
    local player = Player:new(playerEnt)

    self.player = player
end

function game:createProjectile(x, y, angle, speed)
    local projectile = Projectile:new(x, y, angle, speed)
    table.insert(self.projectiles, projectile)
end

function game:updateProjectiles(dt, tiles)
    local toRemove = {}
    for i, projectile in ipairs(self.projectiles) do
        projectile:update(dt, tiles)
        if not projectile.alive then
            table.insert(toRemove, i)
            local explosion = Explosion:new(projectile.x, projectile.y)
            table.insert(self.explosions, explosion)
        end
    end

    for i, projectile in ipairs(toRemove) do
        table.remove(self.projectiles, projectile)
    end
end

function game:updateExplosions(dt, tiles)
    local toRemove = {}
    for i, explosion in ipairs(self.explosions) do
        explosion:update(dt, tiles)
        if not explosion.alive then
            table.insert(toRemove, i)
        end
    end

    for i, explosion in ipairs(toRemove) do
        table.remove(self.explosions, explosion)
    end
end

-- Executed each step
function game:update(dt)

    local tiles = self.map.tl['tiles'].tileData

    self:updateProjectiles(dt, tiles)
    self:updateExplosions(dt, tiles)

    local p = self.player
    local k = self.keys

    if k.left or k.q then
        p:moveLeft()
    end
    if k.right or k.d then
        p:moveRight()
    end
    if not (k.left or k.right or k.q or k.d) then
        p:stopMoving()
    end
    
    if k.up then
        p:jump()
    end
    
    p:updatePhysics(dt, tiles)
    p:updateCrosshair(love.mouse.getPosition())
    p:updateDrawInfo() -- for drawRange optimizations
end

function game:keypressed(key)
    self.keys[key] = true
    if key == ' ' or key == 'z' then
        self.player:jump()
    end
end

function game:keyreleased(key)
    self.keys[key] = false
    if key == ' ' or key == 'z' then
        self.player:stopJump()
    end
end

function game:mousepressed(x, y, button)
    local p = self.player
    if button == 'l' then
        local playerX, playerY = p.x + p.w/2, p.y + p.h/2   -- center of the player
        local dispersion = p.crosshairDispersion * 2
        local dispX, dispY = 0, 0
        if dispersion > 1 then
            dispX = math.random(dispersion) - dispersion/2  -- anywhere in the crosshair
            dispY = math.random(dispersion) - dispersion/2
        end
        
        local targetX = x + dispX
        local targetY = y + dispY
        local angle = math.atan2((targetY - playerY),(targetX - playerX))
        self:createProjectile(playerX, playerY, angle, 1000)
    end
    
    if button == 'r' then
        p:jump()
    end
end

function game:mousereleased(x, y, button)
    if button == 'r' then
        self.player:stopJump()
    end
end

-- Drawing operations
function game:draw()
    self.map:draw()
    for i, projectile in ipairs(self.projectiles) do
        projectile:draw()
    end
    for i, explosion in ipairs(self.explosions) do
        explosion:draw()
    end
end

return game
