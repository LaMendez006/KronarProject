{-# LANGUAGE CPP #-}
------------------------------------------------------------
-- Kronar.hs - Programa principal de la Parte 1 (Haskell)
--
-- Cada persona mantiene su seccion en su propio archivo. Este archivo
-- las une con #include (preprocesador CPP, incluido en GHC: no es una
-- libreria externa) y solo agrega main. Asi se entrega un unico
-- Kronar.hs ejecutable sin copiar el codigo de nadie.
--
-- Ejecutar desde la raiz del repositorio:
--   runghc haskell/Kronar.hs              (usa el tablero por defecto, t1)
--   runghc haskell/Kronar.hs 3 -2 -1 4 2  (tablero por argumentos)
------------------------------------------------------------

import System.Environment (getArgs)
import System.Exit (ExitCode (ExitFailure), exitWith)

-- ORDEN IMPORTANTE: haskellCaminos.hs va primero porque empieza con
-- "import Data.List (minimumBy)", y en Haskell todos los import deben
-- quedar antes de cualquier definicion.

-- === SECCION 2: CAMINOS Y OPTIMO (P2) ===
#include "haskellCaminos.hs"

-- === SECCION 3: TIPOS COMPARTIDOS Y REGLAS (P3) ===
#include "haskellReglas.hs"

-- === SECCION 1: ENTRADA, VALIDACION Y META (P1) ===
#include "haskellEntrada.hs"

-- === SECCION 4: SALIDA, JSON Y ORQUESTACION (P4) ===
#include "haskellSalida.hs"

-- === PROGRAMA PRINCIPAL (P4) ===

-- Lee y valida el tablero (P1). Si falla: imprime el motivo, NO crea
-- resultado.json y termina con codigo 1. Si funciona: resuelve, muestra
-- el resumen y escribe resultado.json.
main :: IO ()
main = do
  args <- getArgs
  case leerTablero args >>= validarTablero of
    Left motivo -> do
      putStrLn ("Tablero invalido: " ++ motivo)
      putStrLn ("No se creo " ++ archivoResultado ++ ".")
      exitWith (ExitFailure 1)
    Right tablero -> do
      let resultado = resolver tablero
      putStr (resumenConsola resultado)
      escribirResultado archivoResultado resultado
      putStrLn ("Archivo " ++ archivoResultado ++ " creado.")
