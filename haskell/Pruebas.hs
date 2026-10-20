{-# LANGUAGE CPP #-}
-- Las pruebas no llaman a todo lo que se incluye (p. ej. escribirResultado,
-- que solo usa main de Kronar.hs); por eso se apaga solo ese aviso aqui.
{-# OPTIONS_GHC -Wno-unused-top-binds #-}
------------------------------------------------------------
-- Pruebas.hs - Pruebas de la Parte 1 (Haskell)
--
-- Igual que Kronar.hs, une con #include las secciones de cada persona
-- y sus archivos de pruebas (con las tablas de caminos hechas a mano),
-- y agrega un main que corre todo y resume cuantas pruebas pasaron.
--
-- Ejecutar desde la raiz del repositorio:
--   runghc haskell/Pruebas.hs
------------------------------------------------------------

import System.Exit (ExitCode (ExitFailure), exitWith)

-- haskellCaminos.hs va primero porque empieza con un import.
#include "haskellCaminos.hs"
#include "haskellReglas.hs"
#include "haskellEntrada.hs"
#include "haskellSalida.hs"

-- === PRUEBAS DE P1: tablero A y t1 con su tabla a mano ===
#include "haskellPruebasEntrada.hs"

-- === PRUEBAS DE P2: tablero B y t2 con su tabla a mano ===
#include "haskellPruebasCaminos.hs"

-- === PRUEBAS DE P3: tablero C y t3 con su tabla a mano ===
#include "haskellPruebasReglas.hs"

-- === PRUEBAS DE P4: JSON, flujo completo y cobertura de reglas ===
#include "haskellPruebasSalida.hs"

-- Todas las pruebas del proyecto.
todasLasPruebas :: [(String, Bool)]
todasLasPruebas = pruebasEntrada ++ pruebasCaminos ++ pruebasReglas ++ pruebasSalida

main :: IO ()
main = do
  putStrLn "=== Pruebas de entrada (P1) ==="
  ejecutarPruebasEntrada
  putStrLn ""
  putStrLn "=== Pruebas de caminos y optimo (P2) ==="
  ejecutarPruebasCaminos
  putStrLn ""
  putStrLn "=== Pruebas de reglas (P3) ==="
  ejecutarPruebasReglas
  putStrLn ""
  putStrLn "=== Pruebas de salida e integracion (P4) ==="
  ejecutarPruebasSalida
  putStrLn ""
  let fallidas = length (filter (not . snd) todasLasPruebas)
  putStrLn ("Resumen: " ++ show (length todasLasPruebas - fallidas) ++ " de "
            ++ show (length todasLasPruebas) ++ " pruebas pasaron.")
  if fallidas > 0 then exitWith (ExitFailure 1) else return ()
