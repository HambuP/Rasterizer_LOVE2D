# Conceptos Fundamentales de Rasterización 3D

Esta guía explica los conceptos clave detrás del rasterizador desde una perspectiva conceptual y práctica.

## Tabla de Contenidos

1. [¿Qué es la Rasterización?](#que-es-la-rasterizacion)
2. [Pipeline de Gráficos 3D](#pipeline-de-graficos-3d)
3. [Espacios de Coordenadas](#espacios-de-coordenadas)
4. [El Problema de Visibilidad](#el-problema-de-visibilidad)
5. [Proyección en Perspectiva](#proyeccion-en-perspectiva-explicada)
6. [Cómo Funciona el Z-Buffer](#como-funciona-el-z-buffer)

---

## ¿Qué es la Rasterización?

La **rasterización** es el proceso de convertir geometría 3D (triángulos, líneas, puntos) en píxeles 2D en una pantalla.

### Analogía Visual

Imagina que tienes un **modelo 3D de una casa** y quieres dibujarlo en un lienzo 2D:

```
Modelo 3D              Rasterización           Imagen 2D
   📦                       →                    🖼️
(geometría)                                  (píxeles)
```

**El proceso:**

1. **Entrada:** Lista de triángulos en 3D
2. **Proceso:** Determinar qué píxeles cubre cada triángulo
3. **Salida:** Imagen 2D con píxeles coloreados

### Rasterización vs Ray Tracing

| Aspecto | Rasterización | Ray Tracing |
|---------|---------------|-------------|
| **Enfoque** | Para cada triángulo → encontrar píxeles | Para cada píxel → encontrar triángulo |
| **Velocidad** | Rápida (tiempo real) | Lenta (offline) |
| **Calidad** | Buena | Fotorrealista |
| **Iluminación** | Aproximada | Físicamente correcta |
| **Reflejos** | Difícil | Natural |
| **Uso** | Videojuegos, apps interactivas | Películas, renders estáticos |

---

## Pipeline de Gráficos 3D

El pipeline de gráficos es el flujo de transformaciones que convierte un modelo 3D en una imagen 2D.

### Pipeline Completo

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. ESPACIO DE MODELO (Model Space)                             │
│    • Vértices definidos en coordenadas locales del objeto      │
│    • Ejemplo: cubo centrado en (0,0,0) con lado = 2           │
└─────────────────────────────────────────────────────────────────┘
                           │
                           │ Transformación de Modelo
                           │ (Rotación + Traslación + Escala)
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│ 2. ESPACIO MUNDIAL (World Space)                               │
│    • Vértices en el sistema de coordenadas del mundo           │
│    • Ejemplo: cubo en posición (10, 5, 3) en el mundo         │
└─────────────────────────────────────────────────────────────────┘
                           │
                           │ Transformación de Vista
                           │ (Traslación + Rotación de cámara)
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│ 3. ESPACIO DE CÁMARA (View/Camera Space)                       │
│    • Vértices relativos a la cámara                            │
│    • Cámara está en origen, mirando hacia -Z                   │
└─────────────────────────────────────────────────────────────────┘
                           │
                           │ Proyección en Perspectiva
                           │ (División por Z)
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│ 4. ESPACIO DE CLIP (Clip Space)                                │
│    • Coordenadas normalizadas (-1 a +1)                        │
│    • Clipping de geometría fuera de view frustum               │
└─────────────────────────────────────────────────────────────────┘
                           │
                           │ Conversión a Pantalla
                           │ (Escala + Offset)
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│ 5. ESPACIO DE PANTALLA (Screen Space)                          │
│    • Coordenadas en píxeles (x, y)                             │
│    • Ejemplo: (400, 300) en una pantalla 800×600              │
└─────────────────────────────────────────────────────────────────┘
                           │
                           │ Rasterización
                           │ (Convertir triángulos a píxeles)
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│ 6. FRAGMENTOS (Fragments)                                       │
│    • Píxeles candidatos con atributos interpolados             │
│    • Cada fragmento tiene: posición, color, profundidad        │
└─────────────────────────────────────────────────────────────────┘
                           │
                           │ Z-Buffer Test
                           │ (Determinar visibilidad)
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│ 7. FRAMEBUFFER (Imagen Final)                                  │
│    • Píxeles finales en pantalla                                │
│    • Solo los fragmentos visibles sobreviven                    │
└─────────────────────────────────────────────────────────────────┘
```

### Ejemplo Numérico

Seguir un vértice a través del pipeline:

```lua
-- 1. ESPACIO DE MODELO
v_model = {1, 0, 0}  -- Esquina derecha de un cubo

-- 2. ESPACIO MUNDIAL (rotar 45° + trasladar)
-- Rotación Y de 45°:
v_world = {0.707, 0, 0.707}
-- Traslación:
v_world = {0.707, 0, 0.707 + 5} = {0.707, 0, 5.707}

-- 3. ESPACIO DE CÁMARA (cámara en z=-2, sin rotación)
v_camera = {0.707, 0, 5.707 - (-2)} = {0.707, 0, 7.707}

-- 4. PROYECCIÓN (FOV=60°, pantalla 800×600)
fx = 502  -- distancia focal
x_screen = 502 × (0.707 / 7.707) + 400 = 446
y_screen = 300  -- (y=0 → centro)
-- Resultado: píxel (446, 300)
```

---

## Espacios de Coordenadas

### Sistema de Coordenadas de la Cámara

```
        Y (Arriba)
        ↑
        |
        |
        +-------→ X (Derecha)
       /
      /
     Z (Atrás)

La cámara mira hacia -Z
```

**Convenciones:**

- **+X:** Derecha de la cámara
- **+Y:** Arriba de la cámara
- **+Z:** Atrás de la cámara (⚠️ cámara mira hacia **-Z**)

### View Frustum

El **frustum** es la pirámide truncada que define qué geometría es visible:

```
         Near Plane
            |   \
            |    \
            |     \  ← FOV
      ------+------\
     /      |       \
    /       |        \
   /        |         \
  /____________________|
         Far Plane
```

**Parámetros:**

- **Near plane:** Distancia mínima visible (ej: 0.1)
- **Far plane:** Distancia máxima visible (ej: 1000)
- **FOV:** Campo de visión (ej: 60°)
- **Aspect ratio:** Relación ancho/alto (ej: 16/9)

Geometría **fuera** del frustum se descarta (clipping).

---

## El Problema de Visibilidad

### ¿Qué Triángulo Está Adelante?

Cuando múltiples triángulos cubren el mismo píxel, ¿cuál dibujar?

```
Escena 3D (vista lateral):

  Cámara     T1 (cerca)   T2 (lejos)
    👁️ --------🔴----------🔵------
              z=2         z=5
```

**Soluciones:**

#### 1. Painter's Algorithm (Ordenar por Profundidad)

```
1. Ordenar triángulos de atrás → adelante
2. Dibujar en ese orden
```

**Problema:** No funciona con intersecciones cíclicas:

```
    A
   /|\
  / | \
 /  B  \
/  / \  \
\ /   \ /
 C-----+
```

¿Orden correcto? A→B→C→A... ❌ (ciclo infinito)

#### 2. Z-Buffer (Buffer de Profundidad)

```
Para cada píxel:
  zbuffer[píxel] = ∞  (inicialmente)

Para cada triángulo:
  Para cada píxel cubierto:
    if z < zbuffer[píxel]:
      dibujar píxel
      zbuffer[píxel] = z
```

**Ventaja:** Funciona siempre, sin importar el orden. ✓

---

## Proyección en Perspectiva Explicada

### La Cámara Pinhole

```
Mundo 3D              Plano de proyección       Imagen

    O                        |                    o
   /|\                       |                   /|\
  / | \        →             |        →          | |
     P                       |                    p
   (alto)                    |                 (bajo)
```

**Intuición:** Objetos lejanos se proyectan más cerca del centro.

### Fórmula Visual

Para un punto $(x, y, z)$ en espacio de cámara:

$$
x_{\text{proyectado}} = \frac{x}{z} \quad \text{(dividir por profundidad)}
$$

**Ejemplo:**

```
Dos puntos a la misma altura (y=1):
  • P1 = (1, 1, 2)  → x_proj = 1/2 = 0.5
  • P2 = (1, 1, 4)  → x_proj = 1/4 = 0.25

P2 está más lejos, así que se proyecta más cerca del centro.
```

### Campo de Visión (FOV)

El FOV determina cuánto del mundo es visible:

```
FOV pequeño (30°):          FOV grande (90°):
      |  |                       |      |
      |  |                       |      |
    --|--|--                   --|------|--
      |  |                       |      |
   (zoom in)                  (zoom out)
```

**Relación:**

- FOV alto → Ve más del mundo → Objetos parecen pequeños
- FOV bajo → Ve menos del mundo → Objetos parecen grandes (efecto zoom)

---

## Cómo Funciona el Z-Buffer

### Visualización Paso a Paso

**Frame inicial:**

```
Color buffer:          Z-buffer:
┌─────────┐           ┌─────────┐
│░░░░░░░░░│           │∞∞∞∞∞∞∞∞∞│
│░░░░░░░░░│           │∞∞∞∞∞∞∞∞∞│
│░░░░░░░░░│           │∞∞∞∞∞∞∞∞∞│
└─────────┘           └─────────┘
(negro)               (infinito)
```

**Dibujar triángulo rojo (z=5):**

```
Color buffer:          Z-buffer:
┌─────────┐           ┌─────────┐
│░░🔴🔴🔴░░│           │∞∞555∞∞∞│
│░🔴🔴🔴🔴░│           │∞5555555∞│
│░░🔴🔴🔴░░│           │∞∞555∞∞∞│
└─────────┘           └─────────┘
```

**Dibujar triángulo azul (z=3, más cerca):**

```
                         Comparación Z:
Color buffer:              5 vs 3
┌─────────┐           ┌─────────┐
│░🔵🔵🔵🔴░│    3<5    │∞3335533∞│
│🔵🔵🔵🔵🔵🔴│   (azul    │3333335∞│
│░🔵🔵🔵🔴░░│   gana)   │∞3335533∞│
└─────────┘           └─────────┘
```

**Resultado:** El triángulo azul (más cerca) oculta parcialmente al rojo.

### Pseudocódigo Detallado

```
function rasterizar_triángulo(T):
  para cada píxel (x, y) dentro de T:
    # 1. Interpolar profundidad
    z = interpolar_profundidad(T, x, y)

    # 2. Probar z-buffer
    if z < zbuffer[x, y]:
      # 3. Este fragmento está más cerca
      zbuffer[x, y] = z
      color[x, y] = color_triángulo

      # 4. (opcional) Calcular iluminación
      # color[x, y] = iluminar(T, x, y)
```

### Precisión y Z-Fighting

**Problema:** Cuando dos superficies están muy cerca, pueden "pelear" por píxeles:

```
Frame 1:  🔴🔴🔵🔴🔴
Frame 2:  🔴🔵🔵🔵🔴  ← Parpadeo!
Frame 3:  🔴🔴🔵🔴🔴
```

**Causas:**

1. Precisión limitada de float (32 bits)
2. Near/far planes muy separados
3. Superficies coplanares

**Soluciones:**

- Separar ligeramente las superficies
- Ajustar near/far planes
- Usar mayor precisión (64 bits)
- Polygon offset

---

## Coordenadas Baricéntricas Explicadas

### ¿Qué Son?

Las coordenadas baricéntricas expresan la **posición** de un punto dentro de un triángulo como **pesos** de los vértices.

### Visualización

```
      v1
      /\
     /  \
  w1/    \w2
   / P•   \
  /  w3    \
 /__________\
v3          v2

P = w1×v1 + w2×v2 + w3×v3
donde w1 + w2 + w3 = 1
```

**Interpretación:**

- $w_1 = 1, w_2 = 0, w_3 = 0$ → P está en v1
- $w_1 = 0.5, w_2 = 0.5, w_3 = 0$ → P está en el punto medio de v1-v2
- $w_1 = w_2 = w_3 = 1/3$ → P está en el **centroide** del triángulo

### Uso en Interpolación

Para interpolar cualquier atributo (color, textura, normal):

```lua
-- Vértices con colores
v1 = {pos={0,1,0}, color={1,0,0}}  -- Rojo
v2 = {pos={-1,-1,0}, color={0,1,0}}  -- Verde
v3 = {pos={1,-1,0}, color={0,0,1}}  -- Azul

-- Punto P con coordenadas baricéntricas
w1, w2, w3 = 0.5, 0.25, 0.25

-- Color interpolado
color_P = {
  r = 0.5×1 + 0.25×0 + 0.25×0 = 0.5,
  g = 0.5×0 + 0.25×1 + 0.25×0 = 0.25,
  b = 0.5×0 + 0.25×0 + 0.25×1 = 0.25
}
-- Resultado: Naranja (mezcla de rojo dominante)
```

---

## Optimizaciones y Técnicas Avanzadas

### Bounding Box

En lugar de testar **todos** los píxeles de la pantalla:

```
❌ Naïve:
Probar 800×600 = 480,000 píxeles por triángulo

✓ Bounding box:
1. Calcular rectángulo mínimo que contiene el triángulo
2. Solo probar píxeles dentro del rectángulo
3. Típicamente 10-100× más rápido
```

### Backface Culling

No dibujar triángulos que miran hacia atrás:

```
    Frente        Atrás
     /\            /\
    /  \          /  \
   /    \        /    \
  --------      --------
    👁️             👁️
  (dibujar)     (descartar)
```

**Test:** Si el producto punto entre la normal y la dirección de vista es negativo, descartar.

### Early Z-Test

Probar z-buffer **antes** de calcular color:

```
Para cada píxel:
  z = interpolar_profundidad()

  if z > zbuffer[píxel]:
    return  # Este píxel está oculto, skip!

  # Solo calcular color si es visible
  color = calcular_iluminacion()
  ...
```

**Ahorro:** Evita cálculos costosos de shading para píxeles ocultos.

---

## Comparación con GPU Modernas

Este rasterizador implementa los conceptos fundamentales que usan las GPU, pero de forma simplificada:

| Concepto | Rasterizador (CPU) | GPU Moderna |
|----------|-------------------|-------------|
| **Paralelismo** | Secuencial | Miles de cores |
| **Shaders** | Colores planos | Programables (GLSL) |
| **Texturas** | No implementado | Hardware acelerado |
| **Iluminación** | No | Shaders personalizados |
| **Anti-aliasing** | No | MSAA, FXAA, TAA |
| **Performance** | ~1000 tris/frame | Millones/frame |

**Ventaja educativa:** Este código es **comprensible** y muestra claramente cómo funcionan los algoritmos.

---

## Próximos Pasos

Después de entender estos conceptos, puedes explorar:

1. **[Matemáticas Detalladas](matematicas.md):** Fórmulas y demostraciones completas
2. **[API de Vectores](api_vectores.md):** Cómo usar las funciones de álgebra lineal
3. **[Código Fuente](https://github.com/HambuP/Rasterizador_LOVE2D):** Implementación completa

---

## Referencias y Recursos

### Tutoriales Online

- **Scratchapixel:** https://www.scratchapixel.com/
  - Explicaciones matemáticas detalladas
- **LearnOpenGL:** https://learnopengl.com/
  - Tutoriales de OpenGL (conceptos similares)
- **TinyRenderer:** https://github.com/ssloy/tinyrenderer/wiki
  - Implementar un rasterizador desde cero (C++)

### Libros Recomendados

1. **"Real-Time Rendering" (4th Ed.)** - Akenine-Möller et al.
   - La biblia de gráficos en tiempo real
2. **"Fundamentals of Computer Graphics" (5th Ed.)** - Marschner & Shirley
   - Excelente introducción académica
3. **"Computer Graphics: Principles and Practice" (3rd Ed.)** - Hughes et al.
   - Clásico completo de CG

### Videos

- **3Blue1Brown:** Álgebra lineal visual
  - https://www.youtube.com/c/3blue1brown
- **The Cherno:** Serie de OpenGL
  - https://www.youtube.com/c/TheChernoProject

---

💡 **Experimento:** Intenta modificar el código para agregar nuevas features (texturas, iluminación, etc.). La mejor forma de aprender es implementando!
