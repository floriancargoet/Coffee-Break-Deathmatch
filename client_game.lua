require 'lib/middleclass'
require 'lib/middleclass-commons'
require 'lib/LUBE'
require 'lib/Tserial'
require 'game'
require 'costume'
require 'lan_player'

local camera = require 'lib/camera'

global.ClientGame = class('ClientGame', Game)

local port = 10000

-- Executed at startup
function ClientGame:initialize()
    self.keys = {}

    self:loadLevel(level)

    self.player = self:createPlayer('host')
    --self.player.character = self:spawnCharacter()

    self.hud = HUD({
        fps = true
    })

    self.synchronized = false
    self.lastUpdateTime = os.clock()

    self:startClient()
end

function ClientGame:createLANPlayer(id)
    local player = LANPlayer(id, self.client)

    self.players[id] = player

    return player

end

function ClientGame:startClient()

    print('Client connecting on port ' .. port)

    self.client = lube.udpClient()
    self.client.callbacks.recv = ClientGame.parseMessage

    self.client.handshake = 'Hellooo'
    self.client:setPing(true, 1, 'PING')

    self.client:connect('localhost', port)

end

function ClientGame.parseMessage(data)
    local message = TSerial.unpack(data)
    if (message.type == 'gamestate') then
        local state = message
        if (game.lastUpdateTime > state.time) then
            return
        end
        game.lastUpdate = state
        game.lastUpdateTime = state.time
    end
    if (message.type == 'playerid') then
        game.playerId = message.id
    end
end

function ClientGame:updateGameState()

    local state = self.lastUpdate
    if not state then
        return
    end

    if not self.synchronized then
        self:loadLevel(level)
    end

    for id, playerState in pairs(state.players) do
        local player = self.players[id]
        if not player then
            player = self:createLANPlayer(id)
        end
        if playerState.character then
            if not player:isSpawned() then
                player.character = self:spawnCharacter()
            end
            player.character.x = playerState.character.x
            player.character.y = playerState.character.y
            player.character.hp = playerState.character.hp
            player.character.entity.x = playerState.character.x
            player.character.entity.y = playerState.character.y
            player.character.speedX = playerState.character.speedX
            player.character.speedY = playerState.character.speedY
            player.character.costume = Costume.registry[playerState.character.costume]()
            if not playerState.character.costumeTime then
                player.character.costume.ttl = math.huge
            else
                player.character.costume.ttl = playerState.character.costumeTime
            end
        end
    end
    self.timedObjects = {}
    for id, objState in pairs(state.timedObjects) do
        local obj = {}
        if (objState.type == 'explosion') then
            obj = Explosion:new(self.players[objState.ownerId], objState.x, objState.y)
        end
        if (objState.type == 'projectile') then
            obj = Projectile:new(self.players[objState.ownerId], objState.x, objState.y, 0, 0)
        end
        table.insert(self.timedObjects, obj)
    end

    -- We clear all objects
    self.map.ol['Items'].objects = {}

    for id, itemState in pairs(state.items) do
        local itemEntity = self.map.ol['Items']:newObject('item', 'Entity', itemState.x, itemState.y, 32, 32)
        local item = Item.registry[itemState.itemType](itemEntity)
        itemEntity.refObject = item
    end

    self.player = self.players[game.playerId]
    self.synchronized = true

end

function ClientGame:update(dt)

    Game.update(self, dt)

    self.client:update(dt)
    self:updateGameState()

    -- The gamestate could have changed, we should change how that works because it has already been done in Game.update()
    self:updateCamera()
    self.player:updateCrosshair(self.mainCamera:mousepos().x, self.mainCamera:mousepos().y)
    if self.player:isSpawned() then
        self.hud:update({
            hp          = self.player.character.hp,
            costume_ttl = self.player.character.costume.ttl
        })
    end

end

function ClientGame:draw()

    Game.draw(self)

    if not self.synchronized then
        love.graphics.print('Waiting for server...', love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    end
end
