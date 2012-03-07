love = {}
love.filesystem = {}
function love.filesystem.read(path)
    local f = assert(io.open(path, "r"))
    local t = f:read("*all")
    f:close()
    return t
end
love.graphics = {}
love.graphics.newImage = function() end

TILED_LOADER_PATH = 'lib/AdvTiledLoader/'
ATL = require 'lib/AdvTiledLoader/init'
ATL.Loader.path = "levels/"
require 'lib/middleclass'

-- We don't want to read the tileset so we override processMap
function ATL.Loader._processMap(name, t)
	
	-- Do some checking
	ATL.Loader._checkXML(t)
	assert(t.label == "map", "Loader._processMap - Passed table is not a map")
	assert(t.xarg.width, t.xarg.height, t.xarg.tilewidth, t.xarg.tileheight,
		   "Loader._processMap - Map data is corrupt")

	-- We'll use these for temporary storage
	local map, tileset, tilelayer, objectlayer
	
	-- Create the map from the settings
	local map = ATL.Map:new(name, tonumber(t.xarg.width),tonumber(t.xarg.height), 
						tonumber(t.xarg.tilewidth), tonumber(t.xarg.tileheight), 
						t.xarg.orientation)
							
	-- Now we fill it with the content
	for _, v in ipairs(t) do

		-- Process TileLayer
		if v.label == "layer" then
			tilelayer = ATL.Loader._processTileLayer(v, map)
			map.tl[tilelayer.name] = tilelayer
			map.drawList[#map.drawList + 1] = tilelayer
		end
		
		-- Process ObjectLayer
		if v.label == "objectgroup" then
			objectlayer = ATL.Loader._processObjectLayer(v, map)
			map.ol[objectlayer.name] = objectlayer
			map.drawList[#map.drawList + 1] = objectlayer
		end
		
		-- Process Map properties
		if v.label == "properties" then
			map.properties = ATL.Loader._processProperties(v)
		end
			
	end
	
	-- Return our map
	return map
end


-- Prevent from using globals
global = {}
setmetatable(global, {__newindex = function(t, k, v) rawset(_G, k, v) end})
--

local clock = os.clock
function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end

prevTime = clock()
currTime = clock()

require 'game'
require 'server_game'
require 'client_game'

Player.updateCrosshair = function() end

local HeadlessGame = class('HeadlessGame', ServerGame)

function HeadlessGame:initialize()
    self.keys = {}

    self:loadLevel('test')

    self.player = self:spawnPlayer('host')
    self.player.x = -60000

    self:startServer()
end

function HeadlessGame:loadLevel(name)
    self.map = ATL.Loader.load(name .. '.tmx')
    self.timedObjects = {}
    self.players = {}
    self.mainCamera = {}
    self.mainCamera.mousepos = function() return {x=0,y=0} end
end

global.game = HeadlessGame()
while(true) do
    prevTime = currTime
    currTime = clock()
    dt = (currTime - prevTime)
    game:update(dt)
    sleep(1/1000)
end
