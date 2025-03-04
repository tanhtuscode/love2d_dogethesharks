local DataManager = {}
DataManager.__index = DataManager

local json = require("json")

function DataManager.loadHighScore()
    if love.filesystem.getInfo("score.json") then
        local contents = love.filesystem.read("score.json")
        local data = json.decode(contents)
        if data and data.highScore then
            return data.highScore
        end
    end
    return 0
end

function DataManager.saveHighScore(score)
    local data = { highScore = score }
    local encoded = json.encode(data)
    love.filesystem.write("score.json", encoded)
end

return DataManager
