local game = {}

-- Executed at startup
function game.load()
    game.map = ATL.Loader.load('levels/test.tmx')
end

-- Executed each step
function game.update(dt)

end

function game.keypressed(key)

end

function game.keyreleased(key)

end

function game.mousepressed(x, y, button)

end

-- Drawing operations
function game.draw()
    game.map:draw()
end

return game
