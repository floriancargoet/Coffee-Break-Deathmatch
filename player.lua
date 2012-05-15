require 'lib/middleclass'
require 'costume'

global.Player = class('Player')

function Player:initialize(id, entity)
    -- copy some properties
    self.id = id
    self.x = entity.x
    self.y = entity.y
    self.w = entity.width
    self.h = entity.height
    self.hp = 100

    self.speedX = 0
    self.speedY = 0
    self.canJump = 0
    self.entity = entity

    self.defaultCostume = Costume()
    self.costume = self.defaultCostume
    
    local this = self
    self.entity.draw = function()
        this:draw()
    end

    self.crosshairX = 0
    self.crosshairY = 0

    self.crosshairDispersion = 0

end

function Player:draw()
    -- player sprite
    love.graphics.draw(self.costume.image, self.entity.x, self.entity.y)
    self:drawHP(self.hp)
end

-- called by Game since we don't want a crosshair for each player
function Player:drawCrosshair()
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

function Player:drawHP(hp)
    local low = (hp <= 20)
    local oldr, oldg, oldb, olda = love.graphics.getColor()

    if low then
        love.graphics.setColor(255, 0, 0, 180)
    else
        love.graphics.setColor(255, 255, 255, 180)
    end
    love.graphics.rectangle( 'line', self.x, self.y, 32, 4 )
    love.graphics.rectangle( 'fill', self.x + 1, self.y + 1, hp/(100/32) - 2, 2 )

    if low then
        love.graphics.setColor(oldr, oldg, oldb, olda)
    end
end

function Player:getBBox()
    local x = self.x
    local w = self.w
    local y = self.y
    local h = self.h

    return x, y, w, h
end

-- return the coordinates of the tiles the player touches
function Player:getSurroundingTiles(tiles)
    local x, y, w, h = self:getBBox()
    -- transform in grid coordinates
    local tileSize = 32
    local tl, br
    tl = {(x - x % tileSize) / tileSize, (y - y % tileSize) / tileSize}
    br = {((x + w) - (x + w) % tileSize) /tileSize, ((y + h) - (y + h) % tileSize) / tileSize}

    local collidedTiles = {}
    for tileX = tl[1], br[1] do
        for tileY = tl[2], br[2] do
            local row = tiles[tileY + 1]
            if row then
                local tile = row[tileX + 1]
                if tile then
                    table.insert(collidedTiles, {x = tileX + 1, y = tileY + 1, size = tileSize, tileType = tile}) -- tiles have 1-based indexing
                end
            end
        end
    end

    return collidedTiles
end

function Player:bumpInWalls(tiles)
    local surroundingTiles = self:getSurroundingTiles(tiles)
    for i, tile in ipairs(surroundingTiles) do
        if tile.tileType ~= 0 then
            local tileX = (tile.x-1) * tile.size
            local tileY = (tile.y-1) * tile.size
            local tileX2 = (tile.x) * tile.size
            local tileY2 = (tile.y) * tile.size
            if not (self.x + 4 >= tileX2 or self.x + 28 <= tileX or self.y + 20 >= tileY2 or self.y + 64 <= tileY) then
                self.x = self.oldX
                self.speedX = 0
            end
        end
    end
end

function Player:bumpInCeiling(tiles)
    if self.speedY > 0 then return false end

    local surroundingTiles = self:getSurroundingTiles(tiles)
    for i, tile in ipairs(surroundingTiles) do
        if tile.tileType ~= 0 then
            local tileX = (tile.x-1) * tile.size
            local tileY = (tile.y-1) * tile.size
            local tileX2 = (tile.x) * tile.size
            local tileY2 = (tile.y) * tile.size
            if not (self.x + 4 >= tileX2 or self.x + 28 <= tileX or self.y + 20 >= tileY2 or self.y + 64 <= tileY) then
                self.y = tileY + 32 - 20
                self.speedY = 0
            end
        end
    end
end

function Player:isOnGround(tiles)
    if self.speedY < 0 then return false end

    local surroundingTiles = self:getSurroundingTiles(tiles)
    for i, tile in ipairs(surroundingTiles) do
        if tile.tileType ~= 0 then
            local tileX = (tile.x-1) * tile.size
            local tileY = (tile.y-1) * tile.size
            local tileX2 = (tile.x) * tile.size
            local tileY2 = (tile.y) * tile.size
            if not (self.x + 4 >= tileX2 or self.x + 28 <= tileX or self.y + 20 >= tileY2 or self.y + 64 < tileY) then
                -- we adjust the y position
                self.y = tileY - 64
                return true
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
    self:bumpInCeiling(tiles)

    -- checking for ground
    if self:isOnGround(tiles) then
        self.inAir = false
        self.speedY = 0
        self.canJump = 100
    else
        self.inAir = true
        if self.canJump > 0 then
            self.canJump = self.canJump - dt * 1000
        end
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
    if self.canJump > 0 then
        self.speedY = -self.costume.jumpSpeed
        self.inAir = true
        self.canJump = 0
    end
end

function Player:stopJump()
    local minJumpSpeed = self.costume.jumpSpeed / 2
    if self.speedY < -minJumpSpeed then
        self.speedY = -minJumpSpeed
    end
end

function Player:hit(power)
    local minJumpSpeed = self.costume.jumpSpeed / 2
    self.hp = self.hp - (self.costume.damageCoeff * power)
end

function Player:updateDrawInfo()
    self.entity:updateDrawInfo()
end

function Player:shoot(targetX, targetY, dispersion)
    local playerX, playerY = self.x + self.w/2, self.y + self.h/2 -- center of the player
    local dispersion = dispersion or (self.crosshairDispersion * 2)
    local dispX, dispY = 0, 0
    if dispersion > 1 then
        dispX = math.random(dispersion) - dispersion/2 -- anywhere in the crosshair
        dispY = math.random(dispersion) - dispersion/2
    end

    local hitX = targetX + dispX
    local hitY = targetY + dispY
    local angle = math.atan2((hitY - playerY),(hitX - playerX))
    game:createProjectile(self, playerX, playerY, angle, 1000)
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
