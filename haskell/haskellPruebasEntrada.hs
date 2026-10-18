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