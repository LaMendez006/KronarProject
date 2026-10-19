# === SECCION 4: REPORTE COMUN (P4) ===
# No define tipos ni lee archivos: usa el tipo Resultado de P1
# (juliaLectura.jl) y a_base1 de P2 (juliaReglasVerificacion.jl), que
# integracion.jl incluye antes que este archivo.
#
# Recordatorio de indices: el JSON trae posiciones desde 0; el reporte
# para personas numera las casillas desde 1. La conversion se hace solo
# con a_base1 (unico punto de conversion del equipo).

# Une textos al estilo "1, 2 y 4" (o "1 y 4", o "1").
function unir_con_y(partes::Vector{String})::String
    n = length(partes)
    n == 0 && return "(ninguna)"
    n == 1 && return partes[1]
    return join(partes[1:end-1], ", ") * " y " * partes[end]
end

# Posiciones desde 0 -> texto de ruta desde 1.  [0, 1, 3] -> "1, 2 y 4"
function formatear_ruta(camino::Vector{Int})::String
    return unir_con_y(string.(a_base1(camino)))
end

# "casilla" o "casillas" segun la cantidad.
palabra_casilla(n::Int)::String = n == 1 ? "casilla" : "casillas"

# Dos filas alineadas: numero de casilla (desde 1) y su valor.
function imprimir_tablero(tablero::Vector{Int})
    ancho = 1 + maximum(length.(string.(vcat(tablero, length(tablero)))))
    println("  Casilla: ", join(lpad.(string.(1:length(tablero)), ancho)))
    println("  Valor:   ", join(lpad.(string.(tablero), ancho)))
end

# Meta (casilla N) y aviso de si se aplico la Regla del Vacio.
function imprimir_meta(res::Resultado)
    meta1 = res.casilla_meta + 1                  # desde 1, para personas
    n = length(res.tablero)
    print("Meta: casilla $meta1 (indice $(res.casilla_meta)). ")
    if res.regla_vacio_aplicada
        fuera = collect(res.casilla_meta + 1 : n - 1)   # posiciones desde 0
        println("Regla del Vacio: APLICADA (fuera de juego: ",
                palabra_casilla(length(fuera)), " ", formatear_ruta(fuera), ").")
    else
        println("Regla del Vacio: no aplicada (la meta es la ultima casilla).")
    end
    # Coherencia: la bandera debe valer true exactamente cuando la meta
    # no es la ultima casilla. Si no coincide, se avisa (no se corrige).
    if res.regla_vacio_aplicada != (res.casilla_meta != n - 1)
        println("  AVISO: regla_vacio_aplicada = $(res.regla_vacio_aplicada) no ",
                "coincide con la meta (casilla $meta1 de $n).")
    end
end

# Antepone el signo con que el valor entra en la formula; el 0 va solo.
con_signo(signo::String, valor::Int)::String = valor == 0 ? "0" : signo * string(valor)

# Una fila del desglose con etiqueta y valor alineados.
fila_desglose(etiqueta::String, valor::String) =
    println("  ", rpad(etiqueta, 21), ": ", lpad(valor, 5))

# Reporte comun pedido en la seccion 5.1 del enunciado. Muestra los
# valores TAL COMO VIENEN en el JSON; la verificacion la hace P2 aparte.
function reporte_comun(res::Resultado)
    println("=== Reporte de la partida ===")
    println("Tablero (", length(res.tablero), " casillas, numeradas desde 1):")
    imprimir_tablero(res.tablero)
    imprimir_meta(res)
    println("Ruta optima: ", palabra_casilla(length(res.camino_optimo)), " ",
            formatear_ruta(res.camino_optimo),
            "  (", length(res.camino_optimo) - 1, " saltos)")
    println("Desglose del puntaje (final = bruto - Zafiro + Eter):")
    fila_desglose("Puntaje bruto",       string(res.puntaje_bruto))
    fila_desglose("Penalizacion Zafiro", con_signo("-", res.penalizacion_zafiro))
    fila_desglose("Bono Eter",           con_signo("+", res.bono_eter))
    fila_desglose("Puntaje final",       string(res.puntaje_final))
    println("Caminos evaluados por Haskell: ", res.caminos_evaluados)
end
