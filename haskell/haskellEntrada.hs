-- El tipo Tablero NO se define aqui: es un tipo compartido y lo define P3
-- en haskellReglas.hs. (Si se define dos veces, Kronar.hs no compila.)

-- ==========================================================
-- ===        UNICO LUGAR EDITABLE DEL TABLERO            ===
-- === Se usa cuando el programa se ejecuta sin argumentos ===
-- ==========================================================
tableroPorDefecto :: Tablero
tableroPorDefecto = [3, -2, -1, 4, 2]
-- ==========================================================

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
        _         -> Left ("El argumento '" ++ texto ++ "' no es un numero entero")

validarTablero :: Tablero -> Either String Tablero 
validarTablero t 
    | n  < minCasillas = Left ("Se recibio " ++ cantidadCasillas n ++ "; el minimo es " ++show minCasillas)
    | n > maxCasillas = Left ("Se recibieron " ++ cantidadCasillas n ++ "; el maximo es " ++ show maxCasillas)
    | all (== 0) t    = Left ("Las " ++ show n ++ " casillas valen 0; debe haber al menos una distinta de 0")
    | otherwise               = Right t
    where n = length t

cantidadCasillas :: Int -> String
cantidadCasillas 1 = "1 casilla"
cantidadCasillas n = show n ++ " casillas"

calcularMeta :: Tablero -> Int
calcularMeta t = length t - 1 - cerosFinales t

cerosFinales :: Tablero -> Int
cerosFinales = length . takeWhile (== 0) . reverse

vacioAplicado :: Tablero -> Int -> Bool
vacioAplicado t meta = meta /= length t - 1

