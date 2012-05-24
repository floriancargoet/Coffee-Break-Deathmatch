require 'lib/middleclass'
require 'costume'

global.Player = class('Player')

function Player:initialize(id)
    -- copy some properties
    self.id = id
    self.character = nil
    self.crosshairX = 0
    self.crosshairY = 0
    self.crosshairDispersion = 0
end

function Player:isSpawned()
    return self.character ~= nil
end

function Player:moveLeft()
    if self:isSpawned() then
        self.character:moveLeft()
    end
end

function Player:moveRight()
    if self:isSpawned() then
        self.character:moveRight()
    end
end

function Player:stopMoving()
    if self:isSpawned() then
        self.character:stopMoving()
    end
end

function Player:jump()
    if self:isSpawned() then
        self.character:jump()
    end
end

function Player:stopJump()
    if self:isSpawned() then
        self.character:stopJump()
    end
end


-- called by Game since we don't want a crosshair for each Character
function Player:drawCrosshair()
    if self:isSpawned() then
        -- crosshair
        local r, g, b, a = love.graphics.getColor() -- backup color
        local isDispersionMax = (self.crosshairDispersion == self.character.costume.maxShootDispersion)
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
end

function Player:updateCrosshair(mouseX, mouseY)
    if self:isSpawned() then
        -- options
        local maxDist = self.character.costume.maxDistanceShootDispersion    -- after maxDist, dispersion is maximal
        local maxPixelDispersion = self.character.costume.maxShootDispersion -- dispersion is between 0 pixels and {maxPixelDispersion} pixels
    
        self.crosshairX = mouseX
        self.crosshairY = mouseY
    
        local x, y = self.character.x + self.character.w/2, self.character.y + self.character.h/2 -- center of the Character
        local dx, dy = mouseX - x, mouseY - y
        local d = math.sqrt(dx*dx + dy*dy)                -- distance between Character and mouse
    
    
        if d > maxDist then
            self.crosshairDispersion = maxPixelDispersion
        else
            self.crosshairDispersion = (d/maxDist) * (d/maxDist) * maxPixelDispersion
        end
    end
end

function Player:shoot(targetX, targetY, dispersion)
    if self:isSpawned() then
        local CharacterX, CharacterY = self.character.x + self.character.w/2, self.character.y + self.character.h/2 -- center of the Character
        local dispersion = dispersion or (self.crosshairDispersion * 2)
        local dispX, dispY = 0, 0
        if dispersion > 1 then
            dispX = math.random(dispersion) - dispersion/2 -- anywhere in the crosshair
            dispY = math.random(dispersion) - dispersion/2
        end
    
        local hitX = targetX + dispX
        local hitY = targetY + dispY
        local angle = math.atan2((hitY - CharacterY),(hitX - CharacterX))
        game:createProjectile(self, CharacterX, CharacterY, angle, 1000)
    end
end
