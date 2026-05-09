# GUÍA - SESIÓN 8
## CVaR y Medidas Coherentes de Riesgo

**Curso:** Mercado de Capitales  
**Profesor:** Ismael Valverde  

---

## OBJETIVOS DE APRENDIZAJE

Al finalizar esta sesión, serás capaz de:

1. Explicar por qué el VaR es una medida incompleta del riesgo de cola
2. Calcular el CVaR histórico, paramétrico y por simulación Monte Carlo
3. Interpretar el CVaR como la pérdida esperada dado que ya se superó el VaR
4. Entender las cuatro propiedades de una medida coherente de riesgo
5. Demostrar por qué el VaR viola subaditividad en distribuciones no normales
6. Comparar VaR y CVaR en contextos de crisis usando datos reales de la BMV
7. Conocer la transición regulatoria de Basilea II (VaR) a Basilea III (Expected Shortfall)

---

## CONTEXTO Y MOTIVACIÓN

### El problema con el VaR

En la Sesión 7 aprendimos a calcular el VaR. Antes de abrir R, considera este ejemplo:

```
Dos portafolios, mismo VaR(99%) = −3%

Portafolio A:
  el 1% de días peores va de −3% a −3.5%
  → pérdida promedio en cola: −3.2%

Portafolio B:
  el 1% de días peores va de −3% a −25%
  → pérdida promedio en cola: −9.1%
```

El VaR reporta el mismo número para ambos. Un gestor que solo mira el VaR trata estos dos portafolios como equivalentes. Claramente no lo son.

Esta limitación no es un detalle técnico menor: es la razón por la que el sistema bancario global sufrió pérdidas catastróficas en 2008 que sus propios modelos de VaR no habían anticipado.

### ¿Qué responde el CVaR?

El CVaR (Conditional Value at Risk), también llamado **Expected Shortfall (ES)**, responde la pregunta que el VaR deja sin contestar:

```
VaR:  ¿cuál es el umbral de pérdida que se supera en el α% de los días?
CVaR: dado que ya estamos en ese peor α%, ¿cuánto perdemos en promedio?
```

### Por qué importa en México

- Basilea III (implementado en México vía CNBV desde 2019) exige el Expected Shortfall como medida regulatoria de riesgo de mercado, sustituyendo al VaR de Basilea II
- Las SOFOMES y fondos de deuda con alta exposición a crédito corporativo usan CVaR porque los defaults son eventos de cola severa, no suave
- Durante el crash de marzo 2020 el CVaR del IPC fue aproximadamente 2.3 veces mayor que su VaR — la diferencia que el VaR "no veía"

---

## CONEXIÓN CON SESIONES ANTERIORES

**Sesión 3 (Estadística descriptiva):**
- La curtosis elevada de los rendimientos mexicanos (> 3) justificó desde entonces usar medidas más robustas que la normal
- El CVaR captura exactamente lo que la curtosis describe: la masa extra en las colas

**Sesión 7 (VaR):**
- El CVaR se construye directamente sobre el VaR: necesitas el umbral VaR para definir la cola que promedias
- Los tres métodos de cálculo (histórico, paramétrico, Monte Carlo) se replican aquí con una extensión

**Mensaje clave:**
"El VaR nos dice dónde empieza el problema. El CVaR nos dice qué tan grave es."

---

## ESTRUCTURA DE LA SESIÓN

### BLOQUE 1: Las limitaciones del VaR y las medidas coherentes

**1.1 Una propiedad que el VaR viola**

Antes de introducir el CVaR formalmente, conviene entender por qué necesitamos algo mejor. En 1999, Philippe Artzner y colaboradores publicaron un artículo que definió formalmente qué propiedades debe cumplir una medida de riesgo para ser considerada **coherente**. Las cuatro propiedades son:

```
1. MONOTONICIDAD
   Si un portafolio siempre pierde más que otro, su riesgo es mayor.
   Si X ≤ Y en todos los escenarios → ρ(X) ≥ ρ(Y)

2. HOMOGENEIDAD POSITIVA
   Escalar el portafolio escala el riesgo proporcionalmente.
   ρ(λX) = λ·ρ(X)  para λ > 0

3. INVARIANZA A TRASLACIONES
   Agregar efectivo libre de riesgo reduce el riesgo en esa cantidad.
   ρ(X + c) = ρ(X) − c

4. SUBADITIVIDAD  ← la más importante
   Fusionar portafolios no puede aumentar el riesgo total.
   ρ(X + Y) ≤ ρ(X) + ρ(Y)
```

La subaditividad formaliza matemáticamente el principio de diversificación: combinar portafolios no debe ser más riesgoso que la suma de sus partes. El VaR **viola esta propiedad** cuando las distribuciones tienen colas pesadas o no son normales.

**Ejemplo de violación:**

```
Dos bonos, cada uno con probabilidad 4% de default:

  VaR(95%) del Bono A solo: $0  (4% < 5%, no supera el umbral)
  VaR(95%) del Bono B solo: $0  (igual)

  Portafolio 50/50 A+B:
  P(al menos un default) ≈ 7.8% > 5%
  VaR(95%) del portafolio: > $0

  ρ(A+B) > ρ(A) + ρ(B)  → violación de subaditividad
```

Un regulador que use VaR puede incentivar que los bancos tengan los bonos por separado en lugar de diversificarlos, lo que es absurdo. El CVaR no tiene este problema: siempre satisface las cuatro propiedades.

**1.2 Definición formal del CVaR**

El CVaR al nivel de confianza $(1- \alpha)$ es la pérdida esperada condicional a estar en el peor α% de los escenarios:

```
CVaR(α) = E[r | r ≤ VaR(α)]

Donde:
  α   = nivel de significancia (ej. 0.05 para CVaR al 95%)
  r   = rendimiento del portafolio
  VaR = umbral ya calculado en Sesión 7
```

En palabras: es el promedio de todos los rendimientos que caen por debajo del VaR.

**Relación con el VaR:**

```
CVaR es SIEMPRE más negativo que el VaR del mismo nivel:
  CVaR(95%) ≤ VaR(95%)

La diferencia (CVaR − VaR) mide la severidad de la cola:
  pequeña diferencia → cola suave (distribución aproximadamente normal)
  gran diferencia    → cola pesada (riesgo de eventos extremos)
```

---

### BLOQUE 2: CVaR Histórico

**2.1 Cálculo paso a paso**

El CVaR histórico es el más intuitivo: simplemente promedias los rendimientos que quedaron por debajo del VaR histórico.

```
Procedimiento:
  1. Calcular VaR histórico al nivel α  →  umbral = quantile(r, probs = α)
  2. Filtrar todos los rendimientos ≤ umbral  →  cola = r[r ≤ umbral]
  3. CVaR = mean(cola)
```

**Ejemplo numérico con 20 rendimientos:**

```
Rendimientos ordenados (los 20 peores días del año en %):
-8.1, -6.3, -5.7, -4.9, -4.2, -3.8, -3.1, -2.9, -2.7, -2.4,
-2.1, -1.9, -1.7, -1.5, -1.3, -1.1, -0.9, -0.7, -0.5, -0.2

Con 200 observaciones totales y α = 5%:
  N cola = 200 × 0.05 = 10 observaciones
  VaR(95%)  = −2.4%  (décima observación)
  CVaR(95%) = promedio de las 10 peores
            = (−8.1 − 6.3 − 5.7 − 4.9 − 4.2 − 3.8 − 3.1 − 2.9 − 2.7 − 2.4) / 10
            = −44.1 / 10
            = −4.41%

Interpretación:
  VaR:  en el 5% peor de los días, la pérdida MÍNIMA es 2.4%
  CVaR: en el 5% peor de los días, la pérdida PROMEDIO es 4.41%
  El CVaR es 1.84 veces mayor → cola de riesgo importante
```

**Preguntas de comprensión:**

**Pregunta 1:** "¿Qué pasaría con el CVaR si eliminamos el día de mayor pérdida (−8.1%)?"  
→ Subiría (sería menos negativo) porque el promedio de la cola cambia al quitar el valor extremo. El VaR no cambiaría porque el umbral sigue siendo el décimo percentil.

**Pregunta 2:** "¿Por qué el CVaR es más informativo que el VaR en distribuciones de cola pesada?"  
→ Porque en colas pesadas hay observaciones muy alejadas del umbral. El promedio captura esa severidad; el umbral solo marca dónde empieza la zona de peligro.

**2.2 CVaR rodante**

De la misma forma que calculamos el VaR rodante en la Sesión 7, podemos calcular el CVaR rodante para ver cómo evoluciona la severidad de la cola a lo largo del tiempo. Este análisis es especialmente revelador en períodos de crisis: el CVaR se dispara mucho más que el VaR, mostrando que no solo hay más días malos sino que esos días son dramáticamente peores.

Ejecutar la Parte correspondiente del script y observar el cociente CVaR/VaR a lo largo del tiempo. Cuando ese cociente se aleja mucho de 1.0, el mercado está en un régimen de cola pesada — exactamente la situación en que el VaR como única medida es más peligroso.

---

### BLOQUE 3: CVaR Paramétrico

**3.1 Derivación bajo distribución normal**

Cuando los rendimientos siguen una distribución normal, el CVaR tiene una fórmula analítica cerrada. La derivación es un ejercicio de integración de la función de densidad normal en la cola izquierda.

```
Bajo r ~ N(μ, σ²):

CVaR(α) = μ − σ × φ(z_α) / α

Donde:
  z_α  = qnorm(α)          cuantil normal estándar
  φ(·) = dnorm(·)          densidad de la normal estándar en z_α
  α    = nivel de significancia (0.05 para CVaR al 95%)
```

**Ejemplo numérico:**

```
Datos del portafolio MV:
  μ = 0.0004
  σ = 0.0150
  α = 0.05  →  z_α = qnorm(0.05) = −1.6449
              φ(z_α) = dnorm(−1.6449) = 0.1031

CVaR(95%) = 0.0004 − 0.0150 × 0.1031 / 0.05
          = 0.0004 − 0.03093
          = −0.03053
          = −3.05%

Comparar con VaR paramétrico(95%) = −2.43%
  CVaR / VaR = 3.05 / 2.43 = 1.26×

Bajo normalidad, el CVaR es aproximadamente 1.25× el VaR al 95%.
Este cociente es fijo para la distribución normal — si es mucho mayor
en los datos reales, la distribución tiene colas más pesadas que la normal.
```

**La lógica detrás de la fórmula:**

La fracción `φ(z_α) / α` es la razón inversa de Mills. Representa qué tan lejos en promedio están las observaciones de la cola respecto al umbral. Cuanto más pesada es la cola (mayor curtosis), mayor es este factor y mayor la diferencia entre CVaR y VaR.

**3.2 CVaR bajo distribución t-Student**

Cuando usamos la distribución t para capturar colas pesadas, la fórmula del CVaR cambia:

```
Bajo r ~ t(df) escalada:

CVaR(α) = μ − σ × [f_t(t_α, df) × (df + t_α²) / ((df-1) × α)]

Donde:
  t_α    = qt(α, df)        cuantil de la t-Student con df grados
  f_t(·) = dt(·, df)        densidad de la t-Student en t_α
  df     = grados de libertad (estimados en Sesión 7)
```

No es necesario memorizar esta fórmula. La implementación en R es directa y el script la calcula automáticamente. Lo importante es la intuición: con df bajos (colas más pesadas), el CVaR se aleja más del VaR que bajo normalidad, reflejando la mayor severidad de los eventos extremos.

---

### BLOQUE 4: CVaR por Simulación Monte Carlo

**4.1 Procedimiento**

Calcular el CVaR mediante simulación es conceptualmente idéntico al caso histórico, pero sobre escenarios simulados en lugar de datos observados:

```
Procedimiento:
  1. Simular N rendimientos del portafolio (igual que en Sesión 7)
  2. Calcular VaR como el cuantil α de esa distribución simulada
  3. CVaR = promedio de todos los rendimientos simulados ≤ VaR

  En R:
    umbral <- quantile(r_simulado, probs = alpha)
    cvar   <- mean(r_simulado[r_simulado <= umbral])
```

Con simulaciones suficientemente grandes (≥ 50,000 escenarios), el CVaR simulado converge al teórico con buena precisión. La ventaja sobre el método paramétrico es que no impone ningún supuesto distribucional.

**4.2 Convergencia y precisión**

Una pregunta práctica importante es cuántas simulaciones necesitamos para que el CVaR sea estable. A diferencia del VaR, el CVaR promedia observaciones de la cola extrema, que son las más escasas. Esto lo hace más sensible al número de simulaciones:

```
Simulaciones  VaR(95%) estable    CVaR(95%) estable
    1,000      Sí (~2 decimales)   No (alta varianza)
   10,000      Sí                  Aproximado
  100,000      Sí                  Sí (~2 decimales)
1,000,000      Sí                  Sí (~3 decimales)
```

En la práctica institucional, los sistemas de riesgo usan entre 100,000 y 1,000,000 simulaciones para reportar el CVaR con confianza suficiente.

---

### BLOQUE 5: Comparación completa y análisis de crisis

**5.1 Tabla comparativa VaR vs. CVaR**

Al ejecutar el script obtendrás una tabla similar a esta (los valores exactos dependen del período y los datos descargados):

| Método | VaR 95% | CVaR 95% | Ratio CVaR/VaR | VaR 99% | CVaR 99% |
|---|---|---|---|---|---|
| Histórico | −2.40% | −3.85% | 1.60× | −3.90% | −5.70% |
| Paramétrico (Normal) | −2.43% | −3.05% | 1.26× | −3.44% | −3.95% |
| Monte Carlo t-Student | −2.61% | −3.90% | 1.49× | −4.10% | −5.80% |

**Cómo leer esta tabla:**

El ratio CVaR/VaR es el indicador más importante. Bajo normalidad perfecta ese ratio es siempre ~1.26 para el nivel 95%. Cuando los datos reales muestran un ratio de 1.5× o mayor, la distribución tiene colas pesadas significativas y el VaR paramétrico está subestimando el riesgo real.

**5.2 Análisis durante la crisis de 2020**

Comparar el cociente CVaR/VaR en dos períodos revela algo importante sobre la naturaleza del riesgo de cola:

```
Período        VaR(95%)  CVaR(95%)  Ratio
2019 normal    −1.6%     −2.3%      1.44×
2020 crisis    −4.8%     −9.2%      1.92×
```

Durante la crisis no solo el VaR creció (de −1.6% a −4.8%), sino que el ratio también aumentó (de 1.44× a 1.92×). Esto significa que las colas se volvieron relativamente más pesadas: los días malos no solo fueron más frecuentes sino que cuando llegaron, fueron mucho peores de lo que el umbral sugería. Esta es exactamente la situación en la que confiar solo en el VaR es más peligroso.

**5.3 Pregunta de síntesis**

"Un gestor de riesgos le presenta a su director dos portafolios con el mismo VaR(99%) pero CVaR distintos: el Portafolio A tiene CVaR/VaR = 1.3× y el B tiene CVaR/VaR = 2.1×. Con el mismo presupuesto de riesgo, ¿cuál prefieren y por qué?"

→ El Portafolio A. Mismo umbral de pérdida probable, pero cuando las cosas se ponen mal, el Portafolio A pierde 30% más que el VaR mientras que el B pierde 110% más. La diferencia en los escenarios de crisis es enorme aunque en condiciones normales parezcan equivalentes.

---

### BLOQUE 6: CVaR en la regulación — Basilea III

**6.1 La transición de VaR a Expected Shortfall**

Durante la crisis financiera de 2008, quedó claro que los bancos globales habían subestimado sistemáticamente el riesgo porque sus modelos de capital se basaban en el VaR. El Comité de Basilea respondió con una reforma fundamental publicada en 2016 (implementación progresiva hasta 2019):

```
BASILEA II (hasta 2019)          BASILEA III / FRTB
Medida: VaR                  →   Expected Shortfall (CVaR)
Nivel:  99%, 10 días         →   97.5%, horizonte variable
Modelo: un solo período      →   stressed ES (período de crisis)
```

El cambio a 97.5% puede parecer menos conservador que 99%, pero el Expected Shortfall al 97.5% captura más riesgo de cola que el VaR al 99%, porque promedia las pérdidas en lugar de solo identificar el umbral.

**6.2 Implicación para capital regulatorio**

El capital de reserva exigido por Basilea III a los bancos mexicanos con actividad de mercado es proporcional al ES estresado (calculado sobre un período de 12 meses de alta volatilidad histórica). En México, la CNBV implementó estas disposiciones mediante modificaciones a las Reglas de Capitalización publicadas en el DOF.

---

## EJEMPLOS Y ANALOGÍAS

### Analogía para explicar CVaR vs VaR

"Imaginen un seguro de automóvil. El VaR sería el deducible: el monto a partir del cual el seguro empieza a pagar. El CVaR sería el costo promedio de los accidentes que superan ese deducible.

Dos aseguradoras pueden tener el mismo deducible (mismo VaR) pero carteras muy distintas: una cubre conductores que sufren golpes menores, otra cubre conductores que sufren accidentes graves. El CVaR diferencia exactamente eso."

### La diferencia en una crisis

Durante el crash de Lehman Brothers (septiembre 2008), los modelos VaR de varios bancos grandes reportaban pérdidas de 1 día en el rango de 50–100 millones de dólares. Las pérdidas reales durante las semanas siguientes estuvieron en el rango de miles de millones. La cola no era solo más frecuente — era cualitativamente diferente. El CVaR calculado con datos históricos que incluyeran períodos de estrés previos habría dado señales mucho más cercanas a la realidad.

---

## EJERCICIOS Y TAREA

**Obligatorios:** 1–4  
**Avanzados:** 5–7

**Énfasis:**
- Ejercicio 2 (cálculo manual del CVaR histórico) es fundamental — deben hacerlo sin funciones
- Ejercicio 4 (comparación VaR vs CVaR en crisis) conecta directamente con la limitación del VaR
- Ejercicio 7 (subaditividad) es el más conceptual y el que más conecta con teoría de medidas coherentes

---

## SOLUCIONES A EJERCICIOS SELECCIONADOS

### Ejercicio 2: CVaR histórico manual

```r
# Dados 500 rendimientos diarios del portafolio MV
# Calcular CVaR al 95% sin usar funciones de paquetes

r <- as.numeric(rendimientos %*% pesos_mv)

alpha    <- 0.05
n        <- length(r)
umbral   <- quantile(r, probs = alpha)

# Filtrar la cola
cola     <- r[r <= umbral]
n_cola   <- length(cola)  # debe ser ≈ n × alpha = 25 observaciones

cvar_95  <- mean(cola)

cat("N observaciones en cola:", n_cola, "\n")
cat("VaR(95%):", round(umbral * 100, 4), "%\n")
cat("CVaR(95%):", round(cvar_95 * 100, 4), "%\n")
cat("Ratio CVaR/VaR:", round(cvar_95 / umbral, 3), "\n")
```

### Ejercicio 4: Comparación VaR vs CVaR durante crisis

```r
# Separar datos en dos períodos
fechas   <- index(rendimientos)
r_port   <- as.numeric(rendimientos %*% pesos_mv)

pre_crisis  <- r_port[fechas >= "2019-01-01" & fechas <= "2019-12-31"]
dur_crisis  <- r_port[fechas >= "2020-02-01" & fechas <= "2020-06-30"]

calcular_var_cvar <- function(r, alpha = 0.05) {
  var_  <- quantile(r, probs = alpha)
  cvar_ <- mean(r[r <= var_])
  ratio <- cvar_ / var_
  return(c(VaR = var_, CVaR = cvar_, Ratio = ratio))
}

res_pre  <- calcular_var_cvar(pre_crisis)
res_cris <- calcular_var_cvar(dur_crisis)

cat("PRE-CRISIS (2019):\n")
cat("  VaR(95%): ", round(res_pre["VaR"]*100, 3), "%\n")
cat("  CVaR(95%):", round(res_pre["CVaR"]*100, 3), "%\n")
cat("  Ratio:    ", round(res_pre["Ratio"], 3), "\n\n")

cat("DURANTE CRISIS (Feb-Jun 2020):\n")
cat("  VaR(95%): ", round(res_cris["VaR"]*100, 3), "%\n")
cat("  CVaR(95%):", round(res_cris["CVaR"]*100, 3), "%\n")
cat("  Ratio:    ", round(res_cris["Ratio"], 3), "\n\n")

cat("El ratio CVaR/VaR aumenta en crisis: las colas se vuelven más pesadas.\n")
cat("Un modelo basado solo en VaR no captura este empeoramiento.\n")
```

### Ejercicio 7: Demostración de violación de subaditividad del VaR

```r
# Dos activos con distribución asimétrica (ejemplo de bonos con riesgo de default)
set.seed(2024)
n_sim <- 200000

# Activo A: rendimiento normal excepto en 4% de escenarios (default)
r_A <- rnorm(n_sim, mean = 0.0003, sd = 0.008)
default_A <- rbinom(n_sim, 1, prob = 0.04)
r_A[default_A == 1] <- -0.30  # pérdida de 30% en default

# Activo B: misma estructura
r_B <- rnorm(n_sim, mean = 0.0003, sd = 0.008)
default_B <- rbinom(n_sim, 1, prob = 0.04)
r_B[default_B == 1] <- -0.30

# Portafolio 50/50 (asumiendo correlación de defaults = 0.3)
# Simular correlación entre defaults
u         <- runif(n_sim)
default_B2 <- ifelse(default_A == 1,
                     rbinom(n_sim, 1, prob = 0.3 + 0.04 * 0.7),
                     rbinom(n_sim, 1, prob = 0.04))
r_B2 <- rnorm(n_sim, mean = 0.0003, sd = 0.008)
r_B2[default_B2 == 1] <- -0.30

r_port <- 0.5 * r_A + 0.5 * r_B2

# Calcular VaR al 95%
var_A    <- quantile(r_A,    probs = 0.05)
var_B    <- quantile(r_B2,   probs = 0.05)
var_port <- quantile(r_port, probs = 0.05)

cat("VaR(95%) activo A:          ", round(var_A*100, 4), "%\n")
cat("VaR(95%) activo B:          ", round(var_B*100, 4), "%\n")
cat("Suma ponderada:             ", round((0.5*var_A + 0.5*var_B)*100, 4), "%\n")
cat("VaR(95%) portafolio 50/50: ", round(var_port*100, 4), "%\n")
cat("¿Violación de subaditividad?",
    ifelse(var_port < 0.5*var_A + 0.5*var_B, "SÍ", "NO"), "\n\n")

# Calcular CVaR al 95%
cvar_A    <- mean(r_A[r_A <= var_A])
cvar_B    <- mean(r_B2[r_B2 <= var_B])
cvar_port <- mean(r_port[r_port <= var_port])

cat("CVaR(95%) activo A:          ", round(cvar_A*100, 4), "%\n")
cat("CVaR(95%) activo B:          ", round(cvar_B*100, 4), "%\n")
cat("Suma ponderada:              ", round((0.5*cvar_A + 0.5*cvar_B)*100, 4), "%\n")
cat("CVaR(95%) portafolio 50/50: ", round(cvar_port*100, 4), "%\n")
cat("¿CVaR satisface subaditividad?",
    ifelse(cvar_port >= 0.5*cvar_A + 0.5*cvar_B, "SÍ", "NO"), "\n")
```

**Interpretación esperada:** el VaR del portafolio resulta mayor que la suma ponderada de los VaR individuales (violación de subaditividad), mientras que el CVaR la satisface. Este resultado demuestra de manera empírica el teorema de Artzner et al.

---

## PROBLEMAS COMUNES Y SOLUCIONES

### Problema 1: CVaR resulta igual al VaR
**Causa:** La condición de filtrado es `<` en lugar de `<=`, dejando una cola vacía o de un solo elemento  
**Solución:** Usar `r[r <= umbral]` — el umbral mismo debe incluirse en la cola

### Problema 2: CVaR positivo o cercano a cero
**Causa:** El período analizado tiene muy pocos días negativos (mercado alcista prolongado)  
**Explicación:** El CVaR es un estadístico de la cola izquierda; en períodos de baja volatilidad puede acercarse a cero. Ampliar el período de análisis o bajar el nivel de confianza

### Problema 3: Ratio CVaR/VaR muy alto (> 3×)
**Causa:** El período incluye un evento extremo muy aislado (crash puntual)  
**Acción:** Verificar si hay datos corruptos o errores de ajuste. Si los datos son correctos, documentar el evento específico que domina la cola

### Problema 4: `mean(cola)` da NA
**Causa:** El vector filtrado está vacío porque el umbral es muy extremo  
**Solución:** Verificar que `length(cola) > 0` antes de calcular. Con muestras pequeñas, niveles de confianza muy altos (99.9%) pueden generar colas vacías

### Problema 5: Diferencia grande entre CVaR histórico y paramétrico
**Causa:** Los rendimientos tienen curtosis elevada (colas pesadas), lo que es esperado  
**Explicación:** No es un error — es exactamente lo que queremos detectar. El CVaR histórico captura las colas reales; el paramétrico asume normalidad y las suaviza

---

## PUNTOS PEDAGÓGICOS CRÍTICOS

### 1. CVaR no reemplaza al VaR: los complementa
El VaR sigue siendo útil como umbral de referencia y es más fácil de comunicar. La práctica profesional usa ambos: el VaR como límite operativo y el CVaR como medida de severidad. Presentarlos como competidores genera confusión; presentarlos como complementarios es más preciso.

### 2. Subaditividad no es un tecnicismo matemático
Es la formalización de algo que los alumnos ya saben intuitivamente: diversificar no puede ser peor que no diversificar. Cuando el VaR viola subaditividad, el sistema de gestión de riesgos puede penalizar la diversificación — un resultado absurdo que tuvo consecuencias reales en 2008.

### 3. El ratio CVaR/VaR es más informativo que los valores absolutos
Enfatizar que comparar portafolios por su ratio CVaR/VaR revela la "forma" de su distribución de riesgo. Un ratio cercano a 1.26 sugiere distribución aproximadamente normal; ratios de 1.5× o más sugieren colas pesadas que merecen atención especial.

### 4. Conectar siempre con la magnitud en pesos
Un CVaR de −4.5% es abstracto. Un CVaR de −$45,000 MXN sobre una inversión de $1,000,000 en los días de crisis es tangible. La conversión a unidades monetarias debe ser automática en cualquier análisis presentado a un cliente o directivo.

---

## EVALUACIÓN DE LA SESIÓN

### Pregunta de salida:
"Un portafolio tiene VaR(95%) = −2.8% y CVaR(95%) = −5.6%. ¿Qué nos dice el ratio de 2× sobre la distribución de los rendimientos? ¿En qué situación sería preferible usar el CVaR al VaR para tomar una decisión de inversión?"

---

## PREPARACIÓN PARA SESIÓN 9

**Tema:** Modelos de volatilidad GARCH

**Conexión:**  
"VaR y CVaR asumen que la volatilidad del portafolio (σ) es constante en el tiempo. Pero hemos visto que durante la crisis de 2020 la volatilidad se disparó. ¿Cómo modelamos una σ que cambia cada día?"

**Anticipar:**  
Los modelos GARCH (Generalized Autoregressive Conditional Heteroskedasticity) permiten estimar una σ_t que varía en el tiempo. Al combinarse con el VaR paramétrico, producen el **VaR condicional**: una medida de riesgo que se actualiza diariamente conforme cambia la volatilidad del mercado.

**Materiales:**  
- Los mismos rendimientos del portafolio de esta sesión
- La librería `rugarch` ya está en la lista del curso
- Revisar brevemente el concepto de autocorrelación en los cuadrados de los rendimientos (el hecho estilizado que motiva GARCH)
