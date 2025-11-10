# API: Módulo de Vectores

Documentación completa del módulo `vectors.lua` que implementa operaciones de álgebra lineal para gráficos 3D.

## Importar el Módulo

```lua
local vec = require("vectors")
```

---

## Operaciones Vectoriales

### `vec.crear()`

Crea un vector nulo (origen).

**Retorna:** `{0, 0, 0}`

**Ejemplo:**
```lua
local v = vec.crear()
-- v = {0, 0, 0}
```

---

### `vec.dot(vec1, vec2)`

Calcula el producto punto (dot product) entre dos vectores 3D.

**Parámetros:**

- `vec1`: Vector 3D `{x, y, z}`
- `vec2`: Vector 3D `{x, y, z}`

**Retorna:** Número (escalar)

**Fórmula:**

$$
\mathbf{a} \cdot \mathbf{b} = a_x b_x + a_y b_y + a_z b_z
$$

**Ejemplo:**
```lua
local a = {1, 0, 0}
local b = {0, 1, 0}
local resultado = vec.dot(a, b)
-- resultado = 0 (vectores perpendiculares)

local c = {3, 4, 0}
local d = {1, 0, 0}
local resultado2 = vec.dot(c, d)
-- resultado2 = 3
```

**Casos de uso:**

- Calcular el ángulo entre dos vectores: $\cos(\theta) = \frac{\mathbf{a} \cdot \mathbf{b}}{|\mathbf{a}||\mathbf{b}|}$
- Determinar si dos vectores son perpendiculares: $\mathbf{a} \cdot \mathbf{b} = 0$
- Proyección de un vector sobre otro

---

### `vec.normalize(vec)`

Normaliza un vector a longitud unitaria (magnitud = 1).

**Parámetros:**

- `vec`: Vector 3D `{x, y, z}`

**Retorna:** Vector normalizado `{x', y', z'}` con $|\mathbf{v}| = 1$

**Fórmula:**

$$
\hat{\mathbf{v}} = \frac{\mathbf{v}}{|\mathbf{v}|} = \frac{\mathbf{v}}{\sqrt{v_x^2 + v_y^2 + v_z^2}}
$$

**Ejemplo:**
```lua
local v = {3, 4, 0}
local vnorm = vec.normalize(v)
-- vnorm = {0.6, 0.8, 0}
-- Longitud: sqrt(0.6^2 + 0.8^2) = 1.0

local cero = {0, 0, 0}
local cero_norm = vec.normalize(cero)
-- cero_norm = {0, 0, 0} (caso especial)
```

**Nota:** Si el vector es nulo (longitud 0), retorna `{0, 0, 0}` para evitar división por cero.

---

## Operaciones de Matrices

### `vec.mat3_mul(mat1, mat2)`

Multiplica dos matrices 3×3.

**Parámetros:**

- `mat1`: Matriz 3×3 `{{fila1}, {fila2}, {fila3}}`
- `mat2`: Matriz 3×3

**Retorna:** Matriz 3×3 resultado de $C = A \times B$

**Fórmula:**

$$
C_{ij} = \sum_{k=1}^{3} A_{ik} \cdot B_{kj}
$$

**Ejemplo:**
```lua
local A = {
  {1, 0, 0},
  {0, 1, 0},
  {0, 0, 1}
}  -- Matriz identidad

local B = {
  {2, 0, 0},
  {0, 3, 0},
  {0, 0, 4}
}  -- Matriz escala

local C = vec.mat3_mul(A, B)
-- C = B (porque A es identidad)
```

**⚠️ Importante:** La multiplicación de matrices **NO es conmutativa**: $A \times B \neq B \times A$ en general.

---

### `vec.mat3_vec(vec, mat)`

Multiplica una matriz 3×3 por un vector 3D.

**Parámetros:**

- `vec`: Vector 3D `{x, y, z}`
- `mat`: Matriz 3×3

**Retorna:** Vector transformado $\mathbf{v}' = M \times \mathbf{v}$

**Fórmula:**

$$
\begin{pmatrix} v'_x \\ v'_y \\ v'_z \end{pmatrix} =
\begin{pmatrix}
m_{11} & m_{12} & m_{13} \\
m_{21} & m_{22} & m_{23} \\
m_{31} & m_{32} & m_{33}
\end{pmatrix}
\begin{pmatrix} v_x \\ v_y \\ v_z \end{pmatrix}
$$

**Ejemplo:**
```lua
-- Rotar vector (1, 0, 0) 90° sobre eje Z
local v = {1, 0, 0}
local Rz = vec.rota_z(math.pi/2)  -- 90 grados
local v_rotado = vec.mat3_vec(v, Rz)
-- v_rotado ≈ {0, 1, 0}
```

---

## Matrices de Rotación

### `vec.rota_x(angle)`

Genera matriz de rotación alrededor del eje X (pitch).

**Parámetros:**

- `angle`: Ángulo en radianes

**Retorna:** Matriz 3×3 de rotación $R_x(\theta)$

**Fórmula:**

$$
R_x(\theta) = \begin{pmatrix}
1 & 0 & 0 \\
0 & \cos\theta & -\sin\theta \\
0 & \sin\theta & \cos\theta
\end{pmatrix}
$$

**Ejemplo:**
```lua
-- Rotar 45 grados sobre eje X
local Rx = vec.rota_x(math.pi/4)
local v = {0, 1, 0}
local v_rot = vec.mat3_vec(v, Rx)
-- v_rot ≈ {0, 0.707, 0.707}
```

**Visualización:**

```
Eje X (no cambia): →
Plano YZ rota:

     Y              Y
     ↑       →      ↗
     |              /
     +--→ Z    θ   +--→ Z
```

---

### `vec.rota_y(angle)`

Genera matriz de rotación alrededor del eje Y (yaw).

**Parámetros:**

- `angle`: Ángulo en radianes

**Retorna:** Matriz 3×3 de rotación $R_y(\theta)$

**Fórmula:**

$$
R_y(\theta) = \begin{pmatrix}
\cos\theta & 0 & \sin\theta \\
0 & 1 & 0 \\
-\sin\theta & 0 & \cos\theta
\end{pmatrix}
$$

**Ejemplo:**
```lua
-- Girar cámara 30 grados a la derecha
local yaw = vec.rota_y(math.rad(30))
```

**Visualización:**

```
Eje Y (no cambia): ↑
Plano XZ rota:

  Z              Z
  ↑       →      ↗
  |              /
  +--→ X    θ   +--→ X
```

---

### `vec.rota_z(angle)`

Genera matriz de rotación alrededor del eje Z (roll).

**Parámetros:**

- `angle`: Ángulo en radianes

**Retorna:** Matriz 3×3 de rotación $R_z(\theta)$

**Fórmula:**

$$
R_z(\theta) = \begin{pmatrix}
\cos\theta & -\sin\theta & 0 \\
\sin\theta & \cos\theta & 0 \\
0 & 0 & 1
\end{pmatrix}
$$

**Ejemplo:**
```lua
-- Rotar sprite 2D 90 grados
local Rz = vec.rota_z(math.pi/2)
```

**Visualización:**

```
Eje Z (no cambia): ⊙ (saliendo de la pantalla)
Plano XY rota:

  Y              Y
  ↑       →      ↗
  |              /
  +--→ X    θ   +--→ X
```

---

### `vec.rotacion_completa(anglex, angley, anglez)`

Compone rotaciones de Euler en el orden Z-Y-X.

**Parámetros:**

- `anglex`: Ángulo sobre X (pitch) en radianes
- `angley`: Ángulo sobre Y (yaw) en radianes
- `anglez`: Ángulo sobre Z (roll) en radianes

**Retorna:** Matriz 3×3 compuesta $R = R_z(\gamma) \times R_y(\beta) \times R_x(\alpha)$

**Fórmula:**

$$
R_{\text{total}} = R_z(\gamma) \cdot R_y(\beta) \cdot R_x(\alpha)
$$

**Orden de aplicación** (de derecha a izquierda):

1. Primero rota sobre X (pitch)
2. Luego rota sobre Y (yaw)
3. Finalmente rota sobre Z (roll)

**Ejemplo:**
```lua
-- Orientación completa de un objeto
local pitch = math.rad(15)  -- Inclinar 15° hacia arriba
local yaw = math.rad(45)    -- Girar 45° a la derecha
local roll = math.rad(0)    -- Sin inclinación lateral

local R = vec.rotacion_completa(pitch, yaw, roll)
local v = {1, 0, 0}
local v_rot = vec.mat3_vec(v, R)
```

**⚠️ Gimbal Lock:**

Las rotaciones de Euler sufren de "gimbal lock" cuando el ángulo Y está cerca de ±90°. En ese caso, las rotaciones X y Z se vuelven dependientes.

**Alternativa:** Usar **cuaterniones** para rotaciones libres de gimbal lock.

---

### `vec.transpose(M)`

Calcula la transpuesta de una matriz 3×3.

**Parámetros:**

- `M`: Matriz 3×3

**Retorna:** Matriz transpuesta $M^T$

**Fórmula:**

$$
(M^T)_{ij} = M_{ji}
$$

La transpuesta intercambia filas por columnas:

$$
\begin{pmatrix}
a & b & c \\
d & e & f \\
g & h & i
\end{pmatrix}^T
=
\begin{pmatrix}
a & d & g \\
b & e & h \\
c & f & i
\end{pmatrix}
$$

**Ejemplo:**
```lua
local M = {
  {1, 2, 3},
  {4, 5, 6},
  {7, 8, 9}
}

local MT = vec.transpose(M)
-- MT = {
--   {1, 4, 7},
--   {2, 5, 8},
--   {3, 6, 9}
-- }
```

**Uso especial:** Para matrices de rotación (ortonormales), la transpuesta es igual a la inversa:

$$
R^T = R^{-1}
$$

Esto permite calcular la inversa de forma eficiente ($O(9)$ en lugar de $O(27)$).

**Ejemplo de uso en cámara:**
```lua
-- Crear matriz de rotación de cámara
local Rcam = vec.mat3_mul(vec.rota_y(yaw), vec.rota_x(pitch))

-- Calcular inversa (para transformar mundo → cámara)
local Rcam_inv = vec.transpose(Rcam)  -- Eficiente!
```

---

## Convenciones

### Sistema de Coordenadas

El rasterizador usa un sistema de coordenadas **mano derecha** (right-handed):

```
      Y (arriba)
      ↑
      |
      |
      +-----→ X (derecha)
     /
    /
   Z (hacia la cámara)
```

**Regla de la mano derecha:**

- Dedo índice: +X
- Dedo medio: +Y
- Pulgar: +Z

### Ángulos

- Todos los ángulos están en **radianes**
- Para convertir de grados: `radianes = math.rad(grados)`
- Para convertir a grados: `grados = math.deg(radianes)`

**Conversiones comunes:**

| Grados | Radianes       | Valor aproximado |
|--------|----------------|------------------|
| 0°     | 0              | 0                |
| 30°    | π/6            | 0.524            |
| 45°    | π/4            | 0.785            |
| 60°    | π/3            | 1.047            |
| 90°    | π/2            | 1.571            |
| 180°   | π              | 3.142            |
| 360°   | 2π             | 6.283            |

### Representación de Datos

**Vectores:**
```lua
local v = {x, y, z}
-- Acceso:
local x = v[1]
local y = v[2]
local z = v[3]
```

**Matrices 3×3:**
```lua
local M = {
  {m11, m12, m13},  -- Fila 1
  {m21, m22, m23},  -- Fila 2
  {m31, m32, m33}   -- Fila 3
}

-- Acceso:
local elemento = M[fila][columna]
```

---

## Ejemplos Completos

### Ejemplo 1: Rotar un Cubo

```lua
local vec = require("vectors")

-- Definir vértices de un cubo
local vertices = {
  {-1, -1, -1}, {1, -1, -1}, {1, 1, -1}, {-1, 1, -1},
  {-1, -1,  1}, {1, -1,  1}, {1, 1,  1}, {-1, 1,  1}
}

-- Crear matriz de rotación
local angulo = math.rad(45)
local R = vec.rotacion_completa(angulo, angulo, 0)

-- Rotar todos los vértices
local vertices_rotados = {}
for i, v in ipairs(vertices) do
  vertices_rotados[i] = vec.mat3_vec(v, R)
end
```

### Ejemplo 2: Orientar Objeto hacia un Punto

```lua
local vec = require("vectors")

-- Posición del objeto y del objetivo
local pos_objeto = {0, 0, 0}
local pos_objetivo = {10, 5, 3}

-- Vector dirección
local direccion = {
  pos_objetivo[1] - pos_objeto[1],
  pos_objetivo[2] - pos_objeto[2],
  pos_objetivo[3] - pos_objeto[3]
}

-- Normalizar para obtener vector unitario
local dir_norm = vec.normalize(direccion)

-- Calcular ángulos (simplificado)
local yaw = math.atan2(dir_norm[1], dir_norm[3])
local pitch = math.asin(-dir_norm[2])

-- Crear matriz de rotación
local R = vec.rotacion_completa(pitch, yaw, 0)
```

### Ejemplo 3: Crear Sistema de Coordenadas Local

```lua
local vec = require("vectors")

-- Definir orientación
local forward = {0, 0, 1}  -- Hacia adelante
local up = {0, 1, 0}       -- Arriba

-- Calcular vector derecha (cross product manual)
local function cross(a, b)
  return {
    a[2]*b[3] - a[3]*b[2],
    a[3]*b[1] - a[1]*b[3],
    a[1]*b[2] - a[2]*b[1]
  }
end

local right = vec.normalize(cross(forward, up))
local up_corrected = vec.normalize(cross(right, forward))

-- Construir matriz de cambio de base
local M = {
  {right[1], right[2], right[3]},
  {up_corrected[1], up_corrected[2], up_corrected[3]},
  {-forward[1], -forward[2], -forward[3]}
}
```

---

## Performance

### Complejidad Computacional

| Operación | Complejidad | Operaciones |
|-----------|-------------|-------------|
| `dot` | O(3) | 3 mult + 2 sum |
| `normalize` | O(6) | 3 cuad + 1 sqrt + 3 div |
| `mat3_vec` | O(9) | 9 mult + 6 sum |
| `mat3_mul` | O(27) | 27 mult + 18 sum |
| `rota_x/y/z` | O(2) | 1 cos + 1 sin |
| `transpose` | O(9) | 9 asignaciones |

### Optimizaciones

1. **Pre-calcular rotaciones:** Si una matriz de rotación se usa múltiples veces, calcularla una sola vez.

```lua
-- Lento (recalcula cada frame)
for i = 1, 1000 do
  local R = vec.rota_y(angle)
  -- usar R...
end

-- Rápido (calcula una vez)
local R = vec.rota_y(angle)
for i = 1, 1000 do
  -- usar R...
end
```

2. **Evitar normalización innecesaria:** Si un vector ya está normalizado, no normalizarlo de nuevo.

3. **Usar transpuesta en lugar de inversa:** Para matrices ortonormales.

---

## Referencias

- **Implementación:** `lua/vectors.lua`
- **Matemáticas:** `docs/matematicas.md`
- **Ejemplos de uso:** `lua/main.lua`

---

📝 **Nota:** Este módulo está optimizado para claridad educativa. Para aplicaciones de producción, considerar usar bibliotecas especializadas como CPML o glm-lua.
