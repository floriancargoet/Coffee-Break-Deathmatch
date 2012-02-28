require 'lib/middleclass'
require 'item'
require 'armor'

global.ArmorItem = class('ArmorItem', Item)

function ArmorItem:initialize(entity)
    Item.initialize(self, entity)

    self.img = love.graphics.newImage('img/armor_icon.png')
end

function Item:draw()
    -- Item sprite
    love.graphics.draw(self.img, self.entity.x, self.entity.y)
end

function Item:applyEffect(player)
    player.costume = Armor:new()
end
