# Camera and Movement

How do we move and rotate a 3D camera? This is essential for creating an interactive 3D experience where the user can explore the scene.

![Camera Diagram](../assets/images/camera.jpg)

## Camera Orientation: Yaw and Pitch

A 3D camera has several rotational degrees of freedom:

- **Yaw**: Rotation around the **Y-axis** (vertical) — turns the camera left and right
- **Pitch**: Rotation around the **X-axis** (horizontal) — tilts the camera up and down
- **Roll**: Rotation around the **Z-axis** (forward) — we'll ignore this for now

In this rasterizer, we use **yaw** and **pitch** to control camera orientation, giving us a first-person camera system.

---

## Understanding Yaw Rotation

Let's start with **yaw** — the horizontal rotation that turns the camera left and right.

### The Unit Circle View

When we rotate around the Y-axis, the **Y coordinate doesn't change** (height stays the same). We're only rotating in the XZ plane.

![Unit Circle XZ Plane](../assets/images/unitary x and z.png)

Looking down from above (the XZ plane), we can think of this as a **unit circle**:

- The **right vector** starts at $(1, 0, 0)$ — pointing in the $+X$ direction
- The **forward vector** starts at $(0, 0, 1)$ — pointing in the $+Z$ direction

### Rotating by Angle θ

If we rotate these vectors by an angle $\theta$ (yaw):

- **Right vector** becomes: $(\cos\theta, y, \sin\theta)$
- **Forward vector** becomes: $(-\sin\theta, y, \cos\theta)$

### Applying to Any Point

For a general 3D point $(x, y, z)$ rotated by yaw angle $\theta$:

$$
\begin{aligned}
x' &= \cos(\theta) \cdot x + \sin(\theta) \cdot z \\
y' &= y \\
z' &= -\sin(\theta) \cdot x + \cos(\theta) \cdot z
\end{aligned}
$$

**Key insight:** The Y component stays unchanged because yaw only rotates around the Y-axis.

---

## Rotation Matrices

We can represent this rotation more compactly using **matrix notation**.

### Expressing Points as Column Vectors

A 3D point $(x, y, z)$ can be written as a **column vector**:

$$
\mathbf{v} = \begin{bmatrix} x \\ y \\ z \end{bmatrix}
$$

### Yaw Rotation Matrix

The yaw rotation can be expressed as a $3 \times 3$ matrix:

$$
R_y(\theta) = \begin{bmatrix}
\cos\theta & 0 & \sin\theta \\
0 & 1 & 0 \\
-\sin\theta & 0 & \cos\theta
\end{bmatrix}
$$

**Matrix-vector multiplication** gives the same result as our formulas:

$$
\begin{bmatrix} x' \\ y' \\ z' \end{bmatrix} = R_y(\theta) \cdot \begin{bmatrix} x \\ y \\ z \end{bmatrix}
$$

Expanding this multiplication:

$$
\begin{bmatrix} x' \\ y' \\ z' \end{bmatrix} = \begin{bmatrix}
\cos\theta \cdot x + \sin\theta \cdot z \\
y \\
-\sin\theta \cdot x + \cos\theta \cdot z
\end{bmatrix}
$$

This matches our rotation formulas exactly!

### Pitch Rotation Matrix

Using the same technique for **pitch** (rotation around the X-axis), we get:

$$
R_x(\phi) = \begin{bmatrix}
1 & 0 & 0 \\
0 & \cos\phi & -\sin\phi \\
0 & \sin\phi & \cos\phi
\end{bmatrix}
$$

Where $\phi$ is the pitch angle.

---

## Combined Camera Rotation

To represent the full camera orientation, we combine both rotations into a single matrix.

### The Camera Rotation Matrix

$$
R_{cam} = R_y(\text{yaw}) \times R_x(\text{pitch})
$$

**Important:** The **order matters**! Matrix multiplication is **not commutative**:

$$
R_y \times R_x \neq R_x \times R_y
$$

We apply yaw first, then pitch. This matches the intuitive behavior of a first-person camera.

### Extracting Camera Axes

The resulting $R_{cam}$ matrix has a useful property: its **columns** represent the camera's local coordinate axes:

$$
R_{cam} = \begin{bmatrix}
| & | & | \\
\text{right} & \text{up} & \text{forward} \\
| & | & |
\end{bmatrix}
$$

- **1st column**: Right vector (camera's local X-axis)
- **2nd column**: Up vector (camera's local Y-axis)
- **3rd column**: Forward vector (camera's local Z-axis)

These vectors tell us which direction the camera is facing in world space.

---

## Free-Fly Movement

Now that we have the camera's orientation, we can implement movement.

### Extracting Direction Vectors

From the camera rotation matrix $R_{cam}$, we extract:

```lua
local right   = { Rcam[1][1], Rcam[2][1], Rcam[3][1] }  -- 1st column
local forward = { Rcam[1][3], Rcam[2][3], Rcam[3][3] }  -- 3rd column
```

### Movement Update

To move the camera in a direction, we update its position:

**Moving forward:**
$$
\begin{aligned}
cam.x &= cam.x + forward_x \cdot speed \cdot \Delta t \\
cam.y &= cam.y + forward_y \cdot speed \cdot \Delta t \\
cam.z &= cam.z + forward_z \cdot speed \cdot \Delta t
\end{aligned}
$$

**Strafing right:**
$$
\begin{aligned}
cam.x = cam.x + right_x \cdot speed \cdot \Delta t \\
cam.y = cam.y + right_y \cdot speed \cdot \Delta t \\
cam.z = cam.z + right_z \cdot speed \cdot \Delta t
\end{aligned}
$$

Where $\Delta t$ is the time elapsed since the last frame (delta time).

### Free-Fly Mode

This gives us **free-fly movement** — the camera can move in any direction, including up and down. It's not locked to the ground plane like a walking character would be.

For example, if you pitch the camera upward and press forward, you'll fly upward into the sky!

---

## Point Transformation Before Projection

Before we can project a 3D point to the screen, we need to transform it into **camera space**.

### Step 1: Translate to Camera-Relative Coordinates

First, express the point **relative to the camera's position**:

$$
\mathbf{p}_{rel} = \mathbf{p}_{world} - \mathbf{cam.pos}
$$

This moves the camera to the origin $(0, 0, 0)$.

### Step 2: The Naive Approach (Doesn't Work!)

You might think we should rotate the point using $R_{cam}$:

$$
\mathbf{p}_{camera} = R_{cam} \times \mathbf{p}_{rel} \quad \text{❌ WRONG!}
$$

**Why doesn't this work?**

When the camera moves to the **right**, objects in the scene should appear to move **left** on the screen. Similarly, when the camera looks up, objects should move down on screen.

The world rotates in the **opposite direction** of the camera!

### Step 3: The Correct Approach — Inverse Rotation

We need to multiply by the **inverse** of the camera rotation:

$$
\mathbf{p}_{camera} = R_{cam}^{-1} \times \mathbf{p}_{rel}
$$

**Key property:** For rotation matrices, the inverse equals the **transpose**:

$$
R_{cam}^{-1} = R_{cam}^T
$$

This is because rotation matrices are **orthogonal** (their columns are perpendicular unit vectors).

### The Complete Transformation

Putting it together:

$$
\mathbf{p}_{camera} = R_{cam}^T \times (\mathbf{p}_{world} - \mathbf{cam.pos})
$$

**Remember:** The order of operations matters! We translate first, then rotate.

---

## Complete Algorithm

Here's how the full camera transformation works in code:

```lua
-- Step 1: Build the camera rotation matrices
local function build_cam_mats()
  local Ry = rota_y(cam.yaw)         -- Yaw rotation matrix
  local Rx = rota_x(cam.pitch)       -- Pitch rotation matrix
  local Rcam = mat3_mul(Ry, Rx)      -- Combined: Rcam = Ry × Rx
  local RcamT = transpose(Rcam)      -- Inverse rotation (transpose)
  return Rcam, RcamT
end

-- Step 2: Extract movement directions
local Rcam, RcamT = build_cam_mats()
local right   = { Rcam[1][1], Rcam[2][1], Rcam[3][1] }
local forward = { Rcam[1][3], Rcam[2][3], Rcam[3][3] }

-- Step 3: Update camera position based on input
local speed = 1.5
if love.keyboard.isDown("w") then
  cam.pos.x = cam.pos.x + forward[1] * speed * dt
  cam.pos.y = cam.pos.y + forward[2] * speed * dt
  cam.pos.z = cam.pos.z + forward[3] * speed * dt
end

-- Step 4: Transform world point to camera space
local function transform_to_camera_space(point_world, cam, RcamT)
  -- Translate to camera-relative coordinates
  local rel = {
    point_world[1] - cam.pos.x,
    point_world[2] - cam.pos.y,
    point_world[3] - cam.pos.z
  }

  -- Apply inverse camera rotation (transpose)
  local point_camera = mat3_vec(rel, RcamT)

  return point_camera
end

-- Step 5: Project to screen (from previous chapter)
local function project_to_screen(point_camera, fov, width, height)
  local x, y, z = point_camera[1], point_camera[2], point_camera[3]

  if z <= 0.001 then return nil end  -- Behind camera

  local f = (height / 2.0) / math.tan(math.rad(fov) / 2.0)
  local x_proj = f * (x / z)
  local y_proj = f * (y / z)

  local x_screen = x_proj + (width / 2.0)
  local y_screen = (height / 2.0) - y_proj

  return x_screen, y_screen
end
```

---

## Summary

The camera transformation pipeline:

1. **Build rotation matrices** from yaw and pitch angles
2. **Combine them**: $R_{cam} = R_y(\text{yaw}) \times R_x(\text{pitch})$
3. **Extract direction vectors** from $R_{cam}$ columns for movement
4. **Transform points to camera space**: $R_{cam}^T \times (\mathbf{p}_{world} - \mathbf{cam.pos})$
5. **Project to screen** using perspective projection

**Key insights:**

- Yaw rotates around Y-axis (left/right)
- Pitch rotates around X-axis (up/down)
- Matrix columns give us the camera's local axes (right, up, forward)
- We use the **transpose** (inverse) of $R_{cam}$ to transform points correctly
- Matrix multiplication order **matters**

With this camera system, we can now freely navigate our 3D scene and view it from any angle!

**Next:** We'll explore the Z-buffer algorithm for correctly sorting overlapping triangles by depth.
