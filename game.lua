require 'player'

local game = {}

game.keys = {}

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

-- Executed each step
function game:update(dt)
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
    
    p:updatePhysics(dt, self.map.tl['tiles'].tileData)
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
    if button == 'r' then
        self.player:jump()
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
end

return game
