# KronarProject


. Reglas del juego
------------------------------------------------------
2.1 Cómo se mueve Dravek

1.	Dravek comienza en la casilla 1 y recoge su piedra. La casilla inicial siempre cuenta.

2.	En cada turno avanza 1, 2 o 3 casillas. No puede retroceder ni quedarse en el mismo lugar.

3.	Recoge la piedra de cada casilla en la que aterriza. Las casillas que salta no cuentan en absoluto.

4.	Debe aterrizar exactamente en la casilla meta. No se permite un salto que la sobrepase.
Llamamos camino a la lista ordenada de casillas en las que aterriza Dravek, desde la casilla 1 hasta la meta, ambas incluidas.

-----------------------------------------------
2.2 La Regla del Vacío

Esta regla decide dónde termina el juego. Dravek no puede terminar en una casilla cuyo valor es 0.


•	Si la casilla n tiene un valor distinto de 0, la meta es la casilla n.

•	Si la casilla n es 0, la meta pasa a ser la casilla n menos 1. Si esa también es 0, sigue retrocediendo hasta encontrar la última casilla con un valor distinto de 0.

•	Las casillas posteriores a la meta están fuera de juego: nadie aterriza en ellas y no afectan el resultado.

•	Decimos que la regla fue aplicada cuando la meta terminó siendo una casilla distinta de la casilla n.
------------------------------------------------------

2.3 La Regla del Zafiro

Cada vez que Dravek aterriza en dos casillas consecutivas de su camino y ambas tienen un valor negativo, pierde 5 puntos por doble contaminación.

•	La penalización se cuenta por cada par. Tres casillas negativas seguidas forman dos pares, por lo que restan 10 puntos.

•	Consecutivas significa consecutivas dentro del camino, no una al lado de la otra en el tablero. Si Dravek salta de la casilla 2 (valor -1) a la casilla 4 (valor -3), la regla igualmente se aplica.

•	El cero no se considera negativo.
------------------------------------------------
2.4 La Regla del Éter

Si el puntaje bruto del camino, es decir, la suma de las piedras recogidas sin bonos ni penalizaciones, es un número par, Dravek gana 10 puntos extra. El cero y los números pares negativos también cuentan como pares.
---------------------------------------------------------
2.5 Puntaje de un camino

Juntando todo, el puntaje de un camino se calcula así:

puntaje final = puntaje bruto - penalización Zafiro + bono Éter