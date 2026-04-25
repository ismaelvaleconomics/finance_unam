# =============================================================================
# MERCADO DE CAPITALES — FACULTAD DE ECONOMÍA, UNAM
# SESIÓN 7: VALOR EN RIESGO (VaR) — HISTÓRICO, PARAMÉTRICO Y SIMULACIÓN
# =============================================================================
# Profesor: Ismael Valverde | ismael_val@economia.unam.mx
# Duración: 2.5 – 3 horas
# Prerrequisitos: Sesiones 1–6 (especialmente estadística descriptiva
#                 y teoría de portafolios)
# =============================================================================
#
# OBJETIVO DE LA SESIÓN
# Medir el riesgo de pérdida de un portafolio con tres metodologías distintas:
#   1. VaR Histórico (simulación con datos pasados reales)
#   2. VaR Paramétrico (distribución normal / varianza-covarianza)
#   3. VaR por Simulación Monte Carlo
#
# Al finalizar podrás responder: "¿Cuánto puede perder mi portafolio en el
# peor 1% (o 5%) de los días?"
#
# LIBRERÍAS NECESARIAS
# install.packages(c("quantmod","PerformanceAnalytics","PortfolioAnalytics",
#                    "tidyverse","ggplot2","moments","tseries","MASS"))
# =============================================================================

library(quantmod)
library(PerformanceAnalytics)
library(tidyverse)
library(ggplot2)
library(moments)    # para skewness y kurtosis
library(tseries)    # para prueba Jarque-Bera
library(MASS)       # para ajuste de distribuciones

# Reproducibilidad en simulaciones
set.seed(2024)

# =============================================================================
# PARTE 1: CONCEPTOS FUNDAMENTALES DEL VaR
# =============================================================================
# El Valor en Riesgo (Value at Risk, VaR) responde a una pregunta concreta:
#
#   "Con un nivel de confianza del X%, ¿cuál es la pérdida máxima esperada
#    en un horizonte de tiempo T?"
#
# Ejemplo de interpretación:
#   VaR(95%, 1 día) = -2.5%  →  Solo en el 5% de los días la pérdida
#                                superará el 2.5% del portafolio.
#
# Dos convenciones de signo:
#   • Pérdida positiva:  VaR = 2.5%  (convención regulatoria / Basilea)
#   • Pérdida negativa:  VaR = -2.5% (convención de cuantil estadístico)
#   En este curso usamos la convención estadística (cuantil negativo).
#
# Tres niveles de confianza estándar en la industria:
#   • 90%  → umbral interno de gestión (más permisivo)
#   • 95%  → estándar de gestión de riesgos
#   • 99%  → estándar regulatorio (Comité de Basilea)
# =============================================================================

cat("=========================================================\n")
cat("  SESIÓN 7: VALOR EN RIESGO (VaR)\n")
cat("  Facultad de Economía — UNAM\n")
cat("=========================================================\n\n")

# =============================================================================
# PARTE 2: DESCARGA DE DATOS
# =============================================================================
# Usaremos las mismas acciones del portafolio que hemos analizado en
# sesiones anteriores, más el IPC como referencia de mercado.
# =============================================================================

cat(">>> Descargando datos de la BMV...\n")

tickers <- c("WALMEX.MX", "GFNORTEO.MX", "CEMEXCPO.MX", "FEMSAUBD.MX")
ipc     <- "^MXX"

# Fecha de inicio: 4 años de historia para tener suficientes observaciones
fecha_inicio <- "2020-01-01"
fecha_fin    <- "2024-12-31"

# Función auxiliar para descargar con manejo de errores
descargar_precio <- function(ticker, from, to) {
  tryCatch({
    datos <- getSymbols(ticker, src = "yahoo", from = from, to = to,
                        auto.assign = FALSE)
    precio <- Ad(datos)  # precio ajustado por dividendos y splits
    colnames(precio) <- ticker
    cat("   ✓", ticker, "— OK\n")
    return(precio)
  }, error = function(e) {
    cat("   ✗", ticker, "— ERROR:", conditionMessage(e), "\n")
    return(NULL)
  })
}

# Descarga de acciones individuales
precios_lista <- lapply(tickers, descargar_precio,
                        from = fecha_inicio, to = fecha_fin)
precios_lista <- Filter(Negate(is.null), precios_lista)

# Descarga del IPC
ipc_datos <- tryCatch({
  datos <- getSymbols(ipc, src = "yahoo", from = fecha_inicio, to = fecha_fin,
                      auto.assign = FALSE)
  precio <- Ad(datos)
  colnames(precio) <- "IPC"
  cat("   ✓", ipc, "(IPC) — OK\n")
  precio
}, error = function(e) {
  cat("   ✗ IPC — ERROR:", conditionMessage(e), "\n")
  NULL
})

# Consolidar precios en una sola matriz
precios <- do.call(merge, precios_lista)
precios <- na.omit(precios)

cat("\nDatos disponibles:", nrow(precios), "días de negociación\n")
cat("Período:", format(index(precios)[1]), "a",
    format(index(precios)[nrow(precios)]), "\n\n")

# =============================================================================
# PARTE 3: CALCULAR RENDIMIENTOS
# =============================================================================
# Usamos rendimientos logarítmicos (continuamente compuestos) porque:
#   • Son aditivos en el tiempo: r_total = r_1 + r_2 + ... + r_T
#   • Se aproximan mejor a la distribución normal
#   • Son estándar en la literatura de gestión de riesgos
# =============================================================================

# Rendimientos logarítmicos diarios
rendimientos <- diff(log(precios))
rendimientos <- na.omit(rendimientos)

cat("--- Rendimientos diarios (primeras filas) ---\n")
print(round(head(rendimientos, 5), 6))

# Estadísticas descriptivas de rendimientos
cat("\n--- Estadísticas descriptivas de rendimientos ---\n")
stats_rend <- data.frame(
  Media    = sapply(rendimientos, mean),
  DesvEst  = sapply(rendimientos, sd),
  Sesgo    = sapply(rendimientos, skewness),
  Curtosis = sapply(rendimientos, kurtosis),
  Min      = sapply(rendimientos, min),
  Max      = sapply(rendimientos, max)
)
print(round(stats_rend, 5))

# =============================================================================
# NOTA PEDAGÓGICA: ¿Por qué importa la curtosis?
# En una distribución normal la curtosis = 3 (o exceso de curtosis = 0).
# Los rendimientos financieros típicamente tienen curtosis > 3 (colas pesadas),
# lo que significa que los eventos extremos son MÁS frecuentes de lo que
# predice una distribución normal. Esto tiene implicaciones directas para el VaR
# paramétrico, que asume normalidad.
# =============================================================================

# Prueba de normalidad Jarque-Bera para cada activo
cat("\n--- Prueba de normalidad Jarque-Bera (p < 0.05 → NO es normal) ---\n")
for (col in colnames(rendimientos)) {
  jb <- jarque.bera.test(as.numeric(rendimientos[, col]))
  cat(sprintf("  %-15s  estadístico = %8.2f  |  p-valor = %.4f  |  %s\n",
              col,
              jb$statistic,
              jb$p.value,
              ifelse(jb$p.value < 0.05, "NO normal", "Normal")))
}

# =============================================================================
# PARTE 4: DEFINIR EL PORTAFOLIO
# =============================================================================
# Usaremos el portafolio de mínima varianza calculado en la Sesión 4.
# Para esta sesión simplificamos con pesos iguales y pesos óptimos.
# =============================================================================

n_activos <- ncol(rendimientos)
cat("\n--- Definición del portafolio ---\n")

# Portafolio 1: pesos iguales (equal-weighted)
pesos_iguales <- rep(1/n_activos, n_activos)
names(pesos_iguales) <- colnames(rendimientos)
cat("Pesos iguales:", round(pesos_iguales, 4), "\n")

# Portafolio 2: pesos hipotéticos basados en análisis previo
# (en la práctica vendrían de la optimización de la Sesión 4)
pesos_mv <- c(0.30, 0.25, 0.20, 0.25)
names(pesos_mv) <- colnames(rendimientos)
cat("Pesos portafolio MV:", round(pesos_mv, 4), "\n")

# Verificar que suman 1
stopifnot(abs(sum(pesos_iguales) - 1) < 1e-10)
stopifnot(abs(sum(pesos_mv)     - 1) < 1e-10)

# Rendimientos del portafolio: suma ponderada de rendimientos individuales
rend_port_igual <- as.numeric(rendimientos %*% pesos_iguales)
rend_port_mv    <- as.numeric(rendimientos %*% pesos_mv)

# Convertir a xts para uso posterior
rend_port_xts <- xts(rend_port_mv, order.by = index(rendimientos))
colnames(rend_port_xts) <- "Portafolio_MV"

cat("\nEstadísticas del portafolio MV:\n")
cat(sprintf("  Media diaria   : %8.5f  (%.2f%% anual)\n",
            mean(rend_port_mv), mean(rend_port_mv)*252*100))
cat(sprintf("  DesvEst diaria : %8.5f  (%.2f%% anual)\n",
            sd(rend_port_mv), sd(rend_port_mv)*sqrt(252)*100))
cat(sprintf("  Sesgo          : %8.4f\n", skewness(rend_port_mv)))
cat(sprintf("  Curtosis       : %8.4f\n", kurtosis(rend_port_mv)))
cat(sprintf("  Mínimo         : %8.4f\n", min(rend_port_mv)))
cat(sprintf("  Máximo         : %8.4f\n", max(rend_port_mv)))

# =============================================================================
# PARTE 5: VaR HISTÓRICO (SIMULACIÓN HISTÓRICA)
# =============================================================================
# CONCEPTO:
# La simulación histórica es el método más intuitivo y transparente.
# Idea central: el futuro se parecerá al pasado, por lo que podemos usar
# la distribución empírica de rendimientos pasados como aproximación de
# la distribución futura.
#
# PROCEDIMIENTO:
#   1. Ordenar los rendimientos históricos de menor a mayor
#   2. El VaR al nivel α es el cuantil (1-α) de esa distribución
#
# VENTAJAS:
#   + No asume ninguna distribución (no paramétrico)
#   + Captura asimetrías y colas pesadas reales
#   + Fácil de explicar a directivos
#
# DESVENTAJAS:
#   − Depende del período de historia disponible
#   − No captura eventos fuera del histórico ("cisnes negros")
#   − Puede ser inestable si el período es corto
# =============================================================================

cat("\n=========================================================\n")
cat("  MÉTODO 1: VaR HISTÓRICO\n")
cat("=========================================================\n\n")

# Parámetros
niveles_confianza <- c(0.90, 0.95, 0.99)
valor_portafolio  <- 1e6  # $1,000,000 MXN

# Función para calcular VaR histórico
var_historico <- function(rendimientos_vec, nivel_confianza, valor) {
  # El cuantil al nivel (1 - confianza) de la distribución empírica
  alpha    <- 1 - nivel_confianza
  cuantil  <- quantile(rendimientos_vec, probs = alpha)
  var_pct  <- cuantil
  var_mxn  <- cuantil * valor
  return(list(cuantil = cuantil,
              var_pct = var_pct,
              var_mxn = var_mxn,
              alpha   = alpha))
}

cat("--- VaR Histórico del portafolio MV (valor: $1,000,000 MXN) ---\n\n")

for (nc in niveles_confianza) {
  resultado <- var_historico(rend_port_mv, nc, valor_portafolio)
  cat(sprintf("  Confianza %3.0f%%: VaR = %7.4f%% | Pérdida máx = $%10.0f MXN\n",
              nc*100, resultado$var_pct*100, resultado$var_mxn))
}

# Guardar resultados para comparación posterior
var_hist_95 <- var_historico(rend_port_mv, 0.95, valor_portafolio)

# =============================================================================
# VISUALIZACIÓN 1: Distribución histórica de rendimientos y VaR
# =============================================================================

# Preparar datos para ggplot
df_rend <- data.frame(rendimiento = rend_port_mv)
var_90  <- var_historico(rend_port_mv, 0.90, valor_portafolio)$var_pct
var_95  <- var_historico(rend_port_mv, 0.95, valor_portafolio)$var_pct
var_99  <- var_historico(rend_port_mv, 0.99, valor_portafolio)$var_pct

grafica_hist_var <- ggplot(df_rend, aes(x = rendimiento)) +
  geom_histogram(aes(y = after_stat(density)),
                 bins = 60, fill = "#2196F3", alpha = 0.7, color = "white") +
  geom_density(color = "#1565C0", linewidth = 1) +
  # Líneas de VaR
  geom_vline(xintercept = var_90, color = "#FF9800", linewidth = 1.2,
             linetype = "dashed") +
  geom_vline(xintercept = var_95, color = "#F44336", linewidth = 1.2,
             linetype = "dashed") +
  geom_vline(xintercept = var_99, color = "#B71C1C", linewidth = 1.5,
             linetype = "solid") +
  # Sombrear región de pérdidas extremas (> VaR 99%)
  geom_area(data = subset(df_rend, rendimiento < var_99),
            stat = "density", fill = "#B71C1C", alpha = 0.25) +
  # Anotaciones
  annotate("text", x = var_90 - 0.002, y = 25, label = "VaR 90%",
           color = "#FF9800", hjust = 1, size = 3.5, fontface = "bold") +
  annotate("text", x = var_95 - 0.002, y = 20, label = "VaR 95%",
           color = "#F44336", hjust = 1, size = 3.5, fontface = "bold") +
  annotate("text", x = var_99 - 0.002, y = 15, label = "VaR 99%",
           color = "#B71C1C", hjust = 1, size = 3.5, fontface = "bold") +
  labs(
    title    = "Distribución Empírica de Rendimientos — Portafolio MV",
    subtitle = "VaR Histórico a niveles de confianza 90%, 95% y 99%",
    x        = "Rendimiento Logarítmico Diario",
    y        = "Densidad",
    caption  = "Fuente: Yahoo Finance / BMV (2020–2024)"
  ) +
  theme_minimal(base_size = 12) +
  theme(plot.title    = element_text(face = "bold"),
        plot.subtitle = element_text(color = "gray40"))

print(grafica_hist_var)

# =============================================================================
# VENTANA RODANTE: VaR histórico a lo largo del tiempo
# (muestra cómo el riesgo cambia durante períodos de crisis)
# =============================================================================

cat("\n--- Calculando VaR histórico con ventana rodante (252 días) ---\n")

ventana <- 252  # 1 año de días de negociación

n_obs      <- length(rend_port_mv)
fechas_var <- index(rendimientos)[(ventana+1):n_obs]
var_rodante_95 <- numeric(n_obs - ventana)
var_rodante_99 <- numeric(n_obs - ventana)

for (i in 1:(n_obs - ventana)) {
  muestra <- rend_port_mv[i:(i + ventana - 1)]
  var_rodante_95[i] <- quantile(muestra, probs = 0.05)
  var_rodante_99[i] <- quantile(muestra, probs = 0.01)
}

df_var_rodante <- data.frame(
  fecha  = fechas_var,
  VaR_95 = var_rodante_95,
  VaR_99 = var_rodante_99,
  rend   = rend_port_mv[(ventana+1):n_obs]
)

grafica_rodante <- ggplot(df_var_rodante, aes(x = fecha)) +
  geom_line(aes(y = rend, color = "Rendimiento diario"),
            alpha = 0.4, linewidth = 0.4) +
  geom_line(aes(y = VaR_95, color = "VaR 95% (rodante)"),
            linewidth = 0.9) +
  geom_line(aes(y = VaR_99, color = "VaR 99% (rodante)"),
            linewidth = 0.9) +
  scale_color_manual(values = c("Rendimiento diario"   = "steelblue",
                                "VaR 95% (rodante)"    = "#F44336",
                                "VaR 99% (rodante)"    = "#B71C1C")) +
  labs(
    title    = "VaR Histórico Rodante (ventana = 252 días)",
    subtitle = "El VaR se vuelve más severo durante períodos de alta volatilidad",
    x        = "Fecha", y        = "Rendimiento",
    color    = NULL,
    caption  = "Fuente: Yahoo Finance / BMV"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom",
        plot.title      = element_text(face = "bold"))

print(grafica_rodante)

# =============================================================================
# PARTE 6: VaR PARAMÉTRICO (VARIANZA-COVARIANZA)
# =============================================================================
# CONCEPTO:
# El método paramétrico supone que los rendimientos siguen una distribución
# normal. Bajo este supuesto, el VaR se calcula analíticamente usando la media
# y la desviación estándar del portafolio.
#
# FÓRMULA:
#   VaR(α) = μ + z_α × σ
#   donde z_α es el cuantil de la distribución normal estándar
#   (para 95%: z = -1.645;  para 99%: z = -2.326)
#
# VENTAJAS:
#   + Rápido de calcular
#   + Descomponible por fuente de riesgo (activo individual)
#   + Facilita el cálculo de VaR marginal y VaR componente
#
# DESVENTAJAS:
#   − Supuesto de normalidad raramente se cumple
#   − Subestima pérdidas en colas pesadas
#   − No captura asimetrías del mercado
# =============================================================================

cat("\n=========================================================\n")
cat("  MÉTODO 2: VaR PARAMÉTRICO (VARIANZA-COVARIANZA)\n")
cat("=========================================================\n\n")

# Parámetros de la distribución normal del portafolio
mu_port    <- mean(rend_port_mv)
sigma_port <- sd(rend_port_mv)

cat(sprintf("Media diaria portafolio (μ): %.6f\n", mu_port))
cat(sprintf("Desv. est. diaria (σ):       %.6f\n", sigma_port))

# Cuantiles de la distribución normal estándar
# qnorm(0.05) = -1.6449  (para VaR al 95%)
# qnorm(0.01) = -2.3263  (para VaR al 99%)
cat("\nCuantiles normales estándar:\n")
for (nc in niveles_confianza) {
  alpha   <- 1 - nc
  z_alpha <- qnorm(alpha)
  cat(sprintf("  Confianza %3.0f%%: z = %7.4f\n", nc*100, z_alpha))
}

# Función para calcular VaR paramétrico
var_parametrico <- function(mu, sigma, nivel_confianza, valor) {
  alpha   <- 1 - nivel_confianza
  z_alpha <- qnorm(alpha)
  var_pct <- mu + z_alpha * sigma
  var_mxn <- var_pct * valor
  return(list(var_pct = var_pct, var_mxn = var_mxn,
              mu = mu, sigma = sigma, z = z_alpha))
}

cat("\n--- VaR Paramétrico del portafolio MV ---\n\n")

for (nc in niveles_confianza) {
  res <- var_parametrico(mu_port, sigma_port, nc, valor_portafolio)
  cat(sprintf("  Confianza %3.0f%%: VaR = %7.4f%% | Pérdida máx = $%10.0f MXN\n",
              nc*100, res$var_pct*100, res$var_mxn))
}

var_param_95 <- var_parametrico(mu_port, sigma_port, 0.95, valor_portafolio)

# =============================================================================
# DESCOMPOSICIÓN DEL VaR POR ACTIVO (VaR componente)
# =============================================================================
# Una ventaja clave del método paramétrico es poder descomponer el VaR total
# en la contribución de cada activo. Esto permite identificar cuál activo
# concentra el mayor riesgo del portafolio.
#
# VaR_componente_i = w_i × Cov(r_i, r_p) / σ_p × z_α
# donde Cov(r_i, r_p) es la covarianza del activo i con el portafolio total.
# =============================================================================

cat("\n--- VaR Componente: contribución de cada activo al riesgo total ---\n\n")

rend_matrix <- as.matrix(rendimientos)
Sigma       <- cov(rend_matrix)  # matriz de varianza-covarianza

# Varianza y desviación estándar del portafolio (por álgebra lineal: w'Σw)
sigma2_port <- as.numeric(t(pesos_mv) %*% Sigma %*% pesos_mv)
sigma_port_check <- sqrt(sigma2_port)
cat(sprintf("Verificación σ portafolio: %.6f (debe ≈ %.6f)\n\n",
            sigma_port_check, sigma_port))

# Covarianza de cada activo con el portafolio: Σ × w
cov_activos_port <- as.numeric(Sigma %*% pesos_mv)

# Beta de cada activo respecto al portafolio
beta_activos <- cov_activos_port / sigma2_port

# VaR componente al 95%
z_95          <- qnorm(0.05)
var_port_95   <- mu_port + z_95 * sigma_port

var_comp <- data.frame(
  Activo          = colnames(rendimientos),
  Peso            = pesos_mv,
  Beta_vs_Port    = round(beta_activos, 4),
  VaR_individual  = round((sapply(1:n_activos, function(i)
                              mu_port + z_95 * sd(rend_matrix[,i])) * 100), 4),
  VaR_componente  = round(pesos_mv * beta_activos * var_port_95 * 100, 4)
)

print(var_comp)

cat(sprintf("\nVaR total portafolio (95%%): %7.4f%%\n", var_port_95*100))
cat(sprintf("Suma VaR componentes:       %7.4f%%  (debe ser igual al total)\n",
            sum(var_comp$VaR_componente)))

# =============================================================================
# AJUSTE A HORIZONTE TEMPORAL: REGLA DE LA RAÍZ CUADRADA DEL TIEMPO
# =============================================================================
# El VaR de 1 día se puede escalar a horizontes más largos usando:
#   VaR(T días) = VaR(1 día) × √T
#
# SUPUESTO: rendimientos independientes e idénticamente distribuidos.
# En la práctica esto es una aproximación (los rendimientos muestran
# autocorrelación leve y clusters de volatilidad).
#
# IMPORTANTE EN REGULACIÓN:
# Basilea III requiere VaR a 10 días para el cálculo de requerimientos
# de capital por riesgo de mercado.
# =============================================================================

cat("\n--- Escalamiento temporal del VaR (regla √T) ---\n\n")

horizontes <- c(1, 5, 10, 21, 63)  # días hábiles
var_1dia   <- var_param_95$var_pct

cat(sprintf("Base: VaR 1 día (95%%) = %.4f%%\n\n", var_1dia*100))
cat(sprintf("  %-15s %-12s %-15s %-15s\n",
            "Horizonte", "√T", "VaR (%)", "Pérdida MXN"))
cat(paste(rep("-", 58), collapse=""), "\n")

for (T in horizontes) {
  var_T     <- var_1dia * sqrt(T)
  perdida_T <- var_T * valor_portafolio
  cat(sprintf("  %-15s %-12.4f %-15.4f %-15.0f\n",
              paste0(T, ifelse(T == 1, " día", " días")),
              sqrt(T), var_T*100, perdida_T))
}

# =============================================================================
# VISUALIZACIÓN 2: Curva de densidad teórica vs. empírica
# =============================================================================

df_comp <- data.frame(rendimiento = rend_port_mv)

var_hist_90  <- var_historico(rend_port_mv, 0.90, 1)$var_pct
var_hist_99  <- var_historico(rend_port_mv, 0.99, 1)$var_pct
var_param_90 <- var_parametrico(mu_port, sigma_port, 0.90, 1)$var_pct
var_param_99 <- var_parametrico(mu_port, sigma_port, 0.99, 1)$var_pct

grafica_param <- ggplot(df_comp, aes(x = rendimiento)) +
  geom_histogram(aes(y = after_stat(density)),
                 bins = 60, fill = "lightblue", alpha = 0.6, color = "white") +
  # Densidad empírica
  geom_density(aes(color = "Empírica"), linewidth = 1) +
  # Densidad normal teórica
  stat_function(fun   = dnorm,
                args  = list(mean = mu_port, sd = sigma_port),
                aes(color = "Normal teórica"),
                linewidth = 1, linetype = "dashed") +
  # VaR histórico
  geom_vline(aes(xintercept = var_hist_95$var_pct, linetype = "VaR Histórico 95%"),
             color = "#E53935", linewidth = 1.2) +
  # VaR paramétrico
  geom_vline(aes(xintercept = var_param_95$var_pct, linetype = "VaR Paramétrico 95%"),
             color = "#1E88E5", linewidth = 1.2) +
  scale_color_manual(name = "Distribución",
                     values = c("Empírica" = "#1B5E20",
                                "Normal teórica" = "#0D47A1")) +
  scale_linetype_manual(name = "VaR",
                        values = c("VaR Histórico 95%"   = "solid",
                                   "VaR Paramétrico 95%" = "dashed")) +
  labs(
    title    = "Distribución Empírica vs. Normal Teórica",
    subtitle = "Las colas pesadas hacen que el VaR paramétrico subestime el riesgo real",
    x        = "Rendimiento Logarítmico Diario",
    y        = "Densidad",
    caption  = "La densidad empírica tiene colas más pesadas que la normal → VaR paramétrico es optimista"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold"))

print(grafica_param)

# =============================================================================
# PARTE 7: VaR POR SIMULACIÓN MONTE CARLO
# =============================================================================
# CONCEPTO:
# Monte Carlo genera miles de escenarios hipotéticos de rendimientos futuros
# a partir de parámetros estadísticos estimados del historial. Luego calcula
# el VaR como el cuantil de esa distribución simulada.
#
# VENTAJAS:
#   + Puede incorporar distribuciones no normales (con colas pesadas)
#   + Permite modelar correlaciones complejas entre activos
#   + Flexible para modelar opciones y derivados no lineales
#   + Mayor precisión con muchas simulaciones
#
# DESVENTAJAS:
#   − Computacionalmente costoso (aunque manejable en R moderno)
#   − Depende de los parámetros del modelo asumido
#   − Riesgo de modelo ("garbage in, garbage out")
# =============================================================================

cat("\n=========================================================\n")
cat("  MÉTODO 3: VaR POR SIMULACIÓN MONTE CARLO\n")
cat("=========================================================\n\n")

# Parámetros para la simulación
n_simulaciones <- 100000  # 100,000 escenarios
set.seed(2024)

cat(sprintf("Número de simulaciones: %s\n\n", format(n_simulaciones, big.mark=",")))

# -------------------------------------------------------
# MÉTODO 3A: Monte Carlo con distribución Normal
# (igual que el paramétrico, pero calculado por simulación)
# -------------------------------------------------------
cat("--- 3A: Monte Carlo Normal ---\n")

# Simular rendimientos del portafolio: r ~ N(μ, σ²)
r_sim_normal <- rnorm(n_simulaciones, mean = mu_port, sd = sigma_port)

var_mc_normal <- sapply(niveles_confianza, function(nc) {
  quantile(r_sim_normal, probs = 1 - nc)
})
names(var_mc_normal) <- paste0("VaR_", niveles_confianza*100, "%")

for (i in seq_along(niveles_confianza)) {
  cat(sprintf("  Confianza %3.0f%%: VaR = %7.4f%% | Pérdida = $%10.0f MXN\n",
              niveles_confianza[i]*100,
              var_mc_normal[i]*100,
              var_mc_normal[i]*valor_portafolio))
}

# -------------------------------------------------------
# MÉTODO 3B: Monte Carlo con distribución t de Student
# (mejor para capturar colas pesadas)
# -------------------------------------------------------
cat("\n--- 3B: Monte Carlo con distribución t de Student ---\n")
cat("(La distribución t tiene colas más pesadas que la normal)\n\n")

# Estimar los grados de libertad de la distribución t que mejor ajusta
# Esto se puede hacer por máxima verosimilitud con la librería MASS
fit_t <- tryCatch({
  # Estandarizar rendimientos
  r_std <- (rend_port_mv - mu_port) / sigma_port
  # Ajustar distribución t estándar
  MASS::fitdistr(r_std, "t")
}, error = function(e) {
  cat("  (ajuste t falló, usando df = 5)\n")
  list(estimate = c(m = 0, s = 1, df = 5))
})

df_estimados <- fit_t$estimate["df"]
cat(sprintf("Grados de libertad estimados: %.2f\n", df_estimados))
cat("(df < 30 sugiere colas pesadas significativas)\n\n")

# Simular con distribución t escalada
r_sim_t <- mu_port + sigma_port * rt(n_simulaciones, df = df_estimados)

var_mc_t <- sapply(niveles_confianza, function(nc) {
  quantile(r_sim_t, probs = 1 - nc)
})

for (i in seq_along(niveles_confianza)) {
  cat(sprintf("  Confianza %3.0f%%: VaR = %7.4f%% | Pérdida = $%10.0f MXN\n",
              niveles_confianza[i]*100,
              var_mc_t[i]*100,
              var_mc_t[i]*valor_portafolio))
}

# -------------------------------------------------------
# MÉTODO 3C: Monte Carlo multivariado (correlaciones reales)
# -------------------------------------------------------
# Este es el enfoque más realista: simula los rendimientos de cada activo
# respetando las correlaciones entre ellos usando la descomposición de Cholesky
# =============================================================================
# ÁLGEBRA LINEAL: DESCOMPOSICIÓN DE CHOLESKY
# Si Σ es la matriz de covarianza del portafolio, existe una matriz triangular
# inferior L tal que Σ = L × L' (descomposición de Cholesky).
# Para generar vectores correlacionados:
#   z ~ N(0, I)  (vectores independientes)
#   r = μ + L × z  (vectores correlacionados con Cov = Σ)
# =============================================================================

cat("\n--- 3C: Monte Carlo Multivariado con correlaciones (Cholesky) ---\n\n")

# Vector de medias y matriz de covarianza
mu_vector <- colMeans(rend_matrix)
Sigma_cov <- cov(rend_matrix)

# Descomposición de Cholesky
L_chol <- chol(Sigma_cov)
cat("Matriz L (Cholesky) — triangular superior:\n")
print(round(L_chol, 6))

# Generar rendimientos simulados correlacionados
# z: matriz de normales estándar independientes (n_sim × n_activos)
z       <- matrix(rnorm(n_simulaciones * n_activos),
                  nrow = n_simulaciones, ncol = n_activos)
# Transformar: r_sim = mu + z × L (preserva covarianzas)
r_sim_mv <- sweep(z %*% L_chol, 2, mu_vector, "+")

# Rendimiento del portafolio para cada escenario simulado
r_sim_port <- r_sim_mv %*% pesos_mv

cat(sprintf("\nVerificación de la simulación:\n"))
cat(sprintf("  σ simulada vs. real: %.6f vs. %.6f\n",
            sd(r_sim_port), sigma_port))
cat(sprintf("  ρ(sim_1, sim_2) vs. real: %.4f vs. %.4f\n",
            cor(r_sim_mv[,1], r_sim_mv[,2]),
            cor(rend_matrix[,1], rend_matrix[,2])))

var_mc_mv <- sapply(niveles_confianza, function(nc) {
  quantile(r_sim_port, probs = 1 - nc)
})

cat("\n")
for (i in seq_along(niveles_confianza)) {
  cat(sprintf("  Confianza %3.0f%%: VaR = %7.4f%% | Pérdida = $%10.0f MXN\n",
              niveles_confianza[i]*100,
              var_mc_mv[i]*100,
              var_mc_mv[i]*valor_portafolio))
}

# =============================================================================
# VISUALIZACIÓN 3: Comparación de distribuciones simuladas
# =============================================================================

df_sims <- data.frame(
  rendimiento  = c(r_sim_normal, r_sim_t, as.numeric(r_sim_port)),
  metodo       = rep(c("Normal", "t-Student", "Cholesky Multivariado"),
                     each = n_simulaciones)
)

# Para eficiencia gráfica, muestrar solo 10,000 puntos
set.seed(42)
idx_muestra <- sample(1:n_simulaciones, 10000)

df_sims_muestra <- data.frame(
  rendimiento = c(r_sim_normal[idx_muestra],
                  r_sim_t[idx_muestra],
                  as.numeric(r_sim_port)[idx_muestra]),
  metodo = rep(c("Normal", "t-Student", "Cholesky Multivariado"),
               each = 10000)
)

# VaR al 95% para cada método
var_lines <- data.frame(
  metodo = c("Normal", "t-Student", "Cholesky Multivariado"),
  var95  = c(quantile(r_sim_normal, 0.05),
             quantile(r_sim_t, 0.05),
             quantile(as.numeric(r_sim_port), 0.05))
)

grafica_mc <- ggplot(df_sims_muestra, aes(x = rendimiento, fill = metodo)) +
  geom_density(alpha = 0.4) +
  geom_vline(data = var_lines, aes(xintercept = var95, color = metodo),
             linewidth = 1.2, linetype = "dashed") +
  # Datos históricos reales como referencia
  geom_density(data = data.frame(rendimiento = rend_port_mv, metodo = "Histórico"),
               aes(x = rendimiento), inherit.aes = FALSE,
               color = "black", linewidth = 1, linetype = "solid") +
  scale_fill_manual(values = c("Normal"                = "#42A5F5",
                               "t-Student"             = "#EF5350",
                               "Cholesky Multivariado" = "#66BB6A")) +
  scale_color_manual(values = c("Normal"                = "#1565C0",
                                "t-Student"             = "#B71C1C",
                                "Cholesky Multivariado" = "#1B5E20")) +
  xlim(c(-0.10, 0.08)) +
  labs(
    title    = "Distribuciones Simuladas — Monte Carlo (3 métodos)",
    subtitle = "Líneas punteadas = VaR al 95% | Línea negra = distribución histórica real",
    x        = "Rendimiento Logarítmico Diario",
    y        = "Densidad",
    fill     = "Método de simulación",
    color    = "VaR 95%",
    caption  = "10,000 escenarios mostrados de 100,000 simulados"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold"))

print(grafica_mc)

# =============================================================================
# PARTE 8: COMPARACIÓN DE MÉTODOS Y TABLA RESUMEN
# =============================================================================
# La comparación entre métodos es fundamental en la práctica profesional.
# Los tres métodos pueden dar resultados distintos porque:
#   • Histórico: usa la distribución real de las pérdidas pasadas
#   • Paramétrico: asume normalidad (subestima colas pesadas)
#   • Monte Carlo: depende del modelo de distribución elegido
# =============================================================================

cat("\n=========================================================\n")
cat("  TABLA COMPARATIVA: LOS TRES MÉTODOS\n")
cat("=========================================================\n\n")

tabla_comparativa <- data.frame(
  Metodo         = c("Histórico", "Paramétrico (Normal)",
                     "Monte Carlo Normal", "Monte Carlo t-Student",
                     "Monte Carlo Cholesky"),
  VaR_90_pct     = NA_real_,
  VaR_95_pct     = NA_real_,
  VaR_99_pct     = NA_real_,
  VaR_95_MXN     = NA_real_
)

# Histórico
tabla_comparativa[1, 2:5] <- c(
  var_historico(rend_port_mv, 0.90, 1)$var_pct * 100,
  var_historico(rend_port_mv, 0.95, 1)$var_pct * 100,
  var_historico(rend_port_mv, 0.99, 1)$var_pct * 100,
  var_historico(rend_port_mv, 0.95, valor_portafolio)$var_mxn
)

# Paramétrico
tabla_comparativa[2, 2:5] <- c(
  var_parametrico(mu_port, sigma_port, 0.90, 1)$var_pct * 100,
  var_parametrico(mu_port, sigma_port, 0.95, 1)$var_pct * 100,
  var_parametrico(mu_port, sigma_port, 0.99, 1)$var_pct * 100,
  var_parametrico(mu_port, sigma_port, 0.95, valor_portafolio)$var_mxn
)

# Monte Carlo Normal
tabla_comparativa[3, 2:5] <- c(
  quantile(r_sim_normal, 0.10) * 100,
  quantile(r_sim_normal, 0.05) * 100,
  quantile(r_sim_normal, 0.01) * 100,
  quantile(r_sim_normal, 0.05) * valor_portafolio
)

# Monte Carlo t-Student
tabla_comparativa[4, 2:5] <- c(
  quantile(r_sim_t, 0.10) * 100,
  quantile(r_sim_t, 0.05) * 100,
  quantile(r_sim_t, 0.01) * 100,
  quantile(r_sim_t, 0.05) * valor_portafolio
)

# Monte Carlo Cholesky
tabla_comparativa[5, 2:5] <- c(
  quantile(r_sim_port, 0.10) * 100,
  quantile(r_sim_port, 0.05) * 100,
  quantile(r_sim_port, 0.01) * 100,
  quantile(r_sim_port, 0.05) * valor_portafolio
)

tabla_comparativa[, 2:4] <- round(tabla_comparativa[, 2:4], 4)
tabla_comparativa[, 5]   <- round(tabla_comparativa[, 5], 0)

cat("VaR como % del portafolio y en MXN (portafolio = $1,000,000 MXN)\n\n")
print(tabla_comparativa, row.names = FALSE)

cat("\nCONCLUSIÓN COMPARATIVA:\n")
cat("• El VaR paramétrico SUBESTIMA el riesgo frente al histórico (por supuesto normal)\n")
cat("• El Monte Carlo t-Student está más cercano al histórico (colas pesadas)\n")
cat("• La diferencia en VaR 99% puede ser sustancial: es en las colas donde divergen\n")

# =============================================================================
# PARTE 9: VISUALIZACIÓN FINAL — COMPARACIÓN GRÁFICA
# =============================================================================

df_tabla_long <- data.frame(
  Metodo    = rep(tabla_comparativa$Metodo, 3),
  Confianza = rep(c("90%", "95%", "99%"), each = nrow(tabla_comparativa)),
  VaR_abs   = c(abs(tabla_comparativa$VaR_90_pct),
                abs(tabla_comparativa$VaR_95_pct),
                abs(tabla_comparativa$VaR_99_pct))
)
df_tabla_long$Confianza <- factor(df_tabla_long$Confianza,
                                   levels = c("90%", "95%", "99%"))

grafica_comparativa <- ggplot(df_tabla_long,
                               aes(x = Metodo, y = VaR_abs, fill = Confianza)) +
  geom_bar(stat = "identity", position = "dodge", alpha = 0.85) +
  scale_fill_manual(values = c("90%" = "#90CAF9",
                               "95%" = "#1E88E5",
                               "99%" = "#0D47A1")) +
  labs(
    title    = "Comparación de VaR por Método y Nivel de Confianza",
    subtitle = "Portafolio MV — $1,000,000 MXN",
    x        = "Método",
    y        = "VaR (% del portafolio, valor absoluto)",
    fill     = "Confianza",
    caption  = "Mayor barra = mayor pérdida potencial estimada"
  ) +
  theme_minimal(base_size = 12) +
  theme(axis.text.x  = element_text(angle = 20, hjust = 1, size = 9),
        legend.position = "top",
        plot.title    = element_text(face = "bold")) +
  coord_flip()

print(grafica_comparativa)

# =============================================================================
# PARTE 10: LIMITACIONES DEL VaR Y MENCIÓN DE CVaR
# =============================================================================
# El VaR, a pesar de su popularidad regulatoria, tiene una debilidad:
# NO dice nada sobre QUÉ TAN GRANDES son las pérdidas más allá del umbral.
#
# Ejemplo: si VaR(99%) = -3%, puede ser que:
#   • En el 1% de los días peores, las pérdidas van entre -3% y -4%
#       → pérdida esperada en cola ≈ -3.5%  (relativamente controlado)
#   • O que en el 1% de los días peores, las pérdidas van entre -3% y -20%
#       → pérdida esperada en cola ≈ -8%    (¡mucho más preocupante!)
#
# El VaR no distingue entre estos dos casos.
# La Sesión 8 introduce el CVaR (Expected Shortfall), que sí mide
# la pérdida ESPERADA dado que se superó el VaR.
# =============================================================================

cat("\n=========================================================\n")
cat("  ANTICIPO: LIMITACIONES DEL VaR → CVaR (Sesión 8)\n")
cat("=========================================================\n\n")

# Calcular CVaR histórico (anticipo de la próxima sesión)
calcular_cvar_historico <- function(rendimientos_vec, nivel_confianza) {
  alpha        <- 1 - nivel_confianza
  umbral_var   <- quantile(rendimientos_vec, probs = alpha)
  tail_obs     <- rendimientos_vec[rendimientos_vec <= umbral_var]
  cvar         <- mean(tail_obs)
  return(list(var = umbral_var, cvar = cvar, n_obs_cola = length(tail_obs)))
}

cat("--- Comparación VaR vs. CVaR al 95% ---\n\n")

resultado_cvar <- calcular_cvar_historico(rend_port_mv, 0.95)
cat(sprintf("  VaR  histórico (95%%): %7.4f%%  → en el 5%% peor de los días,\n",
            resultado_cvar$var * 100))
cat(sprintf("                              la pérdida MÍNIMA es %.4f%%\n",
            resultado_cvar$var * 100))
cat(sprintf("  CVaR histórico (95%%): %7.4f%%  → en el 5%% peor de los días,\n",
            resultado_cvar$cvar * 100))
cat(sprintf("                              la pérdida PROMEDIO es %.4f%%\n",
            resultado_cvar$cvar * 100))
cat(sprintf("\n  Observaciones en cola: %d (de %d total)\n",
            resultado_cvar$n_obs_cola, length(rend_port_mv)))
cat(sprintf("  CVaR / VaR = %.2fx → las pérdidas extremas son %.2f veces el VaR\n\n",
            resultado_cvar$cvar / resultado_cvar$var,
            resultado_cvar$cvar / resultado_cvar$var))

cat("INTERPRETACIÓN: El CVaR nos dice que, dado que ya superamos el VaR,\n")
cat("la pérdida promedio es aún mayor. Este será el tema central de la Sesión 8.\n")

# =============================================================================
# ============================================================================
#                       EJERCICIOS PRÁCTICOS
# ============================================================================
# Los siguientes 7 ejercicios son para trabajo en clase o como tarea.
# Se ordenan de menor a mayor complejidad.
# =============================================================================

cat("\n\n")
cat("============================================================\n")
cat("               EJERCICIOS DE LA SESIÓN 7\n")
cat("============================================================\n\n")

# ----------------------------------------------------------------------------
# EJERCICIO 1 (BÁSICO): Cálculo manual del VaR histórico
# ----------------------------------------------------------------------------
cat("EJERCICIO 1: VaR Histórico Manual\n")
cat("----------------------------------\n")
cat("Dado el siguiente vector de rendimientos diarios (simulados),\n")
cat("calcula el VaR al 95% y al 99% SIN usar funciones predefinidas.\n\n")

set.seed(123)
rend_ejercicio <- rnorm(500, mean = 0.0005, sd = 0.015)

cat("Instrucciones:\n")
cat("1. Ordena el vector de rendimientos de menor a mayor\n")
cat("2. Identifica las posiciones correspondientes a los cuantiles 5% y 1%\n")
cat("3. Extrae los valores en esas posiciones\n\n")

# Pista: ordena y extrae cuantiles
rend_ordenados <- sort(rend_ejercicio)
n_rend         <- length(rend_ordenados)

# ¿Qué posición corresponde al percentil 5% de 500 observaciones?
pos_5pct <- floor(0.05 * n_rend)
pos_1pct <- floor(0.01 * n_rend)

cat(sprintf("Número de observaciones: %d\n", n_rend))
cat(sprintf("Posición percentil 5%%: %d → rendimiento: %.4f%%\n",
            pos_5pct, rend_ordenados[pos_5pct]*100))
cat(sprintf("Posición percentil 1%%: %d → rendimiento: %.4f%%\n",
            pos_1pct, rend_ordenados[pos_1pct]*100))
cat("\nVerificación con quantile():\n")
cat(sprintf("  VaR 95%%: %.4f%% | VaR 99%%: %.4f%%\n\n",
            quantile(rend_ejercicio, 0.05)*100,
            quantile(rend_ejercicio, 0.01)*100))

# ----------------------------------------------------------------------------
# EJERCICIO 2 (BÁSICO): VaR paramétrico desde cero
# ----------------------------------------------------------------------------
cat("EJERCICIO 2: VaR Paramétrico Paso a Paso\n")
cat("-----------------------------------------\n")
cat("Usando los datos de WALMEX.MX únicamente:\n\n")

rend_walmex <- as.numeric(rendimientos[, "WALMEX.MX"])
mu_w        <- mean(rend_walmex)
sigma_w     <- sd(rend_walmex)
valor_inv   <- 500000  # $500,000 MXN

cat(sprintf("Media diaria: %.6f\n", mu_w))
cat(sprintf("Desv. Est.:   %.6f\n", sigma_w))
cat(sprintf("Inversión:    $%s MXN\n\n", format(valor_inv, big.mark=",")))

# Calculamos el VaR al 95%
z_95_w    <- qnorm(0.05)
var_w_95  <- mu_w + z_95_w * sigma_w
var_w_mxn <- var_w_95 * valor_inv

cat(sprintf("z_{0.05} = qnorm(0.05) = %.4f\n", z_95_w))
cat(sprintf("VaR = μ + z × σ = %.6f + (%.4f × %.6f) = %.4f%%\n",
            mu_w, z_95_w, sigma_w, var_w_95*100))
cat(sprintf("Pérdida máxima (95%%) en $500,000 MXN: $%.0f MXN\n\n",
            var_w_mxn))

# Comparar con VaR histórico de WALMEX
var_w_hist <- quantile(rend_walmex, 0.05)
cat(sprintf("Comparación: VaR histórico = %.4f%% | VaR paramétrico = %.4f%%\n",
            var_w_hist*100, var_w_95*100))
cat(sprintf("Diferencia: %.4f%% (si > 0: paramétrico subestima riesgo)\n\n",
            (var_w_95 - var_w_hist)*100))

# ----------------------------------------------------------------------------
# EJERCICIO 3 (INTERMEDIO): Comparación entre acciones
# ----------------------------------------------------------------------------
cat("EJERCICIO 3: Ranking de Riesgo por VaR\n")
cat("--------------------------------------\n")
cat("Calcula el VaR histórico al 95% para cada acción individual\n")
cat("y construye un ranking de mayor a menor riesgo.\n\n")

tabla_ranking <- data.frame(
  Accion        = colnames(rendimientos),
  Media_diaria  = NA_real_,
  Sigma_diaria  = NA_real_,
  VaR_hist_95   = NA_real_,
  VaR_param_95  = NA_real_
)

for (i in 1:n_activos) {
  r_i <- as.numeric(rendimientos[, i])
  tabla_ranking$Media_diaria[i]  <- mean(r_i) * 100
  tabla_ranking$Sigma_diaria[i]  <- sd(r_i) * 100
  tabla_ranking$VaR_hist_95[i]   <- quantile(r_i, 0.05) * 100
  tabla_ranking$VaR_param_95[i]  <- (mean(r_i) + qnorm(0.05)*sd(r_i)) * 100
}

tabla_ranking <- tabla_ranking[order(tabla_ranking$VaR_hist_95), ]
tabla_ranking[, 2:5] <- round(tabla_ranking[, 2:5], 4)

cat("Ranking de riesgo (de mayor a menor pérdida potencial):\n")
print(tabla_ranking, row.names = FALSE)
cat("\nInterpretación: el activo en primer lugar tiene el VaR más negativo,\n")
cat("es decir, es el que puede perder más en el 5% de los peores días.\n\n")

# ----------------------------------------------------------------------------
# EJERCICIO 4 (INTERMEDIO): Efecto de diversificación en el VaR
# ----------------------------------------------------------------------------
cat("EJERCICIO 4: Diversificación y Reducción del VaR\n")
cat("-------------------------------------------------\n")
cat("Compara el VaR paramétrico 'suma' (sin diversificación) con el\n")
cat("VaR real del portafolio para cuantificar el beneficio de diversificar.\n\n")

# VaR individual de cada activo al 95%
var_individuales <- sapply(1:n_activos, function(i) {
  r_i <- as.numeric(rendimientos[, i])
  mean(r_i) + qnorm(0.05) * sd(r_i)
})

# VaR "no diversificado" = suma ponderada de VaR individuales
var_no_div <- sum(pesos_mv * var_individuales)

# VaR real del portafolio (paramétrico)
var_port_param <- var_param_95$var_pct

cat(sprintf("VaR portafolio (suma ponderada, sin correlación): %7.4f%%\n",
            var_no_div * 100))
cat(sprintf("VaR portafolio (paramétrico, con correlación):    %7.4f%%\n",
            var_port_param * 100))
cat(sprintf("Beneficio de diversificación:                     %7.4f%%\n",
            (var_no_div - var_port_param) * 100))
cat(sprintf("Reducción relativa:                               %7.2f%%\n\n",
            (1 - var_port_param / var_no_div) * 100))

cat("Este ejercicio muestra que un portafolio diversificado tiene MENOS\n")
cat("riesgo que la suma del riesgo de sus partes. El VaR del portafolio\n")
cat("es siempre ≤ suma ponderada de VaR individuales (propiedad de subaditividad).\n\n")

# ----------------------------------------------------------------------------
# EJERCICIO 5 (INTERMEDIO): Sensibilidad del VaR al tamaño de la muestra
# ----------------------------------------------------------------------------
cat("EJERCICIO 5: Estabilidad del VaR Histórico según el Horizonte\n")
cat("-------------------------------------------------------------\n")
cat("Calcula el VaR histórico al 95% usando distintas ventanas de historia\n")
cat("para explorar cómo el período elegido afecta el resultado.\n\n")

ventanas_hist <- c(63, 126, 252, 504, length(rend_port_mv))

cat(sprintf("  %-20s %-12s %-12s %-12s\n",
            "Ventana", "N obs", "VaR 95% (%)", "VaR 99% (%)"))
cat(paste(rep("-", 56), collapse=""), "\n")

for (v in ventanas_hist) {
  r_ventana <- tail(rend_port_mv, v)
  var_v_95  <- quantile(r_ventana, 0.05)
  var_v_99  <- quantile(r_ventana, 0.01)
  desc      <- ifelse(v == 63, "~3 meses", ifelse(v == 126, "~6 meses",
               ifelse(v == 252, "~1 año", ifelse(v == 504, "~2 años", "Full"))))
  cat(sprintf("  %-20s %-12d %-12.4f %-12.4f\n",
              desc, v, var_v_95*100, var_v_99*100))
}
cat("\nConclusión: el VaR histórico es sensible al período elegido.\n")
cat("Ventanas cortas reflejan el entorno reciente; ventanas largas suavizan.\n\n")

# ----------------------------------------------------------------------------
# EJERCICIO 6 (AVANZADO): Monte Carlo para un solo activo con drift
# ----------------------------------------------------------------------------
cat("EJERCICIO 6: Monte Carlo con Movimiento Browniano Geométrico\n")
cat("------------------------------------------------------------\n")
cat("Simula el precio de FEMSAUBD.MX a 21 días hábiles (1 mes) usando\n")
cat("un modelo de Movimiento Browniano Geométrico (GBM).\n\n")

# GBM: S(t) = S(0) × exp((μ - σ²/2)×t + σ×√t×z)
# donde z ~ N(0,1)

rend_fem   <- as.numeric(rendimientos[, "FEMSAUBD.MX"])
mu_fem     <- mean(rend_fem)
sigma_fem  <- sd(rend_fem)
S0_fem     <- as.numeric(tail(precios[, "FEMSAUBD.MX"], 1))
T_dias     <- 21
n_sim_gbm  <- 50000

cat(sprintf("Precio inicial (S₀):  $%.2f MXN\n", S0_fem))
cat(sprintf("μ diaria:              %.6f\n", mu_fem))
cat(sprintf("σ diaria:              %.6f\n", sigma_fem))
cat(sprintf("Horizonte:             %d días hábiles\n\n", T_dias))

# Simulación GBM: precio final en T días
# S(T) = S(0) × exp( (μ - σ²/2)×T + σ×√T×z )
z_gbm  <- rnorm(n_sim_gbm)
S_T    <- S0_fem * exp((mu_fem - 0.5 * sigma_fem^2) * T_dias +
                        sigma_fem * sqrt(T_dias) * z_gbm)

# Rendimiento del período
r_gbm_T <- log(S_T / S0_fem)

# VaR del período
var_gbm_95 <- quantile(r_gbm_T, 0.05)
var_gbm_99 <- quantile(r_gbm_T, 0.01)

cat(sprintf("Precio esperado en 21 días: $%.2f MXN\n", mean(S_T)))
cat(sprintf("Percentil  5%% del precio:  $%.2f MXN\n", quantile(S_T, 0.05)))
cat(sprintf("Percentil  1%% del precio:  $%.2f MXN\n\n", quantile(S_T, 0.01)))
cat(sprintf("VaR 95%% (21 días): %.4f%% → Pérdida: $%.2f MXN por acción\n",
            var_gbm_95*100, var_gbm_95*S0_fem))
cat(sprintf("VaR 99%% (21 días): %.4f%% → Pérdida: $%.2f MXN por acción\n\n",
            var_gbm_99*100, var_gbm_99*S0_fem))

# Verificación: ¿Coincide con la regla √T del VaR paramétrico?
var_1d_fem   <- mu_fem + qnorm(0.05)*sigma_fem
var_21d_sqrt <- var_1d_fem * sqrt(T_dias)
cat(sprintf("Comparación regla √21 vs Monte Carlo:\n"))
cat(sprintf("  Regla √21:     %.4f%%\n", var_21d_sqrt*100))
cat(sprintf("  Monte Carlo:   %.4f%%\n\n", var_gbm_95*100))

# ----------------------------------------------------------------------------
# EJERCICIO 7 (AVANZADO): Análisis de Crisis — VaR durante COVID-19
# ----------------------------------------------------------------------------
cat("EJERCICIO 7: VaR Durante la Crisis COVID-19\n")
cat("--------------------------------------------\n")
cat("Compara el VaR calculado ANTES de la crisis (2019) con el VaR\n")
cat("calculado DURANTE la crisis (2020 Q1) para analizar cómo\n")
cat("fallan los modelos de riesgo en períodos de estrés.\n\n")

# Nota: necesitamos datos adicionales para 2018-2019
cat("Descargando datos extendidos (2018-2021) para análisis de crisis...\n")

tickers_crisis <- c("WALMEX.MX", "GFNORTEO.MX", "CEMEXCPO.MX", "FEMSAUBD.MX")
precios_crisis <- tryCatch({
  p_lista <- lapply(tickers_crisis, function(tk) {
    d <- getSymbols(tk, src="yahoo", from="2018-01-01", to="2021-12-31",
                    auto.assign=FALSE)
    p <- Ad(d); colnames(p) <- tk; p
  })
  do.call(merge, p_lista)
}, error = function(e) {
  cat("  (Usando datos ya descargados como proxy)\n")
  precios
})

rend_crisis <- diff(log(precios_crisis))
rend_crisis <- na.omit(rend_crisis)

# Calcular rendimientos del portafolio con pesos MV
r_port_crisis <- as.numeric(rend_crisis %*% pesos_mv)
fechas_crisis <- index(rend_crisis)

# Definir ventanas de análisis
pre_covid  <- r_port_crisis[fechas_crisis >= "2019-01-01" &
                              fechas_crisis <= "2019-12-31"]
dur_covid  <- r_port_crisis[fechas_crisis >= "2020-02-01" &
                              fechas_crisis <= "2020-06-30"]

if (length(pre_covid) > 10 && length(dur_covid) > 10) {
  var_pre  <- quantile(pre_covid, 0.05)
  var_dur  <- quantile(dur_covid, 0.05)

  cat(sprintf("Período pre-COVID  (2019):       N=%d obs\n", length(pre_covid)))
  cat(sprintf("  VaR histórico 95%%:   %7.4f%%\n", var_pre*100))
  cat(sprintf("  Desv. Est. diaria:   %7.4f%%\n\n", sd(pre_covid)*100))
  cat(sprintf("Período COVID (Feb-Jun 2020):    N=%d obs\n", length(dur_covid)))
  cat(sprintf("  VaR histórico 95%%:   %7.4f%%\n", var_dur*100))
  cat(sprintf("  Desv. Est. diaria:   %7.4f%%\n\n", sd(dur_covid)*100))
  cat(sprintf("Incremento del VaR en crisis:    %.1fx más severo\n",
              var_dur/var_pre))
  cat("\n")
  cat("LECCIÓN CLAVE: El VaR calculado con datos pre-COVID era inadecuado\n")
  cat("para predecir las pérdidas de la crisis. Esto motiva:\n")
  cat("  • El stress testing (Sesión 10): simular escenarios de crisis\n")
  cat("  • El VaR condicional GARCH (Sesión 9): volatilidad tiempo-variable\n")
  cat("  • El CVaR (Sesión 8): qué pasa CUANDO se supera el VaR\n")
} else {
  cat("(Datos insuficientes para el período solicitado — ajustar fechas)\n\n")
  cat("Intenta ejecutar con más historia (2017-2024) para ver el contraste.\n\n")
}

# =============================================================================
# RESUMEN EJECUTIVO DE LA SESIÓN
# =============================================================================

cat("\n")
cat("============================================================\n")
cat("              RESUMEN EJECUTIVO — SESIÓN 7\n")
cat("============================================================\n\n")
cat("CONCEPTOS CLAVE:\n")
cat("  • VaR = cuantil de la distribución de pérdidas al nivel (1-α)\n")
cat("  • Histórico: no paramétrico, usa datos reales, transparente\n")
cat("  • Paramétrico: asume normalidad, rápido, descomponible\n")
cat("  • Monte Carlo: flexible, costoso, depende del modelo\n\n")
cat("RESULTADO DEL PORTAFOLIO MV ($1,000,000 MXN):\n")
cat(sprintf("  VaR histórico  95%%: %7.4f%%  ($%10.0f MXN)\n",
            var_hist_95$var_pct*100, var_hist_95$var_mxn))
cat(sprintf("  VaR paramétrico95%%: %7.4f%%  ($%10.0f MXN)\n",
            var_param_95$var_pct*100, var_param_95$var_mxn))
cat("\nPRÓXIMA SESIÓN (8): CVaR y medidas coherentes\n")
cat("  El CVaR dice qué pasa MÁS ALLÁ del VaR — medida más completa.\n\n")
cat("Sesión completada — Facultad de Economía UNAM\n")
cat("Ismael Valverde | ismael_val@economia.unam.mx\n")
cat("============================================================\n")
