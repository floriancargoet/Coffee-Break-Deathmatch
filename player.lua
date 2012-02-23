require 'lib/middleclass'

Player = class('Player')

function Player:initialize(entity)
    self.x = entity.x
    self.y = entity.y
    self.vx = 0
    self.vy = 0
    self.canJump = true
    self.entity = entity

    self.img = love.graphics.newImage('img/player.png')
    
    self.entity.draw = function()
        love.graphics.draw(self.img, self.entity.x, self.entity.y)
    end

end


function Player:bumpInWalls(tiles)
    for j, temp in ipairs(tiles) do
        for i, tile in ipairs(temp) do
            if tile ~= 0 then
                local tilex = (i-1)*32
                local tiley = (j-1)*32
                
                if self.x < tilex + 32 and self.x + 32 > tilex and self.y < tiley + 32 and self.y + 64 > tiley then
                    self.x = self.oldx
                end
            end
        end
    end
end

function Player:isOnGround(tiles)
    for j, temp in ipairs(tiles) do
        for i, tile in ipairs(temp) do
            if tile ~= 0 then
                local tilex = (i-1)*32
                local tiley = (j-1)*32
                
                if self.x < tilex + 32 and self.x + 32 >= tilex and self.y + 64 < tiley + 32 and self.y + 64 >= tiley then
                    -- we adjust the y position
                    self.y = tiley - 64
                    return true
                end
            end
        end
    end
    return false
end

function Player:updatePhysics(dt, tiles)

    self.oldx = self.x
    self.oldy = self.y
    
    -- if falling or jumping
    if self.inAir then
        self.vy = self.vy + 4000*dt
        if self.vy > 800 then
            self.vy = 800
        end
    end
    
    self.x = self.x + self.vx*dt
    self.y = self.y + self.vy*dt
    
    self:bumpInWalls(tiles)

    -- checking for ground
    if self:isOnGround(tiles) then
        self.inAir = false
        self.vy = 0
        self.canJump = true
    else
        self.inAir = true
    end

    self.entity.x = self.x
    self.entity.y = self.y

end

function Player:moveLeft()
    self.vx = -250
end

function Player:moveRight()
    self.vx = 250
end

function Player:stopMoving()
    self.vx = 0
end

function Player:jump()
    if self.canJump then
        self.vy = -1000
        self.inAir = true
        self.canJump = false
    end
end

function Player:updateDrawInfo()
    self.entity:updateDrawInfo()
end
