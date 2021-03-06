require 'lib/middleclass'
require 'lib/middleclass-commons'
require 'lib/LUBE'
require 'lib/Tserial'
require 'game'

local camera = require 'lib/camera'

global.ServerGame = class('ServerGame', Game)

local port = 10000

-- Executed at startup
function ServerGame:initialize()
    self.keys = {}

    self:loadLevel(level)

    self.player = self:createPlayer('host')
    --self.player.character = self:spawnCharacter()

    self.hud = HUD({
        fps = true
    })

    self:startServer()
end

function ServerGame:startServer()

    print('Server listening on port ' .. port)

    self.server = lube.udpServer()
    self.server.callbacks.recv = ServerGame.parseMessage
    self.server.callbacks.connect = ServerGame.playerConnect
    self.server.callbacks.disconnect = ServerGame.playerDisconnect

    self.server.handshake = 'Hellooo'
    self.server:setPing(true, 5, 'PING')

    self.server:listen(port)

    self.dtState = 0

end

function ServerGame.playerConnect(id)
    game.server:send(TSerial.pack({type = 'playerid', id = id}), id)
    local newPlayer = game:createPlayer(id)
    newPlayer.character = game:spawnCharacter()
end

function ServerGame.playerDisconnect(id)
    game:killPlayer(id)
end

function ServerGame.parseMessage(data, id)
    local message = TSerial.unpack(data)
    if (message.action == 'jump') then
        game.players[id]:jump()
    end
    if (message.action == 'stopJump') then
        game.players[id]:stopJump()
    end
    if (message.action == 'moveLeft') then
        game.players[id]:moveLeft()
    end
    if (message.action == 'moveRight') then
        game.players[id]:moveRight()
    end
    if (message.action == 'stopMoving') then
        game.players[id]:stopMoving()
    end
    if (message.action == 'shoot') then
        game.players[id]:shoot(message.targetX, message.targetY, message.dispersion)
    end
end

function ServerGame:sendGameState()
    local state = {}
    state.type = 'gamestate'
    state.players = {}
    state.time = os.clock()
    for id, player in pairs(self.players) do
        state.players[id] = {}
        if player:isSpawned() then
            local character = {
                x = player.character.x,
                y = player.character.y,
                hp = player.character.hp,
                speedX = player.character.speedX,
                speedY = player.character.speedY,
                costume = player.character.costume.name,
                costumeTime = player.character.costume.ttl       
            }
            if player.character.costume.ttl == math.huge then
                character.costumeTime = nil
            end
            
            state.players[id].character = character
        end
    end
    state.timedObjects = {}
    for id, obj in pairs(self.timedObjects) do
        state.timedObjects[id] = {
            x = obj.x,
            y = obj.y,
            ownerId = obj.owner.id
        }
        if instanceOf(Explosion, obj) then
            state.timedObjects[id].type = 'explosion'
        end
        if instanceOf(Projectile, obj) then
            state.timedObjects[id].type = 'projectile'
        end
    end
    state.items = {}
    for id, itemObj in pairs(self.map.ol['Items'].objects) do
        local item = itemObj.refObject
        state.items[id] = {
            x = itemObj.x,
            y = itemObj.y,
            itemType = item.name
        }
    end

    self.server:send(TSerial.pack(state))
end

function ServerGame:update(dt)
    self.server:update(dt)

    Game.update(self, dt)

    self.dtState = self.dtState + dt

    if self.dtState >= 1/100 then
        self:sendGameState()
        self.dtState = 0
    end

end
