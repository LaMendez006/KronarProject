# KronarProject

Proyecto integrador: **Parte 1 en Haskell** (encuentra el camino optimo de Dravek y escribe `resultado.json`) y **Parte 2 en Julia** (lee ese archivo, lo valida y presenta el reporte, el analisis estadistico, el grafico de barras, la verificacion del puntaje y los porcentajes). El unico medio de comunicacion entre los dos programas es `resultado.json`.

## Estructura del repositorio

Cada persona mantiene su seccion en su propio archivo. `Kronar.hs`, `Pruebas.hs` e `integracion.jl` son los archivos de entrega: no copian codigo, **incluyen** las secciones en orden y agregan el programa principal.

```
KronarProject/
├── README.md
├── resultado.json                  # generado por Haskell con t1 (entrega)
├── docs/readmeEntrada.md           # notas de P1 (instalacion y errores)
├── haskell/
│   ├── Kronar.hs                   # ENTREGA: une las secciones + main (P4)
│   ├── Pruebas.hs                  # ENTREGA: une las pruebas + main (P4)
│   ├── haskellEntrada.hs           # P1: tablero editable, lectura, validacion, meta
│   ├── haskellCaminos.hs           # P2: caminos recursivos, desempates, optimo
│   ├── haskellReglas.hs            # P3: tipos compartidos, bruto, Zafiro, Eter
│   ├── haskellSalida.hs            # P4: JSON a mano, resolver, resumen
│   ├── haskellPruebasEntrada.hs    # P1: tablero A y t1 con tabla a mano
│   └── haskellPruebasSalida.hs     # P4: JSON, flujo completo y cobertura
└── julia/
    ├── integracion.jl              # ENTREGA: incluye las secciones + main (P4)
    ├── juliaLectura.jl             # P1: tipos, lector JSON propio, validacion
    ├── juliaReglasVerificacion.jl  # P2: reglas, verificacion, porcentajes
    ├── juliaEstadistica.jl         # P3: estadistica y grafico de barras
    ├── juliaReporte.jl             # P4: ruta legible y reporte comun
    ├── juliaProbarLectura.jl       # P1: prueba de lectura con archivos danados
    ├── juliaProbarIntegracion.jl   # P4: prueba cruzada Haskell vs Julia
    ├── juliaEjemploEnunciado.json  # ejemplo de la seccion 4.2 del enunciado
    ├── errores/                    # JSON danados a proposito (criterio "sin caerse")
    └── pruebas/                    # JSON generados por Kronar.hs para cada tablero
```

**Como une Haskell los archivos.** `Kronar.hs` y `Pruebas.hs` usan `{-# LANGUAGE CPP #-}` y `#include "haskellEntrada.hs"`, etc. CPP es el preprocesador que trae GHC (no es una libreria externa). Las rutas se resuelven desde la carpeta `haskell/`, asi que funciona desde cualquier carpeta. Reglas para no romperlo: los archivos de seccion no llevan `module` ni `main`, cada tipo se define una sola vez (los compartidos estan en `haskellReglas.hs`) y `haskellCaminos.hs` se incluye primero porque empieza con un `import`.

## Requisitos e instalacion

| Herramienta | Version probada | Como comprobarla |
|---|---|---|
| GHC (Haskell) | 9.10.3 (tambien compila sin advertencias en 9.4.7) | `ghc --version` |
| Julia | 1.12.7 | `julia --version` |

- **Haskell:** solo lo que trae GHC (Prelude, Data.List, System.Environment, System.Exit). No hay que instalar paquetes.
- **Julia:** no hay que instalar paquetes. `resultado.json` se lee con un lector JSON propio (`juliaLectura.jl`). `Statistics` es una biblioteca estandar que ya viene con Julia.

## Como ejecutar (en este orden, desde la raiz del repositorio)

**1. Haskell genera `resultado.json`:**

```bash
runghc haskell/Kronar.hs                 # tablero por defecto (t1)
runghc haskell/Kronar.hs 3 -2 -1 4 2     # tablero por argumentos
```

Para cambiar el tablero por defecto, edita `tableroPorDefecto` en el bloque `UNICO LUGAR EDITABLE DEL TABLERO` de `haskell/haskellEntrada.hs`. Si se pasan argumentos, tienen prioridad.

Version compilada (opcional; sirve para revisar que no queden advertencias):

```bash
ghc -Wall -Wmissing-signatures -outputdir build -o kronar haskell/Kronar.hs
./kronar            # en Windows: kronar.exe
```

**2. Julia lee `resultado.json` y presenta el reporte:**

```bash
julia julia/integracion.jl                         # lee ./resultado.json
julia julia/integracion.jl julia/pruebas/t2.json   # lee otro archivo
```

Orden de la salida: reporte comun → estadisticas → grafico de barras → verificacion del puntaje → porcentajes por casilla.

### Errores esperados

**Haskell** con un tablero invalido imprime el motivo, termina con codigo 1 y **no crea** `resultado.json`:

| Entrada | Mensaje |
|---|---|
| `runghc haskell/Kronar.hs 5` | `Tablero invalido: Se recibio 1 casilla; el minimo es 2` |
| 16 numeros | `Tablero invalido: Se recibieron 16 casillas; el maximo es 15` |
| `runghc haskell/Kronar.hs 0 0 0` | `Tablero invalido: Las 3 casillas valen 0; debe haber al menos una distinta de 0` |
| `runghc haskell/Kronar.hs 3 x 1` | `Tablero invalido: El argumento 'x' no es un numero entero` |

Si ya existia un `resultado.json` de una ejecucion anterior, Haskell no lo toca (borrarlo exigiria `System.Directory`, que no esta en la lista permitida).

**Julia** con un archivo inexistente, vacio, truncado, sin una clave o con un tipo equivocado imprime un mensaje que nombra la clave y dice "se esperaba X, se encontro Y", y termina limpio con codigo 1, sin trazas de error. Ejemplo: `julia julia/integracion.jl julia/errores/sinClave.json`.

## Pruebas

```bash
runghc haskell/Pruebas.hs                 # 31 pruebas de Haskell; codigo 1 si alguna falla
julia julia/juliaProbarLectura.jl         # lectura del ejemplo y de los archivos danados
julia julia/juliaProbarIntegracion.jl     # prueba cruzada Haskell vs Julia y archivos danados
```

`Pruebas.hs` reune las tablas hechas a mano de P1 (tablero A y t1) y las pruebas de P4: el JSON exacto del ejemplo del enunciado, el orden de las 9 claves y el flujo completo de `resolver` en 7 tableros. En conjunto cubren las tres reglas y los dos tipos de empate:

| Tablero | Que demuestra | Caminos | Optimo (desde 1) | Final |
|---|---|---|---|---|
| A `[4, -1, 2, 0, 0]` | Regla del Vacio, Eter | 2 | 1 y 3 | 16 |
| B `[-5, 7, 4, 0, 8]` | Empate resuelto por menos saltos, 0 en medio, inicio negativo | 7 | 1, 2, 3 y 5 | 24 |
| C `[9, 4, -3, -3, -6]` | Zafiro en el optimo, Eter, empate lexicografico | 7 | 1, 2, 3 y 5 | 9 |
| t1 `[3, -2, -1, 4, 2]` | Tablero oficial (genera la entrega) | 7 | 1, 3, 4 y 5 | 18 |
| t2 `[1, -3, -4, 2, 0]` | Tablero oficial: Vacio, bruto 0 (par) | 4 | 1, 2 y 4 | 10 |
| t3 `[5, 5, 5, 5, 5, 5]` | Tablero oficial: 13 caminos | 13 | 1, 2, 3, 4, 5 y 6 | 40 |

`juliaProbarIntegracion.jl` lee los JSON de `julia/pruebas/` (generados por `Kronar.hs`), recalcula el puntaje con las reglas escritas en Julia y exige que coincida con Haskell. Ademas usa `t1Alterado.json` (puntaje final cambiado de 18 a 25) para comprobar que la verificacion muestra la diferencia.

## Como se generan los caminos y como se desempata

- `caminosDesde meta actual` es recursiva: si `actual == meta` devuelve `[[meta]]`; si no, prueba cada salto de `saltosValidos = [1, 2, 3]` que no pase de la meta y antepone `actual` a cada camino que sale del destino.
- `generarCaminos meta = caminosDesde meta 0`; `caminos_evaluados` es el largo de esa lista completa.
- Ningun camino pasa de la meta porque el salto se descarta antes de la llamada recursiva.
- `compararCandidatos` define un orden total: mayor puntaje final, luego menos saltos, luego menor lexicografico.
- Como el orden es total, `elegirOptimo` (con `minimumBy`) devuelve siempre un unico optimo.

## Decisiones estadisticas (Julia)

- Solo se usan las casillas en juego: `tablero[1:casilla_meta+1]`. Las posteriores a la meta no entran en ninguna estadistica ni porcentaje.
- La desviacion estandar es **muestral** (divide entre n-1, el valor por defecto de `std`). Con una sola casilla en juego se informa 0.
- Si el maximo o el minimo se repite, se indica la **primera** casilla donde aparece (`argmax` / `argmin`).
- En el grafico, los positivos usan `▇`, los negativos `░` y el 0 una barra vacia; si algun valor pasa de 20, las barras se escalan para que la mas larga mida 20.
- Si el puntaje bruto es 0, los porcentajes no se calculan: se avisa en vez de dividir entre cero.

## Muestras de pantalla

**Haskell** (`runghc haskell/Kronar.hs`):

```
=== Kronar: resultado ===
Tablero (5 casillas, numeradas desde 1):
  Casilla:   1  2  3  4  5
  Valor:     3 -2 -1  4  2
Meta: casilla 5 (indice 4). Regla del Vacio: no aplicada (la meta es la ultima casilla).
Camino optimo: casillas 1, 3, 4 y 5  (indices desde 0: [0, 2, 3, 4])
Desglose del puntaje (final = bruto - Zafiro + Eter):
  Puntaje bruto        :     8
  Penalizacion Zafiro  :     0
  Bono Eter            :   +10
  Puntaje final        :    18
Caminos evaluados: 7
Archivo resultado.json creado.
```

**Haskell con un tablero invalido** (`runghc haskell/Kronar.hs 0 0 0`):

```
Tablero invalido: Las 3 casillas valen 0; debe haber al menos una distinta de 0
No se creo resultado.json.
```

**Julia** (`julia julia/integracion.jl`):

```
PENDIENTE: pegar aqui la salida real de "julia julia/integracion.jl"
despues de ejecutar Haskell con t1.
```

## Reglas del juego
------------------------------------------------------
2.1 Cómo se mueve Dravek

1.	Dravek comienza en la casilla 1 y recoge su piedra. La casilla inicial siempre cuenta.

2.	En cada turno avanza 1, 2 o 3 casillas. No puede retroceder ni quedarse en el mismo lugar.

3.	Recoge la piedra de cada casilla en la que aterriza. Las casillas que salta no cuentan en absoluto.

4.	Debe aterrizar exactamente en la casilla meta. No se permite un salto que la sobrepase.
Llamamos camino a la lista ordenada de casillas en las que aterriza Dravek, desde la casilla 1 hasta la meta, ambas incluidas.

-----------------------------------------------
2.2 La Regla del Vacío

Esta regla decide dónde termina el juego. Dravek no puede terminar en una casilla cuyo valor es 0.


•	Si la casilla n tiene un valor distinto de 0, la meta es la casilla n.

•	Si la casilla n es 0, la meta pasa a ser la casilla n menos 1. Si esa también es 0, sigue retrocediendo hasta encontrar la última casilla con un valor distinto de 0.

•	Las casillas posteriores a la meta están fuera de juego: nadie aterriza en ellas y no afectan el resultado.

•	Decimos que la regla fue aplicada cuando la meta terminó siendo una casilla distinta de la casilla n.
------------------------------------------------------

2.3 La Regla del Zafiro

Cada vez que Dravek aterriza en dos casillas consecutivas de su camino y ambas tienen un valor negativo, pierde 5 puntos por doble contaminación.

•	La penalización se cuenta por cada par. Tres casillas negativas seguidas forman dos pares, por lo que restan 10 puntos.

•	Consecutivas significa consecutivas dentro del camino, no una al lado de la otra en el tablero. Si Dravek salta de la casilla 2 (valor -1) a la casilla 4 (valor -3), la regla igualmente se aplica.

•	El cero no se considera negativo.
------------------------------------------------
2.4 La Regla del Éter

Si el puntaje bruto del camino, es decir, la suma de las piedras recogidas sin bonos ni penalizaciones, es un número par, Dravek gana 10 puntos extra. El cero y los números pares negativos también cuentan como pares.
---------------------------------------------------------
2.5 Puntaje de un camino

Juntando todo, el puntaje de un camino se calcula así:

puntaje final = puntaje bruto - penalización Zafiro + bono Éter
