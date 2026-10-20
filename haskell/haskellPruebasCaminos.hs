-- PRUEBAS DE CAMINOS (P2): TABLERO B Y t2
-- Cada fila de las tablas es (camino desde 0, bruto, zafiro, eter, final).
-- En las listas de Haskell el Zafiro va en positivo (es lo que se resta);
-- en los comentarios aparece con el signo con que entra en la formula.
-- Formula: final = bruto - Zafiro + Eter.
-- Como armar la lista de caminos a mano: desde la casilla actual se prueba
-- saltar 1, 2 y 3 casillas sin pasar de la meta, y se repite desde cada
-- destino hasta llegar a la meta (es lo mismo que hace caminosDesde).


-- TABLERO B = [-5, 7, 4, 0, 8]
--   La casilla 5 vale 8 (no es 0), asi que la meta es la casilla 5
--   (indice 4). Regla del Vacio aplicada: NO. Hay 7 caminos:
--
--   Camino (desde 1) | Valores        | Bruto | Zafiro | Eter | Final
--   1, 2, 3, 4, 5    | -5, 7, 4, 0, 8 |    14 |      0 |  +10 |    24
--   1, 2, 3, 5       | -5, 7, 4, 8    |    14 |      0 |  +10 |    24
--   1, 2, 4, 5       | -5, 7, 0, 8    |    10 |      0 |  +10 |    20
--   1, 2, 5          | -5, 7, 8       |    10 |      0 |  +10 |    20
--   1, 3, 4, 5       | -5, 4, 0, 8    |     7 |      0 |    0 |     7
--   1, 3, 5          | -5, 4, 8       |     7 |      0 |    0 |     7
--   1, 4, 5          | -5, 0, 8       |     3 |      0 |    0 |     3
--
--   Zafiro: la unica casilla negativa es la 1 (valor -5) y el camino nunca
--   vuelve a pisar una negativa; la siguiente casilla visitada vale 7, 4,
--   0 u 8 (el 0 no es negativo). No hay ningun par negativo: Zafiro = 0 en
--   los 7 caminos.
--   Eter: se mira sobre el bruto. Bruto 14 y 10 son pares (+10); 7 y 3 son
--   impares (0).
--   Un 0 en medio del camino: los caminos 1, 3, 5 y 7 aterrizan en la
--   casilla 4 (valor 0). Es legal: la Regla del Vacio solo impide TERMINAR
--   en un 0. El 0 suma 0 y no cambia el bruto.
--   Inicio negativo: la casilla 1 (-5) siempre cuenta y ya esta incluida
--   en todos los brutos.
--   Empate: los caminos 1,2,3,4,5 y 1,2,3,5 dan 24. Criterio 1 (mayor
--   final): empatan. Criterio 2 (menos saltos): el primero tiene 5
--   casillas (4 saltos) y el segundo 4 casillas (3 saltos), gana el
--   segundo. No hace falta llegar al criterio 3.
--   Optimo: 1, 2, 3 y 5 (indices [0,1,2,4]) con 24 puntos.
tableroB :: Tablero
tableroB = [-5, 7, 4, 0, 8]

tablaB :: [(Camino, Int, Int, Int, Int)]
tablaB =
  [ ([0, 1, 2, 3, 4], 14, 0, 10, 24)
  , ([0, 1, 2, 4], 14, 0, 10, 24)
  , ([0, 1, 3, 4], 10, 0, 10, 20)
  , ([0, 1, 4], 10, 0, 10, 20)
  , ([0, 2, 3, 4], 7, 0, 0, 7)
  , ([0, 2, 4], 7, 0, 0, 7)
  , ([0, 3, 4], 3, 0, 0, 3)
  ]


-- TABLERO t2 = [1, -3, -4, 2, 0]  (tablero oficial)
--   La casilla 5 vale 0, asi que la meta retrocede a la casilla 4 (indice
--   3, valor 2). Regla del Vacio aplicada: SI. La casilla 5 queda fuera de
--   juego. Hay 4 caminos:
--
--   Camino (desde 1) | Valores      | Bruto | Zafiro | Eter | Final
--   1, 2, 3, 4       | 1, -3, -4, 2 |    -4 |     -5 |  +10 |     1
--   1, 2, 4          | 1, -3, 2     |     0 |      0 |  +10 |    10
--   1, 3, 4          | 1, -4, 2     |    -1 |      0 |    0 |    -1
--   1, 4             | 1, 2         |     3 |      0 |    0 |     3
--
--   Zafiro: solo el camino 1,2,3,4 pisa dos negativas seguidas (-3 y -4):
--   pierde 5. En 1,2,4 se salta la casilla 3 y en 1,3,4 se salta la 2, asi
--   que no queda ningun par de negativas consecutivas en el camino.
--   Eter: el bruto de 1,2,4 es 0 (1 - 3 + 2), y el cero cuenta como par:
--   +10. El bruto de 1,2,3,4 es -4, un par negativo: tambien +10, pero su
--   Zafiro lo deja en 1. Los brutos -1 y 3 son impares: 0.
--   Optimo: 1, 2 y 4 (indices [0,1,3]) con 10 puntos. No hay empate.
t2 :: Tablero
t2 = [1, -3, -4, 2, 0]

tablaT2 :: [(Camino, Int, Int, Int, Int)]
tablaT2 =
  [ ([0, 1, 2, 3], -4, 5, 10, 1)
  , ([0, 1, 3], 0, 0, 10, 10)
  , ([0, 2, 3], -1, 0, 0, -1)
  , ([0, 3], 3, 0, 0, 3)
  ]


-- Devuelve el puntaje final de una fila de tabla.
finalDeFila :: (Camino, Int, Int, Int, Int) -> Int
finalDeFila (_, _, _, _, f) = f

-- True si el camino empieza en 0, termina en la meta y cada salto es de 1 a 3.
-- Como cada salto es de al menos 1 y termina en la meta, nunca la sobrepasa.
esCaminoValido :: Int -> Camino -> Bool
esCaminoValido _ [] = False
esCaminoValido laMeta elCamino@(elInicio : elResto) =
  elInicio == 0
    && last elCamino == laMeta
    && and (zipWith saltoPermitido elCamino elResto)
  where saltoPermitido a b = (b - a) `elem` saltosValidos

-- Puntaje con solo el final definido (para probar el comparador).
puntajeConFinal :: Int -> Puntaje
puntajeConFinal f = Puntaje 0 0 0 f

-- Camino optimo y puntaje final que entrega el programa para un tablero.
optimoDe :: Tablero -> (Camino, Int)
optimoDe tablero = (rCamino elResultado, puntajeFinal (rPuntaje elResultado))
  where elResultado = resolver tablero

-- Puntaje del camino optimo que entrega el programa para un tablero.
puntajeOptimoDe :: Tablero -> Puntaje
puntajeOptimoDe = rPuntaje . resolver

-- Pruebas de caminos: (descripcion, paso la prueba?).
pruebasCaminos :: [(String, Bool)]
pruebasCaminos =
  [ ("Caminos por meta 0 a 5: 1, 1, 2, 4, 7, 13",
      map (length . generarCaminos) [0 .. 5] == [1, 1, 2, 4, 7, 13])
  , ("Todo camino empieza en 0, termina en la meta y salta de 1 a 3",
      and [ all (esCaminoValido laMeta) (generarCaminos laMeta) | laMeta <- [0 .. 10] ])
  , ("elegirOptimo: a igual puntaje gana el de menos saltos",
      fst (elegirOptimo [([0, 1, 2, 3], puntajeConFinal 5), ([0, 3], puntajeConFinal 5)]) == [0, 3])
  , ("elegirOptimo: a igual puntaje y saltos gana el menor lexicografico",
      fst (elegirOptimo [([0, 2, 3], puntajeConFinal 5), ([0, 1, 3], puntajeConFinal 5)]) == [0, 1, 3])
  , ("Tablero B: meta en el indice 4",                 calcularMeta tableroB == 4)
  , ("Tablero B: Regla del Vacio no aplicada",         not (vacioAplicado tableroB 4))
  , ("Tablero B: tabla a mano = programa (7 caminos)", coincideConTabla tableroB tablaB)
  , ("Tablero B: dos caminos empatan en el maximo (24)",
      length (filter (== 24) (map finalDeFila tablaB)) == 2)
  , ("Tablero B: el desempate por saltos elige [0,1,2,4] con 24",
      optimoDe tableroB == ([0, 1, 2, 4], 24))
  , ("Tablero B: evalua 7 caminos",                    rEvaluados (resolver tableroB) == 7)
  , ("t2: meta en el indice 3",                        calcularMeta t2 == 3)
  , ("t2: Regla del Vacio aplicada",                   vacioAplicado t2 3)
  , ("t2: tabla a mano = programa (4 caminos)",        coincideConTabla t2 tablaT2)
  , ("t2: Zafiro en [0,1,2,3] por las negativas -3 y -4",
      puntajeReglaZafiro (puntuarCamino t2 [0, 1, 2, 3]) == 5)
  , ("t2: el optimo [0,1,3] tiene bruto 0 y gana Eter (0 es par)",
      optimoDe t2 == ([0, 1, 3], 10)
        && puntajeBruto (puntajeOptimoDe t2) == 0
        && puntajeReglaEter (puntajeOptimoDe t2) == 10)
  , ("t2: evalua 4 caminos",                           rEvaluados (resolver t2) == 4)
  ]

ejecutarPruebasCaminos :: IO ()
ejecutarPruebasCaminos = mapM_ mostrar pruebasCaminos
  where
    mostrar (nombre, ok) = putStrLn ((if ok then "[OK]    " else "[FALLO] ") ++ nombre)
