type Tablero = [Int]


tableroPorDefecto :: Tablero
tableroPorDefecto = [3, -2, -1, 4, 2]

minCasillas :: Int
minCasillas = 2

maxCasillas :: Int
maxCasillas = 15


leerTablero :: [String] -> Either String Tablero
leerTablero [] = Right tableroPorDefecto
leerTablero args = mapM leerEntero args

leerEntero :: String -> Either String Int
leerEntero texto =
    case reads texto of
        [(n, "")] -> Right n
        _         -> Left ("El argumento '" ++ texto ++ "' no es un número entero")
