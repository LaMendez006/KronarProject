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

validarTablero :: Tablero -> Either String Tablero 
validarTablero t 
    | n  < minCasillas = Left ("Se recibio " ++ cantidadCasillas n ++ "; el minimo es " ++show minCasillas)
    | n > maxCasillas = Left ("Se recibieron " ++ cantidadCasillas n ++ ";  el maximo es " ++ show maxCasillas)
    | otherwise               = Right t
    where n = length t

cantidadCasillas :: Int -> String
cantidadCasillas 1 = "1 casilla"
cantidadCasillas n = show n ++ " casillas"