require 'lib/middleclass'

global.Costume = class('Costume')

function Costume:initialize()
    self.moveSpeed = 250
    self.jumpSpeed = 600
    self.gravity = 1500
    
    self.distanceShootDispersion = 500
    self.maxShootDispersion = 30
    self.ttl = math.huge
    
    self.image = love.graphics.newImage('img/player.png')
end

function Costume:update(dt)
    if (self.ttl > 0) then
        self.ttl = self.ttl - 1*dt
    else
        self.ttl = 0
    end
end
