
local vec = require("vectors") --hola
local love = require("love")

package.path = package.path .. ";../?.lua;../?/init.lua;./?.lua;./?/init.lua"
local inspect = require("inspect")

------ cámara / entrada ------
function love.mousemoved(_, _, dx, dy)
  local sens = 0.0015
  cam.yaw   = cam.yaw   + dx * sens
  cam.pitch = cam.pitch + dy * sens
  local lim = 1.45
  if cam.pitch >  lim then cam.pitch =  lim end
  if cam.pitch < -lim then cam.pitch = -lim end
end

------ helpers geométricos ------
local function triangular_fan(cara)
  local o = cara[1]
  local tris = {}
  for i = 1, #cara-2 do
    tris[i] = { o, cara[i+1], cara[i+2] }
  end
  return tris
end

local function build_cam_mats()
  -- R_cam = R_y(yaw) * R_x(pitch)
  local Ry = vec.rota_y(cam.yaw)
  local Rx = vec.rota_x(cam.pitch)
  local Rcam = vec.mat3_mul(Ry, Rx)
  return Rcam, vec.transpose(Rcam)  -- inversa ortonormal = traspuesta
end

local function proyectar_vertices(vertices, fov, width, height)
  local proyectados = {}
  local fov_rad = math.rad(fov)
  local fy = (height / 2.0) / math.tan(fov_rad / 2.0)
  local fx = fy                      -- mantiene proporciones como vienes usando
  local cx, cy = width / 2.0, height / 2.0
  local near = 1e-3

  for i, v in ipairs(vertices) do
    local x, y, z = v[1], v[2], v[3]
    if z > near then
      proyectados[i] = { fx*(x/z) + cx,  cy - fy*(y/z) }
    else
      proyectados[i] = nil
    end
  end
  return proyectados
end

------ escena ------
function love.load()
  rotacion_x, rotacion_y, rotacion_z = 0, 0, 0
  fov = 60
  cam = { yaw = 0, pitch = 0, pos = { x = 0, y = 0, z = -2.5 } }
  love.mouse.setRelativeMode(true)

  figuras = {
  
  { -- Piso subdividido 8x8 (y = -0.62, x,z ∈ [-5,5])
  { -- VERTICES (81)
    {-5,-0.62,-5},
    {-3.75,-0.62,-5},
    {-2.5,-0.62,-5},
    {-1.25,-0.62,-5},
    {0,-0.62,-5},
    {1.25,-0.62,-5},
    {2.5,-0.62,-5},
    {3.75,-0.62,-5},
    {5,-0.62,-5},
    {-5,-0.62,-3.75},
    {-3.75,-0.62,-3.75},
    {-2.5,-0.62,-3.75},
    {-1.25,-0.62,-3.75},
    {0,-0.62,-3.75},
    {1.25,-0.62,-3.75},
    {2.5,-0.62,-3.75},
    {3.75,-0.62,-3.75},
    {5,-0.62,-3.75},
    {-5,-0.62,-2.5},
    {-3.75,-0.62,-2.5},
    {-2.5,-0.62,-2.5},
    {-1.25,-0.62,-2.5},
    {0,-0.62,-2.5},
    {1.25,-0.62,-2.5},
    {2.5,-0.62,-2.5},
    {3.75,-0.62,-2.5},
    {5,-0.62,-2.5},
    {-5,-0.62,-1.25},
    {-3.75,-0.62,-1.25},
    {-2.5,-0.62,-1.25},
    {-1.25,-0.62,-1.25},
    {0,-0.62,-1.25},
    {1.25,-0.62,-1.25},
    {2.5,-0.62,-1.25},
    {3.75,-0.62,-1.25},
    {5,-0.62,-1.25},
    {-5,-0.62,0},
    {-3.75,-0.62,0},
    {-2.5,-0.62,0},
    {-1.25,-0.62,0},
    {0,-0.62,0},
    {1.25,-0.62,0},
    {2.5,-0.62,0},
    {3.75,-0.62,0},
    {5,-0.62,0},
    {-5,-0.62,1.25},
    {-3.75,-0.62,1.25},
    {-2.5,-0.62,1.25},
    {-1.25,-0.62,1.25},
    {0,-0.62,1.25},
    {1.25,-0.62,1.25},
    {2.5,-0.62,1.25},
    {3.75,-0.62,1.25},
    {5,-0.62,1.25},
    {-5,-0.62,2.5},
    {-3.75,-0.62,2.5},
    {-2.5,-0.62,2.5},
    {-1.25,-0.62,2.5},
    {0,-0.62,2.5},
    {1.25,-0.62,2.5},
    {2.5,-0.62,2.5},
    {3.75,-0.62,2.5},
    {5,-0.62,2.5},
    {-5,-0.62,3.75},
    {-3.75,-0.62,3.75},
    {-2.5,-0.62,3.75},
    {-1.25,-0.62,3.75},
    {0,-0.62,3.75},
    {1.25,-0.62,3.75},
    {2.5,-0.62,3.75},
    {3.75,-0.62,3.75},
    {5,-0.62,3.75},
    {-5,-0.62,5},
    {-3.75,-0.62,5},
    {-2.5,-0.62,5},
    {-1.25,-0.62,5},
    {0,-0.62,5},
    {1.25,-0.62,5},
    {2.5,-0.62,5},
    {3.75,-0.62,5},
    {5,-0.62,5},
  },
  { -- CARAS CCW (64)
    {1,2,11,10},
    {2,3,12,11},
    {3,4,13,12},
    {4,5,14,13},
    {5,6,15,14},
    {6,7,16,15},
    {7,8,17,16},
    {8,9,18,17},
    {10,11,20,19},
    {11,12,21,20},
    {12,13,22,21},
    {13,14,23,22},
    {14,15,24,23},
    {15,16,25,24},
    {16,17,26,25},
    {17,18,27,26},
    {19,20,29,28},
    {20,21,30,29},
    {21,22,31,30},
    {22,23,32,31},
    {23,24,33,32},
    {24,25,34,33},
    {25,26,35,34},
    {26,27,36,35},
    {28,29,38,37},
    {29,30,39,38},
    {30,31,40,39},
    {31,32,41,40},
    {32,33,42,41},
    {33,34,43,42},
    {34,35,44,43},
    {35,36,45,44},
    {37,38,47,46},
    {38,39,48,47},
    {39,40,49,48},
    {40,41,50,49},
    {41,42,51,50},
    {42,43,52,51},
    {43,44,53,52},
    {44,45,54,53},
    {46,47,56,55},
    {47,48,57,56},
    {48,49,58,57},
    {49,50,59,58},
    {50,51,60,59},
    {51,52,61,60},
    {52,53,62,61},
    {53,54,63,62},
    {55,56,65,64},
    {56,57,66,65},
    {57,58,67,66},
    {58,59,68,67},
    {59,60,69,68},
    {60,61,70,69},
    {61,62,71,70},
    {62,63,72,71},
    {64,65,74,73},
    {65,66,75,74},
    {66,67,76,75},
    {67,68,77,76},
    {68,69,78,77},
    {69,70,79,78},
    {70,71,80,79},
    {71,72,81,80},
  }
},

    -- Árbol 1 (pino, x=-1.8, z=0.6)
{
  { -- VÉRTICES
    -- Tronco
    {-1.87,-0.60,0.53}, {-1.73,-0.60,0.53}, {-1.73,0.20,0.53}, {-1.87,0.20,0.53},
    {-1.87,-0.60,0.67}, {-1.73,-0.60,0.67}, {-1.73,0.20,0.67}, {-1.87,0.20,0.67},
    -- Follaje capa 1 (base + ápice)
    {-2.25,0.20,0.15}, {-1.35,0.20,0.15}, {-1.35,0.20,1.05}, {-2.25,0.20,1.05},
    {-1.80,0.65,0.60},
    -- Follaje capa 2
    {-2.13,0.50,0.27}, {-1.47,0.50,0.27}, {-1.47,0.50,0.93}, {-2.13,0.50,0.93},
    {-1.80,0.95,0.60},
    -- Follaje capa 3
    {-2.02,0.80,0.38}, {-1.58,0.80,0.38}, {-1.58,0.80,0.82}, {-2.02,0.80,0.82},
    {-1.80,1.20,0.60},
  },
  { -- CARAS CCW
    -- Tronco (quads)
    {1,4,3,2}, {5,6,7,8}, {1,2,6,5}, {2,3,7,6}, {3,4,8,7}, {4,1,5,8},
    -- Follaje capa 1 (base + 4 triángulos)
    {9,10,11,12}, {9,10,13}, {10,11,13}, {11,12,13}, {12,9,13},
    -- Follaje capa 2
    {14,15,16,17}, {14,15,18}, {15,16,18}, {16,17,18}, {17,14,18},
    -- Follaje capa 3
    {19,20,21,22}, {19,20,23}, {20,21,23}, {21,22,23}, {22,19,23},
  }
},

-- Árbol 2 (pino pequeño, x=-0.6, z=0.3)
{
  { -- VÉRTICES
    -- Tronco
    {-0.66,-0.60,0.24}, {-0.54,-0.60,0.24}, {-0.54,0.15,0.24}, {-0.66,0.15,0.24},
    {-0.66,-0.60,0.36}, {-0.54,-0.60,0.36}, {-0.54,0.15,0.36}, {-0.66,0.15,0.36},
    -- Follaje capa 1
    {-0.96,0.15,-0.06}, {-0.24,0.15,-0.06}, {-0.24,0.15,0.66}, {-0.96,0.15,0.66},
    {-0.60,0.51,0.30},
    -- Follaje capa 2
    {-0.864,0.39,0.036}, {-0.336,0.39,0.036}, {-0.336,0.39,0.564}, {-0.864,0.39,0.564},
    {-0.60,0.75,0.30},
    -- Follaje capa 3
    {-0.776,0.63,0.124}, {-0.424,0.63,0.124}, {-0.424,0.63,0.476}, {-0.776,0.63,0.476},
    {-0.60,0.95,0.30},
  },
  { -- CARAS CCW
    -- Tronco
    {1,4,3,2}, {5,6,7,8}, {1,2,6,5}, {2,3,7,6}, {3,4,8,7}, {4,1,5,8},
    -- Follaje 1
    {9,10,11,12}, {9,10,13}, {10,11,13}, {11,12,13}, {12,9,13},
    -- Follaje 2
    {14,15,16,17}, {14,15,18}, {15,16,18}, {16,17,18}, {17,14,18},
    -- Follaje 3
    {19,20,21,22}, {19,20,23}, {20,21,23}, {21,22,23}, {22,19,23},
  }
},

-- Árbol 3 (pino, x=0.6, z=0.5)
{
  { -- VÉRTICES
    -- Tronco
    {0.53,-0.60,0.43}, {0.67,-0.60,0.43}, {0.67,0.20,0.43}, {0.53,0.20,0.43},
    {0.53,-0.60,0.57}, {0.67,-0.60,0.57}, {0.67,0.20,0.57}, {0.53,0.20,0.57},
    -- Follaje capa 1
    {0.15,0.20,0.05}, {1.05,0.20,0.05}, {1.05,0.20,0.95}, {0.15,0.20,0.95},
    {0.60,0.65,0.50},
    -- Follaje capa 2
    {0.27,0.50,0.17}, {0.93,0.50,0.17}, {0.93,0.50,0.83}, {0.27,0.50,0.83},
    {0.60,0.95,0.50},
    -- Follaje capa 3
    {0.38,0.80,0.28}, {0.82,0.80,0.28}, {0.82,0.80,0.72}, {0.38,0.80,0.72},
    {0.60,1.20,0.50},
  },
  { -- CARAS CCW
    -- Tronco
    {1,4,3,2}, {5,6,7,8}, {1,2,6,5}, {2,3,7,6}, {3,4,8,7}, {4,1,5,8},
    -- Follaje 1
    {9,10,11,12}, {9,10,13}, {10,11,13}, {11,12,13}, {12,9,13},
    -- Follaje 2
    {14,15,16,17}, {14,15,18}, {15,16,18}, {16,17,18}, {17,14,18},
    -- Follaje 3
    {19,20,21,22}, {19,20,23}, {20,21,23}, {21,22,23}, {22,19,23},
  }
},

-- Árbol 4 (pino grande, x=1.8, z=0.8)
{
  { -- VÉRTICES
    -- Tronco (escalado 1.2)
    {1.72,-0.60,0.716}, {1.88,-0.60,0.716}, {1.88,0.24,0.716}, {1.72,0.24,0.716},
    {1.72,-0.60,0.884}, {1.88,-0.60,0.884}, {1.88,0.24,0.884}, {1.72,0.24,0.884},
    -- Follaje capa 1
    {1.26,0.24,0.26}, {2.34,0.24,0.26}, {2.34,0.24,1.34}, {1.26,0.24,1.34},
    {1.80,0.78,0.80},
    -- Follaje capa 2
    {1.404,0.60,0.404}, {2.196,0.60,0.404}, {2.196,0.60,1.196}, {1.404,0.60,1.196},
    {1.80,1.14,0.80},
    -- Follaje capa 3
    {1.536,0.96,0.536}, {2.064,0.96,0.536}, {2.064,0.96,1.064}, {1.536,0.96,1.064},
    {1.80,1.44,0.80},
  },
  { -- CARAS CCW
    -- Tronco
    {1,4,3,2}, {5,6,7,8}, {1,2,6,5}, {2,3,7,6}, {3,4,8,7}, {4,1,5,8},
    -- Follaje 1
    {9,10,11,12}, {9,10,13}, {10,11,13}, {11,12,13}, {12,9,13},
    -- Follaje 2
    {14,15,16,17}, {14,15,18}, {15,16,18}, {16,17,18}, {17,14,18},
    -- Follaje 3
    {19,20,21,22}, {19,20,23}, {20,21,23}, {21,22,23}, {22,19,23},
  }
},


     {
 { -- VÉRTICES (48) — z desplazada -0.8
  -- Torso (1..8)
  {-0.25,0.20,-0.90}, {0.25,0.20,-0.90}, {0.25,1.00,-0.90}, {-0.25,1.00,-0.90},
  {-0.25,0.20,-0.70}, {0.25,0.20,-0.70}, {0.25,1.00,-0.70}, {-0.25,1.00,-0.70},

  -- Cabeza (9..16)
  {-0.18,1.00,-0.98}, {0.18,1.00,-0.98}, {0.18,1.36,-0.98}, {-0.18,1.36,-0.98},
  {-0.18,1.00,-0.62}, {0.18,1.00,-0.62}, {0.18,1.36,-0.62}, {-0.18,1.36,-0.62},

  -- Brazo izquierdo (17..24)
  {-0.45,0.25,-0.875}, {-0.25,0.25,-0.875}, {-0.25,0.85,-0.875}, {-0.45,0.85,-0.875},
  {-0.45,0.25,-0.725}, {-0.25,0.25,-0.725}, {-0.25,0.85,-0.725}, {-0.45,0.85,-0.725},

  -- Brazo derecho (25..32)
  {0.25,0.25,-0.875}, {0.45,0.25,-0.875}, {0.45,0.85,-0.875}, {0.25,0.85,-0.875},
  {0.25,0.25,-0.725}, {0.45,0.25,-0.725}, {0.45,0.85,-0.725}, {0.25,0.85,-0.725},

  -- Pierna izquierda (33..40)
  {-0.15,-0.60,-0.875}, {0.00,-0.60,-0.875}, {0.00,0.20,-0.875}, {-0.15,0.20,-0.875},
  {-0.15,-0.60,-0.725}, {0.00,-0.60,-0.725}, {0.00,0.20,-0.725}, {-0.15,0.20,-0.725},

  -- Pierna derecha (41..48)
  {0.00,-0.60,-0.875}, {0.15,-0.60,-0.875}, {0.15,0.20,-0.875}, {0.00,0.20,-0.875},
  {0.00,-0.60,-0.725}, {0.15,-0.60,-0.725}, {0.15,0.20,-0.725}, {0.00,0.20,-0.725},
}
,

  { -- CARAS (quads) CCW; tu código las triangula con fan
    -- Torso (base=1)
    {1,4,3,2}, {5,6,7,8}, {1,2,6,5}, {2,3,7,6}, {3,4,8,7}, {4,1,5,8},

    -- Cabeza (base=9)
    {9,12,11,10}, {13,14,15,16}, {9,10,14,13}, {10,11,15,14}, {11,12,16,15}, {12,9,13,16},

    -- Brazo izq. (base=17)
    {17,20,19,18}, {21,22,23,24}, {17,18,22,21}, {18,19,23,22}, {19,20,24,23}, {20,17,21,24},

    -- Brazo der. (base=25)
    {25,28,27,26}, {29,30,31,32}, {25,26,30,29}, {26,27,31,30}, {27,28,32,31}, {28,25,29,32},

    -- Pierna izq. (base=33)
    {33,36,35,34}, {37,38,39,40}, {33,34,38,37}, {34,35,39,38}, {35,36,40,39}, {36,33,37,40},

    -- Pierna der. (base=41)
    {41,44,43,42}, {45,46,47,48}, {41,42,46,45}, {42,43,47,46}, {43,44,48,47}, {44,41,45,48},
  }
},
  }

-- === Paletas por figura/cara (sin iluminación) ===
local function assign_material_colors(figs)
  local colors = {}
  for fi = 1, #figs do
    colors[fi] = {}

    local verts = figs[fi][1]
    local faces = figs[fi][2]
    local nv = #verts
    local nf = #faces

    if nv == 81 and nf == 64 then
      -- Piso 8x8: damero verde suave
      local cA = {0.17, 0.25, 0.17}
      local cB = {0.20, 0.30, 0.20}
      for f = 1, nf do
        local row = math.floor((f-1) / 8)
        local col = (f-1) % 8
        colors[fi][f] = ((row + col) % 2 == 0) and {cA[1],cA[2],cA[3]} or {cB[1],cB[2],cB[3]}
      end

    elseif nv == 23 and nf == 21 then
      -- Árbol: 6 caras tronco + 3 capas de follaje (5 caras cada una)
      local trunk = {0.45, 0.28, 0.12}
      local leaf1 = {0.10, 0.40, 0.16}
      local leaf2 = {0.12, 0.45, 0.18}
      local leaf3 = {0.14, 0.50, 0.20}

      for f = 1, 6 do colors[fi][f] = {trunk[1], trunk[2], trunk[3]} end
      for f = 7, 11 do colors[fi][f] = {leaf1[1], leaf1[2], leaf1[3]} end
      for f = 12,16 do colors[fi][f] = {leaf2[1], leaf2[2], leaf2[3]} end
      for f = 17,21 do colors[fi][f] = {leaf3[1], leaf3[2], leaf3[3]} end

    else
      -- Genérico (p.ej., “humano”): gris neutro
      for f = 1, nf do colors[fi][f] = {0.75, 0.75, 0.78} end
    end
  end
  return colors
end


  colores_cara_figuras = assign_material_colors(figuras)


  -- buffers del z-buffer (software)
  RENDER_W, RENDER_H = 820, 580            -- sube para más nitidez
  zbuf    = {}
  imgData = love.image.newImageData(RENDER_W, RENDER_H)
  img     = love.graphics.newImage(imgData)
  img:setFilter("nearest","nearest")
end

------ z-buffer software ------
local function edge(x0,y0, x1,y1, x,y)
  return (x - x0)*(y1 - y0) - (y - y0)*(x1 - x0)
end

local function clear_buffers()
  for i = 1, RENDER_W*RENDER_H do zbuf[i] = math.huge end
  imgData:mapPixel(function() return 0,0,0,1 end)
end

-- Reúne triángulos y descarta degenerados/near (backface culling en rasterización)
local function gather_tris(figs, vc_all, vs_all, face_colors)
  local tris = {}
  local near = 1e-3
  local EPS  = 1e-6
  for fi = 1, #figs do
    local faces = figs[fi][2]
    local vc = vc_all[fi]         -- en espacio cámara
    local vs = vs_all[fi]         -- proyectados
    for f = 1, #faces do
      local fan = triangular_fan(faces[f])
      local col = (face_colors and face_colors[fi] and face_colors[fi][f]) or {1,1,1}
      for t = 1, #fan do
        local a,b,c = fan[t][1], fan[t][2], fan[t][3]
        local v1,v2,v3 = vc[a],vc[b],vc[c]
        local p1,p2,p3 = vs[a],vs[b],vs[c]
        if v1 and v2 and v3 and p1 and p2 and p3 then
          if v1[3]>near and v2[3]>near and v3[3]>near then
            -- evita triángulos colapsados en pantalla
            local ax, ay = p2[1]-p1[1], p2[2]-p1[2]
            local bx, by = p3[1]-p1[1], p3[2]-p1[2]
            local area2  = ax*by - ay*bx
            if math.abs(area2) > EPS then
              tris[#tris+1] = {
                p1=p1,p2=p2,p3=p3,
                z1=v1[3], z2=v2[3], z3=v3[3],
                color=col
              }
            end
          end
        end
      end
    end
  end
  return tris
end

-- Rasteriza todos los triángulos con z-buffer (no ordena)
local function rasterize_with_zbuffer(tris, winW, winH)
  clear_buffers()
  local sx, sy = RENDER_W / winW, RENDER_H / winH

  for i = 1, #tris do
    local T = tris[i]
    local r,g,b = T.color[1], T.color[2], T.color[3]
    local x1,y1 = T.p1[1]*sx, T.p1[2]*sy
    local x2,y2 = T.p2[1]*sx, T.p2[2]*sy
    local x3,y3 = T.p3[1]*sx, T.p3[2]*sy

    local minx = math.max(0, math.floor(math.min(x1,x2,x3)))
    local maxx = math.min(RENDER_W-1, math.floor(math.max(x1,x2,x3)))
    local miny = math.max(0, math.floor(math.min(y1,y2,y3)))
    local maxy = math.min(RENDER_H-1, math.floor(math.max(y1,y2,y3)))

    local A = edge(x1,y1, x2,y2, x3,y3)
    if A ~= 0 then
      local invA = 1.0 / A
      -- profundidad perspective-correct (estable)
      local invz1 = 1.0 / T.z1
      local invz2 = 1.0 / T.z2
      local invz3 = 1.0 / T.z3

      for y = miny, maxy do
        for x = minx, maxx do
          local px, py = x + 0.5, y + 0.5
          local w1 = edge(x2,y2, x3,y3, px,py) * invA
          local w2 = edge(x3,y3, x1,y1, px,py) * invA
          local w3 = 1.0 - w1 - w2
          -- regla de fill que acepta ambos sentidos de arista
          if (w1>=0 and w2>=0 and w3>=0)   then --or (w1<=0 and w2<=0 and w3<=0)
            local invz = w1*invz1 + w2*invz2 + w3*invz3
            local z = 1.0 / invz
            local idx = y*RENDER_W + x + 1
            if z < zbuf[idx] then
              zbuf[idx] = z
              imgData:setPixel(x, y, r, g, b, 1)
            end
          end
        end
      end
    end
  end

  img:replacePixels(imgData)
end

------ update/draw ------
function love.update(dt)
  local width, height = love.graphics.getDimensions()
  local speed = 1.5

  rotation_mat = vec.rotacion_completa(rotacion_x, rotacion_y, rotacion_z)
  local wx, wy, wz = 0*dt, 0*dt, 0*dt
  local mvx, mvy, mvz = 0, 0, 0

  local Rcam, RcamT = build_cam_mats()
  local right   = { Rcam[1][1], Rcam[2][1], Rcam[3][1] }
  local forward = { Rcam[1][3], Rcam[2][3], Rcam[3][3] }

  if love.keyboard.isDown("w") then mvx=mvx+forward[1]; mvy=mvy+forward[2]; mvz=mvz+forward[3] end
  if love.keyboard.isDown("s") then mvx=mvx-forward[1]; mvy=mvy-forward[2]; mvz=mvz-forward[3] end
  if love.keyboard.isDown("d") then mvx=mvx+right[1];   mvy=mvy+right[2];   mvz=mvz+right[3]   end
  if love.keyboard.isDown("a") then mvx=mvx-right[1];   mvy=mvy-right[2];   mvz=mvz-right[3]   end

  cam.pos.x = cam.pos.x + mvx * speed * dt
  cam.pos.y = cam.pos.y + mvy * speed * dt
  cam.pos.z = cam.pos.z + mvz * speed * dt

  vertices_figura_rot  = {}
  vertices_figuras_proyec = {}

  for i = 1, #figuras do
    vertices_figura_rot[i] = {}
    for vi, v in ipairs(figuras[i][1]) do
      local w = vec.mat3_vec(v, rotation_mat)
      local rel = { w[1] - cam.pos.x, w[2] - cam.pos.y, w[3] - cam.pos.z }
      vertices_figura_rot[i][vi] = vec.mat3_vec(rel, RcamT)
    end
    vertices_figuras_proyec[i] = proyectar_vertices(vertices_figura_rot[i], fov, width, height)
  end

  -- z-buffer: rasteriza todos los triángulos sin ordenar
  local tris = gather_tris(figuras, vertices_figura_rot, vertices_figuras_proyec, colores_cara_figuras)
  rasterize_with_zbuffer(tris, width, height)

  rotacion_x = (rotacion_x + wx) % (2 * math.pi)
  rotacion_y = (rotacion_y + wy) % (2 * math.pi)
  rotacion_z = (rotacion_z + wz) % (2 * math.pi)
end

function love.draw()
  local width, height = love.graphics.getDimensions()
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(img, 0, 0, 0, width/RENDER_W, height/RENDER_H)
end
