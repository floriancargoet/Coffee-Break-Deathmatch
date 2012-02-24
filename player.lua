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

    self.crosshairX = 0
    self.crosshairY = 0

end

function Player:draw()
    -- player sprite
    love.graphics.draw(self.img, self.entity.x, self.entity.y)

    -- crosshair
    local r, g, b, a = love.graphics.getColor() -- backup color
    love.graphics.setColor(255, self.crosshairDispersion == 1 and 255 or 0, 0) -- yellow when max dispersion
    love.graphics.setLineWidth(2)
    local x, y = self.crosshairX, self.crosshairY
    local d = math.floor(self.crosshairDispersion)
    -- top
    love.graphics.line(x, y + d + 4, x , y + d)
    -- bottom
    love.graphics.line(x, y - d - 4, x , y - d)
    --left
    love.graphics.line(x - d - 4, y, x - d, y)
    --right
    love.graphics.line(x + d + 4, y, x + d, y)
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

function Player:shoot(targetX, targetY)
    local playerX, playerY = self.x + self.w/2, self.y + self.h/2   -- center of the player
    local dispersion = self.crosshairDispersion * 2
    local dispX, dispY = 0, 0
    if dispersion > 1 then
        dispX = math.random(dispersion) - dispersion/2  -- anywhere in the crosshair
        dispY = math.random(dispersion) - dispersion/2
    end

    local hitX = targetX + dispX
    local hitY = targetY + dispY
    local angle = math.atan2((hitY - playerY),(hitX - playerX))
    game:createProjectile(playerX, playerY, angle, 1000)
end

function Player:updateCrosshair(mouseX, mouseY)
    -- options
    local maxDist = 500           -- after maxDist, dispersion is maximal
    local maxPixelDispersion = 30 -- dispersion is between 0 pixels and {maxPixelDispersion} pixels

    self.crosshairX = mouseX
    self.crosshairY = mouseY

    local x, y = self.x + self.w/2, self.y + self.h/2 -- center of the player
    local dx, dy = mouseX - x, mouseY - y
    local d = math.sqrt(dx*dx + dy*dy)                -- distance between player and mouse


    if d > maxDist then
        self.crosshairDispersion = maxPixelDispersion
    else
        self.crosshairDispersion = (d/maxDist) * (d/maxDist) * maxPixelDispersion
    end
end
