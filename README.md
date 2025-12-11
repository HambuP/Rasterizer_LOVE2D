# 🧊 3D Software Rasterizer

A simple 3D software rasterizer built from scratch in Lua using LÖVE2D. No GPU acceleration—just pure CPU rendering to understand how 3D graphics work.

![Demo](./screenshots/rasterizer.gif)

## Features

- **Triangle rasterization** using edge functions and barycentric coordinates
- **Perspective projection** with configurable field of view
- **Z-buffering** for correct depth sorting
- **Perspective-correct interpolation** for depth values
- **FPS camera** with mouse look (yaw/pitch) and WASD movement
- **3D transformations** with rotation matrices

## What's Missing

This is a learning project, so it intentionally lacks:

- ❌ Textures
- ❌ Lighting (Phong, Blinn-Phong, etc.)
- ❌ Backface culling
- ❌ View frustum clipping (only near plane clipping implemented)
- ❌ Anti-aliasing

