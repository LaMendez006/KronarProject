## Requisitos e Instalación

| Herramienta | Versión probada | Cómo comprobarla |
|---|---|---|
| GHC (Haskell) | 9.10.3 | `ghc --version` |
| Julia | 1.12.7 | `julia --version` |

- **Haskell:** solo se usa lo que trae GHC (Prelude, Data.List, System.Environment, System.Exit). No hay que instalar paquetes.
- **Julia:** no hay que instalar paquetes. El archivo `resultado.json` se lee con un lector JSON propio incluido en `integracion.jl`.

## Cómo ejecutar Haskell

Desde la raíz del repositorio:

```bash
# Con el tablero por defecto (t1 = [3, -2, -1, 4, 2])
runghc haskell/Kronar.hs

# Con un tablero propio (números separados por espacios)
runghc haskell/Kronar.hs 3 -2 -1 4 2
```

Para cambiar el tablero por defecto sin argumentos, edita `tableroPorDefecto` en el bloque marcado como
`UNICO LUGAR EDITABLE DEL TABLERO` de `haskell/Kronar.hs`. Si se pasan argumentos, estos tienen prioridad.

### Errores esperados

Con un tablero inválido el programa imprime el motivo, termina con código de error 1 y **no crea** `resultado.json`.

| Entrada | Mensaje |
|---|---|
| `runghc haskell/Kronar.hs 5` | `Se recibio 1 casilla; el minimo es 2` |
| 16 números | `Se recibieron 16 casillas; el maximo es 15` |
| `runghc haskell/Kronar.hs 0 0 0` | `Las 3 casillas valen 0; debe haber al menos una distinta de 0` |
| `runghc haskell/Kronar.hs 3 x 1` | `El argumento 'x' no es un numero entero` |