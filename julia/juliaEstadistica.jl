
# Estadistica de las casillas y grafico de barras en texto.
# Para correr las pruebas de este archivo:   julia juliaEstadistica.jl


using Statistics   # trae mean, median y std (media, mediana, desviacion estandar)



struct Resultado
    tablero::Vector{Int}
    casillaMeta::Int
    reglaVacioAplicada::Bool
    caminoOptimo::Vector{Int}
    puntajeBruto::Int
    penalizacionZafiro::Int
    bono_eter::Int
    puntajeFinal::Int
    caminosEvaluados::Int
end

#
# tablero[1:n] significa "dame de la primera a la n-esima casilla".
# Como casillaMeta empieza en 0, la meta esta en la posicion casillaMeta + 1.

function casillas_en_juego(res)
    return res.tablero[1:res.casillaMeta + 1]
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
        estado = estado_casilla(i, res.caminoOptimo, res.casillaMeta)
        texto_estado = replace(String(estado), "_" => " ")

        println(rpad("casilla $i", 11),
                lpad(string(valor), 4), "  ",
                rpad(barra, LARGO_MAXIMO_BARRA + 1),
                texto_estado)
    end
end

