## Requisitos e Instalación

| Herramienta | Versión probada | Cómo comprobarla |
|---|---|---|
| GHC (Haskell) | 9.10.3 | `ghc --version` |
| Julia | 1.12.7 | `julia --version` |

- **Haskell:** solo se usa lo que trae GHC (Prelude, Data.List, System.Environment, System.Exit). No hay que instalar paquetes.
- **Julia:** no hay que instalar paquetes. El archivo `resultado.json` se lee con un lector JSON propio incluido en `integracion.jl`.