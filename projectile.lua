require 'lib/middleclass'
require 'timed_object'

global.Projectile = class('Projectile', TimedObject)

function Projectile:initialize(owner, x, y, angle, speed)
    TimedObject.initialize(self, owner, x, y, 1)
    self.angle = angle
    self.speed = speed
    self.power = 10

    self.img = love.graphics.newImage('img/bullet.tga')

end

function Projectile:update(dt, tiles, players)
    TimedObject.update(self, dt, tiles)

    -- projectile update
    local speedX = self.speed * math.cos(self.angle)
    local speedY = self.speed * math.sin(self.angle)
    self.x = self.x + speedX * dt
    self.y = self.y + speedY * dt

    for x, y, tile in tiles:iterate() do
        if tile and tile.id ~= 0 then
            local tileX = (x)*32
            local tileY = (y)*32

            if self.x + 2 < tileX + 32 and self.x + 2 > tileX and self.y + 2 < tileY + 32 and self.y + 2 > tileY then
                self.alive = false
            end
        end
    end

    for id, player in pairs(players) do
        if id ~= self.owner.id then
            if player.character ~= nil then
                local character = player.character
                if self.x + 2 < character.x + 32 and self.x + 2 > character.x and self.y + 2 < character.y + 64 and self.y + 2 > character.y + 12 then
                    character:hit(self.power)
                    self.alive = false
                end
            end
        end
    end

end

function Projectile:kill()
    game:createExplosion(self.owner, self.x, self.y)
end

function Projectile:draw()
    -- projectile sprite
    love.graphics.draw(self.img, self.x - 2, self.y - 2)
end
