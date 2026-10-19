# === SECCION: REGLAS Y VERIFICACION ===

# UNICO punto de conversion base 0 (JSON) -> base 1 (Julia).
a_base1(v::Vector{Int})::Vector{Int} = v .+ 1

# Suma de los valores de las casillas visitadas (la inicial siempre cuenta).
puntaje_bruto(tablero::Vector{Int}, camino::Vector{Int})::Int =
    sum(tablero[a_base1(camino)])

# 5 puntos por cada par consecutivo DEL CAMINO con ambos valores < 0.
# El 0 no es negativo. Tres negativos seguidos = 2 pares = 10 puntos.
function penalizacion_zafiro(tablero::Vector{Int}, camino::Vector{Int})::Int
    vals = tablero[a_base1(camino)]
    pares = count(i -> vals[i] < 0 && vals[i+1] < 0, 1:length(vals)-1)
    return 5 * pares
end

# 10 si el bruto es par (0 y negativos incluidos); si no, 0.
# Se calcula sobre el bruto, ANTES de restar la penalizacion.
bono_eter(bruto::Int)::Int = iseven(bruto) ? 10 : 0

# Puntaje completo de un camino: final = bruto - zafiro + eter.
function calcular_puntaje(tablero::Vector{Int}, camino::Vector{Int})
    b = puntaje_bruto(tablero, camino)
    z = penalizacion_zafiro(tablero, camino)
    e = bono_eter(b)
    return (bruto = b, zafiro = z, eter = e, final = b - z + e)
end

# Recalcula con el camino del JSON y compara los 4 campos.
# No copia valores del JSON: solo los compara con lo recalculado.
function verificar_puntaje(res::Resultado)::Bool
    calc = calcular_puntaje(res.tablero, res.camino_optimo)
    campos = [
        ("puntaje_bruto",       res.puntaje_bruto,       calc.bruto),
        ("penalizacion_zafiro", res.penalizacion_zafiro, calc.zafiro),
        ("bono_eter",           res.bono_eter,          calc.eter),
        ("puntaje_final",       res.puntaje_final,       calc.final),
    ]
    ok = true
    for (nombre, json, julia) in campos
        if json != julia
            ok = false
            println("  $nombre: el JSON dice $json, Julia calcula $julia, diferencia $(json - julia)")
        end
    end
    ok && println("Verificacion OK: el puntaje del JSON coincide con el recalculado.")
    return ok
end

# Porcentaje del bruto que aporta cada casilla visitada (numeradas desde 1).
# Pueden salir negativos o mayores a 100.
function porcentaje_por_casilla(res::Resultado)
    bruto = puntaje_bruto(res.tablero, res.camino_optimo)   # recalculado, no copiado
    if bruto == 0
        println("El puntaje bruto es 0: no se pueden calcular porcentajes.")
        return
    end
    for pos in res.camino_optimo
        valor = res.tablero[pos + 1]
        pct = valor / bruto * 100
        println("Casilla $(pos + 1): valor $valor -> $(round(pct, digits = 1)) %")
    end
end