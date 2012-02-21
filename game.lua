local game = {}

game.keys = {}

-- Executed at startup
function game:load()
    self.map = ATL.Loader.load('test.tmx')
    local player = self.map.ol["Players"]:newObject("player", "Entity", 0, 0, 32, 64)
    player.img = love.graphics.newImage('img/player.png')
    
    player.vx = 0
    player.vy = 0
    player.jumping = false
    
    player.draw = function()
        love.graphics.draw(player.img, player.x, player.y)
    end
    
    self.player = player
end

-- Executed each step
function game:update(dt)
    local p = self.player
    local k = self.keys
    
    p.vx = 0
    if k.left then
        p.vx = -250
    end
    if k.right then
        p.vx = 250
    end
    
    -- if in the air
    if p.y < 664 then
        p.inAir = true
    else 
        p.inAir = false
    end
    
    if k.up and not p.inAir then
        p.vy = -800
        p.inAir = true
    end
    
    -- if falling
    if p.inAir then
        p.vy = p.vy + 4000*dt
        if p.vy > 800 then
            p.vy = 800
        end
    else -- ground contact
        p.vy = 0
        p.y = 664
    end
    
    p.x = p.x + p.vx*dt
    p.y = p.y + p.vy*dt
    
    p:updateDrawInfo() -- for drawRange optimizations
end

function game:keypressed(key)
    self.keys[key] = true
end

function game:keyreleased(key)
    self.keys[key] = false
end

function game:mousepressed(x, y, button)

end

-- Drawing operations
function game:draw()
    self.map:draw()
end

return game
