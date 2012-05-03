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

    self.player = self:spawnPlayer('host')
    self.playerId = 'host'

    self.synchronized = false
    self.lastUpdateTime = os.clock()

    self:startClient()
end

function ClientGame:spawnLANPlayer(id)
    local spawnIndex = math.random(#self.map.ol['Spawns'].objects)
    local spawnPoint = self.map.ol['Spawns'].objects[spawnIndex]
    local playerEntity = self.map.ol['Players']:newObject('player', 'Entity', spawnPoint.x, spawnPoint.y, 32, 64)
    local player = LANPlayer(id, playerEntity, self.client)

    playerEntity.refObject = player

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
            player = self:spawnLANPlayer(id)
        end
        player.x = playerState.x
        player.y = playerState.y
        player.hp = playerState.hp
        player.entity.x = playerState.x
        player.entity.y = playerState.y
        player.speedX = playerState.speedX
        player.speedY = playerState.speedY
        player.costume = Costume.registry[playerState.costume]()
        if not playerState.costumeTime then
            player.costume.ttl = math.huge
        else
            player.costume.ttl = playerState.costumeTime
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
end

function ClientGame:draw()

    Game.draw(self)

    if not self.synchronized then
        love.graphics.print('Waiting for server...', love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    end
end
