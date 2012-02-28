require 'lib/middleclass'
require 'costume'

global.Armor = class('Armor', Costume)

function Armor:initialize()
    Costume.initialize(self)
    self.move_speed = 120
    self.jump_speed = 500
    self.gravity = 1700
    self.ttl = 10
    
    self.distance_shoot_dispersion = 500
    self.max_shoot_dispersion = 0
    
    self.image = love.graphics.newImage('img/armor.png')
end
