--[[
=============================================================================
MÓDULO: VECTORES Y MATRICES 3D
=============================================================================

Este módulo implementa operaciones fundamentales de álgebra lineal para
gráficos 3D, incluyendo:
  - Operaciones vectoriales (producto punto, normalización)
  - Multiplicación de matrices 3×3
  - Matrices de rotación sobre ejes X, Y, Z
  - Composición de rotaciones (Euler angles)
  - Transposición de matrices (para inversas ortonormales)

Convenciones:
  - Vectores: tablas Lua {x, y, z} donde x=vec[1], y=vec[2], z=vec[3]
  - Matrices: tablas 2D {{fila1}, {fila2}, {fila3}}
  - Rotaciones: convención mano derecha (right-handed)
  - Ángulos: siempre en radianes
=============================================================================
]]--

local vector= {}

--[[
FUNCIÓN: crear()
Crea un vector nulo (origen).

RETORNA: Vector 3D {0, 0, 0}

MATEMÁTICA:
  v = (0, 0, 0)ᵀ
]]--
function vector.crear()
    return {
        0,
        0,
        0
    }
end

--[[
FUNCIÓN: dot(vec1, vec2)
Calcula el producto punto (dot product) entre dos vectores 3D.

PARÁMETROS:
  vec1, vec2: Vectores 3D {x, y, z}

RETORNA: Escalar (número)

MATEMÁTICA:
  a · b = aₓbₓ + aᵧbᵧ + aᵤbᵤ = |a||b|cos(θ)

  Donde θ es el ángulo entre los vectores.

PROPIEDADES:
  - Conmutativo: a · b = b · a
  - Si a · b = 0, los vectores son perpendiculares
  - Si a · b > 0, el ángulo es agudo (< 90°)
  - Si a · b < 0, el ángulo es obtuso (> 90°)
]]--
function vector.dot(vec1,vec2)
    return vec1[1] * vec2[1] + vec1[2] * vec2[2] + vec1[3] * vec2[3]
end

--[[
FUNCIÓN: normalize(vec)
Normaliza un vector a longitud unitaria (magnitud = 1).

PARÁMETROS:
  vec: Vector 3D {x, y, z}

RETORNA: Vector normalizado {x', y', z'} con ||v|| = 1

MATEMÁTICA:
  v̂ = v / ||v||

  Donde ||v|| = √(vₓ² + vᵧ² + vᵤ²) es la norma euclidiana.

  Componentes normalizadas:
    v̂ₓ = vₓ / ||v||
    v̂ᵧ = vᵧ / ||v||
    v̂ᵤ = vᵤ / ||v||

CASO ESPECIAL:
  Si ||v|| = 0 (vector nulo), retorna {0, 0, 0} para evitar división por cero.

APLICACIONES:
  - Vectores de dirección en física
  - Normales de superficie en iluminación
  - Ejes de referencia en sistemas de coordenadas
]]--
function vector.normalize(vec)
    local longitud = (vec[1]^2 + vec[2]^2 + vec[3]^2)^0.5
    if longitud == 0 then
        return {0,0,0}
    else
        return {vec[1]/longitud,vec[2]/longitud,vec[3]/longitud}
    end
    return
end

--[[
FUNCIÓN: mat3_mul(mat1, mat2)
Multiplica dos matrices 3×3.

PARÁMETROS:
  mat1, mat2: Matrices 3×3 representadas como {{fila1}, {fila2}, {fila3}}

RETORNA: Matriz 3×3 resultado de C = A × B

MATEMÁTICA:
  (A × B)ᵢⱼ = Σₖ Aᵢₖ × Bₖⱼ  (para k = 1, 2, 3)

  Cada elemento cᵢⱼ es el producto punto de:
    - La fila i de A
    - La columna j de B

  En notación expandida:
    ┌                                                              ┐
    │ a₁₁b₁₁+a₁₂b₂₁+a₁₃b₃₁  a₁₁b₁₂+a₁₂b₂₂+a₁₃b₃₂  a₁₁b₁₃+a₁₂b₂₃+a₁₃b₃₃ │
    │ a₂₁b₁₁+a₂₂b₂₁+a₂₃b₃₁  a₂₁b₁₂+a₂₂b₂₂+a₂₃b₃₂  a₂₁b₁₃+a₂₂b₂₃+a₂₃b₃₃ │
    │ a₃₁b₁₁+a₃₂b₂₁+a₃₃b₃₁  a₃₁b₁₂+a₃₂b₂₂+a₃₃b₃₂  a₃₁b₁₃+a₃₂b₂₃+a₃₃b₃₃ │
    └                                                              ┘

PROPIEDADES:
  - NO conmutativa: A × B ≠ B × A (en general)
  - Asociativa: (A × B) × C = A × (B × C)
  - Distributiva: A × (B + C) = A × B + A × C
  - Identidad: A × I = I × A = A

COMPLEJIDAD: O(3³) = O(27) multiplicaciones + O(18) sumas
]]--
function vector.mat3_mul(mat1,mat2)
    local matriz = { {0,0,0}, {0,0,0}, {0,0,0} }
  for i = 1, 3 do            -- fila i de A
    for j = 1, 3 do          -- columna j de B
      -- producto punto de la fila i de A con la columna j de B
      matriz[i][j] = mat1[i][1] * mat2[1][j]
              + mat1[i][2] * mat2[2][j]
              + mat1[i][3] * mat2[3][j]
    end
  end
  return matriz
end

--[[
FUNCIÓN: mat3_vec(vec, mat)
Multiplica una matriz 3×3 por un vector 3D.

PARÁMETROS:
  vec: Vector 3D {x, y, z}
  mat: Matriz 3×3 {{fila1}, {fila2}, {fila3}}

RETORNA: Vector 3D transformado v' = M × v

MATEMÁTICA:
  ┌    ┐   ┌           ┐   ┌   ┐
  │ v'ₓ│   │ m₁₁ m₁₂ m₁₃│   │ vₓ │
  │ v'ᵧ│ = │ m₂₁ m₂₂ m₂₃│ × │ vᵧ │
  │ v'ᵤ│   │ m₃₁ m₃₂ m₃₃│   │ vᵤ │
  └    ┘   └           ┘   └   ┘

  Componentes:
    v'ₓ = m₁₁vₓ + m₁₂vᵧ + m₁₃vᵤ  (fila 1 · v)
    v'ᵧ = m₂₁vₓ + m₂₂vᵧ + m₂₃vᵤ  (fila 2 · v)
    v'ᵤ = m₃₁vₓ + m₃₂vᵧ + m₃₃vᵤ  (fila 3 · v)

APLICACIONES:
  - Rotación de vértices: v_rotado = R × v
  - Cambio de base: v_nuevo = T × v_viejo
  - Transformaciones lineales arbitrarias

COMPLEJIDAD: O(9) multiplicaciones + O(6) sumas
]]--
function vector.mat3_vec(vec,mat)
  return {
    mat[1][1]*vec[1] + mat[1][2]*vec[2] + mat[1][3]*vec[3],
    mat[2][1]*vec[1] + mat[2][2]*vec[2] + mat[2][3]*vec[3],
    mat[3][1]*vec[1] + mat[3][2]*vec[2] + mat[3][3]*vec[3],
  }
end

--[[
FUNCIÓN: rota_x(angle)
Genera matriz de rotación alrededor del eje X (pitch).

PARÁMETROS:
  angle: Ángulo de rotación en radianes

RETORNA: Matriz 3×3 de rotación Rₓ(θ)

MATEMÁTICA:
         ┌                     ┐
  Rₓ(θ) = │  1      0       0   │
         │  0   cos(θ)  -sin(θ) │
         │  0   sin(θ)   cos(θ) │
         └                     ┘

DERIVACIÓN:
  Rotar un punto (x, y, z) alrededor del eje X mantiene x constante
  y rota (y, z) en el plano YZ:

    x' = x
    y' = y·cos(θ) - z·sin(θ)
    z' = y·sin(θ) + z·cos(θ)

PROPIEDADES:
  - det(Rₓ) = 1 (preserva orientación)
  - Rₓᵀ = Rₓ⁻¹ (matriz ortonormal)
  - Rₓ(θ₁) × Rₓ(θ₂) = Rₓ(θ₁ + θ₂)
  - Rₓ(0) = I (identidad)
  - Rₓ(2π) = I (rotación completa)

APLICACIONES:
  - Pitch en cámara (mirar arriba/abajo)
  - Rotación de modelos alrededor de eje horizontal
]]--
function vector.rota_x(angle)
    local cosi, sinu = math.cos(angle), math.sin(angle)
    return {
        {1,0,0},
        {0,cosi,-sinu},
        {0,sinu,cosi}
    }
end

--[[
FUNCIÓN: rota_y(angle)
Genera matriz de rotación alrededor del eje Y (yaw).

PARÁMETROS:
  angle: Ángulo de rotación en radianes

RETORNA: Matriz 3×3 de rotación Rᵧ(θ)

MATEMÁTICA:
         ┌                    ┐
  Rᵧ(θ) = │  cos(θ)  0  sin(θ) │
         │    0     1    0    │
         │ -sin(θ)  0  cos(θ) │
         └                    ┘

DERIVACIÓN:
  Rotar un punto (x, y, z) alrededor del eje Y mantiene y constante
  y rota (x, z) en el plano XZ:

    x' =  x·cos(θ) + z·sin(θ)
    y' =  y
    z' = -x·sin(θ) + z·cos(θ)

  NOTA: El signo negativo en z' es por convención mano derecha.

PROPIEDADES:
  - det(Rᵧ) = 1 (preserva orientación)
  - Rᵧᵀ = Rᵧ⁻¹ (matriz ortonormal)
  - Rᵧ(θ₁) × Rᵧ(θ₂) = Rᵧ(θ₁ + θ₂)

APLICACIONES:
  - Yaw en cámara (mirar izquierda/derecha)
  - Rotación de modelos alrededor de eje vertical
  - Orientación en navegación (brújula)
]]--
function vector.rota_y(angle)
    local cosi, sinu = math.cos(angle), math.sin(angle)
    return {
        {cosi,0,sinu},
        {0,1,0},
        {-sinu,0,cosi}
    }
end

--[[
FUNCIÓN: rota_z(angle)
Genera matriz de rotación alrededor del eje Z (roll).

PARÁMETROS:
  angle: Ángulo de rotación en radianes

RETORNA: Matriz 3×3 de rotación Rᵤ(θ)

MATEMÁTICA:
         ┌                     ┐
  Rᵤ(θ) = │ cos(θ)  -sin(θ)  0 │
         │ sin(θ)   cos(θ)  0 │
         │   0        0     1 │
         └                     ┘

DERIVACIÓN:
  Rotar un punto (x, y, z) alrededor del eje Z mantiene z constante
  y rota (x, y) en el plano XY:

    x' = x·cos(θ) - y·sin(θ)
    y' = x·sin(θ) + y·cos(θ)
    z' = z

  Esta es la rotación 2D clásica extendida a 3D.

PROPIEDADES:
  - det(Rᵤ) = 1 (preserva orientación)
  - Rᵤᵀ = Rᵤ⁻¹ (matriz ortonormal)
  - Rᵤ(θ₁) × Rᵤ(θ₂) = Rᵤ(θ₁ + θ₂)

APLICACIONES:
  - Roll en cámara (inclinar cabeza)
  - Rotación de sprites en juegos 2D
  - Orientación de objetos en plano horizontal
]]--
function vector.rota_z(angle)
    local cosi, sinu = math.cos(angle), math.sin(angle)
    return {
        {cosi,-sinu,0},
        {sinu,cosi,0},
        {0,0,1}
    }
end

--[[
FUNCIÓN: rotacion_completa(anglex, angley, anglez)
Compone rotaciones de Euler en el orden Z-Y-X.

PARÁMETROS:
  anglex: Ángulo de rotación sobre X (pitch) en radianes
  angley: Ángulo de rotación sobre Y (yaw) en radianes
  anglez: Ángulo de rotación sobre Z (roll) en radianes

RETORNA: Matriz 3×3 compuesta R = Rᵤ(γ) × Rᵧ(β) × Rₓ(α)

MATEMÁTICA:
  R_total = Rᵤ(γ) × Rᵧ(β) × Rₓ(α)

  ORDEN DE APLICACIÓN (de derecha a izquierda):
    1. Primero rota sobre X (pitch)
    2. Luego rota sobre Y (yaw)
    3. Finalmente rota sobre Z (roll)

  Para transformar un vector v:
    v' = R_total × v = Rᵤ(Rᵧ(Rₓ(v)))

ÁNGULOS DE EULER:
  Los ángulos de Euler (α, β, γ) describen cualquier orientación 3D
  mediante tres rotaciones secuenciales. Existen 12 convenciones
  diferentes (XYZ, ZYX, etc.). Esta función usa ZYX.

GIMBAL LOCK:
  ADVERTENCIA: Las rotaciones de Euler sufren de "gimbal lock" cuando
  el ángulo Y está cerca de ±90°. En ese caso, las rotaciones X y Z
  se vuelven dependientes, perdiendo un grado de libertad.

  Solución alternativa: Usar cuaterniones para rotaciones libres de
  gimbal lock.

EJEMPLO:
  Para rotar 45° en X, 30° en Y, 0° en Z:
    R = rotacion_completa(π/4, π/6, 0)
]]--
function vector.rotacion_completa(anglex,angley,anglez)
    local rotx,roty,rotz= vector.rota_x(anglex),vector.rota_y(angley),vector.rota_z(anglez)
    return vector.mat3_mul(rotz ,vector.mat3_mul(roty,rotx))
end

--[[
FUNCIÓN: transpose(M)
Calcula la transpuesta de una matriz 3×3.

PARÁMETROS:
  M: Matriz 3×3 {{fila1}, {fila2}, {fila3}}

RETORNA: Matriz transpuesta Mᵀ

MATEMÁTICA:
  (Mᵀ)ᵢⱼ = Mⱼᵢ

  La transpuesta intercambia filas por columnas:
    ┌           ┐ᵀ   ┌           ┐
    │ a  b  c   │    │ a  d  g   │
    │ d  e  f   │  = │ b  e  h   │
    │ g  h  i   │    │ c  f  i   │
    └           ┘    └           ┘

PROPIEDADES:
  - (Mᵀ)ᵀ = M (involución)
  - (A + B)ᵀ = Aᵀ + Bᵀ
  - (A × B)ᵀ = Bᵀ × Aᵀ (orden inverso)
  - det(Mᵀ) = det(M)

MATRIZ ORTONORMAL:
  Para matrices de rotación (ortonormales), la transpuesta es
  igual a la inversa:
    Rᵀ = R⁻¹

  Esto se cumple porque las columnas (y filas) son vectores
  unitarios mutuamente perpendiculares:
    R × Rᵀ = Rᵀ × R = I

APLICACIÓN EN CÁMARA:
  En el rasterizador, se usa transpose() para obtener la matriz
  de rotación inversa de la cámara de forma eficiente:

    R_cam = Rᵧ(yaw) × Rₓ(pitch)
    R_cam_inv = transpose(R_cam)  // O(9) en lugar de inversión completa
]]--
function vector.transpose(M)
  return {
    { M[1][1], M[2][1], M[3][1] },
    { M[1][2], M[2][2], M[3][2] },
    { M[1][3], M[2][3], M[3][3] },
  }
end

return vector