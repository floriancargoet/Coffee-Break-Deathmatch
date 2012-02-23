require 'lib/middleclass'

global.Player = class('Player')

function Player:initialize(entity)
    -- copy some properties
    self.x = entity.x
    self.y = entity.y
    self.w = entity.width
    self.h = entity.height
    
    self.vx = 0
    self.vy = 0
    self.canJump = true
    self.entity = entity

    self.img = love.graphics.newImage('img/player.png')
    
    local this = self
    self.entity.draw = function()
        this:draw()
    end

end

function Player:draw()
    -- player sprite
    love.graphics.draw(self.img, self.entity.x, self.entity.y)
    
    -- crosshair
    local r, g, b, a = love.graphics.getColor() -- backup color
    love.graphics.setColor(255, 0, 0)
    love.graphics.setLineWidth(2)
    local x, y = self.crosshairX, self.crosshairY
    love.graphics.line(x - 4, y, x + 4, y)
    love.graphics.line(x, y - 4, x, y + 4)
    love.graphics.setColor(r, g, b, a) -- restore color
end

function Player:bumpInWalls(tiles)
    for j, temp in ipairs(tiles) do
        for i, tile in ipairs(temp) do
            if tile ~= 0 then
                local tilex = (i-1)*32
                local tiley = (j-1)*32
                
                if self.x < tilex + 32 and self.x + 32 > tilex and self.y + 12 < tiley + 32 and self.y + 64 > tiley then
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
                
                if self.x + 2 < tilex + 32 and self.x + 30 > tilex and self.y + 64 < tiley + 32 and self.y + 64 >= tiley then
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
        self.vy = self.vy + 1500*dt
        if self.vy > 600 then
            self.vy = 600
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
        self.vy = -600
        self.inAir = true
        self.canJump = false
    end
end

function Player:stopJump()
    if self.vy < -300 then
        self.vy = -300
    end
end

function Player:updateDrawInfo()
    self.entity:updateDrawInfo()
end

function Player:updateCrosshair(mouseX, mouseY)
    -- crosshair is drawn at a fixed distance
    local crosshairRadius = 100
    local x, y = self.x + self.w/2, self.y + self.h/2 -- center of the player
    local dx, dy = mouseX - x, mouseY - y
    local d = math.sqrt(dx*dx + dy*dy) -- distance between player and mouse
    -- force crosshair on a circle
    x = x + (dx/d) * crosshairRadius
    y = y + (dy/d) * crosshairRadius
    -- store coordinates, the crosshair will be drawn in draw()
    self.crosshairX = x
    self.crosshairY = y
end
