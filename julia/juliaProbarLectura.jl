# Prueba manual: lee el ejemplo y los archivos dañados.
# Ejecutar desde la raíz del repo:  julia julia/juliaProbarLectura.jl
# @__DIR__ es la carpeta donde vive este script (julia/)
include(joinpath(@__DIR__, "juliaLectura.jl"))

const CASOS = [
    "juliaEjemploEnunciado.json",
    "errores/sinClave.json",
    "errores/tipoEquivocado.json",
    "errores/truncado.json",
    "errores/vacio.json",
    "errores/noExiste.json",   
]

for caso in CASOS
    println("== ", caso)
    r = leerResultado(normpath(joinpath(@__DIR__, caso)))
    if r isa ErrorLectura
        println("   ERROR: ", r.mensaje)
    else
        println("   OK: meta=", r.casilla_meta, ", camino=", r.camino_optimo,
                ", final=", r.puntaje_final)
    end
end