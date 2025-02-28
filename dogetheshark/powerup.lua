local PowerUp = {}
PowerUp.__index = PowerUp

function PowerUp.new(x, y, radius, speed)
    local self = setmetatable({}, PowerUp)
    self.x = x
    self.y = y
    self.radius = radius
    self.speed = speed
    return self
end

function PowerUp:update(dt, scoreMultiplier)
    local blockSpeedMultiplier = 1 + 0.5 * (scoreMultiplier - 1)
    self.y = self.y + self.speed * dt * blockSpeedMultiplier
end

function PowerUp:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

return PowerUp
