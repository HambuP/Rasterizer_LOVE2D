local love = require("love")

function love.conf(t)
    t.window.title = "3D Rasterizer"
    t.window.width = 1056
    t.window.height = 656
    t.console = true
    t.window.display = 2
end
