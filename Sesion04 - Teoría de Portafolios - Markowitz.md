# SESIÓN 4
## Teoría de Portafolios - Markowitz

**Curso:** Mercado de Capitales 

**Profesor:** Ismael D. Valverde Ambriz  

---

## OBJETIVOS DE APRENDIZAJE

Al finalizar esta sesión, los estudiantes serán capaces de:

1. Explicar la teoría moderna de portafolios de Markowitz
2. Construir la frontera eficiente con 2 y N activos
3. Calcular el portafolio de mínima varianza global (GMV)
4. Identificar el portafolio de máximo Sharpe (tangente)
5. Entender el efecto de la correlación en la diversificación
6. Instrumentar optimización con restricciones (no venta en corto)
7. Evaluar portafolios usando backtesting

---

## CONTEXTO HISTÓRICO Y MOTIVACIÓN

### La revolución de Markowitz

**Harry Markowitz - 1952:**
- Estudiante de PhD en Universidad de Chicago
- Paper: "Portfolio Selection" - Journal of Finance
- Premio Nobel de Economía 1990 (compartido con Sharpe y Miller)

**Idea revolucionaria:**
"No pongas todos tus huevos en una canasta" → Formalizado matemáticamente

**Antes de Markowitz:**
- Inversionistas analizaban acciones individualmente
- Buscaban "la mejor acción"
- No había framework para combinar activos

**Después de Markowitz:**
- El todo (portafolio) es DIFERENTE a la suma de las partes
- Riesgo de portafolio ≠ promedio de riesgos individuales
- Nace la gestión cuantitativa de portafolios

---

## ESTRUCTURA DE LA SESIÓN

### BLOQUE 1: Fundamentos y motivación

**1.1 Revisión Sesión 3**

Pregunta:
"¿Por qué los retornos NO son normales?"

(Respuestas: asimetría negativa, colas pesadas, eventos extremos)

**Conexión con Markowitz:**
"Markowitz asume normalidad (solo usa $\mu$ y $\sigma^{2}$). Ahora sabemos que es una simplificación. AÚN ASÍ, su teoría es útil como punto de partida y se usa ampliamente en la industria."

**1.2 La pregunta fundamental**

```
PREGUNTA: Tienes dos activos:
Activo A: μ = 12%, σ = 20%
Activo B: μ = 8%,  σ = 15%

¿Cuál es mejor?
```

**Respuesta:**
"¡DEPENDE de tu aversión al riesgo!

Pero hay algo más importante: ¿Por qué elegir SOLO uno?

¿Qué pasa si combinamos ambos?"

**1.3 Demostración numérica rápida**

Calcular:

Portafolio 50-50:
- Retorno: 0.5(12%) + 0.5(8%) = 10%
- Volatilidad: NO es 0.5(20%) + 0.5(15%) = 17.5%

"¿Por qué no?"

Mostrar fórmula:

$$\sigma_{p}^{2} = w_{1}^{2}\sigma_{1}^{2}+w_{2}^{2}\sigma_{2}^{2}+2w_{1}w_{2}\sigma_{1}\sigma_{2}\rho$$

"El último término (correlación) es la CLAVE de la diversificación."

Calcular con $\rho# = 0.3:

$\sigma_{\rho}$ = √[0.25(400) + 0.25(225) + 2(0.5)(0.5)(20)(15)(0.3)]

$\sigma_{\rho}$ = √[100 + 56.25 + 45] = √201.25 = 14.2%

**Resultado sorprendente:**
"¡14.2% es MENOR que ambos activos individuales!

Retorno: 10% (intermedio)
Riesgo: 14.2% (menor que 15% y 20%)

Esto es DIVERSIFICACIÓN."

---

### BLOQUE 2: Frontera eficiente con 2 activos

**2.1 Construcción de la frontera**

**Vamos paso a paso:**

"Crear 101 portafolios variando los pesos de 0% a 100%."

Tabla de portafolios:
- 100% A, 0% B
- 75% A, 25% B
- 50% A, 50% B
- ...
- 0% A, 100% B

**Puntos clave a señalar:**

1. **La curva es CÓNCAVA**
   "No es una línea recta. La curvatura muestra el beneficio de diversificación."

2. **Punto de mínima varianza**
   "El punto más a la izquierda. Tiene el MENOR riesgo posible combinando estos activos."

3. **Frontera eficiente vs ineficiente**
   "Parte superior: eficiente (nadie querría estar en la parte inferior)"

4. **Los activos individuales están EN o ARRIBA de la curva**
   "Nunca debajo (eso violaría la posibilidad de diversificar)"

**Pregunta:**
"¿Dónde invertir en esta curva?"

(depende de aversión al riesgo)

**2.2 Efecto de la correlación**

Ejecutar Parte 4 del script.

**Vea la gráfica con 5 correlaciones diferentes.**

**Análisis guiado:**

"Observar cómo cambia la frontera:

**ρ = -0.9 (verde oscuro):**
- Curva muy pronunciada hacia la izquierda
- Riesgo se puede reducir DRAMÁTICAMENTE
- En el extremo, ρ = -1 permitiría eliminar TODO el riesgo

**ρ = 0 (azul):**
- Beneficio moderado de diversificación
- Típico de activos de sectores diferentes

**ρ = 0.9 (rojo):**
- Curva casi recta
- Poco beneficio de diversificación
- Típico de activos del mismo sector"

**Pregunta clave:**
"¿Por qué diversificar entre CEMEX y GCC (ambas cementeras) da menos beneficio que entre CEMEX y WALMEX?"

(Respuesta: correlación alta entre empresas del mismo sector)

**Lección práctica:**
"Para maximizar diversificación, busca activos con correlaciones BAJAS:
- Diferentes sectores
- Diferentes países
- Diferentes clases de activos (acciones, bonos, bienes raíces)"

---

### BLOQUE 3: Frontera eficiente con N activos

**3.1 Descarga y preparación de datos**

Ejecute Parte 5 del script.

Note que:
"Con 2 activos, la frontera es una curva simple.

Con N activos, la frontera es una superficie en N dimensiones.

Pero podemos proyectarla en 2D: riesgo (x) vs retorno (y)."

**Mostrar parámetros calculados:**

```
Retornos esperados:
WALMEX:  12%
CEMEX:   5%
BANORTE: 15%
FEMSA:   10%

Volatilidades:
WALMEX:  22%
CEMEX:   35%
BANORTE: 28%
FEMSA:   20%

Correlaciones:
...
```

**Análisis rápido:**
"BANORTE tiene mayor retorno pero también mayor riesgo que FEMSA.  
CEMEX es muy volátil (sector cíclico).  
¿Cuál es 'mejor'? ¡Depende! Por eso necesitamos portafolios."

**3.2 Portafolio de mínima varianza global**

Ejecutar Parte 6 del script.

**Explicación del GMV:**

"GMV = Global Minimum Variance

Es el portafolio con el MENOR riesgo posible usando todos los activos disponibles.

No necesariamente tiene el mejor Sharpe, pero es útil como:
1. Punto de referencia
2. Estrategia defensiva
3. Base para construir otros portafolios"

**Fórmula:**

$$w_{GWV}=\frac{\Sigma^{-1} \mathbf{1}}{\mathbf{1}^T \Sigma^{-1} \mathbf{1}}$$

donde $\Sigma^{-1}$ es la matriz inversa de covarianza y 1 es un vector de unos.

**Mostrar resultados:**

```
Pesos GMV:
WALMEX:  35%
CEMEX:   10%
BANORTE: 20%
FEMSA:   35%

Volatilidad GMV: 16.5%
Volatilidad mínima individual: 20% (FEMSA)
```

**Punto CRÍTICO:**

"¡El GMV tiene MENOR riesgo (16.5%) que el activo individual menos riesgoso (FEMSA con 20%)!

Esto demuestra matemáticamente el poder de la diversificación."

**Clave:**
"¿Notan algo interesante en los pesos?"

Nota: CEMEX solo 10% a pesar de ser incluido. ¿Por qué? Alta volatilidad, pero las correlaciones permiten usarlo un poco.

**3.3 Frontera eficiente completa**

Ejecute Parte 7 del script.

**Explicación técnica:**

"Para generar la frontera:
1. Elegimos un retorno objetivo
2. Minimizamos riesgo sujeto a ese retorno
3. Repetimos para muchos retornos objetivos
4. Unimos todos los puntos"

Esto es **optimización cuadrática** (programación matemática).

**Proyectar la gráfica.**

**Análisis:**

"Observen:
- La frontera pasa por el GMV (punto más izquierdo)
- Se extiende hasta el activo de mayor retorno
- Todos los activos individuales están en o bajo la frontera
- Los puntos ROJOS (activos) son DOMINADOS por la frontera azul"

**Definición clave:**

"Un portafolio A DOMINA a un portafolio B si:
- Mayor retorno y mismo riesgo, O
- Mismo retorno y menor riesgo, O
- Mayor retorno Y menor riesgo

Los activos individuales son DOMINADOS por portafolios en la frontera."

---

### BLOQUE 4: Ratio de Sharpe y portafolio tangente

**4.1 Introducción al Sharpe Ratio**

"William Sharpe (Nobel 1990, junto con Markowitz):

¿Cómo comparamos portafolios con diferente riesgo Y retorno?

Necesitamos una medida ajustada por riesgo."

**Fórmula**:

SHARPE RATIO = (Retorno - Tasa Libre Riesgo) / Volatilidad

$$SR = \frac{\mu_p - r_f}{\sigma_p}$$

Esta fórmula ayuda a determinar cuánto retorno excedente estás obteniendo por cada unidad de volatilidad que asumes:
- $SR$: Sharpe Ratio.
- $\mu_p$: Rendimiento esperado del portafolio (o activo).
- $r_f$: Tasa libre de riesgo (como los bonos del tesoro).
- $\sigma_p$: Desviación estándar del rendimiento del portafolio (volatilidad).

"Interpretación: Retorno excedente por unidad de riesgo.

Ejemplo:
Portafolio A: $\mu$ = 12%, $\sigma$ = 20%, $r_{f}$ = 5%
SR_A = (12% - 5%) / 20% = 0.35

Portafolio B: $\mu$ = 10%, $\sigma$ = 15%, $r_{f}$ = 5%
SR_B = (10% - 5%) / 15% = 0.33

Portafolio A es mejor (mayor Sharpe)."

**Reglas prácticas:**
- SR < 0.5: Pobre
- SR 0.5 - 1.0: Bueno
- SR 1.0 - 2.0: Muy bueno
- SR > 2.0: Excelente (raro)

**4.2 Portafolio de máximo Sharpe**

Ejecute Parte 8 del script.

**Explicación del portafolio tangente:**

"De TODOS los portafolios en la frontera eficiente, hay uno especial: el que maximiza el Sharpe.

Se llama PORTAFOLIO TANGENTE porque es tangente a una línea desde r_f."

**Mostrar gráfica con CML.**

**Capital Market Line (CML):**

"Esta línea verde representa combinaciones de:
- Activo libre de riesgo (r_f)
- Portafolio tangente

¿Por qué es importante?

TODOS los puntos en la CML dominan a TODA la frontera eficiente (excepto el punto tangente).

**Implicación (TEOREMA DE SEPARACIÓN):**

El teorema establece que la decisión de inversión de cualquier agente puede "separarse" en dos pasos independientes:
- Optimización del Portafolio de Riesgo: Encontrar el Portafolio de Tangencia ($P$), que es aquel que maximiza el Ratio de Sharpe. Matemáticamente, buscamos los pesos $w$ que maximizan:

$$SR = \frac{w^T \mu - r_f}{\sqrt{w^T \Sigma w}}$$

Sujeto a que la suma de los pesos sea 1 ($\sum w_i = 1$).

- Asignación de Capital: Combinar ese portafolio óptimo $P$ con un activo libre de riesgo ($r_f$) según la tolerancia al riesgo del inversor. El rendimiento esperado del portafolio total ($E[R_c]$) será:

$$E[R_c] = r_f + y(\mu_p - r_f)$$

Donde $y$ es la proporción invertida en el portafolio con riesgo.

**Explicación simple del teorema:** 
Imagina que vas a un restaurante muy famoso que solo sirve un platillo combinado perfecto (el Portafolio de Tangencia). El chef ha decidido que esa mezcla de ingredientes es la que mejor sabor da por cada caloría (mejor retorno por unidad de riesgo).El Teorema de la Separación dice que:
- Paso 1 (El Chef): El chef diseña la mejor mezcla de activos con riesgo del mercado. Esta mezcla es la misma para todos, sin importar si eres un inversor conservador o arriesgado. Es el punto donde la línea que sale desde la tasa libre de riesgo ($r_f$) toca "rozando" (tangente) a la frontera eficiente.
- Paso 2 (Tú): Tú decides cuánta hambre tienes. Si eres miedoso, pides un poco de ese plato y mucha agua (activo libre de riesgo). Si eres audaz, pides tres platos y hasta pides dinero prestado para comprar más.

En resumen: La "receta" del portafolio con riesgo no depende de tus sentimientos; tus sentimientos solo deciden qué tan grande es la porción de ese portafolio que compras frente a tener el dinero seguro en el banco.

**NOTA**: Todos los inversionistas racionales, independientemente de su aversión al riesgo, deberían:
1. Invertir en el MISMO portafolio riesgoso (el tangente)
2. Ajustar su riesgo total combinándolo con el activo libre de riesgo

Inversionista conservador: más en $r_{f}$, menos en tangente
Inversionista agresivo: menos en $r_{f}$ (o pedir prestado), más en tangente"

**Pesos del portafolio tangente:**

```
WALMEX: 25%
CEMEX:  15%
BANORTE: 40%
FEMSA:  20%

Sharpe: 0.85
```

**Análisis:**
"BANORTE tiene el mayor peso (40%). ¿Por qué?  
Tiene el mayor retorno esperado y volatilidad moderada.

CEMEX solo 15% a pesar de su volatilidad, porque la correlación con otros ayuda."

**4.3 Interpretación de la CML**

"Puntos en la CML:

**A la izquierda del tangente:**
- Más del 50% en r_f
- Menos del 50% en tangente
- Menor riesgo que tangente
- Inversionista conservador

**En el punto tangente:**
- 100% en portafolio tangente
- 0% en r_f

**A la derecha del tangente:**
- >100% en tangente (pedir prestado al r_f para invertir más)
- Apalancamiento
- Mayor riesgo que tangente
- Inversionista agresivo"

---

### BLOQUE 5: Restricciones prácticas

**5.1 Problema de venta en corto**

"En la teoría pura de Markowitz, los pesos pueden ser negativos.

Peso negativo = VENTA EN CORTO (short selling):
1. Pides prestadas acciones
2. Las vendes hoy
3. Las recompras después (esperando que bajen)
4. Las devuelves

**Problemas prácticos:**
- Requiere cuenta especial (margin)
- Costos de préstamo de acciones
- Riesgo ilimitado si sube el precio
- Prohibido en algunos mercados/fondos
- Restricciones regulatorias"

**5.2 Optimización con restricciones**

Ejecute Parte 9 del script.

**Explicación:**

"Agregamos restricción: w ≥ 0 (no negativos)

Esto se llama OPTIMIZACIÓN CON RESTRICCIONES.

Matemáticamente más complejo, pero más realista."

**Mostrar comparación:**

```
CON venta en corto:
WALMEX:  25%
CEMEX:   15%
BANORTE: 40%
FEMSA:   20%
Sharpe: 0.85

SIN venta en corto:
WALMEX:  30%
CEMEX:   8%
BANORTE: 45%
FEMSA:   17%
Sharpe: 0.82
```

**Análisis:**

"El Sharpe baja de 0.85 a 0.82.

Las restricciones SIEMPRE reducen el Sharpe (en teoría).

PERO hacen el portafolio más práctico e implementable.

Tradeoff: teoría vs práctica."

**Otras restricciones comunes:**
- Límites de concentración: w_i ≤ 20%
- Restricciones sectoriales: suma de pesos por sector
- Mínimo de posiciones: w_i = 0 o w_i ≥ 5% (no micro-posiciones)
- Turnover limits: cuánto puedes cambiar de un periodo a otro

---

### BLOQUE 6: Backtest y evaluación

**6.1 Desempeño histórico**

Ejecute Parte 10 del script.

**Advertencia CRÍTICA:**

"¡CUIDADO con backtesting!

Estamos usando los MISMOS datos para:
1. Estimar parámetros ($\MU$, $\Sigma$)
2. Evaluar desempeño

Esto se llama IN-SAMPLE testing.

**Sesgo de sobreajuste (overfitting):**
El portafolio se ve bien porque está optimizado para esos datos específicos.

**Práctica correcta:**
- Datos de entrenamiento (estimar parámetros): 2020-2022
- Datos de prueba (evaluar): 2023-2024
- OUT-OF-SAMPLE performance"

**Mostrar resultados:**

```
ESPERADO (ex-ante):
Retorno: 13.5%
Volatilidad: 18.2%
Sharpe: 0.85

REALIZADO (backtest):
Retorno: 11.2%
Volatilidad: 21.5%
Sharpe: 0.62
```

**IMPORTANTE:**

"El desempeño real es PEOR que el esperado. ¿Por qué?

1. **Error de estimación:** μ y Σ estimados tienen error
2. **Cambios estructurales:** Correlaciones cambian en crisis
3. **Eventos imprevistos:** COVID, guerra, etc.
4. **Sesgo de optimización:** Maximizar Sharpe tiende a sobreestimar"

**6.2 Comparación con benchmark**

"Comparamos con portafolio equiponderado (1/N):

Máximo Sharpe: +58% acumulado  
Equiponderado: +45% acumulado

¿Vale la pena la complejidad de Markowitz?

Debate académico: '1/N rule' (equiponderado) a veces gana porque:
- No error de estimación
- Robusto
- Simple

Pero en general, optimización sofisticada ayuda."

---

### BLOQUE 7: Rebalanceo y cierre

**7.1 Rebalanceo de portafolios**

Ejecute Parte 11 del script.

"Los pesos cambian con el tiempo cuando los precios cambian.

Ejemplo:
Empiezas con 50% WALMEX, 50% CEMEX  
WALMEX sube 20%, CEMEX baja 10%  
Ahora tienes ~54% WALMEX, ~46% CEMEX

¿Rebalanceas de vuelta a 50-50?

**PROS del rebalanceo:**
- Mantiene perfil de riesgo deseado
- Disciplina de 'vender caro, comprar barato'
- Controla concentración

**CONTRAS:**
- Costos de transacción (comisiones)
- Impuestos sobre ganancias
- Tiempo y esfuerzo"

**Frecuencias comunes:**
- Mensual: activo, costoso
- Trimestral: balance común
- Anual: pasivo, barato
- Basado en umbrales: cuando desviación > 5%

**7.2 Cierre y preparación Sesión 5**

**Resumen de puntos clave:**

"Hoy aprendimos:
1. Diversificación reduce riesgo (matemáticamente probado)
2. Frontera eficiente muestra portafolios óptimos
3. Sharpe Ratio permite comparar portafolios
4. Correlaciones bajas → mayor beneficio
5. Restricciones prácticas reducen Sharpe pero hacen portafolios implementables

**PRÓXIMA SESIÓN: CAPM**

Markowitz nos dice cómo construir portafolios óptimos.

CAPM nos dice qué debería pasar en EQUILIBRIO cuando TODOS los inversionistas usan Markowitz.

Conectaremos riesgo individual con riesgo de mercado (beta)."

---

## EJERCICIOS Y TAREA

**Obligatorios:** 1-4  
**Avanzados:** 5-7

**Énfasis:**
- Ejercicio 3 (frontera completa) es el más importante
- Ejercicio 6 (backtest) introduce concepto crucial de out-of-sample

---

## SOLUCIONES A EJERCICIOS SELECCIONADOS

### Ejercicio 1:

```r
# Parámetros
mu_X <- 0.15; sigma_X <- 0.25
mu_Y <- 0.10; sigma_Y <- 0.18
rho <- 0.2

# Generar frontera
w_X <- seq(0, 1, 0.01)
w_Y <- 1 - w_X
mu_p <- w_X * mu_X + w_Y * mu_Y
sigma_p <- sqrt(w_X^2 * sigma_X^2 + w_Y^2 * sigma_Y^2 + 
                2 * w_X * w_Y * sigma_X * sigma_Y * rho)

plot(sigma_p * 100, mu_p * 100, type = "l")

# b) Mínima varianza
idx_min <- which.min(sigma_p)
w_X_min <- w_X[idx_min]  # ≈ 0.54
w_Y_min <- w_Y[idx_min]  # ≈ 0.46

# d) ρ = 0.2 da MÁS beneficio que ρ = 0.8
# (curva más hacia la izquierda)
```

### Ejercicio 3 (estructura):

```r
# Descargar 3 activos
tickers <- c("WALMEX.MX", "GMEXICOB.MX", "GFNORTEO.MX")
# ... descargar y calcular retornos

# Parámetros
mu <- colMeans(retornos) * 252
Sigma <- cov(retornos) * 252

# GMV
uno <- rep(1, 3)
Sigma_inv <- solve(Sigma)
w_GMV <- (Sigma_inv %*% uno) / sum(Sigma_inv %*% uno)

# Frontera (50 portafolios)
retornos_obj <- seq(min(mu), max(mu), length = 50)
frontera <- data.frame(Retorno = numeric(50), Riesgo = numeric(50))

# ... calcular cada portafolio con solve.QP

# Graficar
plot(frontera$Riesgo, frontera$Retorno)
points(sqrt(diag(Sigma)), mu)  # Activos
points(sqrt(t(w_GMV) %*% Sigma %*% w_GMV), sum(w_GMV * mu))  # GMV
```

---

## PROBLEMAS COMUNES Y SOLUCIONES

### Problema 1: solve.QP falla
**Causa:** Matriz Sigma no es positiva definida  
**Solución:**
```r
# Agregar pequeña cantidad a diagonal
Sigma_ajustada <- Sigma + diag(1e-8, nrow(Sigma))
```

### Problema 2: Pesos no suman 1
**Causa:** Error numérico en optimización  
**Solución:**
```r
# Normalizar pesos
w <- w / sum(w)
```

### Problema 3: Sharpe negativo
**Causa:** Retorno < tasa libre de riesgo  
**Explicación:** Matemáticamente correcto, portafolio no vale la pena

---

## PUNTOS PEDAGÓGICOS

### 1. Comprender la INTUICIÓN sobre matemáticas
- "¿Por qué funciona?" antes de "¿Cómo se calcula?"
- Usar visualizaciones constantemente
- Conectar con decisiones reales de inversión (esto ayuda a comprender mucho mejor)

### 2. Piense en "el elefante en la sala"
"¿Si Markowitz es tan bueno, por qué no todos lo usan?"

**Respuestas:**
- SÍ se usa (fondos, pensiones, institucionales)
- Requiere estimación de parámetros (error)
- Sensible a inputs
- Supuestos (normalidad) son fuertes
- Versiones modificadas son más comunes

### 3. Conecte con sesión anterior
"Sesión 3: retornos NO son normales  
Sesión 4: Markowitz asume normalidad  

¿Contradicción? No. Es una aproximación útil.  
Eventualmente veremos modelos más sofisticados."

### 4. Uso de ejemplos mexicanos
- Siempre usar datos de BMV cuando sea posible
- Referenciar empresas que conozcan
- Conectar con noticias/eventos locales (también es bueno para encontrar temas de tesis)

---

## PREPARACIÓN PARA SESIÓN 5

**Tema:** CAPM y Modelos Factoriales (repasar de forma autodidácta)

**Conexión:**
"Markowitz → cómo invertir  
CAPM → qué deberían ser los precios en equilibrio"

**Materiales:**
- Datos del IPC (mercado)
- Múltiples acciones individuales
- Introducción a concepto de beta

---

¡Esta es una de las sesiones más importantes del curso! Es IMPORTANTE tomarse el tiempo para entender bien la intuición de la diversificación.

