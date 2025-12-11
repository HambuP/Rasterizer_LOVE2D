local W, H = 320, 180
local imgData, img

local function clamp(x, a, b)
  if x < a then return a elseif x > b then return b else return x end
end

local function edge(x0,y0, x1,y1, x,y)
  return (x - x0)*(y1 - y0) - (y - y0)*(x1 - x0)
end

local function fill_triangle2D(imgData, W, H, p1, p2, p3, color)
  local x1,y1 = p1[1], p1[2]
  local x2,y2 = p2[1], p2[2]
  local x3,y3 = p3[1], p3[2]
  local r,g,b,a = color[1], color[2], color[3], color[4] or 1

  -- área orientada
  local A = edge(x1,y1, x2,y2, x3,y3)
  if A == 0 then return end
  local invA = 1.0 / A

  -- bounding box
  local minx = clamp(math.floor(math.min(x1,x2,x3)), 0, W-1)
  local maxx = clamp(math.floor(math.max(x1,x2,x3)), 0, W-1)
  local miny = clamp(math.floor(math.min(y1,y2,y3)), 0, H-1)
  local maxy = clamp(math.floor(math.max(y1,y2,y3)), 0, H-1)

  -- recorre píxeles (usa centro del píxel)
  for y = miny, maxy do
    for x = minx, maxx do
      local px, py = x + 0.5, y + 0.5
      local w1 = edge(x2,y2, x3,y3, px,py) * invA
      local w2 = edge(x3,y3, x1,y1, px,py) * invA
      local w3 = 1.0 - w1 - w2

      if w1>=0 and w2>=0 and w3>=0 then
        imgData:setPixel(x, y, r, g, b, a)
      end
    end
  end
end

function love.load()
  love.window.setTitle("Triángulo 2D - Rasterizer básico")
  imgData = love.image.newImageData(W, H)
  img     = love.graphics.newImage(imgData)
  img:setFilter("nearest","nearest")

  -- limpia a negro
  imgData:mapPixel(function() return 0,0,0,1 end)

  -- triángulo de ejemplo (en coordenadas de pantalla)
  local p1 = { 40,  30 }
  local p2 = { 280, 50 }
  local p3 = { 120, 150 }

  fill_triangle2D(imgData, W, H, p1, p2, p3, {1, 0.6, 0.1, 1})
  img:replacePixels(imgData)
end

function love.draw()
  -- escalar para llenar ventana
  local winW, winH = love.graphics.getDimensions()
  --love.graphics.setColor(1,1,1,1)
  love.graphics.draw(img, 0, 0, 0, winW/W, winH/H)
end
