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

local game = require 'game'

-- Executed at startup
function love.load()
    game.load()
end

-- Executed each step
function love.update(dt)
    game.update(dt)
end

function love.keypressed(key)
	if love.keyboard.isDown('escape') then
		os.exit(0)
	end
    game.keypressed(key)
end

function love.keyreleased(key)
    game.keyreleased(key)
end

function love.mousepressed(x, y, button)
    game.mousepressed(x, y, button)
end

-- Drawing operations
function love.draw()
    game.draw()
end
