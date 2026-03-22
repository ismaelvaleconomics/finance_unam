# SESIÓN 6
## Valoración de Bonos y Renta Fija

**Curso:** Mercado de Valores  
**Profesor:** Ismael Valverde  


---

## OBJETIVOS DE APRENDIZAJE

Al finalizar esta sesión, los estudiantes serán capaces de:

1. Valuar bonos usando valor presente de flujos
2. Entender la relación inversa precio-yield
3. Calcular e interpretar duration (Macaulay y modificada)
4. Calcular convexidad y mejorar estimaciones de precio
5. Aplicar inmunización para gestionar pasivos
6. Distinguir entre CETES, Bonos M y UDIBONOS
7. Usar duration y convexidad en gestión de portafolios

---

## CONTEXTO Y MOTIVACIÓN

### ¿Por qué estudiar bonos?

**Importancia del mercado de bonos:**
- Mercado de bonos > Mercado de acciones (en valor total)
- Fondos de pensiones: 60-80% en bonos
- Instrumento principal para preservar capital
- Herramienta de política monetaria

**En México:**
- Mercado de deuda gubernamental muy desarrollado
- CETES: instrumento más líquido
- Bonos M: referencia para tasas de largo plazo
- UDIBONOS: protección contra inflación

---

## CONEXIÓN CON SESIONES ANTERIORES

**Sesión 5 (CAPM, Valuación):**
- Vimos valuación de ACCIONES (flujos inciertos)
- Ahora: valuación de BONOS (flujos ciertos/predecibles)

**Diferencias clave:**
```
ACCIONES                    BONOS
Flujos: Inciertos           Flujos: Conocidos
Plazo: Infinito             Plazo: Definido
Riesgo: Alto                Riesgo: Menor
Valuación: Compleja         Valuación: Matemática pura
```

**Conexión:**
"Los bonos son más simples de valuar (sabemos exactamente qué flujos recibiremos), pero las matemáticas son más interesantes: duration, convexidad, inmunización."

---

## ESTRUCTURA DE LA SESIÓN

### BLOQUE 1: Fundamentos y valoración

**1.1 ¿Qué es un bono?**

**Analogía inicial:**

"Un bono es como un PRÉSTAMO que tú le haces al gobierno o una empresa.

Ejemplo personal:
- Tu amigo te pide $1,000 prestados
- Te promete pagarte $50 cada 6 meses de interés
- En 5 años te devuelve los $1,000

Eso es exactamente un bono."

```
BONO TÍPICO:
┌─────────────────────────────────────┐
│ Valor Nominal (VN): $1,000          │
│ Tasa Cupón: 6% anual                │
│ Plazo: 5 años                       │
│ Frecuencia: Semestral               │
│                                     │
│ Cupón semestral = $1,000 × 6%/2    │
│                 = $30               │
│                                     │
│ Flujos:                             │
│ t=0.5: $30                          │
│ t=1.0: $30                          │
│ ...                                 │
│ t=5.0: $30 + $1,000                 │
└─────────────────────────────────────┘
```

**Tipos de bonos mexicanos:**

Mostrar brevemente, profundizar más tarde:
- **CETES:** Cupón cero, corto plazo (28-364 días)
- **Bonos M:** Cupón fijo, mediano/largo plazo
- **UDIBONOS:** Cupón ajustado por inflación

**1.2 Valoración básica**

Ejecutar Parte 3 del script.

**Principio fundamental:**

Escribir GRANDE en la pizarra:

```
PRECIO = VALOR PRESENTE DE TODOS LOS FLUJOS FUTUROS
```

"Es el mismo principio que con acciones (DDM), pero aquí SABEMOS los flujos exactos."

**Ejemplo numérico detallado:**

Proyectar la tabla de flujos del script:

```
Periodo  Tiempo  Flujo   Factor_Desc  VP
1        0.5     $30     0.9615       $28.85
2        1.0     $30     0.9246       $27.74
3        1.5     $30     0.8890       $26.67
...
10       5.0     $1,030  0.6756       $695.87
                                      -------
                         PRECIO =     $918.89
```

**Paso a paso:**

"Para cada flujo:
1. Dividir entre (1 + y/2) elevado al periodo
2. Esto es el VALOR PRESENTE
3. Sumar todos los valores presentes = PRECIO"

**Interpretación crucial:**

"Precio = $918.89 < Valor Nominal = $1,000

¿Por qué?

Tasa cupón = 6%
Yield = 8%

El mercado EXIGE 8% de rendimiento.
El bono solo PAGA 6% de cupón.
Por tanto, el precio debe ser MENOR para compensar.

Si pagas $918.89 hoy y recibes cupones de 6% + $1,000 al final,
tu rendimiento TOTAL será 8%."

**1.3 CETES (cupón cero)**

"CETES son más simples: NO hay cupones.

Compras con descuento, recibes valor nominal al vencimiento."

Ejemplo numérico:

```
CETES 28 días
Valor nominal: $10
Tasa: 10% anual
Precio = $10 / (1 + 0.10 × 28/360)
       = $10 / 1.00778
       = $9.9228

Ganancia en 28 días: $10 - $9.9228 = $0.0772
```

**Pregunta al grupo:**
"¿Por qué CETES no tienen cupones?"

(Respuesta: Plazo muy corto, no vale la pena complejidad de cupones)

---

### BLOQUE 2: Relación precio-yield

**2.1 Concepto fundamental**

Ejecutar Parte 4 del script - mostrar gráfica.

**Regla de oro:**

```
↑ YIELD  →  ↓ PRECIO
↓ YIELD  →  ↑ PRECIO

RELACIÓN INVERSA
```

**¿Por qué?**

"Si las tasas de mercado SUBEN:
- Los bonos nuevos pagan más
- Tu bono viejo (con cupón bajo) vale MENOS
- Su precio BAJA hasta que su rendimiento = mercado

Si las tasas BAJAN:
- Los bonos nuevos pagan menos
- Tu bono viejo (con cupón alto) vale MÁS
- Su precio SUBE"

**Ejemplo concreto:**

"Tienes un bono que paga 6% de cupón.

Escenario 1: Tasas de mercado suben a 8%
- Nuevos bonos pagan 8%
- ¿Quién quiere tu bono de 6%?
- Solo si lo vendes CON DESCUENTO
- Precio baja

Escenario 2: Tasas bajan a 4%
- Nuevos bonos pagan solo 4%
- ¡Tu bono de 6% es atractivo!
- Puedes venderlo CON PRIMA
- Precio sube"

**2.2 Forma de la curva**

Proyectar gráfica precio-yield.

**Observaciones clave:**

"1. La curva es CONVEXA (no lineal)
   - No es una línea recta
   - Se curva hacia arriba

2. Intersección con VN
   - Cuando yield = tasa cupón → precio = VN

3. Asimetría
   - Cuando yield BAJA: precio sube MÁS
   - Cuando yield SUBE: precio baja MENOS
   - Esto es BUENO (convexidad positiva)"

**Demostración numérica:**

```
Bono: VN=$1,000, cupón=6%, 5 años, yield inicial=6%
Precio inicial = $1,000 (a la par)

Si yield BAJA a 4% (-2%):
Precio = $1,089 → Ganancia = +$89

Si yield SUBE a 8% (+2%):
Precio = $920 → Pérdida = -$80

¡Ganancia > Pérdida! (por convexidad)
```

---

### BLOQUE 3: "Duration"

**3.1 Motivación**

PREGUNTA: ¿Cuál bono es más riesgoso?

Bono A: 2 años, cupón 5%
Bono B: 10 años, cupón 5%

Intuitivamente: Bono B (más largo)

¿Pero CÓMO MEDIMOS ese riesgo?

**Respuesta:** DURATION

**3.2 Duration de Macaulay**
La Duración de Macaulay es el tiempo promedio ponderado que un inversor debe esperar para recibir todos los flujos de efectivo (tanto cupones como principal) de un bono.

Para visualizarlo, imagina un subibaja (balancín). La tabla del subibaja representa la línea de tiempo del bono, y los flujos de efectivo son pesos físicos colocados sobre la tabla en diferentes fechas. La Duración de Macaulay es el punto de equilibrio exacto (el fulcro) donde el subibaja queda perfectamente nivelado.

En términos simples, te indica cuántos años toma recuperar el verdadero valor económico de tu inversión, teniendo en cuenta el valor del dinero en el tiempo. Para un bono cupón cero, la Duración de Macaulay es exactamente igual a su tiempo de vencimiento. Para un bono que paga cupones, la duración siempre será menor que su tiempo hasta el vencimiento porque estás recuperando parte de tu dinero antes a través de los cupones.

Para calcularla, multiplicas el tiempo de cada flujo de efectivo por el valor presente de ese flujo, sumas todos los resultados y luego divides entre el precio total del bono.

$$D_{Mac} = \frac{\sum_{t=1}^{T} \frac{t \cdot CF_t}{(1+y)^t}}{P}$$

Donde:

-   $D_{Mac}$ = Duración de Macaulay
    
-   $t$ = Tiempo en años
    
-   $CF_t$ = Flujo de caja en el período $t$
    
-   $y$ = Rendimiento al vencimiento
    
-   $P$ = Precio actual de mercado del bono, que es la suma de todos los valores presentes: $\sum_{t=1}^{T} \frac{CF_t}{(1+y)^t}$

Ejecutar Parte 6 del script.

**Concepto:**

Duration = Promedio PONDERADO del tiempo hasta recibir flujos

Ponderación = Valor presente de cada flujo / Precio total

**Analogía física:**

```
    📍 = Flujo (peso)
    ━━━━━━━━━━━━━━━━━━━
    ↑
  Punto de balance

Duration = ¿Dónde está el punto de balance?
```
Recordar: Es como un sube y baja con pesos en diferentes posiciones.
la $D_{Mac}$ te dice dónde poner el punto de apoyo para balancear.

**Tabla de cálculo:**

```
Periodo  Tiempo  VP_Flujo  Peso    t×Peso
1        0.5     $28.85    3.1%    0.016
2        1.0     $27.74    3.0%    0.030
...
10       5.0     $695.87   75.7%   3.786
                                   ------
                  Duration = 4.38 años
```

**Interpretación:**

$D_{Mac}$ = 4.38 años

¿Qué significa?

1. **Punto de balance temporal:**
   En promedio, recuperas tu inversión en ~4.4 años

2. **Plazo efectivo:**
   El bono 'actúa' como si fuera un bono de 4.4 años
   (aunque el plazo nominal es 5 años)

3. **¿Por qué < 5 años?**
   Porque recibes cupones ANTES del final
   Esos cupones 'adelantan' el tiempo promedio de recuperación"

**3.3 Propiedades de $D_{Mac}$**

```
PROPIEDADES:

1. Bono cupón cero: Duration = Plazo
   (solo recibes flujo al final)

2. Bono con cupones: Duration < Plazo
   (recibes flujos antes)

3. ↑ Tasa cupón → ↓ Duration
   (más peso en cupones tempranos)

4. ↑ Plazo → ↑ Duration
   (flujos más lejanos)

5. ↑ Yield → ↓ Duration
   (flujos lejanos valen menos)
```

**Pregunta interactiva:**

"Dos bonos con mismo plazo (10 años):
Bono A: cupón 10%
Bono B: cupón 2%

¿Cuál tiene MAYOR duración?"

(Respuesta: Bono B - paga menos cupones tempranos, más peso en el principal al final)

**3.4 Duration modificada**

"Duración de Macaulay mide el TIEMPO.

Duración Modificada mide SENSIBILIDAD DE PRECIO."

Fórmula:

```
D_Mod = D_Mac / (1 + y/m)

Uso:
ΔPrecio ≈ -D_Mod × ΔYield × Precio
```

**Ejemplo práctico:**

```
Bono: Precio=$918.89, D_Mod=4.22

Si yield sube de 8% a 8.5% (+0.5%)

ΔPrecio ≈ -4.22 × 0.005 × $918.89
        ≈ -$19.38

Precio nuevo ≈ $918.89 - $19.38 = $899.51
```

"El signo NEGATIVO es crucial:
- Yield sube (+) → Precio baja (-)
- Yield baja (-) → Precio sube (+)"

---

### BLOQUE 4: Convexidad

**4.1 Limitación de duration**

"PROBLEMA: Duration asume relación LINEAL.

REALIDAD: La relación es CURVA (convexa)."

**Demostración visual:**

Proyectar gráfica precio-yield con línea tangente:

```
    Precio
      |     Curva real (convexa)
      |    /
      |   / ----  Aproximación lineal (duration)
      | /‾
      |/_____________________ Yield
```

"Para cambios PEQUEÑOS en yield: duration funciona bien.

Para cambios GRANDES: duration subestima el precio real."

**4.2 Convexidad**

Ejecutar Parte 8 del script.

"CONVEXIDAD mide la CURVATURA. Mejora la aproximación para cambios grandes."

Para modelar matemáticamente la transición de una aproximación lineal a una convexa en la valoración de bonos, debemos recurrir a la **Expansión de Taylor**.

En el mercado de renta fija, el precio de un bono $P$ es una función no lineal de su rendimiento al vencimiento ($y$). Cuando el rendimiento cambia en una magnitud $\Delta y$, el nuevo precio $P(y + \Delta y)$ se puede aproximar mediante la serie de Taylor alrededor de $y$:

$$P(y + \Delta y) \approx P(y) + \frac{dP}{dy}\Delta y + \frac{1}{2}\frac{d^2P}{dy^2}(\Delta y)^2$$

#### El Enfoque Lineal: Duración Modificada

El primer término de la expansión (la primera derivada) representa la pendiente de la curva precio-rendimiento. Si nos quedamos solo aquí, estamos asumiendo que la relación es una línea recta:

$$\Delta P \approx \frac{dP}{dy}\Delta y$$

Si normalizamos para obtener el cambio porcentual en el precio, definimos la **Duración Modificada ($D_{mod}$)** como:

$$D_{mod} = -\frac{1}{P} \frac{dP}{dy}$$

Por lo tanto, la aproximación lineal es:

$$\frac{\Delta P}{P} \approx -D_{mod} \cdot \Delta y$$

**El error:** Como la función precio-rendimiento es convexa (curvada hacia arriba), esta línea siempre estará por debajo del precio real del bono. Ante grandes cambios en $y$, la Duración subestima el aumento de precio cuando las tasas bajan y sobreestima la caída de precio cuando las tasas suben.

####  El Ajuste por Curvatura: Convexidad

Para capturar la realidad de la "curva", añadimos el segundo término de la expansión de Taylor (la segunda derivada). Para ellos definimos la **Convexidad ($C$)** como:

$$C = \frac{1}{P} \frac{d^2P}{dy^2}$$

Al incorporar este término, la ecuación de sensibilidad del precio se vuelve:

$$\frac{\Delta P}{P} \approx \underbrace{-D_{mod} \cdot \Delta y}_{\text{Efecto Lineal}} + \underbrace{\frac{1}{2} C \cdot (\Delta y)^2}_{\text{Ajuste por Convexidad}}$$

#### Implicación en la Curva de Rendimiento

En la práctica, analizar un portafolio frente a desplazamientos en la curva de tipos, ignorar el término $\frac{1}{2} C (\Delta y)^2$ lleva a errores de valoración significativos, especialmente en activos de larga duración (como bonos a 30 años) o en entornos de alta volatilidad de tasas, donde $(\Delta y)^2$ deja de ser despreciable.

### Resumen de la Diferencia Matemática 
| Componente | Definición Matemática | Función en el Modelo | 
| :--- | :--- | :--- | 
| **Duración** | $-\frac{1}{P} \frac{dP}{dy}$ | Mide la **pendiente** (primer orden). Es precisa solo para cambios infinitesimales en $y$. | 
| **Convexidad** | $\frac{1}{P} \frac{d^2P}{dy^2}$ | Mide la **curvatura** (segundo orden). Explica por qué los precios suben más de lo que bajan ante cambios simétricos en las tasas. |

Para el desarrollo matemático vea el Anexo al final

**Vea comparación en el script:**

```
Cambio: yield de 8% a 10% (+2%)

Precio real:        $839
Solo duration:      $841  (error: $2)
Duration + convex:  $838  (error: $1)

¡Convexidad reduce error a la mitad!
```

**4.3 Interpretación de convexidad**

Convexidad SIEMPRE es POSITIVA para bonos simples.

¿Qué significa?

**Cuando yield BAJA:**
Precio sube MÁS de lo que predice duration
↓ Mayor ganancia

**Cuando yield SUBE:**
Precio baja MENOS de lo que predice duration
↓ Menor pérdida

¡Convexidad es BUENA! Es como un 'seguro gratis'.

**Implicación práctica:**

"Si tienes dos bonos con misma duration:
→ Prefiere el de MAYOR convexidad
→ Mejor perfil asimétrico de ganancia/pérdida"

---

### BLOQUE 5: Inmunización

**5.1 El problema**

ESCENARIO REAL: Un fondo de pensiones sabe que debe pagar:
$10,000,000 en EXACTAMENTE 5 años

Riesgo de tasa de interés:
- Si tasas SUBEN: ¿Tendrá suficiente?
- Si tasas BAJAN: ¿Tendrá suficiente?

¿Cómo protegerse?

**Dilema:**
```
Si tasas SUBEN:
✓ Bueno: Reinversión de cupones a mayor tasa
✗ Malo: Precio de bonos baja

Si tasas BAJAN:
✓ Bueno: Precio de bonos sube
✗ Malo: Reinversión de cupones a menor tasa

¿Cómo BALANCEAR?
```

**5.2 Solución: Inmunización**
Ejecutar Parte 9 del script.

INMUNIZACIÓN:

Construir portafolio con Duration = Horizonte

Resultado:
Ganancia en precio ≈ Pérdida en reinversión
(y viceversa)

**Opción 1: Bono cupón cero**

"Lo más simple:

Comprar bono cupón cero que vence EXACTAMENTE en 5 años.

Duration = 5 años ✓
Sin riesgo de reinversión (no hay cupones) ✓

Problema: Tal vez no existe ese bono exacto."

**Opción 2: Portafolio de bonos**

Mostrar el cálculo del script:

```
Necesitas duration = 5 años

Bono A: 3 años, duration = 2.8
Bono B: 10 años, duration = 7.5

Ecuación:
w_A × 2.8 + w_B × 7.5 = 5

Solución:
w_A = 53.2%  (bono corto)
w_B = 46.8%  (bono largo)
```
```
0.532 × 2.8 + 0.468 × 7.5
= 1.49 + 3.51
= 5.0 años ✓
```
**Limitaciones:**
IMPORTANTE: Inmunización NO es perfecta. Limitaciones:
1. Solo protege contra cambios PARALELOS
   (toda la curva sube/baja igual)

2. Duration CAMBIA con el tiempo
   → Requiere REBALANCEO periódico

3. Asume reinversión a misma tasa
   (no siempre cierto)

4. No considera convexidad

Aún así, es mejor que no hacer nada.

---

### BLOQUE 6: Bonos mexicanos

Ejecutar Parte 10 del script.

**6.1 CETES**

**Certificados de la Tesorería**

Características:
- Cupón cero
- Plazos: 28, 91, 182, 364 días
- MUY líquidos
- Benchmark de tasa libre de riesgo

Uso:
- Tesorería corporativa (liquidez de corto plazo)
- Fondos de inversión (efectivo)
- Colateral en repos

**6.2 Bonos M**

**Bonos de Desarrollo del Gobierno Federal**

Características:
- Cupón fijo semestral
- Plazos: 3, 5, 10, 20, 30 años
- Denominados en pesos
- Tasa cupón típica: 7-10%

Riesgo:
- Tasa de interés ✓
- Inflación ✓ (no protegido)
- Crédito: Muy bajo (gobierno)

**6.3 UDIBONOS**

**Bonos indexados a UDIs (inflación)**

¿Cómo funcionan?

1. Principal se ajusta DIARIAMENTE por UDIs
2. Cupón = % del principal ajustado
3. Al vencimiento, recibes principal ajustado

Ejemplo:
- Compras 100 UDIs
- UDI hoy = $7.50 → Inviertes $750
- Cupón real: 4% anual
- En 6 meses, UDI = $7.65 (inflación 2%)
- Cupón = 100 UDIs × 2% = 2 UDIs = $15.30
- Principal ahora vale 100 × $7.65 = $765

Protección REAL contra inflación.

**Comparación:**

```
              CETES    Bonos M    UDIBONOS
Plazo         Corto    Med/Largo  Largo
Cupón         Cero     Fijo       Real
Riesgo Tasa   Bajo     Alto       Medio
Riesgo Infl   Bajo     Alto       Cero
Liquidez      Muy Alta Alta       Media
```
---

### CIERRE

**Resumen de conceptos clave:**

Hoy aprendimos:

1. **Valoración:** VP de todos los flujos
2. **Precio-Yield:** Relación inversa
3. **Duration:** Sensibilidad a tasas (tiempo efectivo)
4. **Convexidad:** Curvatura (siempre positiva = buena)
5. **Inmunización:** Duration matching para proteger pasivos
6. **Bonos mexicanos:** CETES, M, UDIBONOS

**PRÓXIMA SESIÓN: VaR (Value at Risk)**

Comenzamos el módulo de gestión de riesgos.
Pregunta: '¿Cuánto puedo perder en el peor caso?'

Usaremos los conceptos de distribuciones (Sesión 3) y portafolios (Sesión 4)."

---

## EJERCICIOS Y TAREA

**Obligatorios:** 1-4  
**Avanzados:** 5-7

**Énfasis:**
- Ejercicio 3 (duration) es FUNDAMENTAL - deben hacerlo paso a paso
- Ejercicio 6 (inmunización) conecta con gestión de portafolios

---

## SOLUCIONES A EJERCICIOS SELECCIONADOS

### Ejercicio 1:

```r
# Bono: VN=$1,000, cupón=7%, plazo=8, frecuencia=2, yield=6%

resultado <- valorar_bono(VN = 1000, 
                          cupon_tasa = 0.07, 
                          plazo = 8, 
                          frecuencia = 2, 
                          yield = 0.06)

precio <- resultado$precio  # $1,062.81

# b) Cotiza CON PRIMA (precio > VN)
# Razón: yield (6%) < tasa cupón (7%)
```

### Ejercicio 3:

```r
# Duration de Macaulay

periodos <- resultado$periodos
tiempo <- periodos / 2
vp_flujos <- resultado$vp_flujos
precio <- resultado$precio

ponderacion <- tiempo * vp_flujos
duration <- sum(ponderacion) / precio  # ~6.5 años

# b) Significa que el "plazo efectivo" es 6.5 años
# c) Duration (6.5) < Plazo (8) porque hay cupones
# d) Los cupones tempranos "adelantan" el tiempo promedio
```

### Ejercicio 6:

```r
# Inmunización: Pagar $5M en 7 años, tasa=8%

# a) Valor presente
vp <- 5000000 / (1.08)^7  # $2,917,632

# b) Bono cupón cero a 7 años
# VN × factor_desc = VN / (1.08)^7 = $2,917,632
# VN = $5,000,000

# c) Duration matching
# w_A × 3.6 + w_B × 9.2 = 7
# w_A + w_B = 1
# 
# w_B = (7 - 3.6) / (9.2 - 3.6) = 0.607
# w_A = 0.393
#
# 39.3% en Bono A, 60.7% en Bono B
```

---

## PROBLEMAS COMUNES Y SOLUCIONES

### Problema 1: Confusión entre duration y plazo
**Solución:** Enfatizar que son diferentes. Duration = plazo EFECTIVO

### Problema 2: Signo negativo en ΔPrecio
**Causa:** Relación inversa precio-yield  
**Solución:** Recordar: yield↑ → precio↓

### Problema 3: Convexidad negativa
**Causa:** Error en cálculo  
**Explicación:** Bonos simples SIEMPRE tienen convexidad positiva

---

## PUNTOS PEDAGÓGICOS CRÍTICOS

### 1. Usar analogías constantemente
- Bono = préstamo a tu amigo
- Duration = punto de balance
- Convexidad = seguro gratis

### 2. Énfasis en la relación inversa
- Estudiar con cuidado este punto
- Es contraintuitivo la primera vez que se analiza

### 3. Duration es el concepto más difícil
- Tomar tiempo para estudiarlo bien
- Es importante hacer el cálculo paso a paso
- Conecta con tiempo efectivo (tangible)

---

## EVALUACIÓN DE LA SESIÓN

### Pregunta de salida:
"Si las tasas de interés suben, ¿qué pasa con el precio de los bonos? ¿Y si tengo mayor duration, me afecta más o menos?"

---

## PREPARACIÓN PARA SESIÓN 7

**Tema:** Value at Risk (VaR)

**Conexión:**
"Bonos: riesgo de tasa (medido por duration)  
VaR: riesgo de mercado en general (cuantificado)"

**Materiales:**
- Datos históricos de portafolios
- Distribuciones de retornos (Sesión 3)

## Anexo Matemático

### Zero-coupon bond
Here is the step-by-step mathematical derivation of Convexity for a zero-coupon bond.

To find the convexity, we need to take the second derivative of the bond's pricing function with respect to its yield, and then divide it by the bond's price.

### Step 1: Define the Pricing Equation

For a zero-coupon bond, there are no periodic coupon payments. The investor only receives the face value (or maturity value) at the end of the term.

The price $P$ of a zero-coupon bond is the present value of its face value $M$, discounted at the yield to maturity $y$ over $t$ periods:

$$P = \frac{M}{(1+y)^t}$$

To make the calculus easier, we can rewrite this with a negative exponent:

$$P = M(1+y)^{-t}$$

### Step 2: Find the First Derivative (Price Sensitivity)

Next, we take the first derivative of the price with respect to the yield ($\frac{dP}{dy}$). We apply the power rule to the equation from Step 1:

$$\frac{dP}{dy} = -t \cdot M(1+y)^{-t-1}$$

_(Note: If we divided this by the price $P$, we would get the Modified Duration for the zero-coupon bond)._

### Step 3: Find the Second Derivative (Curvature)

Convexity relies on the second derivative, which measures the rate of change of the duration (the curvature of the price-yield function). We take the derivative of the result from Step 2:

$$\frac{d^2P}{dy^2} = -t \cdot (-t - 1) \cdot M(1+y)^{-t-2}$$

Multiply the terms to clean it up:

$$\frac{d^2P}{dy^2} = t(t+1)M(1+y)^{-t-2}$$

### Step 4: Apply the Convexity Formula

The general formula for Convexity $C$ is the second derivative divided by the original price $P$:

$$C = \frac{1}{P} \frac{d^2P}{dy^2}$$

Now, substitute the original price $P = M(1+y)^{-t}$ and the second derivative we just found into this formula:

$$C = \frac{t(t+1)M(1+y)^{-t-2}}{M(1+y)^{-t}}$$

### Step 5: Simplify the Equation

Now, we cancel out the common terms.

1.  The face value $M$ in the numerator and denominator cancels out.
    
2.  We use the exponent quotient rule ($\frac{x^a}{x^b} = x^{a-b}$) on the $(1+y)$ terms:
    

$$C = t(t+1)(1+y)^{(-t-2) - (-t)}$$

$$C = t(t+1)(1+y)^{-2}$$

Rewriting it as a fraction gives us the final, standard formula for the convexity of a zero-coupon bond:

$$C = \frac{t(t+1)}{(1+y)^2}$$

### The Takeaway

Notice that the face value $M$ disappeared entirely during the derivation. This proves mathematically that the convexity of a zero-coupon bond depends exclusively on its **time to maturity ($t$)** and its **yield ($y$)**. Because the formula relies heavily on $t \times (t+1)$, convexity increases exponentially as the maturity of the zero-coupon bond lengthens.

### Bond with periodic coupon payments
Here is the step-by-step mathematical derivation of Convexity for a bond with periodic coupon payments.

Unlike a zero-coupon bond, a coupon-bearing bond has multiple cash flows occurring at different periods. To find its convexity, we still take the second derivative of the price function with respect to the yield and divide it by the price, but we must apply this to the sum of all cash flows.

### Step 1: Define the Pricing Equation for a Coupon Bond

The price $P$ of a bond is the sum of the present values of all future cash flows $CF_t$. These cash flows include the periodic coupon payments and the final principal repayment at maturity $T$, all discounted at the yield to maturity $y$.

$$P = \sum_{t=1}^{T} \frac{CF_t}{(1+y)^t}$$

To make differentiation easier, we rewrite the equation using negative exponents:

$$P = \sum_{t=1}^{T} CF_t(1+y)^{-t}$$

### Step 2: Find the First Derivative (Price Sensitivity)

We take the first derivative of the price with respect to the yield ($\frac{dP}{dy}$). By applying the power rule to the summation:

$$\frac{dP}{dy} = \sum_{t=1}^{T} -t \cdot CF_t(1+y)^{-t-1}$$

_(Note: Dividing this by $P$ gives you the negative Modified Duration)._

### Step 3: Find the Second Derivative (Curvature)

To find the curvature of the price-yield relationship, we take the second derivative by differentiating the result from Step 2 with respect to $y$:

$$\frac{d^2P}{dy^2} = \sum_{t=1}^{T} -t(-t-1) \cdot CF_t(1+y)^{-t-2}$$

Multiply the negative terms to clean up the expression:

$$\frac{d^2P}{dy^2} = \sum_{t=1}^{T} t(t+1) \cdot CF_t(1+y)^{-t-2}$$

### Step 4: Apply the Convexity Formula

The standard measure for Convexity $C$ is the second derivative divided by the bond's current price $P$:

$$C = \frac{1}{P} \frac{d^2P}{dy^2}$$

Substitute the second derivative we found in Step 3 into the formula:

$$C = \frac{1}{P} \sum_{t=1}^{T} t(t+1) \cdot CF_t(1+y)^{-t-2}$$

### Step 5: Simplify into the Standard Financial Formula

To make the formula more intuitive for financial analysis, we factor out $(1+y)^{-2}$ (which is the same as dividing by $(1+y)^2$) from the summation:

$$C = \frac{1}{P(1+y)^2} \sum_{t=1}^{T} t(t+1) \frac{CF_t}{(1+y)^t}$$

Alternatively, we can express this by grouping the present value of each cash flow ($\frac{CF_t}{(1+y)^t}$) divided by the total price $P$. This creates a present value "weight" ($w_t$) for each period's cash flow:

$$C = \frac{1}{(1+y)^2} \sum_{t=1}^{T} t(t+1) \cdot w_t$$

_(where $w_t = \frac{CF_t / (1+y)^t}{P}$)_

### The Takeaway

For a bond with periodic coupons, convexity is effectively a weighted average of the squared times to receipt of cash flows, adjusted by the yield factor $\frac{1}{(1+y)^2}$. Because the cash flows are spread out over time rather than concentrated at maturity, a coupon-bearing bond will always have a **lower convexity** than a zero-coupon bond of the exact same maturity and yield.
