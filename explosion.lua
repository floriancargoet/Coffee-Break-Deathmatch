require 'lib/middleclass'
require 'timed_object'

global.Explosion = class('Explosion', TimedObject)

function Explosion:initialize(owner, x, y)
    TimedObject.initialize(self, owner, x, y, 0.1)

    self.img = love.graphics.newImage('img/explosion.tga')

end

function Explosion:draw()
    -- explosion sprite
    love.graphics.draw(self.img, self.x - 8, self.y - 8)
end
