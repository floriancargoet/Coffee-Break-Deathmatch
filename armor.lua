require 'lib/middleclass'
require 'costume'

global.Armor = class('Armor', Costume)

function Armor:initialize()
    Costume.initialize(self)
    self.moveSpeed = 120
    self.jumpSpeed = 500
    self.gravity = 1700
    self.ttl = 10
    
    self.distanceShootDispersion = 500
    self.maxShootDispersion = 0
    
    self.image = love.graphics.newImage('img/armor.png')
end
