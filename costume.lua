require 'lib/middleclass'

global.Costume = class('Costume')

Costume.registry = {}
Costume.registry['Default'] = Costume

function Costume:initialize()

    self.name = 'Default'

    -- physics
    self.moveSpeed = 250
    self.jumpSpeed = 600
    self.gravity   = 1500
    
    -- shooting
    self.maxDistanceShootDispersion = 500 -- after this distance (pixels), dispersion doesn't increase anymore
    self.maxShootDispersion = 30          -- maximum size of the crosshair
    
    -- display
    self.image = love.graphics.newImage('img/player.png')
    
    -- other
    self.ttl = math.huge -- time after which the costume is lost
end

function Costume:update(dt)
    if (self.ttl > 0) then
        self.ttl = self.ttl - 1*dt
    else
        self.ttl = 0
    end
end
