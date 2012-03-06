require 'lib/middleclass'
require 'timed_object'

global.Projectile = class('Projectile', TimedObject)

function Projectile:initialize(x, y, angle, speed)
    TimedObject.initialize(self, x, y, 1)
    self.angle = angle
    self.speed = speed

    self.img = love.graphics.newImage('img/bullet.tga')

end

function Projectile:update(dt, tiles)
    TimedObject.update(self, dt, tiles)

    -- projectile update
    local speedX = self.speed * math.cos(self.angle)
    local speedY = self.speed * math.sin(self.angle)
    self.x = self.x + speedX * dt
    self.y = self.y + speedY * dt

    for j, temp in ipairs(tiles) do
        for i, tile in ipairs(temp) do
            if tile ~= 0 then
                local tileX = (i-1)*32
                local tileY = (j-1)*32

                if self.x + 2 < tileX + 32 and self.x + 2 > tileX and self.y + 2 < tileY + 32 and self.y + 2 > tileY then
                    self.alive = false
                end
            end
        end
    end

end

function Projectile:kill()
    game:createExplosion(self.x, self.y)
end

function Projectile:draw()
    -- projectile sprite
    love.graphics.draw(self.img, self.x - 2, self.y - 2)
end
