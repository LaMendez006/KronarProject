struct Resultado
   
    tablero::Vector{Int}
    casilla_meta::Int
    regla_vacio_aplicada::Bool
    camino_optimo::Vector{Int}
    puntaje_bruto::Int
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


#Validacion de claves, tipos y rangos

esEntero(x) = !(x isa Bool) && x isa Integer

#Describe lo que se encontró, para el "se encontró Y" de los mensajes.

function describirValor(v)::String
    if v isa Bool
        return "booleano ($v)"
    elseif v isa Integer
        return "entero ($v)"
    elseif v isa AbstractFloat
        return "decimal ($v)"
    elseif v isa AbstractString
        return "texto (\"$v\")"
    elseif v isa AbstractVector
        return "lista"
    elseif v isa AbstractDict
        return "objeto"
    elseif v === nothing
        return "nulo"
    else
        return string(typeof(v))
    end
end

mensajeTipo(clave, esperado, encontrado) =
    "Clave '$clave': se esperaba $esperado, se encontró $(describirValor(encontrado))"

#Valor de la clave, o ErrorLectura si la clave no existe
function extraerValor(datos, clave::String, esperado::String)
    haskey(datos, clave) && return datos[clave]
    return ErrorLectura("Clave '$clave': se esperaba $esperado, se encontró que la clave no existe")
end

function extraerEntero(datos, clave::String)
    valor = extraerValor(datos, clave, "entero")
    valor isa ErrorLectura && return valor
    esEntero(valor) || return ErrorLectura(mensajeTipo(clave, "entero", valor))
    return Int(valor)
end

function extraerBooleano(datos, clave::String)
    valor = extraerValor(datos, clave, "booleano")
    valor isa ErrorLectura && return valor
    valor isa Bool || return ErrorLectura(mensajeTipo(clave, "booleano", valor))
    return valor
end

function extraerListaEnteros(datos, clave::String)
    valor = extraerValor(datos, clave, "lista de enteros")
    valor isa ErrorLectura && return valor
    valor isa AbstractVector || return ErrorLectura(mensajeTipo(clave, "lista de enteros", valor))
    for (i, elemento) in enumerate(valor)
        esEntero(elemento) || return ErrorLectura(
            "Clave '$clave': se esperaba lista de enteros, se encontró " *
            "$(describirValor(elemento)) en el elemento $i de la lista")
    end
    return Int[Int(x) for x in valor]
end

#Las 9 claves, con el nombre exacto y en el orden del enunciado
const EXTRACTORES = [
    "tablero"              => extraerListaEnteros,
    "casilla_meta"         => extraerEntero,
    "regla_vacio_aplicada" => extraerBooleano,
    "camino_optimo"        => extraerListaEnteros,
    "puntaje_bruto"        => extraerEntero,
    "penalizacion_zafiro"  => extraerEntero,
    "bono_eter"            => extraerEntero,
    "puntaje_final"        => extraerEntero,
    "caminos_evaluados"    => extraerEntero,
]

#Comprueba los rangos de valores ya tipados. nothing = todo bien
function validarRangos(v::Dict{String,Any})::Union{Nothing,ErrorLectura}
    n = length(v["tablero"])
    n >= 1 || return ErrorLectura(
        "Clave 'tablero': se esperaba al menos 1 casilla, se encontró una lista vacía")
    ultimo = n - 1  

    meta = v["casilla_meta"]
    (0 <= meta <= ultimo) || return ErrorLectura(
        "Clave 'casilla_meta': se esperaba un entero entre 0 y $ultimo, se encontró $meta")

    camino = v["camino_optimo"]
    isempty(camino) && return ErrorLectura(
        "Clave 'camino_optimo': se esperaba al menos una posición, se encontró una lista vacía")
    for (i, posicion) in enumerate(camino)
        (0 <= posicion <= ultimo) || return ErrorLectura(
            "Clave 'camino_optimo': se esperaban posiciones entre 0 y $ultimo, " *
            "se encontró $posicion en el elemento $i de la lista")
    end

    zafiro = v["penalizacion_zafiro"]
    zafiro >= 0 || return ErrorLectura(
        "Clave 'penalizacion_zafiro': se esperaba un entero mayor o igual a 0, se encontró $zafiro")

    eter = v["bono_eter"]
    eter in (0, 10) || return ErrorLectura(
        "Clave 'bono_eter': se esperaba 0 o 10, se encontró $eter")

    return nothing
end

#Convierte lo que salió del parser en un Resultado, o explica qué falla
function validarEstructura(datos)::Union{Resultado,ErrorLectura}
    datos isa AbstractDict || return ErrorLectura(
        "El archivo: se esperaba un objeto JSON con 9 claves, se encontró $(describirValor(datos))")

    valores = Dict{String,Any}()
    for (clave, extractor) in EXTRACTORES
        valor = extractor(datos, clave)
        valor isa ErrorLectura && return valor
        valores[clave] = valor
    end

    problema = validarRangos(valores)
    problema === nothing || return problema

    return Resultado(
        valores["tablero"],
        valores["casilla_meta"],
        valores["regla_vacio_aplicada"],
        valores["camino_optimo"],
        valores["puntaje_bruto"],
        valores["penalizacion_zafiro"],
        valores["bono_eter"],
        valores["puntaje_final"],
        valores["caminos_evaluados"],
    )
end

#Lectura del archivo

mensajeDe(e::ErrorException) = e.msg
mensajeDe(e) = sprint(showerror, e)

#Texto del archivo, o ErrorLectura si no existe o no se puede abrir
function leerTexto(ruta::AbstractString)::Union{String,ErrorLectura}
    if !isfile(ruta)
        return ErrorLectura("No se encontró el archivo '$ruta'. " *
                            "Ejecuta primero el programa de Haskell para generarlo.")
    end
    try
        return read(ruta, String)
    catch e
        return ErrorLectura("No se pudo abrir '$ruta': " * mensajeDe(e))
    end
end

#Lee y valida resultado.json
#Resultado o un ErrorLectura con el motivo
function leerResultado(ruta::AbstractString)::Union{Resultado,ErrorLectura}
    try
        texto = leerTexto(ruta)
        texto isa ErrorLectura && return texto
        if isempty(strip(texto))
            return ErrorLectura("El archivo '$ruta' está dañado: está vacío.")
        end
        datos = try
            parsearJSON(texto)
        catch e
            return ErrorLectura("El archivo '$ruta' está dañado: " * mensajeDe(e))
        end
        return validarEstructura(datos)
    catch e
        #Red de seguridad: ningún error inesperado debe tumbar el programa
        return ErrorLectura("Error inesperado al leer '$ruta': " * mensajeDe(e))
    end
end