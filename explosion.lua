require 'lib/middleclass'
require 'timedObject'

global.Explosion = class('Explosion', TimedObject)

function Explosion:initialize(x, y)
    TimedObject.initialize(self, x, y, 0.1)

    self.img = love.graphics.newImage('img/explosion.tga')

end

function Explosion:draw()
    -- explosion sprite
    love.graphics.draw(self.img, self.x - 8, self.y - 8)
end
