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
    local playerent = self.map.ol['Players']:newObject('player', 'Entity', spawnPoint.x, spawnPoint.y, 32, 64)
    local player = Player:new(playerent)
    
    self.player = player
end

-- Executed each step
function game:update(dt)
    local p = self.player
    local k = self.keys

    if k.left then
        p:moveLeft()
    end
    if k.right then
        p:moveRight()
    end
    if not (k.left or k.right) then
        p:stopMoving()
    end
    
    if k.up then
        p:jump()
    end
    
    p:updatePhysics(dt, self.map.tl['tiles'].tileData)
    
    p:updateDrawInfo() -- for drawRange optimizations
end

function game:keypressed(key)
    self.keys[key] = true
    if key == ' ' then
        self.player:jump()
    end
end

function game:keyreleased(key)
    self.keys[key] = false
    if key == ' ' then
        self.player:stopJump()
    end
end

function game:mousepressed(x, y, button)

end

-- Drawing operations
function game:draw()
    self.map:draw()
end

return game
