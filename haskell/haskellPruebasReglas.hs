-- PRUEBAS DE REGLAS (P3): TABLERO C Y t3
-- Cada fila de las tablas es (camino desde 0, bruto, zafiro, eter, final).
-- En las listas de Haskell el Zafiro va en positivo (es lo que se resta);
-- en los comentarios aparece con el signo con que entra en la formula.
-- Formula: final = bruto - Zafiro + Eter.


-- TABLERO C = [9, 4, -3, -3, -6]
--   La casilla 5 vale -6 (no es 0), asi que la meta es la casilla 5
--   (indice 4). Regla del Vacio aplicada: NO. Hay 7 caminos:
--
--   Camino (desde 1) | Valores          | Bruto | Zafiro | Eter | Final
--   1, 2, 3, 4, 5    | 9, 4, -3, -3, -6 |     1 |    -10 |    0 |    -9
--   1, 2, 3, 5       | 9, 4, -3, -6     |     4 |     -5 |  +10 |     9
--   1, 2, 4, 5       | 9, 4, -3, -6     |     4 |     -5 |  +10 |     9
--   1, 2, 5          | 9, 4, -6         |     7 |      0 |    0 |     7
--   1, 3, 4, 5       | 9, -3, -3, -6    |    -3 |    -10 |    0 |   -13
--   1, 3, 5          | 9, -3, -6        |     0 |     -5 |  +10 |     5
--   1, 4, 5          | 9, -3, -6        |     0 |     -5 |  +10 |     5
--
--   Zafiro: se cuenta por pares consecutivos DEL CAMINO. 1,2,3,4,5 pisa
--   las tres negativas seguidas (-3, -3, -6): dos pares = -10. Los caminos
--   1,2,3,5 y 1,2,4,5 pisan una sola negativa del medio y la -6: un par =
--   -5. En 1,3,5 y 1,4,5 el par es (-3, -6): -5. En 1,3,4,5 son tres
--   negativas seguidas: -10. En 1,2,5 solo hay una negativa: 0.
--   Eter: se mira sobre el bruto, antes de restar el Zafiro. Bruto 4 y 0
--   son pares (+10); 1, 7 y -3 son impares (0).
--   Zafiro en el optimo: el camino ganador 1,2,3,5 pierde 5 por el par
--   (-3, -6) y aun asi gana, porque su bruto 4 es par y suma +10.
--   Empate: los caminos 1,2,3,5 y 1,2,4,5 dan 9. Criterio 1 (mayor final):
--   empatan. Criterio 2 (menos saltos): los dos tienen 4 casillas (3
--   saltos), empatan. Criterio 3 (orden lexicografico, como un
--   diccionario): [0,1,2,4] contra [0,1,3,4]: iguales en 0 y 1, y en la
--   tercera posicion 2 < 3, asi que gana [0,1,2,4].
--   Optimo: 1, 2, 3 y 5 (indices [0,1,2,4]) con 9 puntos.
tableroC :: Tablero
tableroC = [9, 4, -3, -3, -6]

tablaC :: [(Camino, Int, Int, Int, Int)]
tablaC =
  [ ([0, 1, 2, 3, 4], 1, 10, 0, -9)
  , ([0, 1, 2, 4], 4, 5, 10, 9)
  , ([0, 1, 3, 4], 4, 5, 10, 9)
  , ([0, 1, 4], 7, 0, 0, 7)
  , ([0, 2, 3, 4], -3, 10, 0, -13)
  , ([0, 2, 4], 0, 5, 10, 5)
  , ([0, 3, 4], 0, 5, 10, 5)
  ]


-- TABLERO t3 = [5, 5, 5, 5, 5, 5]  (tablero oficial)
--   La casilla 6 vale 5 (no es 0), asi que la meta es la casilla 6
--   (indice 5). Regla del Vacio aplicada: NO. Hay 13 caminos (cada
--   cantidad de caminos es la suma de las tres anteriores:
--   1, 1, 2, 4, 7, 13):
--
--   Camino (desde 1) | Valores          | Bruto | Zafiro | Eter | Final
--   1, 2, 3, 4, 5, 6 | 5, 5, 5, 5, 5, 5 |    30 |      0 |  +10 |    40
--   1, 2, 3, 4, 6    | 5, 5, 5, 5, 5    |    25 |      0 |    0 |    25
--   1, 2, 3, 5, 6    | 5, 5, 5, 5, 5    |    25 |      0 |    0 |    25
--   1, 2, 3, 6       | 5, 5, 5, 5       |    20 |      0 |  +10 |    30
--   1, 2, 4, 5, 6    | 5, 5, 5, 5, 5    |    25 |      0 |    0 |    25
--   1, 2, 4, 6       | 5, 5, 5, 5       |    20 |      0 |  +10 |    30
--   1, 2, 5, 6       | 5, 5, 5, 5       |    20 |      0 |  +10 |    30
--   1, 3, 4, 5, 6    | 5, 5, 5, 5, 5    |    25 |      0 |    0 |    25
--   1, 3, 4, 6       | 5, 5, 5, 5       |    20 |      0 |  +10 |    30
--   1, 3, 5, 6       | 5, 5, 5, 5       |    20 |      0 |  +10 |    30
--   1, 3, 6          | 5, 5, 5          |    15 |      0 |    0 |    15
--   1, 4, 5, 6       | 5, 5, 5, 5       |    20 |      0 |  +10 |    30
--   1, 4, 6          | 5, 5, 5          |    15 |      0 |    0 |    15
--
--   Zafiro: no hay casillas negativas, asi que es 0 en los 13 caminos.
--   Eter: todas las piedras valen 5, asi que el bruto es 5 por la cantidad
--   de casillas del camino. Es par solo si el camino pisa un numero par de
--   casillas (4 o 6): +10. Con 3 o 5 casillas el bruto es impar: 0.
--   Optimo: el camino que pisa las 6 casillas, 1,2,3,4,5 y 6 (indices
--   [0,1,2,3,4,5]), con bruto 30 + Eter 10 = 40. Es el unico con 40: los
--   de 4 casillas dan 20 + 10 = 30 y los de 5 casillas dan 25 sin bono.
--   No hay empate en el maximo.
t3 :: Tablero
t3 = [5, 5, 5, 5, 5, 5]

tablaT3 :: [(Camino, Int, Int, Int, Int)]
tablaT3 =
  [ ([0, 1, 2, 3, 4, 5], 30, 0, 10, 40)
  , ([0, 1, 2, 3, 5], 25, 0, 0, 25)
  , ([0, 1, 2, 4, 5], 25, 0, 0, 25)
  , ([0, 1, 2, 5], 20, 0, 10, 30)
  , ([0, 1, 3, 4, 5], 25, 0, 0, 25)
  , ([0, 1, 3, 5], 20, 0, 10, 30)
  , ([0, 1, 4, 5], 20, 0, 10, 30)
  , ([0, 2, 3, 4, 5], 25, 0, 0, 25)
  , ([0, 2, 3, 5], 20, 0, 10, 30)
  , ([0, 2, 4, 5], 20, 0, 10, 30)
  , ([0, 2, 5], 15, 0, 0, 15)
  , ([0, 3, 4, 5], 20, 0, 10, 30)
  , ([0, 3, 5], 15, 0, 0, 15)
  ]


-- Pruebas de reglas: (descripcion, paso la prueba?).
pruebasReglas :: [(String, Bool)]
pruebasReglas =
  [ ("Tablero C: meta en el indice 4",                 calcularMeta tableroC == 4)
  , ("Tablero C: Regla del Vacio no aplicada",         not (vacioAplicado tableroC 4))
  , ("Tablero C: tabla a mano = programa (7 caminos)", coincideConTabla tableroC tablaC)
  , ("Tablero C: tres negativas seguidas restan 10 (dos pares)",
      puntajeReglaZafiro (puntuarCamino tableroC [0, 1, 2, 3, 4]) == 10)
  , ("Tablero C: Zafiro y Eter en el optimo",
      puntajeOptimoDe tableroC == Puntaje 4 5 10 9)
  , ("Tablero C: dos caminos empatan en el maximo (9)",
      length (filter (== 9) (map finalDeFila tablaC)) == 2)
  , ("Tablero C: el empate lo decide el orden lexicografico: [0,1,2,4]",
      optimoDe tableroC == ([0, 1, 2, 4], 9))
  , ("t3: meta en el indice 5, Vacio no aplicado",
      calcularMeta t3 == 5 && not (vacioAplicado t3 5))
  , ("t3: tabla a mano = programa (13 caminos)",       coincideConTabla t3 tablaT3)
  , ("t3: sin negativas, Zafiro es 0 en todos los caminos",
      all (\(_, _, z, _, _) -> z == 0) tablaT3)
  , ("t3: Eter solo en los caminos de cantidad par de casillas",
      and [ (e == 10) == even (length c) | (c, _, _, e, _) <- tablaT3 ])
  , ("t3: unico optimo, el camino de las 6 casillas con 40",
      optimoDe t3 == ([0, 1, 2, 3, 4, 5], 40) && length (filter (== 40) (map finalDeFila tablaT3)) == 1)
  , ("t3: evalua 13 caminos",                          rEvaluados (resolver t3) == 13)
  ]

ejecutarPruebasReglas :: IO ()
ejecutarPruebasReglas = mapM_ mostrar pruebasReglas
  where
    mostrar (nombre, ok) = putStrLn ((if ok then "[OK]    " else "[FALLO] ") ++ nombre)
