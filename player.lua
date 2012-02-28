require 'lib/middleclass'
require 'costume'

global.Player = class('Player')

function Player:initialize(entity)
    -- copy some properties
    self.x = entity.x
    self.y = entity.y
    self.w = entity.width
    self.h = entity.height

    self.speedX = 0
    self.speedY = 0
    self.canJump = true
    self.entity = entity

    self.defaultCostume = Costume:new()
    self.costume = self.defaultCostume
    
    local this = self
    self.entity.draw = function()
        this:draw()
    end

    self.crosshairX = 0
    self.crosshairY = 0

end

function Player:draw()
    -- player sprite
    love.graphics.draw(self.costume.image, self.entity.x, self.entity.y)

    -- crosshair
    local r, g, b, a = love.graphics.getColor() -- backup color
    local isDispersionMax = (self.crosshairDispersion == self.costume.maxShootDispersion)
    love.graphics.setColor(255, isDispersionMax and 255 or 0, 0) -- yellow when dispersion is maximal
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
                local tileX = (i-1)*32
                local tileY = (j-1)*32
                
                if self.x < tileX + 32 and self.x + 32 > tileX and self.y + 12 < tileY + 32 and self.y + 64 > tileY then
                    self.x = self.oldX
                end
            end
        end
    end
end

function Player:isOnGround(tiles)
    for j, temp in ipairs(tiles) do
        for i, tile in ipairs(temp) do
            if tile ~= 0 then
                local tileX = (i-1)*32
                local tileY = (j-1)*32
                
                if self.x + 2 < tileX + 32 and self.x + 30 > tileX and self.y + 64 < tileY + 32 and self.y + 64 >= tileY then
                    -- we adjust the y position
                    self.y = tileY - 64
                    return true
                end
            end
        end
    end
    return false
end

function Player:updatePhysics(dt, tiles)

    self.costume:update(dt)
    if (self.costume.ttl == 0) then
        self.costume = self.defaultCostume
    end

    self.oldX = self.x
    self.oldY = self.y

    -- if falling or jumping
    if self.inAir then
        self.speedY = self.speedY + self.costume.gravity * dt
        if self.speedY > 600 then
            self.speedY = 600
        end
    end

    self.x = self.x + self.speedX * dt
    self.y = self.y + self.speedY * dt

    self:bumpInWalls(tiles)

    -- checking for ground
    if self:isOnGround(tiles) then
        self.inAir = false
        self.speedY = 0
        self.canJump = true
    else
        self.inAir = true
    end

    self.entity.x = self.x
    self.entity.y = self.y

end


function Player:moveLeft()
    self.speedX = -self.costume.moveSpeed
end

function Player:moveRight()
    self.speedX = self.costume.moveSpeed
end

function Player:stopMoving()
    self.speedX = 0
end

function Player:jump()
    if self.canJump then
        self.speedY = -self.costume.jumpSpeed
        self.inAir = true
        self.canJump = false
    end
end

function Player:stopJump()
    local minJumpSpeed = self.costume.jumpSpeed / 2
    if self.speedY < -minJumpSpeed then
        self.speedY = -minJumpSpeed
    end
end

function Player:updateDrawInfo()
    self.entity:updateDrawInfo()
end

function Player:shoot(targetX, targetY)
    local playerX, playerY = self.x + self.w/2, self.y + self.h/2 -- center of the player
    local dispersion = self.crosshairDispersion * 2
    local dispX, dispY = 0, 0
    if dispersion > 1 then
        dispX = math.random(dispersion) - dispersion/2 -- anywhere in the crosshair
        dispY = math.random(dispersion) - dispersion/2
    end

    local hitX = targetX + dispX
    local hitY = targetY + dispY
    local angle = math.atan2((hitY - playerY),(hitX - playerX))
    game:createProjectile(playerX, playerY, angle, 1000)
end

function Player:updateCrosshair(mouseX, mouseY)
    -- options
    local maxDist = self.costume.maxDistanceShootDispersion    -- after maxDist, dispersion is maximal
    local maxPixelDispersion = self.costume.maxShootDispersion -- dispersion is between 0 pixels and {maxPixelDispersion} pixels

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
