import Data.List (minimumBy)

-- === CAMINOS ===

-- Saltos permitidos de Dravek (evita numeros magicos).
saltosValidos :: [Int]
saltosValidos = [1, 2, 3]

-- Todos los caminos que van de actual hasta meta (empezando desde 0).
-- Caso base: ya estamos en la meta.
-- Caso recursivo: probamos cada salto que no se pase de la meta y anteponemos la posicion actual a cada camino que sale del destino.
caminosDesde :: Int -> Int -> [Camino]
caminosDesde meta actual
  | actual == meta = [[meta]]
  | otherwise =
      [ actual : resto
      | s     <- saltosValidos
      , actual + s <= meta          -- nunca se pasa de la meta
      , resto <- caminosDesde meta (actual + s)
      ]

-- Todos los caminos de la casilla 0 a la meta.
generarCaminos :: Int -> [Camino]
generarCaminos meta = caminosDesde meta 0

-- Orden total donde "menor" = "mejor candidato":
-- 1) mayor puntaje final, 2) menos saltos, 3) menor lexicografico.
compararCandidatos :: (Camino, Puntaje) -> (Camino, Puntaje) -> Ordering
compararCandidatos (c1, p1) (c2, p2) =
     compare (pFinal p2) (pFinal p1)      -- invertido: mayor puntaje primero
  <> compare (length c1) (length c2)      -- menos saltos
  <> compare c1 c2                        -- orden de diccionario

-- Elige el mejor. Como el orden es total no hay empates reales,
-- asi que no importa que minimumBy devuelva el primero.
elegirOptimo :: [(Camino, Puntaje)] -> (Camino, Puntaje)
elegirOptimo = minimumBy compararCandidatos