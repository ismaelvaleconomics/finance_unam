# GUÍA - SESIÓN 10

## Stress Testing

**Curso:** Mercado de Capitales
**Profesor:** Ismael Valverde

----------

## OBJETIVOS DE APRENDIZAJE

Al finalizar esta sesión, serás capaz de:

1.  Explicar la diferencia fundamental entre el VaR y el stress testing
2.  Identificar y clasificar los episodios históricos de estrés relevantes para México
3.  Aplicar stress histórico reproduciendo crisis pasadas en el portafolio actual
4.  Diseñar escenarios hipotéticos con shocks a factores de riesgo específicos
5.  Construir y leer una matriz de sensibilidad por posición y escenario
6.  Realizar un stress test inverso: encontrar el shock que produce una pérdida dada
7.  Elaborar un reporte resumen de stress para comunicar el riesgo a distintas audiencias

----------

## CONTEXTO Y MOTIVACIÓN

### Las cuatro preguntas de riesgo

A lo largo de las últimas sesiones hemos construido un conjunto de herramientas que responden cuatro preguntas distintas sobre el riesgo del portafolio:

Sesión 7 — VaR:
  "En el 5% de los días peores, ¿Cuánto perdemos como mínimo?"
  $\rightarrow$ respuesta estadística basada en la distribución histórica

Sesión 8 — CVaR:
  "Cuando ya estamos en ese 5% peor, ¿cuánto perdemos en promedio?"
   $\rightarrow$ respuesta sobre la severidad dentro de la cola

Sesión 9 — GARCH:
  "¿Cuánta volatilidad tiene el portafolio hoy, dado lo que ocurrió ayer?"
   $\rightarrow$ respuesta dinámica que actualiza el riesgo cada día

Sesión 10 — Stress testing:
  "¿Cuánto perdería el portafolio si ocurriera exactamente este evento?"
   $\rightarrow$ respuesta condicional a un escenario específico

Las cuatro preguntas son complementarias. Ninguna reemplaza a las otras. Un gestor de riesgos las usa en conjunto.

### Por qué el VaR no es suficiente

El VaR y el CVaR son excelentes para caracterizar el riesgo en condiciones de mercado "normales", incluyendo los episodios pasados que ya están en el historial. Pero tienen un límite estructural: solo conocen el pasado que se les entregó como dato.

El stress testing supera ese límite de tres formas:

**Eventos fuera del historial.** Si el período de datos comienza en 2010, el modelo no "sabe" lo que ocurrió en la crisis de 1994–95 o en 2008. El stress histórico puede aplicar esos episodios manualmente aunque no estén en la muestra de estimación.

**Eventos diseñados.** Un escenario hipotético puede representar algo que aún no ha ocurrido pero que el analista considera plausible: una rebaja de calificación soberana, un conflicto geopolítico, un cambio regulatorio brusco. El VaR nunca generará ese escenario porque no está en la historia.

**Comunicación.** Los directivos y reguladores no piensan en percentiles estadísticos. Piensan en eventos: "¿qué nos haría perder si el peso se deprecia 20%?" El stress testing traduce el riesgo a un lenguaje narrativo que facilita las decisiones de gestión.

### El mandato regulatorio en México

La CNBV y Banxico exigen a las instituciones financieras mexicanas la realización de pruebas de estrés periódicas como parte de sus marcos de gestión de riesgos. Las disposiciones específicas incluyen:

-   Circular Única de Bancos: pruebas de estrés de capital bajo escenarios adversos
-   Reglas CONSAR para AFORES: escenarios de estrés para los distintos tipos de Siefore
-   Marco de supervisión bancaria de Banxico: stress macroeconómico de todo el sistema

----------

## CONEXIÓN CON SESIONES ANTERIORES

**Sesiones 7–8 (VaR y CVaR):**

-   El stress testing no reemplaza al VaR sino que lo complementa. La tabla comparativa final de esta sesión coloca ambos lado a lado para mostrar que los escenarios severos producen pérdidas mayores que el CVaR 99% — eso es precisamente lo que hace útil el stress
-   El drawdown máximo es la versión multiperíodo de las métricas de cola que ya conoces

**Sesión 9 (GARCH):**

-   La volatilidad condicional actual σ_t del GARCH entra directamente en el stress escalado: los shocks históricos se amplifican o reducen según el nivel de riesgo actual del mercado
-   Las trayectorias simuladas del Ejercicio 7 de la Sesión 9 son escenarios de volatilidad futura que pueden combinarse con los shocks de esta sesión

**Sesión 4 (Markowitz):**

-   Los pesos del portafolio MV determinan cuánto impacta cada shock al total. El Ejercicio 5 (stress con rebalanceo) muestra que optimizar los pesos para reducir el stress es la otra cara de la misma moneda que optimizar para minimizar varianza

**Mensaje clave:** "El stress testing es el final del hilo: VaR dice cuándo el riesgo existe, CVaR dice cuánto pesa, GARCH dice cuándo estamos en zona de peligro, y el stress dice exactamente qué pasaría si el peor escenario se materializara."

----------

## ESTRUCTURA DE LA SESIÓN

### BLOQUE 1: Taxonomía del stress testing

Antes de calcular cualquier número, es importante entender las tres categorías principales:

**Stress histórico**

Toma un período de crisis pasado y calcula qué le habría ocurrido al portafolio actual si los rendimientos de ese período se repitieran. El portafolio puede tener una composición diferente a la que tenía durante la crisis, pero los shocks son los observados históricamente.

La ventaja es que los shocks son completamente reales: no hay supuesto alguno sobre la magnitud ni la distribución. La limitación es que solo puede representar lo que ya ocurrió.

Vea el apéndice.

**Stress hipotético**

Define shocks específicos a los factores de riesgo relevantes (mercado, tipo de cambio, tasas, commodities) y calcula el impacto mediante las sensibilidades del portafolio a esos factores. El analista diseña el escenario partiendo de una narrativa económica.

La ventaja es la flexibilidad: puede representar eventos que nunca han ocurrido. La limitación es que los shocks son subjetivos y pueden ser inconsistentes entre sí (no todos los mercados caen simultáneamente en la misma magnitud).

Vea el apéndice.

**Stress inverso**

En lugar de partir del escenario para llegar a la pérdida, parte de la pérdida para encontrar el escenario. Responde: "¿qué tendría que ocurrir para que perdiera el 15% del portafolio?" Es especialmente útil para dimensionar el "escenario de quiebra" y para identificar los factores de riesgo más críticos.

Vea el apéndice.

----------

### BLOQUE 2: Episodios históricos de estrés para México

Para aplicar el stress histórico, primero hay que identificar qué períodos representan los episodios de estrés más relevantes para el portafolio de acciones mexicanas.

El script calcula automáticamente los períodos de mayor volatilidad y los peores días, pero vale la pena conocer la narrativa detrás de cada episodio:

```
Crisis Financiera Global (2008–2009)
  Detonador:  quiebra de Lehman Brothers, septiembre 2008
  Canales:    colapso del crédito global; caída del comercio exterior;
              depreciación del MXN; contracción del PIB mexicano −6.5% en 2009
  IPC:        caída de ~50% desde el máximo (oct 2007 – mar 2009)

Caída del Precio del Petróleo (2014–2016)
  Detonador:  sobreoferta global de petróleo; precio WTI cae de $107 a $26
  Canales:    reducción de ingresos fiscales; presión sobre MXN;
              deterioro fiscal de PEMEX; revisión de calificación soberana
  IPC:        caída moderada pero MXN se deprecia ~50% vs. USD

Resultado Electoral EUA 2016
  Detonador:  victoria de Trump; amenazas de renegociar TLCAN
  Canales:    depreciación brusca del MXN en una noche (−12% el 9 nov 2016)
              incertidumbre sobre el sector exportador mexicano
  IPC:        caída de ~8% en pocas sesiones

Crisis COVID-19 (2020)
  Detonador:  declaración de pandemia (11 marzo 2020)
  Canales:    paralización económica global; caída del petróleo;
              salida de capitales de mercados emergentes
  IPC:        caída de ~35% en 5 semanas (feb–mar 2020)
  Único:      recuperación en forma de V más rápida que en 2008–2009

Ciclo de Alzas Fed (2022)
  Detonador:  inflación global post-pandemia; Fed sube tasas 425 pbs en un año
  Canales:    salida de capitales de emergentes; fortalecimiento del USD;
              presión sobre bonos corporativos con deuda en dólares
  IPC:        caída moderada pero sectores endeudados (CEMEX) muy afectados

```

----------

### BLOQUE 3: La mecánica del stress histórico

**Cálculo del rendimiento acumulado**

Desarrollemos este punto explicando **por qué la composición geométrica es matemáticamente obligatoria en el _stress testing_ multiperiodo** y cómo la aproximación lineal (aritmética) sesga los resultados de manera peligrosa.

En el análisis de riesgo, cuando estresamos un portafolio a lo largo de un horizonte temporal de varios días ($T > 1$), no podemos simplemente sumar los rendimientos diarios. Entremos a la formalización matemática de este fenómeno.

#### 1. Formalización del Rendimiento Acumulado Estresado

Sea $V_0$ el valor inicial del portafolio al comienzo del episodio de estrés. Al final de cada día $t$ dentro de la ventana de crisis $\tau \in \{1, \dots, T\}$, el valor del portafolio se actualiza de manera iterativa de la siguiente forma:

-   **Día 1:** $V_1 = V_0(1 + r_1)$

-   **Día 2:** $V_2 = V_1(1 + r_2) = V_0(1 + r_1)(1 + r_2)$

-   **Día $T$:** $V_T = V_0 \prod_{t=1}^{T} (1 + r_t)$


Por lo tanto, el **Rendimiento Acumulado Real ($R_{geom}$)** del portafolio al final del episodio es el cambio porcentual directo en su valor:

$$R_{geom} = \frac{V_T - V_0}{V_0} = \frac{V_0 \prod_{t=1}^{T} (1 + r_t) - V_0}{V_0}$$

$$\mathbf{R_{geom} = \prod_{t=1}^{T} (1 + r_t) - 1}$$

Esta es la forma **no lineal** correcta de acumular los shocks del mercado.

#### 2. La Falacia de la Suma (Aproximación Lineal)

Muchos analistas o modelos simplificados cometen el error de utilizar el **Rendimiento Aritmético Acumulado ($R_{arit}$)**, definido como:

$$R_{arit} = \sum_{t=1}^{T} r_t$$

- La Demostración Matemática del Sesgo

Para entender el origen del sesgo, podemos expandir algebraicamente el producto para el caso de dos días ($T=2$):

$$R_{geom} = (1 + r_1)(1 + r_2) - 1 = 1 + r_1 + r_2 + (r_1 \cdot r_2) - 1$$

$$R_{geom} = (r_1 + r_2) + (r_1 \cdot r_2)$$

Sustituyendo la definición del rendimiento aritmético, llegamos a la relación fundamental:

$$\mathbf{R_{geom} = R_{arit} + (r_1 \cdot r_2)}$$

El término $\mathbf{r_1 \cdot r_2}$ es el **efecto de interacción o de capitalización**. Es el que determina la dirección y magnitud del sesgo.

#### 3. Comportamiento del Sesgo en Escenarios de Estrés (Días Negativos Consecutivos)

Analicemos matemáticamente qué ocurre en una crisis financiera, donde la característica principal es la persistencia de choques severos y negativos en la misma dirección (por ejemplo, una racha de días donde $r_t < 0$).

Si el día 1 y el día 2 son negativos, entonces $r_1 < 0$ y $r_2 < 0$. Al multiplicar dos números negativos, el signo del término de interacción se vuelve **positivo**:

$$(r_1 \cdot r_2) > 0$$

Por lo tanto, la relación matemática nos dice que:

$$R_{geom} > R_{arit}$$

Dado que ambos rendimientos representan pérdidas (son números negativos), que $R_{geom}$ sea _mayor_ (más cercano a cero) que $R_{arit}$ significa que **la pérdida real geométrica es menor que la pérdida calculada por la suma**.

> **Conclusión del Sesgo:** Al usar la suma ($\sum r_t$), estás asumiendo que los rendimientos negativos siempre operan sobre el capital inicial $V_0$. En la realidad, el segundo día de caída opera sobre un capital que _ya disminuyó_ el día anterior ($V_1 < V_0$). Por ende, el impacto absoluto de la segunda caída es menor en dinero real. **La suma sobreestima la pérdida del portafolio.**

#### Ejemplo Numérico

Imagine un portafolio de $100$ USD que sufre dos días consecutivos de choques del $-10\%$ ($r_1 = -0.10$, $r_2 = -0.10$).

-   **Enfoque Aritmético (Suma):**

    $$R_{arit} = (-0.10) + (-0.10) = -0.20 \quad (-20\%)$$

    Pérdida calculada: **$-20$ USD** (Valor final teórico: $80$).

-   **Enfoque Geométrico (Producto):**

    $$R_{geom} = (1 - 0.10)(1 - 0.10) - 1 = (0.90)(0.90) - 1 = 0.81 - 1 = -0.19 \quad (-19\%)$$

    Pérdida real: **$-19$ USD** (Valor final real: $\$81$).


**El error:** El método de la suma sobreestimó la pérdida por un $1\%$ del portafolio total (el término $r_1 \cdot r_2 = (-0.10)(-0.10) = +0.01$). En portafolios institucionales de miles de millones, este error es masivo.

#### 4. La Excepción Matemática: Rendimientos Logarítmicos

Para cerrar el marco analítico, vale la pena hacer una precisión técnica: este sesgo ocurre únicamente si estás trabajando con **rendimientos lineales o porcentuales**.

Si en tu modelo de _stress testing_ los shocks pasados o hipotéticos se extrajeron como **rendimientos logarítmicos (continuamente compuestos)**, donde:

$$r^{log}_t = \ln\left(\frac{V_t}{V_{t-1}}\right)$$

Entonces la propiedad de los logaritmos permite que la suma matemática sea **exactamente igual** a la composición geométrica:

$$R^{log}_{acumulado} = \sum_{t=1}^{T} \ln\left(\frac{V_t}{V_{t-1}}\right) = \ln\left(\frac{V_1}{V_0} \cdot \frac{V_2}{V_1} \dots \frac{V_T}{V_{T-1}}\right) = \ln\left(\frac{V_T}{V_0}\right)$$

Si tu base de datos de shocks está en rendimientos logarítmicos, la suma es válida. Pero si estás aplicando shocks en porcentajes directos (como es estándar en las mesas de riesgo al reportar a la alta dirección), el uso de la productoria $\prod (1 + r_t) - 1$ es indispensable para no distorsionar el tamaño real de la quiebra.

**Cuándo el stress histórico puede engañar**

Si el portafolio actual tiene una composición muy distinta a la que tenía durante el episodio histórico, el resultado puede ser poco informativo. Por ejemplo, aplicar los rendimientos de 2008 a un portafolio que no incluye ningún banco es razonable, pero si los bancos eran el 60% del portafolio en 2008 y hoy son el 25%, el stress histórico subestimará el impacto que habría tenido en aquella época.

Para mitigar esto, es mejor calcular el stress como el promedio de los rendimientos individuales de los activos durante el período, ponderado por los pesos actuales, en lugar de calcular el rendimiento histórico del portafolio como un todo.

## Tabla Comparativa de Enfoques de Stress Testing

| Dimensión | Stress Histórico | Stress Hipotético | Stress Inverso |
| :--- | :--- | :--- | :--- |
| **Punto de Partida** | Un evento del pasado (ej. Crisis Subprime 2008). | Una narrativa económica (ej. Choque geopolítico). | Una pérdida catastrófica fija (ej. $L^* = -15\%$). |
| **Operador Matemático** | Vector empírico observacional $\mathbf{X}_{\tau}$. | Expansión de Taylor / Esperanza Condicional $\mathbb{E}[\mathbf{\Delta X}_2 \mid \Delta X_1]$. | Optimización restringida (Distancia de Mahalanobis: $\mathbf{\Delta X}^T \mathbf{\Sigma}^{-1} \mathbf{\Delta X}$). |

----------

### BLOQUE 4: La mecánica del stress hipotético

**Los shocks como punto de partida**


Cuando un analista diseña un escenario macroeconómico, usualmente visualiza variables agregadas (el PIB, la tasa de referencia, el índice accionario general). Sin embargo, el portafolio real está compuesto por activos individuales (la acción $i$, el bono $j$). Este bloque formaliza los tres métodos matemáticos para trasladar el choque de la variable macro al activo específico.

#### 1. Método 1: Betas respecto a Factores (El Enfoque de Proyección Lineal)

Este enfoque se fundamenta en los modelos de factores lineales, siendo el más clásico el **CAPM** (_Capital Asset Pricing Model_). Si el escenario hipotético define un choque sobre un índice de mercado (ej. $S_{m}$), el rendimiento esperado de un activo individual $i$ se modela mediante una regresión lineal simple.

##### Formalización Matemática

El rendimiento del activo $i$ en el momento $t$ está dado por:

$$r_{i,t} = \alpha_i + \beta_i r_{m,t} + \epsilon_{i,t}$$

Donde:

-   $\beta_i = \frac{\text{Cov}(r_i, r_m)}{\text{Var}(r_m)}$ representa la sensibilidad sistemática del activo.

-   $\epsilon_{i,t}$ es el riesgo idiosincrático (específico de la empresa), donde se asume estadísticamente que $\mathbb{E}[\epsilon_{i,t}] = 0$.


Al aplicar el operador de esperanza condicional bajo el escenario de estrés donde el mercado sufre un choque fijo ($r_{m,t} = \Delta X_m$), y asumiendo que en una crisis el término constante $\alpha_i$ es despreciable frente al tamaño del choque, el **shock proyectado para el activo** ($\text{shock}_i$) es:

$$\mathbf{\text{shock}_i = \beta_i \cdot \text{shock}_{mercado}}$$

##### Limitación Cuantitativa

Este método asume la **homogeneidad del riesgo sistemático**. Al depender de una sola $\beta$, fuerza a que todas las acciones con la misma beta reaccionen igual, ignorando que un choque de $-20\%$ en el mercado puede afectar de forma destructiva a las empresas tecnológicas mientras que las de consumo básico resisten mejor (efectos sectoriales).

#### 2. Método 2: Análisis Sectorial y Estructura Financiera (Modelación Fundamental)

Cuando la narrativa económica tiene canales de transmisión específicos (como la política monetaria o shocks de oferta), el riesgo se mapea analizando el balance de la empresa. Aquí la matemática se traslada a las **razones financieras y ecuaciones de equilibrio contable**.

##### Caso A: Sensibilidad a Tasas mediante Apalancamiento (_Leverage_)

Si el escenario hipotético implica un incremento en la tasa de interés de referencia ($\Delta I$), el impacto en el rendimiento de la empresa $i$ puede modelarse en función de su estructura de capital:

$$\text{shock}_i \propto -\left( \frac{\text{Deuda a Tasa Variable}_i}{\text{Capital Contable}_i} \right) \cdot \Delta I$$

Las empresas con una alta razón de apalancamiento financiero experimentarán una contracción severa en sus márgenes netos, reduciendo su valuación de manera no lineal respecto a empresas desapalancadas.

##### Caso B: Sensibilidad Cambiaria mediante Flujos de Caja Relativos

Para un choque en el tipo de cambio ($\Delta FX$, expresado como depreciación de la moneda local), el impacto neto depende del perfil comercial de la firma:

$$\text{shock}_i \propto \left( \frac{\text{Ingresos por Exportación}_i - \text{Costos e Insumos Importados}_i}{\text{Ventas Totales}_i} \right) \cdot \Delta FX$$

-   Si la razón es **positiva** (exportadora neta), el shock sobre el activo es positivo.

-   Si es **negativa** (importadora o deudora en moneda extranjera), la depreciación actúa como un choque negativo severo.


#### 3. Método 3: Correlaciones Históricas (El Enfoque Multivariado Condicional)

Para escenarios complejos donde el factor estresado no es el mercado general, sino un _commodity_ específico o un indicador macro (ej. el precio del cobre o el _spread_ de crédito corporativo), recurrimos a la **Teoría de Distribuciones Condicionales** (regresión múltiple o mínimos cuadrados ordinarios).

##### Formalización Matemática

Supongamos que el portafolio contiene un activo $i$ y queremos evaluar el impacto de un choque en un factor de riesgo específico $F_k$. A partir de las series de tiempo históricas, estimamos los parámetros de una regresión lineal múltiple donde incluimos los factores relevantes:

$$r_{i,t} = \gamma_0 + \gamma_{1} F_{1,t} + \dots + \gamma_{k} F_{k,t} + \nu_{i,t}$$

El coeficiente $\gamma_k$ mide el impacto marginal del factor $k$ sobre el activo, manteniendo todo lo demás constante:

$$\gamma_k = \frac{\partial \mathbb{E}[r_i \mid \mathbf{F}]}{\partial F_k}$$

Si la narrativa estresa directamente al factor $k$ con una magnitud $\Delta F_k$, el shock resultante para el activo se calcula como:

$$\mathbf{\text{shock}_i = \gamma_k \cdot \Delta F_k}$$

##### Ventaja y Exigencia Cuantitativa

-   **Precisión:** A diferencia del Método 1 (que asume que todo pasa por el mercado general), este método captura la co-integración histórica real entre el activo y la variable específica.

-   **Restricción de Datos:** Matemáticamente requiere que tanto el activo como el factor de riesgo posean una serie temporal histórica común, con suficiente liquidez y longitud para garantizar que el estimador $\gamma_k$ sea estadísticamente significativo (es decir, con un error estándar mínimo y bajo p-value).

**La consistencia interna del escenario**

Un error común es diseñar escenarios donde los shocks a distintos activos son internamente inconsistentes. Por ejemplo, en un escenario de "depreciación del peso", los bancos no pueden subir simultáneamente con que cae la actividad económica, a menos que el escenario sea explícito sobre el canal por el que opera. Dedicar tiempo a la narrativa antes de asignar los números reduce este problema.


| **Tratamiento de Correlación** | Implícito y real de la crisis seleccionada. | Asumido constante mediante la matriz $\mathbf{\Sigma}$. | Estresa los factores usando la covarianza con el portafolio ($\mathbf{\Sigma}\mathbf{S}$). |
| **Objetivo Principal** | Recordar vulnerabilidades pasadas ante shocks reales. | Explorar horizontes macroeconómicos fuera de la muestra. | Encontrar el "escenario de quiebra" o talón de Aquiles del portafolio. |

---

## Mecánica del Mapping en Stress Hipotético

| Método | Entrada Matemática / Parámetro | Canal de Transmisión | Ventaja Cuantitativa | Limitación Cuantitativa |
| :--- | :--- | :--- | :--- | :--- |
| **Betas respecto a Factores** | $\text{shock}_i = \beta_i \cdot \text{shock}_{m}$ <br> Donde $\beta_i = \frac{\text{Cov}(r_i, r_m)}{\text{Var}(r_m)}$ | Mercado Sistémico (Índice general) | Cálculo inmediato y matricialmente escalable para portafolios masivos. | Ignora la dispersión sectorial y el riesgo idiosincrásico ($\epsilon_i$). |
| **Análisis Sectorial / Fundamental** | Razones de Balance <br> (ej. $\frac{\text{Deuda}}{\text{Capital}}$, $\frac{\text{Exp}}{\text{Imp}}$) | Canales Microeconómicos y Estructura Contable | Refleja la verdadera vulnerabilidad operativa y financiera de la firma. | Difícil de automatizar a gran escala; requiere análisis cualitativo por emisor. |
| **Correlaciones Históricas** | Coeficientes de Regresión Múltiple <br> $\text{shock}_i = \gamma_k \cdot \Delta F_k$ | Series de Tiempo Históricas Co-integradas | Alta especificidad para factores temáticos (ej. *commodities* específicos). | Sufre ante cambios de régimen (inestabilidad de los parámetros en el tiempo). |

----------

### BLOQUE 5: La matriz de sensibilidad

Este es el artefacto más importante de todo el proceso: el **Tablero de Control del Riesgo** o _Risk Dashboard_.

Matemáticamente, lo que estamos viendo aquí es la representación matricial de una **forma lineal multivariada**. Vamos a estructurar y enriquecer este bloque con el rigor que amerita para tus notas.

#### 1. Formalización Matemática de la Matriz de Impacto

Llamemos a tu matriz la **Matriz de Impacto Estresado ($\mathbf{\Delta V}$)**. Esta matriz es el producto de mapear un conjunto de $M$ escenarios sobre un portafolio de $N$ activos individuales.

Si definimos:

-   $\mathbf{E}$ como la matriz de shocks por escenario de dimensión $M \times K$ (donde $K$ es el número de factores de riesgo subyacentes).

-   $\mathbf{S}$ como la matriz de sensibilidades del portafolio de dimensión $K \times N$ (las deltas de cada activo $j$ respecto al factor $i$).


La matriz final de pérdidas y ganancias (P&L) por activo y escenario, expresada en unidades monetarias (pesos MXN), se puede aproximar mediante el producto matricial:

$$\mathbf{\Delta V}_{M \times N} = \mathbf{E}_{M \times K} \times \mathbf{S}_{K \times N}$$

Cada elemento $\Delta v_{s, j}$ de la matriz representa cuantitativamente:

$$\Delta v_{s, j} = \text{Impacto financiero en el activo } j \text{ bajo el escenario } s$$

La última columna (**TOTAL**) no es más que el operador de agregación lineal (la suma por filas), que representa el impacto neto en el portafolio completo para el escenario $s$:

$$\Delta V_{s, \text{TOTAL}} = \sum_{j=1}^{N} \Delta v_{s, j}$$

#### 2. Lectura Analítica y Canales de Transmisión (Microeconomía del Portafolio)

El valor didáctico de esta matriz es que permite realizar un **diagnóstico cruzado** (por filas y por columnas):

##### Análisis por Escenario (Filas)

Permite identificar cuál es la mayor amenaza sistémica para la firma. En tu ejemplo, el escenario de **"Crash -25%"** es la pérdida máxima absoluta ($-\$195,250$ MXN), lo que indica que el portafolio actual tiene una dirección beta marcadamente alcista (_long equity bias_).

##### Análisis por Activo (Columnas)

Permite entender el comportamiento de cobertura (_hedging_) o vulnerabilidad de cada emisora:

-   **CEMEX y WALMEX ante Depreciación del MXN (Dólar Caro):** Matemáticamente, su sensibilidad cambiaria ($\frac{\partial f}{\partial FX}$) es positiva. Para **CEMEX**, sus operaciones internacionales en mercados como EE.UU. e Europa generan flujos de caja en dólares; al traducirlos a pesos MXN (moneda de reporte), el valor contable de la posición aumenta ($+\$20,000$ MXN).

-   **GFNORTE ante Alza de Tasas:**

    Presenta un impacto positivo ($+\$12,500$ MXN). Esto modela la estructura de balance de una institución financiera: cuando las tasas suben, el banco puede ajustar al alza la tasa activa (lo que cobra por créditos nuevos y vigentes a tasa variable) de forma más rápida que la tasa pasiva (lo que paga a los ahorradores), expandiendo su Margen Financiero Neto. Sin embargo, sufre severamente en el escenario de **Recesión** ($-\$45,000$ MXN) debido a que el modelo incorpora el incremento matemático en la Probabilidad de Incumplimiento (PI) y el consecuente aumento en las Reservas Crediticias.

#### La matriz de sensibilidad

La matriz de sensibilidad es la forma compacta de comunicar los resultados del *stress testing*. Cada celda muestra el impacto en pesos (MXN) de un escenario específico sobre una posición determinada, facilitando la toma de decisiones ejecutivas.

| Escenario / Estrés | WALMEX | GFNORTE | CEMEX | FEMSA | **TOTAL PORTAFOLIO** |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Crash −25%** | $-\$60,000$ | $-\$52,500$ | $-\$39,000$ | $-\$43,750$ | **$-\$195,250$** |
| **Dep. MXN** | $+\$15,000$ | $-\$37,500$ | $+\$20,000$ | $-\$20,000$ | **$-\$22,500$** |
| **Alza tasas** | $-\$24,000$ | $+\$12,500$ | $-\$60,000$ | $-\$25,000$ | **$-\$96,500$** |
| **Recesión** | $-\$36,000$ | $-\$45,000$ | $-\$50,000$ | $-\$25,000$ | **$-\$156,000$** |

#### Cómo leer e interpretar la matriz:

* **Efecto de Agregación Lineal:** La columna **TOTAL** representa el riesgo neto por escenario ($\Delta V_s = \sum_{j} \Delta v_{s,j}$). Permite dimensionar si el portafolio cuenta con coberturas naturales entre industrias.
* **Asimetría Cambiaria (Dep. MXN):** Las celdas positivas ($+$) actúan como coberturas. **CEMEX** aparece con ganancias porque sus ingresos globales dolarizados se revalúan al traducirse a pesos MXN. En contraste, **GFNORTE** muestra pérdidas debido a que la depreciación suele venir acompañada de choques macroeconómicos que elevan la morosidad de la cartera local.
* **Sensibilidad Financiera (Alza tasas):** **GFNORTE** es el único beneficiado neto debido a la expansión de su margen financiero (tasas activas vs. pasivas), mientras que **CEMEX** sufre el impacto negativo más alto ($-\$60,000$) reflejando el encarecimiento del costo de refinanciamiento de su deuda corporativa.

----------

### BLOQUE 6: Stress test inverso

Cerremos estructurando y formalizando matemáticamente este procedimiento del **Stress Inverso de Factor Único** (o _Single-Factor Reverse Stress Testing_).

Este enfoque lineal es sumamente potente porque condensa la complejidad matemática de un portafolio multivariable en una sola métrica intuitiva y directa para la toma de decisiones.

#### 1. Formalización del Modelo Lineal de Factor Único

Cuando reducimos el portafolio a un solo factor de riesgo generalizado (en este caso, el mercado local medido a través del Índice de Precios y Cotizaciones, IPC), estamos asumiendo que el riesgo del portafolio está dominado por su **Beta Sistemática Agregada ($\beta_p$)**.

##### Paso 1: Agregación Lineal de la Beta del Portafolio

La beta del portafolio es la media ponderada de las betas individuales de cada activo que lo compone:

$$\beta_p = \sum_{i=1}^{N} w_i \cdot \beta_i$$

Donde:

-   $w_i$ es el peso o participación del activo $i$ en el portafolio ($\sum w_i = 1$).

-   $\beta_i$ es la sensibilidad histórica de la emisora $i$ respecto al IPC.


##### Paso 2: La Condición de Inversión (El Despeje)

Establecemos la aproximación lineal del rendimiento del portafolio ($R_p$) ante un choque del mercado ($\Delta M$):

$$R_p \approx \beta_p \cdot \Delta M$$

Si fijamos el rendimiento objetivo en un umbral de pérdida catastrófica conocido ($R_p = L^*$, donde por ejemplo $L^* = -15\%$), resolvemos el problema inverso despejando el **choque de mercado implícito ($\Delta M^*$)**:

$$\mathbf{\Delta M^* = \frac{L^*}{\beta_p}}$$

Este valor $\Delta M^*$ nos da la magnitud exacta del movimiento del mercado requerido para detonar la pérdida del $15\%$.

#### 2. Validación de Plausibilidad mediante la Medida de Frecuencia Empírica

Encontrar el número $\Delta M^*$ es solo la mitad del trabajo. La verdadera potencia del stress inverso radica en la **evaluación de plausibilidad** utilizando la distribución empírica histórica.

Para responder _"¿cuántas veces ha ocurrido un shock de esa magnitud?"_, definimos matemáticamente una función indicadora $I_t$ sobre la serie de tiempo histórica de rendimientos diarios del mercado ($r_{m,t}$) para una ventana de observaciones de longitud $T$ (por ejemplo, los últimos 20 años, donde $T \approx 5000$ días hábiles):

$$I_t(\Delta M^*) = \begin{cases} 1 & \text{si } r_{m,t} \le \Delta M^* \\ 0 & \text{si } r_{m,t} > \Delta M^* \end{cases}$$

El número de eventos observados ($N$) en la historia es simplemente la suma de estos disparos:

$$N = \sum_{t=1}^{T} I_t(\Delta M^*)$$

A partir de aquí, el analista cuantitativo clasifica el escenario según su probabilidad empírica:

-   Si $N \ge 1$: El escenario es **Extremo pero Plausible**. Ya ocurrió en el pasado (v.g., la crisis de 2008 o la pandemia de 2020), por lo que el portafolio está expuesto a un riesgo real y cuantificable.

-   Si $N = 0$: El escenario entra en el terreno de los **Cisnes Negros** (_Black Swans_). Supera los registros históricos y requiere modelos de Teoría de Valores Extremos (EVT) para estimar su probabilidad matemática de ocurrencia.

Explicado de manera más breve...

El *stress test* inverso simplifica la comunicación del riesgo al cambiar la pregunta tradicional. En lugar de proyectar pérdidas a partir de un escenario arbitrario, encuentra el umbral exacto del mercado que llevaría al portafolio a una situación límite (escenario de quiebra).

#### Algoritmo Matemático de Factor Único

1. **Definir la Pérdida Objetivo ($L^*$):**
   Se establece el límite de tolerancia institucional.
   $$L^* = -15\%$$

2. **Calcular la Beta Agregada del Portafolio ($\beta_p$):**
   Alineación lineal del riesgo sistemático mediante la ponderación de activos:
   $$\beta_p = \sum_{i=1}^{N} w_i \cdot \beta_i$$

3. **Despejar el Shock Implícito del Mercado ($\Delta M^*$):**
   Utilizando la aproximación lineal $R_p \approx \beta_p \cdot \Delta M$, resolvemos para el factor de mercado:
   $$\Delta M^* = \frac{L^*}{\beta_p}$$

4. **Evaluación de Plausibilidad (Frecuencia Histórica):**
   Se calcula el número de veces ($N$) que el rendimiento diario del mercado ($r_{m,t}$) ha sido igual o más severo que el shock implícito en una ventana histórica de tamaño $T$:
   $$N = \sum_{t=1}^{T} \mathbb{I}(r_{m,t} \le \Delta M^*)$$

---

#### Protocolo de Comunicación Ejecutiva

El resultado final de este análisis permite estructurar un argumento directo y libre de tecnicismos para comités de riesgos o la alta dirección:

> **"Para perder el $15\%$ del portafolio en un solo día, necesitaríamos una caída del IPC de X%, un evento extremo pero plausible que históricamente ha ocurrido N veces en los últimos 20 años (asociado a episodios como el *Error de Diciembre* o el *Lunes Negro*)."**
----------

## FÓRMULAS DE REFERENCIA RÁPIDA

# Formulario Técnico de Stress Testing y Gestión de Riesgos

Las expresiones matemáticas fundamentales para la medición de impactos, métricas de trayectoria (*Drawdown*), y metodologías de ajuste de volatilidad en la gestión de portafolios son la siguientes:

### 1. Rendimiento Acumulado del Portafolio (Composición Geométrica)
Para horizontes temporales multiperiodo ($T > 1$), se debe utilizar la capitalización compuesta para evitar el sesgo de sobreestimación por agregación lineal.

$$R_{\text{acum}} = \prod_{t=1}^{T} (1 + r_t) - 1$$

* **$r_t$**: Rendimiento lineal o porcentual del portafolio en el día $t$.
* **$T$**: Longitud o ventana temporal del episodio de estrés.


### 2. Máxima Pérdida de Trayectoria (*Drawdown*) en el Tiempo $t$
Mide la caída porcentual acumulada desde el punto más alto alcanzado por el valor del portafolio hasta un momento específico $t$.

$$DD_t = \frac{V_t - \max_{s \le t}(V_s)}{\max_{s \le t}(V_s)}$$

* **$V_t$**: Valor actual del portafolio en el tiempo $t$.
* **$\max_{s \le t}(V_s)$**: Máximo valor histórico alcanzado por el portafolio previo o igual al momento $t$ (Pico o *Peak*).

### 3. Impacto de un Escenario Hipotético (Mapeo Lineal)
Aproximación de primer orden para calcular el rendimiento total del portafolio a partir del vector de pesos y los shocks individuales asignados a cada activo o sector.

$$R_{\text{escenario}} = \sum_{i=1}^{N} w_i \cdot \text{shock}_i$$

* **$w_i$**: Peso o ponderación del activo $i$ en el portafolio actual ($\sum w_i = 1$).
* **$\text{shock}_i$**: Rendimiento o alteración esperada para el activo $i$ según la narrativa económica del escenario.

### 4. Shock Implícito del Mercado (Stress Inverso de Factor Único)
Procedimiento analítico para hallar la raíz (preimagen) del escenario de quiebra, despejando la magnitud necesaria del movimiento del mercado para detonar una pérdida objetivo fija.

$$\Delta M^* = \frac{L^*}{\beta_p}$$

* **$\Delta M^*$**: Shock implícito del mercado (ej. caída necesaria del IPC).
* **$L^*$**: Rendimiento objetivo o pérdida catastrófica predefinida (ej. $-15\%$).
* **$\beta_p$**: Beta sistemática agregada del portafolio ($\sum w_i \beta_i$).

### 5. Stress Histórico Escalado por Volatilidad (Filtro GARCH / Hull-White)
Metodología para actualizar los shocks del pasado al régimen de mercado presente. Permite ajustar un choque histórico para que refleje si la volatilidad actual es mayor o menor a la del promedio del episodio de crisis.

$$\text{shock}_{\text{escalado}} = \text{shock}_{\text{histórico}} \cdot \left( \frac{\sigma_{t, \text{actual}}}{\sigma_{t, \text{media}}} \right)$$

* **$\text{shock}_{\text{histórico}}$**: Rendimiento observado en el día $\tau$ de la crisis pasada.
* **$\sigma_{t, \text{actual}}$**: Volatilidad condicional estimada para el día de hoy mediante un modelo GARCH(1,1).
* **$\sigma_{t, \text{media}}$**: Volatilidad condicional promedio registrada durante el periodo histórico de la crisis.

## EJERCICIOS Y TAREA

**Obligatorios:** 1–4
**Avanzados:** 5–7

**Énfasis:**

-   Ejercicio 2 (diseñar escenario propio) es el más importante para desarrollar criterio analítico: obliga a pensar en los canales económicos, no solo en los números
-   Ejercicio 4 (concentración del riesgo) conecta directamente con la decisión de gestión: identificar qué posición domina el riesgo en cada escenario es el primer paso para decidir si cubrir o rebalancear
-   Ejercicio 7 (escenario macro narrativo) es el ejercicio que más se parece al trabajo real en una mesa de riesgo o en un comité de inversión

----------

## SOLUCIONES A EJERCICIOS SELECCIONADOS

### Ejercicio 2: Escenario "Guerra Comercial México-EUA"

La clave no son los números finales sino la lógica detrás de cada shock. Una respuesta bien argumentada incluye los canales de transmisión:

```
WALMEX: −20%
  Canal: aranceles encarecen importaciones (cadena de suministro)
         y la contracción económica reduce el consumo discrecional

GFNORTE: −10%
  Canal: caída de la actividad económica deteriora la calidad de cartera
         pero el banco tiene poca exposición directa al comercio exterior

CEMEXCPO: −18%
  Canal: proyectos de infraestructura binacional paralizados;
         exportaciones de cemento al mercado americano reducidas

FEMSAUBD: −8%
  Canal: consumo de bebidas básicas es más resistente a la recesión;
         costos de insumos importados suben pero se pueden trasladar

```

El resultado numérico depende de los datos descargados, pero el ratio respecto al VaR 99% debería estar entre 1.5× y 3×: el escenario de guerra comercial es más severo que el peor día típico pero no es un evento de cisne negro.

### Ejercicio 4: Concentración del riesgo

El patrón esperado es que CEMEX domina la contribución en escenarios de alza de tasas y recesión (alta deuda, ciclicidad), mientras que GFNorte domina en escenarios cambiarios (cartera en pesos, sin cobertura). WALMEX y FEMSA aparecen como contribuyentes más estables en la mayoría de los escenarios.

Esta información tiene implicación directa para la gestión: si el escenario de mayor preocupación es el alza de tasas, reducir la posición en CEMEX o comprar opciones sobre esa acción es la cobertura más eficiente.

----------

## PROBLEMAS COMUNES Y SOLUCIONES

### Problema 1: `prod(1 + r_vec)` devuelve valores extraños

**Causa:** El vector contiene NAs o el período de fechas no tiene datos
**Solución:** Verificar con `sum(is.na(r_vec))` antes de calcular. Filtrar con `na.omit()`

### Problema 2: El drawdown siempre es 0%

**Causa:** El portafolio solo tiene rendimientos positivos en el sub-período analizado
**Explicación:** No es un error, es el resultado correcto. Ampliar el período hasta incluir al menos una racha de pérdidas

### Problema 3: Los shocks hipotéticos producen un impacto positivo total

**Causa:** Algunos activos tienen shocks positivos que compensan los negativos
**Acción:** Verificar que la narrativa sea consistente. Puede ser correcto (ej. depreciación beneficia a exportadores) o puede indicar un error en los signos

### Problema 4: El stress escalado por GARCH da un factor muy alto (> 3)

**Causa:** La volatilidad actual está en un período de estrés extremo
**Acción:** No es un error. Documentar que el escalamiento refleja el estado actual del mercado y presentarlo como el escenario más conservador

### Problema 5: El stress inverso da un shock mayor al 50%

**Causa:** El beta del portafolio es bajo (portafolio defensivo) o la pérdida objetivo es muy alta
**Interpretación:** Significa que el portafolio necesita un evento extraordinario para alcanzar esa pérdida — es una buena señal sobre la resiliencia del portafolio ante shocks de mercado normales

----------

## PUNTOS PEDAGÓGICOS CRÍTICOS

### 1. El stress no tiene probabilidad — y eso es una característica, no un defecto

El VaR responde "con qué probabilidad". El stress responde "qué pasa si". Algunos estudiantes intentan asignar probabilidades a los escenarios de stress; no es el objetivo. Lo que importa es que el escenario sea plausible y que la institución pueda sobrevivir si ocurre.

### 2. La narrativa viene antes que los números

Un escenario bien diseñado empieza con una historia económica coherente (quién genera el shock, por qué canales se transmite, qué sectores se benefician y cuáles se perjudican) y luego se cuantifica. Un escenario que empieza con "el mercado cae 20%" sin explicar por qué es más difícil de defender ante un directivo o regulador.

### 3. El drawdown es la métrica más intuitiva para inversores no técnicos

A diferencia del VaR, el drawdown no requiere ninguna explicación estadística. "En la peor crisis de los últimos 15 años, el portafolio cayó X% desde su máximo y tardó Y meses en recuperarse" es comprensible para cualquier persona. Es el puente entre el análisis técnico y la comunicación con clientes.

### 4. Stress testing no es sinónimo de "peor caso"

Un escenario de stress bien diseñado es severo pero plausible. Los escenarios imposibles (caída del 100% del IPC, colapso simultáneo de todos los activos al máximo histórico) no tienen utilidad práctica porque no generan decisiones de gestión. La pregunta relevante es: "¿en un escenario malo pero creíble, podemos seguir operando?"

----------

## EVALUACIÓN DE LA SESIÓN

### Pregunta de salida:

"Un portafolio tiene VaR(99%) = −4% y el stress test del escenario COVID produce −28%. ¿Qué dice esta diferencia sobre la naturaleza del riesgo de este portafolio? ¿Cuál de las dos métricas usarías para dimensionar el capital de reserva y cuál para fijar límites operativos diarios?"

----------

## PREPARACIÓN PARA SESIÓN 11

**Tema:** Derivados Financieros y Monte Carlo

**Conexión:**
"En esta sesión identificamos los escenarios que más dañan al portafolio. La Sesión 11 introduce los instrumentos para cubrirse contra ellos: opciones, futuros y swaps. Un contrato de futuros sobre el IPC o una opción de venta sobre CEMEX son formas directas de limitar las pérdidas en los escenarios de stress que hemos diseñado."

**Anticipar:**
Monte Carlo, que ya usamos en las Sesiones 7–8 para simular rendimientos, reaparece en la Sesión 11 como herramienta para valuar derivados con payoffs no lineales. La volatilidad σ_t de GARCH entra directamente en el precio de las opciones (fórmula de Black-Scholes usa σ).

**Materiales:**

-   Los escenarios de stress del Ejercicio 7 de esta sesión serán el punto de partida para diseñar estrategias de cobertura en la Sesión 11
-   Revisar el concepto de beta del portafolio: las coberturas con futuros sobre el IPC usan ese beta para determinar el número de contratos necesarios

## Apéndice

### Stress Test Histórico (_Historical Simulation_ aplicado a escenarios de estrés

#### 1. El Marco Conceptual y el Mapeo de Factores

El principio fundamental del estrés histórico es la **invarianza de los shocks observados**. No nos importa cómo estaba compuesto el portafolio en el pasado; lo que importamos del pasado es el vector de alteraciones en las variables de mercado (factores de riesgo) y lo aplicamos sobre la arquitectura actual del portafolio.

Supongamos que el portafolio actual en el tiempo $t = 0$ depende de un vector de $N$ factores de riesgo $\mathbf{X}_0 = [X_{1,0}, X_{2,0}, \dots, X_{N,0}]^T$ (que pueden ser precios de acciones, tasas de interés, tipos de cambio, etc.).

El valor actual del portafolio se define mediante una función de valuación $f$:

$$V_0 = f(\mathbf{w}_0, \mathbf{X}_0)$$

Donde $\mathbf{w}_0$ representa el vector de posiciones o pesos actuales del portafolio.

#### 2. Formalización Matemática del Stress Histórico

Para ejecutar el test, seleccionamos una ventana temporal histórica de crisis de longitud $T$ (por ejemplo, la crisis _Subprime_ de 2008, la crisis del Dot-com en 2000, o el _Flash Crash_ de 2020). Sea esta ventana el conjunto de momentos del tiempo $\tau \in \{1, 2, \dots, T\}$.

##### Paso 1: Extracción de Shocks Históricos (El Operador de Perturbación)

Dependiendo de la naturaleza del factor de riesgo, los shocks se extraen de manera **absoluta** o **relativa**.

-   **Shocks Relativos (Rendimientos Logarítmicos o Geométricos):** Típicos para renta variable y tipos de cambio, donde se asume que la volatilidad escala con el nivel del precio.

    $$r_{i,\tau} = \ln\left(\frac{X_{i,\tau}}{X_{i,\tau-1}}\right) \quad \text{o} \quad \Delta \% X_{i,\tau} = \frac{X_{i,\tau} - X_{i,\tau-1}}{X_{i,\tau-1}}$$

-   **Shocks Absolutos (Diferencias Lineales):** Típicos para tasas de interés (puntos base) o _spreads_ de crédito, donde rendimientos porcentuales podrían generar tasas negativas artificiales o distorsiones.

    $$\Delta X_{i,\tau} = X_{i,\tau} - X_{i,\tau-1}$$


##### Paso 2: Construcción de Escenarios Sintéticos Actuales

Aquí radica la ventaja didáctica del método: **generamos un vector de precios estresados virtuales ($\mathbf{X}^*_{\tau}$)** aplicando los shocks del pasado a los precios reales de hoy ($\mathbf{X}_0$).

Si aplicamos shocks relativos (geométricos), el factor de riesgo estresado para el escenario $\tau$ será:

$$X^*_{i,\tau} = X_{i,0} \cdot (1 + \Delta \% X_{i,\tau}) \quad \text{o} \quad X^*_{i,\tau} = X_{i,0} \cdot e^{r_{i,\tau}}$$

Si aplicamos shocks absolutos:

$$X^*_{i,\tau} = X_{i,0} + \Delta X_{i,\tau}$$

De esta forma, construimos una matriz de factores de riesgo estresados $\mathbf{X}^*$ de dimensión $T \times N$.

##### Paso 3: Revaluación del Portafolio y Vector de Pérdidas

Para cada escenario histórico $\tau$, calculamos el valor hipotético que tendría el portafolio actual utilizando la función de valuación $f$:

$$V^*_{\tau} = f(\mathbf{w}_0, \mathbf{X}^*_{\tau})$$

La **Pérdida o Ganancia Estresada ($\Delta V_{\tau}$)** para cada día de la crisis se define como:

$$\Delta V_{\tau} = V^*_{\tau} - V_0$$

El resultado final de este análisis es un vector de diferencias de valor $\mathbf{\Delta V} = [\Delta V_1, \Delta V_2, \dots, \Delta V_T]^T$.

#### 3. Métricas de Riesgo Derivadas

Una vez que tienes el vector $\mathbf{\Delta V}$, el análisis de riesgo cuantifica el impacto mediante dos métricas principales:

1.  **Peor Escenario (Worst-Case Scenario):**

    $$Loss_{max} = \min_{\tau \in \{1,\dots,T\}} (\Delta V_{\tau})$$

    Es la pérdida máxima absoluta que habría sufrido el portafolio actual si se repitiera el peor día de esa crisis específica.

2.  **VaR Histórico Estresado (Stressed VaR - sVaR):**

    Si la ventana de crisis $T$ es lo suficientemente amplia (por ejemplo, un año completo de crisis, $T \approx 250$ días hábiles), se puede calcular el percentil $\alpha$ (v.g., 99%) de la distribución empírica de $\mathbf{\Delta V}$:

    $$\text{sVaR}_{\alpha} = - P_{\alpha}(\mathbf{\Delta V})$$


#### 4. Balance Metodológico (Pros y Contras desde la Perspectiva Cuantitativa)

### Ventajas Matemáticas

-   **No-parametricidad Estricta:** No asumimos que los rendimientos siguen una distribución Normal, $t$-Student ni ninguna otra. La distribución empírica del pasado contiene intrínsecamente la curtosis (colas pesadas) y la asimetría (_skewness_) reales del mercado en pánico.

-   **Preservación de la Estructura de Dependencia:** Al aplicar los shocks de manera simultánea para el día $\tau$, se preserva la **matriz de covarianza no lineal** y las estructuras de dependencia complejas (cópulas empíricas) que ocurren en momentos de estrés (cuando las correlaciones tienden a 1).


#### Limitaciones Matemáticas

-   **Problema del Soporte Compacto (Sesgo de Supervivencia Histórica):** El soporte de la distribución empírica está acotado por los datos observados. Matemáticamente, el modelo asigna una probabilidad de cero a cualquier evento más severo que el máximo shock histórico registrado:

    $$P(X > \max(X_{\tau})) = 0$$

    Lo cual es conceptualmente erróneo para eventos de "Cisne Negro" (_Black Swans_).

-   **Régimen de Desalineación Temporal:** Si un activo financiero actual no existía durante la crisis analizada (por ejemplo, una criptomoneda o una acción tecnológica reciente en la crisis de 2008), el modelo sufre de falta de datos, obligando al analista a recurrir a _proxies_ (activos sustitutos), lo que introduce riesgo de modelo ($\epsilon$).

---

### Stress Test Hipotético ( _Scenario Analysis_ basado en sensibilidades)

A diferencia del enfoque histórico, aquí abandonamos la comodidad de los datos observados para adentrarnos en la modelación proactiva.

Desde la perspectiva de las matemáticas aplicadas al riesgo, este enfoque se fundamenta en el **Cálculo Diferencial (Aproximaciones de Taylor)** y en la **Teoría de Probabilidad Condicional** para resolver el problema de la consistencia.

#### 1. El Marco Conceptual: Narrativa y Mapeo Lineal / No Lineal

En el estrés hipotético, el analista define una narrativa macroeconómica (por ejemplo: _"Un choque geopolítico eleva los precios del crudo en un 40%, lo que deprecia las monedas emergentes un 15% e incrementa las tasas de interés de largo plazo en 150 puntos base"_).

Matemáticamente, esta narrativa se traduce en un vector de shocks hipotéticos diseñados a mano:

$$\mathbf{\Delta X}_{hip} = [\Delta X_{1}, \Delta X_{2}, \dots, \Delta X_{N}]^T$$

Para medir el impacto en el portafolio actual $V_0 = f(\mathbf{w}_0, \mathbf{X}_0)$, los analistas cuantitativos utilizan dos caminos matemáticos: la **revaluación total** (igual que en el histórico) o, más comúnmente en este enfoque, la **aproximación por sensibilidades (Expansión de Taylor)**.

#### 2. Formalización Matemática mediante Sensibilidades

Si la función de valuación del portafolio $f$ es diferenciable, podemos aproximar el cambio en el valor del portafolio ($\Delta V_{hip}$) mediante una serie de Taylor multivariable alrededor del estado actual $\mathbf{X}_0$.

##### Aproximación de Primer Orden (Lineal / Delta-Riesgo)

Para portafolios compuestos principalmente por activos lineales (acciones, divisas directas, _commodities_ físicos), basta con tomar la primera derivada parcial (el vector gradiente $\nabla f$):

$$\Delta V_{hip} \approx \sum_{i=1}^{N} \frac{\partial f}{\partial X_i} \Delta X_{i, hip} = \mathbf{S}^T \mathbf{\Delta X}_{hip}$$

Donde $\mathbf{S} = \left[ \frac{\partial f}{\partial X_1}, \dots, \frac{\partial f}{\partial X_N} \right]^T$ es el **vector de sensibilidades** del portafolio (las Deltas o las Duraciones, dependiendo de la clase de activo).

##### Aproximación de Segundo Orden (No Lineal / Delta-Gamma Riesgo)

Si el portafolio contiene instrumentos no lineales (opciones financieras, bonos con alta convexidad, productos estructurados), la aproximación lineal falla severamente. Debemos incorporar la matriz Hessiana $\mathbf{H}$ de segundas derivadas parciales:

$$\Delta V_{hip} \approx \sum_{i=1}^{N} \frac{\partial f}{\partial X_i} \Delta X_{i, hip} + \frac{1}{2} \sum_{i=1}^{N} \sum_{j=1}^{N} \frac{\partial^2 f}{\partial X_i \partial X_j} \Delta X_{i, hip} \Delta X_{j, hip}$$

En notación matricial compacta:

$$\Delta V_{hip} \approx \mathbf{S}^T \mathbf{\Delta X}_{hip} + \frac{1}{2} \mathbf{\Delta X}_{hip}^T \mathbf{H} \mathbf{\Delta X}_{hip}$$

Donde:

-   $\mathbf{S}$ representa el riesgo direccional (**Delta / Duración**).

-   $\mathbf{H}$ representa la curvatura y los efectos cruzados (**Gamma / Convexidad**).


#### 3. El Desafío Matemático: Inconsistencia y Correlaciones Condicionales

Como bien señalas, la gran limitación es la **subjetividad e inconsistencia de los shocks**. Si el analista define arbitrariamente que la tasa de interés sube y el tipo de cambio también, podría estar diseñando un escenario matemáticamente imposible o altamente improbable según la estructura económica actual.

Para resolver esto sin perder la "flexibilidad" de la narrativa, la matemática aplicada utiliza el **Enfoque de Stress Test Condicional** (basado en la distribución normal multivariable o modelos de cópulas).

##### El Algoritmo de Shocks Condicionales

Supongamos que el analista solo tiene la certeza de la narrativa sobre _un_ factor de riesgo principal (ej. el precio del petróleo, factor $1$), al que le asigna un shock severo $\Delta X_{1, hip} = z$. ¿Cómo determinamos matemáticamente los shocks consistentes para los otros $N-1$ factores restantes?

Si asumimos que los rendimientos de los factores siguen una distribución conjunta con matriz de covarianza $\mathbf{\Sigma}$, podemos particionar el vector de factores en el componente estresado ($1$) y los componentes remanentes ($2$):

$$\mathbf{\Delta X} = \begin{bmatrix} \Delta X_1 \\ \mathbf{\Delta X}_2 \end{bmatrix}, \quad \mathbf{\Sigma} = \begin{bmatrix} \sigma_{11} & \mathbf{\Sigma}_{12} \\ \mathbf{\Sigma}_{21} & \mathbf{\Sigma}_{22} \end{bmatrix}$$

Utilizando la **Esperanza Condicional Multivariable**, el vector de shocks óptimo y estadísticamente consistente para el resto del mercado será:

$$\mathbb{E}[\mathbf{\Delta X}_2 \mid \Delta X_1 = z] = \mathbf{\Sigma}_{21} \sigma_{11}^{-1} z$$

De esta manera, la matemática "rellena" los shocks del resto de los mercados (tipo de cambio, tasas, etc.) garantizando que la estructura de correlaciones históricas se respete de manera condicional al choque de tu narrativa.

#### 4. Balance Metodológico (Pros y Contras Cuantitativos)

### Ventajas Matemáticas

-   **Soporte Ilimitado (Exploración del Espacio de Estados):** No está acotado por el pasado. Matemáticamente, el analista puede evaluar el impacto en regiones del espacio de estados $\mathbb{R}^N$ que la historia jamás ha tocado (ej. tasas de interés negativas generalizadas antes de la década de 2010 o la crisis de la COVID-19 en su momento).

-   **Aislamiento Causal (Análisis de Sensibilidad Puro):** Permite hacer derivadas parciales analíticas. Puedes apagar todos los shocks y mover _únicamente_ el factor $i$ para entender el riesgo puro de esa variable en el portafolio.


### Limitaciones Matemáticas

-   **Riesgo de Linealización ($\epsilon$):** Si se usa el enfoque de Taylor en lugar de revaluación total, el error de aproximación $\epsilon = \mathcal{O}(\|\mathbf{\Delta X}\|^3)$ crece exponencialmente a medida que el shock hipotético es más severo, desvaneciendo la precisión del cálculo en las colas.

-   **Inestabilidad de la Matriz de Correlación:** Si usas el método condicional para corregir las inconsistencias, estás asumiendo que $\mathbf{\Sigma}$ (la estructura de correlación) se mantiene constante durante la crisis, cuando en la realidad las correlaciones son dinámicas y colapsan en momentos de pánico (_breakdown_ de correlación).

---

### Stress Inverso (_Reverse Stress Testing_)
Este cambia por completo el paradigma del análisis de riesgo. Desde una perspectiva de matemáticas aplicadas, pasamos de un problema directo (calcular una imagen a partir de un dominio) a un **problema inverso** (hallar la preimagen o raíces de una función).

En lugar de evaluar la función de valuación en un punto, buscamos el conjunto de puntos en el espacio de factores de riesgo que satisfacen una condición de pérdida crítica.

#### 1. El Marco Conceptual: El Problema de Inversión Matemático

Si definimos el umbral de pérdida catastrófica o "escenario de quiebra" como $L^*$ (por ejemplo, el $-15\%$ del valor inicial del portafolio, de modo que $\Delta V = -0.15 \cdot V_0$), el objetivo matemático del stress inverso es resolver la siguiente ecuación implícita para encontrar el vector de shocks $\mathbf{\Delta X}$:

$$\Delta V(\mathbf{\Delta X}) = L^*$$

El gran desafío matemático aquí es la **indeterminación (no unicidad)**. Como el portafolio depende de $N$ factores de riesgo, tenemos una sola ecuación con $N$ incógnitas. Existe un subespacio infinito de combinaciones de shocks que pueden generar exactamente esa pérdida del $15\%$. A este subespacio se le conoce en geometría estocástica como la **Superficie de Isopérdida** o _Contorno de Falla_.

#### 2. Formalización Matemática: Búsqueda del Escenario Más Probable (Plausibilidad)

Para resolver la indeterminación y encontrar _el_ escenario más crítico y realista de entre todos los infinitos posibles, el análisis cuantitativo transforma el problema inverso en un **problema de optimización con restricciones**.

Buscamos el vector de shocks $\mathbf{\Delta X}^*$ que minimice la distancia estadística al origen (es decir, el escenario que genere la pérdida $L^*$ pero que requiera los movimientos de mercado menos absurdos o "más probables").

##### El Enfoque de la Distancia de Mahalanobis

Si asumimos que los rendimientos de los factores de riesgo tienen una matriz de covarianza $\mathbf{\Sigma}$, la métrica de distancia estadística adecuada es la distancia de Mahalanobis. El problema se formula formalmente mediante multiplicadores de Lagrange:

$$\min_{\mathbf{\Delta X}} \quad \mathbf{\Delta X}^T \mathbf{\Sigma}^{-1} \mathbf{\Delta X}$$

$$\text{sujeto a:} \quad \mathbf{S}^T \mathbf{\Delta X} + \frac{1}{2} \mathbf{\Delta X}^T \mathbf{H} \mathbf{\Delta X} = L^*$$

Donde $\mathbf{S}$ y $\mathbf{H}$ son el vector de sensibilidades (Delta) y la matriz Hessiana (Gamma) del portafolio actual que vimos en el estrés hipotético.

##### Solución Analítica en el Caso Lineal (Delta-Riesgo)

Si el portafolio es puramente lineal ($\mathbf{H} = \mathbf{0}$), la restricción se vuelve lineal ($\mathbf{S}^T \mathbf{\Delta X} = L^*$). Aplicando el cálculo de optimización restringida, la solución analítica para el vector de estrés inverso óptimo es:

$$\mathbf{\Delta X}^* = L^* \cdot \frac{\mathbf{\Sigma} \mathbf{S}}{\mathbf{S}^T \mathbf{\Sigma} \mathbf{S}}$$

##### Interpretación Didáctica de la Solución:

Esta elegante fórmula matemática nos dice tres cosas fundamentales sobre el escenario de quiebra óptimo:

1.  $\mathbf{S}^T \mathbf{\Sigma} \mathbf{S}$ es la varianza total del portafolio ($\sigma^2_p$). La escala del shock es proporcional a la pérdida objetivo dividida por el riesgo del portafolio.

2.  $\mathbf{\Sigma} \mathbf{S}$ representa la covarianza de cada factor individual con el portafolio completo.

3.  **Resultado:** El modelo matemático estresa automáticamente con mayor severidad a aquellos factores de riesgo ante los cuales el portafolio es más sensible ($\mathbf{S}$) **y** que tienen mayor volatilidad o correlación ($\mathbf{\Sigma}$). Los factores irrelevantes reciben un shock cercano a cero.


#### 3. Algoritmia Numérica para Portafolios Complejos (No Lineales)

Cuando el portafolio tiene opciones o estructuras complejas, la aproximación lineal falla y no hay solución analítica. En la práctica analítica se utilizan dos métodos numéricos:

a.  **Método de Máxima Verosimilitud en Simulación de Monte Carlo:** Se corren $M$ escenarios estocásticos. Se filtran únicamente aquellos escenarios donde la pérdida fue de magnitudes cercanas a $L^*$. Luego, se calcula el vector promedio de esos escenarios filtrados. Matemáticamente es aproximar la esperanza condicional: $\mathbb{E}[\mathbf{\Delta X} \mid \Delta V \approx L^*]$.

b.  **Algoritmos de Optimización No Lineal (v.g., Newton-Raphson o Gradiente Conjugado):** Se resuelven numéricamente sobre la verdadera función de valuación $f(\mathbf{w}_0, \mathbf{X}_0 + \mathbf{\Delta X}) - V_0 = L^*$.


#### 4. Balance Metodológico (Pros y Contras Cuantitativos)

### Ventajas Matemáticas

-   **Identificación Automática de Vulnerabilidades:** Elimina el sesgo del analista. En lugar de adivinar qué mercado podría colapsar (estrés hipotético), la estructura matricial $\mathbf{\Sigma} \mathbf{S}$ "interroga" matemáticamente al portafolio y encuentra sus combinaciones exactas de talón de Aquiles.

-   **Coherencia de la Restricción presupuestaria de Riesgo:** Al incorporar $\mathbf{\Sigma}^{-1}$ en la función objetivo, se garantiza que los shocks resultantes respeten las correlaciones del mercado. El escenario de quiebra no será un evento aislado inconexo, sino una tormenta perfecta estadísticamente consistente.


### Limitaciones Matemáticas

-   **Dependencia Extrema del Modelo de Entrada:** Si la matriz de covarianza $\mathbf{\Sigma}$ o las sensibilidades $\mathbf{S}$ están mal estimadas (riesgo de calibración), el escenario de stress inverso resultante apuntará a una dirección completamente errónea, creando una falsa sensación de seguridad.

-   **Multiplicidad de Máximos Locales (No Convexidad):** En portafolios con opciones exóticas, la función de pérdida puede no ser convexa, presentando múltiples valles y crestas. Los algoritmos de optimización podrían quedar atrapados en un mínimo local, encontrando un "escenario de quiebra" que no es el más probable ni el más peligroso.
