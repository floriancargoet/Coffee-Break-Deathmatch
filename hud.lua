require 'lib/middleclass'
require 'player'
require 'armor_item'
require 'lib/util'

global.HUD = class('HUD')

function HUD:initialize(config)
    self.values = {}
    util.copy(config, self)
    self.font = love.graphics.newFont("fonts/visitor1.ttf", 14)
end

function HUD:update(values)
    util.copy(values, self.values)
end

function HUD:draw()
    local v = self.values
    local g = love.graphics

    -- backup font, use custom
    local old_font = g.getFont()
    g.setFont(self.font)

    self:drawHP(v.hp)

    if v.costume_ttl ~= math.huge then
        love.graphics.print('Costume time left : ' .. math.ceil(v.costume_ttl) .. ' seconds', 0, 40)
    end

    -- special info
    if self.fps then
        love.graphics.print('FPS : ' .. love.timer.getFPS(), 0, 0)
    end

    -- restore font
    g.setFont(old_font)
end


function HUD:drawHP(hp)
    local low = (hp <= 20)
    local oldr, oldg, oldb, olda

    if low then
        oldr, oldg, oldb, olda = love.graphics.getColor()
        love.graphics.setColor(255, 0, 0, olda)
    end

    love.graphics.print('HP : ', 0, 20)
    love.graphics.rectangle( 'line', 40, 22, 100, 8 )
    love.graphics.rectangle( 'fill', 40, 22, hp, 8 )

    if low then
        love.graphics.setColor(oldr, oldg, oldb, olda)
    end
end
