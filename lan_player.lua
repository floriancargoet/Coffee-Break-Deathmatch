require 'player'

global.LANPlayer = class('LANPlayer', Player)

function LANPlayer:initialize(id, entity, client)
    Player.initialize(self, id, entity)
    self.client = client
end

function LANPlayer:updatePhysics(dt, tiles)

end

function LANPlayer:moveLeft()
    local msg = {}
    msg.action = 'moveLeft'
    self.client:send(TSerial.pack(msg))
end

function LANPlayer:moveRight()
    local msg = {}
    msg.action = 'moveRight'
    self.client:send(TSerial.pack(msg))
end

function LANPlayer:stopMoving()
    local msg = {}
    msg.action = 'stopMoving'
    self.client:send(TSerial.pack(msg))
end

function LANPlayer:jump()
    local msg = {}
    msg.action = 'jump'
    self.client:send(TSerial.pack(msg))
end

function LANPlayer:stopJump()
    local msg = {}
    msg.action = 'stopJump'
    self.client:send(TSerial.pack(msg))
end

function LANPlayer:shoot(targetX, targetY, dispersion)
    local msg = {}
    msg.action = 'shoot'
    msg.targetX = targetX
    msg.targetY = targetY
    -- Means that it's possible to cheat by modifying this value to change max dispersion
    msg.dispersion = dispersion or (self.crosshairDispersion * 2)
    self.client:send(TSerial.pack(msg))
end
