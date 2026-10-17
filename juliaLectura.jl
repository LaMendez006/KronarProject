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
    
struct ErrorLectura
    mensaje::String
end
