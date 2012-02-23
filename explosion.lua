require 'lib/middleclass'

global.Explosion = class('Explosion')

function Explosion:initialize(x, y)
    -- copy some properties
    self.x = x
    self.y = y
    self.alive = true
    self.ttl = 0.1

    self.img = img or love.graphics.newImage('img/explosion.tga')

end

function Explosion:update(dt, tiles)
    self.ttl = self.ttl - (1 * dt)
    if self.ttl < 0 then
        self.alive = false
    end
end

function Explosion:draw()
    -- explosion sprite
    love.graphics.draw(self.img, self.x - 8, self.y - 8)
end
