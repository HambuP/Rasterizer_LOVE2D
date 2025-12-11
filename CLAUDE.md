# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **software 3D rasterizer** implemented entirely in Lua using the LÖVE2D framework. It's an educational project that demonstrates fundamental 3D graphics algorithms without hardware acceleration (no OpenGL/DirectX).

**Framework:** LÖVE2D (love2d.org)
**Language:** Lua 5.1+
**Purpose:** Educational - understanding how 3D rendering works at a low level

## Running the Project

```bash
# Run with LÖVE (from project root)
love lua/

# Alternative: Run from lua directory
cd lua/
love .
```

**Controls:**
- Mouse: Camera orientation (yaw/pitch)
- W/A/S/D: Movement (forward/left/back/right)
- ESC: Exit

## Architecture

### Core Components

**`lua/vectors.lua`** - Linear algebra module (410 lines)
- Vector operations (dot product, normalization)
- 3×3 matrix multiplication
- Rotation matrices (X, Y, Z axes)
- Euler angle composition
- Matrix transpose (for orthonormal inverses)

**`lua/main.lua`** - Rendering engine (1056 lines)
- Camera system with FPS controls
- 3D transformations (world → camera space)
- Perspective projection
- Triangle rasterization with z-buffer
- Barycentric coordinate interpolation
- Scene management

**`lua/conf.lua`** - LÖVE2D configuration
- Window settings (1056×656 default)
- Console enabled for debugging

### Rendering Pipeline

```
Model Space (vertices + faces)
    ↓
World Space (rotation matrices)
    ↓
Camera Space (view transform: RcamT × (world - cam.pos))
    ↓
Projection (perspective with FOV)
    ↓
Triangulation (triangular fan for quads)
    ↓
Clipping (near plane, degeneracy test)
    ↓
Rasterization (edge function + barycentric coords)
    ↓
Z-Buffer Test (visibility)
    ↓
Framebuffer (820×580 render target)
```

### Key Algorithms

**Triangulation** (`triangular_fan`)
- Converts convex polygons to triangles
- Fan algorithm: [v1,v2,v3], [v1,v3,v4], ...
- Only works with convex polygons

**Camera Transforms** (`build_cam_mats`)
- R_cam = R_y(yaw) × R_x(pitch)
- Inverse: R_cam^(-1) = R_cam^T (orthonormal property)
- Transforms: v_camera = RcamT × (v_world - cam.pos)

**Projection** (`proyectar_vertices`)
- Perspective projection with configurable FOV
- Near plane clipping (z > 0.001)
- Formula: x_screen = f_x × (x/z) + center_x

**Rasterization** (`rasterize_with_zbuffer`)
- Edge function for barycentric coordinates
- Bounding box optimization
- Perspective-correct depth interpolation: interpolate 1/z, then z = 1/(1/z)
- Z-buffer test for visibility

## Mathematical Conventions

- **Coordinate System:** Right-handed (OpenGL convention)
- **Angles:** Always in radians
- **Camera Axes:**
  - +X: Right
  - +Y: Up
  - +Z: Backward (camera looks toward -Z)
- **Rotation Order:** Z-Y-X (roll-yaw-pitch)
- **Face Winding:** CCW (counter-clockwise) for front faces

## Scene Definition

The scene in `love.load()` contains:
1. **Floor:** 8×8 subdivided grid (81 vertices, 64 quads)
2. **Trees:** 4 pine trees with tiered foliage (23 vertices each)
3. **Character:** Simple humanoid figure (48 vertices)

Each figure is defined as:
```lua
{
  { -- Vertex list: {x, y, z}
    {x1, y1, z1}, {x2, y2, z2}, ...
  },
  { -- Face list: indices (1-based)
    {v1, v2, v3, v4}, ... -- Quads or triangles
  }
}
```

**Color Assignment:** `assign_material_colors()` assigns colors based on vertex/face counts:
- Floor: Checkerboard pattern (green shades)
- Trees: Brown trunk + green foliage (3 shades)
- Character: Neutral gray

## Performance Characteristics

- **Render Resolution:** 820×580 (~476K pixels)
- **Z-Buffer:** 1 float per pixel (~1.8 MB)
- **Typical Scene:** ~290 vertices, ~200 faces
- **Target FPS:** 60 (achievable on modern CPUs)
- **Complexity:** O(triangles × pixels_covered)

**Optimizations:**
- Bounding box clipping (avoid testing pixels outside triangle)
- Near plane clipping (discard invalid geometry early)
- Degeneracy test (skip collapsed triangles, area < 1e-6)
- Pre-computed 1/A (avoid division in inner loop)

## Code Style

- **Documentation:** Extensive block comments with mathematical explanations
- **Naming:** Spanish identifiers (e.g., `proyectar_vertices`, `rotacion_completa`)
- **Math Notation:** Uses Unicode symbols in comments (×, ×, ≥, ∈, etc.)
- **Comment Structure:**
  ```lua
  --[[
  FUNCIÓN: nombre(parámetros)
  Descripción

  PARÁMETROS:
    ...

  RETORNA:
    ...

  MATEMÁTICA:
    Fórmulas y explicaciones
  ]]--
  ```

## Testing & Debugging

- **Console Output:** `t.console = true` in conf.lua
- **Inspect Module:** Uses `inspect.lua` for debugging (package.path configured)
- **Visual Debugging:** Move camera with WASD to inspect geometry
- **Performance:** Monitor FPS in LÖVE console

## Common Modifications

**Change FOV:**
```lua
-- In love.load()
fov = 90 -- Wider field of view
```

**Change Camera Speed:**
```lua
-- In love.update()
local speed = 3.0 -- Faster movement
```

**Change Render Resolution:**
```lua
-- In love.load()
RENDER_W, RENDER_H = 1024, 768 -- Higher quality
```

**Add New Geometry:**
1. Define vertices and faces in `figuras` table in `love.load()`
2. Update `assign_material_colors()` to detect new figure type
3. Ensure faces are CCW winding

## Documentation

Comprehensive documentation in `docs/`:
- **`index.md`** - Main documentation hub (330 lines)
- **`conceptos.md`** - Conceptual explanations with diagrams
- **`matematicas.md`** - Complete mathematical derivations (LaTeX)
- **`api_vectores.md`** - vectors.lua API reference

Built with **MkDocs** using Material theme:
```bash
# Serve docs locally
mkdocs serve

# Build static docs
mkdocs build
```

## Known Limitations (By Design)

These are intentional for educational clarity:
- No textures (flat colors only)
- No dynamic lighting (Phong/Blinn-Phong)
- No anti-aliasing
- No explicit backface culling
- No far plane clipping
- No transparency/blending

## References

The codebase references these concepts:
- **Scratchapixel:** Perspective projection, rasterization
- **Real-Time Rendering:** Z-buffer algorithms
- **Computer Graphics Principles:** Barycentric coordinates
- **Quake/Doom:** Software rasterization techniques (90s era)

## License

MIT License - Free to use, modify, and distribute.
