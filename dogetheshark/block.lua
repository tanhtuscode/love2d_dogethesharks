local Block = {}
Block.__index = Block

-- Load the block sprites.
-- It’s best to load these once and reuse them.
local blockSprites = {
    love.graphics.newImage("assets/shark1.png"),
    love.graphics.newImage("assets/shark1.png"),
    love.graphics.newImage("assets/shark1.png"),
    love.graphics.newImage("assets/shark1.png")
}

-- Create a new Block.
-- x, y: starting position
-- width, height: desired dimensions (for drawing/scaling)
-- speed: falling speed
function Block.new(x, y, width, height, speed)
    local self = setmetatable({}, Block)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.speed = speed
    -- Pick a random sprite from the four available.
    self.sprite = blockSprites[math.random(1, #blockSprites)]
    return self
end

function Block:update(dt, scoreMultiplier)
    local blockSpeedMultiplier = 1 + 0.5 * (scoreMultiplier - 1)
    self.y = self.y + self.speed * dt * blockSpeedMultiplier
end

function Block:draw(scoreMultiplier)
    -- Optional: if you want a trail effect when multiplier is active, you can draw it here.
    -- For now, we simply draw the sprite.
    love.graphics.setColor(1, 1, 1, 1)
    -- Scale the sprite to match the desired width and height.
    local scaleX = self.width / self.sprite:getWidth()
    local scaleY = self.height / self.sprite:getHeight()
    love.graphics.draw(self.sprite, self.x, self.y, 0, scaleX, scaleY)
end

return Block
