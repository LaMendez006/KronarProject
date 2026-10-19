# Estadistica de las casillas y grafico de barras en texto.
# Para correr las pruebas de este archivo:   julia juliaEstadistica.jl


using Statistics   # trae mean, median y std (media, mediana, desviacion estandar)



# El tipo Resultado NO se define aqui: lo define P1 en juliaLectura.jl.
# (Si se define dos veces, Julia da error al juntar los archivos.)
# Campos que usamos, con los nombres de P1 (empiezan en 0 los que vienen del JSON):
#   res.tablero, res.casilla_meta, res.camino_optimo

#
# tablero[1:n] significa "dame de la primera a la n-esima casilla".
# Como casilla_meta empieza en 0, la meta esta en la posicion casilla_meta + 1.

function casillas_en_juego(res)
    return res.tablero[1:res.casilla_meta + 1]
end


function estadisticas(valores)
    if length(valores) > 1
        desviacion = std(valores)
    else
        desviacion = 0.0
    end

    return (
        media          = mean(valores),
        mediana        = median(valores),
        desviacion     = desviacion,
        maximo         = maximum(valores),
        minimo         = minimum(valores),
        casilla_maximo = argmax(valores),
        casilla_minimo = argmin(valores),
    )
end


function conteo_signos(valores)
    return (
        positivas = count(x -> x > 0, valores),
        negativas = count(x -> x < 0, valores),
        vacias    = count(x -> x == 0, valores),
    )
end


function imprimir_estadisticas(res)
    valores = casillas_en_juego(res)
    e = estadisticas(valores)
    c = conteo_signos(valores)

    println("=== Estadisticas (solo casillas en juego: ", length(valores), ") ===")
    println("Media:               ", round(e.media; digits = 2))
    println("Mediana:             ", e.mediana)
    println("Desviacion estandar: ", round(e.desviacion; digits = 2), "  (muestral, n-1)")
    println("Maximo: ", e.maximo, " en la casilla ", e.casilla_maximo)
    println("Minimo: ", e.minimo, " en la casilla ", e.casilla_minimo)
    println("Piedras positivas: ", c.positivas,
            " | negativas: ", c.negativas,
            " | vacias: ", c.vacias)
end

function estado_casilla(i, camino, meta)
    posicion = i - 1                  # de "empieza en 1" a "empieza en 0"

    if posicion > meta
        return :fuera_de_juego        # esta despues de la meta
    elseif posicion in camino
        return :visitada              # Dravek aterrizo aqui
    else
        return :saltada               # Dravek la salto
    end
end


const LARGO_MAXIMO_BARRA = 20

function grafico_barras(res)
    tablero = res.tablero

    # --- Escala: ¿hace falta achicar las barras? ---
    mayor = maximum(abs.(tablero))        # el valor absoluto mas grande
    if mayor > LARGO_MAXIMO_BARRA
        factor = LARGO_MAXIMO_BARRA / mayor    # ej: mayor = 40 -> factor = 0.5
    else
        factor = 1.0                           # no hace falta achicar
    end

    # --- Una linea por cada casilla ---
    for i in 1:length(tablero)
        valor = tablero[i]

        # largo de la barra (entero). Si el valor no es 0, minimo 1 caracter.
        largo = round(Int, abs(valor) * factor)
        if valor == 0
            barra = ""
        else
            marca = valor > 0 ? "▇" : "░"          # positivo o negativo
            barra = marca^max(largo, 1)            # repetir la marca "largo" veces
        end

        # estado de la casilla, escrito con espacios en vez de "_"
        estado = estado_casilla(i, res.camino_optimo, res.casilla_meta)
        texto_estado = replace(String(estado), "_" => " ")

        println(rpad("casilla $i", 11),
                lpad(string(valor), 4), "  ",
                rpad(barra, LARGO_MAXIMO_BARRA + 1),
                texto_estado)
    end
end

#######################################################
# PRUEBAS (cada una dice que debe salir)
#######################################################
# Resultado( tablero, casilla_meta, regla_vacio_aplicada, camino_optimo,
#            puntaje_bruto, penalizacion_zafiro, bono_eter, puntaje_final, caminos_evaluados )

function probar_parte3()
    # ---- Tablero C: [9, 4, -3, -3, -6]  (camino de ejemplo [0,1,2,4]) ----
    tableroC = Resultado([9, 4, -3, -3, -6], 4, false, [0, 1, 2, 4], 4, 5, 10, 9, 7)
    println("##### TABLERO C #####")
    imprimir_estadisticas(tableroC)
    # Esperado: Media 0.2 | Mediana -3 | Desviacion 6.14
    #           Maximo: 9 en la casilla 1 | Minimo: -6 en la casilla 5
    #           Piedras positivas: 2 | negativas: 3 | vacias: 0
    println()
    grafico_barras(tableroC)
    # Esperado:
    #   casilla 1     9  ▇▇▇▇▇▇▇▇▇            visitada
    #   casilla 2     4  ▇▇▇▇                 visitada
    #   casilla 3    -3  ░░░                  visitada
    #   casilla 4    -3  ░░░                  saltada
    #   casilla 5    -6  ░░░░░░               visitada

    # ---- t2: [1, -3, -4, 2, 0]  (la casilla 5 queda fuera de juego) ----
    t2 = Resultado([1, -3, -4, 2, 0], 3, true, [0, 1, 3], 0, 5, 10, 5, 4)
    println("\n##### t2 (la casilla 5 debe salir 'fuera de juego') #####")
    imprimir_estadisticas(t2)
    # Esperado (solo 4 casillas en juego): Media -1.0 | Mediana -1.0 | Desviacion 2.94
    #           Maximo: 2 en la casilla 4 | Minimo: -4 en la casilla 3
    #           Piedras positivas: 2 | negativas: 2 | vacias: 0
    println()
    grafico_barras(t2)
    # Esperado:
    #   casilla 1     1  ▇                    visitada
    #   casilla 2    -3  ░░░                  visitada
    #   casilla 3    -4  ░░░░                 saltada
    #   casilla 4     2  ▇▇                   visitada
    #   casilla 5     0                       fuera de juego

    # ---- Valores grandes: la barra mas larga mide 20 ----
    grande = Resultado([30, -45, 0, 12], 3, false, [0, 3], 42, 0, 10, 52, 4)
    println("\n##### Valores grandes #####")
    grafico_barras(grande)
    # Esperado:
    #   casilla 1    30  ▇▇▇▇▇▇▇▇▇▇▇▇▇        visitada
    #   casilla 2   -45  ░░░░░░░░░░░░░░░░░░░░ saltada
    #   casilla 3     0                       saltada
    #   casilla 4    12  ▇▇▇▇▇                visitada
end

# Corre las pruebas solo si este archivo se ejecuta directamente
# (si P4 lo incluye desde integracion.jl, no se ejecutan).
# Para probar solo, necesita el tipo Resultado de P1, por eso se incluye aqui.
if abspath(PROGRAM_FILE) == @__FILE__
    include(joinpath(@__DIR__, "juliaLectura.jl"))
    probar_parte3()
end