local Player = require("player")
local Block = require("block")
local PowerUp = require("powerup")

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

    -- Load the player sprite from the assets folder.
    local playerSprite = love.graphics.newImage("assets/player2.png")
    self.player = Player.new((self.windowWidth - 50) / 2, self.windowHeight - 20 - 10, 50, 20, 300, playerSprite)
    
    self.retryButton = { x = (self.windowWidth - 150) / 2, y = self.windowHeight / 2 + 40, width = 150, height = 50 }
    self.gameOver = false

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
end

function Game:update(dt)
    if self.gameOver then return end
    
    -- Update score
    self.score = self.score + dt * self.scoreMultiplier
    
    -- Update multiplier timer
    if self.multiplierTimer > 0 then
        self.multiplierTimer = self.multiplierTimer - dt
        if self.multiplierTimer <= 0 then
            self.scoreMultiplier = 1
        end
    end
    
    -- Increase player's speed based on score (10% increase for every 50 points)
    self.player.speed = 300 * (2 + 0.1 * math.floor(self.score / 10))
    self.player:update(dt, self.windowWidth)
    
    -- Spawn blocks
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
    
    -- Check collision: player and blocks
    for _, block in ipairs(self.blocks) do
        if checkCollision(self.player.x, self.player.y, self.player.width, self.player.height,
                          block.x, block.y, block.width, block.height) then
            self.gameOver = true
        end
    end
    
    -- Power-up spawning
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
            self.scoreMultiplier = self.scoreMultiplier * 2  -- Stack multiplier (x2 each time)
            self.multiplierTimer = self.multiplierDuration      -- Reset timer to full duration
            self.spawnInterval = math.max(self.spawnInterval - 0.1, 0.2)
            self.powerUpSpawnInterval = math.max(self.powerUpSpawnInterval - 0.1, 1)
            self.powerUp = nil
        end
    end
end

function Game:draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    
    self.player:draw()
    
    for _, block in ipairs(self.blocks) do
        block:draw(self.scoreMultiplier)
    end
    
    if self.powerUp then
        self.powerUp:draw()
    end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. math.floor(self.score), 10, 10)
    love.graphics.print("Multiplier: x" .. self.scoreMultiplier, 10, 40)
    
    local timerText = "Timer: " .. math.ceil(self.multiplierTimer)
    local timerWidth = self.font:getWidth(timerText)
    love.graphics.print(timerText, self.windowWidth - timerWidth - 10, 10)
    
    if self.gameOver then
        love.graphics.printf("Game Over!", 0, self.windowHeight / 2 - 20, self.windowWidth, "center")
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
