# 3D Software Rasterizer

A simple 3D software rasterizer built from scratch in Lua using LÖVE2D. No GPU acceleration—just pure CPU rendering to understand how 3D graphics really work.

![Demo](https://github.com/HambuP/Rasterizador_LOVE2D/raw/main/screenshots/rasterizer.gif)

## Characteristics

This rasterizer implements fundamental 3D rendering algorithms from scratch:

- **Triangle rasterization** using edge functions and barycentric coordinates
- **Perspective projection** with configurable field of view
- **Z-buffering** for correct depth sorting
- **Perspective-correct interpolation** for depth values
- **FPS camera** with mouse look (yaw/pitch) and WASD movement
- **3D transformations** with rotation matrices

## Requirements & Controls

### Requirements

- [LÖVE2D](https://love2d.org/) 11.3 or higher
- Lua 5.1+

### Running

```bash
git clone https://github.com/HambuP/Rasterizador_LOVE2D.git
cd Rasterizador_LOVE2D
love lua/
```

### Controls

- **Mouse**: Look around
- **W/A/S/D**: Move forward/left/backward/right
- **ESC**: Quit

## Explanation

<div class="grid cards" markdown>

-   **[Simple Rasterization in LOVE](explanation/rasterization.md)**

    Learn how triangle rasterization works in LÖVE2D

-   **[Basics of 3D Projection](explanation/projection.md)**

    Understand perspective projection and coordinate transformations

-   **[Camera and Movement](explanation/camera.md)**

    Implement FPS-style camera controls with mouse and keyboard

-   **[Z-Buffer](explanation/zbuffer.md)**

    Solve visibility problems with depth buffering

</div>
