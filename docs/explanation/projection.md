# Basics of 3D Projection

How do we project a 3D point onto a 2D screen? This is the fundamental question that every 3D renderer must answer.

![Perspective Projection Diagram](../assets/images/Perspective.png)

## The Projection Problem

We have:
- A **camera** at position $(c_x, c_y, c_z)$
- A **3D point** in world space at $(x_1, y_1, z_1)$
- A **2D screen** (image plane) where we want to draw

Our goal: Find the 2D coordinates $(x_{screen}, y_{screen})$ where this 3D point appears on the screen.

---

## The Perspective Projection Model

In perspective projection, we simulate how a real camera works:

1. Light from a 3D point travels through a **projection center** (the camera)
2. It intersects with an **image plane** (the screen)
3. Where it intersects is where we draw the pixel

### Key Components

- **Projection Center**: The camera position (a single point in 3D space)
- **Image Plane**: The virtual screen positioned at distance $f$ from the camera
- **Focal Length** ($f$): The distance from the camera to the image plane
- **Field of View (FOV)**: How "wide" the camera can see (measured in degrees)

**Note:** Traditional graphics use a **near plane** and **far plane** for clipping, but in our implementation, we use the **near plane as our image plane** for simplicity.

---

## Field of View (FOV)

The **FOV** determines how much of the scene the camera can see:

- **Narrow FOV** (e.g., 30°): Telephoto lens, zoomed in, little distortion
- **Normal FOV** (e.g., 60°): Human-like vision
- **Wide FOV** (e.g., 90°+): Wide-angle lens, fisheye effect

**Relationship:** The FOV and focal length are inversely related—wider FOV means shorter focal length.

---

## Step 1: Transform to Camera Space

Before projection, we must **move the camera to the origin** $(0, 0, 0)$. This simplifies the math.

### World Space → Camera Space

For a 3D point $(x_{world}, y_{world}, z_{world})$ and camera at $(c_x, c_y, c_z)$:

$$
\begin{aligned}
x_{rel} &= x_{world} - c_x \\
y_{rel} &= y_{world} - c_y \\
z_{rel} &= z_{world} - c_z
\end{aligned}
$$

Now the point is expressed **relative to the camera**, which we treat as the origin.

---

## Step 2: Calculate Focal Length

The **focal length** ($f$) is computed from the FOV and screen dimensions.

### The Formula

For the vertical axis:

$$
\tan\left(\frac{FOV}{2}\right) = \frac{height / 2}{f}
$$

Solving for $f$:

$$
f = \frac{height / 2}{\tan(FOV / 2)}
$$

### Why This Works

- At distance $f$ from the camera, the image plane has height exactly equal to `height` pixels
- The FOV determines the viewing angle, which relates to the ratio $\frac{height}{f}$
- Larger FOV → smaller $f$ → more distortion (wide angle)
- Smaller FOV → larger $f$ → less distortion (telephoto)

### Horizontal Focal Length

To **maintain aspect ratio**, we set:

$$
f_x = f_y = f
$$

This ensures circles stay circular and squares stay square.

---

## Step 3: Project to Screen Coordinates

Now we apply the **perspective division**—the heart of perspective projection.

### The Projection Formulas

For a 3D point $(x_{rel}, y_{rel}, z_{rel})$ in camera space:

$$
\begin{aligned}
x_{proj} &= f \times \frac{x_{rel}}{z_{rel}} \\
y_{proj} &= f \times \frac{y_{rel}}{z_{rel}}
\end{aligned}
$$

**Key insight:** We divide by $z$! This is why distant objects appear smaller—larger $z$ makes the result smaller.

### Why Division by Z?

Consider two points at the same $x$ but different depths:

- Point A: $(x=1, z=2)$ → $x_{proj} = f \times \frac{1}{2} = 0.5f$
- Point B: $(x=1, z=4)$ → $x_{proj} = f \times \frac{1}{4} = 0.25f$

Point B is twice as far, so it appears **half the size**—this is perspective!

---

## Step 4: Convert to Pixel Coordinates

The projected coordinates $(x_{proj}, y_{proj})$ are centered at the **optical center** of the camera, where $(0, 0)$ is the middle of the screen.

But in screen coordinates, $(0, 0)$ is the **top-left corner**. We need to shift:

$$
\begin{aligned}
x_{screen} &= x_{proj} + \frac{width}{2} \\
y_{screen} &= \frac{height}{2} - y_{proj}
\end{aligned}
$$

**Note the minus sign for $y$!** In camera space, $+y$ points **up**. In screen space, $+y$ points **down**.

---

## Complete Projection Algorithm

Putting it all together:

```lua
function project_point_to_screen(point_world, camera, fov, width, height)
    -- Step 1: Transform to camera space
    local x_rel = point_world.x - camera.x
    local y_rel = point_world.y - camera.y
    local z_rel = point_world.z - camera.z

    -- Step 2: Calculate focal length
    local fov_rad = math.rad(fov)
    local f = (height / 2.0) / math.tan(fov_rad / 2.0)

    -- Step 3: Project (perspective division)
    local x_proj = f * (x_rel / z_rel)
    local y_proj = f * (y_rel / z_rel)

    -- Step 4: Convert to screen coordinates
    local x_screen = x_proj + (width / 2.0)
    local y_screen = (height / 2.0) - y_proj

    return x_screen, y_screen
end
```

---

## Important Edge Cases

### Points Behind the Camera

If $z_{rel} \leq 0$, the point is **behind** the camera and should **not be drawn**.

We use a **near plane** threshold:

```lua
local near = 0.001
if z_rel > near then
    -- Safe to project
else
    -- Discard (behind camera or too close)
end
```

### Points Outside Screen

After projection, check if the point is visible:

```lua
if x_screen >= 0 and x_screen < width and
   y_screen >= 0 and y_screen < height then
    -- Point is on screen
end
```

---

## Summary

Perspective projection in 4 steps:

1. **Transform to camera space**: Subtract camera position
2. **Calculate focal length**: From FOV and screen size
3. **Perspective division**: Divide by $z$ to get projected coordinates
4. **Convert to pixels**: Shift origin from center to top-left corner

The key insight: **Division by $z$** creates perspective—distant objects appear smaller because we divide by a larger number.

**Next:** We'll use this projection to build a complete 3D rasterizer with camera controls!
