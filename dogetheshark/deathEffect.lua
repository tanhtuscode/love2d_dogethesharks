local DeathEffect = {}
DeathEffect.__index = DeathEffect

-- Create a new death effect at (x, y) with an explosive pixel art style.
function DeathEffect.new(x, y)
  local self = setmetatable({}, DeathEffect)
  
  -- Create a 4x4 canvas for a crisp pixel particle.
  local particleImage = love.graphics.newCanvas(4, 4)
  love.graphics.setCanvas(particleImage)
  love.graphics.clear(1, 1, 1, 1) -- White pixel
  love.graphics.setCanvas()
  
  self.ps = love.graphics.newParticleSystem(particleImage, 500)
  self.ps:setParticleLifetime(0.5, 1.2)
  self.ps:setEmissionRate(0)
  self.ps:setSizeVariation(1)
  self.ps:setLinearAcceleration(-200, -200, 200, 200)
  self.ps:setColors(
      1, 0.5, 0, 1,    -- Orange, opaque
      1, 0.2, 0, 0.8,  -- Red-orange, slightly transparent
      0.6, 0.1, 0, 0.5, -- Darker red, more transparent
      0.1, 0.1, 0.1, 0  -- Fades to black, transparent
  )
  
  self.ps:emit(100)
  
  -- Ensure x and y are numbers.
  self.x = tonumber(x) or 0
  self.y = tonumber(y) or 0
  
  return self
end

function DeathEffect:update(dt)
  self.ps:update(dt)
end

function DeathEffect:draw()
  love.graphics.draw(self.ps, self.x, self.y)
end

return DeathEffect
