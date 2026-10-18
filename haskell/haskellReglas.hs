------------------------------------------
-- Villaneda
--Archivo en el cual definiremos reglas base del juego y recursos compartidos.
-----------------------------------------


-- Definimos el tipo tablero
-- Ejemplo dado por Harold: Take the board [2, -1, -3, 5, 0], which has 5 squares.
-- Cada numero es la piedra que se encuentra en cada casilla

type Tablero = [Int]

--Definimos el camino que pisara Dravek
--Siempre empezamos en la casilla 1
--1.	Dravek comienza en la casilla 1 y recoge su piedra. La casilla inicial siempre cuenta.
type Camino = [Int]

-- Definimos los puntajes
--   puntajeBruto  = la suma de las piedras recogidas
--   puntajeReglaZafiro = lo que se RESTA por la Regla del Zafiro (0, 5, 10...)
--   puntajeReglaEter  = lo que se SUMA por la Regla del Eter (0 o 10)
--   puntajeFinal  = el resultado de juntar todo
-- puntaje final = puntaje bruto - penalización Zafiro + bono Éter

data Puntaje = Puntaje
  { puntajeBruto  :: Int
  , puntajeReglaZafiro :: Int
  , puntajeReglaEter   :: Int
  , puntajeFinal  :: Int
  } deriving (Show, Eq)

-- "deriving (Show, Eq)" imprimir el Puntaje y compararlo

--Definimos el resultado que ira al json

data Resultado = Resultado
  { rTablero   :: Tablero   -- el tablero original
  , rMeta      :: Int       -- casilla meta (empezando en 0)
  , rVacio     :: Bool      -- True si se aplico la Regla del Vacio
  , rCamino    :: Camino    -- el mejor camino
  , rPuntaje   :: Puntaje   -- su puntaje
  , rEvaluados :: Int       -- cuantos caminos se revisaron
  } deriving (Show, Eq)

-- "deriving (Show, Eq)" imprimir el Puntaje y compararlo

------------------------------------
--Logica para el puntaje bruto
------------------------------------

-- puntaje final = puntaje bruto - penalización Zafiro + bono Éter
-- calculamos el valor de cada casilla

calcularValorCasilla :: Tablero -> Int -> Int
calcularValorCasilla tablero posicion = tablero !! posicion

--calculamos el p bruto

calcularBruto :: Tablero -> Camino -> Int
calcularBruto _ []                       = 0
calcularBruto tablero (posicion : resto) = calcularValorCasilla tablero posicion + calcularBruto tablero resto

------------------------------------
--REGLA DEL ZAFIRO  (NUEVO: lo que sigue)
------------------------------------
-- Regla: si Dravek pisa dos casillas SEGUIDAS DEL CAMINO y las dos son
-- negativas, pierde 5 puntos. Se cuenta cada pareja
-- (tres negativas seguidas = 2 parejas = 10 puntos). El cero NO es negativo.

-- Cuantos puntos se pierden por cada pareja de negativas

puntosPorPareja :: Int
puntosPorPareja = 5

--CALCULAR Eter
puntosPorEter :: Int
puntosPorEter = 10

calcularEter :: Int -> Int
calcularEter bruto
  | even bruto = puntosPorEter
  | otherwise  = 0


-- Recibe los VALORES del camino (no las posiciones) y devuelve la penalizacion.
-- Mira el inicio de la lista:

--   * si hay menos de 2 valores -> no hay pareja -> 0
--   * si hay 2 o mas (a y b): si los dos son negativos suma 5, si no suma 0,
--     y sigue revisando desde b (porque b tambien forma pareja con el que sigue)
calcularPenalizacionDeValores :: [Int] -> Int

calcularPenalizacionDeValores []  = 0
calcularPenalizacionDeValores [_] = 0
calcularPenalizacionDeValores (a : b : resto)
  | a < 0 && b < 0 = puntosPorPareja + calcularPenalizacionDeValores (b : resto)
  | otherwise      = calcularPenalizacionDeValores (b : resto)

-- Convierte el camino (posiciones) en valores y aplica la funcion de arriba.
calcularZafiro :: Tablero -> Camino -> Int
calcularZafiro tablero camino =
  calcularPenalizacionDeValores (map (calcularValorCasilla tablero) camino)



--PUNTUACION CAMINO 
puntuarCamino :: Tablero -> Camino -> Puntaje
puntuarCamino tablero camino = Puntaje
  { puntajeBruto       = bruto
  , puntajeReglaZafiro = zafiro
  , puntajeReglaEter   = eter
  , puntajeFinal       = bruto - zafiro + eter
  }
  where
    bruto  = calcularBruto tablero camino
    zafiro = calcularZafiro tablero camino
    eter   = calcularEter bruto

