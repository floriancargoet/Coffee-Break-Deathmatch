require 'lib/middleclass'
require 'costume'

global.Character = class('Character')

function Character:initialize(entity)
    -- copy some properties
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

end

function Character:draw()
    -- Character sprite
    love.graphics.draw(self.costume.image, self.entity.x, self.entity.y)
    self:drawHP(self.hp)
end

function Character:drawHP(hp)
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

function Character:getBBox()
    local x = self.x
    local w = self.w
    local y = self.y
    local h = self.h

    return x, y, w, h
end

-- return the coordinates of the tiles the Character touches
function Character:getSurroundingTiles(tiles)
    local x, y, w, h = self:getBBox()
    -- transform in grid coordinates
    local tileSize = 32
    local tl, br
    tl = {(x - x % tileSize) / tileSize, (y - y % tileSize) / tileSize}
    br = {((x + w) - (x + w) % tileSize) /tileSize, ((y + h) - (y + h) % tileSize) / tileSize}

    local collidedTiles = {}
    for tileX = tl[1], br[1] do
        for tileY = tl[2], br[2] do
            local tile = tiles:get(tileX, tileY)
            if tile then
                table.insert(collidedTiles, {x = tileX + 1, y = tileY + 1, size = tileSize, tileType = tile.id}) -- tiles have 1-based indexing
            end
        end
    end

    return collidedTiles
end

function Character:bumpInWalls(tiles)
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

function Character:bumpInCeiling(tiles)
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

function Character:isOnGround(tiles)
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

function Character:updatePhysics(dt, tiles)

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


function Character:moveLeft()
    self.speedX = -self.costume.moveSpeed
end

function Character:moveRight()
    self.speedX = self.costume.moveSpeed
end

function Character:stopMoving()
    self.speedX = 0
end

function Character:jump()
    if self.canJump > 0 then
        self.speedY = -self.costume.jumpSpeed
        self.inAir = true
        self.canJump = 0
    end
end

function Character:stopJump()
    local minJumpSpeed = self.costume.jumpSpeed / 2
    if self.speedY < -minJumpSpeed then
        self.speedY = -minJumpSpeed
    end
end

function Character:hit(power)
    local minJumpSpeed = self.costume.jumpSpeed / 2
    self.hp = self.hp - (self.costume.damageCoeff * power)
end

function Character:updateDrawInfo()
    self.entity:updateDrawInfo()
end

