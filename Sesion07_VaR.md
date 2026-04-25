# GUÍA - SESIÓN 7

## Valor en Riesgo (VaR): Histórico, Paramétrico y Simulación

**Curso:** Mercado de Capitales  
**Profesor:** Ismael Valverde

----------

## OBJETIVOS DE APRENDIZAJE

Al finalizar esta sesión, los estudiantes serán capaces de:

1.  Calcular e interpretar el VaR histórico de un portafolio de acciones mexicanas
2.  Derivar el VaR paramétrico usando la distribución normal y descomponerlo por activo
3.  Escalar el VaR a distintos horizontes temporales con la regla de la raíz cuadrada del tiempo
4.  Implementar una simulación Monte Carlo (normal, t-Student y multivariada con Cholesky)
5.  Comparar los tres métodos e identificar las hipótesis detrás de cada uno
6.  Reconocer las limitaciones del VaR y anticipar la necesidad del CVaR

----------

## CONTEXTO Y MOTIVACIÓN

### ¿Por qué estudiar el VaR?

**En la industria financiera mexicana:**

-   La CNBV exige a los bancos reportar el VaR de su libro de negociación diariamente
-   Las AFORES calculan VaR de sus carteras para cumplir límites de CONSAR (Circular 15-19)
-   Los fondos de inversión incluyen el VaR en sus prospectos conforme a regulación CNBV
-   GFNorte, BBVA México y Santander México publican su VaR en informes trimestrales

**El VaR responde una pregunta concreta:**

```
¿Cuánto puede perder mi portafolio en el peor X% de los días?

```

**Tres niveles estándar en la industria:**

-   90% → umbral interno de gestión (más permisivo)
-   95% → estándar de gestión de riesgos
-   99% → estándar regulatorio (Comité de Basilea)

----------

## CONEXIÓN CON SESIONES ANTERIORES

**Sesión 3 (Estadística descriptiva):**

-   Distribuciones, momentos, cuantiles: ahora tienen aplicación directa en el VaR
-   La curtosis que calculamos explica por qué el VaR paramétrico puede fallar

**Sesión 4 (Markowitz):**

-   La matriz Σ se reutiliza para el VaR paramétrico y la descomposición de Cholesky
-   El portafolio de mínima varianza es sobre el que calculamos el VaR

**Sesión 5 (CAPM / Beta):**

-   El beta de cada activo respecto al portafolio se reinterpreta como VaR componente marginal

**Sesión 6 (Bonos / Duration):**

-   Duration = VaR lineal de renta fija: el estudiante ya conoce la sensibilidad puntual

**Mensaje clave:** "Sesiones 1–6 construyeron las herramientas. Sesión 7 las usa para responder: ¿Cuánto puedo perder?"

----------

## ESTRUCTURA DE LA SESIÓN

### BLOQUE 1: VaR Histórico

**1.1 Pregunta detonadora**

Pregunta fundamental:
```
"Si invierten $500,000 pesos en acciones de la BMV,
 ¿cuánto pueden perder en un día malo?"

```
Exactamente esa pregunta es lo que el VaR responde de forma rigurosa.

**1.2 Concepto*

El VaR histórico es el método más intuitivo: usa la distribución empírica de los rendimientos pasados como aproximación de la distribución futura.

**Ejemplo con 10 rendimientos ordenados:**

```
Rendimientos ordenados (de menor a mayor):
-4.2%,  -3.1%,  -2.8%,  -1.9%,  -0.7%,
+0.3%,  +0.8%,  +1.4%,  +2.1%,  +3.5%

Con 10 observaciones y confianza 90%:
  alpha = 1 - 0.90 = 10%
  posición = floor(0.10 × 10) = 1
  VaR(90%) = -4.2%

Solo en el 10% de los días perderemos MÁS que 4.2%

```
El VaR es una respuesta a una pregunta muy específica de un inversionista: **"¿Cuál es mi pérdida máxima en un día normal?"**.

En términos técnicos:

El VaR es el umbral de pérdida que esperamos no superar en un horizonte de tiempo determinado, dado un nivel de confianza.

Con base en el ejemplo de arriba hacemos lo siguiente: 
##### A. La Ordenación (El Historial)

Primero, tomamos 10 días de rendimientos y los formamos en una fila, del peor al mejor.

-   **A la izquierda:** Los peores escenarios (donde perdimos dinero).
    
-   **A la derecha:** Los mejores escenarios (donde ganamos dinero).
    

##### B. El Nivel de Confianza ($1 - \alpha$)

Si elegimos un **90% de confianza**, le estamos diciendo al algoritmo: _"Ignora el 90% de los mejores resultados y enfócate solo en la frontera del 10% de los peores"_.

-   $\alpha = 0.10$ representa nuestra "zona de peligro".
    
-   Como tenemos 10 datos, el 10% más bajo es exactamente **1 dato**.
    
##### C. El Valor Crítico

Al buscar la posición 1, llegamos al $-4.2\%$. Este número es nuestra **frontera**.

#### La Interpretación Correcta (Lo que debe aprender)

Aquí es donde mucha gente se confunden. Es vital recalcar dos formas de leer ese $-4.2\%$:

1.  **Visión Optimista (Confianza):** "Estamos un **90% seguros** de que mañana nuestra pérdida no será peor que el $4.2\%$".
    
2.  **Visión Pesimista (Riesgo):** "Hay un **10% de probabilidad** de que suframos una pérdida mayor al $4.2\%$".

**La analogía del paraguas:** Si el VaR(90%) es $-4.2\%$, es como decir que el paraguas que llevas te protege del 90% de las lluvias, pero hay un 10% de tormentas tan fuertes (los "cisnes negros") que el paraguas no servirá de nada.

**1.3 Preguntas de comprensión**

**Pregunta 1:** "¿Qué supuesto hace el VaR histórico sobre el futuro?"  
$\rightarrow$ Que el futuro se distribuirá igual que el pasado.

**Pregunta 2:** "¿Si el período histórico incluye la crisis de 2020, el VaR sube o baja?"  
$\rightarrow$ Sube (más conservador) porque incluye rendimientos extremos negativos.

**Pregunta 3:** "¿Por qué el VaR al 99% es siempre mayor en valor absoluto que el 95%?"  
$\rightarrow$ Exige capturar un umbral más extremo: el peor 1% vs el peor 5%.

**1.4 Demostración en R (Partes 1–5 del script)**

Ir línea por línea en el cálculo del VaR histórico. Pausar especialmente en:

-   `quantile()` con `probs = 0.05`: asegurar que entienden que probs = 0.05 da el VaR al 95%
-   La gráfica de distribución empírica: señalar visualmente las líneas y la región sombreada en rojo
-   El VaR rodante: señalar cómo el VaR se dispara durante COVID-19 de 2020

**Preguntas pedagógicas**

"¿Qué observan en el gráfico durante el primer trimestre de 2020?"

$\rightarrow$ Si observa que el VaR cae dramáticamente. Pregúntese

"¿Un fondo que calculara su VaR en enero de 2020 con datos de 2019 habría estado bien preparado para marzo? ¿Por qué no?"

Esta discusión motiva orgánicamente el stress testing (Sesión 10) y los modelos GARCH (Sesión 9).

**Ventajas y limitaciones del método histórico:**

| VENTAJAS | LIMITACIONES |
| :--- | :--- |
| No asume distribución | Depende del período histórico |
| Captura asimetrías reales | No captura cisnes negros |
| Transparente y fácil de explicar | Inestable con muestras cortas |

**1.5 Laboratorio guiado (Ejercicio 1)**

Resuelvan el Ejercicio 1 del script (VaR histórico manual por ordenamiento).

Circular para verificar que entienden la diferencia entre `floor(0.05 × n)` y `quantile()`. Luego mostrar solución en pantalla.

----------

### BLOQUE 2: VaR Paramétrico (0:55 – 1:35)

**2.1 Derivación en pizarrón — fórmula central**

Esta es la sección matemáticamente más importante. Escribir la derivación completa:

#### Estimación del VaR Paramétrico (Método Delta-Normal)

Para una serie de rendimientos que sigue una distribución normal, el proceso de cálculo se estructura en los siguientes pasos:

- Paso 1: Estandarización de los rendimientos**

Si los rendimientos $r$ siguen una distribución normal con media $\mu$ y varianza $\sigma^2$:

$$r \sim N(\mu, \sigma^2)$$

Podemos estandarizar la variable para trabajar con la normal estándar:

$$z = \frac{r - \mu}{\sigma} \sim N(0,1)$$

- Paso 2: Definición de la probabilidad de pérdida**

El Value at Risk (VaR) al nivel de confianza $(1 - \alpha)$ se define como el umbral donde la probabilidad de tener un rendimiento igual o peor es exactamente $\alpha$:

$$P(r \leq \text{VaR}) = \alpha$$

- Paso 3: Relación con el cuantil de la normal estándar**

En términos de la distribución normal estándar, el VaR corresponde al valor crítico $z_\alpha$:

$$\frac{\text{VaR} - \mu}{\sigma} = z_\alpha$$

Donde $z_\alpha$ es el cuantil $\alpha$ de la normal (obtenido como `qnorm(α)` en software como R).

- Paso 4: Cálculo del VaR (Despeje)**

Finalmente, reescalamos el valor a las unidades originales del portafolio:

$$\text{VaR}(\alpha) = \mu + z_\alpha \times \sigma$$

- Cuantiles clave:

```
VaR 90%:  z = qnorm(0.10) = −1.2816
VaR 95%:  z = qnorm(0.05) = −1.6449
VaR 99%:  z = qnorm(0.01) = −2.3263

```
> Nota: Es importante recordar que, dado que estamos analizando el extremo izquierdo de la distribución (pérdidas), $z_\alpha$ será un número **negativo** para niveles de confianza comunes (como 95% o 99%), lo que resultará en un VaR inferior a la media.

**2.2 Ejemplo numérico completo para pizarrón**

Entienda este ejemplo ANTES de abrir R:

```
Datos:
  Activo: WALMEX.MX
  Inversión: $1,000,000 MXN
  μ = 0.0004  (0.04% diario)
  σ = 0.0150  (1.50% diario)
  Confianza: 95%  →  z = −1.6449

VaR(95%) = 0.0004 + (−1.6449 × 0.0150)
         = 0.0004 − 0.02467
         = −0.02427

Interpretación:
  −2.43% del portafolio
  Pérdida máxima = $24,270 MXN
  (solo en el 5% de los días perderemos más que esto)

```

**Pregunta:**

"Si la curtosis de WALMEX es 5.8 y la normal tiene curtosis 3, ¿qué implica para el VaR paramétrico?"

$\rightarrow$ Las colas reales son más pesadas que las de la normal: el VaR paramétrico **subestima** pérdidas extremas.

**2.3 VaR Componente: ¿qué activo concentra el riesgo?**

Explicar intuición antes del código:

-   El VaR del portafolio no es la suma de los VaR individuales (hay efecto de diversificación)
-   El VaR componente descompone el riesgo total en la parte que aporta cada activo

**Fórmulas importantes:**

### Descomposición del VaR del Portafolio

Para analizar la contribución de cada activo al riesgo total, utilizamos la siguiente estructura matricial:

**1. Varianza del portafolio**

Dada una matriz de varianza-covarianza $\Sigma$ y un vector de ponderaciones $w$:

$$\sigma_p^2 = w^T \Sigma w$$

**2. Covarianza del activo $i$ con el portafolio**

La covarianza del rendimiento de un activo individual con el rendimiento total del portafolio se obtiene de la $i$-ésima fila del producto matricial:

$$\text{Cov}(r_i, r_p) = (\Sigma w)_i$$

**3. Beta del activo $i$**

El coeficiente beta mide la sensibilidad del activo respecto a los movimientos del portafolio:

$$\beta_i = \frac{\text{Cov}(r_i, r_p)}{\sigma_p^2}$$

**4. VaR por Componente ($CVaR_i$)**

El VaR componente cuantifica la cantidad de riesgo que el activo $i$ aporta al portafolio total, considerando su efecto de diversificación:

$$\text{VaR}_{\text{comp}_i} = w_i \times \beta_i \times \text{VaR}_p$$

#### Propiedad de Agregación

Una característica fundamental de esta descomposición (basada en el teorema de Euler para funciones homogéneas de grado 1) es que el VaR total es igual a la suma de sus componentes:

$$\sum_{i=1}^n \text{VaR}_{\text{comp}_i} = \text{VaR}_{\text{total}}$$

> Nota: Esta propiedad es extremadamente útil para la gestión de riesgos, ya que permite identificar exactamente qué activos están "empujando" el VaR hacia arriba y cuáles ayudan a mitigarlo.

**2.4 Escalamiento temporal — regla √T**

```
VaR(T días) = VaR(1 día) × √T

Ejemplo: VaR(1 día, 95%) = −1.5%
  VaR(5 días)  = −1.5% × √5  = −3.35%
  VaR(10 días) = −1.5% × √10 = −4.74%  ← Basilea III
  VaR(21 días) = −1.5% × √21 = −6.87%

```

**Advertencia importante:**  
Esta regla asume rendimientos independientes e idénticamente distribuidos. En la práctica los mercados muestran clusters de volatilidad (GARCH, Sesión 9) que invalidan esta hipótesis.

### BLOQUE 3: VaR Monte Carlo

**3.1 Intuición — analogía de los dados**

"¿Cómo calcularían la probabilidad de obtener suma 7 al lanzar dos dados?

-   **Opción A (analítica):** Por combinatoria $\rightarrow$ 6/36 = 16.67%
-   **Opción B (simulación):** Lanzar los dados 10,000 veces y contar $\rightarrow$ mismo resultado

Monte Carlo es exactamente la opción B aplicada a los mercados: generamos miles de escenarios de rendimientos futuros y medimos cuántas veces se supera el umbral."

**Ventajas y limitaciones de Monte Carlo:**

| VENTAJAS | LIMITACIONES |
| :--- | :--- |
| Acepta cualquier distribución | Computacionalmente costoso |
| Modela correlaciones complejas | Depende del modelo asumido |
| Flexible para derivados no lineales | "Garbage in, garbage out" |
| Converge con suficientes simulaciones | |

**3.2 Descomposición de Cholesky — el momento de mayor álgebra lineal**

La **Descomposición de Cholesky** es, en términos sencillos, la "raíz cuadrada" de una matriz. Es la herramienta que nos permite pasar de variables aleatorias independientes a variables que **comparten una estructura de correlación real**.

- ¿Qué es la Descomposición de Cholesky? (La Analogía)

Imagina que tienes una matriz de varianza-covarianza $\Sigma$. Esta matriz representa cómo se mueven los activos en el mercado (por ejemplo, si el petróleo sube, las aerolíneas suelen bajar).

La Descomposición de Cholesky toma esa matriz $\Sigma$ y la descompone en el producto de una matriz triangular inferior ($L$) y su transpuesta ($L^T$):

$$\Sigma = L L^T$$

**La analogía:** Si $\Sigma$ es el número **25**, la matriz $L$ es el número **5**. Es el "componente básico" que, al multiplicarse por sí mismo, genera toda la estructura de riesgo del portafolio.

- ¿Para qué sirve en la Simulación de Monte Carlo?

Aquí es donde ocurre la magia. Cuando hacemos Monte Carlo, la computadora genera números aleatorios **independientes** (basados en una normal estándar $Z \sim N(0,1)$ ).

El problema es que, en la vida real, los activos **no son independientes**. Si simulas 1,000 escenarios donde Apple y Microsoft se mueven de forma totalmente aleatoria e inconexa, tus resultados de VaR serán falsos porque estarás sobreestimando la diversificación.

- El proceso de "Infección de Correlación":

1.  **Generas ruido blanco:** Creas un vector $Z$ de números aleatorios con media 0 y varianza 1 (sin correlación).
    
2.  **Aplicas Cholesky:** Multiplicas ese ruido por la matriz triangular $L$.
    
3.  **Resultado:** Obtienes un nuevo vector de choques $X$ que **sí tiene la correlación** que observaste históricamente.
    
- Explicación con Fórmulas

Si queremos simular dos activos con correlación $\rho$, la matriz de Cholesky nos dice que:

**Paso 1: Generar dos valores independientes**

$$z_1, z_2 \sim N(0,1) \quad \text{con } \text{Cov}(z_1, z_2) = 0$$

**Paso 2: Transformar usando la estructura de Cholesky**

Para el primer activo:

$$\epsilon_1 = z_1$$

Para el segundo activo (aquí aplicamos la correlación):

$$\epsilon_2 = \rho z_1 + \sqrt{1 - \rho^2} z_2$$

**Resultado:**

Ahora $\epsilon_1$ y $\epsilon_2$ tienen una correlación exactamente igual a $\rho$.

- ¿Por qué es vital para el VaR?

**"Sin Cholesky, Monte Carlo es solo ruido"**.

-   **Sin Cholesky:** Estás asumiendo que el mundo es un caos desordenado donde nada tiene que ver con nada.
    
-   **Con Cholesky:** Estás respetando la estructura histórica de cómo los activos "co-vibran". Esto permite que el VaR capture el riesgo de que varios activos caigan al mismo tiempo (riesgo de colapso sistémico).

**Problema:** La función `rnorm(n)` genera variables aleatorias **independientes**. Sin embargo, la teoría de portafolios (Markowitz) nos indica que los activos financieros están correlacionados. ¿Cómo podemos generar vectores que respeten la estructura de covarianza del mercado?

#### Solución: Descomposición de Cholesky en 3 Pasos

- Paso 1: Calcular la matriz de varianza-covarianza**

A partir de los rendimientos históricos, estimamos la matriz $\Sigma$:

$$\Sigma = \text{Cov}(R)$$

- Paso 2: Factorizar la matriz**

Buscamos una matriz $L$ tal que:

$$\Sigma = L L^T$$

> **Nota técnica en R:** La función `chol(Σ)` devuelve por defecto una matriz triangular **superior** ($U$). Para propósitos de la fórmula siguiente, podrías usar $L = t(\text{chol}(\Sigma))$.

- Paso 3: Generar vectores correlacionados**

Transformamos el ruido blanco $z$ (independiente) en rendimientos $r$ con la estructura deseada:

1.  Generar $z \sim N(0, I)$ (vectores con media 0 e identidad como covarianza).
    
2.  Aplicar la transformación:
    
    $$r = \mu + Lz$$
    

- Verificación Matemática

Para demostrar que el nuevo vector $r$ tiene la estructura de correlación correcta, calculamos su covarianza:

$$\text{Cov}(r) = \text{Cov}(\mu + Lz)$$

$$\text{Cov}(r) = \text{Cov}(Lz)$$

$$\text{Cov}(r) = L \cdot \text{Cov}(z) \cdot L^T$$

Como sabemos que $\text{Cov}(z) = I$ (por ser independientes y estandarizados):

$$\text{Cov}(r) = L \cdot I \cdot L^T$$

$$\text{Cov}(r) = L L^T = \Sigma \quad \checkmark$$

> Nota para la implementación:

Si en el código utilizas la matriz triangular superior de R ($U = \text{chol}(\Sigma)$), la fórmula de transformación se ajusta a:

$$r = \mu + zU$$

Donde $z$ es un vector fila. El resultado es matemáticamente equivalente.

**Consejo:**

Si algún estudiante se atasca con la demostración formal, es más importante entender la **idea**:

"Cholesky es una especie de raíz cuadrada de la matriz de covarianzas, que transforma variables independientes en correlacionadas."

**3.3 t-Student vs Normal**

-   La distribución t tiene colas más pesadas que la normal
-   Con df bajo (3–8) los rendimientos simulados incluyen eventos extremos más frecuentes
-   El VaR con t-Student es más conservador: mejor para capital de reserva
-   En la práctica, muchos modelos profesionales usan df entre 3 y 8 para acciones emergentes

Esta es una de las partes más importantes para entender por qué el mundo financiero no siempre se comporta como un libro de texto básico. La diferencia entre una Normal y una $t$ de Student es, literalmente, la diferencia entre estar preparado para una crisis o quebrar.

- El Concepto: "El peso de lo improbable"

Considera esto **"La distribución Normal es optimista por naturaleza"**. En una Normal, la probabilidad de ver un evento a 5 desviaciones estándar (un "cisne negro") es casi cero.

En cambio, la **distribución $t$ de Student** es "realista" o "pesimista". Sus colas no se pegan al eje horizontal tan rápido; se mantienen elevadas. Eso significa que "acepta" que los eventos extremos ocurren con más frecuencia de lo que la estadística tradicional sugiere.

- Los Grados de Libertad ($df$): La perilla del riesgo

Para que entender mejor, que los grados de libertad ($df$) son como una **perilla de realismo**:

-   **Si $df$ es muy alto (e.g., 100):** La $t$ de Student se convierte en una Normal. El mundo es predecible.
    
-   **Si $df$ es bajo (e.g., 3 a 8):** Las colas se "inflan". Estamos admitiendo que el mercado es volátil y propenso a saltos bruscos (común en mercados emergentes como México o Brasil).
    

### Comparación: ¿Por qué el VaR con $t$-Student es "Conservador"?

La siguiente tabla contrasta los dos enfoques principales en el cálculo del VaR paramétrico:

| Característica | VaR Normal | VaR $t$-Student |
| :--- | :--- | :--- |
| **Cálculo** | Basado en el valor crítico $z_\alpha$ | Basado en el valor crítico $t_{\alpha, df}$ |
| **Tratamiento de colas** | Colas delgadas (ignora extremos) | Colas pesadas (captura "cisnes negros") |
| **Sensibilidad al riesgo** | Subestima la probabilidad de crisis | Reconoce eventos extremos frecuentes |
| **Resultado del VaR** | Valor de pérdida menor (más optimista) | Valor de pérdida mayor (más pesimista) |
| **Uso en Capital** | Requiere menos reservas técnicas | **Más conservador**: Exige mayor capital de reserva |
| **Contexto Ideal** | Mercados maduros y estables | Acciones, Criptos y Mercados Emergentes |

**Conclusión didáctica:** Calcular el VaR con una $t$ de Student te dará una cifra de pérdida potencial **más grande**. Esto es "conservador" porque te obliga a guardar más capital de reserva. Es preferible que te sobre dinero después de una crisis a que te falte porque tu modelo fue demasiado optimista.

### BLOQUE 4: Comparación

**4.1 Pregunta de síntesis antes de mostrar la tabla**

"Tenemos tres métodos y todos calculan el VaR del mismo portafolio. ¿Por qué obtenemos números distintos? ¿Cuál es el correcto? ¿Cuál usarían en una institución financiera?"

$\rightarrow$ Objetivo: entender que no hay un método "correcto" sino que cada uno tiene fortalezas. En la práctica se calculan los tres como cross-check y se reporta el más conservador.

### 4.2 Tabla Comparativa de Métodos de Cálculo del VaR

| Método | Hipótesis principal | Ventajas | Limitaciones | Cuándo usarlo |
| :--- | :--- | :--- | :--- | :--- |
| **Histórico** | El pasado = el futuro | No asume distribución; transparente | Depende del período; sin "cisnes negros" | Regulación; comunicación directiva |
| **Paramétrico** | $r \sim N(\mu, \sigma^2)$ | Descomponible; rápido; analítico | Subestima colas; ignora asimetrías | VaR componente; horizonte corto |
| **Monte Carlo Normal** | $r \sim N(\mu, \sigma^2)$ | Base para activos no-lineales | Igual de optimista que el paramétrico | Opciones y derivados complejos |
| **Monte Carlo $t$-Student** | $r \sim t(\mu, \sigma, df)$ | Colas pesadas; más realista | Sensible al $df$ estimado | Mercados emergentes (volátiles) |
| **Monte Carlo Cholesky** | Normal multivariada con $\Sigma$ real | Respeta correlaciones; general | Asume correlaciones estables | Portafolios grandes y diversificados |


El cálculo del VaR no es un proceso de "talla única". La elección del método depende de qué estamos dispuestos a sacrificar: **precisión, tiempo o explicabilidad**.

-   **El Enfoque Prudente (Histórico):** Es como decir "esperamos que lo peor que ya pasó sea lo peor que pueda pasar". Es excelente para presentar ante una junta directiva porque no requiere entender estadística compleja, solo de historia.
    
-   **El Enfoque de Ingeniería (Paramétrico y Normal):** Es elegante y rápido. Nos permite saber cuánto riesgo aporta cada activo individualmente (VaR Componente), pero tiene un "punto ciego": asume que los mercados son campanas de Gauss perfectas, lo que en crisis financieras suele fallar.
    
-   **El Enfoque de Simulación (Monte Carlo):** Aquí es donde entramos al mundo real. Al usar la **$t$-Student**, estamos admitiendo que el mercado es más peligroso de lo que dice la teoría normal. Y al usar **Cholesky**, estamos reconociendo que los activos no se mueven solos, sino que "co-vibran" entre ellos.
    

**Conclusión:** Un buen economista no usa el método más complejo solo por serlo, sino el que mejor captura los riesgos específicos de su portafolio. Si tienes acciones de mercados emergentes (como las de la BMV), un VaR Normal probablemente te mentirá; ahí es donde la robustez de la $t$-Student y Cholesky se vuelven indispensables.

**4.3 Limitaciones del VaR — motivar CVaR**

El VaR tiene una debilidad fundamental: **no dice nada sobre QUÉ TAN GRANDES son las pérdidas más allá del umbral.**

```
Ejemplo: VaR(99%) = −3% en dos portafolios distintos

Portafolio A: el 1% peor va de −3% a −4%
              → pérdida esperada en cola ≈ −3.5%  (controlado)

Portafolio B: el 1% peor va de −3% a −20%
              → pérdida esperada en cola ≈ −8%    (muy preocupante)

El VaR reporta el mismo número: −3%
No distingue entre estos dos casos.

```

**Puente hacia Sesión 8:**

"El CVaR (Expected Shortfall) responde: ¿cuánto perdemos en PROMEDIO cuando ya superamos el VaR?

El script ya calcula esto en la Parte 10. Para WALMEX (2020-2024), el CVaR típicamente es 30–50% más severo que el VaR. Eso es lo que exploramos en la Sesión 8."

**Nota regulatoria:** Basilea III (2019) reemplazó el VaR por el Expected Shortfall como medida estándar para requerimientos de capital por riesgo de mercado.


----------

## EJERCICIOS Y TAREA

**Obligatorios:** 1-4  
**Avanzados:** 5-7

**Énfasis:**

-   Ejercicio 1 (VaR manual por ordenamiento) es fundamental — deben entender el cuantil empírico
-   Ejercicio 4 (diversificación y VaR) conecta directamente con Markowitz: candidato al parcial
-   Ejercicio 7 (COVID-19) desarrolla intuición sobre limitaciones del modelo histórico

----------

## SOLUCIONES A EJERCICIOS SELECCIONADOS

### Ejercicio 4: Beneficio de diversificación

```r
# VaR individual de cada activo al 95%
var_individuales <- sapply(1:n_activos, function(i) {
  r_i <- as.numeric(rendimientos[, i])
  mean(r_i) + qnorm(0.05) * sd(r_i)
})

# VaR "no diversificado" = suma ponderada sin correlación
var_no_div <- sum(pesos_mv * var_individuales)
# Equivale a asumir correlación perfecta +1 entre activos

# VaR real del portafolio (con correlaciones)
var_port_param <- var_param_95$var_pct

# Beneficio de diversificación
beneficio <- var_no_div - var_port_param

# Valores típicos con los tickers del curso:
#   VaR suma ponderada:       −2.85%
#   VaR portafolio real:      −2.10%
#   Beneficio:                 0.75%  (reducción del ~26%)
#   En $1M: la diversificación "ahorra" ~$7,500 de VaR

```

**Lección:** El VaR del portafolio siempre es ≤ suma ponderada de VaR individuales. Esta es la propiedad de subaditividad — que el VaR **viola** en distribuciones no normales (tema de CVaR).

### Ejercicio 7: Crisis COVID-19

Resultados esperados (variarán con los datos descargados):

Período

VaR histórico 95%

Desv. Est. diaria

Comentario

2019 (pre-COVID)

≈ −1.5% a −1.8%

≈ 0.8% – 1.0%

Mercado tranquilo

Feb–Jun 2020

≈ −4.5% a −6.5%

≈ 2.5% – 3.5%

3–4x más volátil

Incremento

**3x a 4x más severo**

—

Modelo 2019 era inadecuado

**Discusión esperada:** Un banco que calculó su VaR en diciembre de 2019 con datos de ese año y lo usó para el capital de reserva de 2020 estuvo severamente subcapitalizado cuando llegó marzo. El modelo no estaba equivocado en sí mismo — el período histórico simplemente no era representativo.

----------

## PROBLEMAS COMUNES Y SOLUCIONES

### Problema 1: `quantile()` da un valor positivo

**Causa:** Usaron `probs = 0.95` en lugar de `probs = 0.05`  
**Solución:** VaR al 95% es el percentil 5% (la cola izquierda). `probs = 1 - confianza`

### Problema 2: VaR paramétrico resulta positivo

**Causa:** Olvidaron que `qnorm(0.05)` es negativo  
**Solución:** `qnorm(0.05) = −1.6449`. El resultado es negativo cuando σ domina sobre μ, como debe ser

### Problema 3: Error `non-finite values` en `MASS::fitdistr`

**Causa:** NAs o ceros en los datos antes del `log()`  
**Solución:** Limpiar con `na.omit()` y verificar que no hay precios en cero

### Problema 4: La simulación Monte Carlo da resultados distintos cada vez

**Causa:** Falta el `set.seed()` antes de `rnorm()` o `rt()`  
**Solución:** Agregar `set.seed(2024)` inmediatamente antes del bloque de simulación

### Problema 5: Error `matrix is not positive definite` en `chol()`

**Causa:** Activos altamente correlacionados generan matriz casi singular  
**Solución:** Eliminar activos redundantes o usar `nearPD()` del paquete `Matrix`

### Problema 6: Error en Ejercicio 6 — `S_T` tiene valores negativos

**Causa:** Error en la fórmula del GBM, falta la función `exp()`  
**Solución:** `S_T = S0 * exp(...)` — los precios en GBM son siempre positivos

### Problema 7: Yahoo Finance no carga los datos

**Causa:** Ticker desactualizado o caído  
**Solución:** Probar sin `.MX` (e.g., `"WALMEX"` en lugar de `"WALMEX.MX"`) o verificar en finance.yahoo.com

----------

## PUNTOS PEDAGÓGICOS CRÍTICOS

### 1. El VaR no es "la pérdida máxima"

-   Es la pérdida que se **supera** en el X% de los casos
-   Enfatizar la dirección correcta: VaR(95%) = pérdida mínima del peor 5%
-   Confundir esto es el error más común en exámenes y en la práctica

### 2. Conectar curtosis con la elección del método

-   Si curtosis > 3 (colas pesadas): el paramétrico subestima riesgo
-   Esto lo calcularon en Sesión 3 — cerrar el círculo explícitamente
-   Es la razón por la que Monte Carlo con t-Student existe

### 3. Cholesky como extensión de Markowitz

-   La misma Σ del portafolio óptimo se usa aquí para generar simulaciones
-   No es nueva matemática: es la misma herramienta aplicada diferente

### 4. Énfasis en interpretación monetaria

-   Siempre traducir el VaR a pesos mexicanos
-   "−2.4%" es abstracto; "$24,000 MXN de pérdida máxima" es tangible
-   Los directivos financieros hablan en pesos, no en porcentajes


### Pregunta de salida:

"Un portafolio tiene VaR histórico (95%) de −2.5% y VaR paramétrico (95%) de −1.8%. ¿Qué nos dice esta diferencia sobre la distribución de los rendimientos? ¿Cuál usarías para reportar al regulador?"

----------

## PREPARACIÓN PARA SESIÓN 8

**Tema:** CVaR y medidas coherentes de riesgo

**Conexión:**  
"VaR: ¿cuál es el umbral del peor 5% de los días?  
CVaR: ¿cuánto perdemos en promedio cuando ya estamos en ese peor 5%?"

**Materiales:**

-   Los mismos datos y portafolio de esta sesión
-   El cálculo preliminar del CVaR ya está en la Parte 10 del script de hoy

**Concepto a anticipar:**

-   Medidas coherentes de riesgo (Artzner et al., 1999)
-   Por qué el VaR viola subaditividad en distribuciones no normales
-   El CVaR siempre es más conservador que el VaR del mismo nivel

----------

## AVISO — EXAMEN PARCIAL (próxima sesión)

Esta es la última sesión antes del Examen Parcial (25% de la calificación). Reservar los últimos 10 minutos para:

-   Confirmar el alcance: Sesiones 1–7, Unidades III–IV

**Temas más probables en el parcial:**

Tema

Tipo de pregunta

Dificultad

Álgebra lineal (S2)

Calcular w'Σw dado w y Σ explícitos

Básico

Estadística (S3)

Calcular curtosis e interpretar colas pesadas

Básico

Markowitz (S4)

Portafolio de mínima varianza (sistema Kx=b)

Intermedio

CAPM (S5)

Calcular beta; interpretar alfa de Jensen

Básico

Bonos (S6)

Precio de bono cupón cero; duration

Intermedio

VaR Histórico (S7)

Dado un vector de rendimientos, calcular VaR 95%

Básico

VaR Paramétrico (S7)

Dado μ y σ, calcular y escalar a 10 días

Intermedio

VaR Componente (S7)

Contribución de cada activo al riesgo total

Avanzado

**Para el repaso, dominar:**

-   [ ] Fórmula `VaR = μ + z_α × σ` y los z-scores de memoria
-   [ ] Diferencia entre el VaR histórico (cuantil empírico) y el paramétrico
-   [ ] Interpretar VaR en pesos dado un monto de inversión
-   [ ] Regla √T para escalar de 1 día a 10 días (Basilea III)
-   [ ] Por qué el paramétrico subestima cuando curtosis > 3
