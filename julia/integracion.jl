# integracion.jl - Programa principal de la Parte 2 (Julia)
#
# Cada persona mantiene su seccion en su propio archivo; este archivo
# las incluye en orden y solo agrega main. Unico medio de comunicacion
# con Haskell: el archivo resultado.json.
#
# Ejecutar desde la raiz del repositorio (despues de correr Haskell):
#   julia julia/integracion.jl                     (lee ./resultado.json)
#   julia julia/integracion.jl otra/ruta.json      (lee otro archivo)

# === SECCION 1: TIPOS, LECTURA Y VALIDACION DEL JSON (P1) ===
include(joinpath(@__DIR__, "juliaLectura.jl"))

# === SECCION 2: REGLAS, VERIFICACION Y PORCENTAJES (P2) ===
# (define a_base1, que usa el reporte de P4)
include(joinpath(@__DIR__, "juliaReglasVerificacion.jl"))

# === SECCION 3: ESTADISTICA Y GRAFICO DE BARRAS (P3) ===
include(joinpath(@__DIR__, "juliaEstadistica.jl"))

# === SECCION 4: REPORTE COMUN (P4) ===
include(joinpath(@__DIR__, "juliaReporte.jl"))

# === PROGRAMA PRINCIPAL (P4) ===

const RUTA_POR_DEFECTO = "resultado.json"

# Titulo de cada bloque del reporte.
titulo(texto::String) = println("\n=== ", texto, " ===")

# Orden de salida: lectura (P1) -> reporte comun (P4) -> estadisticas (P3)
# -> grafico (P3) -> verificacion (P2) -> porcentajes (P2).
# Devuelve el codigo de salida: 0 si todo salio bien, 1 si no se pudo
# leer el archivo o hubo un error inesperado. Nunca lanza excepciones.
function main(args::Vector{String} = ARGS)::Int
    ruta = isempty(args) ? RUTA_POR_DEFECTO : args[1]

    res = leerResultado(ruta)
    if res isa ErrorLectura
        println("No se pudo usar el archivo '", ruta, "':")
        println("  ", res.mensaje)
        return 1
    end

    try
        println("Archivo leido y validado: ", ruta, "\n")
        reporte_comun(res)

        titulo("Analisis estadistico")
        imprimir_estadisticas(res)

        titulo("Grafico de barras (▇ positivo, ░ negativo)")
        grafico_barras(res)

        titulo("Verificacion del puntaje (recalculado en Julia)")
        verificar_puntaje(res)

        titulo("Aporte de cada casilla visitada al puntaje bruto")
        porcentaje_por_casilla(res)
        return 0
    catch e
        # Red de seguridad: un error inesperado se informa, no tumba el programa.
        println("\nError inesperado al generar el reporte: ", sprint(showerror, e))
        return 1
    end
end

# Solo se ejecuta main cuando se corre este archivo directamente
# (no cuando otro archivo, como las pruebas, lo incluye).
if abspath(PROGRAM_FILE) == @__FILE__
    exit(main(ARGS))
end
