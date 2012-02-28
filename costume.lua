require 'lib/middleclass'

global.Costume = class('Costume')

function Costume:initialize()
    self.move_speed = 250
    self.jump_speed = 600
    self.gravity = 1500
    
    self.distance_shoot_dispersion = 500
    self.max_shoot_dispersion = 30
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
