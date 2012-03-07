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

    self:loadLevel('test')

    self.player = self:spawnPlayer('host')

    self.mainCamera = camera()
    self.mainCamera.limit_x = self.map.tileWidth*self.map.width
    self.mainCamera.limit_y = self.map.tileHeight*self.map.height

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

end

function ServerGame.playerConnect(id)
    game.server:send(TSerial.pack({type = 'playerid', id = id}), id)
    game:spawnPlayer(id)
end

function ServerGame.playerDisconnect(id)
    game:killPlayer(id)
end

function ServerGame.parseMessage(data, id)
    if (data == 'getId') then
        game.server:send(TSerial.pack({type = 'playerid', id = id}), id)
    end
    if (data == 'jump') then
        game.players[id]:jump()
    end
    if (data == 'stopJump') then
        game.players[id]:stopJump()
    end
    if (data == 'moveLeft') then
        game.players[id]:moveLeft()
    end
    if (data == 'moveRight') then
        game.players[id]:moveRight()
    end
    if (data == 'stopMoving') then
        game.players[id]:stopMoving()
    end
end

function ServerGame:sendGameState()
    local state = {}
    state.type = 'gamestate'
    state.players = {}
    state.time = os.clock()
    for id, player in pairs(self.players) do
        state.players[id] = {
            x = player.x,
            y = player.y,
            speedX = player.speedX,
            speedY = player.speedY,
            costume = player.costume.name,
            costumeTime = player.costume.ttl
        }
        if player.costume.ttl == math.huge then
            state.players[id].costumeTime = nil
        end
    end
    self.server:send(TSerial.pack(state))
end

function ServerGame:update(dt)
    self.server:update(dt)

    Game.update(self, dt)

    self:sendGameState()
end
