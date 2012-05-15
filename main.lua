TILED_LOADER_PATH = 'lib/AdvTiledLoader/'
ATL = require 'lib/AdvTiledLoader'
ATL.Loader.path = "levels/"
require 'lib/middleclass'

-- Prevent from using globals
global = {}
setmetatable(global, {__newindex = function(t, k, v) rawset(_G, k, v) end})
setmetatable(_G, {__newindex = function(t,k,v)
    local info = debug.getinfo(2, 'Sl')
    -- We substring because love 0.8.0 adds an @ before the filename
    print(string.format('%s:%d:  Global found "%s"', info.source:sub(2), info.currentline, k))
    rawset(_G,k,v)
end})
--

require 'game'
require 'server_game'
require 'client_game'

local lan = false
local levels = {
	'test'
}
global.level = levels[1]

-- Executed at startup
function love.load()
    math.randomseed(os.time())
    global.game = Game()
    love.mouse.setVisible(false)
    --love.mouse.setGrab(true)
    -- please don't smooth the lines!
    love.graphics.setLineStyle('rough')
end

-- Executed each step
function love.update(dt)
    game:update(dt)
end

function love.keypressed(key)
    if love.keyboard.isDown('escape') then
        os.exit(0)
    end
    if love.keyboard.isDown('h') then
        if not lan then
            lan = true
            global.game = ServerGame()
        end
    end
    if love.keyboard.isDown('c') then
        if not lan then
            lan = true
            global.game = ClientGame()
        end
    end
    game:keypressed(key)
end

function love.keyreleased(key)
    game:keyreleased(key)
end

function love.mousepressed(x, y, button)
    game:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    game:mousereleased(x, y, button)
end

-- Drawing operations
function love.draw()
    game:draw()

    love.graphics.setBackgroundColor(50, 50, 50)
end
