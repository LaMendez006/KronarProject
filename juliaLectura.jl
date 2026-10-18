struct Resultado
   
    tablero::Vector{Int}
    casilla_meta::Int
    regla_vacio_aplicada::Bool
    camino_optimo::Vector{Int}
    puntaje_ruto::Int
    penalizacion_zafiro::Int
    bono_eter::Int
    puntaje_final::Int
    caminos_evaluados::Int

end
    

#Texto legible para el usuario
struct ErrorLectura
    mensaje::String
end


#Entiende objetos, listas, textos, numeros, true/false y null


mutable struct LectorJSON
    caracteres:: Vector{Char}
    pos::Int
end

const ESCAPES_JSON = Dict('n' => '\n', 't' => '\t', 'r' => '\r', 'b' => '\b', '\\' => '\\', '/' => '/', 'b' => '\b', 
                          'f' => '\f', '"' => '"', '\\' => '\\', '/' => '/')

#Carácter en la posición actual, o nothing si ya se acabó el texto
caracterActual(l::LectorJSON) = 
    l.pos <= length(l.caracteres) ? l.caracteres[l.pos] : nothing

function describirActual(l::LectorJSON) :: String
    c = caracterActual(l)
    return c === nothing ? "El final del archivo (¿está truncado?)" : "'$c'"
end

function saltarEspacios!(l::LectorJSON)
    while l.pos <= length(l.caracteres) && isspace(l.caracteres[l.pos]) 
        l.pos+=1
    end 
end


# Exige que el siguiente carácter sea c, y lo consume
function esperar!(l::LectorJSON, c::Char)
    saltarEspacios!(l)
    if caracterActual(l) != c
        error("Se esperaba '$c' en la posición $(l.pos) pero se encontró $(describirActual(l))")
    end
    l.pos += 1
end

function leerValor!(l::LectorJSON)
    saltarEspacios!(l)
    c= caracterActual(l)
    if c === nothing
        error("El archivo termina de forma inesperada (esta truncado?)")
    elseif c == '{'
        return leerObjeto!(l)
    elseif c == '['
        return leerLista!(l)
    elseif c == '"'
        return leerCadena!(l)
    elseif c == 't' || c == 'f' || c == 'n'
        return leerLiteral!(l)
    elseif c == '-' || isdigit(c)
        return leerNumero!(l)
    else
        error("Caracter inesperado '$c' en la posición $(l.pos)")
    end
end


function leerObjeto!(l::LectorJSON)
    esperar!(l, '{')
    objeto = Dict{String, Any}()
    saltarEspacios!(l)
    
    if caracterActual(l) == '}'
        l.pos += 1
        return objeto
    end
    while true
        saltarEspacios!(l)
        if caracterActual(l) != '"'
            error("Se esperaba el nombre de una clave entre comillas en la posición $(l.pos) y se encontró $(describirActual(l))")
        end
        clave = leerCadena!(l)
        esperar!(l, ':')
        objeto[clave] = leerValor!(l)
        saltarEspacios!(l)
        c= caracterActual(l)

        if c == ','
            l.pos+= 1
        elseif c == '}'
            l.pos += 1
            return objeto
        else
            error("Se esperaba ',' o '}' en la posición $(l.pos) y se encontró $(describirActual(l))")
        end
    end
end

function leerLista!(l::LectorJSON)
    esperar!(l, '[')
    lista = Any[]
    saltarEspacios!(l)
    
    if caracterActual(l) == ']'
        l.pos += 1
        return lista
    end
    while true
        push!(lista, leerValor!(l))
        saltarEspacios!(l)
        c= caracterActual(l)

        if c == ','
            l.pos+= 1
        elseif c == ']'
            l.pos += 1
            return lista
        else
            error("Se esperaba ',' o ']' en la posición $(l.pos) y se encontró $(describirActual(l))")
        end 
    end
end

function leerCadena!(l::LectorJSON)::String
    esperar!(l, '"')
    contenido = Char[]
    while true
        c= caracterActual(l)
        c === nothing && error("Un texto entre comillas no se cierra (archivo truncado)")
        l.pos += 1
        if c == '"'
            return join(contenido)
        elseif c == '\\'
            e = caracterActual(l)
            (e !== nothing && haskey(ESCAPES_JSON, e)) || 
            error("Secuencia de escape no soportada en la posicion $(l.pos)")
            push!(contenido, ESCAPES_JSON[e])
            l.pos += 1
        else
            push!(contenido, c)
        end
    end
end


#True, false o null
function leerLiteral!(l::LectorJSON)
    for (palabra, valor) in (("true", true ), ("false", false), ("null", nothing))
        fin = l.pos + length(palabra) - 1
        if fin <=length(l.caracteres) && join(l.caracteres[l.pos:fin]) == palabra
            l.pos = fin + 1
            return valor
        end
    end
    error("Palabra no reconocida en la posición $(l.pos)")
end

#Devuelve Int si el numero es entero y Float64 si trae decimales 
function leerNumero!(l::LectorJSON)
    inicio = l.pos
    while l.pos <= length(l.caracteres) && (isdigit(l.caracteres[l.pos]) || l.caracteres[l.pos] in "+-.eE")
        l.pos+= 1
        
    end

    texto = join(l.caracteres[inicio:l.pos-1])
    entero = tryparse(Int, texto)
    entero !== nothing && return entero
    decimal = tryparse(Float64, texto)
    decimal !== nothing && return decimal
    error("Numero mal formado '$texto' en la posición $inicio")
end



function parsearJSON(texto::AbstractString)
    l= LectorJSON(collect(texto), 1)
    valor = leerValor!(l)
    saltarEspacios!(l)
    if l.pos <= length(l.caracteres)
        error("Hay texto sobrante despues del JSON, en la posición $(l.pos)")
    end
    return valor
end

