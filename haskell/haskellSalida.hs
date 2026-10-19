-- === SECCION 4: SALIDA, JSON Y ORQUESTACION (P4) ===
-- Este archivo no tiene main ni imports: Kronar.hs lo incluye junto con
-- las secciones de P1 (haskellEntrada.hs), P2 (haskellCaminos.hs) y
-- P3 (haskellReglas.hs). Usa los tipos compartidos Tablero, Camino,
-- Puntaje y Resultado tal como los definio P3.

-- Nombre del archivo que lee el programa de Julia.
archivoResultado :: FilePath
archivoResultado = "resultado.json"

------------------------------------------------------------
-- Utilidades de texto
------------------------------------------------------------

-- Une textos poniendo un separador entre ellos (como intercalate,
-- escrito a mano para no depender de otro import).
unirCon :: String -> [String] -> String
unirCon _   []       = ""
unirCon _   [x]      = x
unirCon sep (x : xs) = x ++ sep ++ unirCon sep xs

-- Rellena con espacios a la izquierda hasta el ancho pedido.
alinearDerecha :: Int -> String -> String
alinearDerecha ancho texto = replicate (ancho - length texto) ' ' ++ texto

-- Rellena con espacios a la derecha hasta el ancho pedido.
alinearIzquierda :: Int -> String -> String
alinearIzquierda ancho texto = texto ++ replicate (ancho - length texto) ' '

------------------------------------------------------------
-- JSON escrito a mano (sin librerias)
------------------------------------------------------------

-- [2, -1, 3]. show maneja bien los negativos.
listaAJson :: [Int] -> String
listaAJson xs = "[" ++ unirCon ", " (map show xs) ++ "]"

-- Trampa: show True da "True"; el JSON exige true/false en minuscula.
boolAJson :: Bool -> String
boolAJson True  = "true"
boolAJson False = "false"

-- Las 9 claves con su valor ya convertido a texto JSON.
-- El ORDEN de esta lista es el orden exigido por el enunciado (4.2).
camposJson :: Resultado -> [(String, String)]
camposJson r =
  [ ("tablero",              listaAJson (rTablero r))
  , ("casilla_meta",         show (rMeta r))
  , ("regla_vacio_aplicada", boolAJson (rVacio r))
  , ("camino_optimo",        listaAJson (rCamino r))
  , ("puntaje_bruto",        show (puntajeBruto p))
  , ("penalizacion_zafiro",  show (puntajeReglaZafiro p))
  , ("bono_eter",            show (puntajeReglaEter p))
  , ("puntaje_final",        show (puntajeFinal p))
  , ("caminos_evaluados",    show (rEvaluados r))
  ]
  where p = rPuntaje r

-- Una linea del objeto:   "clave": valor
lineaJson :: (String, String) -> String
lineaJson (clave, valor) = "  \"" ++ clave ++ "\": " ++ valor

-- Texto exacto de resultado.json (mismo formato que la seccion 4.2).
resultadoAJson :: Resultado -> String
resultadoAJson r =
  "{\n" ++ unirCon ",\n" (map lineaJson (camposJson r)) ++ "\n}\n"

-- Escribe el JSON en la ruta indicada.
escribirResultado :: FilePath -> Resultado -> IO ()
escribirResultado ruta r = writeFile ruta (resultadoAJson r)

------------------------------------------------------------
-- Orquestacion: meta (P1) -> caminos (P2) -> puntaje (P3) -> optimo (P2)
------------------------------------------------------------

-- Resuelve un tablero YA VALIDADO. caminos_evaluados es el largo de la
-- lista completa de caminos generados (no de una lista filtrada).
resolver :: Tablero -> Resultado
resolver t = Resultado
  { rTablero   = t
  , rMeta      = meta
  , rVacio     = vacioAplicado t meta
  , rCamino    = camino
  , rPuntaje   = puntaje
  , rEvaluados = length caminos
  }
  where
    meta              = calcularMeta t
    caminos           = generarCaminos meta
    candidatos        = [ (c, puntuarCamino t c) | c <- caminos ]
    (camino, puntaje) = elegirOptimo candidatos

------------------------------------------------------------
-- Resumen en consola (para personas: casillas numeradas desde 1)
------------------------------------------------------------

-- Posiciones desde 0 -> texto de ruta desde 1: "1, 3, 4 y 5".
rutaLegible :: Camino -> String
rutaLegible camino = case map (show . (+ 1)) camino of
  []  -> "(vacio)"
  [x] -> x
  xs  -> unirCon ", " (init xs) ++ " y " ++ last xs

-- Dos filas alineadas: numero de casilla (desde 1) y su valor.
filasTablero :: Tablero -> [String]
filasTablero t =
  [ "  Casilla: " ++ concatMap (alinearDerecha ancho . show) [1 .. length t]
  , "  Valor:   " ++ concatMap (alinearDerecha ancho . show) t
  ]
  where ancho = 1 + maximum (map (length . show) (length t : t))

-- Texto de la meta con el aviso de la Regla del Vacio.
lineaMeta :: Resultado -> String
lineaMeta r
  | rVacio r  = base ++ "Regla del Vacio: APLICADA (fuera de juego: "
                     ++ palabraCasilla (length fuera) ++ " " ++ rutaLegible fuera ++ ")."
  | otherwise = base ++ "Regla del Vacio: no aplicada (la meta es la ultima casilla)."
  where
    fuera = [rMeta r + 1 .. length (rTablero r) - 1]   -- posiciones desde 0
    base  = "Meta: casilla " ++ show (rMeta r + 1)
            ++ " (indice " ++ show (rMeta r) ++ "). "

-- "casilla" o "casillas" segun la cantidad.
palabraCasilla :: Int -> String
palabraCasilla 1 = "casilla"
palabraCasilla _ = "casillas"

-- Una fila del desglose: etiqueta alineada y valor alineado.
filaDesglose :: String -> String -> String
filaDesglose etiqueta valor =
  "  " ++ alinearIzquierda 21 etiqueta ++ ": " ++ alinearDerecha 5 valor

-- Desglose del puntaje con el signo con que entra en la formula.
filasDesglose :: Puntaje -> [String]
filasDesglose p =
  [ filaDesglose "Puntaje bruto"       (show (puntajeBruto p))
  , filaDesglose "Penalizacion Zafiro" (conSigno "-" (puntajeReglaZafiro p))
  , filaDesglose "Bono Eter"           (conSigno "+" (puntajeReglaEter p))
  , filaDesglose "Puntaje final"       (show (puntajeFinal p))
  ]

-- Antepone el signo con que el valor entra en la formula; el 0 va solo.
conSigno :: String -> Int -> String
conSigno _     0 = "0"
conSigno signo n = signo ++ show n

-- Resumen completo que se imprime al terminar.
resumenConsola :: Resultado -> String
resumenConsola r = unlines $
  [ "=== Kronar: resultado ==="
  , "Tablero (" ++ show (length (rTablero r)) ++ " casillas, numeradas desde 1):"
  ] ++ filasTablero (rTablero r) ++
  [ lineaMeta r
  , "Camino optimo: casillas " ++ rutaLegible (rCamino r)
      ++ "  (indices desde 0: " ++ listaAJson (rCamino r) ++ ")"
  , "Desglose del puntaje (final = bruto - Zafiro + Eter):"
  ] ++ filasDesglose (rPuntaje r) ++
  [ "Caminos evaluados: " ++ show (rEvaluados r) ]
