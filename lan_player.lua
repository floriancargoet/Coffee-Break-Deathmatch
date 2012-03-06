require 'player'

global.LANPlayer = class('LANPlayer', Player)

function LANPlayer:initialize(id, entity, client)
    Player.initialize(self, id, entity)
    self.client = client
end

function LANPlayer:updatePhysics(dt, tiles)

end

function LANPlayer:moveLeft()
    self.client:send('moveLeft')
end

function LANPlayer:moveRight()
    self.client:send('moveRight')
end

function LANPlayer:stopMoving()
    self.client:send('stopMoving')
end

function LANPlayer:jump()
    self.client:send('jump')
end

function LANPlayer:stopJump()
    self.client:send('stopJump')
end
