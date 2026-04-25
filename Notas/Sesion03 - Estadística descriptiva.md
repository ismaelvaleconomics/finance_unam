# SESIÓN 3
## Estadística Descriptiva de Mercados

**Curso:** Mercado de capitales
**Profesor:** Ismael Valverde

---

## OBJETIVOS DE APRENDIZAJE

Al finalizar esta sesión, los estudiantes serán capaces de:

1. Calcular e interpretar los cuatro momentos estadísticos de retornos financieros
2. Entender por qué los retornos NO son normales (colas pesadas, asimetría)
3. Usar Q-Q plots y pruebas formales para evaluar normalidad
4. Identificar eventos extremos y comprender riesgo de cola
5. Calcular y visualizar volatilidad rodante
6. Analizar drawdowns y recuperaciones
7. Aplicar estos conceptos a datos reales del IPC y acciones mexicanas

---

## CONEXIÓN CON SESIONES ANTERIORES

**Sesión 1:** Aprendimos a descargar datos y calcular retornos  
**Sesión 2:** Calculamos media ($\mu$) y varianza ($\sigma^{2}$) en contexto de portafolios  
**Sesión 3:** Profundizar en la DISTRIBUCIÓN completa de retornos

**Mensaje clave:** "En Sesión 2 usamos media y varianza para portafolios. Hoy descubriremos que los retornos tienen características que la distribución normal no captura: eventos extremos, asimetría, colas pesadas. Esto es crítico para entender riesgo."

---

## PREPARACIÓN PREVIA

### Tener listo:
- [ ] Librerías instaladas: `quantmod`, `PerformanceAnalytics`, `moments`, `tseries`, `ggplot2`


### Concepto previo a refrescar:
- Distribución normal y sus propiedades
- Concepto de percentiles y cuantiles

---

## ESTRUCTURA DE LA SESIÓN

### BLOQUE 1: Revisión y motivación

**1.1 Revisión rápida Sesión 2**

Recuerde:
- "¿Qué es la varianza de un portafolio?"
- "¿Cómo se calcula?"
- "¿Cuál es la fórmula matricial?" ($w^{T} * Σ * w$)

**1.2 Motivación para la sesión**

**Historia real:**

"El 19 de octubre de 1987, el Dow Jones cayó 22.6% en UN DÍA.

Si los retornos fueran normales con volatilidad del 15% anual, ¿cuál es la probabilidad de este evento?

Cálculo rápido:
- Volatilidad diaria = 15% / √252 ≈ 0.94%
- Caída observada = 22.6%
- Desviaciones estándar = 22.6 / 0.94 ≈ 24 sigmas

En distribución normal, un evento de 24 sigmas tiene probabilidad de ~10^-126

¡Debería ocurrir una vez en la vida del universo!"

**Pregunta:**
"¿Qué nos dice esto? ¿Los retornos son realmente normales?"

**Respuesta:** No. Eventos extremos ocurren MÁS frecuentemente.

**Transición:**
"Tenemos que estudiar exactamente QUÉ hace que los retornos financieros sean diferentes de la distribución normal, y por qué esto importa."

---

### BLOQUE 2: Los cuatro momentos estadísticos

**2.1 Introducción a los momentos**

Importante:

```
CUATRO MOMENTOS DE UNA DISTRIBUCIÓN:

1° Media (μ)          → ¿Dónde está centrada?
2° Varianza (σ²)      → ¿Qué tan dispersa?
3° Asimetría (skew)   → ¿Tiene cola larga?
4° Curtosis           → ¿Qué tan gruesas las colas?
```

"La distribución NORMAL está completamente determinada por los primeros dos momentos ($\mu$ y $\sigma$).

Pero los retornos financieros necesitan los CUATRO momentos para ser descritos completamente."

**2.2 Primer y segundo momento**

Ejecutar la Parte 2 y 3 del script de R:

```r
# Crear datos de ejemplo
set.seed(123)
datos_normales <- rnorm(1000, mean = 0, sd = 1)

# Media
mean(datos_normales)

# Varianza
var(datos_normales)

# Desviación estándar
sd(datos_normales)
```

**Recordatorio rápido:**
- Media: retorno esperado
- Varianza: dispersión, riesgo
- Desv. Est.: volatilidad (√varianza)

Esto ya se analizó en la Sesión 2. Ahora sigue comprender por qué los momentos 3 y 4 que son NUEVOS y CRÍTICOS.

**2.3 Tercer momento - Asimetría/Skewness**

**Explicación conceptual:**

Proyectar el script Parte 5 con las tres distribuciones:

```r
# Normal: skewness ≈ 0
# Asimetría positiva: skewness > 0
# Asimetría negativa: skewness < 0
```

**En la pizarra, dibujar:**

```
Asimetría NEGATIVA (< 0):        Asimetría POSITIVA (> 0):
     /\                                   /\
    /  \                                 /  \___
   /    \___                            /       \___
  /         \___                       /            \___
  
Cola IZQUIERDA larga              Cola DERECHA larga
```

**Interpretación financiera (punto CRUCIAL):**

"Para un inversionista:

**Asimetría NEGATIVA = MALO**
- Más caídas extremas que subidas extremas
- Ejemplo: Crash bursátil del 2008
- Retornos típicos pequeños, pero con riesgo de grandes pérdidas

**Asimetría POSITIVA = BUENO**
- Más subidas extremas que caídas extremas  
- Ejemplo: Inversión en startups (muchas quiebran poco, algunas explotan al alza)
- Pérdidas limitadas, potencial de grandes ganancias"

**Pregunta interactiva:**
Si tienen dos activos con mismo retorno esperado y misma volatilidad, pero uno tiene skewness de -0.5 y otro de +0.5, ¿cuál prefieren?

(Respuesta: +0.5, obviamente)

**Demostración en R:**

Ejecute y muestre los histogramas con diferentes skewness.

**Punto clave:**
"Observar cómo en asimetría negativa, la MEDIA está a la IZQUIERDA de la MEDIANA. Hay una cola larga de pérdidas que jala la media hacia abajo."

**2.4 Cuarto momento - Curtosis**

**Explicación conceptual:**

"Curtosis mide el 'grosor' de las colas. Es el momento más difícil de visualizar pero el MÁS IMPORTANTE para gestión de riesgos."

Importante:

```
Curtosis = 3: Distribución NORMAL (mesocúrtica)
Curtosis > 3: COLAS PESADAS (leptocúrtica)
Curtosis < 3: COLAS LIGERAS (platicúrtica)
```

"En finanzas usamos EXCESS KURTOSIS = Curtosis - 3

Excess kurtosis = 0: normal
Excess kurtosis > 0: más eventos extremos que normal
Excess kurtosis < 0: menos eventos extremos que normal"

**Visualización clave:**

Proyectar los histogramas de datos_normales vs datos_colas_pesadas.

"Observen: colas pesadas tienen:
1. Pico MÁS ALTO en el centro
2. Colas MÁS GRUESAS (más observaciones extremas)
3. 'Hombros' más bajos"

**Interpretación financiera (CRÍTICA):**

"¿Por qué importa la curtosis?

Modelo normal predice:
- 68% de retornos entre $\mu \pm 1\sigma$
- 95% entre $\mu \pm 2\sigma$
- 99.7% entre $\mu \pm 3\sigma$

Pero con colas pesadas (curtosis alta):
- Eventos de $3\sigma$, $4\sigma$, $5\sigma$ ocurren MUCHO más frecuentemente
- Los modelos de riesgo basados en normalidad SUBESTIMAN el riesgo
- VaR calculado asumiendo normalidad será DEMASIADO OPTIMISTA"

**Ejemplo numérico (importante):**

"Si calculamos VaR al 99% asumiendo normalidad, esperamos perder más del VaR el 1% del tiempo (3.65 días al año).

Con colas pesadas, podríamos exceder el VaR el 3-5% del tiempo (11-18 días al año).

Esto es ENORME para gestión de riesgos."

**Demostración en R:**

Ejecutar Parte 6 del script, mostrar los dos histogramas lado a lado.

---

### BLOQUE 3: Aplicación con datos reales

**3.1 Descarga de datos**

Ejecutar Parte 7 del script:

```r
tickers <- c("^MXX", "WALMEX.MX", "CEMEXCPO.MX", "GFNORTEO.MX")
# Ajustar según lo que funcione en el sistema
```

Analizar el IPC y 3 acciones grandes mexicanas. Calcular los 4 momentos y ver si son normales o no:

**3.2 Análisis de momentos - datos reales**

Ejecutar Parte 8 del script.

**Tabla de estadísticas:**

```
                Media  Volatilidad  Asimetria  Curtosis  Excess_Curtosis
IPC            0.08      0.18        -0.5       5.2          2.2
WALMEX         0.12      0.22        -0.3       4.8          1.8
CEMEX          0.05      0.35        -0.8       7.1          4.1
BANORTE        0.15      0.28        -0.4       5.5          2.5
```

**(Nota: Números ejemplo, los reales variarán)**

**Análisis:**

"Observar varias cosas:

1. **TODAS tienen asimetría negativa**
   - Más riesgo de caídas extremas que de subidas
   - Típico de mercados accionarios

2. **TODAS tienen excess curtosis positiva**
   - Colas más pesadas que la normal
   - Eventos extremos más frecuentes

3. **CEMEX tiene la curtosis más alta**
   - Sector cíclico, más volatilidad extrema
   - ¿Por qué? (Discusión: construcción, economía global)

4. **BANORTE tiene mejor retorno ajustado por riesgo**
   - Mayor retorno, volatilidad moderada
   - Asimetría menos negativa"

**Pregunta:**
"¿Cuál activo tiene peor perfil de riesgo? ¿Por qué?"

(Respuesta: CEMEX - alta volatilidad, asimetría muy negativa, curtosis altísima)

**3.3 Visualización de distribuciones**

Ejecutar Parte 9 del script - vea los 4 histogramas.

**Punto de observación:**
"La línea azul es cómo se VERÍA si fuera normal.  
El histograma gris es cómo es REALMENTE.

Note:
- Picos más altos que la normal
- Colas más gruesas (especialmente izquierda)
- Asimetría visible

---

### BLOQUE 4: Pruebas de normalidad

**4.1 Q-Q Plots - Prueba visual**

Ejecutar Parte 10 del script.

**Explicación de Q-Q plots:**

"Q-Q = Quantile-Quantile

Comparar los cuantiles de nuestros datos con los de una distribución normal.

Si los datos fueran normales, todos los puntos estarían sobre la línea roja.

Desviaciones de la línea indican NO normalidad."

**Interpretación guiada:**

Proyectar los 4 Q-Q plots y analizar:

"Observar:
- En el CENTRO: puntos cerca de la línea (comportamiento normal)
- En las COLAS (extremos izq/der): puntos se desvían
  - Arriba de la línea: valores más extremos de lo esperado
  - Abajo: menos extremos

¿Qué vemos en nuestros datos?
- Cola izquierda: puntos ABAJO de la línea (más caídas extremas)
- Cola derecha: puntos arriba (más subidas extremas)

Esto confirma: colas pesadas y asimetría."

**4.2 Test de Jarque-Bera - Prueba formal**

Ejecutar Parte 11 del script.

**Explicación del test:**

"Jarque-Bera es una prueba estadística formal de normalidad.

H₀ (hipótesis nula): Los datos son normales  
Hₐ (hipótesis alternativa): Los datos NO son normales

Si p-value < 0.05: rechazamos H₀ (NO son normales)  
Si p-value ≥ 0.05: no rechazamos H₀ (podrían ser normales)"

**Mostrar resultados:**

```
IPC: p-value < 0.0001 → RECHAZAMOS normalidad
WALMEX: p-value < 0.0001 → RECHAZAMOS normalidad
CEMEX: p-value < 0.0001 → RECHAZAMOS normalidad
BANORTE: p-value < 0.0001 → RECHAZAMOS normalidad
```

**Conclusión enfática:**

"NINGÚN activo es normal.

Esto es típico en finanzas. Los retornos financieros casi NUNCA son normales.

**¿Por qué importa?**

Muchos modelos asumen normalidad:
- VaR paramétrico
- Optimización media-varianza de Markowitz (técnicamente)
- Black-Scholes (para opciones)
- Muchos modelos econométricos

Si los datos NO son normales pero asumimos que sí, nuestros modelos SUBESTIMAN el riesgo."

---

### BLOQUE 5: Series temporales y volatilidad

**5.1 Evolución de precios**

Ejecutar Parte 12 del script - gráfica de precios normalizados.

**Análisis:**
"Esta gráfica muestra desempeño relativo desde un punto común (base 100).

¿Qué activo tuvo mejor desempeño?
¿Cuál tuvo peor?
¿Observan periodos de alta volatilidad comunes?"

**5.2 Volatilidad rodante**

Ejecutar Parte 13 del script.

**Concepto de volatilidad rodante:**

"Volatilidad rodante = calcular volatilidad en ventana móvil (ej: 30 días).

Nos muestra cómo la volatilidad cambia en el TIEMPO.

Esto es importante porque violamos otro supuesto de muchos modelos: volatilidad constante."

**Observaciones clave:**

Proyectar la gráfica de volatilidad rodante y señalar:

1. **Clustering de volatilidad:**
   "Periodos de alta volatilidad tienden a agruparse.
   
   Alta volatilidad → alta volatilidad  
   Baja volatilidad → baja volatilidad
   
   Esto se llama 'clustering' o agrupamiento."

2. **Spikes de volatilidad:**
   "Identificar picos: COVID (2020), elecciones, crisis..."

3. **Co-movimiento:**
   "Las volatilidades tienden a subir JUNTAS en crisis.
   
   Esto reduce beneficios de diversificación cuando más los necesitas."

**Pregunta:**
"¿Por qué la volatilidad aumenta durante crisis?"

(Respuestas: incertidumbre, pánico, noticias, liquidez)

**Implicación práctica:**

"Si su modelo de riesgo asume volatilidad constante, subestimará el riesgo en periodos de crisis."

---

### BLOQUE 6: Drawdowns y cierre

**6.1 Retornos acumulados y drawdowns**

Ejecutar Parte 14 del script.

**Concepto de drawdown:**

"Drawdown = caída desde un máximo histórico.

Es la respuesta a: '¿Cuánto perdí desde mi mejor momento?'

Muy importante para inversionistas porque mide el DOLOR psicológico."

**Análisis de la tabla de drawdowns:**

```
IPC: Máximo Drawdown -35.2%
WALMEX: -28.5%
CEMEX: -62.1%
BANORTE: -41.3%
```

**Discusión:**
"CEMEX tuvo el peor drawdown (-62%).

¿Qué significa para un inversionista?
- Si invertiste $100,000, en el peor momento tenías $37,900
- Necesitas 165% de ganancia para recuperarte (no 62%)
- Psicológicamente devastador"

**6.2 Cierre y conexión con próxima sesión**

**Resumen de conceptos clave:**

"Aprendimos que los retornos:
1. NO son normales
2. Tienen asimetría negativa (riesgo de caídas)
3. Tienen colas pesadas (eventos extremos frecuentes)
4. La volatilidad NO es constante

**¿Por qué importa?**

Próxima sesión: Teoría de Markowitz para optimizar portafolios.

Markowitz técnicamente asume normalidad (solo usa media y varianza).

Pero ahora saben que hay MÁS que considerar: asimetría, curtosis, eventos extremos.

Esto nos llevará eventualmente a modelos más sofisticados de gestión de riesgos."

---

## EJERCICIOS Y TAREA

**Ejercicios obligatorios:** 1-4  
**Ejercicios avanzados:** 5-7

**Fecha de entrega:** Inicio de Sesión 4

**Énfasis:**
- Ejercicio 3 es el más importante (análisis completo de un activo)
- Ejercicio 5 conecta con gestión de riesgos (eventos extremos)

---

## SOLUCIONES A EJERCICIOS SELECCIONADOS

### Ejercicio 1:

```r
# a) Generar datos
datos <- rt(1000, df = 5)

# Momentos
mean(datos)          # ≈ 0
sd(datos)            # ≈ 1.29 (mayor que 1, colas pesadas)
skewness(datos)      # ≈ 0 (simétrica)
kurtosis(datos)      # ≈ 9 (mucho mayor que 3!)

# c) Sí, colas MUY pesadas (curtosis = 9 >> 3)
# d) Sí, simétrica (skewness ≈ 0)
```

### Ejercicio 3 (ejemplo con WALMEX):

```r
# a) Descargar
getSymbols("WALMEX.MX", from = "2019-01-01")
ret <- dailyReturn(Cl(WALMEX.MX))
ret <- na.omit(ret)

# b) Momentos
mean(ret) * 252           # Ret. anual
sd(ret) * sqrt(252)       # Vol. anual
skewness(ret)             # ≈ -0.3 (asim. negativa)
kurtosis(ret)             # ≈ 5.2 (colas pesadas)

# d) Test J-B
jarque.bera.test(as.numeric(ret))
# p-value < 0.001 → NO normales

# e) Los retornos NO son normales:
#    - Asimetría negativa leve
#    - Colas pesadas significativas
#    - Eventos extremos más frecuentes
```

---

## PROBLEMAS COMUNES Y SOLUCIONES

### Problema 1: Error "could not find function 'skewness'"
**Causa:** Librería `moments` no cargada  
**Solución:**
```r
install.packages("moments")
library(moments)
```

### Problema 2: Q-Q plot se ve raro
**Causa:** Demasiados datos o escalas diferentes  
**Solución:**
```r
# Limitar muestra si hay muchos datos
qqnorm(sample(retornos, 1000))
qqline(sample(retornos, 1000))
```

### Problema 3: Test Jarque-Bera falla
**Causa:** Datos en formato xts  
**Solución:**
```r
# Convertir a vector numérico
jarque.bera.test(as.numeric(retornos))
```

---

## PUNTOS PEDAGÓGICOS:

### 1. No abrumarse con matemáticas
- Enfocarse en INTERPRETACIÓN, no fórmulas
- Usar visualizaciones todo el tiempo
- Conectar siempre con implicaciones financieras

### 2. Usar ejemplos reales y dramáticos (esto es bueno para temas de tesis)
- Crash del '87, '08, COVID
- "¿Cuántas sigmas fue ese evento?"
- Esto captura la atención de los analistas

### 3. Comprenda el mensaje clave
"Los retornos NO son normales.  
Esto tiene implicaciones ENORMES para gestión de riesgos."

### 4. Anticipar confusión común
**Clave:** "Si no son normales, ¿por qué usamos media y varianza?"

**Respuesta:** "Media y varianza SIGUEN siendo útiles como resúmenes. Pero ahora sabemos que NO capturan todo el riesgo. Por eso eventualmente usaremos VaR, CVaR, y otros modelos que consideran colas pesadas."

---

## PREPARACIÓN PARA SESIÓN 4

**Tema:** Teoría de Portafolios - Markowitz

**Conexión:**
Ahora que conocen la distribución real de retornos, vamos a usar media y varianza (Markowitz) para construir portafolios óptimos. Pero tendremos en mente las limitaciones.

