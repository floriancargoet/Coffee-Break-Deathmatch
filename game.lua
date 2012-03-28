require 'lib/middleclass'
require 'player'
require 'projectile'
require 'explosion'
require 'armor_item'
local camera = require 'lib/camera'

global.Game = class('Game')

-- Executed at startup
function Game:initialize()

    self.keys = {}

    self:loadLevel('test')

    self.player = self:spawnPlayer('host')

    self:spawnArmor()

end

function Game:loadLevel(name)
    self.map = ATL.Loader.load(name .. '.tmx')
    self.timedObjects = {}
    self.players = {}
    self.mainCamera = camera()
    self.mainCamera.limit_x = self.map.tileWidth*self.map.width
    self.mainCamera.limit_y = self.map.tileHeight*self.map.height
end

function Game:spawnPlayer(id)
    local spawnIndex = math.random(#self.map.ol['Spawns'].objects)
    local spawnPoint = self.map.ol['Spawns'].objects[spawnIndex]
    local playerEntity = self.map.ol['Players']:newObject('player', 'Entity', spawnPoint.x, spawnPoint.y, 32, 64)
    local player = Player(id, playerEntity)

    playerEntity.refObject = player

    self.players[id] = player

    if id == 'host' then
        self.player = player
    end

    return player
end

function Game:killPlayer(id)
    local toRemove = {}
    for i, playerEntity in ipairs(self.map.ol['Players'].objects) do
        if self.players[id] == playerEntity.refObject then
            table.insert(toRemove, i)
            break
        end
    end

    for i, object in ipairs(toRemove) do
        table.remove(self.map.ol['Players'].objects, object)
    end

    self.players[id] = nil
end

function Game:spawnArmor()
    local spawnIndex = math.random(#self.map.ol['Spawns'].objects)
    local spawnPoint = self.map.ol['Spawns'].objects[spawnIndex]
    local armorEntity = self.map.ol['Items']:newObject('item', 'Entity', spawnPoint.x, spawnPoint.y+32, 32, 32)
    local armor = ArmorItem:new(armorEntity)
    armorEntity.refObject = armor
end

function Game:createProjectile(owner, x, y, angle, speed)
    local projectile = Projectile:new(owner, x, y, angle, speed)
    table.insert(self.timedObjects, projectile)
end

function Game:createExplosion(owner, x, y)
    local explosion = Explosion:new(owner, x, y)
    table.insert(self.timedObjects, explosion)
end

function Game:checkForItems(player)
    local toRemove = {}
    for i, itemObj in ipairs(self.map.ol['Items'].objects) do
        local item = itemObj.refObject
        if player.x < item.x + item.w and player.x + player.w > item.x and player.y + 12 < item.y + item.h and player.y + player.h > item.y then
            item:applyEffect(player)
            table.insert(toRemove, i)
        end
    end

    for i, object in ipairs(toRemove) do
        table.remove(self.map.ol['Items'].objects, object)
    end
end

function Game:updateTimedObjects(dt, tiles, players)
    local toRemove = {}
    for i, object in ipairs(self.timedObjects) do
        object:update(dt, tiles, players)
        if not object.alive then
            table.insert(toRemove, i)
            object:kill()
        end
    end

    for i, object in ipairs(toRemove) do
        table.remove(self.timedObjects, object)
    end
end

-- Executed each step
function Game:update(dt)

    local tiles = self.map.tl['tiles'].tileData

    self:updateTimedObjects(dt, tiles, self.players)

    local myPlayer = self.player
    local k = self.keys

    if k.left or k.q then
        myPlayer:moveLeft()
    end
    if k.right or k.d then
        myPlayer:moveRight()
    end
    if not (k.left or k.right or k.q or k.d) then
        myPlayer:stopMoving()
    end
    
    if k.up then
        myPlayer:jump()
    end

    for id, p in pairs(self.players) do
        self:checkForItems(p)
        p:updatePhysics(dt, tiles)
        p:updateDrawInfo() -- for drawRange optimizations

        if (p.hp <= 0) then
            self:killPlayer(id)
            self:spawnPlayer(id)
        end
    end

    myPlayer:updateCrosshair(self.mainCamera:mousepos().x, self.mainCamera:mousepos().y)

end

function Game:keypressed(key)
    self.keys[key] = true
    if key == ' ' or key == 'z' then
        self.player:jump()
    end
    if key == 'a' then
        self:spawnArmor()
    end
end

function Game:keyreleased(key)
    self.keys[key] = false
    if key == ' ' or key == 'z' then
        self.player:stopJump()
    end
end

function Game:mousepressed(x, y, button)

    x, y = self.mainCamera:mousepos().x, self.mainCamera:mousepos().y

    local p = self.player
    if button == 'l' then
        p:shoot(x, y)
    end
    
    if button == 'r' then
        p:jump()
    end

    if button == 'wu' then
        self.mainCamera.zoom = self.mainCamera.zoom + 0.1
    end
    if button == 'wd' then
        self.mainCamera.zoom = self.mainCamera.zoom - 0.1
    end

end

function Game:mousereleased(x, y, button)
    if button == 'r' then
        self.player:stopJump()
    end
end

function Game:updateCamera()
    local cam = self.mainCamera

    local offsetX = self.player.x - cam.pos.x
    local offsetY = self.player.y - cam.pos.y

    -- We let a small zone in which we can move without moving the camera
    local cameraEyeX = 100
    local cameraEyeY = 50
    if (offsetX > cameraEyeX) then
        offsetX = offsetX - cameraEyeX
    elseif (offsetX < -cameraEyeX) then
        offsetX = offsetX + cameraEyeX
    else
        offsetX = 0
    end
    if (offsetY > cameraEyeY) then
        offsetY = offsetY - cameraEyeY
    elseif (offsetY < -cameraEyeY) then
        offsetY = offsetY + cameraEyeY
    else
        offsetY = 0
    end
    cam:move(offsetX, offsetY)

    local originX = cam:worldCoords(0,0).x
    local originY = cam:worldCoords(0,0).y

    if originX < 0 then
        cam.pos.x = cam.pos.x-originX
    end
    if originY < 0 then
        cam.pos.y = cam.pos.y-originY
    end
    if cam:worldCoords(love.graphics.getWidth(), love.graphics.getHeight()).x > cam.limit_x then
        cam.pos.x = cam.limit_x-(cam.pos.x-originX)
    end
    if cam:worldCoords(love.graphics.getWidth(), love.graphics.getHeight()).y > cam.limit_y then
        cam.pos.y = cam.limit_y-(cam.pos.y-originY)
    end

end

-- Drawing operations
function Game:draw()

    self:updateCamera()

    self.mainCamera:attach()
    self.map:draw()
    self.player:drawCrosshair()

    for i, object in ipairs(self.timedObjects) do
        object:draw()
    end

    self.mainCamera:detach()
    -- HUD
    if (self.player.hp <= 20) then
        local oldr, oldg, oldb, olda = love.graphics.getColor()
        love.graphics.setColor(255, 0, 0, olda)
        love.graphics.print('HP : ' .. self.player.hp, 0, 20)
        love.graphics.setColor(oldr, oldg, oldb, olda)
    else
        love.graphics.print('HP : ' .. self.player.hp, 0, 20)
    end
    love.graphics.print('Costume time left : ' .. math.ceil(self.player.costume.ttl) .. ' seconds', 0, 40)
end
