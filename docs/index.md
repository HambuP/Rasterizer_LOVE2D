# Rasterizador LOVE2D

Bienvenido a la documentación del **Rasterizador LOVE2D**, un motor de renderizado 3D por software implementado completamente en Lua usando el framework LÖVE2D.

![Demo del Rasterizador](https://github.com/HambuP/Rasterizador_LOVE2D/raw/main/screenshots/rasterizer.gif)

## ¿Qué es este proyecto?

Este es un **rasterizador 3D educativo** que implementa desde cero los algoritmos fundamentales de gráficos 3D, sin usar aceleración por hardware (OpenGL/DirectX). Es perfecto para entender **cómo funcionan realmente** los motores 3D.

### Características Implementadas

- 🎨 **Rasterización de triángulos** - Algoritmo edge-based con coordenadas baricéntricas
- 📐 **Proyección en perspectiva** - Campo de visión (FOV) configurable
- 🔄 **Transformaciones 3D completas** - Matrices de rotación, traslación
- 🎮 **Sistema de cámara FPS** - Controles con mouse (yaw/pitch) y teclado (WASD)
- 💾 **Z-buffer por software** - Resolución correcta de visibilidad
- 🎯 **Interpolación perspective-correct** - Profundidad interpolada correctamente
- 📏 **Triangulación automática** - Convierte polígonos en triángulos (fan algorithm)
- ⚡ **Near plane clipping** - Descarta geometría inválida
- 📚 **Código completamente documentado** - Con explicaciones matemáticas detalladas

## ¿Para quién es esto?

- 🎓 **Estudiantes** de ciencias de la computación aprendiendo gráficos 3D
- 💻 **Programadores curiosos** que quieren entender cómo funcionan los motores 3D
- 🎮 **Desarrolladores de LÖVE2D** experimentando con renderizado 3D
- 🧮 **Entusiastas de las matemáticas** interesados en álgebra lineal aplicada
- 👨‍🏫 **Profesores** buscando material educativo sobre computer graphics

## Inicio Rápido

### Requisitos

- [LÖVE2D](https://love2d.org/) 11.3 o superior
- Lua 5.1+

### Ejecutar

```bash
# Clonar el repositorio
git clone https://github.com/HambuP/Rasterizador_LOVE2D.git
cd Rasterizador_LOVE2D

# Ejecutar con LÖVE
love lua/
```

### Controles

- **Mouse:** Mover la cámara (yaw/pitch)
- **W/A/S/D:** Moverse (adelante/izquierda/atrás/derecha)
- **ESC:** Salir

## ¿Qué Aprenderás?

A través de esta documentación completa, comprenderás:

### 1. Fundamentos Matemáticos

- ✓ Álgebra lineal (vectores, matrices, producto punto)
- ✓ Matrices de rotación (Euler angles, composición)
- ✓ Proyección en perspectiva (FOV, frustum)
- ✓ Coordenadas baricéntricas (interpolación)
- ✓ Interpolación perspective-correct

### 2. Pipeline de Gráficos

- ✓ Espacios de coordenadas (modelo → mundo → cámara → pantalla)
- ✓ Transformaciones 3D (rotación, traslación)
- ✓ Proyección y clipping
- ✓ Rasterización de triángulos
- ✓ Z-buffering

### 3. Implementación Práctica

- ✓ Código Lua optimizado y legible
- ✓ Arquitectura del motor de rendering
- ✓ Técnicas de optimización
- ✓ Debugging y profiling

## Documentación Completa

### 📘 Guías Conceptuales

<div class="grid cards" markdown>

-   **[Conceptos Fundamentales](conceptos.md)**

    Explicación visual e intuitiva de cómo funciona la rasterización 3D

    - Pipeline de gráficos explicado
    - Espacios de coordenadas
    - Problema de visibilidad
    - Z-buffering ilustrado

-   **[Matemáticas Completas](matematicas.md)**

    Todas las fórmulas con derivaciones paso a paso usando LaTeX

    - Álgebra lineal básica
    - Matrices de rotación
    - Proyección en perspectiva
    - Coordenadas baricéntricas
    - Interpolación perspective-correct

</div>

### 📙 Referencias Técnicas

<div class="grid cards" markdown>

-   **[API de Vectores](api_vectores.md)**

    Documentación completa del módulo `vectors.lua`

    - Operaciones vectoriales
    - Multiplicación de matrices
    - Matrices de rotación (X, Y, Z)
    - Composición de rotaciones
    - Ejemplos de uso

-   **[Código Fuente](https://github.com/HambuP/Rasterizador_LOVE2D)**

    Código completamente comentado en GitHub

    - `lua/vectors.lua` - Álgebra lineal
    - `lua/main.lua` - Motor de rendering
    - Comentarios con fórmulas matemáticas

</div>

## Arquitectura del Proyecto

```
Rasterizador_LOVE2D/
├── lua/
│   ├── main.lua          # Motor de rendering (576 líneas)
│   ├── vectors.lua       # Álgebra lineal (410 líneas)
│   └── conf.lua          # Configuración LÖVE2D
├── docs/
│   ├── index.md          # Esta página
│   ├── conceptos.md      # Guía conceptual
│   ├── matematicas.md    # Fórmulas completas
│   └── api_vectores.md   # Referencia API
├── screenshots/
│   └── rasterizer.gif    # Demo animada
├── mkdocs.yml            # Configuración docs
├── README.md             # Resumen del proyecto
└── LICENSE               # MIT License
```

## Ejemplo de Código

### Rotar y Proyectar un Cubo

```lua
local vec = require("vectors")

-- Definir vértices de un cubo
local cubo = {
  {-1, -1, -1}, {1, -1, -1}, {1, 1, -1}, {-1, 1, -1},
  {-1, -1,  1}, {1, -1,  1}, {1, 1,  1}, {-1, 1,  1}
}

-- Crear matriz de rotación
local angulo_x = math.rad(45)
local angulo_y = math.rad(30)
local R = vec.rotacion_completa(angulo_x, angulo_y, 0)

-- Rotar todos los vértices
local cubo_rotado = {}
for i, v in ipairs(cubo) do
  cubo_rotado[i] = vec.mat3_vec(v, R)
end

-- Proyectar en pantalla (simplificado)
local fov = 60
local proyectados = proyectar_vertices(cubo_rotado, fov, 800, 600)
```

## Pipeline Implementado

```
┌──────────────────┐
│  Modelo 3D       │  Vértices + Caras
│  (5 figuras)     │  - Piso (81 vértices)
└────────┬─────────┘  - Árboles (4)
         │            - Personaje (1)
         ↓
┌──────────────────┐
│  Transformación  │  • Rotación (matrices 3×3)
│  Mundial         │  • Traslación
└────────┬─────────┘  • Cambio de base a cámara
         ↓
┌──────────────────┐
│  Proyección      │  • FOV = 60°
│  Perspectiva     │  • Near plane = 0.001
└────────┬─────────┘  • División por Z
         ↓
┌──────────────────┐
│  Triangulación   │  • Triangular fan
│  y Clipping      │  • Descarte de degenerados
└────────┬─────────┘  • Test de área > ε
         ↓
┌──────────────────┐
│  Rasterización   │  • Edge function
│  con Z-Buffer    │  • Coordenadas baricéntricas
└────────┬─────────┘  • Interpolación depth
         ↓            • Z-buffer test
┌──────────────────┐
│  Framebuffer     │  Imagen final: 820×580
│  (Pantalla)      │  Escalada a resolución de ventana
└──────────────────┘
```

## Performance

### Especificaciones Técnicas

| Parámetro | Valor |
|-----------|-------|
| **Resolución de rendering** | 820×580 (475,600 píxeles) |
| **Z-buffer** | 1 float por píxel (~1.8 MB) |
| **Escena de prueba** | ~290 vértices, ~200 caras |
| **Framerate** | 60 FPS (CPU moderna) |
| **Complejidad** | O(triángulos × píxeles_cubiertos) |

### Optimizaciones Implementadas

- ✓ Bounding box (evita testar píxeles fuera del triángulo)
- ✓ Near plane clipping (descarta geometría inválida temprano)
- ✓ Degeneracy test (evita procesar triángulos colapsados)
- ✓ Pre-cálculo de 1/A (evita divisiones en inner loop)

## Limitaciones (por diseño educativo)

- ❌ Sin texturas (solo colores planos)
- ❌ Sin iluminación dinámica (Phong/Blinn-Phong)
- ❌ Sin anti-aliasing
- ❌ Sin backface culling explícito
- ❌ Sin far plane clipping
- ❌ Sin transparencia/blending

**Nota:** Estas son oportunidades de aprendizaje. ¡Intenta implementarlas tú mismo!

## Comparación con GPU Modernas

| Característica | Este Rasterizador (CPU) | GPU Moderna |
|----------------|-------------------------|-------------|
| Triángulos/frame | ~1,000-10,000 | Millones |
| Paralelismo | Secuencial | Miles de cores |
| Shaders | No (colores fijos) | Sí (programables) |
| Texturas | No | Sí (aceleradas) |
| Velocidad | ~60 FPS | 100+ FPS |
| **Claridad educativa** | ⭐⭐⭐⭐⭐ | ⭐ (caja negra) |

## Contribuir

Este es un proyecto **educativo abierto**. Las contribuciones son bienvenidas:

### Ideas para Contribuir

- 📝 Mejorar documentación
- 🐛 Reportar/arreglar bugs
- ✨ Implementar nuevas features (texturas, iluminación, etc.)
- 🎓 Crear tutoriales adicionales
- 🌍 Traducir documentación

### Proceso

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/mi-feature`)
3. Commit tus cambios con mensajes descriptivos
4. Push a tu fork (`git push origin feature/mi-feature`)
5. Abre un Pull Request

**GitHub:** [https://github.com/HambuP/Rasterizador_LOVE2D](https://github.com/HambuP/Rasterizador_LOVE2D)

## Recursos Adicionales

### Tutoriales Online

- **Scratchapixel:** [https://www.scratchapixel.com/](https://www.scratchapixel.com/)
- **LearnOpenGL:** [https://learnopengl.com/](https://learnopengl.com/)
- **TinyRenderer:** [https://github.com/ssloy/tinyrenderer/wiki](https://github.com/ssloy/tinyrenderer/wiki)

### Libros Recomendados

1. **"Real-Time Rendering" (4th Ed.)** - Akenine-Möller et al.
2. **"Fundamentals of Computer Graphics" (5th Ed.)** - Marschner & Shirley
3. **"Computer Graphics: Principles and Practice" (3rd Ed.)** - Hughes et al.

### Videos

- **3Blue1Brown:** Álgebra lineal visual
- **The Cherno:** Serie de OpenGL

## Licencia

**MIT License** - Libre de usar, modificar y distribuir.

Ver [LICENSE](https://github.com/HambuP/Rasterizador_LOVE2D/blob/main/LICENSE) para detalles.

---

## ¡Comienza Ahora!

<div class="grid cards" markdown>

-   **[📖 Conceptos Fundamentales](conceptos.md)**

    Entiende los conceptos básicos de rasterización con explicaciones visuales

-   **[🧮 Matemáticas Completas](matematicas.md)**

    Todas las fórmulas con LaTeX y derivaciones paso a paso

-   **[⚙️ API de Vectores](api_vectores.md)**

    Referencia completa del módulo de álgebra lineal

-   **[💻 Código Fuente](https://github.com/HambuP/Rasterizador_LOVE2D)**

    Explora el código completamente comentado en GitHub

</div>

---

💡 **Tip:** Lee primero [Conceptos Fundamentales](conceptos.md) para una introducción visual, luego explora [Matemáticas](matematicas.md) para los detalles técnicos.