# Fundamentos Matemáticos del Rasterizador

Este documento explica en detalle las matemáticas detrás de cada componente del rasterizador 3D.

## Tabla de Contenidos

1. [Álgebra Lineal Básica](#algebra-lineal-basica)
2. [Matrices de Rotación](#matrices-de-rotacion)
3. [Proyección en Perspectiva](#proyeccion-en-perspectiva)
4. [Coordenadas Baricéntricas](#coordenadas-baricentricas)
5. [Interpolación Perspective-Correct](#interpolacion-perspective-correct)
6. [Z-Buffering](#z-buffering)

---

## Álgebra Lineal Básica

### Vectores 3D

Un vector en $\mathbb{R}^3$ se representa como:

$$
\mathbf{v} = \begin{pmatrix} x \\ y \\ z \end{pmatrix}
$$

#### Producto Punto (Dot Product)

El producto punto de dos vectores $\mathbf{a}$ y $\mathbf{b}$ es:

$$
\mathbf{a} \cdot \mathbf{b} = a_x b_x + a_y b_y + a_z b_z = |\mathbf{a}| |\mathbf{b}| \cos(\theta)
$$

donde $\theta$ es el ángulo entre los vectores.

**Propiedades importantes:**

- Si $\mathbf{a} \cdot \mathbf{b} = 0$, los vectores son **perpendiculares**
- Si $\mathbf{a} \cdot \mathbf{b} > 0$, el ángulo es agudo ($< 90°$)
- Si $\mathbf{a} \cdot \mathbf{b} < 0$, el ángulo es obtuso ($> 90°$)

#### Normalización

La normalización de un vector lo convierte a longitud unitaria:

$$
\hat{\mathbf{v}} = \frac{\mathbf{v}}{|\mathbf{v}|} = \frac{\mathbf{v}}{\sqrt{v_x^2 + v_y^2 + v_z^2}}
$$

### Matrices 3×3

Una matriz $3 \times 3$ se representa como:

$$
M = \begin{pmatrix}
m_{11} & m_{12} & m_{13} \\
m_{21} & m_{22} & m_{23} \\
m_{31} & m_{32} & m_{33}
\end{pmatrix}
$$

#### Multiplicación Matriz-Vector

$$
M \mathbf{v} = \begin{pmatrix}
m_{11}v_x + m_{12}v_y + m_{13}v_z \\
m_{21}v_x + m_{22}v_y + m_{23}v_z \\
m_{31}v_x + m_{32}v_y + m_{33}v_z
\end{pmatrix}
$$

Cada componente del resultado es el **producto punto** de una fila de $M$ con $\mathbf{v}$.

#### Multiplicación de Matrices

$$
(AB)_{ij} = \sum_{k=1}^{3} A_{ik} B_{kj}
$$

**Importante:** La multiplicación de matrices **NO es conmutativa**: $AB \neq BA$ en general.

---

## Matrices de Rotación

Las matrices de rotación son transformaciones que rotan vectores alrededor de ejes en el espacio 3D.

### Propiedades de Matrices de Rotación

Todas las matrices de rotación son **ortonormales**, lo que significa:

1. Sus columnas (y filas) son vectores unitarios mutuamente perpendiculares
2. $R^T R = R R^T = I$ (la transpuesta es la inversa)
3. $\det(R) = 1$ (preservan orientación)
4. Preservan longitudes: $|R\mathbf{v}| = |\mathbf{v}|$

### Rotación sobre el Eje X (Pitch)

Rota en el plano YZ, manteniendo X constante:

$$
R_x(\theta) = \begin{pmatrix}
1 & 0 & 0 \\
0 & \cos\theta & -\sin\theta \\
0 & \sin\theta & \cos\theta
\end{pmatrix}
$$

**Derivación:** Para rotar un punto $(x, y, z)$:

- $x' = x$ (eje de rotación no cambia)
- $y' = y \cos\theta - z \sin\theta$
- $z' = y \sin\theta + z \cos\theta$

### Rotación sobre el Eje Y (Yaw)

Rota en el plano XZ, manteniendo Y constante:

$$
R_y(\theta) = \begin{pmatrix}
\cos\theta & 0 & \sin\theta \\
0 & 1 & 0 \\
-\sin\theta & 0 & \cos\theta
\end{pmatrix}
$$

**Nota:** El signo negativo en $R_y$ se debe a la convención de mano derecha (right-handed).

### Rotación sobre el Eje Z (Roll)

Rota en el plano XY, manteniendo Z constante:

$$
R_z(\theta) = \begin{pmatrix}
\cos\theta & -\sin\theta & 0 \\
\sin\theta & \cos\theta & 0 \\
0 & 0 & 1
\end{pmatrix}
$$

Esta es la rotación 2D clásica extendida a 3D.

### Composición de Rotaciones (Ángulos de Euler)

Para aplicar múltiples rotaciones, se multiplican las matrices. El orden **importa**:

$$
R_{\text{total}} = R_z(\gamma) \cdot R_y(\beta) \cdot R_x(\alpha)
$$

Este orden (ZYX) significa que se aplica primero la rotación X, luego Y, luego Z.

**Ejemplo:**
```
Para rotar un vector v:
  v' = R_z(R_y(R_x(v)))
```

#### Gimbal Lock

⚠️ **Advertencia:** Las rotaciones de Euler sufren de "gimbal lock" cuando el ángulo Y está cerca de $\pm 90°$. En ese caso, las rotaciones X y Z se vuelven dependientes, perdiendo un grado de libertad.

**Solución alternativa:** Usar **cuaterniones** para rotaciones libres de gimbal lock.

---

## Proyección en Perspectiva

La proyección en perspectiva convierte coordenadas 3D en coordenadas 2D de pantalla, simulando cómo objetos lejanos se ven más pequeños.

### Modelo de Cámara Pinhole

El modelo básico es una cámara "pinhole" (agujero de alfiler):

```
        Objeto 3D (x,y,z)
             ↓
        Plano focal
             ↓
      Centro de proyección
             ↓
        Imagen 2D
```

### Fórmulas de Proyección

Para un punto $\mathbf{p} = (x, y, z)$ en espacio de cámara:

$$
\begin{aligned}
x_{\text{ndc}} &= \frac{x}{z} \\
y_{\text{ndc}} &= \frac{y}{z}
\end{aligned}
$$

donde NDC = Normalized Device Coordinates (van de -1 a +1).

### Conversión a Coordenadas de Pantalla

Para convertir a píxeles en pantalla:

$$
\begin{aligned}
x_{\text{screen}} &= f_x \cdot \frac{x}{z} + c_x \\
y_{\text{screen}} &= c_y - f_y \cdot \frac{y}{z}
\end{aligned}
$$

donde:

- $f_x, f_y$ = **distancias focales** en píxeles
- $c_x, c_y$ = **centro de proyección** (centro de pantalla)
- El signo negativo en $y$ es porque en pantalla Y crece hacia abajo

### Cálculo de la Distancia Focal

Dado un campo de visión (FOV) en grados:

$$
f_y = \frac{h/2}{\tan(\text{FOV}/2)}
$$

donde $h$ es la altura de la pantalla en píxeles.

**Ejemplo numérico:**

Para FOV = 60°, altura = 580px:

$$
f_y = \frac{290}{\tan(30°)} = \frac{290}{0.577} \approx 502 \text{ píxeles}
$$

### Near y Far Planes

Se define un **near plane** ($z_{\text{near}}$) y opcionalmente un **far plane** ($z_{\text{far}}$):

- Geometría con $z < z_{\text{near}}$ se descarta (detrás de la cámara)
- Geometría con $z > z_{\text{far}}$ se descarta (muy lejos)

En este rasterizador: $z_{\text{near}} = 0.001$, sin far clipping.

### Matriz de Proyección en Perspectiva

La forma matricial completa (no usada directamente en el código):

$$
P = \begin{pmatrix}
\frac{f_x}{a} & 0 & 0 & 0 \\
0 & f_y & 0 & 0 \\
0 & 0 & \frac{f+n}{n-f} & \frac{2fn}{n-f} \\
0 & 0 & -1 & 0
\end{pmatrix}
$$

donde $a$ = aspect ratio, $f$ = far, $n$ = near.

---

## Coordenadas Baricéntricas

Las coordenadas baricéntricas permiten expresar cualquier punto dentro de un triángulo como combinación lineal de sus vértices.

### Definición

Para un triángulo con vértices $\mathbf{v}_1, \mathbf{v}_2, \mathbf{v}_3$, cualquier punto $\mathbf{p}$ se expresa como:

$$
\mathbf{p} = \lambda_1 \mathbf{v}_1 + \lambda_2 \mathbf{v}_2 + \lambda_3 \mathbf{v}_3
$$

donde $\lambda_1 + \lambda_2 + \lambda_3 = 1$ y $\lambda_i \geq 0$ para puntos dentro del triángulo.

### Interpretación Geométrica

$$
\lambda_i = \frac{\text{Área del subtriángulo opuesto a } \mathbf{v}_i}{\text{Área total del triángulo}}
$$

### Cálculo mediante Edge Function

La **edge function** es el producto cruz 2D:

$$
E(\mathbf{p}_0, \mathbf{p}_1, \mathbf{p}) = (p_x - p_{0x})(p_{1y} - p_{0y}) - (p_y - p_{0y})(p_{1x} - p_{0x})
$$

**Interpretación:**

- $E > 0$: $\mathbf{p}$ está a la **izquierda** de la arista $\mathbf{p}_0 \to \mathbf{p}_1$
- $E < 0$: $\mathbf{p}$ está a la **derecha**
- $E = 0$: $\mathbf{p}$ está **sobre** la arista

### Fórmulas de Coordenadas Baricéntricas

Dado un triángulo $(\mathbf{v}_1, \mathbf{v}_2, \mathbf{v}_3)$ y un punto $\mathbf{p}$:

$$
\begin{aligned}
A &= E(\mathbf{v}_1, \mathbf{v}_2, \mathbf{v}_3) \quad \text{(doble del área)} \\
\lambda_1 &= \frac{E(\mathbf{v}_2, \mathbf{v}_3, \mathbf{p})}{A} \\
\lambda_2 &= \frac{E(\mathbf{v}_3, \mathbf{v}_1, \mathbf{p})}{A} \\
\lambda_3 &= 1 - \lambda_1 - \lambda_2
\end{aligned}
$$

### Test de Inclusión

Un punto $\mathbf{p}$ está **dentro** del triángulo si y solo si:

$$
\lambda_1 \geq 0 \quad \land \quad \lambda_2 \geq 0 \quad \land \quad \lambda_3 \geq 0
$$

### Interpolación de Atributos

Para interpolar cualquier atributo (color, profundidad, coordenadas de textura):

$$
u(\mathbf{p}) = \lambda_1 u_1 + \lambda_2 u_2 + \lambda_3 u_3
$$

⚠️ **Importante:** Esta fórmula es correcta en 3D, pero en 2D (después de proyección) requiere corrección de perspectiva.

---

## Interpolación Perspective-Correct

### El Problema

Después de la proyección en perspectiva, la interpolación lineal en espacio de pantalla **no** corresponde a interpolación lineal en espacio 3D.

**Ejemplo visual:**
```
En 3D: Puntos equiespaciados en una línea
   o-----o-----o-----o

Después de proyección:
   o----o---o--o  (no equiespaciados!)
```

### La Solución

Para interpolar correctamente un atributo $u$ después de la proyección:

$$
\frac{1}{z_p} = \lambda_1 \frac{1}{z_1} + \lambda_2 \frac{1}{z_2} + \lambda_3 \frac{1}{z_3}
$$

$$
u_p = \frac{\lambda_1 \frac{u_1}{z_1} + \lambda_2 \frac{u_2}{z_2} + \lambda_3 \frac{u_3}{z_3}}{\frac{1}{z_p}}
$$

### Simplificación para Profundidad

Para interpolar solo la profundidad $z$:

$$
\begin{aligned}
\frac{1}{z_p} &= \lambda_1 \frac{1}{z_1} + \lambda_2 \frac{1}{z_2} + \lambda_3 \frac{1}{z_3} \\
z_p &= \frac{1}{\frac{1}{z_p}}
\end{aligned}
$$

### Demostración Matemática

La proyección divide por $z$:

$$
x_{\text{screen}} = \frac{f_x \cdot x}{z} + c_x
$$

Esto introduce una transformación **no-lineal** (hiperbólica) en el espacio.

Para recuperar la interpolación lineal original en 3D, debemos interpolar $1/z$ (cantidad lineal en espacio de proyección) en lugar de $z$ directamente.

**Proof sketch:**

1. En espacio 3D (antes de proyección): $u$ varía linealmente
2. Proyección: $x' = x/z$ (transformación no-lineal)
3. En espacio 2D: $u/z$ varía linealmente
4. Para recuperar $u$: multiplicar por $z$

### Ejemplo Numérico

```
Triángulo con vértices:
  v1 = (0, 0, 1), u1 = 0.0
  v2 = (1, 0, 2), u2 = 1.0
  v3 = (0, 1, 1), u3 = 0.5

Punto p con coordenadas baricéntricas:
  λ1 = 0.25, λ2 = 0.50, λ3 = 0.25

Interpolación incorrecta (lineal):
  u_wrong = 0.25×0.0 + 0.50×1.0 + 0.25×0.5 = 0.625

Interpolación correcta (perspective-correct):
  1/z_p = 0.25×(1/1) + 0.50×(1/2) + 0.25×(1/1)
       = 0.25 + 0.25 + 0.25 = 0.75
  z_p = 1/0.75 = 1.333

  u_correct = (0.25×0.0/1 + 0.50×1.0/2 + 0.25×0.5/1) × 1.333
           = (0 + 0.25 + 0.125) × 1.333 = 0.5
```

---

## Z-Buffering

El z-buffer (o depth buffer) es una técnica para resolver el problema de **visibilidad**: determinar qué superficies están frente a otras.

### Problema de Visibilidad

Sin un mecanismo de visibilidad, triángulos dibujados más tarde sobrescriben los anteriores, sin importar su profundidad:

```
Incorrecto (sin z-buffer):
  Dibujar triángulo lejano → OK
  Dibujar triángulo cercano → OK
  Dibujar triángulo lejano → ¡Sobrescribe el cercano! ❌
```

### Algoritmo Z-Buffer

**Inicialización:**
```
Para cada píxel (x, y):
  zbuffer[x, y] = ∞
  color[x, y] = color_fondo
```

**Para cada triángulo:**
```
Para cada píxel (x, y) cubierto por el triángulo:
  z = profundidad interpolada en (x, y)

  if z < zbuffer[x, y]:
    zbuffer[x, y] = z
    color[x, y] = color_triángulo
```

### Fórmula Matemática

Para un píxel $(x, y)$ y un conjunto de triángulos $\{T_1, T_2, \ldots, T_n\}$:

$$
\text{color}(x, y) = \text{color}(T_i) \quad \text{donde} \quad i = \arg\min_j z_j(x, y)
$$

Es decir, se dibuja el color del triángulo con **menor profundidad** (más cercano).

### Ventajas

✓ **No requiere ordenamiento:** Los triángulos pueden procesarse en cualquier orden
✓ **Maneja escenas complejas:** Funciona con intersecciones arbitrarias de geometría
✓ **Complejidad lineal:** $O(n)$ en el número de triángulos
✓ **Fácil de implementar:** Algoritmo simple y robusto

### Desventajas

✗ **Memoria adicional:** Requiere un buffer completo ($W \times H$ valores)
✗ **No maneja transparencia:** Solo un fragmento por píxel (el más cercano)
✗ **Z-fighting:** Problemas de precisión cuando dos superficies están muy cerca
✗ **Overdraw:** Píxeles pueden dibujarse múltiples veces (desperdicio)

### Z-Fighting

Ocurre cuando dos triángulos tienen profundidades muy similares:

$$
|z_1 - z_2| < \epsilon_{\text{float}}
$$

**Soluciones:**

1. Usar mayor precisión (float64 en lugar de float32)
2. Ajustar near/far planes para mejor distribución de profundidad
3. Offset de polígonos (polygon offset)
4. Usar logarithmic depth buffer

### Comparación con Painter's Algorithm

**Painter's Algorithm:** Ordenar triángulos por profundidad y dibujar de atrás hacia adelante.

| Aspecto | Z-Buffer | Painter's |
|---------|----------|-----------|
| Ordenamiento | No requiere | Requiere $O(n \log n)$ |
| Intersecciones | Maneja correctamente | Falla con ciclos |
| Memoria | $O(W \times H)$ | $O(1)$ |
| Transparencia | No soporta bien | Funciona bien |

### Optimizaciones

**Early Z-Test (no implementado aquí):**
- Probar z-buffer antes de calcular color
- Ahorra cálculos de shading para píxeles ocultos

**Hierarchical Z-Buffer:**
- Mantener mipmap de valores mínimos de z
- Descartar triángulos completos si están detrás

**Z-Prepass:**
- Primer pass: solo escribir profundidad
- Segundo pass: dibujar color (solo píxeles visibles)

---

## Pipeline Completo

Resumen del flujo matemático completo:

```
1. ESPACIO DE MODELO
   v_model = (x, y, z)

   ↓ [Rotación + Traslación]

2. ESPACIO MUNDIAL
   v_world = R_model × v_model + t_model

   ↓ [Traslación de cámara + Rotación inversa]

3. ESPACIO DE CÁMARA
   v_camera = R_cam^T × (v_world - p_cam)

   ↓ [Proyección en perspectiva]

4. ESPACIO DE PANTALLA (2D + profundidad)
   x_screen = f_x × (v_camera.x / v_camera.z) + c_x
   y_screen = c_y - f_y × (v_camera.y / v_camera.z)
   z_depth = v_camera.z

   ↓ [Triangulación + Clipping]

5. TRIÁNGULOS VÁLIDOS
   {(v1, v2, v3) | z_i > near, área > ε}

   ↓ [Rasterización]

6. PÍXELES CON ATRIBUTOS
   Para cada píxel en triángulo:
     - Coordenadas baricéntricas (λ1, λ2, λ3)
     - Profundidad (perspective-correct)
     - Test de inclusión
     - Z-buffer test

   ↓ [Presentación]

7. FRAME BUFFER → PANTALLA
```

Cada etapa aplica transformaciones matemáticas específicas que, en conjunto, crean la ilusión de un mundo 3D proyectado en una pantalla 2D.

---

## Referencias

1. **Real-Time Rendering (4th Edition)** - Akenine-Möller et al.
2. **Computer Graphics: Principles and Practice (3rd Edition)** - Hughes et al.
3. **Fundamentals of Computer Graphics (5th Edition)** - Marschner & Shirley
4. **Scratchapixel:** https://www.scratchapixel.com/
5. **learnopengl.com:** https://learnopengl.com/

---

📝 **Nota:** Todas las fórmulas en este documento están implementadas en el rasterizador. Puedes encontrar el código correspondiente en `lua/vectors.lua` y `lua/main.lua`.
