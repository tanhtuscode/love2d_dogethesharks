local Game = require("game")

local GameManager = {}
GameManager.__index = GameManager

function GameManager.new()
  local self = setmetatable({}, GameManager)
  self.state = "menu"  -- States: "menu", "game", "gameover"
  self.game = nil
  return self
end

-- Called when the player chooses to start a game.
function GameManager:startGame()
  self.game = Game.new()
  self.state = "game"
end

function GameManager:update(dt)
  if self.state == "game" then
    self.game:update(dt)
    if self.game.gameOver then
      self.state = "gameover"
    end
  end
end

function GameManager:draw()
  if self.state == "menu" then
    love.graphics.clear(0.2, 0.2, 0.2) -- Dark gray background for menu
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Main Menu", 0, 100, love.graphics.getWidth(), "center")
    love.graphics.printf("Click anywhere to Start", 0, 150, love.graphics.getWidth(), "center")
  elseif self.state == "game" then
    self.game:draw()
  elseif self.state == "gameover" then
    self.game:draw()  -- Draw the final game state (with death effect, etc.)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Game Over! Press R to return to Menu", 0, love.graphics.getHeight()-50, love.graphics.getWidth(), "center")
  end
end

function GameManager:mousepressed(x, y, button)
  if self.state == "menu" and button == 1 then
    self:startGame()
  elseif self.state == "game" then
    self.game:mousepressed(x, y, button)
  end
end

function GameManager:keypressed(key)
  if self.state == "gameover" and key == "r" then
    -- Return to menu: stop any game sounds and clear the game instance
    if self.game and self.game.bgMusic then
      love.audio.stop(self.game.bgMusic)
    end
    self.state = "menu"
    self.game = nil
  end
end

return GameManager
