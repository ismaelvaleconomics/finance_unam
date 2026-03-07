# SESIÓN 2
## Álgebra Lineal Aplicada a Finanzas

**Curso:** Mercado de Capitales  
**Profesor:** Ismael Valverde

---

## OBJETIVOS DE APRENDIZAJE

Al finalizar esta sesión, los estudiantes serán capaces de:

1. Crear y manipular vectores y matrices en R para representar datos financieros
2. Calcular retornos de portafolio usando producto punto ($w^{T} * r$)
3. Construir e interpretar matrices de covarianza y correlación
4. Calcular la varianza de un portafolio usando álgebra matricial ($w^{T} * Σ * w$)
5. Aplicar estas técnicas a datos reales de la BMV
6. Entender el concepto de diversificación mediante covarianzas
7. Interpretar el trade-off entre retorno esperado y riesgo

---

## PREPARACIÓN PREVIA A LA SESIÓN

### Materiales que los estudiantes deben haber leído:

1. **Documento de álgebra lineal** (proporcionado antes de clase)
2. **Lecturas asignadas:**
   - Haeussler et al. - Capítulo 6: Álgebra Matricial
   - Cornuejols & Tütüncü - Capítulo 2: Mean-Variance Analysis

### Verificar antes de clase:

- [ ] Todos los estudiantes tienen R y RStudio instalados
- [ ] Las librerías necesarias están disponibles (quantmod, PerformanceAnalytics, corrplot)
- [ ] Conexión a internet funcional (para descargar datos)
- [ ] Proyector conectado y funcionando
- [ ] Tener datos pre-descargados como backup

---

## ESTRUCTURA DE LA SESIÓN

### BLOQUE 1: Revisión y contextualización

**1.1 Revisión de ejercicios Sesión 1**

**Errores comunes a mencionar:**
```r
# Error 1: No usar .MX en el ticker
getSymbols("CEMEX")  # ✗ Incorrecto
getSymbols("CEMEXCPO.MX")  # ✓ Correcto

# Error 2: No manejar NAs
retornos <- dailyReturn(AMX)  # Puede tener NAs
retornos <- na.omit(dailyReturn(AMXL))  # ✓ Correcto

# Error 3: Confundir precios con retornos
mean(Cl(AMX))  # Precio promedio (no muy útil)
mean(dailyReturn(AMX))  # Retorno promedio (lo que queremos)
```

**1.2 Conexión con álgebra lineal**

- **Leer el documento de álgebra lineal"
  - Pregunta: ¿Cómo calculamos el retorno del portafolio?

**Transición:**
Implementar en R todo lo que leído sobre álgebra lineal aplicada a finanzas. Pasar las fórmulas matemáticas directamente a código.

---

### BLOQUE 2: Vectores en R

**2.1 Demostración guiada**

**Proyectar y ejecutar en vivo el código de la Parte 2 del script.**

**Conceptos clave a enfatizar:**

1. **Vectores como series de datos:**
```r
retornos <- c(0.015, -0.008, 0.023)
# ¿Qué representa cada número?
# - Primera acción subió 1.5%
# - Segunda bajó 0.8%
# - Tercera subió 2.3%
```

2. **Operaciones elemento por elemento:**
```r
pesos <- c(0.4, 0.3, 0.3)
capital <- 100000
inversion <- pesos * capital
# Muestra cómo se distribuye el dinero
```

3. **Producto punto = Promedio ponderado:**
```r
retorno_portafolio <- sum(pesos * retornos)
# Equivalente a:
# 0.4 * 0.015 + 0.3 * (-0.008) + 0.3 * 0.023
```

**Punto pedagógico importante:**
"El producto punto no es solo una operación matemática abstracta. En finanzas, representa un PROMEDIO PONDERADO. Están calculando cuánto ganó o perdió su portafolio considerando cuánto invirtieron en cada acción."

**2.2 Ejercicio en clase**

Mini-ejercicio:

**Problema:**
```r
# Tienes estos datos:
retornos_ayer <- c(0.02, -0.01, 0.03, 0.01)
pesos_portfolio <- c(0.25, 0.25, 0.25, 0.25)

# Calcula:
# 1. Retorno del portafolio
# 2. ¿Cuál acción tuvo el mejor desempeño?
# 3. ¿Cuál tuvo el peor?
```

**Solución:**
```r
# 1. Retorno del portafolio
ret_port <- sum(pesos_portfolio * retornos_ayer)
# ret_port = 0.0125 = 1.25%

# 2. Mejor desempeño
max(retornos_ayer)  # 0.03 (tercera acción)

# 3. Peor desempeño
min(retornos_ayer)  # -0.01 (segunda acción)
```

**2.3 Preguntas y discusión**

Preguntas para generar discusión:
- "¿Qué pasa si los pesos no suman 1?"
- "¿Puede un peso ser negativo? (introducir concepto de venta en corto)"
- "Si todos los retornos son positivos, ¿el portafolio siempre gana?"

---

### BLOQUE 3: Matrices en R

**3.1 Construcción de matrices**

**Demostración en vivo:**

```r
# Mostrar cómo crear una matriz paso a paso
# Datos: 3 activos, 5 días

# Opción 1: Ingresar por columnas (más natural para finanzas)
retornos_matriz <- matrix(
  c(0.015, -0.008, 0.023, 0.012, -0.005,  # Activo 1
    0.010, 0.005, -0.010, 0.018, 0.002,   # Activo 2
    0.020, -0.003, 0.015, 0.008, 0.012),  # Activo 3
  nrow = 5,
  ncol = 3,
  byrow = FALSE
)
```

**Visualización pedagógica:**

```
         AMXL   WALMEX  GFNORTEO
Día 1   0.015   0.010   0.020
Día 2  -0.008   0.005  -0.003
Día 3   0.023  -0.010   0.015
Día 4   0.012   0.018   0.008
Día 5  -0.005   0.002   0.012
```

**Interpretación:**
- **Filas:** Días de negociación (observaciones en el tiempo)
- **Columnas:** Diferentes activos
- **Cada celda:** Retorno de un activo en un día específico

**3.2 Operaciones con matrices**

**Demostración guiada:**

1. **Acceso a elementos:**
```r
# Retorno de AMXL en Día 3
retornos_matriz[3, 1]

# Todos los retornos de WALMEX
retornos_matriz[, 2]

# Retornos de todos los activos en Día 1
retornos_matriz[1, ]
```

2. **Estadísticas por columna:**
```r
# Retorno promedio de cada activo
colMeans(retornos_matriz)

# Interpretación: "AMXL ganó en promedio X% por día"
```

3. **Multiplicación matriz-vector (clave para portafolios):**
```r
w <- c(0.4, 0.3, 0.3)
retornos_portafolio <- retornos_matriz %*% w

# Resultado: vector de 5 elementos
# Cada uno es el retorno del portafolio en cada día
```

**Punto crítico a enfatizar:**
"Cuando multiplicamos la matriz de retornos por el vector de pesos, obtenemos los retornos históricos del portafolio. Es como si hubiéramos invertido así desde el principio y estamos viendo cómo nos habría ido cada día."

**3.3 Ejercicio**

**Problema:**
```r
# Crear matriz 4x3 con estos retornos:
# Día 1: 0.01, 0.02, -0.01
# Día 2: 0.03, 0.01, 0.02
# Día 3: -0.02, 0.01, 0.03
# Día 4: 0.02, -0.01, 0.01

# Tareas:
# 1. Crear la matriz
# 2. Calcular retorno promedio de cada activo
# 3. Calcular retornos de portafolio w = (0.5, 0.3, 0.2)
# 4. ¿En qué día el portafolio tuvo mejor desempeño?
```

### BLOQUE 4: Covarianza y Correlación

**4.1 Matriz de covarianza**

**Introducción conceptual:**

"La covarianza mide si dos activos se mueven juntos. Si la covarianza es:
- **Positiva:** Tienden a subir y bajar juntos
- **Negativa:** Cuando uno sube, el otro tiende a bajar
- **Cercana a cero:** Se mueven independientemente"

**Demostración en R:**

```r
# Calcular matriz de covarianza
matriz_cov <- cov(retornos_matriz)
print(matriz_cov)
```

**Interpretación guiada:**

Proyectar la matriz y explicar cada elemento:

```
              AMXL      WALMEX    GFNORTEO
AMXL      0.000XYZ   0.000ABC   0.000DEF
WALMEX    0.000ABC   0.000GHI   0.000JKL
GFNORTEO  0.000DEF   0.000JKL   0.000MNO
```

- **Diagonal:** Varianzas (riesgo individual)
- **Fuera diagonal:** Covarianzas (co-movimiento)
- **Simetría:** Cov(A,B) = Cov(B,A)

**Pregunta:**
"Si quieren REDUCIR el riesgo del portafolio, ¿prefieren activos con covarianza positiva o negativa?" 
(Respuesta: negativa, porque se compensan)

**4.2 Matriz de correlación**

**Explicar diferencia cov vs cor:**

"La correlación es la covarianza estandarizada. Siempre está entre -1 y 1, lo que la hace más fácil de interpretar."

```r
# Calcular correlación
matriz_cor <- cor(retornos_matriz)
print(matriz_cor)

# Visualizar
corrplot(matriz_cor, 
         method = "color",
         type = "upper",
         addCoef.col = "black")
```

**Interpretación de valores:**
- **ρ ≈ 1:** Correlación perfecta positiva (se mueven igual)
- **ρ ≈ 0:** No correlacionados (independientes)
- **ρ ≈ -1:** Correlación perfecta negativa (espejo)

**Ejemplo del mundo real:**
"Dos empresas del mismo sector (ej: Walmart y Soriana) probablemente tienen correlación positiva alta. Una empresa de tecnología y una de cemento probablemente tienen correlación más baja."

**4.3 Mini-ejercicio**

**Problema:**
"Usando los datos que ya tienen cargados, respondan:
1. ¿Qué par de activos tiene la correlación más alta?
2. ¿Cuál tiene la más baja?
3. ¿Qué implica esto para la diversificación?"

---

### BLOQUE 5: Varianza de portafolio - La fórmula estrella

**5.1 Introducción a la fórmula **

$$\sigma_p^2 = \mathbf{w}^T \Sigma \mathbf{w}$$

"Esta es LA fórmula más importante de la teoría moderna de portafolios. Nos dice cuánto riesgo tiene nuestro portafolio considerando:
1. El riesgo de cada activo individual (varianzas)
2. Cómo se mueven juntos (covarianzas)
3. Cuánto invertimos en cada uno (pesos)"

**5.2 Cálculo paso a paso**

**Demostración en R:**

```r
# Datos
w <- c(0.4, 0.3, 0.3)
matriz_cov <- cov(retornos_matriz)

# Paso 1: Σ * w
print("Paso 1: Multiplicar matriz de covarianza por vector de pesos")
Sigma_w <- matriz_cov %*% w
print(Sigma_w)

# Paso 2: w^T * (Σ * w)
print("Paso 2: Multiplicar transpuesto de pesos por resultado anterior")
varianza <- as.numeric(t(w) %*% Sigma_w)
print(paste("Varianza del portafolio:", varianza))

# Paso 3: Raíz cuadrada para obtener volatilidad
volatilidad <- sqrt(varianza)
print(paste("Volatilidad del portafolio:", 
            round(volatilidad * 100, 2), "%"))
```

**Comparación crucial:**

```r
# Volatilidades individuales
vol_individual <- sqrt(diag(matriz_cov))
print("Volatilidades individuales:")
print(vol_individual * 100)

print("Volatilidad del portafolio:")
print(volatilidad * 100)
```

**Clave:**
"¿Nota: La volatilidad del portafolio es MENOR que el promedio de las volatilidades individuales. Esto es la DIVERSIFICACIÓN en acción."

**5.3 Experimento interactivo**

Probar diferentes pesos:

```r
# Portafolio A: Todo en un activo
w_A <- c(1, 0, 0)
var_A <- t(w_A) %*% matriz_cov %*% w_A
vol_A <- sqrt(var_A)

# Portafolio B: Igualmente distribuido
w_B <- c(0.33, 0.33, 0.34)
var_B <- t(w_B) %*% matriz_cov %*% w_B
vol_B <- sqrt(var_B)

# Comparar
print(paste("Volatilidad portafolio A:", vol_A * 100, "%"))
print(paste("Volatilidad portafolio B:", vol_B * 100, "%"))
```

**Pregunta para reflexión:**
"¿Cuál tiene menor riesgo? ¿Por qué?"

---

### BLOQUE 6: Aplicación con datos reales de la BMV

**6.1 Descarga y preparación de datos**

**Ejecutar en vivo:**

```r
# Descargar datos reales
tickers <- c("AMX", "WALMEX.MX", "GFNORTEO.MX")
getSymbols(tickers, from = "2024-01-01", to = Sys.Date())

# Combinar precios
precios <- merge(Cl(AMXL), Cl(WALMEX.MX), Cl(GFNORTEO.MX))
colnames(precios) <- c("AMX", "WALMEX", "GFNORTEO")

# Calcular retornos
retornos <- Return.calculate(precios, method = "discrete")
retornos <- na.omit(retornos)
```

**6.2 Análisis exploratorio**

```r
# Estadísticas descriptivas
summary(retornos)

# Matriz de correlación
cor_real <- cor(retornos)
corrplot(cor_real, method = "color", addCoef.col = "black")
```

**Preguntas de interpretación:**
- "¿La correlación que vemos tiene sentido económico?"
- "¿Por qué WALMEX y GFNORTEO tienen esta correlación?"
- "¿Cómo usarían esta información para construir un portafolio?"

**6.3 Análisis de portafolio completo**

```r
# Definir portafolio
w <- c(0.4, 0.3, 0.3)

# Retorno esperado
mu <- colMeans(retornos)
ret_esperado <- t(w) %*% mu
print(paste("Retorno esperado anual:", 
            round(ret_esperado * 252 * 100, 2), "%"))

# Varianza y volatilidad
Sigma <- cov(retornos)
var_port <- t(w) %*% Sigma %*% w
vol_port <- sqrt(var_port)
print(paste("Volatilidad anual:", 
            round(vol_port * sqrt(252) * 100, 2), "%"))

# Gráfica de retornos acumulados
retornos_port <- retornos %*% w
retornos_acum <- cumprod(1 + retornos_port) - 1
plot(retornos_acum, main = "Desempeño del Portafolio")
```

**Interpretación financiera:**
"Si hubieran invertido $100,000 pesos el 1 de enero de 2024 con estos pesos, así habría evolucionado su inversión."

---

### BLOQUE 7: Función personalizada y cierre

**7.1 Presentar función reutilizable**

Mostrar la función `analizar_portafolio()` del script:

"Esto es programación práctica. En lugar de escribir el mismo código cada vez, creamos una función que podemos reutilizar."

**Demostrar uso:**
```r
resultado <- analizar_portafolio(retornos, w)
print(resultado$retorno_esperado_anual)
print(resultado$volatilidad_anual)
print(resultado$sharpe_ratio)
```

**7.2 Introducción a ejercicios y cierre**

- Presentar los 7 ejercicios del script
- Explicar que son progresivos (del más fácil al más desafiante)


**Tarea:**
1. Completar ejercicios 1-4 (obligatorios)
2. Ejercicios 5-7 (opcionales pero muy recomendados)
3. Leer material sobre estadística descriptiva para la Sesión 3

---

## SOLUCIONES A EJERCICIOS

### Ejercicio 1:

```r
# a) Crear vectores
A <- c(0.02, -0.01, 0.03, 0.01, -0.02)
B <- c(0.01, 0.02, -0.01, 0.02, 0.01)

# b) Retorno promedio
mean(A)  # 0.006 = 0.6%
mean(B)  # 0.010 = 1.0%

# c) Volatilidad
sd(A)  # 0.0187 = 1.87%
sd(B)  # 0.0114 = 1.14%

# d) Retorno del portafolio
w <- c(0.6, 0.4)
retornos_prom <- c(mean(A), mean(B))
ret_port <- sum(w * retornos_prom)
# ret_port = 0.0076 = 0.76%
```

### Ejercicio 4:

```r
# a) Crear datos
w <- c(0.5, 0.3, 0.2)
Sigma <- matrix(c(0.04, 0.01, 0.02,
                  0.01, 0.09, -0.01,
                  0.02, -0.01, 0.16), 
                nrow = 3, ncol = 3)

# b) Varianza
var_p <- t(w) %*% Sigma %*% w
# var_p = 0.0334

# c) Volatilidad
vol_p <- sqrt(var_p)
# vol_p = 0.1828 = 18.28%

# d) Volatilidades individuales
vol_ind <- sqrt(diag(Sigma))
# [1] 0.20 0.30 0.40
# El portafolio (18.28%) tiene menor volatilidad
# que el promedio ponderado de las individuales
```

---

## PROBLEMAS COMUNES Y SOLUCIONES

### Problema 1: Error en multiplicación matricial
**Síntoma:** "non-conformable arguments"

**Causa:** Dimensiones incompatibles

**Solución:**
```r
# Verificar dimensiones
dim(matriz_cov)  # debe ser 3x3
length(w)        # debe ser 3

# Si w es una matriz en lugar de vector:
w <- as.numeric(w)  # Convertir a vector
```

### Problema 2: Matriz de covarianza con NAs
**Síntoma:** `cov()` devuelve NA

**Causa:** Datos faltantes en las series de tiempo

**Solución:**
```r
# Eliminar NAs antes de calcular covarianza
retornos_limpios <- na.omit(retornos)
matriz_cov <- cov(retornos_limpios)
```

### Problema 3: Fechas no coinciden al hacer merge
**Síntoma:** Muchos NAs al combinar activos

**Causa:** Días de negociación diferentes

**Solución:**
```r
# Usar merge con all=FALSE para conservar solo fechas comunes
precios <- merge(Cl(AMXL.MX), Cl(WALMEX.MX), all = FALSE)
```

### Problema 4: Confusión entre cov() y cor()
**Síntoma:** Valores muy pequeños o muy grandes

**Explicación:**
```r
# Covarianza: magnitud depende de escala de datos
cov(retornos)  # Valores pequeños (ej: 0.0001)

# Correlación: siempre entre -1 y 1
cor(retornos)  # Valores interpretables (ej: 0.65)
```

---

## EXTENSIONES Y PROFUNDIZACIÓN (Si hay tiempo extra)

### Tema adicional 1: Diversificación con muchos activos

```r
# ¿Qué pasa con 10 activos vs 3?
# Descargar más acciones y mostrar cómo la diversificación
# tiene rendimientos decrecientes
```

### Tema adicional 2: Pesos negativos (venta en corto)

```r
# ¿Qué significa w = c(0.6, 0.5, -0.1)?
# Introducir concepto de posiciones largas y cortas
```

### Tema adicional 3: Restricción de presupuesto

```r
# Verificar que sum(w) = 1
# ¿Qué pasa si sum(w) > 1? (apalancamiento)
# ¿Qué pasa si sum(w) < 1? (cash holdings)
```

---

## PREPARACIÓN PARA SESIÓN 3

**Temas de la siguiente sesión:**
- Estadística descriptiva de mercados
- Momentos estadísticos (media, varianza, asimetría, curtosis)
- Distribuciones de retornos
- Visualización de series temporales

**Materiales a preparar:**
- Lectura sobre estadística financiera
- Dataset con retornos de múltiples activos
- Ejemplos de distribuciones no-normales

**Conexión con Sesión 2:**
"Ya saben calcular retornos promedio y volatilidad. La próxima sesión profundizaremos en las DISTRIBUCIONES de esos retornos. ¿Son normales? ¿Hay valores extremos? ¿Qué implica para la gestión de riesgos?"

---

## RECURSOS ADICIONALES

### Para compartir:

**Videos complementarios:**
- 3Blue1Brown: "Essence of Linear Algebra" (YouTube)
  - Especialmente capítulo sobre matrices y transformaciones lineales
- Khan Academy: Matrix multiplication

**Artículos:**
- "The Only Three Questions That Count" - Ken Fisher (intro a pensamiento cuantitativo)

**Herramientas:**
- Matrix calculator online (para verificar cálculos a mano)
- Excel template para cálculo de covarianza (para quienes prefieren verificar visualmente)

### Para los más curiosos:

**Lecturas de profundización:**
- Markowitz (1952): El paper original de teoría de portafolios
- Elton & Gruber: "Modern Portfolio Theory, 1950 to Date"


