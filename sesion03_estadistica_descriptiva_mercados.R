################################################################################
# MERCADOS DE CAPITALES - ANÁLISIS CUANTITATIVO
# SESIÓN 3: Estadística Descriptiva de Mercados
#
# Profesor: Ismael Valverde
# Facultad de Economía, UNAM
#
# CONTENIDO DE LA SESIÓN:
# 1. Revisión de ejercicios Sesión 2 (15 minutos)
# 2. Momentos estadísticos: media, varianza, asimetría, curtosis
# 3. Distribuciones de retornos financieros
# 4. Pruebas de normalidad
# 5. Valores extremos y colas pesadas
# 6. Visualización de series temporales
# 7. Análisis exploratorio del IPC y acciones mexicanas
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
library(moments)      # Para asimetría y curtosis
library(tseries)      # Para pruebas estadísticas
library(ggplot2)
library(gridExtra)    # Para múltiples gráficas

cat("Librerías cargadas exitosamente!\n")
cat("Sesión 3: Estadística Descriptiva de Mercados\n\n")

################################################################################
# PARTE 2: MOMENTOS ESTADÍSTICOS - INTRODUCCIÓN
################################################################################

cat("========== PARTE 2: MOMENTOS ESTADÍSTICOS ==========\n\n")

# Los momentos estadísticos describen la forma de una distribución
# En finanzas, nos interesan principalmente 4 momentos:
# 1. Media (primer momento) - ubicación central
# 2. Varianza/Desviación estándar (segundo momento) - dispersión
# 3. Asimetría/Skewness (tercer momento) - simetría
# 4. Curtosis (cuarto momento) - "grosor" de las colas

# Crear datos de ejemplo para demostrar los conceptos
set.seed(123)

# Distribución normal estándar
datos_normales <- rnorm(1000, mean = 0, sd = 1)

# Distribución con asimetría positiva (cola derecha larga)
datos_asimetria_pos <- rchisq(1000, df = 3)

# Distribución con asimetría negativa (cola izquierda larga)
datos_asimetria_neg <- -rchisq(1000, df = 3)

# Distribución con colas pesadas (curtosis alta)
datos_colas_pesadas <- rt(1000, df = 3)

cat("--- Datos generados para demostración ---\n")
cat("1. Normales: N(0,1)\n")
cat("2. Asimetría positiva: Chi-cuadrado\n")
cat("3. Asimetría negativa: -Chi-cuadrado\n")
cat("4. Colas pesadas: t-Student\n\n")

################################################################################
# PARTE 3: PRIMER MOMENTO - MEDIA (RETORNO PROMEDIO)
################################################################################

cat("\n========== PRIMER MOMENTO: MEDIA ==========\n\n")

# La media es el valor esperado o promedio
# En finanzas: retorno promedio o esperado

cat("Cálculo de la media:\n")
cat("Media datos normales:", mean(datos_normales), "\n")
cat("Media asimetría positiva:", mean(datos_asimetria_pos), "\n")
cat("Media asimetría negativa:", mean(datos_asimetria_neg), "\n")

# Visualización
par(mfrow = c(2, 2))

hist(datos_normales, breaks = 30, main = "Distribución Normal",
     xlab = "Valor", col = "lightblue", border = "white")
abline(v = mean(datos_normales), col = "red", lwd = 2, lty = 2)

hist(datos_asimetria_pos, breaks = 30, main = "Asimetría Positiva",
     xlab = "Valor", col = "lightgreen", border = "white")
abline(v = mean(datos_asimetria_pos), col = "red", lwd = 2, lty = 2)

hist(datos_asimetria_neg, breaks = 30, main = "Asimetría Negativa",
     xlab = "Valor", col = "lightyellow", border = "white")
abline(v = mean(datos_asimetria_neg), col = "red", lwd = 2, lty = 2)

hist(datos_colas_pesadas, breaks = 30, main = "Colas Pesadas",
     xlab = "Valor", col = "lightcoral", border = "white")
abline(v = mean(datos_colas_pesadas), col = "red", lwd = 2, lty = 2)

par(mfrow = c(1, 1))

cat("\nLa línea roja indica la media en cada distribución\n")

################################################################################
# PARTE 4: SEGUNDO MOMENTO - VARIANZA Y DESVIACIÓN ESTÁNDAR
################################################################################

cat("\n\n========== SEGUNDO MOMENTO: VARIANZA Y VOLATILIDAD ==========\n\n")

# Varianza: promedio de las desviaciones cuadradas respecto a la media
# Desviación estándar: raíz cuadrada de la varianza
# En finanzas: volatilidad = desviación estándar de retornos

cat("--- VARIANZA ---\n")
cat("Varianza datos normales:", var(datos_normales), "\n")
cat("Varianza colas pesadas:", var(datos_colas_pesadas), "\n")

cat("\n--- DESVIACIÓN ESTÁNDAR (VOLATILIDAD) ---\n")
cat("Desv. Est. datos normales:", sd(datos_normales), "\n")
cat("Desv. Est. colas pesadas:", sd(datos_colas_pesadas), "\n")

# Interpretación financiera
cat("\n*** INTERPRETACIÓN FINANCIERA ***\n")
cat("Si un activo tiene retorno medio = 10% anual\n")
cat("y desviación estándar = 20% anual:\n")
cat("- 68% del tiempo, el retorno estará entre -10% y 30% (μ ± 1σ)\n")
cat("- 95% del tiempo, el retorno estará entre -30% y 50% (μ ± 2σ)\n")
cat("(Asumiendo distribución normal)\n")

################################################################################
# PARTE 5: TERCER MOMENTO - ASIMETRÍA (SKEWNESS)
################################################################################

cat("\n\n========== TERCER MOMENTO: ASIMETRÍA (SKEWNESS) ==========\n\n")

# Asimetría mide si la distribución es simétrica o tiene cola larga
# Skewness = 0: distribución simétrica
# Skewness > 0: cola derecha larga (asimetría positiva)
# Skewness < 0: cola izquierda larga (asimetría negativa)

library(moments)

cat("--- CÁLCULO DE ASIMETRÍA ---\n")
asim_normal <- skewness(datos_normales)
asim_pos <- skewness(datos_asimetria_pos)
asim_neg <- skewness(datos_asimetria_neg)

cat("Asimetría distribución normal:", round(asim_normal, 3), "\n")
cat("Asimetría distribución positiva:", round(asim_pos, 3), "\n")
cat("Asimetría distribución negativa:", round(asim_neg, 3), "\n")

cat("\n*** INTERPRETACIÓN EN FINANZAS ***\n")
cat("Asimetría NEGATIVA (< 0): Riesgo de grandes pérdidas\n")
cat("  - Más probabilidad de caídas extremas\n")
cat("  - Ejemplo: Crash bursátil\n")
cat("  - Indeseable para inversionistas\n\n")

cat("Asimetría POSITIVA (> 0): Potencial de grandes ganancias\n")
cat("  - Más probabilidad de subidas extremas\n")
cat("  - Ejemplo: Inversión en startups exitosas\n")
cat("  - Deseable para inversionistas\n\n")

# Visualización comparativa
par(mfrow = c(1, 3))

hist(datos_normales, breaks = 30, main = paste("Skewness =", round(asim_normal, 2)),
     xlab = "Valor", col = "lightblue")
abline(v = mean(datos_normales), col = "red", lwd = 2)
abline(v = median(datos_normales), col = "blue", lwd = 2, lty = 2)

hist(datos_asimetria_pos, breaks = 30, main = paste("Skewness =", round(asim_pos, 2)),
     xlab = "Valor", col = "lightgreen")
abline(v = mean(datos_asimetria_pos), col = "red", lwd = 2)
abline(v = median(datos_asimetria_pos), col = "blue", lwd = 2, lty = 2)

hist(datos_asimetria_neg, breaks = 30, main = paste("Skewness =", round(asim_neg, 2)),
     xlab = "Valor", col = "lightyellow")
abline(v = mean(datos_asimetria_neg), col = "red", lwd = 2)
abline(v = median(datos_asimetria_neg), col = "blue", lwd = 2, lty = 2)

par(mfrow = c(1, 1))

cat("\nLínea ROJA = Media, Línea AZUL = Mediana\n")
cat("En distribución simétrica: media = mediana\n")
cat("En asimetría positiva: media > mediana\n")
cat("En asimetría negativa: media < mediana\n")

################################################################################
# PARTE 6: CUARTO MOMENTO - CURTOSIS
################################################################################

cat("\n\n========== CUARTO MOMENTO: CURTOSIS ==========\n\n")

# Curtosis mide el "grosor" de las colas de la distribución
# Curtosis = 3: distribución normal (mesocúrtica)
# Curtosis > 3: colas pesadas (leptocúrtica) - más valores extremos
# Curtosis < 3: colas ligeras (platicúrtica) - menos valores extremos

# En finanzas usamos "excess kurtosis" = curtosis - 3
# Excess kurtosis = 0: normal
# Excess kurtosis > 0: colas más pesadas que normal
# Excess kurtosis < 0: colas más ligeras que normal

cat("--- CÁLCULO DE CURTOSIS ---\n")
curt_normal <- kurtosis(datos_normales)
curt_pesadas <- kurtosis(datos_colas_pesadas)

cat("Curtosis distribución normal:", round(curt_normal, 3), "\n")
cat("Curtosis colas pesadas:", round(curt_pesadas, 3), "\n")

cat("\n--- EXCESS KURTOSIS ---\n")
excess_curt_normal <- curt_normal - 3
excess_curt_pesadas <- curt_pesadas - 3

cat("Excess curtosis normal:", round(excess_curt_normal, 3), "\n")
cat("Excess curtosis colas pesadas:", round(excess_curt_pesadas, 3), "\n")

cat("\n*** INTERPRETACIÓN EN FINANZAS ***\n")
cat("Curtosis ALTA (> 3): Eventos extremos más frecuentes\n")
cat("  - Más crashes y rallies que lo predicho por distribución normal\n")
cat("  - Mayor riesgo de cola (tail risk)\n")
cat("  - Los modelos que asumen normalidad SUBESTIMAN el riesgo\n\n")

cat("Ejemplo práctico:\n")
cat("Si la distribución normal predice un crash cada 100 años,\n")
cat("una distribución con colas pesadas podría tener crashes cada 10-20 años.\n")

# Visualización
par(mfrow = c(1, 2))

hist(datos_normales, breaks = 30, 
     main = paste("Normal - Curtosis =", round(curt_normal, 2)),
     xlab = "Valor", col = "lightblue", border = "white",
     xlim = c(-5, 5), ylim = c(0, 200))

hist(datos_colas_pesadas, breaks = 30,
     main = paste("Colas Pesadas - Curtosis =", round(curt_pesadas, 2)),
     xlab = "Valor", col = "lightcoral", border = "white",
     xlim = c(-5, 5), ylim = c(0, 200))

par(mfrow = c(1, 1))

cat("\nObserva cómo la distribución con colas pesadas tiene:\n")
cat("- Más observaciones en el centro (pico más alto)\n")
cat("- Más observaciones en los extremos (colas más gruesas)\n")

################################################################################
# PARTE 7: APLICACIÓN CON DATOS REALES - DESCARGAR DATOS
################################################################################

cat("\n\n========== APLICACIÓN CON DATOS REALES DEL MERCADO ==========\n\n")

# Descargar datos del IPC y algunas acciones mexicanas
# NOTA: Ajusta los tickers según lo que funcione en tu sistema

tickers <- c("^MXX",        # IPC (Índice principal)
             "WALMEX.MX",   # Walmart México
             "CEMEXCPO.MX", # Cemex
             "GFNORTEO.MX") # Banorte

# Ajustar si tus tickers no tienen .MX
# tickers <- c("^MXX", "WALMEX", "CEMEXCPO", "GFNORTEO")

fecha_inicio <- "2020-01-01"
fecha_fin <- Sys.Date()

cat("Descargando datos desde", fecha_inicio, "hasta", fecha_fin, "\n")
cat("Tickers:", paste(tickers, collapse = ", "), "\n\n")

# Descargar datos
tryCatch({
  getSymbols(tickers,
             from = fecha_inicio,
             to = fecha_fin,
             src = "yahoo",
             auto.assign = TRUE)
  
  # Combinar precios de cierre
  precios <- merge(Cl(MXX), Cl(WALMEX.MX), Cl(CEMEXCPO.MX), Cl(GFNORTEO.MX))
  colnames(precios) <- c("IPC", "WALMEX", "CEMEX", "BANORTE")
  
  # Eliminar NAs
  precios <- na.omit(precios)
  
  cat("Datos descargados exitosamente!\n")
  cat("Observaciones:", nrow(precios), "\n")
  cat("Periodo:", index(precios)[1], "a", index(tail(precios, 1)), "\n\n")
  
  # Calcular retornos diarios
  retornos <- Return.calculate(precios, method = "discrete")
  retornos <- na.omit(retornos)
  
  cat("Retornos calculados. Primeras observaciones:\n")
  print(head(retornos))
  
}, error = function(e) {
  cat("Error al descargar datos. Mensaje:", e$message, "\n")
  cat("Verifica los tickers y tu conexión a internet.\n")
})

################################################################################
# PARTE 8: ESTADÍSTICAS DESCRIPTIVAS DE RETORNOS REALES
################################################################################

cat("\n\n========== ESTADÍSTICAS DESCRIPTIVAS - DATOS REALES ==========\n\n")

if(exists("retornos")) {
  
  # Calcular todos los momentos para cada activo
  estadisticas <- data.frame(
    Media = apply(retornos, 2, mean) * 252,           # Anualizado
    Volatilidad = apply(retornos, 2, sd) * sqrt(252), # Anualizado
    Asimetria = apply(retornos, 2, skewness),
    Curtosis = apply(retornos, 2, kurtosis),
    Excess_Curtosis = apply(retornos, 2, kurtosis) - 3,
    Min = apply(retornos, 2, min),
    Max = apply(retornos, 2, max)
  )
  
  cat("=== TABLA DE ESTADÍSTICAS DESCRIPTIVAS ===\n")
  print(round(estadisticas, 4))
  
  cat("\n=== INTERPRETACIÓN ===\n\n")
  
  # Analizar cada activo
  for(i in 1:ncol(retornos)) {
    activo <- colnames(retornos)[i]
    cat("---", activo, "---\n")
    cat("Retorno esperado anual:", round(estadisticas$Media[i] * 100, 2), "%\n")
    cat("Volatilidad anual:", round(estadisticas$Volatilidad[i] * 100, 2), "%\n")
    
    # Interpretar asimetría
    if(estadisticas$Asimetria[i] < -0.5) {
      cat("Asimetría NEGATIVA significativa: Mayor riesgo de grandes caídas\n")
    } else if(estadisticas$Asimetria[i] > 0.5) {
      cat("Asimetría POSITIVA significativa: Mayor potencial de grandes ganancias\n")
    } else {
      cat("Asimetría cercana a 0: Distribución relativamente simétrica\n")
    }
    
    # Interpretar curtosis
    if(estadisticas$Excess_Curtosis[i] > 1) {
      cat("Colas PESADAS: Eventos extremos más frecuentes que en distribución normal\n")
    } else if(estadisticas$Excess_Curtosis[i] < -1) {
      cat("Colas LIGERAS: Menos eventos extremos que en distribución normal\n")
    } else {
      cat("Curtosis cercana a la normal\n")
    }
    
    cat("Peor día:", round(estadisticas$Min[i] * 100, 2), "%\n")
    cat("Mejor día:", round(estadisticas$Max[i] * 100, 2), "%\n\n")
  }
  
}

################################################################################
# PARTE 9: VISUALIZACIÓN DE DISTRIBUCIONES
################################################################################

cat("\n========== VISUALIZACIÓN DE DISTRIBUCIONES ==========\n\n")

if(exists("retornos")) {
  
  # Histogramas de cada activo
  par(mfrow = c(2, 2))
  
  for(i in 1:ncol(retornos)) {
    activo <- colnames(retornos)[i]
    
    hist(retornos[, i],
         breaks = 50,
         main = paste("Distribución Retornos -", activo),
         xlab = "Retorno Diario",
         ylab = "Frecuencia",
         col = "lightblue",
         border = "white")
    
    # Agregar línea de media
    abline(v = mean(retornos[, i]), col = "red", lwd = 2, lty = 2)
    
    # Superponer distribución normal teórica
    x <- seq(min(retornos[, i]), max(retornos[, i]), length = 100)
    y <- dnorm(x, mean = mean(retornos[, i]), sd = sd(retornos[, i]))
    y <- y * length(retornos[, i]) * diff(range(retornos[, i])) / 50
    lines(x, y, col = "blue", lwd = 2)
    
    legend("topright",
           legend = c("Media", "Normal teórica"),
           col = c("red", "blue"),
           lty = c(2, 1),
           lwd = 2,
           cex = 0.7)
  }
  
  par(mfrow = c(1, 1))
  
  cat("Las líneas azules muestran cómo se vería una distribución normal.\n")
  cat("Observa las diferencias con la distribución real (histograma).\n")
  
}

################################################################################
# PARTE 10: Q-Q PLOTS (GRÁFICAS CUANTIL-CUANTIL)
################################################################################

cat("\n\n========== Q-Q PLOTS: PRUEBA VISUAL DE NORMALIDAD ==========\n\n")

cat("Los Q-Q plots comparan los cuantiles de los datos con los de una distribución normal.\n")
cat("Si los datos fueran normales, los puntos seguirían la línea recta.\n\n")

if(exists("retornos")) {
  
  par(mfrow = c(2, 2))
  
  for(i in 1:ncol(retornos)) {
    activo <- colnames(retornos)[i]
    
    qqnorm(retornos[, i], 
           main = paste("Q-Q Plot -", activo),
           col = "blue",
           pch = 20)
    qqline(retornos[, i], col = "red", lwd = 2)
  }
  
  par(mfrow = c(1, 1))
  
  cat("INTERPRETACIÓN:\n")
  cat("- Puntos siguen la línea roja → Distribución normal\n")
  cat("- Puntos se desvían en las colas → Colas más pesadas/ligeras que normal\n")
  cat("- Curva S → Asimetría\n\n")
  
}

################################################################################
# PARTE 11: PRUEBAS FORMALES DE NORMALIDAD
################################################################################

cat("\n\n========== PRUEBAS ESTADÍSTICAS DE NORMALIDAD ==========\n\n")

if(exists("retornos")) {
  
  cat("=== JARQUE-BERA TEST ===\n")
  cat("H0: Los datos provienen de una distribución normal\n")
  cat("Si p-value < 0.05, rechazamos H0 (NO son normales)\n\n")
  
  library(tseries)
  
  for(i in 1:ncol(retornos)) {
    activo <- colnames(retornos)[i]
    
    # Test de Jarque-Bera
    jb_test <- jarque.bera.test(as.numeric(retornos[, i]))
    
    cat("---", activo, "---\n")
    cat("Estadístico JB:", round(jb_test$statistic, 4), "\n")
    cat("P-value:", format.pval(jb_test$p.value, digits = 4), "\n")
    
    if(jb_test$p.value < 0.05) {
      cat("Conclusión: RECHAZAMOS normalidad (p < 0.05)\n")
      cat("Los retornos NO siguen una distribución normal\n")
    } else {
      cat("Conclusión: NO rechazamos normalidad (p >= 0.05)\n")
      cat("Los retornos podrían ser normales\n")
    }
    cat("\n")
  }
  
  cat("*** IMPLICACIÓN PRÁCTICA ***\n")
  cat("La mayoría de los retornos financieros NO son normales.\n")
  cat("Tienen colas más pesadas (más eventos extremos).\n")
  cat("Por eso modelos como VaR que asumen normalidad pueden fallar.\n\n")
  
}

################################################################################
# PARTE 12: SERIES DE TIEMPO - VISUALIZACIÓN
################################################################################

cat("\n\n========== VISUALIZACIÓN DE SERIES TEMPORALES ==========\n\n")

if(exists("precios")) {
  
  # Gráfica de precios normalizados (base 100)
  cat("Normalizando precios a base 100 para comparación...\n")
  
  precios_norm <- precios / as.numeric(precios[1, ]) * 100
  
  # Gráfica con ggplot2
  precios_df <- data.frame(
    Fecha = index(precios_norm),
    IPC = as.numeric(precios_norm$IPC),
    WALMEX = as.numeric(precios_norm$WALMEX),
    CEMEX = as.numeric(precios_norm$CEMEX),
    BANORTE = as.numeric(precios_norm$BANORTE)
  )
  
  # Convertir a formato largo
  precios_long <- precios_df %>%
    pivot_longer(cols = -Fecha, names_to = "Activo", values_to = "Precio_Normalizado")
  
  # Gráfica
  p1 <- ggplot(precios_long, aes(x = Fecha, y = Precio_Normalizado, color = Activo)) +
    geom_line(linewidth = 1) +
    labs(title = "Evolución de Precios (Base 100)",
         subtitle = paste("Periodo:", fecha_inicio, "a", fecha_fin),
         x = "Fecha",
         y = "Precio Normalizado (Base 100)",
         color = "Activo") +
    theme_minimal() +
    theme(legend.position = "bottom")
  
  print(p1)
  
  cat("\n¿Qué activo tuvo mejor desempeño en el periodo?\n")
  valores_finales <- as.numeric(tail(precios_norm, 1))
  mejor_activo <- colnames(precios_norm)[which.max(valores_finales)]
  cat("Mejor desempeño:", mejor_activo, 
      "con", round(valores_finales[which.max(valores_finales)] - 100, 2), "% de ganancia\n")
  
}

################################################################################
# PARTE 13: VOLATILIDAD EN EL TIEMPO (ROLLING VOLATILITY)
################################################################################

cat("\n\n========== VOLATILIDAD RODANTE (ROLLING VOLATILITY) ==========\n\n")

if(exists("retornos")) {
  
  cat("Calculando volatilidad en ventana móvil de 30 días...\n")
  
  # Calcular volatilidad rodante
  ventana <- 30
  
  vol_rodante <- rollapply(retornos, 
                           width = ventana,
                           FUN = function(x) sd(x) * sqrt(252),
                           by.column = TRUE,
                           fill = NA,
                           align = "right")
  
  vol_rodante <- na.omit(vol_rodante)
  
  # Convertir a data frame
  vol_df <- data.frame(
    Fecha = index(vol_rodante),
    IPC = as.numeric(vol_rodante$IPC),
    WALMEX = as.numeric(vol_rodante$WALMEX),
    CEMEX = as.numeric(vol_rodante$CEMEX),
    BANORTE = as.numeric(vol_rodante$BANORTE)
  )
  
  vol_long <- vol_df %>%
    pivot_longer(cols = -Fecha, names_to = "Activo", values_to = "Volatilidad")
  
  # Gráfica
  p2 <- ggplot(vol_long, aes(x = Fecha, y = Volatilidad, color = Activo)) +
    geom_line(linewidth = 1) +
    labs(title = "Volatilidad Anualizada Rodante (30 días)",
         x = "Fecha",
         y = "Volatilidad Anualizada",
         color = "Activo") +
    scale_y_continuous(labels = scales::percent) +
    theme_minimal() +
    theme(legend.position = "bottom")
  
  print(p2)
  
  cat("\n*** OBSERVACIONES IMPORTANTES ***\n")
  cat("- La volatilidad NO es constante en el tiempo\n")
  cat("- Aumenta durante crisis (clustering de volatilidad)\n")
  cat("- Periodos de alta volatilidad tienden a agruparse\n")
  cat("- Esto viola el supuesto de muchos modelos financieros\n\n")
  
}

################################################################################
# PARTE 14: RETORNOS ACUMULADOS Y DRAWDOWNS
################################################################################

cat("\n\n========== RETORNOS ACUMULADOS Y DRAWDOWNS ==========\n\n")

if(exists("retornos")) {
  
  # Calcular retornos acumulados
  retornos_acum <- cumprod(1 + retornos) - 1
  
  # Gráfica de retornos acumulados
  ret_acum_df <- data.frame(
    Fecha = index(retornos_acum),
    IPC = as.numeric(retornos_acum$IPC),
    WALMEX = as.numeric(retornos_acum$WALMEX),
    CEMEX = as.numeric(retornos_acum$CEMEX),
    BANORTE = as.numeric(retornos_acum$BANORTE)
  )
  
  ret_acum_long <- ret_acum_df %>%
    pivot_longer(cols = -Fecha, names_to = "Activo", values_to = "Retorno_Acumulado")
  
  p3 <- ggplot(ret_acum_long, aes(x = Fecha, y = Retorno_Acumulado, color = Activo)) +
    geom_line(linewidth = 1) +
    labs(title = "Retornos Acumulados",
         x = "Fecha",
         y = "Retorno Acumulado",
         color = "Activo") +
    scale_y_continuous(labels = scales::percent) +
    theme_minimal() +
    theme(legend.position = "bottom")
  
  print(p3)
  
  # Calcular drawdowns (caídas desde máximos históricos)
  cat("\n--- DRAWDOWNS (Caídas desde máximos) ---\n")
  
  for(i in 1:ncol(retornos_acum)) {
    activo <- colnames(retornos_acum)[i]
    
    # Calcular wealth index
    wealth <- cumprod(1 + retornos[, i])
    
    # Máximo acumulado
    max_acum <- cummax(wealth)
    
    # Drawdown
    drawdown <- (wealth - max_acum) / max_acum
    
    # Máximo drawdown
    max_dd <- min(drawdown)
    
    cat(activo, "- Máximo Drawdown:", round(max_dd * 100, 2), "%\n")
  }
  
  cat("\nEl drawdown mide la peor caída desde un máximo histórico.\n")
  cat("Es una medida importante de riesgo para inversionistas.\n")
  
}

################################################################################
# EJERCICIOS PARA LOS ESTUDIANTES
################################################################################

cat("\n\n")
cat("================================================================================\n")
cat("                         EJERCICIOS PARA PRÁCTICA\n")
cat("================================================================================\n\n")

cat("EJERCICIO 1: CÁLCULO DE MOMENTOS\n")
cat("--------------------------------\n")
cat("Genera 1000 observaciones de una distribución t-Student con 5 grados de libertad:\n")
cat("datos <- rt(1000, df = 5)\n\n")
cat("a) Calcula la media, desviación estándar, asimetría y curtosis\n")
cat("b) Crea un histograma con la media marcada en rojo\n")
cat("c) ¿La distribución tiene colas más pesadas que la normal? (curtosis > 3?)\n")
cat("d) ¿Es simétrica? (asimetría cercana a 0?)\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 2: COMPARACIÓN DE DISTRIBUCIONES\n")
cat("-------------------------------------------\n")
cat("Genera tres conjuntos de datos:\n")
cat("  normal <- rnorm(1000, mean = 0.05, sd = 0.15)\n")
cat("  lognormal <- rlnorm(1000, meanlog = -0.5, sdlog = 0.5) - 1\n")
cat("  uniforme <- runif(1000, min = -0.2, max = 0.2)\n\n")
cat("a) Calcula los 4 momentos de cada distribución\n")
cat("b) Crea histogramas lado a lado (usa par(mfrow = c(1,3)))\n")
cat("c) ¿Cuál tiene mayor asimetría?\n")
cat("d) ¿Cuál tiene colas más pesadas?\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 3: ANÁLISIS DE UN ACTIVO REAL\n")
cat("----------------------------------------\n")
cat("Descarga datos de una acción mexicana de tu elección para los últimos 5 años:\n\n")
cat("a) Descarga los datos y calcula retornos diarios\n")
cat("b) Calcula todos los momentos estadísticos (media, vol, skew, curtosis)\n")
cat("c) Crea un histograma y un Q-Q plot\n")
cat("d) Realiza el test de Jarque-Bera\n")
cat("e) Escribe una interpretación: ¿Son los retornos normales?\n")
cat("   Si no, ¿qué características tienen? (asimetría, colas pesadas, etc.)\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 4: COMPARACIÓN IPC vs ACCIÓN INDIVIDUAL\n")
cat("--------------------------------------------------\n")
cat("Descarga datos del IPC (^MXX) y una acción individual para 2020-2024:\n\n")
cat("a) Calcula retornos de ambos\n")
cat("b) Compara los 4 momentos en una tabla\n")
cat("c) ¿Cuál es más volátil?\n")
cat("d) ¿Cuál tiene mayor asimetría negativa (más riesgo de caídas)?\n")
cat("e) Crea gráficas lado a lado: histogramas y Q-Q plots\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 5: EVENTOS EXTREMOS\n")
cat("------------------------------\n")
cat("Usando retornos del IPC de los últimos 5 años:\n\n")
cat("a) Identifica los 10 peores días (mayores caídas)\n")
cat("   Pista: usa sort() o order()\n")
cat("b) Identifica los 10 mejores días (mayores subidas)\n")
cat("c) ¿Qué porcentaje de retornos están más allá de ±2 desviaciones estándar?\n")
cat("   (En distribución normal deberían ser ~5%)\n")
cat("d) ¿Qué porcentaje están más allá de ±3 desviaciones estándar?\n")
cat("   (En distribución normal deberían ser ~0.3%)\n")
cat("e) ¿Hay más eventos extremos de lo que predice la distribución normal?\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 6: VOLATILIDAD RODANTE\n")
cat("---------------------------------\n")
cat("Descarga datos de 2 activos mexicanos correlacionados (ej: bancos):\n\n")
cat("a) Calcula volatilidad rodante de 20 días para ambos\n")
cat("b) Grafica ambas volatilidades en la misma gráfica\n")
cat("c) ¿Se mueven juntas? (clustering de volatilidad)\n")
cat("d) Identifica periodos de alta volatilidad\n")
cat("e) ¿Puedes relacionarlos con eventos económicos? (COVID, elecciones, etc.)\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 7: DRAWDOWNS Y RECUPERACIÓN\n")
cat("--------------------------------------\n")
cat("Analiza un activo mexicano durante un periodo que incluya COVID (2019-2024):\n\n")
cat("a) Calcula el wealth index: cumprod(1 + retornos)\n")
cat("b) Calcula el máximo acumulado: cummax(wealth)\n")
cat("c) Calcula el drawdown: (wealth - max_acum) / max_acum\n")
cat("d) Grafica el drawdown en el tiempo\n")
cat("e) ¿Cuál fue el máximo drawdown? ¿Cuándo ocurrió?\n")
cat("f) ¿Cuánto tiempo tomó recuperarse del peor drawdown?\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\n")
cat("================================================================================\n")
cat("             FIN DE LA SESIÓN 3 - ESTADÍSTICA DESCRIPTIVA\n")
cat("================================================================================\n")
cat("\n")
cat("RECORDATORIOS:\n")
cat("- Los retornos financieros NO son normales (colas pesadas, asimetría)\n")
cat("- Esto tiene implicaciones importantes para modelos de riesgo\n")
cat("- La volatilidad NO es constante (clustering)\n")
cat("- Eventos extremos ocurren más frecuentemente de lo predicho por normalidad\n")
cat("\n")
cat("PRÓXIMA SESIÓN: Teoría de Portafolios - Markowitz\n")
cat("Usaremos estos conceptos estadísticos para construir portafolios óptimos.\n")
cat("\n")

################################################################################
# FIN DEL SCRIPT
################################################################################
