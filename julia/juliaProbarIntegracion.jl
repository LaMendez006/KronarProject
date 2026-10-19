# Pruebas de integracion de P4 (Julia).
# Ejecutar desde la raiz del repositorio:  julia julia/juliaProbarIntegracion.jl
#
# 1) Pruebas puntuales de formatear_ruta.
# 2) Prueba cruzada Haskell vs Julia: los JSON de julia/pruebas/ los genero
#    Kronar.hs (t1, t2, t3, A, B, C); Julia recalcula y debe coincidir.
# 3) Un JSON alterado a mano debe detectarse en la verificacion.
# 4) Archivos danados o inexistentes: main termina limpio con codigo 1.

include(joinpath(@__DIR__, "integracion.jl"))

const CARPETA_PRUEBAS = joinpath(@__DIR__, "pruebas")
const CARPETA_ERRORES = joinpath(@__DIR__, "errores")

aprobadas = 0
fallidas  = 0

# Registra e imprime el resultado de una prueba.
function anotar(nombre::String, ok::Bool)
    global aprobadas, fallidas
    ok ? (aprobadas += 1) : (fallidas += 1)
    println(ok ? "[OK]    " : "[FALLO] ", nombre)
end

# Ejecuta f sin mostrar lo que imprime (para no ensuciar la salida).
function en_silencio(f)
    ruta, io = mktemp()
    try
        return redirect_stdout(f, io)
    finally
        close(io)
        rm(ruta; force = true)
    end
end

println("=== 1) formatear_ruta ===")
anotar("una casilla: [0] -> \"1\"",         formatear_ruta([0]) == "1")
anotar("dos casillas: [0,3] -> \"1 y 4\"",  formatear_ruta([0, 3]) == "1 y 4")
anotar("tres: [0,1,3] -> \"1, 2 y 4\"",     formatear_ruta([0, 1, 3]) == "1, 2 y 4")

println("\n=== 2) Prueba cruzada Haskell vs Julia ===")
for nombre in ["t1", "t2", "t3", "tableroA", "tableroB", "tableroC"]
    res = leerResultado(joinpath(CARPETA_PRUEBAS, nombre * ".json"))
    if res isa ErrorLectura
        anotar("$nombre: lectura (" * res.mensaje * ")", false)
        continue
    end
    calc = calcular_puntaje(res.tablero, res.camino_optimo)
    iguales = (calc.bruto, calc.zafiro, calc.eter, calc.final) ==
              (res.puntaje_bruto, res.penalizacion_zafiro, res.bono_eter, res.puntaje_final)
    anotar("$nombre: Julia recalcula lo mismo que Haskell", iguales)
    anotar("$nombre: main termina con codigo 0",
           en_silencio(() -> main([joinpath(CARPETA_PRUEBAS, nombre * ".json")])) == 0)
end

println("\n=== 3) JSON alterado (puntaje_final 18 -> 25) ===")
alterado = leerResultado(joinpath(CARPETA_PRUEBAS, "t1Alterado.json"))
anotar("se lee bien (el formato es valido)", alterado isa Resultado)
if alterado isa Resultado
    println("  Lo que muestra la verificacion:")
    anotar("verificar_puntaje detecta la diferencia", verificar_puntaje(alterado) == false)
end

println("\n=== 4) Archivos danados: main termina limpio con codigo 1 ===")
for archivo in ["sinClave.json", "tipoEquivocado.json", "truncado.json", "vacio.json", "noExiste.json"]
    ruta = joinpath(CARPETA_ERRORES, archivo)
    leido = leerResultado(ruta)
    if leido isa ErrorLectura
        println("  ", archivo, ": ", leido.mensaje)
    end
    anotar("$archivo: mensaje claro y codigo 1",
           leido isa ErrorLectura && en_silencio(() -> main([ruta])) == 1)
end

println("\nResumen: $aprobadas de $(aprobadas + fallidas) pruebas pasaron.")
exit(fallidas == 0 ? 0 : 1)
