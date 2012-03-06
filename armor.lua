require 'lib/middleclass'
require 'costume'

global.Armor = class('Armor', Costume)

Costume.registry['Armor'] = Armor

function Armor:initialize()
    Costume.initialize(self)

    self.name = 'Armor'

    -- physics
    self.moveSpeed = 120 -- armor is heavy, you are slower
    self.jumpSpeed = 500
    self.gravity   = 1700

    -- shooting
    self.maxDistanceShootDispersion = 500
    self.maxShootDispersion = 0 -- you are a sniper!

    -- display
    self.image = love.graphics.newImage('img/armor.png')

    -- other
    self.ttl = 10
end
