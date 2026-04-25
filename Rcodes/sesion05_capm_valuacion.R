################################################################################
# MERCADOS DE CAPITALES
# SESIÓN 5: CAPM, Valuación Fundamental y Modelos Factoriales
#
# Profesor: Ismael Valverde
# Facultad de Economía, UNAM
#
# CONTENIDO DE LA SESIÓN:
# 1. Revisión de ejercicios Sesión 4
# 2. Capital Asset Pricing Model (CAPM)
# 3. Beta: medida de riesgo sistemático
# 4. Security Market Line (SML)
# 5. Valuación fundamental: Modelo de Descuento de Dividendos (DDM)
# 6. Valuación por múltiplos (P/E, P/B, EV/EBITDA)
# 7. Modelo de Fama-French de 3 factores
# 8. Aplicación con datos reales de la BMV
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
library(ggplot2)
library(lmtest)        # Para pruebas de regresión
library(sandwich)      # Para errores robustos

cat("Librerías cargadas exitosamente!\n")
cat("Sesión 5: CAPM, Valuación y Modelos Factoriales\n\n")

################################################################################
# PARTE 2: CAPITAL ASSET PRICING MODEL (CAPM) - INTRODUCCIÓN
################################################################################

cat("========== CAPITAL ASSET PRICING MODEL (CAPM) ==========\n\n")

cat("*** WILLIAM SHARPE (1964) ***\n")
cat("Premio Nobel de Economía 1990\n")
cat("'Capital Asset Prices: A Theory of Market Equilibrium'\n\n")

cat("PREGUNTA FUNDAMENTAL:\n")
cat("Si TODOS los inversionistas usan la teoría de Markowitz,\n")
cat("¿qué pasa en EQUILIBRIO?\n\n")

cat("SUPUESTOS DEL CAPM:\n")
cat("1. Todos los inversionistas tienen las MISMAS expectativas (μ, σ, ρ)\n")
cat("2. Todos pueden prestar/pedir prestado a la tasa libre de riesgo\n")
cat("3. No hay impuestos ni costos de transacción\n")
cat("4. Los activos son infinitamente divisibles\n")
cat("5. Todos los inversionistas son aversos al riesgo y usan media-varianza\n")
cat("6. El mercado está en equilibrio\n\n")

cat("RESULTADO PRINCIPAL:\n")
cat("En equilibrio, TODOS los inversionistas tendrán el MISMO portafolio riesgoso:\n")
cat("¡El PORTAFOLIO DE MERCADO!\n\n")

cat("ECUACIÓN DEL CAPM:\n")
cat("E(R_i) = R_f + β_i × [E(R_m) - R_f]\n\n")

cat("Donde:\n")
cat("E(R_i) = Retorno esperado del activo i\n")
cat("R_f = Tasa libre de riesgo\n")
cat("β_i = Beta del activo i (riesgo sistemático)\n")
cat("E(R_m) = Retorno esperado del mercado\n")
cat("[E(R_m) - R_f] = Prima de riesgo de mercado\n\n")

################################################################################
# PARTE 3: BETA - RIESGO SISTEMÁTICO VS NO SISTEMÁTICO
################################################################################

cat("\n========== BETA: RIESGO SISTEMÁTICO ==========\n\n")

cat("TEORÍA:\n")
cat("Riesgo Total = Riesgo Sistemático + Riesgo No Sistemático\n\n")

cat("RIESGO SISTEMÁTICO (medido por Beta):\n")
cat("- No se puede eliminar con diversificación\n")
cat("- Afecta a TODO el mercado\n")
cat("- Ejemplos: recesión, inflación, tasas de interés, guerra\n")
cat("- El mercado COMPENSA este riesgo con mayor retorno\n\n")

cat("RIESGO NO SISTEMÁTICO (idiosincrático):\n")
cat("- Se PUEDE eliminar con diversificación\n")
cat("- Específico de la empresa\n")
cat("- Ejemplos: huelga, cambio de CEO, demanda legal\n")
cat("- El mercado NO compensa este riesgo (deberías diversificar)\n\n")

cat("BETA:\n")
cat("β = Cov(R_i, R_m) / Var(R_m)\n\n")

cat("Interpretación:\n")
cat("β = 1.0: El activo se mueve igual que el mercado\n")
cat("β > 1.0: El activo es MÁS volátil que el mercado (agresivo)\n")
cat("β < 1.0: El activo es MENOS volátil que el mercado (defensivo)\n")
cat("β = 0.0: El activo no se correlaciona con el mercado\n")
cat("β < 0.0: El activo se mueve OPUESTO al mercado (cobertura)\n\n")

cat("Ejemplos típicos:\n")
cat("- Empresas tecnológicas: β ≈ 1.3 - 1.5\n")
cat("- Empresas de utilities: β ≈ 0.6 - 0.8\n")
cat("- Bancos: β ≈ 1.1 - 1.3\n")
cat("- Oro: β ≈ 0 o negativo\n\n")

################################################################################
# PARTE 4: ESTIMACIÓN DE BETA CON REGRESIÓN
################################################################################

cat("\n========== ESTIMACIÓN DE BETA ==========\n\n")

# Descargar datos del mercado (IPC) y una acción
ticker_accion <- "WALMEX.MX"
ticker_mercado <- "^MXX"

fecha_inicio <- "2020-01-01"
fecha_fin <- Sys.Date()

cat("Descargando datos de:", ticker_accion, "y", ticker_mercado, "\n")
cat("Periodo:", fecha_inicio, "a", fecha_fin, "\n\n")

tryCatch({
  # Descargar datos
  getSymbols(c(ticker_accion, ticker_mercado),
             from = fecha_inicio,
             to = fecha_fin,
             src = "yahoo",
             auto.assign = TRUE)
  
  # Extraer precios de cierre
  precio_accion <- Cl(get(gsub("\\.MX", ".MX", ticker_accion)))
  precio_mercado <- Cl(MXX)
  
  # Combinar
  precios <- merge(precio_accion, precio_mercado)
  colnames(precios) <- c("Accion", "Mercado")
  precios <- na.omit(precios)
  
  # Calcular retornos
  retornos <- Return.calculate(precios, method = "discrete")
  retornos <- na.omit(retornos)
  
  cat("Datos descargados exitosamente!\n")
  cat("Observaciones:", nrow(retornos), "\n\n")
  
  # Modelo de regresión: R_i = α + β × R_m + ε
  modelo_capm <- lm(Accion ~ Mercado, data = retornos)
  
  cat("=== REGRESIÓN CAPM ===\n")
  print(summary(modelo_capm))
  
  # Extraer coeficientes
  alpha <- coef(modelo_capm)[1]
  beta <- coef(modelo_capm)[2]
  
  cat("\n=== RESULTADOS ===\n")
  cat("Alpha (intercepto):", round(alpha * 252 * 100, 2), "% anual\n")
  cat("Beta (pendiente):", round(beta, 3), "\n")
  
  # R-cuadrado
  r_cuadrado <- summary(modelo_capm)$r.squared
  cat("R² (bondad de ajuste):", round(r_cuadrado, 3), "\n\n")
  
  cat("*** INTERPRETACIÓN ***\n")
  cat("Beta =", round(beta, 2), "\n")
  
  if(beta > 1.1) {
    cat("→ Acción AGRESIVA: se mueve MÁS que el mercado\n")
    cat("  Si el mercado sube 10%, esta acción subiría ~", round(beta * 10, 1), "%\n")
  } else if(beta < 0.9) {
    cat("→ Acción DEFENSIVA: se mueve MENOS que el mercado\n")
    cat("  Si el mercado sube 10%, esta acción subiría ~", round(beta * 10, 1), "%\n")
  } else {
    cat("→ Acción NEUTRAL: se mueve similar al mercado\n")
  }
  
  cat("\nAlpha =", round(alpha * 252 * 100, 2), "%\n")
  
  if(abs(alpha * 252) > 0.05) {
    if(alpha > 0) {
      cat("→ Alpha POSITIVO: la acción supera al modelo CAPM\n")
      cat("  Posible oportunidad o el modelo no captura todo el riesgo\n")
    } else {
      cat("→ Alpha NEGATIVO: la acción está por debajo del modelo CAPM\n")
      cat("  Posible mal desempeño o el modelo no captura todo el riesgo\n")
    }
  } else {
    cat("→ Alpha cercano a CERO: consistente con CAPM\n")
  }
  
  cat("\nR² =", round(r_cuadrado, 3), "\n")
  cat("→", round(r_cuadrado * 100, 1), "% de la varianza de la acción\n")
  cat("  se explica por movimientos del mercado\n")
  cat("→", round((1 - r_cuadrado) * 100, 1), "% es riesgo específico (diversificable)\n\n")
  
  # Gráfica de la regresión
  plot(retornos$Mercado * 100, retornos$Accion * 100,
       pch = 20,
       col = rgb(0, 0, 1, 0.3),
       xlab = "Retorno del Mercado (IPC) %",
       ylab = paste("Retorno de", ticker_accion, "%"),
       main = "Modelo CAPM: Línea Característica")
  
  # Línea de regresión
  abline(modelo_capm$coefficients[1] * 100,
         modelo_capm$coefficients[2],
         col = "red",
         lwd = 2)
  
  # Línea de referencia (β = 1)
  abline(0, 1, col = "gray", lwd = 1, lty = 2)
  
  legend("topleft",
         legend = c(paste("Beta =", round(beta, 2)),
                   paste("Alpha =", round(alpha * 252 * 100, 2), "%"),
                   "β = 1 (referencia)"),
         col = c("red", "red", "gray"),
         lty = c(1, NA, 2),
         lwd = c(2, NA, 1),
         pch = c(NA, NA, NA))
  
  grid()
  
}, error = function(e) {
  cat("Error al descargar datos:", e$message, "\n")
})

################################################################################
# PARTE 5: SECURITY MARKET LINE (SML)
################################################################################

cat("\n\n========== SECURITY MARKET LINE (SML) ==========\n\n")

cat("La SML grafica la relación entre Beta y Retorno Esperado según CAPM.\n\n")

if(exists("beta")) {
  
  # Parámetros del mercado (ejemplos)
  rf <- 0.08        # Tasa libre de riesgo (ej: Cetes 8%)
  r_mercado <- 0.14  # Retorno esperado del mercado (14%)
  prima_mercado <- r_mercado - rf  # Prima de riesgo
  
  cat("Parámetros del mercado:\n")
  cat("Tasa libre de riesgo (rf):", rf * 100, "%\n")
  cat("Retorno esperado del mercado:", r_mercado * 100, "%\n")
  cat("Prima de riesgo de mercado:", prima_mercado * 100, "%\n\n")
  
  # Calcular retorno esperado según CAPM
  retorno_esperado_capm <- rf + beta * prima_mercado
  
  cat("Retorno esperado según CAPM:\n")
  cat("E(R) = rf + β × [E(Rm) - rf]\n")
  cat("E(R) =", rf * 100, "% +", round(beta, 2), "×", prima_mercado * 100, "%\n")
  cat("E(R) =", round(retorno_esperado_capm * 100, 2), "%\n\n")
  
  # Retorno realizado (histórico)
  retorno_realizado <- mean(retornos$Accion) * 252
  
  cat("Retorno realizado (histórico):", round(retorno_realizado * 100, 2), "%\n\n")
  
  # Comparación
  diferencia <- retorno_realizado - retorno_esperado_capm
  
  if(abs(diferencia) > 0.02) {
    if(diferencia > 0) {
      cat("La acción SUPERÓ las expectativas del CAPM por",
          round(diferencia * 100, 2), "%\n")
      cat("→ Posible alpha positivo o mala estimación de beta\n")
    } else {
      cat("La acción estuvo POR DEBAJO de las expectativas del CAPM por",
          round(abs(diferencia) * 100, 2), "%\n")
      cat("→ Posible alpha negativo o mala estimación de beta\n")
    }
  } else {
    cat("La acción se comportó consistentemente con CAPM\n")
  }
  
  # Gráfica SML
  betas <- seq(0, 2, 0.1)
  retornos_sml <- rf + betas * prima_mercado
  
  plot(betas, retornos_sml * 100,
       type = "l",
       lwd = 3,
       col = "blue",
       xlab = "Beta (Riesgo Sistemático)",
       ylab = "Retorno Esperado (%)",
       main = "Security Market Line (SML)",
       ylim = c(0, max(retornos_sml) * 110))
  
  # Punto del mercado
  points(1, r_mercado * 100, pch = 19, col = "red", cex = 2)
  text(1, r_mercado * 100, "Mercado\n(β=1)", pos = 4, col = "red")
  
  # Punto de tasa libre de riesgo
  points(0, rf * 100, pch = 19, col = "black", cex = 2)
  text(0, rf * 100, "Rf", pos = 4)
  
  # Punto de la acción
  points(beta, retorno_esperado_capm * 100, pch = 19, col = "green", cex = 2)
  text(beta, retorno_esperado_capm * 100, 
       ticker_accion, pos = 4, col = "green")
  
  # Punto realizado (si difiere)
  if(abs(diferencia) > 0.02) {
    points(beta, retorno_realizado * 100, pch = 4, col = "orange", cex = 2, lwd = 2)
    text(beta, retorno_realizado * 100, "Realizado", pos = 2, col = "orange")
  }
  
  grid()
  
  cat("\n*** LECTURA DE LA SML ***\n")
  cat("Todos los activos 'correctamente valuados' deberían estar en la línea.\n")
  cat("Puntos ARRIBA de la línea: infravaluados (comprar)\n")
  cat("Puntos ABAJO de la línea: sobrevaluados (vender)\n\n")
}

################################################################################
# PARTE 6: VALUACIÓN FUNDAMENTAL - MODELO DE DESCUENTO DE DIVIDENDOS (DDM)
################################################################################

cat("\n\n========== VALUACIÓN FUNDAMENTAL: DIVIDENDOS ==========\n\n")

cat("MODELO DE GORDON (DDM de crecimiento constante):\n")
cat("P₀ = D₁ / (r - g)\n\n")

cat("Donde:\n")
cat("P₀ = Precio justo de la acción HOY\n")
cat("D₁ = Dividendo esperado el próximo año\n")
cat("r = Tasa de descuento (retorno requerido)\n")
cat("g = Tasa de crecimiento perpetuo de dividendos\n\n")

cat("*** EJEMPLO NUMÉRICO ***\n")

# Parámetros de ejemplo
D0 <- 2.50       # Dividendo actual por acción
g <- 0.05        # Crecimiento de 5% anual
r <- 0.12        # Retorno requerido 12%

D1 <- D0 * (1 + g)

precio_justo_ddm <- D1 / (r - g)

cat("Dividendo actual (D₀):", D0, "pesos\n")
cat("Crecimiento esperado (g):", g * 100, "%\n")
cat("Retorno requerido (r):", r * 100, "%\n")
cat("Dividendo próximo año (D₁):", round(D1, 2), "pesos\n\n")

cat("Precio justo según DDM:\n")
cat("P₀ = D₁ / (r - g)\n")
cat("P₀ =", round(D1, 2), "/ (", r, "-", g, ")\n")
cat("P₀ =", round(D1, 2), "/", r - g, "\n")
cat("P₀ =", round(precio_justo_ddm, 2), "pesos\n\n")

cat("*** INTERPRETACIÓN ***\n")
cat("Si el precio de mercado es < ", round(precio_justo_ddm, 2), 
    " → INFRAVALUADA (comprar)\n")
cat("Si el precio de mercado es > ", round(precio_justo_ddm, 2), 
    " → SOBREVALUADA (vender)\n\n")

cat("LIMITACIONES DEL DDM:\n")
cat("1. Solo funciona para empresas que pagan dividendos estables\n")
cat("2. Asume crecimiento constante perpetuo (poco realista)\n")
cat("3. Muy sensible a los parámetros (r y g)\n")
cat("4. No funciona si g >= r (división por cero o negativo)\n\n")

# Análisis de sensibilidad
cat("=== ANÁLISIS DE SENSIBILIDAD ===\n")

tasas_g <- seq(0.02, 0.10, 0.01)
precios_ddm <- D0 * (1 + tasas_g) / (r - tasas_g)

plot(tasas_g * 100, precios_ddm,
     type = "l",
     lwd = 2,
     col = "blue",
     xlab = "Tasa de Crecimiento g (%)",
     ylab = "Precio Justo (pesos)",
     main = "Sensibilidad del DDM a la Tasa de Crecimiento")

abline(v = g * 100, col = "red", lty = 2)
abline(h = precio_justo_ddm, col = "red", lty = 2)

grid()

cat("\nEl precio es MUY SENSIBLE al supuesto de crecimiento.\n")
cat("Un pequeño cambio en 'g' puede cambiar dramáticamente la valuación.\n\n")

################################################################################
# PARTE 7: VALUACIÓN POR MÚLTIPLOS
################################################################################

cat("\n========== VALUACIÓN POR MÚLTIPLOS ==========\n\n")

cat("En lugar de modelos de descuento, comparamos con empresas similares.\n\n")

cat("MÚLTIPLOS COMUNES:\n\n")

cat("1. P/E (Price-to-Earnings):\n")
cat("   P/E = Precio por Acción / Utilidad por Acción\n")
cat("   Interpretación: ¿Cuánto paga el mercado por cada peso de utilidades?\n")
cat("   Típico: 10-20 (depende del sector y país)\n\n")

cat("2. P/B (Price-to-Book):\n")
cat("   P/B = Precio por Acción / Valor en Libros por Acción\n")
cat("   Interpretación: ¿Precio vs valor contable?\n")
cat("   P/B < 1: posiblemente infravalorada\n")
cat("   P/B > 1: el mercado valora más que el valor contable\n\n")

cat("3. EV/EBITDA (Enterprise Value / EBITDA):\n")
cat("   Más completo que P/E porque incluye deuda\n")
cat("   Típico: 8-12\n\n")

cat("4. P/S (Price-to-Sales):\n")
cat("   Útil para empresas sin utilidades (startups, crecimiento)\n\n")

# Ejemplo numérico
cat("*** EJEMPLO: VALUACIÓN COMPARATIVA ***\n\n")

valuacion <- data.frame(
  Empresa = c("Nuestra Empresa", "Competidor A", "Competidor B", "Competidor C"),
  Precio = c(NA, 45, 52, 38),
  UPA = c(5.2, 4.8, 5.5, 4.2),
  VL_Accion = c(32, 28, 35, 25),
  EBITDA = c(12, 10, 13, 9)
)

# Calcular P/E de competidores
valuacion$PE <- valuacion$Precio / valuacion$UPA
valuacion$PB <- valuacion$Precio / valuacion$VL_Accion

cat("Tabla de comparación:\n")
print(valuacion[, c("Empresa", "Precio", "UPA", "PE", "PB")])

# P/E promedio de competidores
pe_promedio <- mean(valuacion$PE[2:4], na.rm = TRUE)
pb_promedio <- mean(valuacion$PB[2:4], na.rm = TRUE)

cat("\nP/E promedio de competidores:", round(pe_promedio, 2), "\n")
cat("P/B promedio de competidores:", round(pb_promedio, 2), "\n\n")

# Valuación implícita
precio_implícito_pe <- valuacion$UPA[1] * pe_promedio
precio_implícito_pb <- valuacion$VL_Accion[1] * pb_promedio

cat("=== VALUACIÓN IMPLÍCITA ===\n")
cat("Por P/E: Precio justo =", round(precio_implícito_pe, 2), "pesos\n")
cat("Por P/B: Precio justo =", round(precio_implícito_pb, 2), "pesos\n")
cat("Promedio:", round((precio_implícito_pe + precio_implícito_pb) / 2, 2), "pesos\n\n")

cat("VENTAJAS de valuación por múltiplos:\n")
cat("+ Simple y rápida\n")
cat("+ Basada en comparables reales del mercado\n")
cat("+ No requiere proyecciones complejas\n\n")

cat("LIMITACIONES:\n")
cat("- Empresas comparables pueden no ser verdaderamente similares\n")
cat("- Si todo el sector está mal valuado, el múltiplo también\n")
cat("- No captura potencial de crecimiento único\n\n")

################################################################################
# PARTE 8: MODELO DE FAMA-FRENCH (3 FACTORES)
################################################################################

cat("\n========== MODELO DE FAMA-FRENCH ==========\n\n")

cat("*** EUGENE FAMA & KENNETH FRENCH (1992) ***\n")
cat("Fama: Premio Nobel 2013\n\n")

cat("PROBLEMA CON CAPM:\n")
cat("El CAPM solo usa UN factor: el mercado (beta).\n")
cat("Pero empíricamente, otros factores también explican retornos:\n")
cat("1. Tamaño de la empresa (SMB: Small Minus Big)\n")
cat("2. Valor vs Crecimiento (HML: High Minus Low)\n\n")

cat("MODELO DE 3 FACTORES:\n")
cat("R_i - R_f = α + β_m(R_m - R_f) + β_s×SMB + β_v×HML + ε\n\n")

cat("Donde:\n")
cat("β_m = Sensibilidad al factor de mercado (como en CAPM)\n")
cat("β_s = Sensibilidad al factor de tamaño (SMB)\n")
cat("β_v = Sensibilidad al factor de valor (HML)\n")
cat("SMB = Retorno de small caps - retorno de large caps\n")
cat("HML = Retorno de value stocks - retorno de growth stocks\n\n")

cat("HALLAZGOS EMPÍRICOS:\n")
cat("1. Empresas PEQUEÑAS tienden a tener mayores retornos\n")
cat("2. Empresas de VALOR (P/B bajo) superan a empresas de CRECIMIENTO\n")
cat("3. Estos factores explican MEJOR los retornos que CAPM solo\n\n")

cat("*** EJEMPLO CONCEPTUAL ***\n")
cat("Empresa pequeña (small cap) con P/B bajo (value):\n")
cat("- β_mercado = 1.2 (más volátil que mercado)\n")
cat("- β_SMB = 0.8 (positivo: es pequeña)\n")
cat("- β_HML = 0.6 (positivo: es value)\n")
cat("→ Retorno esperado MAYOR que lo predicho por CAPM\n\n")

cat("NOTA: Para México, los factores Fama-French no están tan disponibles.\n")
cat("En EE.UU. están en la biblioteca de Kenneth French (online).\n")
cat("Para análisis serio en México, habría que construir los factores.\n\n")

################################################################################
# PARTE 9: ESTIMACIÓN DE BETAS PARA MÚLTIPLES ACCIONES
################################################################################

cat("\n========== BETAS DE MÚLTIPLES ACCIONES MEXICANAS ==========\n\n")

# Lista de acciones mexicanas
tickers_acciones <- c("WALMEX.MX", "CEMEXCPO.MX", "GFNORTEO.MX", "FEMSAUBD.MX")

cat("Estimando betas para:", paste(tickers_acciones, collapse = ", "), "\n\n")

tryCatch({
  # Descargar datos
  getSymbols(c(tickers_acciones, "^MXX"),
             from = "2020-01-01",
             to = Sys.Date(),
             src = "yahoo",
             auto.assign = TRUE)
  
  # Combinar precios
  precios_multi <- merge(Cl(WALMEX.MX), Cl(CEMEXCPO.MX), 
                         Cl(GFNORTEO.MX), Cl(FEMSAUBD.MX),
                         Cl(MXX))
  
  colnames(precios_multi) <- c("WALMEX", "CEMEX", "BANORTE", "FEMSA", "IPC")
  precios_multi <- na.omit(precios_multi)
  
  # Retornos
  retornos_multi <- Return.calculate(precios_multi)
  retornos_multi <- na.omit(retornos_multi)
  
  # Estimar beta para cada acción
  resultados_beta <- data.frame(
    Accion = character(),
    Beta = numeric(),
    Alpha_Anual = numeric(),
    R_cuadrado = numeric(),
    stringsAsFactors = FALSE
  )
  
  for(i in 1:(ncol(retornos_multi) - 1)) {
    accion <- colnames(retornos_multi)[i]
    
    # Regresión
    modelo <- lm(retornos_multi[, i] ~ retornos_multi$IPC)
    
    # Extraer resultados
    beta_est <- coef(modelo)[2]
    alpha_est <- coef(modelo)[1] * 252  # Anualizado
    r2 <- summary(modelo)$r.squared
    
    resultados_beta <- rbind(resultados_beta,
                            data.frame(Accion = accion,
                                      Beta = beta_est,
                                      Alpha_Anual = alpha_est,
                                      R_cuadrado = r2))
  }
  
  cat("=== TABLA DE BETAS ===\n")
  print(resultados_beta)
  
  cat("\n*** ANÁLISIS ***\n")
  
  # Identificar más agresiva y más defensiva
  idx_max_beta <- which.max(resultados_beta$Beta)
  idx_min_beta <- which.min(resultados_beta$Beta)
  
  cat("\nAcción más AGRESIVA:", resultados_beta$Accion[idx_max_beta], 
      "con beta =", round(resultados_beta$Beta[idx_max_beta], 2), "\n")
  cat("Acción más DEFENSIVA:", resultados_beta$Accion[idx_min_beta], 
      "con beta =", round(resultados_beta$Beta[idx_min_beta], 2), "\n\n")
  
  # Gráfica de betas
  barplot(resultados_beta$Beta,
          names.arg = resultados_beta$Accion,
          col = ifelse(resultados_beta$Beta > 1, "red", "green"),
          main = "Betas de Acciones Mexicanas",
          ylab = "Beta",
          ylim = c(0, max(resultados_beta$Beta) * 1.2))
  
  abline(h = 1, col = "blue", lwd = 2, lty = 2)
  text(2, 1.05, "Beta del Mercado = 1", col = "blue")
  
  grid()
  
  cat("Interpretación de colores:\n")
  cat("ROJO: Beta > 1 (agresiva)\n")
  cat("VERDE: Beta < 1 (defensiva)\n\n")
  
}, error = function(e) {
  cat("Error:", e$message, "\n")
})

################################################################################
# EJERCICIOS PARA LOS ESTUDIANTES
################################################################################

cat("\n\n")
cat("================================================================================\n")
cat("                         EJERCICIOS PARA PRÁCTICA\n")
cat("================================================================================\n\n")

cat("EJERCICIO 1: ESTIMACIÓN DE BETA\n")
cat("--------------------------------\n")
cat("Descarga datos de una acción mexicana y el IPC (últimos 3 años):\n\n")
cat("a) Calcula retornos mensuales (no diarios)\n")
cat("b) Estima beta usando regresión lineal\n")
cat("c) Interpreta el beta: ¿agresiva o defensiva?\n")
cat("d) ¿Qué porcentaje de la varianza explica el mercado? (R²)\n")
cat("e) Crea la gráfica de dispersión con línea de regresión\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 2: ALPHA Y DESEMPEÑO\n")
cat("-------------------------------\n")
cat("Usando la misma acción del Ejercicio 1:\n\n")
cat("a) Extrae el alpha de la regresión\n")
cat("b) Anualiza el alpha\n")
cat("c) ¿Es estadísticamente significativo? (mira el p-value)\n")
cat("d) Si alpha > 0, ¿qué significa?\n")
cat("e) ¿Esta acción 'le ganó al mercado'?\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 3: SECURITY MARKET LINE\n")
cat("----------------------------------\n")
cat("Estima betas para 5 acciones mexicanas diferentes:\n\n")
cat("a) Crea una tabla con: Acción, Beta, Retorno Promedio\n")
cat("b) Grafica SML (beta en x, retorno en y)\n")
cat("c) Marca los 5 puntos en la gráfica\n")
cat("d) ¿Alguna acción está muy arriba/abajo de la línea?\n")
cat("e) Según SML, ¿cuál parece infravalorada?\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 4: MODELO DE DESCUENTO DE DIVIDENDOS\n")
cat("-----------------------------------------------\n")
cat("Investiga una empresa mexicana que pague dividendos estables:\n\n")
cat("a) Encuentra el dividendo por acción del último año\n")
cat("b) Estima una tasa de crecimiento razonable (ej: inflación + 2%)\n")
cat("c) Calcula el retorno requerido usando CAPM (estima beta primero)\n")
cat("d) Aplica el modelo de Gordon: P = D₁/(r-g)\n")
cat("e) Compara con el precio de mercado actual\n")
cat("f) ¿Está infravalorada o sobrevalorada según DDM?\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 5: VALUACIÓN POR MÚLTIPLOS\n")
cat("-------------------------------------\n")
cat("Selecciona un sector (ej: bancos, retail, telecomunicaciones):\n\n")
cat("a) Encuentra P/E de 4-5 empresas del sector (usa Yahoo Finance)\n")
cat("b) Calcula el P/E promedio del sector\n")
cat("c) Identifica la empresa con P/E más bajo\n")
cat("d) ¿El P/E bajo indica infravaloración o hay otros factores?\n")
cat("e) Repite con P/B y compara conclusiones\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 6: COMPARACIÓN CAPM VS REALIZADO\n")
cat("-------------------------------------------\n")
cat("Para una acción mexicana (2020-2024):\n\n")
cat("a) Estima beta usando datos 2020-2022\n")
cat("b) Calcula retorno esperado según CAPM para 2023-2024\n")
cat("   (usa rf ≈ 8%, prima de mercado ≈ 6%)\n")
cat("c) Calcula retorno REALIZADO en 2023-2024\n")
cat("d) Compara esperado vs realizado\n")
cat("e) ¿El CAPM predijo bien? ¿Por qué sí o no?\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 7: BETAS POR SECTOR\n")
cat("------------------------------\n")
cat("Estima betas para acciones de diferentes sectores:\n")
cat("- Financiero: GFNORTEO.MX\n")
cat("- Retail: WALMEX.MX\n")
cat("- Materiales: CEMEXCPO.MX\n")
cat("- Consumo: FEMSAUBD.MX\n\n")
cat("a) Calcula beta de cada una\n")
cat("b) ¿Qué sector tiene betas más altas? ¿Por qué?\n")
cat("c) ¿Qué sector es más defensivo?\n")
cat("d) En una recesión, ¿qué sector preferirías?\n")
cat("e) En expansión económica, ¿cuál?\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\n")
cat("================================================================================\n")
cat("              FIN DE LA SESIÓN 5 - CAPM Y VALUACIÓN\n")
cat("================================================================================\n")
cat("\n")
cat("RECORDATORIOS:\n")
cat("- Beta mide riesgo SISTEMÁTICO (no diversificable)\n")
cat("- CAPM relaciona riesgo con retorno esperado\n")
cat("- Alpha mide desempeño ajustado por riesgo\n")
cat("- Valuación fundamental: DDM, múltiplos\n")
cat("- Fama-French mejora CAPM con factores adicionales\n")
cat("\n")
cat("PRÓXIMA SESIÓN: Valoración de Bonos y Renta Fija\n")
cat("Aplicaremos descuento de flujos a bonos, duration, convexidad.\n")
cat("\n")

################################################################################
# FIN DEL SCRIPT
################################################################################
