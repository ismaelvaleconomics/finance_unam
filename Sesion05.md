# GUÍA - SESIÓN 5
## CAPM, Valuación Fundamental y Modelos Factoriales

**Curso:** Mercado de Capitales  
**Profesor:** Ismael Valverde 


---

## OBJETIVOS DE APRENDIZAJE

Al finalizar esta sesión, los estudiantes serán capaces de:

1. Explicar la lógica del CAPM y su relación con Markowitz
2. Calcular e interpretar beta (riesgo sistemático)
3. Distinguir entre riesgo sistem

ático y no sistemático
4. Usar la Security Market Line (SML) para valuación
5. Aplicar el modelo de descuento de dividendos (DDM)
6. Valuar acciones usando múltiplos (P/E, P/B, EV/EBITDA)
7. Entender las limitaciones del CAPM
8. Conocer el modelo de Fama-French como extensión

---

## CONEXIÓN CON SESIÓN ANTERIOR

**Sesión 4 (Markowitz):**
- Pregunta: ¿Cómo debe invertir UN individuo?
- Respuesta: Portafolio en la frontera eficiente

**Sesión 5 (CAPM):**
- Pregunta: ¿Qué pasa cuando TODOS invierten usando Markowitz?
- Respuesta: Equilibrio de mercado → CAPM

**Mensaje clave:**
"Markowitz nos dice QUÉ hacer. CAPM nos dice QUÉ ESPERAR en equilibrio."

---

## ESTRUCTURA DE LA SESIÓN

### BLOQUE 1: Introducción al CAPM

**1.1 Revisión y motivación**

**Pregunta:**
"En Sesión 4 vimos que todos deberían invertir en el portafolio tangente (máximo Sharpe).

¿Qué pasa si LITERALMENTE todos hacen eso?"

**Respuesta:**
"Si todos quieren comprar el mismo portafolio, los precios se ajustarán hasta alcanzar un EQUILIBRIO.

En ese equilibrio:
- El portafolio tangente = PORTAFOLIO DE MERCADO
- Todos los activos están correctamente valuados
- Existe una relación lineal entre riesgo y retorno"

**1.2 Supuestos del CAPM**

El Modelo de Valoración de Activos de Capital (CAPM) se basa en una serie de supuestos que simplifican la realidad para determinar la relación entre el riesgo sistémico y el rendimiento esperado:

1.  **Inversionistas son maximizadores de utilidad adversos al riesgo:** Los individuos son racionales y buscan maximizar su utilidad económica. Al ser adversos al riesgo, solo aceptarán mayor volatilidad si se les compensa con un mayor rendimiento esperado.
2.  **Eficiencia de Media-Varianza:** Los inversionistas evalúan sus portafolios basándose exclusivamente en dos parámetros: el rendimiento esperado (media) y el riesgo (varianza o desviación estándar).
3.  **Expectativas Homogéneas:** Todos los inversionistas tienen acceso a la misma información y la interpretan de la misma manera. Por lo tanto, todos coinciden en las estimaciones de rendimientos, volatilidades y correlaciones de los activos.
4.  **Horizonte de Inversión de un Solo Período:** Se asume que todos los inversionistas planifican sus decisiones de inversión para un mismo intervalo de tiempo idéntico (por ejemplo, un año).
5.  **Mercados de Capitales Perfectos:** No existen fricciones en el mercado. Esto implica que no hay impuestos ni costos de transacción, los activos son infinitamente divisibles y ningún inversionista tiene el poder de influir en los precios (competencia perfecta).
6.  **Préstamos y Endeudamiento a una Tasa Libre de Riesgo:** Todos los inversionistas pueden prestar o pedir prestado cualquier cantidad de capital a una tasa de interés única y libre de riesgo ($R_f$), la cual es la misma para todos.

**Representación Matemática de los Supuestos del CAPM**

A continuación se detalla la base formal y las ecuaciones que sustentan los seis supuestos del modelo:

### 1. Inversionistas son maximizadores de utilidad adversos al riesgo
Matemáticamente, esto se expresa a través de la **Función de Utilidad**, $U(W)$.
* **Aversión al riesgo:** La segunda derivada de la función de utilidad es negativa: $U''(W) < 0$. Esto significa que la función de utilidad es **cóncava**, lo que refleja una utilidad marginal decreciente de la riqueza.
* **Maximización:** Los inversionistas resuelven para:
    $$\max E[U(W)]$$

### 2. Eficiencia de Media-Varianza
Este supuesto asume que la utilidad de un inversionista es una función que depende únicamente de los dos primeros momentos de la distribución de los rendimientos.
* **Representación:** $U = f(E(R), \sigma^2)$.
* Esto es matemáticamente consistente si los rendimientos siguen una **Distribución Normal** $\mathcal{N}(\mu, \sigma^2)$ o si la función de utilidad es **Cuadrática**: $U(W) = aW - bW^2$.

### 3. Expectativas Homogéneas
Esto significa que todos los inversionistas utilizan los mismos datos de entrada para el problema de optimización de Markowitz.
* **Identidad:** Para cualquier par de inversionistas $i$ y $j$:
    $$E_i(R) = E_j(R) \quad \text{y} \quad \text{Cov}_i(R_x, R_y) = \text{Cov}_j(R_x, R_y)$$
    Esto lleva a que todos identifiquen exactamente el mismo **Portafolio de Tangencia**.



### 4. Horizonte de Inversión de un Solo Período
El modelo es "estático". Asume que todas las variables se miden en un único intervalo $[t, t+1]$.
* No hay un "rebalanceo" matemático o un "proceso estocástico" a través de múltiples pasos de tiempo en el CAPM estándar.

### 5. Mercados de Capitales Perfectos
Esto significa que los precios se determinan estrictamente por la oferta y la demanda sin "fricciones".
* **Sin costos de transacción:** El precio de compra ($P_b$) es igual al precio de venta ($P_s$): $P_b = P_s$.
* **Tomadores de precios:** La cantidad de intercambio de un individuo $q$ no afecta el precio $P$: $\frac{dP}{dq} = 0$.

### 6. Préstamos y Endeudamiento a una Tasa Libre de Riesgo
Este supuesto asume la existencia de un activo con varianza cero.
* **Representación:** Existe un activo $f$ tal que $\sigma_f = 0$ y $E(R_f) = R_f$.
* Los inversionistas pueden formar un portafolio $R_p$ con un peso $w$ en activos con riesgo y $(1-w)$ en el activo libre de riesgo:
    $$E(R_p) = wE(R_m) + (1-w)R_f$$
    $$\sigma_p = w\sigma_m$$

---

### La Línea del Mercado de Valores (SML)
Al combinar estas condiciones, obtenemos la ecuación central del CAPM:

$$E(R_i) = R_f + \beta_i [E(R_m) - R_f]$$

Donde el coeficiente $\beta_i$ se define como:
$$\beta_i = \frac{\text{Cov}(R_i, R_m)}{\text{Var}(R_m)}$$

---

**Discusión honesta:**

"Estos supuestos son CLARAMENTE irreales:
- ¿Todos tenemos las mismas expectativas? NO
- ¿No hay impuestos? NO
- ¿No hay costos de transacción? NO

PERO, el modelo es útil porque:
1. Captura una verdad fundamental (riesgo → retorno)
2. Es simple y elegante
3. Es un punto de partida para modelos más sofisticados
4. Funciona razonablemente bien empíricamente"

**1.3 La ecuación del CAPM **

$$E(R_i) = R_f + \beta_i [E(R_m) - R_f]$$

**Desglosar cada término:**

**$R_f$ (tasa libre de riesgo):**
- En México: Cetes a 28 días (~8-10% actualmente)
- En teoría: rendimiento SIN riesgo
- En práctica: gobierno puede hacer default (pequeño riesgo)

**$[E(R_m) - R_f]$(prima de riesgo de mercado):**
- Retorno extra por invertir en mercado vs rf
- Históricamente en México: ~5-7%
- Compensa por asumir riesgo sistemático

**$\beta_i$ (beta del activo i):**
- Mide sensibilidad al mercado
- β = 1: se mueve como el mercado
- β > 1: amplifica movimientos del mercado
- β < 1: amortigua movimientos del mercado

**Ejemplo numérico:**

```
Supongamos:
rf = 8%
E(Rm) = 14%
Prima = 14% - 8% = 6%

Si β_WALMEX = 0.8:
E(R_WALMEX) = 8% + 0.8 × 6% = 12.8%

Si β_CEMEX = 1.5:
E(R_CEMEX) = 8% + 1.5 × 6% = 17%
```

**Pregunta al grupo:**
"¿Por qué CEMEX debería tener mayor retorno esperado?"

(Respuesta: Mayor beta = mayor riesgo sistemático)

---

### BLOQUE 2: Beta y riesgo

**2.1 Riesgo sistemático vs no sistemático**
```
RIESGO TOTAL
    |
    |--- Riesgo SISTEMÁTICO (beta)
    |     • Afecta a todo el mercado
    |     • NO eliminable con diversificación
    |     • Ejemplos: recesión, inflación, guerra
    |     • EL MERCADO COMPENSA
    |
    |--- Riesgo NO SISTEMÁTICO (idiosincrático)
          • Específico de la empresa
          • SÍ eliminable con diversificación
          • Ejemplos: huelga, demanda, cambio CEO
          • EL MERCADO NO COMPENSA
```

**Historia para ilustrar:**

"Imaginen dos noticias:

**Noticia 1:** El Banco de México sube tasas de interés 1%
→ Afecta a TODAS las empresas
→ Riesgo SISTEMÁTICO
→ No puedes diversificar esto

**Noticia 2:** Un incendio destruye una planta de CEMEX
→ Afecta solo a CEMEX
→ Riesgo NO SISTEMÁTICO
→ Si tienes 20 acciones, esto solo afecta 5% de tu portafolio"

**Implicación crucial:**

"El CAPM dice: solo el riesgo sistemático (beta) debería ser compensado.

¿Por qué? Porque el riesgo no sistemático lo puedes eliminar gratis (diversificando).

Si una acción tiene alto riesgo NO sistemático, la solución no es pagar menos por ella... es DIVERSIFICAR."

**2.2 Estimación de beta con regresión**

Ejecutar Parte 4 del script en vivo.

**Explicación de la regresión:**

"Vamos a estimar beta con una regresión simple:

$$R_{acción} = \alpha + \beta \times R_{mercado} + \epsilon$$

Esto se llama la 'línea característica' de la acción."

**Proyectar los resultados:**

```
Call:
lm(formula = Accion ~ Mercado, data = retornos)

Coefficients:
            Estimate Std. Error t value Pr(>|t|)
(Intercept)  0.00015    0.00023   0.65    0.515
Mercado      0.85432    0.04125  20.71   <2e-16 ***

R-squared: 0.523
```

**Interpretación guiada:**

"**$\beta$ = 0.85**
- La acción se mueve 85% de lo que se mueve el mercado
- Es ligeramente DEFENSIVA (< 1)
- Si el IPC sube 10%, esperamos que esta acción suba ~8.5%

**$\alpha$ = 0.00015 diario = 3.8% anual**
- Retorno extra no explicado por el mercado
- POSITIVO: la acción superó el CAPM
- Pero miren el p-value = 0.515 → NO es estadísticamente significativo

**$R^{2}$ = 0.523**
- 52.3% de la varianza de la acción se explica por el mercado
- 47.7% es riesgo específico (diversificable)
- $R^{2}$ típicos: 0.2-0.6 para acciones individuales"

**Mostrar gráfica de dispersión:**

Señalar:
- Nube de puntos = cada día
- Línea roja = regresión ($\beta$ = pendiente)
- Línea gris = $\beta$ = 1 (referencia)
- Distancia vertical de puntos a línea = riesgo específico

**2.3 Interpretación de diferentes betas**

**Ejemplos típicos:**

$$\begin{aligned} \beta \approx 0.5 - 0.7: & \quad \text{Servicios públicos (Utilities), consumo básico (defensivas)} \\ \beta \approx 0.8 - 1.2: & \quad \text{Mayoría de empresas grandes} \\ \beta \approx 1.3 - 1.8: & \quad \text{Tecnología, construcción (agresivas)} \\ \beta \approx 2.0+: & \quad \text{Muy volátiles, pequeñas, apalancadas} \\ \beta \approx 0 \text{ o neg}: & \quad \text{Oro, algunos bonos (cobertura)} \end{aligned}$$

**Pregunta:**

"Si esperan una RECESIÓN, ¿preferirían acciones con beta alto o bajo?"

(Respuesta: Bajo - se caen menos que el mercado)

"Si esperan EXPANSIÓN económica, ¿beta alto o bajo?"

(Respuesta: Alto - suben más que el mercado)

---

### BLOQUE 3: Security Market Line

**3.1 Construcción de la SML**

Ejecutar Parte 5 del script.

**Explicación:**

"La SML grafica la relación CAPM:
- Eje X: Beta (riesgo)
- Eje Y: Retorno esperado

Todos los activos correctamente valuados deberían estar EN la línea."

**Proyectar gráfica SML.**

**Puntos clave:**

1. **Punto (0, rf):**
   "$\beta = 0$, retorno = $r_f$
   Un activo sin riesgo sistemático gana solo rf"

2. **Punto (1, E(Rm)):**
   "$\beta = 1$, retorno = $E(R_m)$
   El MERCADO tiene beta de 1 por definición"

3. **La línea:**
   "Pendiente = prima de riesgo de mercado
   Más empinada $\rightarrow$ mayor compensación por riesgo"

**3.2 Uso de SML para valuación**

"Si una acción está:

**ARRIBA de la línea:**
- Retorno esperado $>$ lo que predice CAPM
- Está INFRAVALUADA
- Recomendación: COMPRAR
- Eventualmente subirá de precio

**ABAJO de la línea:**
- Retorno esperado $<$ lo que predice CAPM
- Está SOBREVALUADA
- Recomendación: VENDER
- Eventualmente bajará de precio

**EN la línea:**
- Correctamente valuada
- No hay oportunidad de arbitraje"

**Ejemplo numérico:**

```
Acción XYZ:
- Beta = 1.2
- Retorno esperado según CAPM = 8% + 1.2 × 6% = 15.2%
- Retorno histórico = 18%

Está 2.8% ARRIBA de la línea
→ Posible infravaloración
→ Investigar más antes de comprar
```

**Advertencia:**

"En la práctica:
- Betas cambian en el tiempo
- Estimaciones tienen error
- Expectativas difieren entre inversionistas
- No hay 'free lunch' tan obvio

Pero la intuición es correcta: buscar activos con retorno alto relativo a su riesgo sistemático."

---

### BLOQUE 4: Valuación fundamental - DDM

**4.1 Modelo de Gordon**

Ejecutar Parte 6 del script.

**Introducción:**

"Hasta ahora: CAPM nos dice retorno ESPERADO dado el riesgo.

Ahora: ¿Cuál debería ser el PRECIO de una acción?

Modelo de descuento de dividendos: El valor presente de TODOS los dividendos futuros."

**Fórmula de Gordon:**

$$P_0 = \frac{D_1}{r - g}$$

Donde:
$P_{0}$ = Precio justo HOY
$D_{1}$ = Dividendo próximo año
$r$ = Tasa de descuento (retorno requerido)
$g$ = Crecimiento perpetuo de dividendos

**Ejemplo en pizarra:**
```
Empresa XYZ:
- Dividendo este año: D₀ = $2.50
- Crecimiento esperado: g = 5%
- Retorno requerido: r = 12% (del CAPM)

D₁ = $2.50 × 1.05 = $2.625

P₀ = $2.625 / (0.12 - 0.05)
   = $2.625 / 0.07
   = $37.50

Si precio de mercado = $32 → INFRAVALUADA (comprar)
Si precio de mercado = $45 → SOBREVALUADA (vender)
```
**4.2 Limitaciones del DDM**

**Problema 1: Sensibilidad extrema**

Mostrar gráfica de sensibilidad del script.

"Observen: un pequeño cambio en 'g' cambia DRAMÁTICAMENTE el precio.

g = 4%: P = $43.75
g = 5%: P = $37.50
g = 6%: P = $31.88

Diferencia de 1% en g → Cambio de $12 en precio!"

**Problema 2: Solo para empresas con dividendos**

"No funciona para:
- Empresas que no pagan dividendos (ej: Amazon históricamente)
- Empresas en crecimiento que reinvierten todo
- Startups

Necesitas otras metodologías."

**Problema 3: Crecimiento perpetuo**

"Asumir crecimiento constante para SIEMPRE es poco realista.

Alternativas más sofisticadas:
- Modelo de dos etapas (crecimiento alto, luego estable)
- Modelo de tres etapas
- Flujos de efectivo descontados (DCF) - más general"

**4.3 ¿Cuándo usar DDM?**

"El DDM funciona bien para:
- Empresas maduras
- Dividendos estables y predecibles
- Utilities, telecomunicaciones, algunas financieras
- Análisis de largo plazo

En México, candidatos:
- América Móvil (si paga dividendos estables)
- Kimberly-Clark
- Algunas FIBRAs (inmobiliarias)"

---

### BLOQUE 5: Valuación por múltiplos

**5.1 Introducción a múltiplos**

"En lugar de modelar flujos futuros, comparamos con empresas similares.

Pregunta: '¿Cuánto paga el mercado por empresas como esta?'"

**Múltiplos principales:**

**1. $\frac{P}{E}$ (Price-to-Earnings):**
```
P/E = Precio / Utilidad por Acción

Ejemplo: Acción a $50, UPA = $5 → P/E = 10

Interpretación: Pagas $10 por cada $1 de utilidades anuales
```
```
P/E típicos:
- Utilities: 12-15
- Retail: 15-20
- Tecnología: 20-30
- Startups sin utilidades: ∞ (no aplicable)
```
**2. $\frac{P}{B}$ (Price-to-Book):**
```
P/B = Precio / Valor en Libros

P/B < 1: Precio menor que valor contable (posible ganga)
P/B > 1: Mercado valora más que contabilidad (típico)
```

**3. EV/EBITDA:**
```
Más completo que P/E
Incluye deuda en el numerador
Útil para comparar empresas con diferente estructura de capital
```
**5.2 Ejemplo práctico**

Ejecutar Parte 7 del script.

Mostrar tabla de comparación.

**Análisis guiado:**

"Veamos la tabla:

```
Empresa          Precio  UPA   P/E   P/B
Competidor A      45    4.8   9.4   1.6
Competidor B      52    5.5   9.5   1.5
Competidor C      38    4.2   9.0   1.5
Promedio                      9.3   1.5

Nuestra Empresa    ?    5.2    ?     ?
```

Por P/E: Precio implícito = 5.2 × 9.3 = $48.36
Por P/B: Precio implícito = 32 × 1.5 = $48.00

Si precio de mercado = $42 → INFRAVALUADA
Si precio de mercado = $55 → SOBREVALUADA"

**5.3 Ventajas y limitaciones**

**PROS:**
- ✓ Simple y rápido
- ✓ Basado en comparables reales
- ✓ No requiere proyecciones complejas
- ✓ Intuitivo para presentar

**CONTRAS:**
- ✗ Difícil encontrar comparables verdaderamente similares
- ✗ Si todo el sector está mal valuado, múltiplos también
- ✗ No captura potencial único de crecimiento
- ✗ Contabilidad puede diferir entre empresas

**Mejores prácticas:**
- Usar MÚLTIPLES múltiplos (P/E, P/B, EV/EBITDA)
- Ajustar por diferencias (crecimiento, márgenes, riesgo)
- Complementar con otros métodos (DDM, DCF)

---

### BLOQUE 6: Modelo de Fama-French

**6.1 Motivación**

"PROBLEMA con CAPM:

Empíricamente, el CAPM no explica bien todos los retornos.

**Anomalías documentadas:**
1. Empresas PEQUEÑAS superan a grandes (size effect)
2. Empresas VALUE (P/B bajo) superan a GROWTH (small effect)
3. Momentum: ganadoras siguen ganando

¿Por qué el CAPM falla? Porque beta NO es el único factor de riesgo."

**6.2 Modelo de 3 factores**

Ejecutar Parte 8 del script.

"**Eugene Fama & Kenneth French (1992):**

Agregaron DOS factores al CAPM:

$$R_i - R_f = \alpha + \beta_m(R_m - R_f) + \beta_s SMB + \beta_v HML + \epsilon$$

-   **$R_i - R_f$**: Represente el exceso de retorno del activo sobre la tasa libre de riesgo.
    
-   **$\alpha$**: Representa el retorno no explicado por los factores.
    
-   **$\beta_m(R_m - R_f)$**: El factor de la prima de riesgo del mercado (*the classic CAPM component*).
    
-   **$\beta_s SMB$**: El factor "Small Minus Big" factor.
    
-   **$\beta_v HML$**: El factor "High Minus Low" (*book-to-market ratio*).

Este modelo fue desarrollado para abordar las fallas empíricas del CAPM. Mientras que el CAPM solo utiliza un factor (el mercado), Fama y French añadieron el Tamaño (Size) y el Valor (Value) porque observaron que las acciones de pequeña capitalización y las acciones de valor superaban consistentemente el promedio del mercado a lo largo del tiempo.

SMB = Small Minus Big (tamaño)
HML = High Minus Low (valor)

**SMB (Small Minus Big):**
- Retorno de small caps - retorno de large caps
- Captura 'efecto tamaño'
- $\beta_{SMB} > 0$: empresa pequeña

**HML (High Minus Low):**
- Retorno de value stocks - retorno de growth stocks
- Captura 'efecto valor'
- $\beta_{HML} > 0$: empresa value (P/B bajo)"

**Ejemplo conceptual:**

```
Empresa: CEMEX (materiales, cíclica)
- β_mercado = 1.3 (volátil)
- β_SMB = -0.2 (empresa grande)
- β_HML = 0.4 (algo value)

Retorno esperado = rf + 1.3×(Rm-rf) - 0.2×SMB + 0.4×HML
```

**Nota práctica:**

"Para México, estos factores NO están fácilmente disponibles.

En EE.UU., Kenneth French los publica en su sitio web.

Para análisis serio en México, habría que:
1. Clasificar todas las empresas de la BMV por tamaño
2. Clasificar por P/B (value vs growth)
3. Construir portafolios long-short
4. Calcular retornos de estos portafolios

Es posible, pero laborioso."

---

### BLOQUE 7: Aplicación práctica - Betas de sectores

Ejecutar Parte 9 del script.

**Mostrar tabla de betas:**

```
Acción      Beta    R²
WALMEX      0.75   0.48
CEMEX       1.45   0.38
BANORTE     1.15   0.52
FEMSA       0.82   0.44
```

**Análisis por sector:**

"**CEMEX (Materiales, cíclico):**
- Beta MÁS ALTO (1.45)
- ¿Por qué? Sector muy sensible a economía
- Recesión $\rightarrow$ construcción para $\rightarrow$ CEMEX sufre mucho
- Expansión $\rightarrow$ construcción sube $\rightarrow$ CEMEX sube mucho

**WALMEX (Retail, consumo básico):**
- Beta MÁS BAJO (0.75)
- ¿Por qué? Gente siempre necesita comida
- Defensivo en recesiones
- Pero sube menos en expansiones

**BANORTE (Financiero):**
- Beta MEDIO-ALTO (1.15)
- Sensible a tasas de interés y economía
- Típico de bancos

**FEMSA (Bebidas, consumo):**
- Beta BAJO-MEDIO (0.82)
- Similar a WALMEX, algo defensivo"

**Pregunta al grupo:**

"Estamos en 2024. Si esperan:

a) RECESIÓN en 2025 → ¿Qué acción prefieren?"
(Respuesta: WALMEX o FEMSA - defensivas)

b) EXPANSIÓN fuerte → ¿Qué acción?"
(Respuesta: CEMEX - agresiva, captura crecimiento)

**Lección:**

"Beta no es solo un número abstracto. 

Refleja CARACTERÍSTICAS REALES del negocio:
- Cíclico vs defensivo
- Sensibilidad a economía
- Apalancamiento operativo

Entender el negocio $\rightarrow$ Entender el beta"

---

### CIERRE Y PREPARACIÓN SESIÓN 6

**Resumen de puntos clave:**

1. **CAPM:** Equilibrio de mercado $\rightarrow$ relación riesgo-retorno
2. **Beta:** Riesgo sistemático, no diversificable
3. **SML:** Herramienta de valuación relativa
4. **DDM:** Valuación por dividendos (empresas maduras)
5. **Múltiplos:** Valuación comparativa (simple, rápida)
6. **Fama-French:** CAPM no es perfecto, hay otros factores

**PRÓXIMA SESIÓN: Renta Fija y Bonos**

Aplicaremos descuento de flujos a BONOS:
- Duration (sensibilidad a tasas)
- Convexidad
- Inmunización de portafolios

Los bonos son MÁS simples que acciones (flujos predecibles) pero las matemáticas son interesantes."

---

## EJERCICIOS Y TAREA

**Obligatorios:** 1-4  
**Avanzados:** 5-7

**Énfasis especial:**
- Ejercicio 1 (estimación de beta) es FUNDAMENTAL
- Ejercicio 4 (DDM) conecta teoría con práctica
- Ejercicio 7 (betas por sector) desarrolla intuición

---

## PROBLEMAS COMUNES Y SOLUCIONES

### Problema 1: Beta negativo
**Causa:** Correlación negativa con mercado (raro)  
**Solución:** Verificar datos, puede ser oro, algunos bonos

### Problema 2: $R^{2}$ muy bajo
**Causa:** Mucho riesgo específico  
**Explicación:** Normal para empresas pequeñas, β menos confiable

### Problema 3: DDM da precio negativo
**Causa:** g >= r  
**Solución:** Modelo no aplicable, usar método alternativo

---

## PUNTOS PEDAGÓGICOS CRÍTICOS

### 1. No sobrevender el CAPM
- Reconocer limitaciones abiertamente
- Es un MODELO, no la realidad
- Útil como framework, no como verdad absoluta

### 2. Conectar beta con negocio real
- No es solo matemáticas
- Refleja características del sector
- Ayuda a desarrollar intuición

### 3. Valuación es arte Y ciencia
- DDM y múltiplos dan resultados diferentes
- Ningún método es perfecto
- Usar múltiples enfoques

### 4. Énfasis en interpretación
- Más importante entender QUÉ significa beta
- Que calcular beta perfectamente

---

## EVALUACIÓN DE LA SESIÓN

### Indicadores de éxito de esta sesión, considera que esta sesión es fundamental para el curso:
- [ ] Puedes calcular beta en R
- [ ] Interpretas beta correctamente (agresivo/defensivo)
- [ ] Entiendes diferencia riesgo sistemático vs específico
- [ ] Puedes aplicar DDM a empresa real
- [ ] Reconoces limitaciones de cada modelo
