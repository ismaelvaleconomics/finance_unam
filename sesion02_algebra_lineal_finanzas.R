################################################################################
# MERCADOS DE CAPITALES - ANÁLISIS CUANTITATIVO
# SESIÓN 2: Álgebra Lineal Aplicada a Finanzas
#
# Profesor: Ismael Valverde
# Facultad de Economía, UNAM
#
# CONTENIDO DE LA SESIÓN:
# 1. Revisión de ejercicios Sesión 1
# 2. Vectores y matrices en R - Operaciones básicas
# 3. Vectores de retornos y pesos de portafolios
# 4. Matrices de retornos de múltiples activos
# 5. Matriz de covarianza y correlación
# 6. Cálculo de retornos y varianza de portafolios
# 7. Lab: Aplicación con datos reales de la BMV
################################################################################

################################################################################
# PARTE 1: CONFIGURACIÓN INICIAL
################################################################################

# Limpiar el ambiente de trabajo
rm(list = ls())

# Cargar librerías necesarias
library(quantmod)
library(PerformanceAnalytics)
library(tidyverse)
library(corrplot)  # Para visualizar matrices de correlación

cat("Librerías cargadas exitosamente!\n")
cat("Sesión 2: Álgebra Lineal Aplicada a Finanzas\n\n")

################################################################################
# PARTE 2: VECTORES EN R - FUNDAMENTOS
################################################################################

cat("========== PARTE 2: VECTORES EN R ==========\n\n")

# Los vectores son la estructura fundamental en R
# Representan series de datos del mismo tipo

# Crear un vector de retornos de una acción durante 5 días
retornos_accion <- c(0.015, -0.008, 0.023, 0.012, -0.005)
print("Vector de retornos diarios de una acción:")
print(retornos_accion)

# Características del vector
cat("\nLongitud del vector:", length(retornos_accion), "\n")
cat("Clase del objeto:", class(retornos_accion), "\n")

# Operaciones con vectores
cat("\n--- Operaciones con vectores ---\n")

# Suma de vectores (elemento por elemento)
retornos_dia1 <- c(0.02, 0.01, 0.03)
retornos_dia2 <- c(0.01, -0.01, 0.02)
suma_retornos <- retornos_dia1 + retornos_dia2
print("Suma de vectores:")
print(suma_retornos)

# Multiplicación por escalar
capital_inicial <- 100000  # $100,000 MXN
pesos <- c(0.4, 0.3, 0.3)
inversion_pesos <- capital_inicial * pesos
print("\nInversión en cada activo ($MXN):")
print(inversion_pesos)

# Producto punto (inner product) - MUY IMPORTANTE EN FINANZAS
# En R se usa %*% para multiplicación matricial o producto punto
cat("\n--- Producto punto (retorno de portafolio) ---\n")

# Vector de pesos (proporciones)
w <- c(0.4, 0.3, 0.3)

# Vector de retornos
r <- c(0.015, -0.008, 0.023)

# Retorno del portafolio: w^T * r
# Método 1: usando sum()
retorno_portafolio_1 <- sum(w * r)

# Método 2: usando producto matricial
retorno_portafolio_2 <- as.numeric(t(w) %*% r)

cat("Retorno del portafolio (Método 1):", retorno_portafolio_1, "\n")
cat("Retorno del portafolio (Método 2):", retorno_portafolio_2, "\n")
cat("Retorno en porcentaje:", round(retorno_portafolio_1 * 100, 3), "%\n")

# Verificación importante: los pesos deben sumar 1
cat("\nSuma de pesos:", sum(w), "\n")
if (sum(w) == 1) {
  cat("✓ Los pesos suman correctamente 1 (100%)\n")
} else {
  cat("✗ ADVERTENCIA: Los pesos no suman 1\n")
}

################################################################################
# PARTE 3: MATRICES EN R - FUNDAMENTOS
################################################################################

cat("\n\n========== PARTE 3: MATRICES EN R ==========\n\n")

# Las matrices son arreglos bidimensionales
# Filas = periodos de tiempo, Columnas = diferentes activos

# Crear una matriz de retornos: 5 días, 3 activos
# Método 1: Usando matrix() y llenando por columnas
retornos_matriz <- matrix(
  c(0.015, -0.008, 0.023, 0.012, -0.005,  # Retornos Activo 1 (AMXL)
    0.010, 0.005, -0.010, 0.018, 0.002,   # Retornos Activo 2 (WALMEX)
    0.020, -0.003, 0.015, 0.008, 0.012),  # Retornos Activo 3 (GFNORTEO)
  nrow = 5,        # 5 filas (días)
  ncol = 3,        # 3 columnas (activos)
  byrow = FALSE    # Llenar por columnas
)

# Asignar nombres a filas y columnas
rownames(retornos_matriz) <- paste("Día", 1:5)
colnames(retornos_matriz) <- c("AMXL", "WALMEX", "GFNORTEO")

print("Matriz de retornos (5 días, 3 activos):")
print(retornos_matriz)

# Dimensiones de la matriz
cat("\nDimensiones de la matriz (filas x columnas):", dim(retornos_matriz), "\n")
cat("Número de filas:", nrow(retornos_matriz), "\n")
cat("Número de columnas:", ncol(retornos_matriz), "\n")

# Acceso a elementos de la matriz
cat("\n--- Acceso a elementos ---\n")
cat("Retorno de AMXL en Día 3:", retornos_matriz[3, 1], "\n")
cat("Retorno de WALMEX en Día 5:", retornos_matriz[5, 2], "\n")

# Acceso a filas completas (todos los activos en un día)
cat("\nRetornos de todos los activos en Día 1:\n")
print(retornos_matriz[1, ])

# Acceso a columnas completas (un activo en todos los días)
cat("\nRetornos de WALMEX en todos los días:\n")
print(retornos_matriz[, 2])

# Operaciones con matrices
cat("\n--- Estadísticas por columna (por activo) ---\n")

# Retorno promedio de cada activo
retornos_promedio <- colMeans(retornos_matriz)
print("Retorno promedio por activo:")
print(retornos_promedio)

# Desviación estándar de cada activo (volatilidad)
volatilidades <- apply(retornos_matriz, 2, sd)
print("\nVolatilidad (desviación estándar) por activo:")
print(volatilidades)

# Retorno acumulado
retornos_acumulados <- apply(retornos_matriz, 2, sum)
print("\nRetorno acumulado (5 días) por activo:")
print(retornos_acumulados)

################################################################################
# PARTE 4: MATRIZ TRANSPUESTA
################################################################################

cat("\n--- Matriz Transpuesta ---\n")

# Transponer: intercambiar filas por columnas
retornos_transpuesta <- t(retornos_matriz)

print("Matriz original (5x3):")
print(dim(retornos_matriz))

print("\nMatriz transpuesta (3x5):")
print(dim(retornos_transpuesta))
print(retornos_transpuesta)

# Aplicación: convertir de formato "días x activos" a "activos x días"

################################################################################
# PARTE 5: MULTIPLICACIÓN DE MATRICES
################################################################################

cat("\n\n========== PARTE 5: MULTIPLICACIÓN MATRICIAL ==========\n\n")

# La multiplicación de matrices es crucial para cálculos de portafolios

# Ejemplo simple: matriz 2x3 por vector 3x1
A <- matrix(c(1, 2, 3, 4, 5, 6), nrow = 2, ncol = 3, byrow = TRUE)
v <- c(1, 2, 3)

print("Matriz A (2x3):")
print(A)
print("\nVector v (3x1):")
print(v)

# Multiplicación: A %*% v
resultado <- A %*% v
print("\nResultado A %*% v:")
print(resultado)

# APLICACIÓN FINANCIERA: Calcular retornos de portafolio para múltiples días

cat("\n--- Aplicación: Retornos de portafolio en múltiples días ---\n")

# Tenemos retornos_matriz (5 días x 3 activos)
# Vector de pesos w (3 activos)
w <- c(0.4, 0.3, 0.3)

# Calcular retorno del portafolio para cada día
# Resultado: vector de 5 elementos (uno por día)
retornos_portafolio <- retornos_matriz %*% w

print("Retornos del portafolio por día:")
print(retornos_portafolio)

# Agregar como columna a la matriz
retornos_con_portafolio <- cbind(retornos_matriz, Portafolio = retornos_portafolio)
print("\nMatriz con columna de portafolio:")
print(retornos_con_portafolio)

# Retorno promedio del portafolio
retorno_promedio_portafolio <- mean(retornos_portafolio)
cat("\nRetorno promedio del portafolio:", 
    round(retorno_promedio_portafolio * 100, 3), "%\n")

################################################################################
# PARTE 6: MATRIZ DE COVARIANZA
################################################################################

cat("\n\n========== PARTE 6: MATRIZ DE COVARIANZA ==========\n\n")

# La matriz de covarianza es FUNDAMENTAL en teoría de portafolios
# Captura cómo se mueven los activos juntos

# Calcular matriz de covarianza de nuestros 3 activos
matriz_cov <- cov(retornos_matriz)

print("Matriz de Covarianza:")
print(matriz_cov)

cat("\n--- Interpretación ---\n")
cat("Elementos de la diagonal (varianzas):\n")
cat("  Var(AMXL)     =", matriz_cov[1,1], "\n")
cat("  Var(WALMEX)   =", matriz_cov[2,2], "\n")
cat("  Var(GFNORTEO) =", matriz_cov[3,3], "\n")

cat("\nElementos fuera de la diagonal (covarianzas):\n")
cat("  Cov(AMXL, WALMEX)     =", matriz_cov[1,2], "\n")
cat("  Cov(AMXL, GFNORTEO)   =", matriz_cov[1,3], "\n")
cat("  Cov(WALMEX, GFNORTEO) =", matriz_cov[2,3], "\n")

# Desviaciones estándar (raíz cuadrada de varianzas)
desv_std <- sqrt(diag(matriz_cov))
print("\nDesviaciones estándar (volatilidades):")
print(desv_std)

################################################################################
# PARTE 7: MATRIZ DE CORRELACIÓN
################################################################################

cat("\n\n========== PARTE 7: MATRIZ DE CORRELACIÓN ==========\n\n")

# La correlación estandariza las covarianzas entre -1 y 1
matriz_cor <- cor(retornos_matriz)

print("Matriz de Correlación:")
print(round(matriz_cor, 3))

cat("\n--- Interpretación de correlaciones ---\n")
cat("Correlación AMXL - WALMEX:    ", round(matriz_cor[1,2], 3), "\n")
cat("Correlación AMXL - GFNORTEO:  ", round(matriz_cor[1,3], 3), "\n")
cat("Correlación WALMEX - GFNORTEO:", round(matriz_cor[2,3], 3), "\n")

# Visualización de la matriz de correlación
cat("\nGenerando gráfica de correlación...\n")
corrplot(matriz_cor, 
         method = "color",
         type = "upper",
         addCoef.col = "black",
         tl.col = "black",
         tl.srt = 45,
         title = "Matriz de Correlación",
         mar = c(0,0,1,0))

# Relación entre correlación y covarianza
cat("\n--- Relación Correlación-Covarianza ---\n")
cat("Fórmula: Cov(X,Y) = Cor(X,Y) * SD(X) * SD(Y)\n")

# Verificación manual
cor_manual <- matriz_cov[1,2] / (desv_std[1] * desv_std[2])
cat("Correlación AMXL-WALMEX (calculada manualmente):", 
    round(cor_manual, 3), "\n")
cat("Correlación AMXL-WALMEX (función cor()):", 
    round(matriz_cor[1,2], 3), "\n")

################################################################################
# PARTE 8: VARIANZA DE PORTAFOLIO
################################################################################

cat("\n\n========== PARTE 8: VARIANZA DE PORTAFOLIO ==========\n\n")

# Esta es LA fórmula más importante de la sesión:
# σ²_p = w^T * Σ * w
# Donde:
#   w = vector de pesos
#   Σ = matriz de covarianza

# Nuestro portafolio
w <- c(0.4, 0.3, 0.3)
print("Vector de pesos del portafolio:")
print(w)

# Paso 1: Calcular Σ * w
Sigma_w <- matriz_cov %*% w
print("\nΣ * w =")
print(Sigma_w)

# Paso 2: Calcular w^T * (Σ * w)
varianza_portafolio <- as.numeric(t(w) %*% Sigma_w)

cat("\nVarianza del portafolio: σ²_p =", varianza_portafolio, "\n")

# Desviación estándar del portafolio (volatilidad)
volatilidad_portafolio <- sqrt(varianza_portafolio)
cat("Volatilidad del portafolio: σ_p =", volatilidad_portafolio, "\n")
cat("Volatilidad en porcentaje:", round(volatilidad_portafolio * 100, 2), "%\n")

# Forma alternativa (todo en una línea)
varianza_alternativa <- as.numeric(t(w) %*% matriz_cov %*% w)
cat("\nVerificación (método alternativo):", varianza_alternativa, "\n")

# Comparar con volatilidades individuales
cat("\n--- Comparación ---\n")
cat("Volatilidad AMXL:       ", round(desv_std[1] * 100, 2), "%\n")
cat("Volatilidad WALMEX:     ", round(desv_std[2] * 100, 2), "%\n")
cat("Volatilidad GFNORTEO:   ", round(desv_std[3] * 100, 2), "%\n")
cat("Volatilidad PORTAFOLIO: ", round(volatilidad_portafolio * 100, 2), "%\n")

cat("\n** La diversificación reduce el riesgo! **\n")

################################################################################
# PARTE 9: RETORNO Y RIESGO DE PORTAFOLIO - RESUMEN
################################################################################

cat("\n\n========== PARTE 9: RESUMEN - RETORNO Y RIESGO ==========\n\n")

# Cálculo completo de un portafolio

# Vector de retornos esperados
mu <- colMeans(retornos_matriz)
print("Vector de retornos esperados (μ):")
print(mu)

# Vector de pesos
print("\nVector de pesos (w):")
print(w)

# Retorno esperado del portafolio: μ_p = w^T * μ
retorno_esperado_portafolio <- as.numeric(t(w) %*% mu)
cat("\nRetorno esperado del portafolio: μ_p =", 
    round(retorno_esperado_portafolio * 100, 3), "%\n")

# Varianza del portafolio (ya calculada)
cat("Varianza del portafolio: σ²_p =", 
    round(varianza_portafolio, 6), "\n")

# Volatilidad del portafolio (ya calculada)
cat("Volatilidad del portafolio: σ_p =", 
    round(volatilidad_portafolio * 100, 2), "%\n")

# Ratio de Sharpe (asumiendo tasa libre de riesgo = 0 para simplificar)
sharpe_ratio <- retorno_esperado_portafolio / volatilidad_portafolio
cat("\nRatio de Sharpe (aprox.):", round(sharpe_ratio, 3), "\n")

# Crear un data frame resumen
resumen_portafolio <- data.frame(
  Activo = c("AMXL", "WALMEX", "GFNORTEO", "PORTAFOLIO"),
  Peso = c(w, sum(w)),
  Retorno_Esperado = c(mu, retorno_esperado_portafolio) * 100,
  Volatilidad = c(desv_std, volatilidad_portafolio) * 100
)

print("\n--- RESUMEN DEL PORTAFOLIO ---")
print(resumen_portafolio)

################################################################################
# PARTE 10: APLICACIÓN CON DATOS REALES DE LA BMV
################################################################################

cat("\n\n========== PARTE 10: APLICACIÓN CON DATOS REALES ==========\n\n")

# Descargar datos de 3 acciones mexicanas
tickers <- c("AMXL.MX", "WALMEX.MX", "GFNORTEO.MX")
fecha_inicio <- "2024-01-01"
fecha_fin <- Sys.Date()

cat("Descargando datos de la BMV...\n")
cat("Tickers:", paste(tickers, collapse = ", "), "\n")
cat("Periodo:", fecha_inicio, "a", fecha_fin, "\n\n")

# Descargar datos
tryCatch({
  getSymbols(tickers, 
             from = fecha_inicio, 
             to = fecha_fin,
             src = "yahoo",
             auto.assign = TRUE)
  
  # Extraer precios de cierre y combinar
  precios <- merge(Cl(AMXL.MX), Cl(WALMEX.MX), Cl(GFNORTEO.MX))
  colnames(precios) <- c("AMXL", "WALMEX", "GFNORTEO")
  
  # Eliminar NAs
  precios <- na.omit(precios)
  
  cat("Datos descargados exitosamente!\n")
  cat("Primeras observaciones:\n")
  print(head(precios))
  
  # Calcular retornos diarios
  retornos_reales <- Return.calculate(precios, method = "discrete")
  retornos_reales <- na.omit(retornos_reales)
  
  cat("\nRetornos diarios calculados.\n")
  cat("Primeros retornos:\n")
  print(head(retornos_reales))
  
  # Estadísticas descriptivas
  cat("\n--- ESTADÍSTICAS DESCRIPTIVAS ---\n")
  print(summary(retornos_reales))
  
  # Calcular matriz de covarianza con datos reales
  cov_real <- cov(retornos_reales)
  cat("\n--- MATRIZ DE COVARIANZA (Datos Reales) ---\n")
  print(cov_real)
  
  # Calcular matriz de correlación con datos reales
  cor_real <- cor(retornos_reales)
  cat("\n--- MATRIZ DE CORRELACIÓN (Datos Reales) ---\n")
  print(round(cor_real, 3))
  
  # Visualizar correlación
  corrplot(cor_real,
           method = "color",
           type = "upper",
           addCoef.col = "black",
           tl.col = "black",
           tl.srt = 45,
           title = "Correlación - Datos Reales BMV",
           mar = c(0,0,2,0))
  
  # Definir un portafolio
  w_real <- c(0.4, 0.3, 0.3)
  names(w_real) <- c("AMXL", "WALMEX", "GFNORTEO")
  
  cat("\n--- ANÁLISIS DEL PORTAFOLIO ---\n")
  cat("Pesos:\n")
  print(w_real)
  
  # Retorno esperado (usando promedio histórico)
  mu_real <- colMeans(retornos_reales)
  retorno_esp_real <- as.numeric(t(w_real) %*% mu_real)
  
  cat("\nRetorno esperado diario:", round(retorno_esp_real * 100, 4), "%\n")
  cat("Retorno esperado anual (aprox.):", 
      round(retorno_esp_real * 252 * 100, 2), "%\n")
  
  # Varianza y volatilidad del portafolio
  var_port_real <- as.numeric(t(w_real) %*% cov_real %*% w_real)
  vol_port_real <- sqrt(var_port_real)
  
  cat("\nVolatilidad diaria:", round(vol_port_real * 100, 3), "%\n")
  cat("Volatilidad anual (aprox.):", 
      round(vol_port_real * sqrt(252) * 100, 2), "%\n")
  
  # Calcular retornos históricos del portafolio
  retornos_portafolio_real <- as.xts(retornos_reales %*% w_real)
  
  # Gráfica de retornos acumulados
  retornos_acum <- cumprod(1 + retornos_portafolio_real) - 1
  
  plot(retornos_acum,
       main = "Retorno Acumulado del Portafolio",
       ylab = "Retorno Acumulado",
       xlab = "Fecha",
       col = "blue",
       lwd = 2)
  grid()
  
  # Comparar con retornos acumulados individuales
  retornos_acum_individuales <- cumprod(1 + retornos_reales) - 1
  
  plot(retornos_acum_individuales$AMXL,
       main = "Comparación de Retornos Acumulados",
       ylab = "Retorno Acumulado",
       col = "red",
       lwd = 2,
       ylim = range(retornos_acum_individuales, retornos_acum))
  lines(retornos_acum_individuales$WALMEX, col = "green", lwd = 2)
  lines(retornos_acum_individuales$GFNORTEO, col = "orange", lwd = 2)
  lines(retornos_acum, col = "blue", lwd = 2, lty = 2)
  legend("topleft",
         legend = c("AMXL", "WALMEX", "GFNORTEO", "Portafolio"),
         col = c("red", "green", "orange", "blue"),
         lty = c(1, 1, 1, 2),
         lwd = 2)
  grid()
  
  # Distribución de retornos del portafolio
  hist(retornos_portafolio_real,
       breaks = 30,
       main = "Distribución de Retornos del Portafolio",
       xlab = "Retorno Diario",
       col = "lightblue",
       border = "white")
  abline(v = mean(retornos_portafolio_real), col = "red", lwd = 2, lty = 2)
  abline(v = 0, col = "black", lwd = 1)
  legend("topright",
         legend = c("Media", "Cero"),
         col = c("red", "black"),
         lty = c(2, 1),
         lwd = c(2, 1))
  
  cat("\nAnálisis completado con datos reales!\n")
  
}, error = function(e) {
  cat("Error al descargar datos. Verifica conexión a internet.\n")
  cat("Mensaje de error:", e$message, "\n")
})

################################################################################
# PARTE 11: FUNCIÓN PERSONALIZADA PARA ANÁLISIS DE PORTAFOLIO
################################################################################

cat("\n\n========== PARTE 11: FUNCIÓN PERSONALIZADA ==========\n\n")

# Crear una función reutilizable para analizar portafolios

analizar_portafolio <- function(retornos, pesos) {
  # Validaciones
  if (ncol(retornos) != length(pesos)) {
    stop("El número de activos no coincide con el número de pesos")
  }
  
  if (abs(sum(pesos) - 1) > 0.001) {
    warning("Los pesos no suman exactamente 1")
  }
  
  # Cálculos
  mu <- colMeans(retornos)
  Sigma <- cov(retornos)
  
  # Retorno esperado
  retorno_esp <- as.numeric(t(pesos) %*% mu)
  
  # Varianza y volatilidad
  varianza <- as.numeric(t(pesos) %*% Sigma %*% pesos)
  volatilidad <- sqrt(varianza)
  
  # Ratio de Sharpe (asumiendo rf = 0)
  sharpe <- retorno_esp / volatilidad
  
  # Retornos del portafolio
  ret_port <- retornos %*% pesos
  
  # Crear objeto de resultados
  resultado <- list(
    pesos = pesos,
    retorno_esperado_diario = retorno_esp,
    retorno_esperado_anual = retorno_esp * 252,
    volatilidad_diaria = volatilidad,
    volatilidad_anual = volatilidad * sqrt(252),
    sharpe_ratio = sharpe,
    matriz_covarianza = Sigma,
    matriz_correlacion = cor(retornos),
    retornos_portafolio = ret_port
  )
  
  return(resultado)
}

# Usar la función con nuestros datos reales
cat("Usando función personalizada para analizar portafolio...\n")

if (exists("retornos_reales")) {
  resultado_analisis <- analizar_portafolio(retornos_reales, w_real)
  
  cat("\n--- RESULTADOS DEL ANÁLISIS ---\n")
  cat("Retorno esperado anual:", 
      round(resultado_analisis$retorno_esperado_anual * 100, 2), "%\n")
  cat("Volatilidad anual:", 
      round(resultado_analisis$volatilidad_anual * 100, 2), "%\n")
  cat("Ratio de Sharpe:", 
      round(resultado_analisis$sharpe_ratio, 3), "\n")
}

################################################################################
# EJERCICIOS PARA LOS ESTUDIANTES
################################################################################

cat("\n\n")
cat("================================================================================\n")
cat("                         EJERCICIOS PARA PRÁCTICA\n")
cat("================================================================================\n\n")

cat("EJERCICIO 1: VECTORES Y RETORNOS\n")
cat("--------------------------------\n")
cat("Tienes los siguientes retornos semanales de dos activos:\n")
cat("Activo A: c(0.02, -0.01, 0.03, 0.01, -0.02)\n")
cat("Activo B: c(0.01, 0.02, -0.01, 0.02, 0.01)\n\n")
cat("a) Crea dos vectores con estos retornos\n")
cat("b) Calcula el retorno promedio de cada activo\n")
cat("c) Calcula la volatilidad (desviación estándar) de cada activo\n")
cat("d) Si inviertes 60% en A y 40% en B, ¿cuál sería el retorno promedio\n")
cat("   del portafolio?\n\n")

# ESPACIO PARA RESPUESTA
# Tu código aquí:




cat("\n\nEJERCICIO 2: MATRICES DE RETORNOS\n")
cat("----------------------------------\n")
cat("a) Crea una matriz de retornos de 4 activos durante 6 días\n")
cat("   (usa datos ficticios realistas entre -2% y 2%)\n")
cat("b) Asigna nombres a las filas (Día 1 a 6) y columnas (Activo A, B, C, D)\n")
cat("c) Calcula el retorno promedio de cada activo\n")
cat("d) Identifica qué activo tuvo la mayor volatilidad\n")
cat("e) Calcula el retorno del portafolio para cada día si los pesos son:\n")
cat("   w = c(0.25, 0.25, 0.25, 0.25)\n\n")

# ESPACIO PARA RESPUESTA
# Tu código aquí:




cat("\n\nEJERCICIO 3: MATRIZ DE COVARIANZA Y CORRELACIÓN\n")
cat("-----------------------------------------------\n")
cat("Usando la matriz de retornos que creaste en el Ejercicio 2:\n")
cat("a) Calcula la matriz de covarianza\n")
cat("b) Calcula la matriz de correlación\n")
cat("c) Identifica qué par de activos tiene la mayor correlación positiva\n")
cat("d) Identifica qué par de activos tiene la menor correlación\n")
cat("e) Crea una visualización de la matriz de correlación usando corrplot()\n\n")

# ESPACIO PARA RESPUESTA
# Tu código aquí:




cat("\n\nEJERCICIO 4: VARIANZA DE PORTAFOLIO\n")
cat("-----------------------------------\n")
cat("Considera un portafolio de 3 activos con:\n")
cat("- Pesos: w = c(0.5, 0.3, 0.2)\n")
cat("- Matriz de covarianza:\n")
cat("  Σ = matrix(c(0.04, 0.01, 0.02,\n")
cat("               0.01, 0.09, -0.01,\n")
cat("               0.02, -0.01, 0.16), nrow=3, ncol=3)\n\n")
cat("a) Crea el vector de pesos y la matriz de covarianza en R\n")
cat("b) Calcula la varianza del portafolio usando la fórmula: w^T * Σ * w\n")
cat("c) Calcula la volatilidad (desviación estándar) del portafolio\n")
cat("d) Compara la volatilidad del portafolio con las volatilidades individuales\n")
cat("   (que son la raíz cuadrada de los elementos diagonales de Σ)\n\n")

# ESPACIO PARA RESPUESTA
# Tu código aquí:




cat("\n\nEJERCICIO 5: DATOS REALES - PORTAFOLIO PERSONALIZADO\n")
cat("----------------------------------------------------\n")
cat("a) Descarga datos de 4 acciones mexicanas de tu elección para el año 2024\n")
cat("   Sugerencias: CEMEXCPO.MX, TLEVISA.MX, FEMSAUBD.MX, GMEXICOB.MX\n")
cat("b) Calcula los retornos diarios\n")
cat("c) Calcula la matriz de correlación y visualízala\n")
cat("d) Define un portafolio con pesos de tu elección (que sumen 1)\n")
cat("e) Calcula el retorno esperado anual del portafolio\n")
cat("f) Calcula la volatilidad anual del portafolio\n")
cat("g) Grafica los retornos acumulados del portafolio vs cada activo individual\n\n")

# ESPACIO PARA RESPUESTA
# Tu código aquí:




cat("\n\nEJERCICIO 6: OPTIMIZACIÓN SIMPLE\n")
cat("--------------------------------\n")
cat("Usando los datos del Ejercicio 5:\n")
cat("a) Prueba 3 combinaciones diferentes de pesos:\n")
cat("   - Portafolio 1: Pesos iguales (0.25, 0.25, 0.25, 0.25)\n")
cat("   - Portafolio 2: Concentrado en 2 activos (0.5, 0.5, 0, 0)\n")
cat("   - Portafolio 3: Tu elección\n")
cat("b) Para cada portafolio, calcula retorno esperado y volatilidad\n")
cat("c) Calcula el ratio de Sharpe para cada uno (asume rf = 0)\n")
cat("d) ¿Cuál portafolio tiene el mejor ratio de Sharpe?\n")
cat("e) Crea una tabla comparativa con los resultados\n\n")

# ESPACIO PARA RESPUESTA
# Tu código aquí:




cat("\n\nEJERCICIO 7: DIVERSIFICACIÓN\n")
cat("----------------------------\n")
cat("Este ejercicio demuestra el beneficio de la diversificación:\n")
cat("a) Descarga datos de 2 activos con baja correlación (ej: AMXL.MX y CEMEXCPO.MX)\n")
cat("b) Calcula retornos diarios del último año\n")
cat("c) Crea 11 portafolios variando los pesos de 0% a 100% en incrementos de 10%\n")
cat("   Portafolio 1:  w = c(1.0, 0.0)\n")
cat("   Portafolio 2:  w = c(0.9, 0.1)\n")
cat("   ...\n")
cat("   Portafolio 11: w = c(0.0, 1.0)\n")
cat("d) Para cada portafolio, calcula retorno esperado y volatilidad\n")
cat("e) Grafica volatilidad (eje x) vs retorno esperado (eje y)\n")
cat("f) ¿Observas la frontera eficiente?\n\n")

# ESPACIO PARA RESPUESTA
# Tu código aquí:




cat("\n\n")
cat("================================================================================\n")
cat("                   FIN DE LA SESIÓN 2 - ÁLGEBRA LINEAL EN FINANZAS\n")
cat("================================================================================\n")
cat("\n")
cat("RECORDATORIOS:\n")
cat("- Practica las fórmulas matriciales: w^T * r  y  w^T * Σ * w\n")
cat("- Entiende la diferencia entre covarianza y correlación\n")
cat("- La diversificación reduce el riesgo (pero no lo elimina completamente)\n")
cat("- Guarda tus ejercicios para la próxima sesión\n")
cat("\n")
cat("PRÓXIMA SESIÓN: Estadística descriptiva de mercados\n")
cat("\n")

################################################################################
# FIN DEL SCRIPT
################################################################################
