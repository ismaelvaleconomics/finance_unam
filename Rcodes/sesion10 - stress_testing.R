# =============================================================================
# MERCADO DE CAPITALES — FACULTAD DE ECONOMÍA, UNAM
# SESIÓN 10: STRESS TESTING
# =============================================================================
# Profesor: Ismael Valverde | ismael_val@economia.unam.mx
# Prerrequisitos: Sesiones 7–9 (VaR, CVaR y GARCH)
# =============================================================================
#
# OBJETIVO DE LA SESIÓN
# El VaR y el CVaR responden "¿qué pérdida esperar en el peor X% de los
# días normales?". El stress testing responde algo distinto: "¿qué le
# pasa al portafolio en un escenario extremo específico, ocurrido o no?"
#
# Hay dos familias de escenarios:
#   1. Stress histórico: reproducir lo que ocurrió en crisis pasadas
#      (crisis Tequila 1994, crisis global 2008, COVID 2020, etc.)
#   2. Stress hipotético: diseñar shocks plausibles que aún no han ocurrido
#      (colapso del peso, subida brusca de tasas, shock de materias primas)
#
# Al finalizar podrás:
#   1. Distinguir el stress testing del VaR y entender por qué se complementan
#   2. Aplicar escenarios históricos al portafolio actual
#   3. Diseñar escenarios hipotéticos con shocks a factores de riesgo
#   4. Construir una matriz de sensibilidad (factor shock × activo)
#   5. Calcular pérdidas y ganancias bajo cada escenario en pesos MXN
#   6. Presentar los resultados en un reporte de stress resumen
#
# LIBRERÍAS NECESARIAS
# install.packages(c("quantmod","rugarch","PerformanceAnalytics",
#                    "tidyverse","ggplot2","gridExtra","scales"))
# =============================================================================

library(quantmod)
library(rugarch)
library(PerformanceAnalytics)
library(tidyverse)
library(ggplot2)
library(gridExtra)
library(scales)

set.seed(2024)

# =============================================================================
# PARTE 1: STRESS TESTING VS. VaR — DOS PREGUNTAS DISTINTAS
# =============================================================================
# El VaR y el CVaR son medidas estadísticas: describen la distribución
# de pérdidas bajo condiciones de mercado "normales" o "típicas",
# incluyendo los peores episodios del período histórico observado.
#
# El stress testing es una evaluación de escenarios: aplica shocks
# específicos y calcula cuánto perdería el portafolio exactamente.
# No pregunta "¿con qué probabilidad?" sino "¿cuánto si...?"
#
# COMPLEMENTARIEDAD:
#   VaR (Sesión 7):     pérdida en el 5% peor de los días — basado en historia
#   CVaR (Sesión 8):    promedio de pérdidas en esa cola  — severidad esperada
#   GARCH (Sesión 9):   volatilidad dinámica              — estado actual
#   Stress (Sesión 10): pérdida bajo un escenario puntual — qué pasa si ocurre X
#
# Los cuatro son complementarios. El stress testing es especialmente útil
# para eventos que son raros o que no aparecen en la historia disponible,
# pero que los reguladores, directivos o clientes quieren entender.
# =============================================================================

cat("=========================================================\n")
cat("  SESIÓN 10: STRESS TESTING\n")
cat("  Facultad de Economía — UNAM\n")
cat("=========================================================\n\n")

cat("Stress testing: ¿cuánto pierde el portafolio si ocurre X?\n")
cat("A diferencia del VaR, no pregunta con qué probabilidad.\n")
cat("Pregunta: dado que el escenario ocurre, ¿cuál es el impacto?\n\n")

# =============================================================================
# PARTE 2: DESCARGA DE DATOS
# =============================================================================

cat(">>> Descargando datos de la BMV...\n")

tickers      <- c("WALMEX.MX", "GFNORTEO.MX", "CEMEXCPO.MX", "FEMSAUBD.MX")
fecha_inicio <- "2005-01-01"   # historia larga para capturar varias crisis
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

rendimientos  <- diff(log(precios))
rendimientos  <- na.omit(rendimientos)
fechas        <- index(rendimientos)
n_obs         <- nrow(rendimientos)

# Portafolio MV (pesos de sesiones anteriores)
pesos_mv      <- c(0.30, 0.25, 0.20, 0.25)
names(pesos_mv) <- colnames(rendimientos)

rend_port     <- as.numeric(rendimientos %*% pesos_mv)
valor_port    <- 1e6   # $1,000,000 MXN

# Precios actuales (último día disponible)
precios_actuales <- as.numeric(tail(precios, 1))
names(precios_actuales) <- colnames(precios)

# Valor de cada posición en el portafolio
valor_posiciones <- pesos_mv * valor_port
names(valor_posiciones) <- colnames(rendimientos)

cat(sprintf("\nObservaciones: %d días | Período: %s a %s\n\n",
            n_obs, format(fechas[1]), format(fechas[n_obs])))

cat("--- Composición actual del portafolio ---\n\n")
cat(sprintf("  %-15s  %8s  %12s  %12s\n",
            "Activo", "Peso", "Valor (MXN)", "Precio actual"))
cat(paste(rep("-", 52), collapse = ""), "\n")
for (i in seq_along(tickers)) {
  if (tickers[i] %in% names(precios_actuales)) {
    cat(sprintf("  %-15s  %8.2f%%  %12.0f  %12.2f\n",
                tickers[i],
                pesos_mv[i] * 100,
                valor_posiciones[i],
                precios_actuales[tickers[i]]))
  }
}
cat(sprintf("  %-15s  %8s  %12.0f\n", "TOTAL", "100.00%", valor_port))

# =============================================================================
# PARTE 3: IDENTIFICACIÓN DE PERÍODOS DE ESTRÉS HISTÓRICO
# =============================================================================
# Antes de diseñar escenarios, es útil identificar empíricamente qué
# períodos del historial representan los mayores episodios de estrés.
# Esto se hace midiendo:
#   a) Las mayores caídas acumuladas (drawdowns)
#   b) Los períodos de volatilidad máxima
#   c) Los peores días individuales
# =============================================================================

cat("\n=========================================================\n")
cat("  PARTE 3: EPISODIOS HISTÓRICOS DE ESTRÉS\n")
cat("=========================================================\n\n")

# --- 3A: Mayores caídas individuales (peores días) ---
n_peores <- 15
idx_orden <- order(rend_port)
peores_dias <- data.frame(
  Fecha       = fechas[idx_orden[1:n_peores]],
  Rendimiento = round(rend_port[idx_orden[1:n_peores]] * 100, 4),
  Perdida_MXN = round(rend_port[idx_orden[1:n_peores]] * valor_port, 0)
)

cat("--- Peores 15 días del portafolio ---\n\n")
print(peores_dias, row.names = FALSE)
cat("\n")

# --- 3B: Drawdown máximo ---
# El drawdown mide la caída acumulada desde un máximo previo hasta el mínimo
# siguiente. Es la medida de pérdida más relevante para el horizonte de
# tenencia largo (no solo un día sino semanas o meses).

precios_port_idx <- cumprod(1 + rend_port)  # valor acumulado del portafolio
maximo_acum      <- cummax(precios_port_idx)
drawdown_serie   <- (precios_port_idx - maximo_acum) / maximo_acum * 100

df_dd <- data.frame(
  fecha    = fechas,
  valor    = precios_port_idx,
  drawdown = as.numeric(drawdown_serie)
)

max_dd       <- min(df_dd$drawdown)
fecha_max_dd <- fechas[which.min(df_dd$drawdown)]

cat(sprintf("--- Drawdown máximo histórico ---\n\n"))
cat(sprintf("  Drawdown máximo:  %.2f%%\n", max_dd))
cat(sprintf("  Fecha del fondo:  %s\n", format(fecha_max_dd)))
cat(sprintf("  Pérdida en $1M:   $%.0f MXN\n\n", max_dd / 100 * valor_port))

# Gráfica del drawdown
g_dd <- ggplot(df_dd, aes(x = fecha, y = drawdown)) +
  geom_area(fill = "#FFCDD2", alpha = 0.7) +
  geom_line(color = "#B71C1C", linewidth = 0.6) +
  geom_hline(yintercept = max_dd, color = "#6A1B9A",
             linetype = "dashed", linewidth = 0.8) +
  annotate("text", x = fecha_max_dd, y = max_dd - 1,
           label = sprintf("Máx. drawdown: %.1f%%", max_dd),
           color = "#6A1B9A", hjust = 0, size = 3.5) +
  labs(
    title    = "Drawdown del Portafolio MV",
    subtitle = "Caída acumulada respecto al máximo previo",
    x        = NULL, y = "Drawdown (%)"
  ) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"))

print(g_dd)

# --- 3C: Ventanas de alta volatilidad (candidatos a escenarios históricos) ---
vol_movil_63 <- zoo::rollapply(rend_port, width = 63, FUN = sd,
                                fill = NA, align = "right")

df_vol <- data.frame(
  fecha  = fechas,
  vol_63 = as.numeric(vol_movil_63) * sqrt(252) * 100
)

# Identificar el top-5 de períodos más volátiles (ventanas de 63 días)
idx_vol_orden <- order(df_vol$vol_63, decreasing = TRUE, na.last = NA)
fechas_vol_top <- fechas[idx_vol_orden[1:5]]

cat("--- Períodos de mayor volatilidad (ventana 63 días, anualizada) ---\n\n")
cat(sprintf("  %-12s  %-14s\n", "Fecha centro", "Volatilidad anual"))
cat(paste(rep("-", 30), collapse = ""), "\n")
for (i in 1:5) {
  j <- idx_vol_orden[i]
  if (!is.na(df_vol$vol_63[j])) {
    cat(sprintf("  %-12s  %14.2f%%\n",
                format(fechas[j]), df_vol$vol_63[j]))
  }
}
cat("\n")

# =============================================================================
# PARTE 4: STRESS HISTÓRICO — REPRODUCIR CRISIS PASADAS
# =============================================================================
# El stress histórico extrae los rendimientos de un período de crisis
# pasado y los aplica al portafolio actual.
#
# PROCEDIMIENTO:
#   1. Definir el período de crisis (fecha inicio y fin)
#   2. Extraer los rendimientos diarios de ese período
#   3. Calcular la pérdida/ganancia acumulada del portafolio
#   4. Escalar al valor actual del portafolio en pesos MXN
#
# SUPUESTO IMPLÍCITO:
#   Los activos en el portafolio actual habrían tenido el mismo comportamiento
#   relativo que en el período histórico. Esto no siempre se cumple (la
#   composición del portafolio puede haber cambiado) pero es una aproximación
#   útil y estándar en la industria.
# =============================================================================

cat("=========================================================\n")
cat("  PARTE 4: STRESS HISTÓRICO\n")
cat("=========================================================\n\n")

# Definición de episodios de crisis históricos relevantes para México
crisis_historicas <- list(
  list(
    nombre = "Crisis Financiera Global 2008",
    inicio = "2008-09-01",
    fin    = "2009-03-31",
    descripcion = "Quiebra de Lehman Brothers; contracción del crédito global"
  ),
  list(
    nombre = "Crisis del Precio del Petróleo 2014–2016",
    inicio = "2014-07-01",
    fin    = "2016-01-31",
    descripcion = "Caída del precio del petróleo; depreciación del MXN"
  ),
  list(
    nombre = "Resultado Electoral EUA 2016",
    inicio = "2016-11-07",
    fin    = "2016-12-31",
    descripcion = "Incertidumbre por política comercial; caída del MXN"
  ),
  list(
    nombre = "Crisis COVID-19 2020",
    inicio = "2020-02-20",
    fin    = "2020-04-30",
    descripcion = "Pandemia global; parálisis económica; crash de mercados"
  ),
  list(
    nombre = "Ciclo de alzas Fed 2022",
    inicio = "2022-01-01",
    fin    = "2022-10-31",
    descripcion = "Inflación global; Fed sube tasas; aversión al riesgo"
  )
)

# Función para calcular el impacto de un período histórico en el portafolio
stress_historico <- function(rend_mat, pesos, fechas_v, crisis, valor) {
  idx    <- fechas_v >= crisis$inicio & fechas_v <= crisis$fin
  if (sum(idx) < 5) return(NULL)

  r_crisis   <- rend_mat[idx, , drop = FALSE]
  r_port_c   <- as.numeric(r_crisis %*% pesos)
  n_dias_c   <- nrow(r_crisis)

  # Rendimiento acumulado del portafolio en el período
  rend_acum  <- prod(1 + r_port_c) - 1

  # Rendimiento acumulado de cada activo
  rend_acum_act <- sapply(1:ncol(r_crisis), function(i)
    prod(1 + r_crisis[, i]) - 1)
  names(rend_acum_act) <- colnames(rend_mat)

  # Estadísticas del período
  vol_periodo <- sd(r_port_c) * sqrt(252) * 100
  max_caida_1d <- min(r_port_c) * 100
  n_dias_neg  <- sum(r_port_c < 0)

  return(list(
    nombre       = crisis$nombre,
    descripcion  = crisis$descripcion,
    n_dias       = n_dias_c,
    rend_acum    = rend_acum * 100,
    perdida_mxn  = rend_acum * valor,
    rend_activos = rend_acum_act * 100,
    vol_periodo  = vol_periodo,
    max_caida_1d = max_caida_1d,
    n_dias_neg   = n_dias_neg
  ))
}

resultados_hist <- lapply(crisis_historicas, function(c)
  stress_historico(as.matrix(rendimientos), pesos_mv, fechas, c, valor_port))
resultados_hist <- Filter(Negate(is.null), resultados_hist)

# Tabla resumen
cat("--- Impacto de crisis históricas en el portafolio MV ---\n\n")
cat(sprintf("  %-36s  %6s  %10s  %14s  %10s\n",
            "Escenario", "Días", "Rend.(%)", "Pérdida (MXN)", "Vol.anual"))
cat(paste(rep("-", 82), collapse = ""), "\n")

for (res in resultados_hist) {
  cat(sprintf("  %-36s  %6d  %10.2f  %14.0f  %10.2f%%\n",
              substr(res$nombre, 1, 36),
              res$n_dias,
              res$rend_acum,
              res$perdida_mxn,
              res$vol_periodo))
}

# Detalle del escenario más severo
cat("\n--- Detalle del escenario más severo ---\n\n")
idx_severo <- which.min(sapply(resultados_hist, function(r) r$rend_acum))
res_severo <- resultados_hist[[idx_severo]]

cat(sprintf("Escenario: %s\n", res_severo$nombre))
cat(sprintf("  %s\n\n", res_severo$descripcion))
cat(sprintf("  Días en el período:           %d\n",   res_severo$n_dias))
cat(sprintf("  Rendimiento acumulado:        %.2f%%\n", res_severo$rend_acum))
cat(sprintf("  Pérdida total estimada:       $%.0f MXN\n", res_severo$perdida_mxn))
cat(sprintf("  Volatilidad en el período:    %.2f%% anual\n", res_severo$vol_periodo))
cat(sprintf("  Peor caída en un solo día:    %.2f%%\n", res_severo$max_caida_1d))
cat(sprintf("  Días con pérdida:             %d de %d (%.0f%%)\n\n",
            res_severo$n_dias_neg, res_severo$n_dias,
            res_severo$n_dias_neg / res_severo$n_dias * 100))
cat("  Rendimiento acumulado por activo en este período:\n")
for (act in names(res_severo$rend_activos)) {
  cat(sprintf("    %-15s  %8.2f%%\n", act, res_severo$rend_activos[act]))
}

# Visualización: rendimiento acumulado durante cada crisis
cat("\n")

df_crisis_viz <- do.call(rbind, lapply(crisis_historicas, function(c) {
  idx <- fechas >= c$inicio & fechas <= c$fin
  if (sum(idx) < 5) return(NULL)
  r_c <- as.numeric(as.matrix(rendimientos[idx, ]) %*% pesos_mv)
  data.frame(
    fecha    = fechas[idx],
    rend_cum = (cumprod(1 + r_c) - 1) * 100,
    crisis   = c$nombre,
    dia_rel  = seq_along(r_c)
  )
}))

if (!is.null(df_crisis_viz)) {
  g_crisis <- ggplot(df_crisis_viz, aes(x = dia_rel, y = rend_cum,
                                         color = crisis)) +
    geom_line(linewidth = 0.9) +
    geom_hline(yintercept = 0, color = "gray40", linewidth = 0.5) +
    labs(
      title    = "Rendimiento Acumulado del Portafolio MV durante Crisis Históricas",
      subtitle = "Cada línea parte desde 0% al inicio del episodio",
      x        = "Días hábiles desde el inicio del episodio",
      y        = "Rendimiento acumulado (%)",
      color    = NULL
    ) +
    theme_minimal(base_size = 12) +
    theme(legend.position = "bottom",
          plot.title = element_text(face = "bold"))
  print(g_crisis)
}

# =============================================================================
# PARTE 5: STRESS HIPOTÉTICO — SHOCKS A FACTORES DE RIESGO
# =============================================================================
# El stress hipotético diseña escenarios que no necesariamente ocurrieron
# en la historia disponible. Parte de identificar los factores de riesgo
# relevantes para el portafolio y aplica shocks explícitos a cada uno.
#
# Para un portafolio de acciones mexicanas, los factores de riesgo
# principales son:
#   1. El nivel general del mercado (IPC)
#   2. El tipo de cambio USD/MXN (riesgo cambiario)
#   3. La tasa de interés (rendimiento de Cetes/Mbonos)
#   4. El precio del petróleo (relevante para CEMEX, FEMSA, economía en general)
#
# El impacto de un shock a cada factor sobre cada acción se estima
# mediante el BETA de la acción respecto a ese factor.
# =============================================================================

cat("\n=========================================================\n")
cat("  PARTE 5: STRESS HIPOTÉTICO\n")
cat("=========================================================\n\n")

# --- 5A: Estimar betas respecto al mercado (IPC) ---
# Usamos el período completo disponible. Si el IPC no descargó, lo construimos
# como proxy con los propios rendimientos del portafolio igual ponderado.

cat(">>> Calculando sensibilidades (betas) respecto al mercado...\n\n")

# Intentar descargar el IPC
ipc_datos <- tryCatch({
  d <- getSymbols("^MXX", src = "yahoo", from = fecha_inicio, to = fecha_fin,
                  auto.assign = FALSE)
  p <- Ad(d); colnames(p) <- "IPC"
  rend_ipc <- diff(log(p))
  rend_ipc <- rend_ipc[index(rend_ipc) %in% fechas]
  na.omit(rend_ipc)
}, error = function(e) {
  cat("  (IPC no disponible, usando proxy igual ponderado)\n")
  NULL
})

if (!is.null(ipc_datos) && nrow(ipc_datos) > 100) {
  # Alinear fechas
  fechas_comunes <- intersect(as.character(fechas),
                               as.character(index(ipc_datos)))
  rend_ipc_v <- as.numeric(ipc_datos[fechas_comunes])
  rend_acc_v <- as.matrix(rendimientos[fechas_comunes, ])
} else {
  # Proxy: portafolio igual ponderado como mercado
  rend_ipc_v <- as.numeric(rendimientos %*% rep(0.25, 4))
  rend_acc_v <- as.matrix(rendimientos)
}

# Beta de cada acción respecto al mercado
betas_mercado <- sapply(1:ncol(rend_acc_v), function(i) {
  cov(rend_acc_v[, i], rend_ipc_v) / var(rend_ipc_v)
})
names(betas_mercado) <- colnames(rendimientos)

cat("Betas respecto al mercado (IPC):\n\n")
for (i in seq_along(betas_mercado)) {
  cat(sprintf("  %-15s  β = %.3f\n", names(betas_mercado)[i], betas_mercado[i]))
}
cat("\n")
cat("Interpretación: β = 1.2 significa que si el mercado cae 10%,\n")
cat("la acción cae aproximadamente 12% en promedio.\n\n")

# --- 5B: Definir escenarios hipotéticos ---
# Cada escenario especifica un shock porcentual a cada activo.
# Los shocks pueden derivarse de:
#   a) Betas multiplicados por el shock al mercado
#   b) Análisis sectorial (qué le pasa a cada empresa bajo el escenario)
#   c) Correlaciones históricas con el factor de riesgo

escenarios_hipoteticos <- list(

  list(
    nombre      = "Crash de mercado severo (−25% IPC)",
    descripcion = "Caída abrupta del IPC equivalente a la de octubre 2008",
    shocks      = setNames(betas_mercado * (-0.25), names(betas_mercado))
  ),

  list(
    nombre      = "Depreciación extrema del peso (−30% MXN)",
    descripcion = "Colapso cambiario estilo 1994–95; USD/MXN sube de ~17 a ~24",
    shocks      = c(
      WALMEX.MX   =  0.05,   # Walmart: ingresos en MXN, importaciones caras → leve daño
      GFNORTEO.MX = -0.15,   # GFNorte: cartera en pesos, activos se erosionan
      CEMEXCPO.MX =  0.10,   # CEMEX: ingresos globales en USD → beneficiada
      FEMSAUBD.MX = -0.08    # FEMSA: costos importados suben; operación local
    )
  ),

  list(
    nombre      = "Alza de tasas Banxico +300 pbs",
    descripcion = "Subida brusca de la tasa de referencia; encarece deuda corporativa",
    shocks      = c(
      WALMEX.MX   = -0.08,   # Walmart: deuda moderada → impacto medio
      GFNORTEO.MX =  0.05,   # GFNorte: banco → margen de interés neto sube
      CEMEXCPO.MX = -0.20,   # CEMEX: alta deuda → muy sensible a tasas
      FEMSAUBD.MX = -0.10    # FEMSA: deuda significativa
    )
  ),

  list(
    nombre      = "Recesión México (PIB −4%)",
    descripcion = "Contracción económica doméstica; caída del consumo y la inversión",
    shocks      = c(
      WALMEX.MX   = -0.12,   # consumo discrecional cae
      GFNORTEO.MX = -0.18,   # crédito se deteriora; morosidad sube
      CEMEXCPO.MX = -0.25,   # construcción colapsa
      FEMSAUBD.MX = -0.10    # consumo básico: más resistente
    )
  ),

  list(
    nombre      = "Shock combinado (crash + depreciación)",
    descripcion = "Crisis sistémica: caída del mercado y colapso cambiario simultáneos",
    shocks      = c(
      WALMEX.MX   = -0.18,
      GFNORTEO.MX = -0.28,
      CEMEXCPO.MX = -0.15,
      FEMSAUBD.MX = -0.20
    )
  )
)

# Función para calcular el impacto de un escenario hipotético
stress_hipotetico <- function(shocks_vec, pesos, valor, nombre, descripcion) {
  # Alinear shocks con los nombres del portafolio
  shocks_alineados <- shocks_vec[names(pesos)]
  shocks_alineados[is.na(shocks_alineados)] <- 0

  # Impacto en el rendimiento del portafolio
  rend_escenario  <- sum(pesos * shocks_alineados)
  perdida_total   <- rend_escenario * valor

  # Impacto por posición
  perdida_pos <- pesos * valor * shocks_alineados

  return(list(
    nombre        = nombre,
    descripcion   = descripcion,
    shocks        = shocks_alineados * 100,
    rend_port     = rend_escenario * 100,
    perdida_total = perdida_total,
    perdida_pos   = perdida_pos
  ))
}

resultados_hip <- lapply(escenarios_hipoteticos, function(e)
  stress_hipotetico(e$shocks, pesos_mv, valor_port, e$nombre, e$descripcion))

# Tabla resumen escenarios hipotéticos
cat("--- Impacto de escenarios hipotéticos en el portafolio ---\n\n")
cat(sprintf("  %-40s  %10s  %14s\n",
            "Escenario", "Rend.(%)", "Pérdida (MXN)"))
cat(paste(rep("-", 68), collapse = ""), "\n")
for (res in resultados_hip) {
  cat(sprintf("  %-40s  %10.2f  %14.0f\n",
              substr(res$nombre, 1, 40),
              res$rend_port,
              res$perdida_total))
}

# =============================================================================
# PARTE 6: MATRIZ DE SENSIBILIDAD
# =============================================================================
# La matriz de sensibilidad muestra el impacto de cada escenario sobre
# cada posición del portafolio. Es la forma más compacta de comunicar
# el riesgo de stress a un comité de gestión de riesgos.
#
# Filas = escenarios | Columnas = activos (+ total portafolio)
# Celdas = pérdida/ganancia en pesos MXN bajo ese escenario para esa posición
# =============================================================================

cat("\n=========================================================\n")
cat("  PARTE 6: MATRIZ DE SENSIBILIDAD\n")
cat("=========================================================\n\n")

# Construir la matriz
n_esc   <- length(resultados_hip)
n_act   <- length(pesos_mv)
activos <- names(pesos_mv)

mat_sensibilidad <- matrix(NA, nrow = n_esc, ncol = n_act + 1)
rownames(mat_sensibilidad) <- sapply(resultados_hip, function(r)
  substr(r$nombre, 1, 35))
colnames(mat_sensibilidad) <- c(activos, "TOTAL")

for (i in seq_along(resultados_hip)) {
  res <- resultados_hip[[i]]
  mat_sensibilidad[i, 1:n_act] <- round(res$perdida_pos, 0)
  mat_sensibilidad[i, n_act+1] <- round(res$perdida_total, 0)
}

cat("Pérdida/ganancia en MXN por posición y escenario:\n\n")
print(mat_sensibilidad)

cat("\n")
cat("Lectura: cada celda es la pérdida (negativo) o ganancia (positivo)\n")
cat("en MXN si ese escenario ocurriera hoy con este portafolio.\n\n")

# Gráfica de la matriz de sensibilidad
df_mat <- as.data.frame(mat_sensibilidad) %>%
  rownames_to_column("Escenario") %>%
  pivot_longer(cols = -Escenario,
               names_to = "Activo",
               values_to = "Impacto_MXN") %>%
  filter(Activo != "TOTAL")

g_mat <- ggplot(df_mat, aes(x = Activo, y = Escenario,
                             fill = Impacto_MXN / 1000)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = paste0("$", round(Impacto_MXN/1000, 0), "K")),
            size = 3, fontface = "bold",
            color = ifelse(df_mat$Impacto_MXN < 0, "white", "black")) +
  scale_fill_gradient2(
    low      = "#B71C1C",
    mid      = "#FFFDE7",
    high     = "#1B5E20",
    midpoint = 0,
    name     = "Impacto\n($K MXN)"
  ) +
  labs(
    title    = "Matriz de Sensibilidad — Stress Testing",
    subtitle = "Pérdida (rojo) o ganancia (verde) en miles de MXN por posición",
    x        = "Posición en el portafolio",
    y        = NULL
  ) +
  theme_minimal(base_size = 11) +
  theme(axis.text.x  = element_text(angle = 20, hjust = 1),
        axis.text.y  = element_text(size = 8),
        plot.title   = element_text(face = "bold"))

print(g_mat)

# =============================================================================
# PARTE 7: STRESS TESTING CON VOLATILIDAD GARCH
# =============================================================================
# Una mejora sobre el stress estático es escalar los shocks históricos
# por el nivel de volatilidad actual (estimado por GARCH en la Sesión 9).
#
# INTUICIÓN:
# Un shock de −5% ocurrido en un período de alta volatilidad es menos
# "inusual" que el mismo shock en un período tranquilo. Al escalar por
# la volatilidad condicional actual, obtenemos un stress más realista.
#
# FÓRMULA:
#   shock_escalado = shock_historico × (σ_t_actual / σ_t_histórica)
#
# Si la volatilidad actual es mayor que la histórica, el shock se amplifica.
# Si la volatilidad actual es menor, el shock se reduce.
# =============================================================================

cat("=========================================================\n")
cat("  PARTE 7: STRESS ESCALADO POR VOLATILIDAD GARCH\n")
cat("=========================================================\n\n")

# Estimar GARCH para obtener la volatilidad actual
cat(">>> Estimando GARCH para escalar shocks por volatilidad actual...\n\n")

spec_garch <- ugarchspec(
  variance.model     = list(model = "sGARCH", garchOrder = c(1, 1)),
  mean.model         = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "std"
)

garch_port <- tryCatch(
  ugarchfit(spec = spec_garch, data = rend_port, solver = "hybrid"),
  error = function(e) NULL
)

if (!is.null(garch_port)) {
  sigma_t_serie    <- as.numeric(sigma(garch_port))
  sigma_t_actual   <- tail(sigma_t_serie, 1) * sqrt(252)  # anualizado
  sigma_t_hist_med <- mean(sigma_t_serie) * sqrt(252)
  factor_escala    <- sigma_t_actual / sigma_t_hist_med

  cat(sprintf("Volatilidad anualizada actual (GARCH):     %.2f%%\n",
              sigma_t_actual * 100))
  cat(sprintf("Volatilidad anualizada media histórica:    %.2f%%\n",
              sigma_t_hist_med * 100))
  cat(sprintf("Factor de escala (actual / media):         %.3f\n\n",
              factor_escala))

  if (factor_escala > 1) {
    cat("La volatilidad actual está POR ENCIMA de la media histórica.\n")
    cat("Los shocks escalados serán MÁS severos que los originales.\n\n")
  } else {
    cat("La volatilidad actual está POR DEBAJO de la media histórica.\n")
    cat("Los shocks escalados serán MENOS severos que los originales.\n\n")
  }

  # Aplicar el factor de escala al escenario más severo
  res_severo_esc <- res_severo
  rend_escalado  <- res_severo$rend_acum * factor_escala
  perdida_esc    <- rend_escalado / 100 * valor_port

  cat(sprintf("--- Escenario '%s' — comparación ---\n\n",
              substr(res_severo$nombre, 1, 40)))
  cat(sprintf("  Sin escalar (stress histórico puro):  %8.2f%%  ($%.0f MXN)\n",
              res_severo$rend_acum, res_severo$perdida_mxn))
  cat(sprintf("  Escalado por volatilidad actual:      %8.2f%%  ($%.0f MXN)\n\n",
              rend_escalado, perdida_esc))
} else {
  cat("(GARCH no convergió — usando stress sin escalamiento)\n\n")
  factor_escala  <- 1
}

# =============================================================================
# PARTE 8: COMPARACIÓN GLOBAL — VaR, CVaR Y STRESS
# =============================================================================
# Una tabla que coloca todas las medidas de riesgo juntas permite
# comunicar de forma completa el perfil de riesgo del portafolio.
# Es el formato típico de un reporte de riesgo de mercado institucional.
# =============================================================================

cat("=========================================================\n")
cat("  PARTE 8: CUADRO COMPARATIVO DE MEDIDAS DE RIESGO\n")
cat("=========================================================\n\n")

# Calcular VaR y CVaR histórico para referencia
var_95_h  <- quantile(rend_port, probs = 0.05)
cvar_95_h <- mean(rend_port[rend_port <= var_95_h])
var_99_h  <- quantile(rend_port, probs = 0.01)
cvar_99_h <- mean(rend_port[rend_port <= var_99_h])

cat(sprintf("  %-40s  %10s  %14s\n",
            "Medida de riesgo", "% portafolio", "MXN ($1M)"))
cat(paste(rep("-", 68), collapse = ""), "\n")

# VaR y CVaR estadísticos
cat(sprintf("  %-40s  %10.3f  %14.0f\n",
            "VaR histórico (95%, 1 día)",
            var_95_h * 100, var_95_h * valor_port))
cat(sprintf("  %-40s  %10.3f  %14.0f\n",
            "CVaR histórico (95%, 1 día)",
            cvar_95_h * 100, cvar_95_h * valor_port))
cat(sprintf("  %-40s  %10.3f  %14.0f\n",
            "VaR histórico (99%, 1 día)",
            var_99_h * 100, var_99_h * valor_port))
cat(sprintf("  %-40s  %10.3f  %14.0f\n",
            "CVaR histórico (99%, 1 día)",
            cvar_99_h * 100, cvar_99_h * valor_port))

# Drawdown máximo histórico
cat(sprintf("  %-40s  %10.3f  %14.0f\n",
            "Drawdown máximo histórico",
            max_dd, max_dd / 100 * valor_port))

cat(paste(rep("-", 68), collapse = ""), "\n")

# Escenarios de stress
for (res in resultados_hist) {
  cat(sprintf("  %-40s  %10.3f  %14.0f\n",
              paste0("Stress: ", substr(res$nombre, 1, 29)),
              res$rend_acum, res$perdida_mxn))
}
for (res in resultados_hip) {
  cat(sprintf("  %-40s  %10.3f  %14.0f\n",
              paste0("Hipot: ", substr(res$nombre, 1, 30)),
              res$rend_port, res$perdida_total))
}

cat(paste(rep("-", 68), collapse = ""), "\n\n")
cat("LECTURA DEL CUADRO:\n")
cat("• Las medidas estadísticas (VaR, CVaR) describen el riesgo 'normal'.\n")
cat("• El drawdown máximo muestra la peor experiencia histórica acumulada.\n")
cat("• Los escenarios de stress muestran la pérdida bajo eventos específicos.\n")
cat("• En general: stress severo > CVaR 99% > VaR 99% > CVaR 95% > VaR 95%.\n\n")

# =============================================================================
# PARTE 9: STRESS TESTING INVERSO (REVERSE STRESS TEST)
# =============================================================================
# El stress test inverso responde la pregunta al revés: en lugar de
# preguntar "¿cuánto pierdo si ocurre X?", pregunta "¿qué tendría que
# ocurrir para que yo perdiera Y pesos?"
#
# Es especialmente útil para identificar el "escenario de quiebra":
# el shock que llevaría al portafolio o a la institución a incumplir
# sus obligaciones o a consumir todo su capital disponible.
#
# PROCEDIMIENTO:
#   1. Definir un umbral de pérdida máxima tolerable (ej. 20% del portafolio)
#   2. Calcular qué rendimiento del portafolio implica esa pérdida
#   3. Buscar en la historia cuántos días (o períodos) alcanzaron ese umbral
#   4. Caracterizar qué condiciones de mercado los generaron
# =============================================================================

cat("=========================================================\n")
cat("  PARTE 9: STRESS TEST INVERSO\n")
cat("=========================================================\n\n")

# Definir umbrales de pérdida
umbrales_pct   <- c(-0.05, -0.10, -0.15, -0.20, -0.30)
umbrales_desc  <- c("−5% (pérdida operativa)", "−10% (alerta severa)",
                    "−15% (capital en riesgo)", "−20% (umbral crítico)",
                    "−30% (escenario extremo)")

cat("¿Qué condiciones producirían cada nivel de pérdida en el portafolio?\n\n")
cat(sprintf("  %-28s  %10s  %12s  %8s\n",
            "Umbral", "MXN", "Días históricos", "% del tiempo"))
cat(paste(rep("-", 62), collapse = ""), "\n")

for (i in seq_along(umbrales_pct)) {
  u     <- umbrales_pct[i]
  n_sup <- sum(rend_port <= u)
  cat(sprintf("  %-28s  %10.0f  %12d  %8.3f%%\n",
              umbrales_desc[i],
              u * valor_port,
              n_sup,
              n_sup / n_obs * 100))
}

cat("\n")

# Para el umbral de -20%, caracterizar los días que lo superaron
umbral_ref <- -0.20
dias_extremos <- which(rend_port <= umbral_ref)

if (length(dias_extremos) > 0) {
  cat(sprintf("--- Días que superaron el umbral de %.0f%% ---\n\n",
              umbral_ref * 100))
  df_extremos <- data.frame(
    Fecha       = fechas[dias_extremos],
    Rendimiento = round(rend_port[dias_extremos] * 100, 3),
    Perdida_MXN = round(rend_port[dias_extremos] * valor_port, 0)
  )
  print(df_extremos, row.names = FALSE)
  cat("\n")
} else {
  cat(sprintf("No hay días con pérdida mayor al %.0f%% en la muestra disponible.\n",
              abs(umbral_ref) * 100))
  cat("Este umbral está más allá del historial analizado — es un escenario\n")
  cat("puramente hipotético que no tiene precedente en los datos.\n\n")
}

# Reverse stress: ¿qué shock de mercado produciría una pérdida del 15%?
cat("--- Reverse stress: shock de mercado implícito ---\n\n")

perdida_objetivo <- -0.15   # queremos perder no más del 15%
# Si todos los activos se mueven proporcionalmente a sus betas:
# rend_port = sum(w_i * beta_i * shock_mercado)
beta_port <- sum(pesos_mv * betas_mercado)
shock_mercado_impl <- perdida_objetivo / beta_port

cat(sprintf("  Pérdida objetivo del portafolio:  %.0f%%\n",
            perdida_objetivo * 100))
cat(sprintf("  Beta del portafolio vs. mercado:  %.3f\n", beta_port))
cat(sprintf("  Shock implícito al mercado (IPC): %.2f%%\n\n",
            shock_mercado_impl * 100))
cat(sprintf("  Una caída del %.2f%% del IPC en un día llevaría al portafolio\n",
            abs(shock_mercado_impl) * 100))
cat(sprintf("  a perder aproximadamente el 15%% de su valor ($%.0f MXN).\n",
            perdida_objetivo * valor_port))
cat(sprintf("  ¿Es este shock plausible? Comparar con el peor día histórico\n"))
cat(sprintf("  del IPC: %.2f%%\n\n",
            min(as.numeric(diff(log(
              tryCatch(Ad(getSymbols("^MXX", src="yahoo",
                                     from=fecha_inicio, to=fecha_fin,
                                     auto.assign=FALSE)),
                       error=function(e) NULL)
            ))) * 100, na.rm = TRUE)))

# =============================================================================
# PARTE 10: REPORTE RESUMEN DE STRESS TESTING
# =============================================================================
# En la práctica institucional, los resultados del stress testing se
# sintetizan en un reporte que va al comité de riesgo o a la dirección.
# Construimos una versión simplificada de ese reporte.
# =============================================================================

cat("\n=========================================================\n")
cat("  PARTE 10: REPORTE DE STRESS — PORTAFOLIO MV\n")
cat("=========================================================\n\n")

cat("RESUMEN EJECUTIVO\n")
cat(paste(rep("=", 60), collapse = ""), "\n")
cat(sprintf("Portafolio: MV (WALMEX/GFNORTE/CEMEX/FEMSA)\n"))
cat(sprintf("Valor:      $%s MXN\n", format(valor_port, big.mark = ",")))
cat(sprintf("Fecha:      %s\n", format(Sys.Date())), "\n")
cat(paste(rep("-", 60), collapse = ""), "\n\n")

cat("MÉTRICAS ESTADÍSTICAS (1 día, datos históricos)\n")
cat(sprintf("  VaR 95%%:   %6.3f%%   ($%8.0f MXN)\n",
            var_95_h * 100, var_95_h * valor_port))
cat(sprintf("  CVaR 95%%:  %6.3f%%   ($%8.0f MXN)\n",
            cvar_95_h * 100, cvar_95_h * valor_port))
cat(sprintf("  VaR 99%%:   %6.3f%%   ($%8.0f MXN)\n",
            var_99_h * 100, var_99_h * valor_port))
cat(sprintf("  CVaR 99%%:  %6.3f%%   ($%8.0f MXN)\n\n",
            cvar_99_h * 100, cvar_99_h * valor_port))

cat("ESCENARIOS HISTÓRICOS (impacto acumulado del período)\n")
for (res in resultados_hist) {
  flag <- ifelse(res$rend_acum < -20, " ⚠", "")
  cat(sprintf("  %-38s  %7.2f%%  ($%9.0f MXN)%s\n",
              substr(res$nombre, 1, 38),
              res$rend_acum, res$perdida_mxn, flag))
}
cat("\n")

cat("ESCENARIOS HIPOTÉTICOS (impacto instantáneo)\n")
for (res in resultados_hip) {
  flag <- ifelse(res$rend_port < -15, " ⚠", "")
  cat(sprintf("  %-38s  %7.2f%%  ($%9.0f MXN)%s\n",
              substr(res$nombre, 1, 38),
              res$rend_port, res$perdida_total, flag))
}
cat("\n")

cat("ESCENARIO MÁS SEVERO IDENTIFICADO\n")
todos_rend <- c(
  sapply(resultados_hist, function(r) r$rend_acum),
  sapply(resultados_hip,  function(r) r$rend_port)
)
todos_nombres <- c(
  sapply(resultados_hist, function(r) r$nombre),
  sapply(resultados_hip,  function(r) r$nombre)
)
idx_peor <- which.min(todos_rend)
cat(sprintf("  Escenario:  %s\n", todos_nombres[idx_peor]))
cat(sprintf("  Impacto:    %.2f%%  ($%.0f MXN)\n",
            todos_rend[idx_peor], todos_rend[idx_peor]/100*valor_port))
cat(paste(rep("=", 60), collapse = ""), "\n\n")

# =============================================================================
# ============================================================================
#                       EJERCICIOS DE LA SESIÓN 10
# ============================================================================
# Ejercicios 1–4 obligatorios | Ejercicios 5–7 de profundización
# =============================================================================

cat("\n")
cat("============================================================\n")
cat("               EJERCICIOS DE LA SESIÓN 10\n")
cat("============================================================\n\n")

# ----------------------------------------------------------------------------
# EJERCICIO 1 (BÁSICO): Stress histórico manual
# ----------------------------------------------------------------------------
cat("EJERCICIO 1: Stress Histórico Manual — Crisis 2008\n")
cat("---------------------------------------------------\n")
cat("Calcula manualmente el impacto de la crisis financiera global de 2008\n")
cat("en el portafolio MV, paso a paso sin usar la función stress_historico().\n\n")

ini_e1 <- "2008-09-15"   # quiebra de Lehman Brothers
fin_e1 <- "2009-01-31"

idx_e1    <- fechas >= ini_e1 & fechas <= fin_e1
r_e1      <- as.matrix(rendimientos[idx_e1, ])
r_port_e1 <- as.numeric(r_e1 %*% pesos_mv)
n_dias_e1 <- length(r_port_e1)

# Rendimiento acumulado: producto de (1 + r_t) para todo t
rend_acum_e1 <- prod(1 + r_port_e1) - 1

cat(sprintf("Período: %s a %s (%d días hábiles)\n\n", ini_e1, fin_e1, n_dias_e1))
cat(sprintf("Rendimiento acumulado del portafolio:  %.4f%%\n",
            rend_acum_e1 * 100))
cat(sprintf("Pérdida en $1,000,000 MXN:             $%.0f MXN\n\n",
            rend_acum_e1 * valor_port))

# ¿Cuál fue el peor día individual?
peor_dia_e1 <- which.min(r_port_e1)
cat(sprintf("Peor día individual en el período:\n"))
cat(sprintf("  Fecha:       %s\n",
            format(fechas[idx_e1][peor_dia_e1])))
cat(sprintf("  Rendimiento: %.4f%%\n\n",
            r_port_e1[peor_dia_e1] * 100))

# Rendimiento por activo en el período
cat("Rendimiento acumulado por activo:\n")
for (i in 1:ncol(r_e1)) {
  cat(sprintf("  %-15s  %.3f%%\n",
              colnames(r_e1)[i],
              (prod(1 + r_e1[, i]) - 1) * 100))
}

# ----------------------------------------------------------------------------
# EJERCICIO 2 (BÁSICO): Diseñar un escenario hipotético propio
# ----------------------------------------------------------------------------
cat("\nEJERCICIO 2: Diseñar tu Propio Escenario Hipotético\n")
cat("------------------------------------------------------\n")
cat("Define un escenario de 'Guerra Comercial México-EUA' con los siguientes\n")
cat("shocks sectoriales y calcula el impacto en el portafolio.\n\n")

shocks_gc <- c(
  WALMEX.MX   = -0.20,  # cadena de suministro interrumpida
  GFNORTEO.MX = -0.10,  # crédito se contrae, actividad económica cae
  CEMEXCPO.MX = -0.18,  # exportaciones y proyectos de infraestructura afectados
  FEMSAUBD.MX = -0.08   # consumo doméstico resiste mejor
)

cat("Shocks definidos por activo:\n")
for (nm in names(shocks_gc)) {
  cat(sprintf("  %-15s  %+.1f%%\n", nm, shocks_gc[nm] * 100))
}

rend_gc <- sum(pesos_mv * shocks_gc[names(pesos_mv)])
cat(sprintf("\nRendimiento del portafolio bajo este escenario:\n"))
cat(sprintf("  Rend. ponderado:   %.4f%%\n", rend_gc * 100))
cat(sprintf("  Pérdida en $1M:    $%.0f MXN\n\n", rend_gc * valor_port))

# Comparar con el VaR y CVaR
cat("¿Cómo se compara con las medidas estadísticas?\n")
cat(sprintf("  VaR 99%%  (1 día):  %.4f%%  — el escenario es %.1fx más severo\n",
            var_99_h * 100, rend_gc / var_99_h))
cat(sprintf("  CVaR 99%% (1 día):  %.4f%%  — el escenario es %.1fx más severo\n\n",
            cvar_99_h * 100, rend_gc / cvar_99_h))

# ----------------------------------------------------------------------------
# EJERCICIO 3 (INTERMEDIO): Drawdown y horizonte de recuperación
# ----------------------------------------------------------------------------
cat("EJERCICIO 3: Drawdown Máximo y Recuperación\n")
cat("---------------------------------------------\n")
cat("Calcula el drawdown para cada sub-período de crisis y estima cuántos\n")
cat("días tardó el portafolio en recuperar el nivel anterior al inicio.\n\n")

calcular_drawdown_periodo <- function(r_vec, nombre_periodo) {
  val_acum <- cumprod(1 + r_vec)
  max_prev <- cummax(val_acum)
  dd       <- (val_acum - max_prev) / max_prev * 100
  max_dd   <- min(dd)
  # Fecha del fondo (dentro del vector)
  idx_fondo <- which.min(dd)
  # ¿Cuántos días tardó en recuperarse (volver a dd = 0)?
  idx_rec   <- which(dd[idx_fondo:length(dd)] >= -0.1)[1]
  dias_rec  <- ifelse(is.na(idx_rec), NA, idx_rec)
  return(list(
    nombre    = nombre_periodo,
    max_dd    = max_dd,
    idx_fondo = idx_fondo,
    dias_rec  = dias_rec
  ))
}

sub_crisis_e3 <- list(
  list(n = "Crisis 2008–2009",   ini = "2008-09-01", fin = "2009-12-31"),
  list(n = "Petróleo 2015–2016", ini = "2014-07-01", fin = "2016-06-30"),
  list(n = "COVID 2020",         ini = "2020-01-01", fin = "2021-06-30")
)

cat(sprintf("  %-24s  %12s  %10s  %12s\n",
            "Período", "Max. DD (%)", "Día fondo", "Días recup."))
cat(paste(rep("-", 62), collapse = ""), "\n")

for (per in sub_crisis_e3) {
  idx_p <- fechas >= per$ini & fechas <= per$fin
  if (sum(idx_p) < 20) next
  res_dd <- calcular_drawdown_periodo(rend_port[idx_p], per$n)
  cat(sprintf("  %-24s  %12.2f  %10d  %12s\n",
              per$n, res_dd$max_dd, res_dd$idx_fondo,
              ifelse(is.na(res_dd$dias_rec), "No recuperó", res_dd$dias_rec)))
}

cat("\n")
cat("Nota: 'No recuperó' significa que el portafolio no volvió al nivel\n")
cat("pre-crisis dentro del sub-período analizado. Ampliar el rango de fechas.\n\n")

# ----------------------------------------------------------------------------
# EJERCICIO 4 (INTERMEDIO): Concentración del riesgo — ¿qué posición domina?
# ----------------------------------------------------------------------------
cat("EJERCICIO 4: Concentración del Riesgo bajo Stress\n")
cat("--------------------------------------------------\n")
cat("Analiza qué posición del portafolio contribuye más a la pérdida\n")
cat("en cada escenario hipotético y calcula la contribución porcentual.\n\n")

cat(sprintf("  %-28s", "Escenario"))
for (act in names(pesos_mv)) cat(sprintf("  %12s", act))
cat(sprintf("  %12s\n", "TOTAL"))
cat(paste(rep("-", 28 + 13*5), collapse = ""), "\n")

for (res in resultados_hip) {
  cat(sprintf("  %-28s", substr(res$nombre, 1, 28)))
  for (act in names(pesos_mv)) {
    contrib_pct <- res$perdida_pos[act] / res$perdida_total * 100
    cat(sprintf("  %11.1f%%", contrib_pct))
  }
  cat(sprintf("  %11.0f\n", res$perdida_total))
}

cat("\n")
cat("Posición más concentrada por escenario (contribución > 35%):\n")
for (res in resultados_hip) {
  contribs <- res$perdida_pos / res$perdida_total * 100
  dom <- names(which(abs(contribs) > 35))
  if (length(dom) > 0) {
    cat(sprintf("  %-28s → %s (%.1f%%)\n",
                substr(res$nombre, 1, 28), dom[1], contribs[dom[1]]))
  }
}

# ----------------------------------------------------------------------------
# EJERCICIO 5 (INTERMEDIO): Stress test con rebalanceo
# ----------------------------------------------------------------------------
cat("\nEJERCICIO 5: ¿Mejora el Stress si Rebalanceamos el Portafolio?\n")
cat("---------------------------------------------------------------\n")
cat("Compara el impacto del escenario más severo bajo el portafolio actual\n")
cat("y bajo tres portafolios alternativos con distinta composición.\n\n")

portafolios_alt <- list(
  list(nombre = "MV original",   pesos = c(0.30, 0.25, 0.20, 0.25)),
  list(nombre = "Defensivo",     pesos = c(0.45, 0.30, 0.05, 0.20)),  # más WALMEX/GFNORTE
  list(nombre = "Igual pond.",   pesos = c(0.25, 0.25, 0.25, 0.25)),
  list(nombre = "Sin CEMEX",     pesos = c(0.35, 0.30, 0.00, 0.35))
)

# Usar el escenario hipotético más severo
esc_severo_hip <- resultados_hip[[which.min(
  sapply(resultados_hip, function(r) r$rend_port))]]
shocks_severo <- esc_severo_hip$shocks / 100

cat(sprintf("Escenario: %s\n\n", esc_severo_hip$nombre))
cat(sprintf("  %-18s  %8s  %10s  %14s\n",
            "Portafolio", "Rend.(%)", "vs. MV", "Pérdida (MXN)"))
cat(paste(rep("-", 54), collapse = ""), "\n")

rend_mv_ref <- sum(portafolios_alt[[1]]$pesos * shocks_severo)
for (port in portafolios_alt) {
  pesos_p <- setNames(port$pesos, names(pesos_mv))
  rend_p  <- sum(pesos_p * shocks_severo)
  cat(sprintf("  %-18s  %8.3f  %10.3f  %14.0f\n",
              port$nombre,
              rend_p * 100,
              (rend_p - rend_mv_ref) * 100,
              rend_p * valor_port))
}

cat("\n")
cat("El portafolio 'defensivo' pesa más en activos con menor sensibilidad\n")
cat("al escenario severo y menos en los más afectados.\n")
cat("El stress testing así puede usarse para DISEÑAR portafolios resilientes.\n\n")

# ----------------------------------------------------------------------------
# EJERCICIO 6 (AVANZADO): Stress test probabilístico con Monte Carlo
# ----------------------------------------------------------------------------
cat("EJERCICIO 6: Stress Test Probabilístico\n")
cat("----------------------------------------\n")
cat("En lugar de un shock puntual, simula 50,000 escenarios de un 'día de\n")
cat("crisis' tomando los rendimientos del período COVID como distribución\n")
cat("y calcula la distribución de pérdidas bajo ese régimen de estrés.\n\n")

# Extraer rendimientos durante COVID como distribución de referencia
idx_covid <- fechas >= "2020-02-20" & fechas <= "2020-06-30"
r_covid   <- rend_port[idx_covid]

if (length(r_covid) > 20) {
  mu_covid    <- mean(r_covid)
  sigma_covid <- sd(r_covid)
  n_mc_stress <- 50000
  set.seed(2024)

  # Simular rendimientos del portafolio bajo el régimen COVID
  r_stress_sim <- rnorm(n_mc_stress, mean = mu_covid, sd = sigma_covid)

  var_stress_95  <- quantile(r_stress_sim, 0.05)
  cvar_stress_95 <- mean(r_stress_sim[r_stress_sim <= var_stress_95])
  var_stress_99  <- quantile(r_stress_sim, 0.01)
  cvar_stress_99 <- mean(r_stress_sim[r_stress_sim <= var_stress_99])

  cat(sprintf("Parámetros del régimen COVID (Feb–Jun 2020):\n"))
  cat(sprintf("  μ diaria:  %.4f%%  |  σ diaria:  %.4f%%\n\n",
              mu_covid*100, sigma_covid*100))
  cat(sprintf("  VaR 95%%  bajo régimen COVID:  %.4f%%  ($%.0f MXN)\n",
              var_stress_95*100,  var_stress_95*valor_port))
  cat(sprintf("  CVaR 95%% bajo régimen COVID:  %.4f%%  ($%.0f MXN)\n",
              cvar_stress_95*100, cvar_stress_95*valor_port))
  cat(sprintf("  VaR 99%%  bajo régimen COVID:  %.4f%%  ($%.0f MXN)\n",
              var_stress_99*100,  var_stress_99*valor_port))
  cat(sprintf("  CVaR 99%% bajo régimen COVID:  %.4f%%  ($%.0f MXN)\n\n",
              cvar_stress_99*100, cvar_stress_99*valor_port))

  # Comparar con VaR histórico normal
  cat("Comparación régimen normal vs. régimen COVID:\n")
  cat(sprintf("  VaR 95%%  normal: %.4f%%  |  COVID: %.4f%%  (%.1fx más severo)\n",
              var_95_h*100, var_stress_95*100, var_stress_95/var_95_h))
  cat(sprintf("  CVaR 95%% normal: %.4f%%  |  COVID: %.4f%%  (%.1fx más severo)\n\n",
              cvar_95_h*100, cvar_stress_95*100, cvar_stress_95/cvar_95_h))

  # Gráfica comparativa de distribuciones
  df_regimenes <- data.frame(
    r      = c(rend_port, r_stress_sim),
    regimen= rep(c("Normal (histórico completo)",
                   "Estrés (régimen COVID simulado)"),
                 c(length(rend_port), n_mc_stress))
  )
  set.seed(1)
  df_reg_muestra <- df_regimenes[
    c(seq_len(length(rend_port)),
      sample(length(rend_port)+1:n_mc_stress, 5000)), ]

  g_regimenes <- ggplot(df_reg_muestra, aes(x = r * 100, fill = regimen)) +
    geom_density(alpha = 0.5) +
    geom_vline(xintercept = var_95_h    * 100, color = "#1565C0",
               linetype = "dashed", linewidth = 1) +
    geom_vline(xintercept = var_stress_95 * 100, color = "#B71C1C",
               linetype = "dashed", linewidth = 1) +
    scale_fill_manual(values = c(
      "Normal (histórico completo)"  = "#42A5F5",
      "Estrés (régimen COVID simulado)" = "#EF5350"
    )) +
    labs(
      title    = "Distribución Normal vs. Distribución de Estrés (régimen COVID)",
      subtitle = "Líneas punteadas = VaR 95% en cada régimen",
      x        = "Rendimiento del portafolio (%)", y = "Densidad", fill = NULL
    ) +
    theme_minimal(base_size = 12) +
    theme(legend.position = "top", plot.title = element_text(face = "bold"))

  print(g_regimenes)
} else {
  cat("(Datos insuficientes para el período COVID — ajustar fechas)\n\n")
}

# ----------------------------------------------------------------------------
# EJERCICIO 7 (AVANZADO): Construcción de un escenario macro completo
# ----------------------------------------------------------------------------
cat("EJERCICIO 7: Escenario Macro Completo — 'Crisis de Deuda Soberana'\n")
cat("-------------------------------------------------------------------\n")
cat("Construye un escenario macroeconómico narrativo y cuantitativo:\n")
cat("México enfrenta una crisis de confianza fiscal. El CDS soberano\n")
cat("se dispara, el MXN colapsa y el Banxico sube tasas de emergencia.\n\n")

cat("NARRATIVA DEL ESCENARIO:\n")
cat("  Evento detonador: rebaja de calificación soberana de México a BB+\n")
cat("  Canal 1:  salida de capitales → depreciación MXN +25%\n")
cat("  Canal 2:  Banxico sube tasa referencia +250 pbs de emergencia\n")
cat("  Canal 3:  contracción del crédito → actividad económica −3%\n")
cat("  Canal 4:  el mercado accionario cae en promedio −20%\n\n")

# Traducir la narrativa a shocks por activo usando análisis sectorial
shocks_macro <- c(
  # WALMEX: consumo resiste parcialmente, pero crédito y confianza caen
  WALMEX.MX   = -(0.20 * 0.8),          # β=0.8 vs. mercado + efecto tasa bajo
  # GFNORTE: tasa más alta mejora NIM pero el riesgo crediticio sube mucho
  GFNORTEO.MX = -(0.20 * 1.2 - 0.03),  # β=1.2 vs. mercado, beneficio parcial tasa
  # CEMEX: altamente apalancado + exposición cambiaria + colapso construcción
  CEMEXCPO.MX = -(0.20 * 1.5),          # β=1.5 vs. mercado
  # FEMSA: consumo básico, algo de protección; exposición cambiaria parcial
  FEMSAUBD.MX = -(0.20 * 0.9)           # β=0.9 vs. mercado
)
names(shocks_macro) <- names(pesos_mv)

rend_macro <- sum(pesos_mv * shocks_macro)

cat("SHOCKS POR ACTIVO (derivados del análisis sectorial):\n")
for (nm in names(shocks_macro)) {
  cat(sprintf("  %-15s  %+7.2f%%  →  pérdida posición: $%.0f MXN\n",
              nm,
              shocks_macro[nm] * 100,
              pesos_mv[nm] * shocks_macro[nm] * valor_port))
}

cat(sprintf("\nIMPACTO TOTAL EN EL PORTAFOLIO:\n"))
cat(sprintf("  Rendimiento:         %+.3f%%\n",   rend_macro * 100))
cat(sprintf("  Pérdida en $1M MXN:  $%.0f MXN\n", rend_macro * valor_port))
cat(sprintf("  Como múltiplo VaR 99%%: %.2fx\n",   rend_macro / var_99_h))

cat("\n")
cat("DISCUSIÓN:\n")
cat("Un escenario macro completo tiene tres ventajas sobre un shock puntual:\n")
cat("  1. La narrativa facilita la comunicación con directivos no técnicos\n")
cat("  2. Los shocks por activo reflejan diferencias sectoriales reales\n")
cat("  3. Permite identificar qué posición se beneficiaría o qué cobertura\n")
cat("     reduciría el impacto (ej. comprar USD, reducir CEMEX, aumentar FEMSA)\n\n")

# =============================================================================
# RESUMEN EJECUTIVO DE LA SESIÓN
# =============================================================================

cat("\n")
cat("============================================================\n")
cat("              RESUMEN EJECUTIVO — SESIÓN 10\n")
cat("============================================================\n\n")
cat("CONCEPTOS CLAVE:\n")
cat("  • Stress testing ≠ VaR: escenarios específicos, no distribuciones\n")
cat("  • Stress histórico:   reproducir crisis pasadas en el portafolio actual\n")
cat("  • Stress hipotético:  diseñar shocks plausibles a factores de riesgo\n")
cat("  • Stress inverso:     ¿qué necesita ocurrir para perder Y pesos?\n")
cat("  • Drawdown:           caída acumulada desde un máximo previo\n")
cat("  • Los cuatro complementan: VaR + CVaR + GARCH + Stress = perfil completo\n\n")
cat("RESULTADO DEL PORTAFOLIO MV ($1,000,000 MXN):\n")
cat(sprintf("  VaR 95%% (1 día):          %6.3f%%  ($%8.0f MXN)\n",
            var_95_h * 100, var_95_h * valor_port))
cat(sprintf("  Peor stress histórico:    %6.2f%%  ($%8.0f MXN)\n",
            min(sapply(resultados_hist, function(r) r$rend_acum)),
            min(sapply(resultados_hist, function(r) r$perdida_mxn))))
cat(sprintf("  Drawdown máximo:          %6.2f%%  ($%8.0f MXN)\n",
            max_dd, max_dd / 100 * valor_port))
cat("\nPRÓXIMA SESIÓN (11): Derivados Financieros y Monte Carlo\n")
cat("  Con el perfil de riesgo completo, exploraremos cómo los derivados\n")
cat("  (opciones, futuros) pueden usarse para cubrir los escenarios de estrés\n")
cat("  más severos identificados en esta sesión.\n\n")
cat("Sesión completada — Facultad de Economía UNAM\n")
cat("Ismael Valverde | ismael_val@economia.unam.mx\n")
cat("============================================================\n")
