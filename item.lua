require 'lib/middleclass'

global.Item = class('Item')

Item.registry = {}
Item.registry['Default'] = Item

function Item:initialize(entity)
    self.entity = entity
    self.x = entity.x
    self.y = entity.y
    self.w = entity.width
    self.h = entity.height

    self.name = 'Default'

    self.img = love.graphics.newImage('img/default_item.png')

    local this = self
    self.entity.draw = function()
        this:draw()
    end

end

function Item:draw()
    -- Item sprite
    love.graphics.draw(self.img, self.entity.x, self.entity.y)
end

function Item:applyEffect(player)
    print('Player took the item')
end
