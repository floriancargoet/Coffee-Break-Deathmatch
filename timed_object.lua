require 'lib/middleclass'

global.TimedObject = class('TimedObject')

function TimedObject:initialize(x, y, ttl)
    self.x = x
    self.y = y
    self.alive = true
    self.ttl = ttl
end

function TimedObject:update(dt, tiles)
    if self.ttl then
        self.ttl = self.ttl - (1 * dt)
        if self.ttl < 0 then
            self.alive = false
        end
    end
end

function TimedObject:kill(dt, tiles)

end
