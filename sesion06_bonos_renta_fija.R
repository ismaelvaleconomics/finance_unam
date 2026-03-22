################################################################################
# MERCADOS DE CAPITALES - ANÁLISIS CUANTITATIVO
# SESIÓN 6: Valoración de Bonos y Renta Fija
#
# Profesor: Ismael Valverde
# Facultad de Economía, UNAM
#
# CONTENIDO DE LA SESIÓN:
# 1. Revisión de ejercicios Sesión 5
# 2. Fundamentos de bonos y renta fija
# 3. Valoración de bonos: valor presente de flujos
# 4. Estructura temporal de tasas de interés (yield curve)
# 5. Duration (Macaulay y Modificada)
# 6. Convexidad
# 7. Inmunización de portafolios de bonos
# 8. Aplicación con bonos mexicanos (Cetes, Bonos M, Udibonos)
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

cat("Librerías cargadas exitosamente!\n")
cat("Sesión 6: Valoración de Bonos y Renta Fija\n\n")

################################################################################
# PARTE 2: FUNDAMENTOS DE BONOS
################################################################################

cat("========== FUNDAMENTOS DE RENTA FIJA ==========\n\n")

cat("*** ¿QUÉ ES UN BONO? ***\n")
cat("Un bono es un instrumento de DEUDA donde:\n")
cat("- El emisor (gobierno o empresa) PIDE PRESTADO\n")
cat("- El inversionista PRESTA dinero\n")
cat("- El emisor promete pagar INTERESES (cupones) y PRINCIPAL\n\n")

cat("COMPONENTES DE UN BONO:\n")
cat("1. Valor Nominal (Face Value): Cantidad a pagar al vencimiento (ej: $1,000)\n")
cat("2. Tasa Cupón: Tasa de interés anual (ej: 6%)\n")
cat("3. Cupón: Pago periódico = Nominal × Tasa Cupón / Frecuencia\n")
cat("4. Plazo (Maturity): Tiempo hasta vencimiento (ej: 10 años)\n")
cat("5. Frecuencia de Pago: Anual, semestral, trimestral\n\n")

cat("TIPOS DE BONOS EN MÉXICO:\n")
cat("1. CETES: Certificados de la Tesorería (cupón cero, 28-360 días)\n")
cat("2. BONOS M: Bonos de desarrollo a tasa fija (3, 5, 10, 20, 30 años)\n")
cat("3. UDIBONOS: Bonos indexados a inflación (UDIs)\n")
cat("4. BONDES: Bonos de desarrollo a tasa flotante\n")
cat("5. Certificados Bursátiles: Deuda corporativa\n\n")

cat("RIESGO VS RETORNO:\n")
cat("Bonos Gubernamentales < Bonos Corporativos AAA < Bonos BB < Bonos Basura\n")
cat("(Menor riesgo)                                              (Mayor riesgo)\n")
cat("(Menor retorno)                                            (Mayor retorno)\n\n")

################################################################################
# PARTE 3: VALORACIÓN DE BONOS - VALOR PRESENTE
################################################################################

cat("\n========== VALORACIÓN DE BONOS ==========\n\n")

cat("PRINCIPIO FUNDAMENTAL:\n")
cat("Precio del Bono = Valor Presente de TODOS los flujos futuros\n\n")

cat("FÓRMULA GENERAL:\n")
cat("P = C/(1+y) + C/(1+y)² + ... + C/(1+y)ⁿ + VN/(1+y)ⁿ\n\n")

cat("Donde:\n")
cat("P = Precio del bono\n")
cat("C = Cupón periódico\n")
cat("y = Rendimiento al vencimiento (yield)\n")
cat("VN = Valor nominal\n")
cat("n = Número de periodos\n\n")

# Ejemplo numérico
cat("*** EJEMPLO 1: BONO CON CUPONES ***\n\n")

VN <- 1000          # Valor nominal
cupon_tasa <- 0.06  # Tasa cupón 6% anual
plazo <- 5          # 5 años
frecuencia <- 2     # Semestral
y <- 0.08           # Yield 8% anual

# Cálculos
n_periodos <- plazo * frecuencia
cupon <- VN * cupon_tasa / frecuencia
y_periodo <- y / frecuencia

cat("Características del bono:\n")
cat("Valor Nominal:", VN, "\n")
cat("Tasa Cupón Anual:", cupon_tasa * 100, "%\n")
cat("Plazo:", plazo, "años\n")
cat("Frecuencia: Semestral (", frecuencia, "pagos/año)\n")
cat("Cupón semestral:", cupon, "\n")
cat("Yield (YTM):", y * 100, "%\n\n")

# Crear tabla de flujos
periodos <- 1:n_periodos
flujos <- rep(cupon, n_periodos)
flujos[n_periodos] <- flujos[n_periodos] + VN  # Último flujo incluye principal

# Calcular valor presente de cada flujo
vp_flujos <- flujos / (1 + y_periodo)^periodos

# Tabla de flujos
tabla_flujos <- data.frame(
  Periodo = periodos,
  Tiempo_años = periodos / frecuencia,
  Flujo = flujos,
  Factor_Descuento = 1 / (1 + y_periodo)^periodos,
  Valor_Presente = vp_flujos
)

cat("TABLA DE FLUJOS DE EFECTIVO:\n")
print(tabla_flujos)

# Precio del bono
precio_bono <- sum(vp_flujos)

cat("\n=== VALORACIÓN ===\n")
cat("Precio del bono:", round(precio_bono, 2), "\n\n")

cat("*** INTERPRETACIÓN ***\n")
if(precio_bono < VN) {
  cat("Precio < Valor Nominal → Bono cotiza CON DESCUENTO\n")
  cat("Razón: Yield (", y*100, "%) > Tasa Cupón (", cupon_tasa*100, "%)\n")
  cat("El mercado exige mayor rendimiento que el cupón.\n")
} else if(precio_bono > VN) {
  cat("Precio > Valor Nominal → Bono cotiza CON PRIMA\n")
  cat("Razón: Yield < Tasa Cupón\n")
} else {
  cat("Precio = Valor Nominal → Bono cotiza A LA PAR\n")
  cat("Razón: Yield = Tasa Cupón\n")
}

cat("\n")

# Función para valorar bonos
valorar_bono <- function(VN, cupon_tasa, plazo, frecuencia, yield) {
  n <- plazo * frecuencia
  C <- VN * cupon_tasa / frecuencia
  y_per <- yield / frecuencia
  
  periodos <- 1:n
  flujos <- rep(C, n)
  flujos[n] <- flujos[n] + VN
  
  vp <- flujos / (1 + y_per)^periodos
  precio <- sum(vp)
  
  return(list(
    precio = precio,
    flujos = flujos,
    vp_flujos = vp,
    periodos = periodos
  ))
}

# Ejemplo 2: Bono cupón cero (CETES)
cat("*** EJEMPLO 2: BONO CUPÓN CERO (CETES) ***\n\n")

VN_cete <- 10  # Valor nominal 10 pesos
plazo_cete <- 28  # 28 días
tasa_cete <- 0.10  # Tasa 10% anual

# Precio
precio_cete <- VN_cete / (1 + tasa_cete * plazo_cete/360)

cat("CETES a 28 días:\n")
cat("Valor Nominal:", VN_cete, "pesos\n")
cat("Plazo:", plazo_cete, "días\n")
cat("Tasa:", tasa_cete * 100, "% anual\n")
cat("Precio:", round(precio_cete, 4), "pesos\n\n")

cat("El inversionista paga", round(precio_cete, 4), 
    "hoy y recibe", VN_cete, "en 28 días.\n")
cat("Ganancia:", round(VN_cete - precio_cete, 4), "pesos\n\n")

################################################################################
# PARTE 4: RELACIÓN PRECIO-YIELD
################################################################################

cat("\n========== RELACIÓN PRECIO-YIELD ==========\n\n")

cat("REGLA FUNDAMENTAL:\n")
cat("Precio y Yield tienen relación INVERSA:\n")
cat("- Yield SUBE → Precio BAJA\n")
cat("- Yield BAJA → Precio SUBE\n\n")

# Gráfica precio vs yield
yields <- seq(0.02, 0.15, 0.001)
precios <- numeric(length(yields))

for(i in 1:length(yields)) {
  precios[i] <- valorar_bono(VN = 1000, 
                             cupon_tasa = 0.06, 
                             plazo = 5, 
                             frecuencia = 2, 
                             yield = yields[i])$precio
}

plot(yields * 100, precios,
     type = "l",
     lwd = 2,
     col = "blue",
     xlab = "Yield (%)",
     ylab = "Precio del Bono",
     main = "Relación Precio-Yield\n(Bono 6%, 5 años, semestral)")

# Marcar valor nominal
abline(h = 1000, col = "red", lty = 2)
text(12, 1020, "Valor Nominal = 1,000", col = "red")

# Marcar tasa cupón
abline(v = 6, col = "green", lty = 2)
text(6.5, 1100, "Tasa Cupón = 6%", col = "green", srt = 90)

grid()

cat("*** OBSERVACIONES ***\n")
cat("1. La curva es CONVEXA (no lineal)\n")
cat("2. Cuando Yield = Tasa Cupón → Precio = Valor Nominal\n")
cat("3. La sensibilidad al yield aumenta cuando yield baja\n")
cat("   (curva más empinada a la izquierda)\n\n")

################################################################################
# PARTE 5: ESTRUCTURA TEMPORAL DE TASAS (YIELD CURVE)
################################################################################

cat("\n========== ESTRUCTURA TEMPORAL DE TASAS ==========\n\n")

cat("La CURVA DE RENDIMIENTOS muestra la relación entre:\n")
cat("- Eje X: Plazo al vencimiento\n")
cat("- Eje Y: Yield (rendimiento)\n\n")

cat("FORMAS DE LA CURVA:\n")
cat("1. NORMAL (ascendente): Plazos largos → mayor yield\n")
cat("   Interpretación: Economía estable, expectativa de crecimiento\n\n")
cat("2. INVERTIDA (descendente): Plazos cortos → mayor yield\n")
cat("   Interpretación: Predictor de RECESIÓN\n\n")
cat("3. PLANA: Yields similares en todos los plazos\n")
cat("   Interpretación: Transición, incertidumbre\n\n")

# Ejemplo de curvas de rendimiento
plazos <- c(0.25, 0.5, 1, 2, 3, 5, 7, 10, 20, 30)  # años

# Curva normal
yield_normal <- 0.04 + 0.02 * (1 - exp(-plazos/5))

# Curva invertida
yield_invertida <- 0.06 - 0.015 * (1 - exp(-plazos/3))

# Curva plana
yield_plana <- rep(0.05, length(plazos))

plot(plazos, yield_normal * 100,
     type = "l",
     lwd = 2,
     col = "green",
     ylim = c(0, 8),
     xlab = "Plazo (años)",
     ylab = "Yield (%)",
     main = "Formas de la Curva de Rendimientos")

lines(plazos, yield_invertida * 100, lwd = 2, col = "red")
lines(plazos, yield_plana * 100, lwd = 2, col = "blue", lty = 2)

legend("bottom",
       legend = c("Normal (expansión)", "Invertida (recesión)", "Plana (transición)"),
       col = c("green", "red", "blue"),
       lty = c(1, 1, 2),
       lwd = 1)

grid()

cat("\n*** CURVA INVERTIDA Y RECESIONES ***\n")
cat("Históricamente, una curva invertida ha precedido TODAS las recesiones\n")
cat("en EE.UU. desde 1970.\n")
cat("Es uno de los mejores predictores de recesión.\n\n")

cat("¿POR QUÉ?\n")
cat("Si inversionistas esperan recesión → esperan que tasas BAJEN en futuro\n")
cat("→ Prefieren comprar bonos largos HOY (fijar tasas altas)\n")
cat("→ Demanda por bonos largos sube → Precio sube → Yield baja\n")
cat("→ Yields de largo plazo < Yields de corto plazo\n\n")

################################################################################
# PARTE 6: DURATION (MACAULAY)
################################################################################

cat("\n========== DURATION DE MACAULAY ==========\n\n")

cat("*** ¿QUÉ ES DURATION? ***\n")
cat("Duration = Promedio PONDERADO del tiempo hasta recibir los flujos\n")
cat("Unidades: AÑOS\n\n")

cat("INTERPRETACIÓN:\n")
cat("1. Punto de balance temporal de los flujos\n")
cat("2. Medida de SENSIBILIDAD al cambio en tasas\n")
cat("3. Mayor duration → Mayor sensibilidad → Mayor riesgo de tasa\n\n")

cat("FÓRMULA:\n")
cat("D_Mac = Σ [t × PV(CF_t)] / Precio\n\n")

# Calcular duration del ejemplo anterior
resultado_bono <- valorar_bono(VN = 1000, 
                                cupon_tasa = 0.06, 
                                plazo = 5, 
                                frecuencia = 2, 
                                yield = 0.08)

periodos <- resultado_bono$periodos
tiempo_años <- periodos / 2  # Convertir periodos a años
vp_flujos <- resultado_bono$vp_flujos
precio <- resultado_bono$precio

# Duration de Macaulay
ponderacion_tiempo <- tiempo_años * vp_flujos
duration_mac <- sum(ponderacion_tiempo) / precio

cat("=== CÁLCULO DE DURATION ===\n\n")

tabla_duration <- data.frame(
  Periodo = periodos,
  Tiempo_años = tiempo_años,
  Flujo = resultado_bono$flujos,
  VP_Flujo = vp_flujos,
  Peso = vp_flujos / precio,
  t_x_Peso = tiempo_años * vp_flujos / precio
)

print(tabla_duration)

cat("\nDuration de Macaulay:", round(duration_mac, 3), "años\n\n")

cat("*** INTERPRETACIÓN ***\n")
cat("Duration =", round(duration_mac, 2), "años\n")
cat("En promedio, recuperas tu inversión en ~", round(duration_mac, 2), "años.\n")
cat("Nota: El plazo del bono es 5 años, pero duration < 5\n")
cat("porque recibes cupones ANTES del vencimiento.\n\n")

# Propiedades de duration
cat("PROPIEDADES DE DURATION:\n")
cat("1. Bono cupón cero: Duration = Plazo\n")
cat("2. Bono con cupones: Duration < Plazo\n")
cat("3. Mayor tasa cupón → Menor duration\n")
cat("4. Mayor plazo → Mayor duration\n")
cat("5. Mayor yield → Menor duration\n\n")

# Función para calcular duration
calcular_duration <- function(VN, cupon_tasa, plazo, frecuencia, yield) {
  resultado <- valorar_bono(VN, cupon_tasa, plazo, frecuencia, yield)
  
  periodos <- resultado$periodos
  tiempo_años <- periodos / frecuencia
  vp_flujos <- resultado$vp_flujos
  precio <- resultado$precio
  
  duration <- sum(tiempo_años * vp_flujos) / precio
  
  return(duration)
}

################################################################################
# PARTE 7: DURATION MODIFICADA
################################################################################

cat("\n========== DURATION MODIFICADA ==========\n\n")

cat("La DURATION MODIFICADA mide la sensibilidad del PRECIO al cambio en YIELD.\n\n")

cat("FÓRMULA:\n")
cat("D_Mod = D_Mac / (1 + y/m)\n\n")

cat("Donde:\n")
cat("D_Mac = Duration de Macaulay\n")
cat("y = Yield\n")
cat("m = Frecuencia de capitalización\n\n")

# Calcular duration modificada
duration_mod <- duration_mac / (1 + y/frecuencia)

cat("Duration Modificada:", round(duration_mod, 3), "\n\n")

cat("*** USO PRÁCTICO ***\n")
cat("Cambio en Precio ≈ -D_Mod × ΔYield × Precio\n\n")

cat("EJEMPLO:\n")
cat("Si yield SUBE de 8% a 8.5% (Δy = +0.5% = 0.005):\n")
cat("ΔPrecio ≈ -", round(duration_mod, 3), "× 0.005 ×", round(precio, 2), "\n")

cambio_precio <- -duration_mod * 0.005 * precio
precio_nuevo_aprox <- precio + cambio_precio

cat("ΔPrecio ≈", round(cambio_precio, 2), "\n")
cat("Precio nuevo (aprox):", round(precio_nuevo_aprox, 2), "\n\n")

# Verificar con cálculo exacto
precio_nuevo_exacto <- valorar_bono(VN = 1000, 
                                     cupon_tasa = 0.06, 
                                     plazo = 5, 
                                     frecuencia = 2, 
                                     yield = 0.085)$precio

cat("Precio nuevo (exacto):", round(precio_nuevo_exacto, 2), "\n")
cat("Error de aproximación:", round(precio_nuevo_aprox - precio_nuevo_exacto, 2), "\n\n")

cat("La duration da una APROXIMACIÓN LINEAL del cambio en precio.\n")
cat("Para cambios grandes en yield, hay error porque la relación es CONVEXA.\n\n")

################################################################################
# PARTE 8: CONVEXIDAD
################################################################################

cat("\n========== CONVEXIDAD ==========\n\n")

cat("PROBLEMA: Duration asume relación LINEAL entre precio y yield.\n")
cat("REALIDAD: La relación es CONVEXA (curva).\n\n")

cat("CONVEXIDAD mide la CURVATURA de la relación precio-yield.\n\n")

cat("FÓRMULA APROXIMADA:\n")
cat("Convexidad ≈ (P+ + P- - 2P0) / (P0 × Δy²)\n\n")

cat("Donde:\n")
cat("P+ = Precio si yield sube Δy\n")
cat("P- = Precio si yield baja Δy\n")
cat("P0 = Precio actual\n\n")

# Calcular convexidad
delta_y <- 0.001  # 10 bps

precio_arriba <- valorar_bono(VN = 1000, cupon_tasa = 0.06, plazo = 5, 
                               frecuencia = 2, yield = y + delta_y)$precio

precio_abajo <- valorar_bono(VN = 1000, cupon_tasa = 0.06, plazo = 5, 
                              frecuencia = 2, yield = y - delta_y)$precio

precio_actual <- precio

convexidad <- (precio_arriba + precio_abajo - 2 * precio_actual) / 
              (precio_actual * delta_y^2)

cat("=== CÁLCULO DE CONVEXIDAD ===\n")
cat("Precio si yield +10bps:", round(precio_arriba, 2), "\n")
cat("Precio si yield -10bps:", round(precio_abajo, 2), "\n")
cat("Precio actual:", round(precio_actual, 2), "\n")
cat("Convexidad:", round(convexidad, 2), "\n\n")

cat("*** FÓRMULA MEJORADA CON CONVEXIDAD ***\n")
cat("ΔPrecio ≈ -D_Mod × ΔYield × P + 0.5 × Convexidad × (ΔYield)² × P\n\n")

# Comparar aproximaciones
delta_yield_grande <- 0.02  # Cambio de 2% (200 bps)

# Solo duration
cambio_duration <- -duration_mod * delta_yield_grande * precio

# Duration + convexidad
cambio_convexidad <- -duration_mod * delta_yield_grande * precio + 
                     0.5 * convexidad * (delta_yield_grande)^2 * precio

# Valor exacto
precio_exacto <- valorar_bono(VN = 1000, cupon_tasa = 0.06, plazo = 5, 
                               frecuencia = 2, yield = y + delta_yield_grande)$precio
cambio_exacto <- precio_exacto - precio

cat("Cambio en yield: +2% (de 8% a 10%)\n\n")
cat("Cambio real en precio:", round(cambio_exacto, 2), "\n")
cat("Aproximación con duration:", round(cambio_duration, 2), 
    " (error:", round(abs(cambio_exacto - cambio_duration), 2), ")\n")
cat("Aproximación con duration + convexidad:", round(cambio_convexidad, 2), 
    " (error:", round(abs(cambio_exacto - cambio_convexidad), 2), ")\n\n")

cat("¡La convexidad mejora significativamente la aproximación!\n\n")

cat("*** INTERPRETACIÓN DE CONVEXIDAD ***\n")
cat("Convexidad POSITIVA (siempre para bonos simples):\n")
cat("- Cuando yield baja → Precio sube MÁS de lo que predice duration\n")
cat("- Cuando yield sube → Precio baja MENOS de lo que predice duration\n")
cat("- ¡Convexidad es BUENA para el inversionista!\n\n")

################################################################################
# PARTE 9: INMUNIZACIÓN DE PORTAFOLIOS
################################################################################

cat("\n========== INMUNIZACIÓN DE PORTAFOLIOS ==========\n\n")

cat("PROBLEMA:\n")
cat("Un fondo de pensiones debe pagar $10,000,000 en exactamente 5 años.\n")
cat("¿Cómo invertir HOY para asegurar ese pago, sin importar cómo cambien las tasas?\n\n")

cat("SOLUCIÓN: INMUNIZACIÓN\n")
cat("Construir un portafolio de bonos con Duration = Horizonte de inversión\n\n")

cat("ESTRATEGIA:\n")
cat("1. Identificar horizonte: 5 años\n")
cat("2. Crear portafolio con Duration de Macaulay = 5 años\n")
cat("3. Si tasas cambian, ganancia en precio ≈ pérdida en reinversión\n\n")

# Ejemplo de inmunización
cat("*** EJEMPLO DE INMUNIZACIÓN ***\n\n")

pasivo <- 10000000  # Obligación en 5 años
horizonte <- 5      # años
tasa_actual <- 0.07  # 7%

# Valor presente del pasivo
vp_pasivo <- pasivo / (1 + tasa_actual)^horizonte

cat("Pasivo a pagar en", horizonte, "años:", pasivo, "\n")
cat("Valor presente (a tasa 7%):", round(vp_pasivo, 2), "\n\n")

cat("Necesitamos invertir", round(vp_pasivo, 2), "HOY\n")
cat("en un portafolio con Duration =", horizonte, "años\n\n")

# Opción 1: Bono cupón cero a 5 años (duration = 5)
cat("OPCIÓN 1: Bono cupón cero a 5 años\n")
cat("Duration = Plazo = 5 años ✓\n")
cat("Inversión requerida:", round(vp_pasivo, 2), "\n\n")

# Opción 2: Combinación de bonos cortos y largos
cat("OPCIÓN 2: Portafolio de dos bonos\n")
cat("Bono A: 3 años, duration = 2.8 años\n")
cat("Bono B: 10 años, duration = 7.5 años\n\n")

# Encontrar pesos para que duration del portafolio = 5
# w_A × 2.8 + w_B × 7.5 = 5
# w_A + w_B = 1

duration_A <- 2.8
duration_B <- 7.5
duration_objetivo <- 5

w_B <- (duration_objetivo - duration_A) / (duration_B - duration_A)
w_A <- 1 - w_B

cat("Pesos necesarios:\n")
cat("Bono A (3 años):", round(w_A * 100, 2), "%\n")
cat("Bono B (10 años):", round(w_B * 100, 2), "%\n\n")

cat("Verificación:\n")
cat("Duration del portafolio =", w_A, "×", duration_A, "+", w_B, "×", duration_B, "\n")
cat("                        =", round(w_A * duration_A + w_B * duration_B, 2), "años ✓\n\n")

cat("*** LIMITACIONES DE INMUNIZACIÓN ***\n")
cat("1. Solo protege contra CAMBIOS PARALELOS en la curva\n")
cat("2. Duration cambia con el tiempo (requiere REBALANCEO)\n")
cat("3. Asume reinversión de cupones a la misma tasa (no siempre cierto)\n")
cat("4. No considera convexidad (aproximación)\n\n")

################################################################################
# PARTE 10: BONOS MEXICANOS - APLICACIÓN PRÁCTICA
################################################################################

cat("\n========== BONOS GUBERNAMENTALES MEXICANOS ==========\n\n")

cat("*** CETES (Certificados de la Tesorería) ***\n")
cat("- Cupón: CERO (se compran con descuento)\n")
cat("- Plazos: 28, 91, 182, 364 días\n")
cat("- Emisor: Gobierno Federal (Banxico)\n")
cat("- Riesgo: Muy bajo (deuda soberana)\n")
cat("- Liquidez: MUY alta\n\n")

# Ejemplo CETES
cat("Ejemplo: CETES a 91 días\n")
vn_cetes <- 10
plazo_dias <- 91
tasa_cetes_anual <- 0.105  # 10.5% anual

precio_cetes <- vn_cetes / (1 + tasa_cetes_anual * plazo_dias/360)

cat("Valor nominal:", vn_cetes, "pesos\n")
cat("Tasa:", tasa_cetes_anual * 100, "% anual\n")
cat("Precio:", round(precio_cetes, 4), "pesos\n")
cat("Rendimiento:", round((vn_cetes - precio_cetes), 4), "pesos en", plazo_dias, "días\n\n")

cat("*** BONOS M (Bonos de Desarrollo) ***\n")
cat("- Cupón: FIJO semestral\n")
cat("- Plazos: 3, 5, 10, 20, 30 años\n")
cat("- Denominación: Pesos mexicanos\n")
cat("- Tasa cupón típica: 7-10% (depende del plazo y momento)\n\n")

# Ejemplo Bono M
cat("Ejemplo: Bono M a 10 años\n")
resultado_bonom <- valorar_bono(VN = 100, 
                                cupon_tasa = 0.08, 
                                plazo = 10, 
                                frecuencia = 2, 
                                yield = 0.09)

cat("Valor nominal: 100 pesos\n")
cat("Tasa cupón: 8% anual\n")
cat("Yield de mercado: 9% anual\n")
cat("Precio:", round(resultado_bonom$precio, 2), "pesos\n")
cat("Duration:", round(calcular_duration(100, 0.08, 10, 2, 0.09), 2), "años\n\n")

cat("*** UDIBONOS (Bonos indexados a inflación) ***\n")
cat("- Cupón: REAL (se ajusta por inflación vía UDIs)\n")
cat("- Plazos: 3, 10, 30 años\n")
cat("- Protección: INFLACIÓN\n")
cat("- Tasa cupón real típica: 3-4%\n\n")

cat("¿Cómo funcionan?\n")
cat("1. El principal se ajusta diariamente según UDIs\n")
cat("2. Los cupones se calculan sobre el principal ajustado\n")
cat("3. Al vencimiento, se paga el principal ajustado\n\n")

cat("Ejemplo conceptual:\n")
cat("- Compras 100 UDIs de un UDIBONO\n")
cat("- Valor de UDI hoy: 7.50 pesos → Inversión: 750 pesos\n")
cat("- Tasa cupón real: 4% anual semestral\n")
cat("- Después de 6 meses, UDI = 7.65 (inflación 2% semestral)\n")
cat("- Cupón = 100 UDIs × 4%/2 = 2 UDIs = 2 × 7.65 = 15.30 pesos\n")
cat("- Principal ajustado = 100 × 7.65 = 765 pesos\n\n")

cat("*** COMPARACIÓN ***\n")
cat("CETES: Muy corto plazo, sin riesgo de tasa, alta liquidez\n")
cat("BONOS M: Mediano/largo plazo, riesgo de tasa, cupón fijo en pesos\n")
cat("UDIBONOS: Largo plazo, protección inflación, cupón real\n\n")

################################################################################
# EJERCICIOS PARA LOS ESTUDIANTES
################################################################################

cat("\n\n")
cat("================================================================================\n")
cat("                         EJERCICIOS PARA PRÁCTICA\n")
cat("================================================================================\n\n")

cat("EJERCICIO 1: VALORACIÓN BÁSICA\n")
cat("-------------------------------\n")
cat("Valora un bono con las siguientes características:\n")
cat("- Valor Nominal: $1,000\n")
cat("- Tasa Cupón: 7% anual\n")
cat("- Plazo: 8 años\n")
cat("- Cupones: Semestrales\n")
cat("- Yield de mercado: 6% anual\n\n")
cat("a) Calcula el precio del bono\n")
cat("b) ¿Cotiza con prima, descuento, o a la par?\n")
cat("c) Crea una tabla con todos los flujos y sus valores presentes\n")
cat("d) Grafica los valores presentes de cada flujo\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 2: SENSIBILIDAD AL YIELD\n")
cat("-----------------------------------\n")
cat("Usando el bono del Ejercicio 1:\n\n")
cat("a) Calcula el precio para yields de 4%, 5%, 6%, 7%, 8%, 9%, 10%\n")
cat("b) Grafica la relación precio-yield\n")
cat("c) ¿Qué observas sobre la forma de la curva?\n")
cat("d) ¿Para qué yield el precio = valor nominal?\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 3: DURATION DE MACAULAY\n")
cat("----------------------------------\n")
cat("Para el bono del Ejercicio 1 (con yield = 6%):\n\n")
cat("a) Calcula la duration de Macaulay paso a paso\n")
cat("b) ¿Qué significa este número en años?\n")
cat("c) Compara duration con el plazo del bono (8 años)\n")
cat("d) ¿Por qué duration < plazo?\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 4: DURATION MODIFICADA Y SENSIBILIDAD\n")
cat("------------------------------------------------\n")
cat("Continuando con el mismo bono:\n\n")
cat("a) Calcula la duration modificada\n")
cat("b) Si yield sube de 6% a 7%, estima el cambio en precio\n")
cat("c) Calcula el precio exacto con yield = 7%\n")
cat("d) Compara tu estimación con el precio exacto\n")
cat("e) ¿Qué tan buena fue la aproximación?\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 5: CONVEXIDAD\n")
cat("------------------------\n")
cat("Para el bono del Ejercicio 1:\n\n")
cat("a) Calcula la convexidad\n")
cat("b) Si yield sube de 6% a 9% (+3%), estima cambio con:\n")
cat("   - Solo duration\n")
cat("   - Duration + convexidad\n")
cat("c) Calcula el precio exacto con yield = 9%\n")
cat("d) ¿Cuál aproximación fue mejor?\n")
cat("e) ¿Por qué la convexidad mejora la estimación?\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 6: INMUNIZACIÓN\n")
cat("--------------------------\n")
cat("Un fondo debe pagar $5,000,000 en exactamente 7 años.\n")
cat("Tasa actual de mercado: 8%\n\n")
cat("a) ¿Cuánto debe invertir hoy?\n")
cat("b) Si compra un bono cupón cero a 7 años, ¿cuál debe ser su VN?\n")
cat("c) Si usa dos bonos:\n")
cat("   Bono A: 4 años, duration = 3.6 años\n")
cat("   Bono B: 12 años, duration = 9.2 años\n")
cat("   ¿Qué % debe invertir en cada uno para inmunizar?\n")
cat("d) Verifica que duration del portafolio = 7 años\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\nEJERCICIO 7: COMPARACIÓN DE BONOS\n")
cat("----------------------------------\n")
cat("Compara dos bonos con igual plazo (5 años) y yield (8%):\n")
cat("Bono A: Tasa cupón 10% semestral\n")
cat("Bono B: Tasa cupón 4% semestral\n\n")
cat("a) Calcula el precio de cada uno\n")
cat("b) Calcula la duration de cada uno\n")
cat("c) ¿Cuál tiene mayor duration? ¿Por qué?\n")
cat("d) ¿Cuál es más sensible a cambios en tasas?\n")
cat("e) Si yield sube a 9%, ¿cuál baja más de precio?\n\n")

# ESPACIO PARA RESPUESTA




cat("\n\n")
cat("================================================================================\n")
cat("              FIN DE LA SESIÓN 6 - BONOS Y RENTA FIJA\n")
cat("================================================================================\n")
cat("\n")
cat("RECORDATORIOS:\n")
cat("- Precio y yield tienen relación INVERSA\n")
cat("- Duration mide sensibilidad al cambio en tasas\n")
cat("- Convexidad mide la curvatura (siempre positiva para bonos simples)\n")
cat("- Inmunización protege contra riesgo de tasa para un horizonte específico\n")
cat("- CETES (corto), Bonos M (fijo pesos), UDIBONOS (protección inflación)\n")
cat("\n")
cat("PRÓXIMA SESIÓN: VaR - Value at Risk\n")
cat("Comenzaremos el módulo de gestión de riesgos.\n")
cat("\n")

################################################################################
# FIN DEL SCRIPT
################################################################################
