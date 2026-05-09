# =============================================================================
# MERCADO DE CAPITALES — FACULTAD DE ECONOMÍA, UNAM
# SESIÓN 8: CVaR Y MEDIDAS COHERENTES DE RIESGO
# =============================================================================
# Profesor: Ismael Valverde | ismael_val@economia.unam.mx
# Prerrequisitos: Sesión 7 (VaR histórico, paramétrico y Monte Carlo)
# =============================================================================
#
# OBJETIVO DE LA SESIÓN
# Ir más allá del VaR respondiendo: ¿qué tan graves son las pérdidas
# cuando ya se superó el umbral?
#
# Herramienta: CVaR (Conditional Value at Risk), también llamado
# Expected Shortfall (ES). Es la medida estándar de Basilea III.
#
# Al finalizar podrás:
#   1. Calcular CVaR histórico, paramétrico y por Monte Carlo
#   2. Interpretar el ratio CVaR/VaR como indicador de cola pesada
#   3. Demostrar la violación de subaditividad del VaR
#   4. Entender por qué el CVaR es una medida coherente de riesgo
#
# LIBRERÍAS NECESARIAS
# install.packages(c("quantmod","PerformanceAnalytics","tidyverse",
#                    "ggplot2","moments","tseries","MASS","gridExtra"))
# =============================================================================

library(quantmod)
library(PerformanceAnalytics)
library(tidyverse)
library(ggplot2)
library(moments)
library(tseries)
library(MASS)
library(gridExtra)

set.seed(2024)

# =============================================================================
# PARTE 1: RECORDATORIO — EL PROBLEMA DEL VaR
# =============================================================================
# En la Sesión 7 aprendimos a calcular el VaR con tres métodos. Antes de
# introducir el CVaR, vale la pena visualizar exactamente qué información
# deja fuera el VaR.
#
# Dos portafolios con el mismo VaR(95%) pueden tener distribuciones de
# pérdidas radicalmente distintas en su cola izquierda. El VaR no distingue
# entre ellos; el CVaR sí.
# =============================================================================

cat("=========================================================\n")
cat("  SESIÓN 8: CVaR Y MEDIDAS COHERENTES DE RIESGO\n")
cat("  Facultad de Economía — UNAM\n")
cat("=========================================================\n\n")

cat(">>> Construyendo ejemplo motivador...\n\n")

# Simulamos dos portafolios con el mismo VaR(95%) pero distinto CVaR
set.seed(42)
n_demo <- 100000

# Portafolio A: distribución aproximadamente normal (cola suave)
r_A <- rnorm(n_demo, mean = 0.0004, sd = 0.0148)

# Portafolio B: misma media y desviación estándar, pero con cola pesada
# Modelado como mezcla: 95% días normales + 5% días de crisis severa
r_B <- ifelse(
  runif(n_demo) > 0.05,
  rnorm(n_demo, mean = 0.0008, sd = 0.010),   # días normales
  rnorm(n_demo, mean = -0.060, sd = 0.020)     # días de crisis
)

# Verificar que ambos tienen estadísticas similares en general
cat("--- Comparación de estadísticas generales ---\n\n")
cat(sprintf("  %-20s  %12s  %12s\n", "Estadística", "Portafolio A", "Portafolio B"))
cat(paste(rep("-", 48), collapse=""), "\n")
cat(sprintf("  %-20s  %12.5f  %12.5f\n", "Media",     mean(r_A),     mean(r_B)))
cat(sprintf("  %-20s  %12.5f  %12.5f\n", "Desv. Est.", sd(r_A),       sd(r_B)))
cat(sprintf("  %-20s  %12.4f  %12.4f\n", "Sesgo",     skewness(r_A), skewness(r_B)))
cat(sprintf("  %-20s  %12.4f  %12.4f\n", "Curtosis",  kurtosis(r_A), kurtosis(r_B)))

# Calcular VaR y CVaR de cada portafolio al 95%
var_A  <- quantile(r_A, probs = 0.05)
var_B  <- quantile(r_B, probs = 0.05)
cvar_A <- mean(r_A[r_A <= var_A])
cvar_B <- mean(r_B[r_B <= var_B])

cat(sprintf("\n  %-20s  %12.4f  %12.4f\n", "VaR(95%)",  var_A*100,  var_B*100))
cat(sprintf("  %-20s  %12.4f  %12.4f\n", "CVaR(95%)", cvar_A*100, cvar_B*100))
cat(sprintf("  %-20s  %12.4f  %12.4f\n", "Ratio CVaR/VaR",
            cvar_A/var_A, cvar_B/var_B))

cat("\n")
cat("OBSERVACIÓN CLAVE:\n")
cat("  Los dos portafolios tienen VaR muy similares.\n")
cat("  Pero el CVaR del Portafolio B es mucho más negativo.\n")
cat("  En los días de crisis, B pierde mucho más que A.\n")
cat("  El VaR trata ambos portafolios como equivalentes. El CVaR no.\n\n")

# Visualización comparativa
df_demo <- data.frame(
  r      = c(r_A, r_B),
  port   = rep(c("Portafolio A (cola suave)", "Portafolio B (cola pesada)"),
               each = n_demo)
)

# Para no saturar la gráfica, muestrar 20,000 observaciones por portafolio
set.seed(1)
idx <- sample(n_demo, 20000)
df_plot <- data.frame(
  r    = c(r_A[idx], r_B[idx]),
  port = rep(c("Portafolio A (cola suave)", "Portafolio B (cola pesada)"),
             each = 20000)
)

grafica_motivacion <- ggplot(df_plot, aes(x = r, fill = port)) +
  geom_density(alpha = 0.5) +
  geom_vline(xintercept = var_A,  color = "#1565C0", linewidth = 1.1,
             linetype = "dashed") +
  geom_vline(xintercept = var_B,  color = "#B71C1C", linewidth = 1.1,
             linetype = "dashed") +
  geom_vline(xintercept = cvar_A, color = "#1565C0", linewidth = 1.1,
             linetype = "solid") +
  geom_vline(xintercept = cvar_B, color = "#B71C1C", linewidth = 1.1,
             linetype = "solid") +
  annotate("text", x = var_A - 0.003,  y = 30,
           label = "VaR A", color = "#1565C0", hjust = 1, size = 3.5) +
  annotate("text", x = var_B - 0.003,  y = 25,
           label = "VaR B", color = "#B71C1C", hjust = 1, size = 3.5) +
  annotate("text", x = cvar_A - 0.003, y = 20,
           label = "CVaR A", color = "#1565C0", hjust = 1, size = 3.5) +
  annotate("text", x = cvar_B - 0.003, y = 15,
           label = "CVaR B", color = "#B71C1C", hjust = 1, size = 3.5) +
  scale_fill_manual(values = c("Portafolio A (cola suave)" = "#42A5F5",
                               "Portafolio B (cola pesada)" = "#EF5350")) +
  xlim(c(-0.18, 0.06)) +
  labs(
    title    = "El VaR no distingue entre colas suaves y pesadas",
    subtitle = "Líneas punteadas = VaR  |  Líneas sólidas = CVaR  |  Ambos niveles al 95%",
    x        = "Rendimiento diario",
    y        = "Densidad",
    fill     = NULL,
    caption  = "Mismos VaR, CVaR muy distintos: el CVaR captura la severidad de la cola"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "top",
        plot.title = element_text(face = "bold"))

print(grafica_motivacion)

# =============================================================================
# PARTE 2: DESCARGA DE DATOS Y PREPARACIÓN DEL PORTAFOLIO
# =============================================================================
# Usamos exactamente los mismos datos y pesos de la Sesión 7.
# Si ya los tienes en memoria de la sesión anterior, puedes saltar esta parte.
# =============================================================================

cat(">>> Descargando datos de la BMV...\n")

tickers      <- c("WALMEX.MX", "GFNORTEO.MX", "CEMEXCPO.MX", "FEMSAUBD.MX")
fecha_inicio <- "2020-01-01"
fecha_fin    <- "2024-12-31"

descargar_precio <- function(ticker, from, to) {
  tryCatch({
    datos  <- getSymbols(ticker, src = "yahoo", from = from, to = to,
                         auto.assign = FALSE)
    precio <- Ad(datos)
    colnames(precio) <- ticker
    cat("   ✓", ticker, "\n")
    return(precio)
  }, error = function(e) {
    cat("   ✗", ticker, "— ERROR:", conditionMessage(e), "\n")
    return(NULL)
  })
}

precios_lista <- lapply(tickers, descargar_precio,
                        from = fecha_inicio, to = fecha_fin)
precios_lista <- Filter(Negate(is.null), precios_lista)
precios       <- do.call(merge, precios_lista)
precios       <- na.omit(precios)

# Rendimientos logarítmicos diarios
rendimientos <- diff(log(precios))
rendimientos <- na.omit(rendimientos)

# Pesos del portafolio de mínima varianza (Sesión 4/7)
pesos_mv     <- c(0.30, 0.25, 0.20, 0.25)
names(pesos_mv) <- colnames(rendimientos)

# Rendimiento diario del portafolio
rend_port    <- as.numeric(rendimientos %*% pesos_mv)
fechas_port  <- index(rendimientos)

n_obs        <- length(rend_port)
valor_port   <- 1e6  # $1,000,000 MXN

cat(sprintf("\nObservaciones: %d días  |  Período: %s a %s\n\n",
            n_obs,
            format(fechas_port[1]),
            format(fechas_port[n_obs])))

# =============================================================================
# PARTE 3: DEFINICIÓN FORMAL DEL CVaR
# =============================================================================
# El CVaR (Conditional Value at Risk) se define como:
#
#   CVaR(α) = E[r | r ≤ VaR(α)]
#
# Es la pérdida ESPERADA dado que ya estamos en el peor α% de los escenarios.
#
# Propiedades importantes:
#   1. CVaR ≤ VaR siempre (en términos de pérdida, CVaR es siempre mayor)
#   2. CVaR es una medida COHERENTE: satisface subaditividad
#   3. CVaR captura la FORMA de la cola, no solo el umbral
#
# En la regulación internacional:
#   Basilea III reemplazó el VaR(99%) por el Expected Shortfall(97.5%)
#   como medida estándar para requerimientos de capital de mercado.
# =============================================================================

cat("=========================================================\n")
cat("  CONCEPTOS: CVaR Y MEDIDAS COHERENTES\n")
cat("=========================================================\n\n")

cat("Las cuatro propiedades de una medida coherente de riesgo:\n\n")
cat("  1. Monotonicidad: si X ≤ Y en todos los escenarios → ρ(X) ≥ ρ(Y)\n")
cat("  2. Homogeneidad positiva: ρ(λX) = λ·ρ(X) para λ > 0\n")
cat("  3. Invarianza a traslaciones: ρ(X + c) = ρ(X) − c\n")
cat("  4. SUBADITIVIDAD: ρ(X + Y) ≤ ρ(X) + ρ(Y)  ← el VaR puede violarla\n\n")
cat("El CVaR satisface las cuatro. Veremos la violación del VaR en el Ejercicio 7.\n\n")

# =============================================================================
# PARTE 4: CVaR HISTÓRICO
# =============================================================================
# Método más directo: filtrar los rendimientos que caen por debajo del VaR
# y promediarlos. No asume ninguna distribución.
#
# Procedimiento:
#   1. Calcular VaR = quantile(r, probs = alpha)
#   2. Filtrar cola: r[r <= VaR]
#   3. CVaR = mean(cola)
# =============================================================================

cat("=========================================================\n")
cat("  MÉTODO 1: CVaR HISTÓRICO\n")
cat("=========================================================\n\n")

niveles_confianza <- c(0.90, 0.95, 0.99)

# Función general: calcula VaR y CVaR histórico
var_cvar_historico <- function(r, nivel_confianza, valor = 1) {
  alpha   <- 1 - nivel_confianza
  var_    <- quantile(r, probs = alpha)
  cola    <- r[r <= var_]
  cvar_   <- mean(cola)
  return(list(
    var       = var_,
    cvar      = cvar_,
    ratio     = cvar_ / var_,
    n_cola    = length(cola),
    var_mxn   = var_  * valor,
    cvar_mxn  = cvar_ * valor
  ))
}

cat("--- CVaR Histórico del portafolio MV ($1,000,000 MXN) ---\n\n")
cat(sprintf("  %-12s  %10s  %10s  %10s  %14s  %14s\n",
            "Confianza", "VaR (%)", "CVaR (%)", "Ratio", "VaR (MXN)", "CVaR (MXN)"))
cat(paste(rep("-", 74), collapse=""), "\n")

resultados_hist <- list()
for (nc in niveles_confianza) {
  res <- var_cvar_historico(rend_port, nc, valor_port)
  resultados_hist[[as.character(nc)]] <- res
  cat(sprintf("  %-12s  %10.4f  %10.4f  %10.3f  %14.0f  %14.0f\n",
              paste0(nc*100, "%"),
              res$var  * 100,
              res$cvar * 100,
              res$ratio,
              res$var_mxn,
              res$cvar_mxn))
}

cat("\n")
cat("INTERPRETACIÓN (nivel 95%):\n")
res95 <- resultados_hist[["0.95"]]
cat(sprintf("  • En el 5%% peor de los días, la pérdida MÍNIMA   es %.4f%%\n",
            res95$var  * 100))
cat(sprintf("  • En el 5%% peor de los días, la pérdida PROMEDIO es %.4f%%\n",
            res95$cvar * 100))
cat(sprintf("  • El CVaR es %.2fx el VaR: las pérdidas extremas son\n",
            res95$ratio))
cat(sprintf("    significativamente peores que el simple umbral del VaR.\n"))
cat(sprintf("  • Observaciones en la cola (N × 5%%): %d días\n\n",
            res95$n_cola))

# =============================================================================
# VISUALIZACIÓN 1: Distribución con VaR y CVaR señalados
# =============================================================================

var_95_h  <- resultados_hist[["0.95"]]$var
cvar_95_h <- resultados_hist[["0.95"]]$cvar

df_rend <- data.frame(r = rend_port)

grafica_var_cvar <- ggplot(df_rend, aes(x = r)) +
  geom_histogram(aes(y = after_stat(density)),
                 bins = 60, fill = "#90CAF9", alpha = 0.7, color = "white") +
  geom_density(color = "#1565C0", linewidth = 0.9) +
  # Zona VaR (entre VaR y CVaR)
  geom_area(
    data = subset(df_rend, r <= var_95_h & r >= cvar_95_h),
    stat = "density", fill = "#FFA726", alpha = 0.5
  ) +
  # Zona CVaR (más extrema que CVaR)
  geom_area(
    data = subset(df_rend, r < cvar_95_h),
    stat = "density", fill = "#B71C1C", alpha = 0.6
  ) +
  geom_vline(xintercept = var_95_h,  color = "#E65100",
             linewidth = 1.3, linetype = "dashed") +
  geom_vline(xintercept = cvar_95_h, color = "#B71C1C",
             linewidth = 1.3, linetype = "solid") +
  annotate("text", x = var_95_h  - 0.002, y = 22,
           label = paste0("VaR 95%\n", round(var_95_h*100, 2), "%"),
           color = "#E65100", hjust = 1, size = 3.5, fontface = "bold") +
  annotate("text", x = cvar_95_h - 0.002, y = 16,
           label = paste0("CVaR 95%\n", round(cvar_95_h*100, 2), "%"),
           color = "#B71C1C", hjust = 1, size = 3.5, fontface = "bold") +
  annotate("text", x = (var_95_h + cvar_95_h)/2, y = 4,
           label = "zona\nVaR-CVaR", color = "#E65100", size = 2.8) +
  annotate("text", x = cvar_95_h - 0.015, y = 4,
           label = "cola\nextrema", color = "#B71C1C", size = 2.8) +
  labs(
    title    = "Distribución de Rendimientos — VaR y CVaR al 95%",
    subtitle = "Zona naranja: días entre VaR y CVaR | Zona roja: días más extremos que el CVaR",
    x        = "Rendimiento logarítmico diario",
    y        = "Densidad",
    caption  = "Portafolio MV: WALMEX / GFNORTE / CEMEX / FEMSA (2020–2024)"
  ) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"))

print(grafica_var_cvar)

# =============================================================================
# PARTE 5: CVaR PARAMÉTRICO
# =============================================================================
# Cuando los rendimientos siguen una distribución normal, el CVaR tiene
# una fórmula analítica cerrada. La clave es integrar la densidad normal
# en la cola izquierda:
#
#   CVaR(α) = μ − σ × φ(z_α) / α
#
# Donde:
#   z_α  = qnorm(α)   cuantil normal estándar al nivel α
#   φ(·) = dnorm(·)   densidad de la normal estándar evaluada en z_α
#   α    = nivel de significancia (0.05 para CVaR al 95%)
#
# La fracción φ(z_α)/α se llama razón inversa de Mills. Mide cuánto más
# alejada está la cola en promedio respecto al umbral z_α.
# =============================================================================

cat("=========================================================\n")
cat("  MÉTODO 2: CVaR PARAMÉTRICO\n")
cat("=========================================================\n\n")

mu_port    <- mean(rend_port)
sigma_port <- sd(rend_port)

cat(sprintf("Parámetros del portafolio:\n"))
cat(sprintf("  μ (media diaria):           %8.6f  (%6.3f%% anual)\n",
            mu_port, mu_port * 252 * 100))
cat(sprintf("  σ (desv. est. diaria):      %8.6f  (%6.3f%% anual)\n",
            sigma_port, sigma_port * sqrt(252) * 100))

# Función CVaR paramétrico (bajo normalidad)
cvar_parametrico_normal <- function(mu, sigma, nivel_confianza, valor = 1) {
  alpha    <- 1 - nivel_confianza
  z_alpha  <- qnorm(alpha)           # ej: qnorm(0.05) = -1.6449
  phi_z    <- dnorm(z_alpha)         # densidad normal en z_alpha
  # Razón inversa de Mills
  mills    <- phi_z / alpha          # siempre > 0
  var_     <- mu + z_alpha * sigma
  cvar_    <- mu - sigma * mills
  return(list(
    var       = var_,
    cvar      = cvar_,
    ratio     = cvar_ / var_,
    z_alpha   = z_alpha,
    phi_z     = phi_z,
    mills     = mills,
    var_mxn   = var_  * valor,
    cvar_mxn  = cvar_ * valor
  ))
}

cat("\n--- CVaR Paramétrico (distribución Normal) ---\n\n")
cat(sprintf("  %-12s  %8s  %8s  %8s  %8s\n",
            "Confianza", "z_α", "φ(z_α)/α", "VaR (%)", "CVaR (%)"))
cat(paste(rep("-", 56), collapse=""), "\n")

resultados_param <- list()
for (nc in niveles_confianza) {
  res <- cvar_parametrico_normal(mu_port, sigma_port, nc, valor_port)
  resultados_param[[as.character(nc)]] <- res
  cat(sprintf("  %-12s  %8.4f  %8.4f  %8.4f  %8.4f\n",
              paste0(nc*100, "%"),
              res$z_alpha,
              res$mills,
              res$var  * 100,
              res$cvar * 100))
}

cat("\n")
cat("NOTA: Bajo normalidad perfecta, el ratio CVaR/VaR al 95% es siempre ~1.26.\n")
cat("Cuando los datos reales muestran un ratio mayor, la distribución\n")
cat("tiene colas más pesadas que la normal.\n\n")

res95_param <- resultados_param[["0.95"]]
cat(sprintf("  Ratio CVaR/VaR paramétrico (95%%): %.4f\n",  res95_param$ratio))
cat(sprintf("  Ratio CVaR/VaR histórico    (95%%): %.4f\n",  res95$ratio))
cat(sprintf("  ¿Colas más pesadas que normal?     %s\n\n",
            ifelse(abs(res95$ratio) > abs(res95_param$ratio) + 0.05,
                   "SÍ — el histórico > paramétrico", "No significativamente")))

# =============================================================================
# PARTE 6: CVaR BAJO DISTRIBUCIÓN t-STUDENT
# =============================================================================
# Para distribuciones con colas más pesadas que la normal, la t-Student
# ofrece un mejor ajuste. Con df grados de libertad:
#
#   CVaR_t(α) = μ − σ × [f_t(t_α) × (df + t_α²) / ((df − 1) × α)]
#
# Donde t_α = qt(α, df) y f_t(·) = dt(·, df).
# El factor entre corchetes es la razón inversa de Mills de la distribución t,
# que es siempre mayor que la de la normal para el mismo α, reflejando
# las colas más pesadas.
# =============================================================================

cat("=========================================================\n")
cat("  CVaR PARAMÉTRICO BAJO t-STUDENT\n")
cat("=========================================================\n\n")

# Estimar grados de libertad por máxima verosimilitud
cat("Estimando grados de libertad de la distribución t...\n")

r_std <- (rend_port - mu_port) / sigma_port

fit_t <- tryCatch({
  MASS::fitdistr(r_std, "t")
}, error = function(e) {
  cat("  (ajuste t falló, usando df = 5 como aproximación)\n")
  list(estimate = c(m = 0, s = 1, df = 5))
})

df_est <- fit_t$estimate["df"]
cat(sprintf("  Grados de libertad estimados: %.2f\n", df_est))
cat(sprintf("  (df = 30 ≈ normal; df < 10 indica colas pesadas significativas)\n\n"))

# Función CVaR paramétrico bajo t-Student
cvar_parametrico_t <- function(mu, sigma, df, nivel_confianza, valor = 1) {
  alpha   <- 1 - nivel_confianza
  t_alpha <- qt(alpha, df = df)
  f_t     <- dt(t_alpha, df = df)
  # Factor de cola pesada de la t-Student
  factor  <- f_t * (df + t_alpha^2) / ((df - 1) * alpha)
  var_    <- mu + sigma * t_alpha
  cvar_   <- mu - sigma * factor
  return(list(
    var     = var_,
    cvar    = cvar_,
    ratio   = cvar_ / var_,
    var_mxn = var_  * valor,
    cvar_mxn= cvar_ * valor
  ))
}

cat("--- CVaR paramétrico t-Student vs. Normal ---\n\n")
cat(sprintf("  %-12s  %12s  %12s  %12s  %12s\n",
            "Confianza", "CVaR Normal", "CVaR t-Stu.", "Diferencia", "Ratio t/N"))
cat(paste(rep("-", 64), collapse=""), "\n")

for (nc in niveles_confianza) {
  res_n <- resultados_param[[as.character(nc)]]
  res_t <- cvar_parametrico_t(mu_port, sigma_port, df_est, nc, valor_port)
  cat(sprintf("  %-12s  %12.4f  %12.4f  %12.4f  %12.4f\n",
              paste0(nc*100, "%"),
              res_n$cvar * 100,
              res_t$cvar * 100,
              (res_t$cvar - res_n$cvar) * 100,
              res_t$cvar / res_n$cvar))
}

cat("\n")
cat("La t-Student produce CVaR más conservadores (más negativos) que la normal.\n")
cat("La diferencia es mayor al 99%: es en las colas extremas donde la t-Student\n")
cat("captura mejor la realidad de los mercados emergentes.\n\n")

# =============================================================================
# PARTE 7: CVaR POR SIMULACIÓN MONTE CARLO
# =============================================================================
# El procedimiento es idéntico al VaR Monte Carlo de la Sesión 7,
# con un paso adicional: en lugar de quedarnos con el cuantil (VaR),
# promediamos todos los valores simulados que caen por debajo de ese cuantil.
#
# Ventaja: no depende de ninguna forma distribucional. Con suficientes
# simulaciones, converge al CVaR "verdadero" de la distribución usada.
# =============================================================================

cat("=========================================================\n")
cat("  MÉTODO 3: CVaR POR SIMULACIÓN MONTE CARLO\n")
cat("=========================================================\n\n")

n_sim      <- 100000
set.seed(2024)

cat(sprintf("Número de simulaciones: %s\n\n", format(n_sim, big.mark = ",")))

# --- 3A: Monte Carlo Normal ---
r_mc_normal  <- rnorm(n_sim, mean = mu_port, sd = sigma_port)

# --- 3B: Monte Carlo t-Student ---
r_mc_t       <- mu_port + sigma_port * rt(n_sim, df = df_est)

# --- 3C: Monte Carlo Cholesky (multivariado) ---
rend_matrix  <- as.matrix(rendimientos)
mu_vector    <- colMeans(rend_matrix)
Sigma_cov    <- cov(rend_matrix)
L_chol       <- chol(Sigma_cov)

z_chol       <- matrix(rnorm(n_sim * ncol(rendimientos)),
                       nrow = n_sim, ncol = ncol(rendimientos))
r_mc_mv      <- sweep(z_chol %*% L_chol, 2, mu_vector, "+")
r_mc_chol    <- as.numeric(r_mc_mv %*% pesos_mv)

# Función unificada: VaR y CVaR de un vector simulado
var_cvar_mc <- function(r_sim, nivel_confianza, valor = 1, nombre = "") {
  alpha    <- 1 - nivel_confianza
  var_     <- quantile(r_sim, probs = alpha)
  cola     <- r_sim[r_sim <= var_]
  cvar_    <- mean(cola)
  return(list(
    metodo   = nombre,
    var      = var_,
    cvar     = cvar_,
    ratio    = cvar_ / var_,
    var_mxn  = var_  * valor,
    cvar_mxn = cvar_ * valor
  ))
}

cat("--- CVaR Monte Carlo al 95% ---\n\n")
cat(sprintf("  %-25s  %10s  %10s  %10s\n",
            "Método", "VaR (%)", "CVaR (%)", "Ratio"))
cat(paste(rep("-", 60), collapse=""), "\n")

metodos_mc <- list(
  var_cvar_mc(r_mc_normal, 0.95, valor_port, "MC Normal"),
  var_cvar_mc(r_mc_t,      0.95, valor_port, "MC t-Student"),
  var_cvar_mc(r_mc_chol,   0.95, valor_port, "MC Cholesky")
)

for (res in metodos_mc) {
  cat(sprintf("  %-25s  %10.4f  %10.4f  %10.3f\n",
              res$metodo,
              res$var  * 100,
              res$cvar * 100,
              res$ratio))
}

# =============================================================================
# PARTE 8: TABLA COMPARATIVA COMPLETA
# =============================================================================

cat("\n=========================================================\n")
cat("  TABLA COMPARATIVA: VaR Y CVaR — TODOS LOS MÉTODOS\n")
cat("=========================================================\n\n")

# Construir tabla completa para los tres niveles de confianza
metodos_nombres <- c("Histórico", "Paramétrico Normal",
                     "Paramétrico t-Student", "MC Normal",
                     "MC t-Student", "MC Cholesky")

tabla_comp <- data.frame(
  Metodo       = metodos_nombres,
  VaR_90       = NA_real_, CVaR_90 = NA_real_,
  VaR_95       = NA_real_, CVaR_95 = NA_real_,
  VaR_99       = NA_real_, CVaR_99 = NA_real_,
  Ratio_95     = NA_real_
)

for (i in seq_along(niveles_confianza)) {
  nc  <- niveles_confianza[i]
  col_var  <- paste0("VaR_",  nc*100)
  col_cvar <- paste0("CVaR_", nc*100)

  # Histórico
  rh <- var_cvar_historico(rend_port, nc)
  tabla_comp[1, col_var]  <- rh$var  * 100
  tabla_comp[1, col_cvar] <- rh$cvar * 100

  # Paramétrico Normal
  rp <- cvar_parametrico_normal(mu_port, sigma_port, nc)
  tabla_comp[2, col_var]  <- rp$var  * 100
  tabla_comp[2, col_cvar] <- rp$cvar * 100

  # Paramétrico t-Student
  rt_ <- cvar_parametrico_t(mu_port, sigma_port, df_est, nc)
  tabla_comp[3, col_var]  <- rt_$var  * 100
  tabla_comp[3, col_cvar] <- rt_$cvar * 100

  # MC Normal
  rm_n <- var_cvar_mc(r_mc_normal, nc)
  tabla_comp[4, col_var]  <- rm_n$var  * 100
  tabla_comp[4, col_cvar] <- rm_n$cvar * 100

  # MC t-Student
  rm_t <- var_cvar_mc(r_mc_t, nc)
  tabla_comp[5, col_var]  <- rm_t$var  * 100
  tabla_comp[5, col_cvar] <- rm_t$cvar * 100

  # MC Cholesky
  rm_c <- var_cvar_mc(r_mc_chol, nc)
  tabla_comp[6, col_var]  <- rm_c$var  * 100
  tabla_comp[6, col_cvar] <- rm_c$cvar * 100
}

# Calcular ratio CVaR/VaR al 95%
tabla_comp$Ratio_95 <- tabla_comp$CVaR_95 / tabla_comp$VaR_95

tabla_comp[, 2:8] <- round(tabla_comp[, 2:8], 3)

cat("VaR y CVaR como porcentaje del portafolio\n\n")
print(tabla_comp[, c("Metodo","VaR_90","CVaR_90","VaR_95","CVaR_95",
                     "VaR_99","CVaR_99","Ratio_95")],
      row.names = FALSE)

cat("\n")
cat("CONCLUSIONES DE LA TABLA:\n")
cat("• El ratio CVaR/VaR al 95% debería ser ~1.26 bajo normalidad perfecta.\n")
cat("• Ratios mayores indican colas pesadas: los métodos t-Student y el\n")
cat("  histórico capturan esto; el paramétrico normal lo subestima.\n")
cat("• La mayor diferencia entre métodos se observa al 99%: es en las\n")
cat("  colas extremas donde la hipótesis de normalidad más falla.\n\n")

# =============================================================================
# VISUALIZACIÓN 2: VaR vs CVaR por método — gráfica de barras comparativa
# =============================================================================

df_barras <- data.frame(
  Metodo    = rep(tabla_comp$Metodo, 2),
  Medida    = rep(c("VaR 95%", "CVaR 95%"), each = nrow(tabla_comp)),
  Valor_abs = c(abs(tabla_comp$VaR_95), abs(tabla_comp$CVaR_95))
)
df_barras$Medida <- factor(df_barras$Medida, levels = c("VaR 95%", "CVaR 95%"))

grafica_comp <- ggplot(df_barras, aes(x = Metodo, y = Valor_abs, fill = Medida)) +
  geom_bar(stat = "identity", position = "dodge", alpha = 0.85, width = 0.65) +
  scale_fill_manual(values = c("VaR 95%"  = "#42A5F5",
                               "CVaR 95%" = "#B71C1C")) +
  labs(
    title    = "VaR vs. CVaR al 95% — Comparación por Método",
    subtitle = "El CVaR siempre es mayor en valor absoluto que el VaR del mismo nivel",
    x        = NULL,
    y        = "Pérdida potencial (% del portafolio, valor absoluto)",
    fill     = NULL,
    caption  = "Portafolio MV: WALMEX / GFNORTE / CEMEX / FEMSA (2020–2024)"
  ) +
  coord_flip() +
  theme_minimal(base_size = 12) +
  theme(legend.position = "top",
        plot.title = element_text(face = "bold"))

print(grafica_comp)

# =============================================================================
# PARTE 9: CVaR RODANTE — CÓMO CAMBIA EL RIESGO DE COLA EN EL TIEMPO
# =============================================================================
# La versión rodante del CVaR es especialmente informativa porque muestra
# cómo la severidad de la cola cambia durante períodos de crisis.
# Durante mercados estresados, el ratio CVaR/VaR aumenta: los días malos
# no solo son más frecuentes sino que son peores de lo que el VaR sugiere.
# =============================================================================

cat("=========================================================\n")
cat("  CVaR RODANTE (ventana = 252 días)\n")
cat("=========================================================\n\n")

ventana          <- 252
n_rodante        <- n_obs - ventana
fechas_rodante   <- fechas_port[(ventana + 1):n_obs]
var_rod_95       <- numeric(n_rodante)
cvar_rod_95      <- numeric(n_rodante)
ratio_rod_95     <- numeric(n_rodante)

for (i in 1:n_rodante) {
  muestra       <- rend_port[i:(i + ventana - 1)]
  var_i         <- quantile(muestra, probs = 0.05)
  cvar_i        <- mean(muestra[muestra <= var_i])
  var_rod_95[i]   <- var_i
  cvar_rod_95[i]  <- cvar_i
  ratio_rod_95[i] <- cvar_i / var_i
}

df_rodante <- data.frame(
  fecha      = fechas_rodante,
  VaR_95     = var_rod_95,
  CVaR_95    = cvar_rod_95,
  Ratio      = ratio_rod_95,
  rend       = rend_port[(ventana + 1):n_obs]
)

# Gráfica 1: VaR y CVaR rodantes
g1 <- ggplot(df_rodante, aes(x = fecha)) +
  geom_line(aes(y = rend, color = "Rendimiento diario"), alpha = 0.35, linewidth = 0.4) +
  geom_line(aes(y = VaR_95,  color = "VaR 95% rodante"),  linewidth = 0.9) +
  geom_line(aes(y = CVaR_95, color = "CVaR 95% rodante"), linewidth = 0.9) +
  scale_color_manual(values = c(
    "Rendimiento diario"  = "steelblue",
    "VaR 95% rodante"     = "#F57F17",
    "CVaR 95% rodante"    = "#B71C1C"
  )) +
  labs(
    title  = "VaR y CVaR Rodantes (ventana = 252 días)",
    x      = NULL, y = "Rendimiento", color = NULL
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom", plot.title = element_text(face = "bold"))

# Gráfica 2: Ratio CVaR/VaR rodante
g2 <- ggplot(df_rodante, aes(x = fecha, y = Ratio)) +
  geom_line(color = "#6A1B9A", linewidth = 0.9) +
  geom_hline(yintercept = 1.26, color = "gray50",
             linetype = "dashed", linewidth = 0.7) +
  annotate("text", x = min(fechas_rodante), y = 1.22,
           label = "Ratio normal (~1.26)", hjust = 0, color = "gray50", size = 3) +
  labs(
    title  = "Ratio CVaR/VaR Rodante — Indicador de cola pesada",
    subtitle = "Cuando sube por encima de 1.26, las colas son más pesadas que la normal",
    x      = NULL, y = "CVaR / VaR (en valor absoluto)"
  ) +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold"))

grid.arrange(g1, g2, nrow = 2)

# Estadísticas del ratio rodante
cat(sprintf("Ratio CVaR/VaR promedio en el período:  %.3f\n", mean(ratio_rod_95)))
cat(sprintf("Ratio CVaR/VaR máximo  (peor momento):  %.3f\n", max(ratio_rod_95)))
cat(sprintf("Ratio CVaR/VaR mínimo  (mejor momento): %.3f\n\n", min(ratio_rod_95)))

# Identificar el mes de mayor ratio
fecha_max_ratio <- fechas_rodante[which.max(ratio_rod_95)]
cat(sprintf("El ratio más alto ocurrió alrededor de: %s\n", format(fecha_max_ratio)))
cat("(Probablemente coincida con el período de mayor estrés del mercado)\n\n")

# =============================================================================
# PARTE 10: ANÁLISIS POR PERÍODOS — NORMAL vs. CRISIS
# =============================================================================

cat("=========================================================\n")
cat("  VaR vs. CVaR: PERÍODO NORMAL vs. PERÍODO DE CRISIS\n")
cat("=========================================================\n\n")

# Definir períodos
periodos <- list(
  list(nombre = "Pre-COVID  (2019)",          inicio = "2019-01-01", fin = "2019-12-31"),
  list(nombre = "Crisis COVID (Feb-Jun 2020)", inicio = "2020-02-01", fin = "2020-06-30"),
  list(nombre = "Recuperación (2021)",         inicio = "2021-01-01", fin = "2021-12-31"),
  list(nombre = "Período completo (2020-2024)",inicio = "2020-01-01", fin = "2024-12-31")
)

cat(sprintf("  %-32s  %10s  %10s  %8s  %10s\n",
            "Período", "VaR(95%)", "CVaR(95%)", "Ratio", "N obs"))
cat(paste(rep("-", 74), collapse=""), "\n")

for (per in periodos) {
  idx   <- fechas_port >= per$inicio & fechas_port <= per$fin
  r_per <- rend_port[idx]
  if (length(r_per) < 30) {
    cat(sprintf("  %-32s  (datos insuficientes)\n", per$nombre))
    next
  }
  res <- var_cvar_historico(r_per, 0.95)
  cat(sprintf("  %-32s  %10.4f  %10.4f  %8.3f  %10d\n",
              per$nombre,
              res$var  * 100,
              res$cvar * 100,
              res$ratio,
              length(r_per)))
}

cat("\n")
cat("LECTURA CLAVE:\n")
cat("Durante la crisis, no solo el VaR creció (más días malos),\n")
cat("sino que el ratio también subió (los días malos fueron mucho peores).\n")
cat("Un modelo basado solo en VaR subestima el deterioro doble del riesgo.\n\n")

# =============================================================================
# PARTE 11: ESCALAMIENTO TEMPORAL DEL CVaR
# =============================================================================
# Al igual que el VaR, el CVaR puede escalarse a horizontes más largos
# con la regla de la raíz cuadrada del tiempo (mismo supuesto i.i.d.):
#
#   CVaR(T días) ≈ CVaR(1 día) × √T
#
# Esta aproximación hereda los mismos supuestos y limitaciones que
# la versión del VaR estudiada en la Sesión 7.
# =============================================================================

cat("=========================================================\n")
cat("  ESCALAMIENTO TEMPORAL DEL CVaR (regla √T)\n")
cat("=========================================================\n\n")

cvar_1d   <- resultados_hist[["0.95"]]$cvar
var_1d    <- resultados_hist[["0.95"]]$var
horizontes <- c(1, 5, 10, 21, 63)

cat(sprintf("Base: CVaR 1 día (95%%) = %.4f%%  |  VaR 1 día (95%%) = %.4f%%\n\n",
            cvar_1d * 100, var_1d * 100))
cat(sprintf("  %-15s  %8s  %12s  %12s  %14s\n",
            "Horizonte", "√T", "VaR (%)", "CVaR (%)", "CVaR (MXN)"))
cat(paste(rep("-", 65), collapse=""), "\n")

for (T in horizontes) {
  var_T  <- var_1d  * sqrt(T)
  cvar_T <- cvar_1d * sqrt(T)
  desc   <- switch(as.character(T),
    "1"  = "1 día",
    "5"  = "5 días (~1 sem)",
    "10" = "10 días (Basilea)",
    "21" = "21 días (~1 mes)",
    "63" = "63 días (~1 trim)"
  )
  cat(sprintf("  %-15s  %8.4f  %12.4f  %12.4f  %14.0f\n",
              desc, sqrt(T), var_T*100, cvar_T*100, cvar_T*valor_port))
}

cat("\n")

# =============================================================================
# PARTE 12: RESUMEN — MEDIDAS COHERENTES
# =============================================================================

cat("=========================================================\n")
cat("  RESUMEN: VaR vs. CVaR\n")
cat("=========================================================\n\n")

cat("PREGUNTA                        VaR          CVaR\n")
cat(paste(rep("-", 60), collapse=""), "\n")
cat("¿Qué mide?              Umbral de pérdida  Pérdida promedio en la cola\n")
cat("¿Subaditividad?         No siempre         Siempre (medida coherente)\n")
cat("¿Sensible a la forma    No                 Sí\n")
cat("  de la cola?           (solo el umbral)   (promedia la cola entera)\n")
cat("¿Estándar regulatorio?  Basilea II         Basilea III (desde 2019)\n")
cat("¿Más fácil de comunicar?Sí                 Menos\n")
cat("¿Más informativo?       No                 Sí\n\n")
cat("RECOMENDACIÓN: calcular siempre ambos. El VaR como límite operativo;\n")
cat("el CVaR como medida de severidad y para cálculo de capital regulatorio.\n\n")

# =============================================================================
# ============================================================================
#                       EJERCICIOS DE LA SESIÓN 8
# ============================================================================
# Los siguientes 7 ejercicios van de básico a avanzado.
# Los ejercicios 1–4 son obligatorios; 5–7 son de profundización.
# =============================================================================

cat("\n")
cat("============================================================\n")
cat("               EJERCICIOS DE LA SESIÓN 8\n")
cat("============================================================\n\n")

# ----------------------------------------------------------------------------
# EJERCICIO 1 (BÁSICO): CVaR histórico manual sin funciones de paquetes
# ----------------------------------------------------------------------------
cat("EJERCICIO 1: CVaR Histórico Manual\n")
cat("-----------------------------------\n")
cat("Dado el siguiente vector de rendimientos, calcula el CVaR al 95%\n")
cat("SIN usar ninguna función de paquetes: solo sort(), length() y mean().\n\n")

set.seed(101)
r_ej1 <- rnorm(400, mean = 0.0003, sd = 0.014)

# Paso 1: ordenar
r_ej1_ord <- sort(r_ej1)
n_ej1     <- length(r_ej1_ord)

# Paso 2: identificar cuántos días caen en el peor 5%
n_cola_ej1 <- floor(0.05 * n_ej1)
cat(sprintf("Total de observaciones: %d\n", n_ej1))
cat(sprintf("Observaciones en la cola (5%%): %d\n\n", n_cola_ej1))

# Paso 3: extraer la cola y calcular la media
cola_ej1 <- r_ej1_ord[1:n_cola_ej1]
var_ej1  <- r_ej1_ord[n_cola_ej1]      # el umbral = última obs. de la cola
cvar_ej1 <- mean(cola_ej1)

cat(sprintf("VaR(95%%)  = %.4f%%  (último valor de la cola)\n",
            var_ej1 * 100))
cat(sprintf("CVaR(95%%) = %.4f%%  (promedio de los %d peores días)\n",
            cvar_ej1 * 100, n_cola_ej1))
cat(sprintf("Ratio CVaR/VaR = %.3f\n\n", cvar_ej1 / var_ej1))

cat("Verificación con quantile() y filtrado:\n")
var_ver  <- quantile(r_ej1, probs = 0.05)
cvar_ver <- mean(r_ej1[r_ej1 <= var_ver])
cat(sprintf("  VaR verificado:  %.4f%%\n", var_ver  * 100))
cat(sprintf("  CVaR verificado: %.4f%%\n\n", cvar_ver * 100))

# ----------------------------------------------------------------------------
# EJERCICIO 2 (BÁSICO): Comparar VaR y CVaR entre activos individuales
# ----------------------------------------------------------------------------
cat("EJERCICIO 2: Ranking de Riesgo de Cola por Activo\n")
cat("--------------------------------------------------\n")
cat("Calcula VaR y CVaR al 95% para cada acción individual y construye\n")
cat("un ranking. Nota si el orden cambia entre VaR y CVaR.\n\n")

n_activos <- ncol(rendimientos)
tabla_rank <- data.frame(
  Accion    = colnames(rendimientos),
  Media     = NA_real_,
  Sigma     = NA_real_,
  VaR_95    = NA_real_,
  CVaR_95   = NA_real_,
  Ratio     = NA_real_
)

for (i in 1:n_activos) {
  r_i    <- as.numeric(rendimientos[, i])
  var_i  <- quantile(r_i, probs = 0.05)
  cvar_i <- mean(r_i[r_i <= var_i])
  tabla_rank$Media[i]   <- mean(r_i) * 100
  tabla_rank$Sigma[i]   <- sd(r_i)   * 100
  tabla_rank$VaR_95[i]  <- var_i     * 100
  tabla_rank$CVaR_95[i] <- cvar_i    * 100
  tabla_rank$Ratio[i]   <- cvar_i / var_i
}

# Ordenar por CVaR (de mayor pérdida a menor)
tabla_rank <- tabla_rank[order(tabla_rank$CVaR_95), ]
tabla_rank[, 2:6] <- round(tabla_rank[, 2:6], 4)

cat("Ranking por CVaR(95%) — de mayor a menor riesgo de cola:\n\n")
print(tabla_rank, row.names = FALSE)

cat("\n¿El activo más riesgoso según VaR es también el más riesgoso según CVaR?\n")
rank_var  <- order(tabla_rank$VaR_95)
rank_cvar <- order(tabla_rank$CVaR_95)
cat(sprintf("Correlación de rangos (VaR vs CVaR): %.3f\n",
            cor(tabla_rank$VaR_95, tabla_rank$CVaR_95)))
cat("Si < 1.0, el orden cambia: algunos activos tienen colas más pesadas\n")
cat("de lo que su VaR sugiere.\n\n")

# ----------------------------------------------------------------------------
# EJERCICIO 3 (INTERMEDIO): Fórmula analítica del CVaR paramétrico
# ----------------------------------------------------------------------------
cat("EJERCICIO 3: CVaR Paramétrico Paso a Paso\n")
cat("------------------------------------------\n")
cat("Replica el cálculo analítico del CVaR bajo normalidad para GFNORTEO.MX\n")
cat("usando solo las funciones qnorm() y dnorm(), sin funciones auxiliares.\n\n")

r_gfn   <- as.numeric(rendimientos[, "GFNORTEO.MX"])
mu_gfn  <- mean(r_gfn)
sig_gfn <- sd(r_gfn)
inv_gfn <- 750000  # $750,000 MXN

alpha_ej3 <- 0.05
z_ej3     <- qnorm(alpha_ej3)          # = -1.6449
phi_ej3   <- dnorm(z_ej3)             # densidad en z_α

cat(sprintf("GFNORTEO.MX:\n"))
cat(sprintf("  μ diaria:  %.6f\n", mu_gfn))
cat(sprintf("  σ diaria:  %.6f\n", sig_gfn))
cat(sprintf("  Inversión: $%s MXN\n\n", format(inv_gfn, big.mark = ",")))

cat(sprintf("Paso 1: z_α = qnorm(%.2f) = %.4f\n", alpha_ej3, z_ej3))
cat(sprintf("Paso 2: φ(z_α) = dnorm(%.4f) = %.6f\n", z_ej3, phi_ej3))
cat(sprintf("Paso 3: Razón inversa de Mills = φ(z_α)/α = %.6f/%.2f = %.4f\n",
            phi_ej3, alpha_ej3, phi_ej3/alpha_ej3))
cat(sprintf("Paso 4: VaR  = μ + z_α × σ        = %.6f + %.4f × %.6f\n",
            mu_gfn, z_ej3, sig_gfn))

var_gfn_param  <- mu_gfn + z_ej3 * sig_gfn
cvar_gfn_param <- mu_gfn - sig_gfn * (phi_ej3 / alpha_ej3)

cat(sprintf("               = %.4f%%\n", var_gfn_param * 100))
cat(sprintf("Paso 5: CVaR = μ − σ × φ(z_α)/α  = %.6f − %.6f × %.4f\n",
            mu_gfn, sig_gfn, phi_ej3/alpha_ej3))
cat(sprintf("               = %.4f%%\n\n", cvar_gfn_param * 100))

cat(sprintf("En pesos MXN ($750,000):\n"))
cat(sprintf("  VaR  pérdida máxima (95%%):    $%8.0f MXN\n",
            var_gfn_param  * inv_gfn))
cat(sprintf("  CVaR pérdida promedio (95%%):  $%8.0f MXN\n\n",
            cvar_gfn_param * inv_gfn))

# Comparar con el histórico
var_gfn_hist  <- quantile(r_gfn, probs = 0.05)
cvar_gfn_hist <- mean(r_gfn[r_gfn <= var_gfn_hist])
cat(sprintf("Comparación con método histórico:\n"))
cat(sprintf("  VaR  histórico:  %.4f%%  |  VaR  paramétrico: %.4f%%\n",
            var_gfn_hist*100, var_gfn_param*100))
cat(sprintf("  CVaR histórico:  %.4f%%  |  CVaR paramétrico: %.4f%%\n\n",
            cvar_gfn_hist*100, cvar_gfn_param*100))

# ----------------------------------------------------------------------------
# EJERCICIO 4 (INTERMEDIO): CVaR durante períodos de crisis
# ----------------------------------------------------------------------------
cat("EJERCICIO 4: CVaR — Período Normal vs. Período de Estrés\n")
cat("---------------------------------------------------------\n")
cat("Compara VaR y CVaR en distintos sub-períodos y calcula qué tan\n")
cat("inadecuado habría sido usar el modelo de un período tranquilo\n")
cat("para gestionar el riesgo durante la crisis.\n\n")

calcular_metricas <- function(r, nombre) {
  if (length(r) < 30) return(NULL)
  var_  <- quantile(r, probs = 0.05)
  cvar_ <- mean(r[r <= var_])
  data.frame(
    Periodo = nombre,
    N       = length(r),
    Media   = round(mean(r) * 100, 5),
    Sigma   = round(sd(r)   * 100, 5),
    VaR_95  = round(var_    * 100, 4),
    CVaR_95 = round(cvar_   * 100, 4),
    Ratio   = round(cvar_ / var_, 3)
  )
}

sub_periodos <- list(
  list(nombre = "2019 (pre-crisis)",      ini = "2019-01-01", fin = "2019-12-31"),
  list(nombre = "Q1 2020 (inicio COVID)", ini = "2020-01-01", fin = "2020-03-31"),
  list(nombre = "Q2 2020 (fondo crisis)", ini = "2020-04-01", fin = "2020-06-30"),
  list(nombre = "2021 (recuperación)",    ini = "2021-01-01", fin = "2021-12-31"),
  list(nombre = "2022 (inflación alta)",  ini = "2022-01-01", fin = "2022-12-31"),
  list(nombre = "2023–2024 (reciente)",   ini = "2023-01-01", fin = "2024-12-31")
)

resultados_sub <- do.call(rbind, lapply(sub_periodos, function(per) {
  idx <- fechas_port >= per$ini & fechas_port <= per$fin
  calcular_metricas(rend_port[idx], per$nombre)
}))
resultados_sub <- resultados_sub[!is.null(resultados_sub), ]

cat("Sub-período       |  N   | Media  | Sigma  | VaR(95%) | CVaR(95%) | Ratio\n")
cat(paste(rep("-", 78), collapse=""), "\n")
for (i in 1:nrow(resultados_sub)) {
  cat(sprintf("%-22s| %4d | %6.4f | %6.4f | %8.4f | %9.4f | %5.3f\n",
              resultados_sub$Periodo[i],
              resultados_sub$N[i],
              resultados_sub$Media[i],
              resultados_sub$Sigma[i],
              resultados_sub$VaR_95[i],
              resultados_sub$CVaR_95[i],
              resultados_sub$Ratio[i]))
}

cat("\n")
# ¿Cuánto cambió el CVaR entre el período más tranquilo y el más estresado?
if (nrow(resultados_sub) >= 2) {
  cvar_tranquilo <- resultados_sub$CVaR_95[1]
  cvar_estresado <- min(resultados_sub$CVaR_95)
  periodo_max    <- resultados_sub$Periodo[which.min(resultados_sub$CVaR_95)]
  cat(sprintf("Período más tranquilo: %s → CVaR = %.4f%%\n",
              resultados_sub$Periodo[1], cvar_tranquilo))
  cat(sprintf("Período más estresado: %s → CVaR = %.4f%%\n",
              periodo_max, cvar_estresado))
  cat(sprintf("El CVaR en crisis fue %.1fx mayor que en el período tranquilo.\n\n",
              cvar_estresado / cvar_tranquilo))
}

# ----------------------------------------------------------------------------
# EJERCICIO 5 (INTERMEDIO): Monte Carlo con distintas hipótesis de distribución
# ----------------------------------------------------------------------------
cat("EJERCICIO 5: Sensibilidad del CVaR a la Distribución Asumida\n")
cat("-------------------------------------------------------------\n")
cat("Calcula el CVaR al 99% bajo cinco supuestos distribucionales distintos\n")
cat("y compara qué tan conservadores son entre sí.\n\n")

set.seed(2024)
n_ej5 <- 200000

# Distribución 1: Normal
r_norm <- rnorm(n_ej5, mean = mu_port, sd = sigma_port)

# Distribución 2: t-Student (df estimado)
r_t4   <- mu_port + sigma_port * rt(n_ej5, df = df_est)

# Distribución 3: t-Student más pesada (df = 3, muy pesada)
r_t3   <- mu_port + sigma_port * rt(n_ej5, df = 3)

# Distribución 4: asimétrica (mezcla: 97% normal + 3% eventos extremos)
es_crisis4 <- rbinom(n_ej5, 1, prob = 0.03)
r_mix4     <- ifelse(es_crisis4 == 0,
                     rnorm(n_ej5, mean = mu_port + 0.001, sd = sigma_port * 0.8),
                     rnorm(n_ej5, mean = -0.05, sd = sigma_port * 2))

# Distribución 5: bootstrap histórico (resampleo de datos reales)
r_boot <- sample(rend_port, size = n_ej5, replace = TRUE)

distribuciones <- list(
  list(r = r_norm, nombre = "Normal"),
  list(r = r_t4,   nombre = paste0("t-Student (df=", round(df_est,1), ")")),
  list(r = r_t3,   nombre = "t-Student (df=3, muy pesada)"),
  list(r = r_mix4, nombre = "Mezcla (3% crisis severa)"),
  list(r = r_boot, nombre = "Bootstrap histórico")
)

cat(sprintf("  %-32s  %10s  %10s  %8s\n",
            "Distribución", "VaR(99%)", "CVaR(99%)", "Ratio"))
cat(paste(rep("-", 64), collapse=""), "\n")

for (d in distribuciones) {
  res_d <- var_cvar_mc(d$r, 0.99)
  cat(sprintf("  %-32s  %10.4f  %10.4f  %8.3f\n",
              d$nombre,
              res_d$var  * 100,
              res_d$cvar * 100,
              res_d$ratio))
}

cat("\n")
cat("OBSERVACIÓN: La distribución con df=3 y la mezcla producen CVaR\n")
cat("significativamente más conservadores al 99% que la normal.\n")
cat("Al 95% las diferencias son menores; al 99% son mucho mayores.\n")
cat("Esto ilustra por qué la elección de distribución importa más\n")
cat("cuanto más extremo es el nivel de confianza requerido.\n\n")

# ----------------------------------------------------------------------------
# EJERCICIO 6 (AVANZADO): CVaR rodante y señales de alerta temprana
# ----------------------------------------------------------------------------
cat("EJERCICIO 6: CVaR como Sistema de Alerta Temprana\n")
cat("--------------------------------------------------\n")
cat("Construye un semáforo de riesgo basado en el CVaR rodante:\n")
cat("compara el CVaR actual contra su promedio histórico para detectar\n")
cat("cuándo el mercado entra en régimen de cola pesada.\n\n")

# Calcular percentiles del CVaR rodante para definir umbrales
cvar_med  <- median(cvar_rod_95)
cvar_p75  <- quantile(cvar_rod_95, probs = 0.25)  # negativo: percentil 25 en negativo
cvar_p90  <- quantile(cvar_rod_95, probs = 0.10)  # más extremo

cat(sprintf("Distribución del CVaR rodante (95%%):\n"))
cat(sprintf("  Mediana (nivel normal):      %.4f%%\n", cvar_med  * 100))
cat(sprintf("  Percentil 25%% (alerta):     %.4f%%\n", cvar_p75  * 100))
cat(sprintf("  Percentil 10%% (peligro):    %.4f%%\n", cvar_p90  * 100))

# Clasificar cada día del período rodante
df_rodante$Semaforo <- case_when(
  df_rodante$CVaR_95 >= cvar_med  ~ "Verde  (riesgo normal)",
  df_rodante$CVaR_95 >= cvar_p75  ~ "Amarillo (alerta)",
  TRUE                             ~ "Rojo   (peligro)"
)

tabla_semaforo <- table(df_rodante$Semaforo)
cat(sprintf("\nDías por estado del semáforo:\n"))
for (estado in names(tabla_semaforo)) {
  pct <- tabla_semaforo[estado] / sum(tabla_semaforo) * 100
  cat(sprintf("  %s: %d días (%.1f%%)\n", estado, tabla_semaforo[estado], pct))
}

# Gráfica del semáforo
colores_sem <- c("Verde  (riesgo normal)" = "#2E7D32",
                 "Amarillo (alerta)"      = "#F57F17",
                 "Rojo   (peligro)"       = "#B71C1C")

grafica_semaforo <- ggplot(df_rodante, aes(x = fecha, y = CVaR_95 * 100,
                                            color = Semaforo)) +
  geom_line(linewidth = 0.7) +
  geom_hline(yintercept = cvar_med  * 100, linetype = "dashed",
             color = "#2E7D32", linewidth = 0.6) +
  geom_hline(yintercept = cvar_p75  * 100, linetype = "dashed",
             color = "#F57F17", linewidth = 0.6) +
  geom_hline(yintercept = cvar_p90  * 100, linetype = "dashed",
             color = "#B71C1C", linewidth = 0.6) +
  scale_color_manual(values = colores_sem) +
  labs(
    title    = "Semáforo de Riesgo — CVaR Rodante al 95%",
    subtitle = "Verde = normal | Amarillo = alerta | Rojo = peligro",
    x        = NULL, y = "CVaR(95%) — %", color = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold"))

print(grafica_semaforo)

cat("\n")
cat("Este tipo de semáforo es usado en mesas de riesgo para activar\n")
cat("protocolos de reducción de exposición cuando el CVaR supera umbrales\n")
cat("predefinidos. Es una forma práctica de convertir una medida estadística\n")
cat("en una decisión operativa concreta.\n\n")

# ----------------------------------------------------------------------------
# EJERCICIO 7 (AVANZADO): Demostración de violación de subaditividad del VaR
# ----------------------------------------------------------------------------
cat("EJERCICIO 7: ¿Diversificar puede ser 'más riesgoso' según el VaR?\n")
cat("------------------------------------------------------------------\n")
cat("Este ejercicio demuestra empíricamente que el VaR puede violar\n")
cat("la propiedad de subaditividad cuando las distribuciones tienen\n")
cat("colas asimétricas y eventos de default correlacionados.\n\n")

set.seed(2024)
n_ej7 <- 500000

# Dos instrumentos de crédito con riesgo de default
# En el 96% de los días: rendimiento normal pequeño
# En el  4% de los días: pérdida severa por default

prob_default   <- 0.04   # 4% de probabilidad de default
perdida_default <- -0.30  # pérdida de 30% en caso de default

# Default del Instrumento A (independiente)
default_A <- rbinom(n_ej7, 1, prob = prob_default)
r_ej7_A   <- ifelse(default_A == 0,
                    rnorm(n_ej7, mean = 0.0004, sd = 0.006),
                    rnorm(n_ej7, mean = perdida_default, sd = 0.01))

# Default del Instrumento B con correlación con A (ρ ≈ 0.4)
# Simular correlación via cópula gaussiana simplificada
u_comun    <- rnorm(n_ej7)
u_B        <- 0.4 * u_comun + sqrt(1 - 0.4^2) * rnorm(n_ej7)
default_B  <- as.integer(pnorm(u_comun) < prob_default)
# Nota: aquí default_B tiene correlación con u_comun, no con default_A directamente
# Para simplicidad, usamos default conjunto con probabilidad ajustada
prob_joint <- prob_default^2 + 0.4 * prob_default * (1 - prob_default)
default_AB <- rbinom(n_ej7, 1, prob = prob_joint)

r_ej7_B  <- ifelse(default_B == 0,
                   rnorm(n_ej7, mean = 0.0004, sd = 0.006),
                   rnorm(n_ej7, mean = perdida_default, sd = 0.01))

# Portafolio 50/50
r_ej7_port <- 0.5 * r_ej7_A + 0.5 * r_ej7_B

# Calcular VaR y CVaR al 95%
var_ej7_A    <- quantile(r_ej7_A,    probs = 0.05)
var_ej7_B    <- quantile(r_ej7_B,    probs = 0.05)
var_ej7_port <- quantile(r_ej7_port, probs = 0.05)
suma_var_ej7 <- 0.5 * var_ej7_A + 0.5 * var_ej7_B

cvar_ej7_A    <- mean(r_ej7_A[r_ej7_A <= var_ej7_A])
cvar_ej7_B    <- mean(r_ej7_B[r_ej7_B <= var_ej7_B])
cvar_ej7_port <- mean(r_ej7_port[r_ej7_port <= var_ej7_port])
suma_cvar_ej7 <- 0.5 * cvar_ej7_A + 0.5 * cvar_ej7_B

cat("RESULTADOS:\n\n")
cat(sprintf("  %-30s  %12s  %12s\n", "", "VaR(95%)", "CVaR(95%)"))
cat(paste(rep("-", 58), collapse=""), "\n")
cat(sprintf("  %-30s  %12.4f  %12.4f\n",
            "Instrumento A solo", var_ej7_A*100, cvar_ej7_A*100))
cat(sprintf("  %-30s  %12.4f  %12.4f\n",
            "Instrumento B solo", var_ej7_B*100, cvar_ej7_B*100))
cat(sprintf("  %-30s  %12.4f  %12.4f\n",
            "Suma ponderada (50/50)", suma_var_ej7*100, suma_cvar_ej7*100))
cat(sprintf("  %-30s  %12.4f  %12.4f\n",
            "Portafolio real 50/50", var_ej7_port*100, cvar_ej7_port*100))
cat(paste(rep("-", 58), collapse=""), "\n\n")

# ¿El VaR viola subaditividad?
violacion_var  <- var_ej7_port  < suma_var_ej7   # más negativo = mayor pérdida
violacion_cvar <- cvar_ej7_port < suma_cvar_ej7

cat(sprintf("  VaR:  portafolio (%+.4f%%) vs. suma (%+.4f%%)  →  %s\n",
            var_ej7_port*100, suma_var_ej7*100,
            ifelse(violacion_var,
                   "VIOLACIÓN DE SUBADITIVIDAD",
                   "Subaditividad satisfecha")))
cat(sprintf("  CVaR: portafolio (%+.4f%%) vs. suma (%+.4f%%)  →  %s\n\n",
            cvar_ej7_port*100, suma_cvar_ej7*100,
            ifelse(!violacion_cvar,
                   "Subaditividad SATISFECHA (como siempre)",
                   "Resultado inesperado — revisar datos")))

cat("CONCLUSIÓN:\n")
cat("Cuando el VaR viola subaditividad, el sistema de límites basado en VaR\n")
cat("puede PENALIZAR la diversificación: aparentemente es 'más riesgoso'\n")
cat("combinar los dos instrumentos que tenerlos por separado. Esto es\n")
cat("matemáticamente posible con el VaR pero nunca ocurre con el CVaR.\n")
cat("Es la razón fundamental por la que Basilea III adoptó el Expected\n")
cat("Shortfall como medida regulatoria estándar.\n\n")

# =============================================================================
# RESUMEN EJECUTIVO DE LA SESIÓN
# =============================================================================

cat("\n")
cat("============================================================\n")
cat("              RESUMEN EJECUTIVO — SESIÓN 8\n")
cat("============================================================\n\n")
cat("CONCEPTOS CLAVE:\n")
cat("  • CVaR = pérdida PROMEDIO dado que ya superamos el VaR\n")
cat("  • CVaR ≤ VaR siempre: captura la forma de la cola, no solo el umbral\n")
cat("  • Ratio CVaR/VaR ≈ 1.26 bajo normalidad; mayor indica colas pesadas\n")
cat("  • CVaR satisface subaditividad (medida coherente); VaR puede no hacerlo\n")
cat("  • Basilea III adoptó el Expected Shortfall (CVaR) sobre el VaR\n\n")
cat(sprintf("RESULTADO DEL PORTAFOLIO MV ($1,000,000 MXN):\n"))
cat(sprintf("  VaR  histórico (95%%): %7.4f%% → pérdida mínima:  $%8.0f MXN\n",
            resultados_hist[["0.95"]]$var  * 100,
            resultados_hist[["0.95"]]$var_mxn))
cat(sprintf("  CVaR histórico (95%%): %7.4f%% → pérdida promedio: $%8.0f MXN\n",
            resultados_hist[["0.95"]]$cvar  * 100,
            resultados_hist[["0.95"]]$cvar_mxn))
cat(sprintf("  Ratio CVaR/VaR:        %7.4f×\n\n",
            resultados_hist[["0.95"]]$ratio))
cat("PRÓXIMA SESIÓN (9): Modelos de Volatilidad GARCH\n")
cat("  Hasta ahora σ es constante. GARCH modela una σ_t que cambia cada día.\n")
cat("  VaR condicional = VaR paramétrico con σ_t de GARCH en lugar de σ fija.\n\n")
cat("Sesión completada — Facultad de Economía UNAM\n")
cat("Ismael Valverde | ismael_val@economia.unam.mx\n")
cat("============================================================\n")
