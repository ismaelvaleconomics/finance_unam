################################################################################
# MERCADOS DE CAPITALES - ANÁLISIS CUANTITATIVO
# SESIÓN 4: Teoría de Portafolios - Markowitz
#
# Profesor: Ismael Valverde
# Facultad de Economía, UNAM
#
# CONTENIDO DE LA SESIÓN:
# 1. Revisión de ejercicios Sesión 3
# 2. Teoría Moderna de Portafolios - Fundamentos
# 3. Frontera eficiente con 2 activos
# 4. Frontera eficiente con N activos
# 5. Portafolio de mínima varianza
# 6. Ratio de Sharpe y portafolio óptimo
# 7. Optimización con restricciones
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
library(quadprog)      # Para optimización cuadrática
library(ggplot2)
library(plotly)        # Para gráficas interactivas

cat("Librerías cargadas exitosamente!\n")
cat("Sesión 4: Teoría de Portafolios - Markowitz\n\n")

################################################################################
# PARTE 2: TEORÍA MODERNA DE PORTAFOLIOS - INTRODUCCIÓN
################################################################################

cat("========== TEORÍA MODERNA DE PORTAFOLIOS (MPT) ==========\n\n")

cat("*** HARRY MARKOWITZ (1952) ***\n")
cat("Premio Nobel de Economía 1990\n")
cat("'Portfolio Selection' - Journal of Finance\n\n")

cat("IDEA FUNDAMENTAL:\n")
cat("No evaluar activos de forma aislada, sino como parte de un PORTAFOLIO.\n")
cat("La diversificación puede REDUCIR el riesgo sin sacrificar retorno.\n\n")

cat("SUPUESTOS CLAVE:\n")
cat("1. Inversionistas son aversos al riesgo\n")
cat("2. Inversionistas se preocupan solo por media (μ) y varianza (σ²)\n")
cat("3. Los retornos siguen distribución normal (o multivariada normal)\n")
cat("4. No hay costos de transacción ni impuestos\n")
cat("5. Los inversionistas pueden prestar/pedir prestado a tasa libre de riesgo\n\n")

cat("NOTA: En Sesión 3 vimos que retornos NO son normales.\n")
cat("Aún así, MPT es útil como aproximación y punto de partida.\n\n")

################################################################################
# PARTE 3: EJEMPLO SIMPLE - DOS ACTIVOS
################################################################################

cat("\n========== FRONTERA EFICIENTE: DOS ACTIVOS ==========\n\n")

# Crear ejemplo numérico simple
# Activo A: Mayor retorno, mayor riesgo
# Activo B: Menor retorno, menor riesgo

mu_A <- 0.12      # 12% anual
mu_B <- 0.08      # 8% anual
sigma_A <- 0.20   # 20% volatilidad
sigma_B <- 0.15   # 15% volatilidad
rho_AB <- 0.3     # Correlación 0.3

cat("Activo A: μ = 12%, σ = 20%\n")
cat("Activo B: μ = 8%,  σ = 15%\n")
cat("Correlación (ρ) = 0.3\n\n")

# Crear 101 portafolios variando pesos de 0% a 100%
n_portfolios <- 101
w_A <- seq(0, 1, length.out = n_portfolios)
w_B <- 1 - w_A

# Calcular retorno y riesgo de cada portafolio
mu_p <- w_A * mu_A + w_B * mu_B

# Varianza del portafolio: σ²_p = w_A² σ_A² + w_B² σ_B² + 2 w_A w_B σ_A σ_B ρ
sigma_p_sq <- w_A^2 * sigma_A^2 + 
              w_B^2 * sigma_B^2 + 
              2 * w_A * w_B * sigma_A * sigma_B * rho_AB

sigma_p <- sqrt(sigma_p_sq)

# Crear data frame
frontera_2activos <- data.frame(
  Peso_A = w_A,
  Peso_B = w_B,
  Retorno = mu_p,
  Riesgo = sigma_p
)

cat("Tabla de algunos portafolios:\n")
idx_mostrar <- c(1, 26, 51, 76, 101)
print(frontera_2activos[idx_mostrar, ])

# Gráfica de la frontera eficiente
plot(frontera_2activos$Riesgo * 100, 
     frontera_2activos$Retorno * 100,
     type = "l",
     lwd = 3,
     col = "blue",
     xlab = "Riesgo (Volatilidad %)",
     ylab = "Retorno Esperado (%)",
     main = "Frontera Eficiente - Dos Activos",
     xlim = c(8, max(frontera_2activos$Riesgo) * 110),
     ylim = c(7, max(frontera_2activos$Retorno) * 110))

# Marcar los activos individuales
points(sigma_A * 100, mu_A * 100, pch = 19, col = "red", cex = 2)
text(sigma_A * 100, mu_A * 100, "Activo A", pos = 4, col = "red")

points(sigma_B * 100, mu_B * 100, pch = 19, col = "green", cex = 2)
text(sigma_B * 100, mu_B * 100, "Activo B", pos = 2, col = "green")

# Marcar portafolio de mínima varianza
idx_min_var <- which.min(sigma_p)
points(sigma_p[idx_min_var] * 100, mu_p[idx_min_var] * 100, 
       pch = 19, col = "purple", cex = 2)
text(sigma_p[idx_min_var] * 100, mu_p[idx_min_var] * 100, 
     "Mín. Varianza", pos = 1, col = "purple")

grid()

cat("\n*** OBSERVACIONES CLAVE ***\n")
cat("1. La curva es la FRONTERA EFICIENTE\n")
cat("2. Cualquier punto en la curva es un portafolio posible\n")
cat("3. La parte SUPERIOR es eficiente (máximo retorno para cada nivel de riesgo)\n")
cat("4. El punto más a la IZQUIERDA es el de MÍNIMA VARIANZA\n")
cat("5. La curva es CÓNCAVA (beneficio de diversificación)\n\n")

cat("Portafolio de Mínima Varianza:\n")
cat("Peso en A:", round(w_A[idx_min_var] * 100, 2), "%\n")
cat("Peso en B:", round(w_B[idx_min_var] * 100, 2), "%\n")
cat("Retorno esperado:", round(mu_p[idx_min_var] * 100, 2), "%\n")
cat("Riesgo (volatilidad):", round(sigma_p[idx_min_var] * 100, 2), "%\n\n")

################################################################################
# PARTE 4: EFECTO DE LA CORRELACIÓN
################################################################################

cat("\n========== EFECTO DE LA CORRELACIÓN EN LA DIVERSIFICACIÓN ==========\n\n")

# Calcular fronteras con diferentes correlaciones
correlaciones <- c(-0.9, -0.5, 0, 0.5, 0.9)
colores <- c("darkgreen", "green", "blue", "orange", "red")

plot(NULL, xlim = c(0, 25), ylim = c(0, 15),
     xlab = "Riesgo (Volatilidad %)",
     ylab = "Retorno Esperado (%)",
     main = "Frontera Eficiente con Diferentes Correlaciones")

for(i in 1:length(correlaciones)) {
  rho <- correlaciones[i]
  
  sigma_p_sq_temp <- w_A^2 * sigma_A^2 + 
                     w_B^2 * sigma_B^2 + 
                     2 * w_A * w_B * sigma_A * sigma_B * rho
  
  sigma_p_temp <- sqrt(sigma_p_sq_temp)
  
  lines(sigma_p_temp * 100, mu_p * 100, 
        col = colores[i], lwd = 2)
}

# Agregar activos individuales
points(sigma_A * 100, mu_A * 100, pch = 19, col = "black", cex = 1.5)
points(sigma_B * 100, mu_B * 100, pch = 19, col = "black", cex = 1.5)

legend("bottomright",
       legend = c("ρ = -0.9", "ρ = -0.5", "ρ = 0", "ρ = 0.5", "ρ = 0.9"),
       col = colores,
       lwd = 2,
       cex = 0.8)

grid()

cat("\n*** LECCIONES IMPORTANTES ***\n")
cat("1. Correlación BAJA o NEGATIVA → Mayor beneficio de diversificación\n")
cat("2. Con ρ = -1 (correlación perfecta negativa), puedes eliminar TODO el riesgo\n")
cat("3. Con ρ = 1 (correlación perfecta positiva), NO hay beneficio de diversificación\n")
cat("4. En la práctica, ρ suele estar entre 0.3 y 0.7 para acciones del mismo mercado\n\n")

################################################################################
# PARTE 5: FRONTERA EFICIENTE CON N ACTIVOS
################################################################################

cat("\n========== FRONTERA EFICIENTE: N ACTIVOS ==========\n\n")

# Descargar datos reales de acciones mexicanas
tickers <- c("WALMEX.MX", "CEMEXCPO.MX", "GFNORTEO.MX", "FEMSAUBD.MX")
# Ajustar según tu sistema

fecha_inicio <- "2020-01-01"
fecha_fin <- Sys.Date()

cat("Descargando datos de:", paste(tickers, collapse = ", "), "\n")
cat("Periodo:", fecha_inicio, "a", fecha_fin, "\n\n")

tryCatch({
  getSymbols(tickers,
             from = fecha_inicio,
             to = fecha_fin,
             src = "yahoo",
             auto.assign = TRUE)
  
  # Combinar precios
  precios <- merge(Cl(WALMEX.MX), Cl(CEMEXCPO.MX), 
                   Cl(GFNORTEO.MX), Cl(FEMSAUBD.MX))
  colnames(precios) <- c("WALMEX", "CEMEX", "BANORTE", "FEMSA")
  
  precios <- na.omit(precios)
  
  # Calcular retornos
  retornos <- Return.calculate(precios, method = "discrete")
  retornos <- na.omit(retornos)
  
  cat("Datos descargados exitosamente!\n")
  cat("Observaciones:", nrow(retornos), "\n\n")
  
  # Calcular parámetros
  mu <- colMeans(retornos) * 252  # Anualizado
  Sigma <- cov(retornos) * 252    # Anualizado
  
  n_activos <- ncol(retornos)
  
  cat("=== PARÁMETROS DE LOS ACTIVOS ===\n")
  cat("\nRetornos esperados anuales:\n")
  print(round(mu * 100, 2))
  
  cat("\nVolatilidades anuales:\n")
  vol <- sqrt(diag(Sigma))
  print(round(vol * 100, 2))
  
  cat("\nMatriz de Correlación:\n")
  print(round(cor(retornos), 3))
  
}, error = function(e) {
  cat("Error al descargar datos:", e$message, "\n")
})

################################################################################
# PARTE 6: PORTAFOLIO DE MÍNIMA VARIANZA GLOBAL (GMV)
################################################################################

cat("\n\n========== PORTAFOLIO DE MÍNIMA VARIANZA GLOBAL ==========\n\n")

if(exists("mu") && exists("Sigma")) {
  
  cat("Calculando portafolio de mínima varianza...\n")
  
  # Método 1: Fórmula analítica
  # w_GMV = (Σ^-1 * 1) / (1^T * Σ^-1 * 1)
  
  uno <- rep(1, n_activos)
  Sigma_inv <- solve(Sigma)
  
  w_GMV <- (Sigma_inv %*% uno) / as.numeric(t(uno) %*% Sigma_inv %*% uno)
  w_GMV <- as.numeric(w_GMV)
  names(w_GMV) <- colnames(retornos)
  
  cat("\nPesos del Portafolio de Mínima Varianza:\n")
  print(round(w_GMV * 100, 2))
  
  # Verificar que suman 1
  cat("\nSuma de pesos:", round(sum(w_GMV), 6), "\n")
  
  # Calcular retorno y riesgo del GMV
  mu_GMV <- sum(w_GMV * mu)
  sigma_GMV <- sqrt(t(w_GMV) %*% Sigma %*% w_GMV)
  
  cat("\nCaracterísticas del GMV:\n")
  cat("Retorno esperado anual:", round(mu_GMV * 100, 2), "%\n")
  cat("Volatilidad anual:", round(sigma_GMV * 100, 2), "%\n")
  
  # Comparar con activos individuales
  cat("\n=== COMPARACIÓN ===\n")
  cat("Volatilidad mínima individual:", round(min(vol) * 100, 2), "%\n")
  cat("Volatilidad GMV:", round(sigma_GMV * 100, 2), "%\n")
  cat("Reducción de riesgo:", 
      round((1 - sigma_GMV/min(vol)) * 100, 2), "%\n\n")
  
  cat("*** BENEFICIO DE LA DIVERSIFICACIÓN ***\n")
  cat("El GMV tiene MENOR riesgo que el activo individual menos riesgoso!\n\n")
}

################################################################################
# PARTE 7: GENERAR FRONTERA EFICIENTE COMPLETA
################################################################################

cat("\n========== GENERANDO FRONTERA EFICIENTE ==========\n\n")

if(exists("mu") && exists("Sigma")) {
  
  cat("Generando 100 portafolios eficientes...\n\n")
  
  # Función para calcular portafolio eficiente dado retorno objetivo
  portafolio_eficiente <- function(mu_target, mu, Sigma) {
    n <- length(mu)
    
    # Matriz y vector para optimización cuadrática
    # min 0.5 * w^T * Sigma * w
    # sujeto a: mu^T * w = mu_target
    #           1^T * w = 1
    
    Dmat <- 2 * Sigma
    dvec <- rep(0, n)
    
    # Restricciones de igualdad
    Amat <- cbind(mu, rep(1, n))
    bvec <- c(mu_target, 1)
    
    # Resolver
    sol <- solve.QP(Dmat, dvec, Amat, bvec, meq = 2)
    
    return(list(
      pesos = sol$solution,
      retorno = mu_target,
      riesgo = sqrt(sol$value)
    ))
  }
  
  # Rango de retornos para la frontera
  mu_min <- mu_GMV
  mu_max <- max(mu)
  
  retornos_objetivo <- seq(mu_min, mu_max, length.out = 100)
  
  # Calcular frontera
  frontera <- data.frame(
    Retorno = numeric(100),
    Riesgo = numeric(100)
  )
  
  pesos_frontera <- matrix(0, nrow = 100, ncol = n_activos)
  
  for(i in 1:100) {
    tryCatch({
      port <- portafolio_eficiente(retornos_objetivo[i], mu, Sigma)
      frontera$Retorno[i] <- port$retorno
      frontera$Riesgo[i] <- port$riesgo
      pesos_frontera[i, ] <- port$pesos
    }, error = function(e) {
      frontera$Retorno[i] <- NA
      frontera$Riesgo[i] <- NA
    })
  }
  
  # Eliminar NAs
  frontera <- na.omit(frontera)
  
  cat("Frontera eficiente calculada con", nrow(frontera), "portafolios\n\n")
  
  # Gráfica
  plot(frontera$Riesgo * 100, frontera$Retorno * 100,
       type = "l",
       lwd = 3,
       col = "blue",
       xlab = "Riesgo (Volatilidad Anual %)",
       ylab = "Retorno Esperado Anual (%)",
       main = "Frontera Eficiente - Mercado Mexicano")
  
  # Agregar activos individuales
  points(vol * 100, mu * 100, 
         pch = 19, col = "red", cex = 2)
  text(vol * 100, mu * 100, 
       labels = names(mu), pos = 4, cex = 0.8)
  
  # Agregar GMV
  points(sigma_GMV * 100, mu_GMV * 100,
         pch = 19, col = "purple", cex = 2)
  text(sigma_GMV * 100, mu_GMV * 100,
       "GMV", pos = 1, col = "purple", cex = 0.8)
  
  grid()
  
  cat("La curva azul muestra TODOS los portafolios eficientes.\n")
  cat("Cualquier punto en la curva domina a los puntos a su derecha.\n\n")
}

################################################################################
# PARTE 8: RATIO DE SHARPE Y PORTAFOLIO ÓPTIMO
################################################################################

cat("\n========== RATIO DE SHARPE Y PORTAFOLIO ÓPTIMO ==========\n\n")

cat("RATIO DE SHARPE = (Retorno - Tasa Libre de Riesgo) / Volatilidad\n")
cat("Mide retorno excedente por unidad de riesgo.\n")
cat("Mayor Sharpe = Mejor portafolio ajustado por riesgo.\n\n")

if(exists("mu") && exists("Sigma")) {
  
  # Tasa libre de riesgo (ejemplo: Cetes a 28 días ≈ 10%)
  rf <- 0.10
  
  cat("Tasa libre de riesgo:", rf * 100, "%\n\n")
  
  # Calcular Sharpe para cada portafolio en la frontera
  sharpe_frontera <- (frontera$Retorno - rf) / frontera$Riesgo
  
  # Encontrar portafolio con máximo Sharpe
  idx_max_sharpe <- which.max(sharpe_frontera)
  
  port_max_sharpe <- frontera[idx_max_sharpe, ]
  sharpe_max <- sharpe_frontera[idx_max_sharpe]
  
  cat("=== PORTAFOLIO DE MÁXIMO SHARPE (TANGENTE) ===\n")
  cat("Retorno esperado:", round(port_max_sharpe$Retorno * 100, 2), "%\n")
  cat("Volatilidad:", round(port_max_sharpe$Riesgo * 100, 2), "%\n")
  cat("Ratio de Sharpe:", round(sharpe_max, 3), "\n\n")
  
  # Pesos del portafolio de máximo Sharpe
  w_max_sharpe <- pesos_frontera[idx_max_sharpe, ]
  names(w_max_sharpe) <- colnames(retornos)
  
  cat("Pesos del portafolio de máximo Sharpe:\n")
  print(round(w_max_sharpe * 100, 2))
  
  # Gráfica con línea de mercado de capitales (CML)
  plot(frontera$Riesgo * 100, frontera$Retorno * 100,
       type = "l",
       lwd = 3,
       col = "blue",
       xlab = "Riesgo (Volatilidad %)",
       ylab = "Retorno Esperado (%)",
       main = "Frontera Eficiente y Capital Market Line (CML)")
  
  # Línea de Mercado de Capitales (CML)
  # Pasa por rf y el portafolio tangente
  abline(a = rf * 100, 
         b = (port_max_sharpe$Retorno - rf) / port_max_sharpe$Riesgo * 100,
         col = "green",
         lwd = 2,
         lty = 2)
  
  # Punto de tasa libre de riesgo
  points(0, rf * 100, pch = 19, col = "black", cex = 2)
  text(0, rf * 100, "rf", pos = 4)
  
  # Portafolio de máximo Sharpe
  points(port_max_sharpe$Riesgo * 100, port_max_sharpe$Retorno * 100,
         pch = 19, col = "green", cex = 2)
  text(port_max_sharpe$Riesgo * 100, port_max_sharpe$Retorno * 100,
       "Máx. Sharpe", pos = 4, col = "green")
  
  # Activos individuales
  points(vol * 100, mu * 100, pch = 19, col = "red", cex = 1.5)
  
  legend("bottomright",
         legend = c("Frontera Eficiente", "Capital Market Line", 
                   "Portafolio Tangente", "Tasa Libre Riesgo"),
         col = c("blue", "green", "green", "black"),
         lty = c(1, 2, NA, NA),
         pch = c(NA, NA, 19, 19),
         lwd = c(3, 2, NA, NA))
  
  grid()
  
  cat("\n*** INTERPRETACIÓN ***\n")
  cat("La línea verde (CML) representa portafolios que combinan:\n")
  cat("- El activo libre de riesgo (rf)\n")
  cat("- El portafolio tangente (máximo Sharpe)\n\n")
  cat("TODOS los puntos en la CML dominan a la frontera eficiente!\n")
  cat("Por eso los inversionistas racionales invierten en la CML, no en la frontera.\n\n")
}

################################################################################
# PARTE 9: RESTRICCIONES EN OPTIMIZACIÓN
################################################################################

cat("\n========== OPTIMIZACIÓN CON RESTRICCIONES ==========\n\n")

if(exists("mu") && exists("Sigma")) {
  
  cat("En la práctica, hay restricciones adicionales:\n")
  cat("1. No venta en corto: w >= 0\n")
  cat("2. Límites de concentración: w <= max_peso\n")
  cat("3. Restricciones sectoriales\n")
  cat("4. Número mínimo/máximo de activos\n\n")
  
  # Ejemplo: Portafolio con restricción de no venta en corto
  cat("Calculando portafolio de máximo Sharpe SIN venta en corto...\n\n")
  
  # Función objetivo: maximizar Sharpe = min -Sharpe
  objetivo_sharpe <- function(w) {
    retorno <- sum(w * mu)
    riesgo <- sqrt(t(w) %*% Sigma %*% w)
    sharpe <- -(retorno - rf) / riesgo  # Negativo para minimizar
    return(sharpe)
  }
  
  # Optimización con restricciones
  # Restricción: suma de pesos = 1, pesos >= 0
  
  library(nloptr)
  
  # Función de restricción de igualdad: sum(w) = 1
  restriccion_eq <- function(w) {
    return(sum(w) - 1)
  }
  
  # Pesos iniciales
  w0 <- rep(1/n_activos, n_activos)
  
  # Optimizar
  resultado <- slsqp(
    x0 = w0,
    fn = objetivo_sharpe,
    heq = restriccion_eq,
    lower = rep(0, n_activos),  # No negativos
    upper = rep(1, n_activos),
    control = list(xtol_rel = 1e-8)
  )
  
  w_sharpe_sin_cortos <- resultado$par
  names(w_sharpe_sin_cortos) <- colnames(retornos)
  
  cat("Pesos del portafolio de máximo Sharpe (sin venta en corto):\n")
  print(round(w_sharpe_sin_cortos * 100, 2))
  
  # Comparar con portafolio sin restricción
  cat("\n=== COMPARACIÓN ===\n")
  cat("Con venta en corto permitida:\n")
  print(round(w_max_sharpe * 100, 2))
  
  cat("\nSin venta en corto:\n")
  print(round(w_sharpe_sin_cortos * 100, 2))
  
  # Calcular métricas
  ret_sin_cortos <- sum(w_sharpe_sin_cortos * mu)
  risk_sin_cortos <- sqrt(t(w_sharpe_sin_cortos) %*% Sigma %*% w_sharpe_sin_cortos)
  sharpe_sin_cortos <- (ret_sin_cortos - rf) / risk_sin_cortos
  
  cat("\n=== DESEMPEÑO ===\n")
  cat("Con venta en corto:\n")
  cat("  Sharpe:", round(sharpe_max, 3), "\n")
  
  cat("Sin venta en corto:\n")
  cat("  Sharpe:", round(sharpe_sin_cortos, 3), "\n\n")
  
  cat("Las restricciones reducen el Sharpe, pero hacen el portafolio más práctico.\n\n")
}

################################################################################
# PARTE 10: BACKTEST DEL PORTAFOLIO ÓPTIMO
################################################################################

cat("\n========== BACKTEST: DESEMPEÑO HISTÓRICO ==========\n\n")

if(exists("w_max_sharpe") && exists("retornos")) {
  
  cat("Evaluando desempeño histórico del portafolio de máximo Sharpe...\n\n")
  
  # Retornos del portafolio
  retornos_portafolio <- retornos %*% w_max_sharpe
  
  # Estadísticas
  ret_promedio <- mean(retornos_portafolio) * 252
  vol_real <- sd(retornos_portafolio) * sqrt(252)
  sharpe_real <- (ret_promedio - rf) / vol_real
  
  cat("=== DESEMPEÑO REAL (Backtest) ===\n")
  cat("Retorno anual realizado:", round(ret_promedio * 100, 2), "%\n")
  cat("Volatilidad anual realizada:", round(vol_real * 100, 2), "%\n")
  cat("Sharpe realizado:", round(sharpe_real, 3), "\n\n")
  
  cat("=== ESPERADO (Ex-ante) ===\n")
  cat("Retorno esperado:", round(port_max_sharpe$Retorno * 100, 2), "%\n")
  cat("Volatilidad esperada:", round(port_max_sharpe$Riesgo * 100, 2), "%\n")
  cat("Sharpe esperado:", round(sharpe_max, 3), "\n\n")
  
  # Retornos acumulados
  retornos_acum <- cumprod(1 + retornos_portafolio) - 1
  
  # Comparar con benchmark (portafolio equiponderado)
  w_equal <- rep(1/n_activos, n_activos)
  retornos_equal <- retornos %*% w_equal
  retornos_acum_equal <- cumprod(1 + retornos_equal) - 1
  
  # Gráfica
  plot(index(retornos_acum), retornos_acum,
       type = "l",
       lwd = 2,
       col = "blue",
       xlab = "Fecha",
       ylab = "Retorno Acumulado",
       main = "Desempeño: Portafolio Óptimo vs Benchmark")
  
  lines(index(retornos_acum_equal), retornos_acum_equal,
        col = "gray", lwd = 2, lty = 2)
  
  legend("topleft",
         legend = c("Máximo Sharpe", "Equiponderado"),
         col = c("blue", "gray"),
         lty = c(1, 2),
         lwd = 2)
  
  grid()
  
  # Drawdown
  wealth <- cumprod(1 + retornos_portafolio)
  max_wealth <- cummax(wealth)
  drawdown <- (wealth - max_wealth) / max_wealth
  
  max_dd <- min(drawdown)
  
  cat("Máximo Drawdown:", round(max_dd * 100, 2), "%\n\n")
  
  cat("*** NOTA IMPORTANTE ***\n")
  cat("El desempeño pasado NO garantiza resultados futuros.\n")
  cat("Este backtest usa los MISMOS datos para estimar parámetros y evaluar.\n")
  cat("En la práctica, deberías usar datos out-of-sample para evaluar.\n\n")
}

################################################################################
# PARTE 11: REBALANCEO DE PORTAFOLIOS
################################################################################

cat("\n========== REBALANCEO DE PORTAFOLIOS ==========\n\n")

cat("Los pesos del portafolio cambian con el tiempo debido a:\n")
cat("1. Cambios en precios de activos\n")
cat("2. Cambios en correlaciones\n")
cat("3. Cambios en expectativas de retornos\n\n")

cat("ESTRATEGIAS DE REBALANCEO:\n")
cat("1. Calendario (ej: mensual, trimestral)\n")
cat("2. Umbral (ej: cuando un peso se desvía >5%)\n")
cat("3. Sin rebalanceo (buy-and-hold)\n\n")

if(exists("retornos") && exists("w_max_sharpe")) {
  
  cat("Simulando rebalanceo trimestral...\n\n")
  
  # Dividir datos en trimestres
  fechas <- index(retornos)
  trimestres <- format(fechas, "%Y-%m")
  trimestres_unicos <- unique(format(seq(fechas[1], 
                                         fechas[length(fechas)], 
                                         by = "3 months"), "%Y-%m"))
  
  # Simular con y sin rebalanceo
  riqueza_con_rebalanceo <- 1
  riqueza_sin_rebalanceo <- 1
  
  pesos_actuales <- w_max_sharpe
  
  for(i in 2:length(retornos_portafolio)) {
    # Retorno del periodo
    ret_periodo <- as.numeric(retornos_portafolio[i])
    
    # Con rebalanceo: mantener pesos fijos
    riqueza_con_rebalanceo <- riqueza_con_rebalanceo * (1 + ret_periodo)
    
    # Sin rebalanceo: pesos evolucionan con precios
    # (simplificación para demostración)
    riqueza_sin_rebalanceo <- riqueza_sin_rebalanceo * (1 + ret_periodo)
  }
  
  cat("Riqueza final con rebalanceo:", round(riqueza_con_rebalanceo, 3), "\n")
  cat("Riqueza final sin rebalanceo:", round(riqueza_sin_rebalanceo, 3), "\n\n")
  
  cat("El rebalanceo puede:\n")
  cat("+ Mantener el perfil de riesgo deseado\n")
  cat("+ Forzar 'comprar barato, vender caro'\n")
  cat("- Generar costos de transacción\n")
  cat("- Generar impuestos sobre ganancias de capital\n\n")
}

################################################################################
# EJERCICIOS PARA LOS ESTUDIANTES
################################################################################

cat("\n\n")
cat("================================================================================\n")
cat("                         EJERCICIOS PARA PRÁCTICA\n")
cat("================================================================================\n\n")

cat("EJERCICIO 1: FRONTERA CON DOS ACTIVOS\n")
cat("--------------------------------------\n")
cat("Dos activos con las siguientes características:\n")
cat("Activo X: μ = 15%, σ = 25%\n")
cat("Activo Y: μ = 10%, σ = 18%\n\n")
cat("a) Calcula y grafica la frontera eficiente con ρ = 0.2\n")
cat("b) Encuentra el portafolio de mínima varianza analíticamente\n")
cat("c) Repite con ρ = 0.8 y compara las fronteras\n")
cat("d) ¿Cuál correlación da mayor beneficio de diversificación?\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 2: PORTAFOLIO DE MÍNIMA VARIANZA\n")
cat("-------------------------------------------\n")
cat("Descarga datos de 3 acciones mexicanas de sectores DIFERENTES:\n")
cat("(ej: retail, minería, financiero)\n\n")
cat("a) Calcula retornos de los últimos 3 años\n")
cat("b) Estima μ y Σ\n")
cat("c) Calcula el portafolio de mínima varianza global\n")
cat("d) Compara su volatilidad con la del activo menos volátil\n")
cat("e) ¿Algún peso es negativo? ¿Qué significa?\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 3: FRONTERA EFICIENTE COMPLETA\n")
cat("-----------------------------------------\n")
cat("Usando los mismos 3 activos del Ejercicio 2:\n\n")
cat("a) Genera 50 portafolios eficientes\n")
cat("b) Grafica la frontera eficiente\n")
cat("c) Marca los activos individuales y el GMV\n")
cat("d) ¿Qué portafolio tiene Sharpe más alto? (asume rf = 8%)\n")
cat("e) Grafica la Capital Market Line\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 4: EFECTO DE LA TASA LIBRE DE RIESGO\n")
cat("-----------------------------------------------\n")
cat("Usando tu frontera eficiente del Ejercicio 3:\n\n")
cat("a) Calcula el portafolio de máximo Sharpe con rf = 5%\n")
cat("b) Calcula el portafolio de máximo Sharpe con rf = 10%\n")
cat("c) Calcula el portafolio de máximo Sharpe con rf = 15%\n")
cat("d) ¿Cómo cambian los pesos al variar rf?\n")
cat("e) ¿Por qué cambia el portafolio óptimo?\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 5: RESTRICCIONES DE NO VENTA EN CORTO\n")
cat("------------------------------------------------\n")
cat("Descarga 4 activos mexicanos y calcula:\n\n")
cat("a) Portafolio de máximo Sharpe SIN restricciones\n")
cat("b) Portafolio de máximo Sharpe CON restricción w >= 0\n")
cat("c) Compara los pesos de ambos portafolios\n")
cat("d) Compara los ratios de Sharpe\n")
cat("e) ¿Cuál es más práctico para implementar? ¿Por qué?\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 6: BACKTEST Y EVALUACIÓN\n")
cat("-----------------------------------\n")
cat("Divide tus datos en dos periodos:\n")
cat("- Periodo 1 (2020-2022): Estimar parámetros\n")
cat("- Periodo 2 (2023-2024): Evaluar desempeño\n\n")
cat("a) Calcula portafolio óptimo usando solo Periodo 1\n")
cat("b) Evalúa su desempeño en Periodo 2 (out-of-sample)\n")
cat("c) Compara retorno realizado vs esperado\n")
cat("d) Compara volatilidad realizada vs esperada\n")
cat("e) ¿El portafolio 'funcionó'? ¿Por qué sí o no?\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 7: COMPARACIÓN DE ESTRATEGIAS\n")
cat("----------------------------------------\n")
cat("Compara 4 estrategias de portafolio durante 2020-2024:\n")
cat("1. Equiponderado (1/N en cada activo)\n")
cat("2. Mínima varianza global\n")
cat("3. Máximo Sharpe\n")
cat("4. Maximum Diversification (pesos ∝ volatilidades inversas)\n\n")
cat("Para cada estrategia calcula:\n")
cat("a) Retorno acumulado\n")
cat("b) Volatilidad anualizada\n")
cat("c) Ratio de Sharpe\n")
cat("d) Máximo Drawdown\n")
cat("e) Crea una tabla comparativa y recomienda una estrategia\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\n")
cat("================================================================================\n")
cat("           FIN DE LA SESIÓN 4 - TEORÍA DE PORTAFOLIOS (MARKOWITZ)\n")
cat("================================================================================\n")
cat("\n")
cat("RECORDATORIOS:\n")
cat("- La diversificación REDUCE el riesgo sin sacrificar retorno\n")
cat("- El portafolio óptimo depende de tu aversión al riesgo\n")
cat("- Correlaciones bajas aumentan beneficios de diversificación\n")
cat("- El ratio de Sharpe ayuda a comparar portafolios ajustados por riesgo\n")
cat("- Restricciones prácticas reducen el Sharpe pero hacen portafolios implementables\n")
cat("\n")
cat("PRÓXIMA SESIÓN: CAPM y Modelos Factoriales\n")
cat("Construiremos sobre Markowitz para entender el equilibrio del mercado.\n")
cat("\n")

################################################################################
# FIN DEL SCRIPT
################################################################################
