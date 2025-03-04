local Assets = {}
Assets.__index = Assets

function Assets.new()
    local self = setmetatable({}, Assets)
    self.images = {}
    self.sounds = {}
    return self
end

function Assets:loadImage(key, path)
    self.images[key] = love.graphics.newImage(path)
end

function Assets:getImage(key)
    return self.images[key]
end

function Assets:loadSound(key, path, mode)
    self.sounds[key] = love.audio.newSource(path, mode or "static")
end

function Assets:getSound(key)
    return self.sounds[key]
end

function Assets:loadAll()
    -- Images
    self:loadImage("player", "assets/player2.png")
    self:loadImage("block1", "assets/shark1.png")
    -- Sounds
    self:loadSound("booster", "assets/ting.wav")
    self:loadSound("bgmusic", "assets/bgmusic.wav")
    self:loadSound("endsound", "assets/endgame.wav")
end

return Assets
