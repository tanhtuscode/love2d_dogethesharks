local Block = {}
Block.__index = Block

function Block.new(x, y, width, height, speed)
    local self = setmetatable({}, Block)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.speed = speed
    return self
end

function Block:update(dt, scoreMultiplier)
    local blockSpeedMultiplier = 1 + 0.5 * (scoreMultiplier - 1)
    self.y = self.y + self.speed * dt * blockSpeedMultiplier
end

function Block:draw(scoreMultiplier)
    if scoreMultiplier > 1 then
        love.graphics.setColor(1, 0, 0, 0.3)
        love.graphics.rectangle("fill", self.x, self.y - 10, self.width, self.height)
        love.graphics.rectangle("fill", self.x, self.y - 20, self.width, self.height)
    end
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

return Block
