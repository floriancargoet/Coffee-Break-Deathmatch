require 'lib/middleclass'

global.Projectile = class('Projectile')

function Projectile:initialize(x, y, angle, speed)
    -- copy some properties
    self.x = x
    self.y = y
    self.angle = angle
    self.speed = speed
    self.alive = true
    self.ttl = 1

    self.img = img or love.graphics.newImage('img/bullet.tga')

end

function Projectile:update(dt, tiles)
    -- projectile update
    local vx = self.speed * math.cos(self.angle)
    local vy = self.speed * math.sin(self.angle)
    self.x = self.x + vx*dt
    self.y = self.y + vy*dt

    for j, temp in ipairs(tiles) do
        for i, tile in ipairs(temp) do
            if tile ~= 0 then
                local tilex = (i-1)*32
                local tiley = (j-1)*32

                if self.x + 2 < tilex + 32 and self.x + 2 > tilex and self.y + 2 < tiley + 32 and self.y + 2 > tiley then
                    self.alive = false
                end
            end
        end
    end

    self.ttl = self.ttl - (1 * dt)
    if self.ttl < 0 then
        self.alive = false
    end

end

function Projectile:draw()
    -- projectile sprite
    love.graphics.draw(self.img, self.x - 2, self.y - 2)
end
