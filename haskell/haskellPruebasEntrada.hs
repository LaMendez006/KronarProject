-- PRUEBAS DE ENTRADA: TABLERO A Y t1
-- Cada fila de las tablas es (camino desde 0, bruto, zafiro, eter, final).


-- TABLERO A = [4, -1, 2, 0, 0]  (prueba la Regla del Vacio)
--   Las casillas 4 y 5 valen 0, asi que la meta retrocede a la casilla 3
--   (indice 2, valor 2). Regla del Vacio aplicada: SI. Hay 2 caminos:
--
--   Camino (desde 1) | Valores    | Bruto | Zafiro | Eter        | Final
--   1, 2, 3          | 4, -1, 2   |   5   |   0    | 0 (5 impar) |   5
--   1, 3             | 4, 2       |   6   |   0    | +10 (6 par) |  16
--
--   Zafiro: en 1,2,3 los pares son (4,-1) y (-1,2); ninguno tiene los dos
--   valores negativos, asi que no se resta nada.
--   Optimo: 1, 3 (indices [0,2]) con 16 puntos. No hay empate.
tableroA :: Tablero
tableroA = [4, -1, 2, 0, 0]

tablaA :: [(Camino, Int, Int, Int, Int)]
tablaA =
  [ ([0, 1, 2], 5, 0, 0, 5)
  , ([0, 2],    6, 0, 10, 16)
  ]


-- TABLERO t1 = [3, -2, -1, 4, 2]  
--   La casilla 5 vale 2 (no es 0), asi que la meta es la casilla 5
--   (indice 4). Regla del Vacio aplicada: NO. Hay 7 caminos:
--
--   Camino (desde 1) | Valores         | Bruto | Zafiro       | Eter | Final
--   1, 2, 3, 4, 5    | 3, -2, -1, 4, 2 |   6   | -5 (-2 y -1) | +10  |  11
--   1, 2, 3, 5       | 3, -2, -1, 2    |   2   | -5 (-2 y -1) | +10  |   7
--   1, 2, 4, 5       | 3, -2, 4, 2     |   7   |  0           |  0   |   7
--   1, 2, 5          | 3, -2, 2        |   3   |  0           |  0   |   3
--   1, 3, 4, 5       | 3, -1, 4, 2     |   8   |  0           | +10  |  18
--   1, 3, 5          | 3, -1, 2        |   4   |  0           | +10  |  14
--   1, 4, 5          | 3, 4, 2         |   9   |  0           |  0   |   9
--
--   Zafiro: solo los caminos que pasan por las casillas 2 y 3 seguidas
--   (valores -2 y -1) pierden 5. Saltar de la casilla 3 a la 5 o de la 1
--   a la 3 no genera pares negativos.
--   Eter: se mira sobre el bruto, ANTES de restar el Zafiro (por eso
--   1,2,3,5 tiene bruto 2, par, y gana +10 aunque pierda 5).
--   Optimo: 1, 3, 4, 5 (indices [0,2,3,4]) con 18 puntos. No hay empate.
t1 :: Tablero
t1 = [3, -2, -1, 4, 2]

tablaT1 :: [(Camino, Int, Int, Int, Int)]
tablaT1 =
  [ ([0, 1, 2, 3, 4],  6, 5, 10, 11)
  , ([0, 1, 2, 4],     2, 5, 10,  7)
  , ([0, 1, 3, 4],     7, 0,  0,  7)
  , ([0, 1, 4],        3, 0,  0,  3)
  , ([0, 2, 3, 4],     8, 0, 10, 18)
  , ([0, 2, 4],        4, 0, 10, 14)
  , ([0, 3, 4],        9, 0,  0,  9)
  ]

-- True si el programa genera exactamente los caminos de la tabla (en
-- cualquier orden) y le da a cada uno el mismo puntaje que salio a mano.
coincideConTabla :: Tablero -> [(Camino, Int, Int, Int, Int)] -> Bool
coincideConTabla t tabla =
  mismosCaminos (generarCaminos (calcularMeta t)) (map camino tabla)
    && and [ puntuarCamino t c == Puntaje b z e f | (c, b, z, e, f) <- tabla ]
  where camino (c, _, _, _, _) = c

-- True si las dos listas tienen los mismos caminos (no importa el orden;
-- los caminos de un tablero nunca se repiten).
mismosCaminos :: [Camino] -> [Camino] -> Bool
mismosCaminos a b = length a == length b && all (`elem` b) a

-- True si el resultado de validar fue un error (Left).
esError :: Either String a -> Bool
esError (Left _) = True
esError _        = False

-- Pruebas de entrada: (descripcion, paso la prueba?).
pruebasEntrada :: [(String, Bool)]
pruebasEntrada =
  [ ("Tablero A: meta en el indice 2",         calcularMeta tableroA == 2)
  , ("Tablero A: Regla del Vacio aplicada",    vacioAplicado tableroA 2)
  , ("t1: meta en el indice 4",                calcularMeta t1 == 4)
  , ("t1: Regla del Vacio no aplicada",        not (vacioAplicado t1 4))
  , ("Rechaza 1 casilla",                      esError (validarTablero [5]))
  , ("Rechaza 16 casillas",                    esError (validarTablero [1 .. 16]))
  , ("Rechaza tablero de solo ceros",          esError (validarTablero [0, 0, 0]))
  , ("Acepta 15 casillas",                     not (esError (validarTablero (replicate 15 1))))
  , ("Rechaza argumento no entero",            esError (leerTablero ["3", "x", "1"]))
  , ("Tablero A: tabla a mano = programa",     coincideConTabla tableroA tablaA)
  , ("t1: tabla a mano = programa",            coincideConTabla t1 tablaT1)
  ]

ejecutarPruebasEntrada :: IO ()
ejecutarPruebasEntrada = mapM_ mostrar pruebasEntrada
  where
    mostrar (nombre, ok) = putStrLn ((if ok then "[OK]    " else "[FALLO] ") ++ nombre)