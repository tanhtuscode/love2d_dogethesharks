local Player = require("player")
local Block = require("block")
local PowerUp = require("powerup")
local Assets = require("assetmanager")
local DataManager = require("dataManager")
local DeathEffect = require("deathEffect")

local Game = {}
Game.__index = Game

-- Helper collision function
local function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 and
         x2 < x1 + w1 and
         y1 < y2 + h2 and
         y2 < y1 + h1
end

function Game.new()
  local self = setmetatable({}, Game)
  self.windowWidth = love.graphics.getWidth()
  self.windowHeight = love.graphics.getHeight()
  self.font = love.graphics.newFont(20)
  love.graphics.setFont(self.font)
  
  -- Initialize asset manager and load assets
  self.assets = Assets.new()
  self.assets:loadAll()  -- Must load "player", "booster", "bgmusic", "endsound", and "block1" for death effect
  
  self.score = 0
  self.scoreMultiplier = 1
  self.multiplierTimer = 0
  self.multiplierDuration = 10
  
  self.spawnInterval = 0.9
  self.blockTimer = 0
  self.blocks = {}
  
  self.powerUpSpawnInterval = 5
  self.powerUpSpawnTimer = 0
  self.powerUp = nil

  -- Create player using the asset manager (key "player")
  local playerSprite = self.assets:getImage("player")
  self.player = Player.new((self.windowWidth - 50) / 2, self.windowHeight - 20 - 10, 50, 20, 300, playerSprite)
  
  self.retryButton = { x = (self.windowWidth - 150) / 2, y = self.windowHeight / 2 + 40, width = 150, height = 50 }
  self.gameOver = false
  
  -- Load sounds from assets
  self.boosterSound = self.assets:getSound("booster")
  self.boosterSound:setLooping(false)
  
  self.bgMusic = self.assets:getSound("bgmusic")
  self.bgMusic:setLooping(true)
  love.audio.play(self.bgMusic)
  
  self.endsound = self.assets:getSound("endsound")
  self.endsound:setLooping(false)
  self.endSoundPlayed = false
  
  -- Death effect is created when the player dies
  self.deathEffect = nil
  
  -- Load high score
  self.highScore = DataManager.loadHighScore()
  
  return self
end

function Game:reset()
  self.player.x = (self.windowWidth - self.player.width) / 2
  self.player.y = self.windowHeight - self.player.height - 10
  self.blocks = {}
  self.blockTimer = 0
  self.powerUp = nil
  self.powerUpSpawnTimer = 0
  self.score = 0
  self.scoreMultiplier = 1
  self.multiplierTimer = 0
  self.spawnInterval = 0.9
  self.powerUpSpawnInterval = 5
  self.gameOver = false
  self.endSoundPlayed = false
  self.deathEffect = nil
  if not self.bgMusic:isPlaying() then
    love.audio.play(self.bgMusic)
  end
end

function Game:triggerDeathEffect()
  -- Create death effect at the center of the player.
  local particleImage = self.assets:getImage("block1")
  local x = self.player.x + self.player.width / 2
  local y = self.player.y + self.player.height / 2
  self.deathEffect = DeathEffect.new(x, y)
end

function Game:update(dt)
  if self.gameOver then
    if self.deathEffect then
      self.deathEffect:update(dt)
    end
    return
  end
  
  -- Update score
  self.score = self.score + dt * self.scoreMultiplier
  
  -- Update multiplier timer
  if self.multiplierTimer > 0 then
    self.multiplierTimer = self.multiplierTimer - dt
    if self.multiplierTimer <= 0 then
      self.scoreMultiplier = 1
    end
  end
  
  self.player.speed = 300 * (1 + 0.1 * math.floor(self.score / 50))
  self.player:update(dt, self.windowWidth)
  
  self.blockTimer = self.blockTimer + dt
  if self.blockTimer >= self.spawnInterval then
    self.blockTimer = 0
    local width = math.random(20, 70)
    local height = math.random(20, 70)
    local x = math.random(0, self.windowWidth - width)
    local y = -height
    local speed = math.random(150, 300)
    local block = Block.new(x, y, width, height, speed)
    table.insert(self.blocks, block)
  end
  
  for _, block in ipairs(self.blocks) do
    block:update(dt, self.scoreMultiplier)
  end
  
  for i = #self.blocks, 1, -1 do
    if self.blocks[i].y > self.windowHeight then
      table.remove(self.blocks, i)
    end
  end
  
  for _, block in ipairs(self.blocks) do
    if checkCollision(self.player.x, self.player.y, self.player.width, self.player.height,
                      block.x, block.y, block.width, block.height) then
      self.gameOver = true
      if not self.deathEffect then
        self:triggerDeathEffect()
      end
      if self.score > self.highScore then
        self.highScore = self.score
        DataManager.saveHighScore(self.highScore)
      end
      break
    end
  end
  
  self.powerUpSpawnTimer = self.powerUpSpawnTimer + dt
  if not self.powerUp and self.powerUpSpawnTimer >= self.powerUpSpawnInterval then
    self.powerUpSpawnTimer = 0
    local x = math.random(15, self.windowWidth - 15)
    self.powerUp = PowerUp.new(x, -15, 15, math.random(150, 300))
  end
  
  if self.powerUp then
    self.powerUp:update(dt, self.scoreMultiplier)
    if self.powerUp.y - self.powerUp.radius > self.windowHeight then
      self.powerUp = nil
    elseif checkCollision(self.player.x, self.player.y, self.player.width, self.player.height,
                          self.powerUp.x - self.powerUp.radius, self.powerUp.y - self.powerUp.radius,
                          self.powerUp.radius * 2, self.powerUp.radius * 2) then
      self.scoreMultiplier = self.scoreMultiplier * 2
      self.multiplierTimer = self.multiplierDuration
      self.spawnInterval = math.max(self.spawnInterval - 0.1, 0.2)
      self.powerUpSpawnInterval = math.max(self.powerUpSpawnInterval - 0.1, 1)
      love.audio.play(self.boosterSound)
      self.powerUp = nil
    end
  end
  
  if self.bgMusic then
    self.bgMusic:setPitch(1 + (self.scoreMultiplier - 1) * 2)
  end
end

function Game:draw()
  love.graphics.clear(3/255, 161/255, 252/255)
  
  -- If game is not over, draw the player. Otherwise, let the death effect take over.
  if not self.gameOver then
    self.player:draw()
  end
  
  for _, block in ipairs(self.blocks) do
    block:draw(self.scoreMultiplier)
  end
  
  if self.powerUp then
    self.powerUp:draw()
  end
  
  -- Draw death effect only when game is over
  if self.gameOver and self.deathEffect then
    self.deathEffect:draw()
  end
  
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Score: " .. math.floor(self.score), 10, 10)
  love.graphics.print("Multiplier: x" .. self.scoreMultiplier, 10, 40)
  
  local timerText = "Timer: " .. math.ceil(self.multiplierTimer)
  local timerWidth = self.font:getWidth(timerText)
  love.graphics.print(timerText, self.windowWidth - timerWidth - 10, 10)
  
  if self.gameOver then
    love.audio.stop(self.bgMusic)
    if not self.endSoundPlayed then
      love.audio.play(self.endsound)
      self.endSoundPlayed = true
    end
    love.graphics.printf("Game Over!", 0, self.windowHeight / 2 - 20, self.windowWidth, "center")
    love.graphics.print("High Score: " .. math.floor(self.highScore), 10, 60)
    love.graphics.setColor(0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", self.retryButton.x, self.retryButton.y, self.retryButton.width, self.retryButton.height)
    love.graphics.setColor(1, 1, 1)
    local btnText = "Retry"
    local btnTextWidth = self.font:getWidth(btnText)
    local btnTextHeight = self.font:getHeight(btnText)
    love.graphics.print(btnText, self.retryButton.x + (self.retryButton.width - btnTextWidth) / 2, 
                             self.retryButton.y + (self.retryButton.height - btnTextHeight) / 2)
  end
end

function Game:mousepressed(x, y, button)
  if self.gameOver and button == 1 then
    if x >= self.retryButton.x and x <= self.retryButton.x + self.retryButton.width and
       y >= self.retryButton.y and y <= self.retryButton.y + self.retryButton.height then
      self:reset()
    end
  end
end

return Game
