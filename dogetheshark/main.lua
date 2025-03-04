local GameManager = require("gameManager")
local manager

function love.load()
  manager = GameManager.new()
end

function love.update(dt)
  manager:update(dt)
end

function love.draw()
  manager:draw()
end

function love.mousepressed(x, y, button)
  manager:mousepressed(x, y, button)
end

function love.keypressed(key)
  manager:keypressed(key)
end
