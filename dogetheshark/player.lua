local Player = {}
Player.__index = Player

-- Creates a new Player.
-- x, y: starting position
-- width, height: dimensions
-- speed: movement speed
-- sprite: a LOVE2D image to represent the player
function Player.new(x, y, width, height, speed, sprite)
    local self = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.speed = speed
    self.sprite = sprite
    return self
end

function Player:update(dt, windowWidth)
    if love.keyboard.isDown("left") then
        self.x = self.x - self.speed * dt
    elseif love.keyboard.isDown("right") then
        self.x = self.x + self.speed * dt
    end
    if self.x < 0 then self.x = 0 end
    if self.x + self.width > windowWidth then
        self.x = windowWidth - self.width
    end
end

function Player:draw()
    love.graphics.draw(self.sprite, self.x, self.y)
end

return Player
