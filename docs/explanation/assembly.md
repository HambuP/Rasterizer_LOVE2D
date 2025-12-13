# Triangle Assembly

How do we convert 3D model data into triangles ready for rasterization? This is the critical bridge between loading a model file and rendering it on screen.

## The Model-to-Triangle Problem

3D models are typically stored as two arrays:

- **Vertices**: A list of 3D points in world space
- **Faces**: A list of polygons, each referencing vertex indices

But rasterizers can only draw **triangles**—three-sided polygons with specific properties that make them efficient to render.

**The challenge**: Convert arbitrary N-sided polygons into triangles while preserving geometry, depth, and color.

---

## Model Data Structure

### Vertices

Vertices are stored as an array of 3D coordinates:

```lua
vertices = {
  {0.0, 0.0, 0.0},    -- Vertex 1
  {1.0, 0.0, 0.0},    -- Vertex 2
  {1.0, 1.0, 0.0},    -- Vertex 3
  {0.0, 1.0, 0.0},    -- Vertex 4
  ...
}
```

Each vertex is a point in 3D space: $(x, y, z)$.

### Faces

Faces are stored as arrays of **vertex indices**:

```lua
faces = {
  {1, 2, 3},           -- Triangle (3 vertices)
  {4, 5, 6, 7},        -- Quad (4 vertices)
  {8, 9, 10, 11, 12},  -- Pentagon (5 vertices)
  ...
}
```

**Why indices?** Vertices are shared between faces—a vertex can be part of multiple polygons. Storing indices instead of duplicating coordinates saves memory.

**Example:**

- Face `{1, 2, 3}` uses vertices at positions 1, 2, and 3 in the `vertices` array
- In Lua (1-based indexing): `vertices[1]`, `vertices[2]`, `vertices[3]`

---

## The Triangle Fan Algorithm

How do we split an N-sided polygon into triangles?

### The Problem

A face with N vertices needs to become multiple triangles. How many? **N - 2** triangles.

**Examples:**
- Triangle (N=3): $3 - 2 = 1$ triangle ✓ (already a triangle)
- Quad (N=4): $4 - 2 = 2$ triangles ✓
- Pentagon (N=5): $5 - 2 = 3$ triangles ✓

### The Solution: Triangle Fan

The **triangle fan** algorithm is simple:

1. Choose one vertex as the **origin** (typically the first vertex)
2. Create triangles by connecting the origin to consecutive pairs of remaining vertices

**Visual breakdown for a quad `{1, 2, 3, 4}`:**

```
  4 -------- 3
  |          |
  |          |
  1 -------- 2

Triangle Fan from vertex 1:
  Triangle A: {1, 2, 3}
  Triangle B: {1, 3, 4}
```

![Triangle Fan](../assets/images/triangle_fan.png)

### The Algorithm

```lua
local function triangular_fan(face)
  local origin = face[1]           -- First vertex is the origin
  local tris = {}

  for i = 1, #face - 2 do
    tris[i] = { origin, face[i+1], face[i+2] }
  end

  return tris
end
```

**Step-by-step:**
1. Origin = `face[1]`
2. For each consecutive pair `(face[i+1], face[i+2])`:
   - Create triangle: `{origin, face[i+1], face[i+2]}`

**Example: Pentagon `{1, 2, 3, 4, 5}`**

- Origin = vertex 1
- Triangle 1: `{1, 2, 3}`
- Triangle 2: `{1, 3, 4}`
- Triangle 3: `{1, 4, 5}`

**Result:** 3 triangles from 5 vertices ✓

### Why Triangle Fan?

- **Simple**: Easy to understand and implement
- **Fast**: Linear time complexity $O(N)$
- **Correct**: Preserves winding order (CCW vertices → CCW triangles)
- **General**: Works for any convex polygon

**Important**: This only works correctly for **convex polygons** (all internal angles < 180°). For concave polygons, more complex triangulation algorithms are needed.

---

## The Vertex Transformation Pipeline

Before we can assemble triangles, vertices must be transformed from world space to screen space.

### Transformation Steps

1. **World space** → Camera space (view transform)
   - Apply camera rotation and translation
   - Result: Vertices relative to camera at origin

2. **Camera space** → Screen space (projection)
   - Apply perspective projection
   - Result: 2D screen coordinates

### What We Preserve

After transformation, we maintain **two representations** of each vertex:

**Camera-space vertex:**
- 3D coordinates $(x, y, z)$
- Used for **depth** (the $z$ component)

**Screen-space vertex:**
- 2D coordinates $(x_{screen}, y_{screen})$
- Used for **rasterization**

This dual representation is crucial: we need screen positions to draw, but camera-space depth for the z-buffer.

---

## The gather_tris() Function

The `gather_tris()` function is the heart of triangle assembly. It combines transformation, triangulation, and validation into a single pipeline.

### Inputs

```lua
local function gather_tris(figs, vc_all, vs_all, face_colors)
```

- **figs**: Array of model figures (each has `vertices` and `faces`)
- **vc_all**: Camera-space vertices (after view transform)
- **vs_all**: Screen-space vertices (after projection)
- **face_colors**: Per-face color assignments

### Outputs

An array of **triangle structures** ready for rasterization:

```lua
{
  p1 = {x, y},        -- Screen position of vertex 1
  p2 = {x, y},        -- Screen position of vertex 2
  p3 = {x, y},        -- Screen position of vertex 3
  z1 = depth,         -- Camera-space depth of vertex 1
  z2 = depth,         -- Camera-space depth of vertex 2
  z3 = depth,         -- Camera-space depth of vertex 3
  color = {r, g, b}   -- Face color
}
```

This structure contains everything the rasterizer needs:
- **Screen positions** for drawing
- **Depths** for z-buffer testing
- **Color** for shading

---

## Validation and Clipping

Not all triangles are valid for rendering. We must **validate** and **clip** geometry before rasterization.

### Near Plane Clipping

**Problem**: Vertices behind the camera (negative or very small $z$) cause division by zero in projection.

**Solution**: Reject triangles with any vertex too close to or behind the camera:

```lua
local near = 0.001

if v1[3] > near and v2[3] > near and v3[3] > near then
  -- Safe to rasterize (all vertices in front of camera)
else
  -- Discard triangle (at least one vertex behind camera)
end
```

**Why 0.001?** This is the **near plane distance**. Anything closer is considered behind the camera.

### Degeneracy Check

**Problem**: Vertices that are collinear (form a line, not a triangle) have zero area. Rasterizing them causes division by zero.

**Solution**: Compute the triangle's signed area using the edge function:

```lua
local A = edge(x1, y1, x2, y2, x3, y3)

if A ~= 0 then
  -- Valid triangle (non-zero area)
else
  -- Discard (degenerate triangle)
end
```

The edge function computes:

$$
A = (x_2 - x_1)(y_3 - y_1) - (y_2 - y_1)(x_3 - x_1)
$$

This is **twice the signed area** of the triangle:
- $A > 0$: Counter-clockwise (CCW) winding
- $A < 0$: Clockwise (CW) winding
- $A = 0$: Degenerate (collinear vertices)

**Why validation matters**: Without these checks, we'd attempt to rasterize invalid geometry, causing crashes or visual artifacts.

---

## Complete Assembly Algorithm

Here's the full `gather_tris()` function with all validation and triangulation logic:

```lua
local function gather_tris(figs, vc_all, vs_all, face_colors)
  local tris = {}
  local near = 0.001

  -- For each model figure
  for i, fig in ipairs(figs) do
    local vertices_c = vc_all[i]  -- Camera-space vertices
    local vertices_s = vs_all[i]  -- Screen-space vertices

    -- For each face in the figure
    for j, face in ipairs(fig.faces) do
      -- Split face into triangles using triangle fan
      local face_tris = triangular_fan(face)

      -- For each triangle in the fan
      for _, tri in ipairs(face_tris) do
        local idx1, idx2, idx3 = tri[1], tri[2], tri[3]

        -- Get camera-space vertices (for depth)
        local v1 = vertices_c[idx1]
        local v2 = vertices_c[idx2]
        local v3 = vertices_c[idx3]

        -- Near plane clipping
        if v1[3] > near and v2[3] > near and v3[3] > near then
          -- Get screen-space positions
          local p1 = vertices_s[idx1]
          local p2 = vertices_s[idx2]
          local p3 = vertices_s[idx3]

          -- Degeneracy check
          local A = edge(p1[1], p1[2], p2[1], p2[2], p3[1], p3[2])

          if A ~= 0 then
            -- Get face color
            local col = face_colors[i][j]

            -- Store complete triangle
            tris[#tris + 1] = {
              p1 = p1, p2 = p2, p3 = p3,
              z1 = v1[3], z2 = v2[3], z3 = v3[3],
              color = col
            }
          end
        end
      end
    end
  end

  return tris
end
```

### Algorithm Summary

1. **Iterate** over all model figures and faces
2. **Triangulate** each face using triangle fan
3. **Validate** each triangle:
   - Check near plane clipping (all vertices $z > 0.001$)
   - Check degeneracy (non-zero area)
4. **Package** valid triangles with screen positions, depths, and color
5. **Return** array of renderable triangles

---

## The Complete Pipeline

From loading a 3D model to rendering it on screen, here's the full pipeline:

### Step 1: Load Model

Read vertices and faces from file:

```lua
model = {
  vertices = { {x1,y1,z1}, {x2,y2,z2}, ... },
  faces = { {1,2,3}, {4,5,6,7}, ... }
}
```

### Step 2: Assign Colors

Determine per-face colors from material properties:

```lua
face_colors = {
  {r1, g1, b1},  -- Color for face 1
  {r2, g2, b2},  -- Color for face 2
  ...
}
```

### Step 3: View Transform

Transform vertices from world space to camera space:

**Input**: World-space vertices
**Transform**: Apply camera rotation and translation
**Output**: Camera-space vertices `vc_all`

Each vertex now expressed relative to camera at origin.

### Step 4: Projection

Project camera-space vertices to screen space:

**Input**: Camera-space vertices `vc_all`
**Transform**: Apply perspective projection
**Output**: Screen-space vertices `vs_all`

Each vertex now has 2D screen coordinates.

### Step 5: Triangle Assembly

Call `gather_tris()` to create renderable triangles:

**Input**: Models, camera-space vertices, screen-space vertices, colors
**Process**:
1. Triangulate faces using triangle fan
2. Validate triangles (near plane + degeneracy)
3. Package: `{screen_pos, depth, color}`

**Output**: Array of complete triangles ready for rasterization

### Step 6: Rasterization

Draw triangles using the z-buffer algorithm:

- For each pixel in triangle:
  - Interpolate depth using barycentric coordinates
  - Z-test: is this pixel closer than what's stored?
  - If yes: update z-buffer and draw pixel

---

## Example Walkthrough

Let's trace a simple quad through the entire pipeline.

### Given

**Vertices** (world space):
```lua
v1 = {0, 0, 5}
v2 = {1, 0, 5}
v3 = {1, 1, 5}
v4 = {0, 1, 5}
```

**Face**: `{1, 2, 3, 4}` (quad, CCW winding)

**Color**: `{1.0, 0.5, 0.0}` (orange)

### Step 1: Triangle Fan

Split the quad into two triangles:

- **Origin** = vertex 1
- **Triangle A**: `{1, 2, 3}`
- **Triangle B**: `{1, 3, 4}`

### Step 2: Transform to Camera Space

Assume identity camera (camera at origin, no rotation):

```lua
vc1 = {0, 0, 5}
vc2 = {1, 0, 5}
vc3 = {1, 1, 5}
vc4 = {0, 1, 5}
```

The vertices are already in camera space.

### Step 3: Project to Screen

Assume FOV = 60°, screen resolution = 800×600.

**Calculate focal length**:

$$
f = \frac{height / 2}{\tan(FOV / 2)} = \frac{300}{\tan(30°)} \approx 519.6
$$

**Project each vertex**:

For vertex 1: $(0, 0, 5)$

$$
\begin{aligned}
x_{proj} &= f \times \frac{0}{5} = 0 \\
y_{proj} &= f \times \frac{0}{5} = 0 \\
x_{screen} &= 0 + 400 = 400 \\
y_{screen} &= 300 - 0 = 300
\end{aligned}
$$

**Result**: vs1 = `{400, 300}` (screen center)

For vertex 2: $(1, 0, 5)$

$$
\begin{aligned}
x_{proj} &= 519.6 \times \frac{1}{5} = 103.9 \\
y_{proj} &= 519.6 \times \frac{0}{5} = 0 \\
x_{screen} &= 103.9 + 400 = 503.9 \\
y_{screen} &= 300 - 0 = 300
\end{aligned}
$$

**Result**: vs2 = `{503.9, 300}`

Similarly:
- vs3 ≈ `{503.9, 196.1}`
- vs4 ≈ `{400, 196.1}`

### Step 4: Assemble Triangles

Create triangle structures:

**Triangle A**: `{1, 2, 3}`

```lua
{
  p1 = {400, 300},
  p2 = {503.9, 300},
  p3 = {503.9, 196.1},
  z1 = 5,
  z2 = 5,
  z3 = 5,
  color = {1.0, 0.5, 0.0}
}
```

**Triangle B**: `{1, 3, 4}`

```lua
{
  p1 = {400, 300},
  p2 = {503.9, 196.1},
  p3 = {400, 196.1},
  z1 = 5,
  z2 = 5,
  z3 = 5,
  color = {1.0, 0.5, 0.0}
}
```

### Step 5: Validation

**Near plane check**: All depths = 5 > 0.001 ✓

**Degeneracy check**: Both triangles have non-zero area ✓

### Step 6: Ready for Rasterization!

Both triangles pass validation and are added to the `tris[]` array, ready to be drawn on screen.

---

## Why This Approach?

The triangle assembly system has several key advantages:

### Flexibility
Handles any N-sided polygon—triangles, quads, pentagons, or more complex shapes—all using the same triangle fan algorithm.

### Efficiency
Triangle fan is computationally cheap: $O(N)$ time complexity for an N-sided polygon.

### Correctness
Preserves **winding order**: CCW vertices produce CCW triangles, ensuring correct backface culling and normal orientation.

### Modularity
Clean separation of concerns:
- Transformation: Convert to camera/screen space
- Assembly: Create triangles
- Validation: Ensure renderable geometry
- Rasterization: Draw pixels

Each stage has a clear input and output, making the pipeline easy to understand and debug.

### Memory Efficiency
Vertices are stored once and referenced by index—shared vertices don't duplicate data.

---

## Summary

Triangle assembly is the bridge between 3D model data and renderable triangles.

**Key Insights:**

- **Models** store vertices (3D points) + faces (index lists)
- **Triangle fan** splits N-sided polygons into N-2 triangles
- **gather_tris()** combines transformation, triangulation, and validation
- **Output structure**: `{screen_pos, depth, color}` — everything needed for rasterization
- **Near plane clipping** prevents rendering geometry behind the camera
- **Degeneracy check** prevents invalid triangles with zero area

**What We Achieved:**

- ✅ Convert arbitrary polygons to triangles
- ✅ Preserve depth information for z-buffer
- ✅ Validate geometry before rasterization
- ✅ Create a clean pipeline from model data to renderable triangles

**The Formula:**

For an N-sided polygon:

$$
\text{Number of triangles} = N - 2
$$

Edge function (signed area):

$$
A = (x_2 - x_1)(y_3 - y_1) - (y_2 - y_1)(x_3 - x_1)
$$

Near plane test:

$$
z > 0.001
$$

With triangle assembly complete, our 3D models are now ready for the z-buffer and rasterization stages!
