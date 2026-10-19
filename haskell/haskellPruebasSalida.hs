-- PRUEBAS DE SALIDA E INTEGRACION (P4)
-- Comprueban el JSON escrito a mano y el flujo completo de resolver
-- (meta -> caminos -> puntaje -> optimo) sobre todos los tableros:
-- el ejemplo del enunciado, los 3 tableros propios (A, B, C) y t1, t2, t3.
-- Los tableros van como literales para no chocar con los nombres que
-- usa cada persona en sus propios archivos de pruebas.

-- Texto esperado para el ejemplo de la seccion 4.2 del enunciado.
jsonEsperadoEnunciado :: String
jsonEsperadoEnunciado = unlines
  [ "{"
  , "  \"tablero\": [2, -1, -3, 5, 0],"
  , "  \"casilla_meta\": 3,"
  , "  \"regla_vacio_aplicada\": true,"
  , "  \"camino_optimo\": [0, 1, 3],"
  , "  \"puntaje_bruto\": 6,"
  , "  \"penalizacion_zafiro\": 0,"
  , "  \"bono_eter\": 10,"
  , "  \"puntaje_final\": 16,"
  , "  \"caminos_evaluados\": 4"
  , "}"
  ]

-- (nombre, tablero, meta, vacio, camino optimo, puntaje, caminos evaluados)
-- A, B y C: valores de autocomprobacion de la division del trabajo.
-- t2 y t3: los saca el programa; su tabla a mano la justifican P2 y P3.
type CasoIntegracion = (String, Tablero, Int, Bool, Camino, Puntaje, Int)

casosIntegracion :: [CasoIntegracion]
casosIntegracion =
  [ ("Enunciado", [2, -1, -3, 5, 0],   3, True,  [0, 1, 3],          Puntaje 6 0 10 16, 4)
  , ("A",         [4, -1, 2, 0, 0],    2, True,  [0, 2],             Puntaje 6 0 10 16, 2)
  , ("B",         [-5, 7, 4, 0, 8],    4, False, [0, 1, 2, 4],       Puntaje 14 0 10 24, 7)
  , ("C",         [9, 4, -3, -3, -6],  4, False, [0, 1, 2, 4],       Puntaje 4 5 10 9, 7)
  , ("t1",        [3, -2, -1, 4, 2],   4, False, [0, 2, 3, 4],       Puntaje 8 0 10 18, 7)
  , ("t2",        [1, -3, -4, 2, 0],   3, True,  [0, 1, 3],          Puntaje 0 0 10 10, 4)
  , ("t3",        [5, 5, 5, 5, 5, 5],  5, False, [0, 1, 2, 3, 4, 5], Puntaje 30 0 10 40, 13)
  ]

-- El Resultado que deberia armar resolver para un caso.
resultadoEsperado :: CasoIntegracion -> Resultado
resultadoEsperado (_, t, meta, vacio, camino, puntaje, evaluados) =
  Resultado t meta vacio camino puntaje evaluados

-- Una prueba por caso: resolver devuelve exactamente lo esperado.
pruebaResolver :: CasoIntegracion -> (String, Bool)
pruebaResolver caso@(nombre, t, _, _, _, _, _) =
  ("resolver " ++ nombre ++ " = valores esperados", resolver t == resultadoEsperado caso)

-- Caminos (con su puntaje final) que empatan con el maximo del tablero.
empatadosEnMaximo :: Tablero -> [Camino]
empatadosEnMaximo t = [ c | (c, f) <- finales, f == maximo ]
  where
    finales = [ (c, puntajeFinal (puntuarCamino t c)) | c <- generarCaminos (calcularMeta t) ]
    maximo  = maximum (map snd finales)

-- True si hubo empate en el maximo y el optimo tiene MENOS saltos que
-- todos los demas empatados (primer desempate).
desempatePorSaltos :: Tablero -> Bool
desempatePorSaltos t =
  length empatados > 1 && all (\c -> length c > length optimo) (filter (/= optimo) empatados)
  where
    empatados = empatadosEnMaximo t
    optimo    = rCamino (resolver t)

-- True si el optimo empata con otro camino del MISMO numero de saltos y
-- gana por ser menor lexicograficamente (segundo desempate).
desempateLexicografico :: Tablero -> Bool
desempateLexicografico t =
  not (null rivales) && all (optimo <) rivales
  where
    optimo  = rCamino (resolver t)
    rivales = [ c | c <- empatadosEnMaximo t, c /= optimo, length c == length optimo ]

-- True si el primer texto aparece dentro del segundo.
estaEn :: String -> String -> Bool
estaEn buscado texto = any (comienzaCon buscado) (colas texto)
  where
    comienzaCon :: String -> String -> Bool
    comienzaCon a b = take (length a) b == a
    colas :: String -> [String]
    colas [] = [[]]
    colas t@(_ : resto) = t : colas resto

-- Pruebas de P4: (descripcion, paso la prueba?).
pruebasSalida :: [(String, Bool)]
pruebasSalida =
  [ ("listaAJson con negativos",        listaAJson [2, -1, 3] == "[2, -1, 3]")
  , ("listaAJson de lista vacia",       listaAJson [] == "[]")
  , ("boolAJson en minuscula",          boolAJson True == "true" && boolAJson False == "false")
  , ("JSON del enunciado: texto exacto",
       resultadoAJson (resolver [2, -1, -3, 5, 0]) == jsonEsperadoEnunciado)
  , ("JSON: 9 claves en el orden pedido",
       map fst (camposJson (resolver [3, -2, -1, 4, 2])) ==
         [ "tablero", "casilla_meta", "regla_vacio_aplicada", "camino_optimo"
         , "puntaje_bruto", "penalizacion_zafiro", "bono_eter", "puntaje_final"
         , "caminos_evaluados" ])
  , ("rutaLegible de 1, 2 y 4+ casillas",
       rutaLegible [0] == "1" && rutaLegible [0, 3] == "1 y 4"
         && rutaLegible [0, 1, 3] == "1, 2 y 4")
  , ("Resumen de consola con meta, ruta y conteo",
       all (`estaEn` resumenConsola (resolver [3, -2, -1, 4, 2]))
         [ "Meta: casilla 5", "casillas 1, 3, 4 y 5", "Caminos evaluados: 7" ])
  ] ++ map pruebaResolver casosIntegracion ++
  [ ("Cobertura: Regla del Vacio (A)",       rVacio (resolver [4, -1, 2, 0, 0]))
  , ("Cobertura: Zafiro en el optimo (C)",   puntajeReglaZafiro (rPuntaje (resolver [9, 4, -3, -3, -6])) > 0)
  , ("Cobertura: Eter en el optimo (t1)",    puntajeReglaEter (rPuntaje (resolver [3, -2, -1, 4, 2])) == 10)
  , ("Cobertura: empate por saltos (B)",     desempatePorSaltos [-5, 7, 4, 0, 8])
  , ("Cobertura: empate lexicografico (C)",  desempateLexicografico [9, 4, -3, -3, -6])
  ]

ejecutarPruebasSalida :: IO ()
ejecutarPruebasSalida = mapM_ mostrar pruebasSalida
  where
    mostrar :: (String, Bool) -> IO ()
    mostrar (nombre, ok) = putStrLn ((if ok then "[OK]    " else "[FALLO] ") ++ nombre)
