% =====================================================================
%  Logic.pl  -  Reglas de gramatica BNF y de inferencia logica
%  Tarea #3  -  Paradigmas de Programacion (CE3104) -  TEC 2026-1S
% ---------------------------------------------------------------------
%  Este archivo contiene UNICAMENTE las reglas:
%   1) De la gramatica libre de contexto (Sintagma Nominal,
%      Sintagma Verbal y Sintagma Adverbial), implementadas con la
%      tecnica de listas diferenciadas presentada en el Ejemplo 6.2
%      del libro de Monferrer, Toledo & Pacheco (2001), capitulo 6.
%   2) De inferencia: deducir polaridad (afirmativo / negativo) y
%      tema de una oracion analizada, e interpretarla.
%   3) De puntuacion de profesiones a partir de las preferencias.
%
%  Depende de BD.pl (debe ser consultado primero por BNF.pl).
%
%  Gramatica BNF (forma Backus-Naur, libro pag. 71-72):
%
%   <oracion>            ::= <sintagma_nominal> <sintagma_verbal>
%                          | <sintagma_verbal>
%                          | <sintagma_adverbial>
%
%   <sintagma_nominal>   ::= <pronombre>
%                          | <determinante> <nombre>
%                          | <determinante> <adjetivo> <nombre>
%                          | <nombre>
%
%   <sintagma_verbal>    ::= <verbo>
%                          | <verbo> <sintagma_nominal>
%                          | <verbo> <adverbio>
%                          | <verbo> <adverbio> <sintagma_nominal>
%                          | <adverbio> <verbo>
%                          | <adverbio> <verbo> <sintagma_nominal>
%                          | <verbo> <verbo>
%                          | <verbo> <adverbio> <verbo>
%                          | <verbo> <preposicion> <sintagma_nominal>
%                          | <verbo> <adverbio> <preposicion> <sintagma_nominal>
%                          | <verbo> <preposicion> <verbo> <sintagma_nominal>
%                          | <verbo> <adverbio> <preposicion> <verbo> <sintagma_nominal>
%
%   <sintagma_adverbial> ::= <adverbio>
%                          | <adverbio> <adverbio>
% =====================================================================


% ---------------------------------------------------------------------
%   1) GRAMATICA: estilo del Ejemplo 6.2 del libro (listas diferenciadas)
%   Cada predicado toma una lista de entrada S0 y devuelve S = el resto
%   no consumido. La oracion es valida si oracion(L,[]) tiene exito.
% ---------------------------------------------------------------------

% --- adverbio cualquiera (uniformiza afirmativo / negativo / neutro) -
adverbio(A) :- adverbio_afirm(A).
adverbio(A) :- adverbio_neg(A).
adverbio(A) :- adverbio_neutro(A).

% --- verbo cualquiera (uniformiza gusto / disgusto / neutro / topico) -
verbo(V) :- verbo_gusto(V).
verbo(V) :- verbo_disgusto(V).
verbo(V) :- verbo_neutro(V).
verbo(V) :- verbo_topico(V, _).

% --- nombre cualquiera ---------------------------------------------
es_nombre(N) :- nombre(N, _).


% --------------------- Sintagma Nominal ----------------------------
%  Cuatro reglas, en orden de mayor a menor longitud para favorecer
%  el reconocimiento de SN largos.

sintagma_nominal([P|S], S) :-
    pronombre(P).

sintagma_nominal([D, A, N | S], S) :-
    determinante(D),
    adjetivo(A),
    es_nombre(N).

sintagma_nominal([D, N | S], S) :-
    determinante(D),
    es_nombre(N).

sintagma_nominal([N|S], S) :-
    es_nombre(N).


% --------------------- Sintagma Verbal -----------------------------
%  Las reglas se ordenan de mas larga a mas corta para que el parser
%  consuma siempre el SV de mayor cobertura cuando hay ambiguedad.

% V Adv Prep V SN  -> "disfruto mucho de resolver problemas"
sintagma_verbal([V1, A, P, V2 | S0], S) :-
    verbo(V1), adverbio(A), preposicion(P), verbo(V2),
    sintagma_nominal(S0, S).

% V Prep V SN
sintagma_verbal([V1, P, V2 | S0], S) :-
    verbo(V1), preposicion(P), verbo(V2),
    sintagma_nominal(S0, S).

% V Adv Prep SN    -> "intereso mucho por las personas"
sintagma_verbal([V, A, P | S0], S) :-
    verbo(V), adverbio(A), preposicion(P),
    sintagma_nominal(S0, S).

% V Prep SN
sintagma_verbal([V, P | S0], S) :-
    verbo(V), preposicion(P),
    sintagma_nominal(S0, S).

% V Adv V          -> "disfruto mucho resolver"
sintagma_verbal([V1, A, V2 | S], S) :-
    verbo(V1), adverbio(A), verbo(V2).

% V V              -> "prefiero escuchar"
sintagma_verbal([V1, V2 | S], S) :-
    verbo(V1), verbo(V2).

% Adv V SN
sintagma_verbal([A, V | S0], S) :-
    adverbio(A), verbo(V),
    sintagma_nominal(S0, S).

% V Adv SN
sintagma_verbal([V, A | S0], S) :-
    verbo(V), adverbio(A),
    sintagma_nominal(S0, S).

% V SN             -> "amo las matematicas"
sintagma_verbal([V | S0], S) :-
    verbo(V),
    sintagma_nominal(S0, S).

% Adv V
sintagma_verbal([A, V | S], S) :-
    adverbio(A), verbo(V).

% V Adv
sintagma_verbal([V, A | S], S) :-
    verbo(V), adverbio(A).

% V solo
sintagma_verbal([V | S], S) :-
    verbo(V).


% ----------------- Sintagma Adverbial ------------------------------
%  Para respuestas tipo "no mucho", "si claro", "no".

sintagma_adverbial([A1, A2 | S], S) :-
    adverbio(A1), adverbio(A2).

sintagma_adverbial([A | S], S) :-
    adverbio(A).


% ------------------------- Oracion ---------------------------------
%  Una oracion completa puede ser SN+SV, solo SV, o solo SA.

oracion(S0, S) :-
    sintagma_nominal(S0, S1),
    sintagma_verbal(S1, S).

oracion(S0, S) :-
    sintagma_verbal(S0, S).

oracion(S0, S) :-
    sintagma_adverbial(S0, S).


% ---------------------------------------------------------------------
%   2) BUSQUEDA DEL MEJOR PARSEO
%   El usuario envia una lista de tokens que puede contener "ruido"
%   (saludos, palabras desconocidas). Buscamos el sub-segmento mas
%   largo que sea una <oracion> valida.
% ---------------------------------------------------------------------

% sufijos(L, Sufijo) genera, por backtracking, todos los sufijos de L
% (incluyendo L mismo y la lista vacia).
sufijos(L, L).
sufijos([_|T], S) :- sufijos(T, S).

% longitud_consumida(S0, S, N) calcula cuantos elementos de S0 fueron
% consumidos para llegar a S.
longitud_consumida(S0, S, N) :-
    length(S0, L0), length(S, L1), N is L0 - L1.

% mejor_parseo(Tokens, Estructura, Consumido)
% Devuelve el parseo (estructura + cantidad consumida) que cubre la
% mayor cantidad de tokens. Si ningun sub-segmento parsea, falla.
mejor_parseo(Tokens, Estructura, MaxCons) :-
    findall(Cons-(S0,Resto),
            ( sufijos(Tokens, S0),
              oracion(S0, Resto),
              longitud_consumida(S0, Resto, Cons),
              Cons > 0 ),
            Lista),
    Lista \= [],
    sort(0, @>=, Lista, [MaxCons-(SInicial,RestoFinal)|_]),
    Estructura = parse(SInicial, RestoFinal).


% ---------------------------------------------------------------------
%   3) INFERENCIA DE POLARIDAD Y TEMA
% ---------------------------------------------------------------------

% --- Polaridad de una palabra individual ---------------------------
polaridad_palabra(W, negativo) :- adverbio_neg(W).
polaridad_palabra(W, negativo) :- verbo_disgusto(W).
polaridad_palabra(W, afirmativo) :- verbo_gusto(W).
polaridad_palabra(W, afirmativo) :- adverbio_afirm(W).

% --- Polaridad de una lista de palabras ----------------------------
%  Regla: si aparece CUALQUIER palabra negativa, la polaridad es
%  negativa (los marcadores de rechazo dominan). Si no, basta con
%  encontrar una palabra afirmativa para concluir afirmativo. Si no
%  hay ninguna, la polaridad es desconocida.
hay_negativo([W|_]) :- polaridad_palabra(W, negativo), !.
hay_negativo([_|T]) :- hay_negativo(T).

hay_afirmativo([W|_]) :- polaridad_palabra(W, afirmativo), !.
hay_afirmativo([_|T]) :- hay_afirmativo(T).

polaridad(Tokens, negativo)    :- hay_negativo(Tokens), !.
polaridad(Tokens, afirmativo)  :- hay_afirmativo(Tokens), !.
polaridad(_,      desconocido).


% --- Tema (topico) de una palabra individual ------------------------
tema_palabra(W, T) :- nombre(W, T).
tema_palabra(W, T) :- verbo_topico(W, T).

% --- Tema de la lista (toma el primero que aparezca) ----------------
tema([W|_], T) :- tema_palabra(W, T), !.
tema([_|R], T) :- tema(R, T).
% si no hay ningun nombre/verbo_topico, tema/2 falla (usar con catch)
tema_o_ninguno(L, T) :- tema(L, T), !.
tema_o_ninguno(_, ninguno).


% ---------------------------------------------------------------------
%   4) INTERPRETAR UNA RESPUESTA DEL USUARIO
%
%   interpretar(+Tokens, -Polaridad, -Tema, -Estado)
%
%   Estado puede ser:
%      ok           : se entendio la respuesta
%      no_entendido : no se pudo extraer una intencion clara
%
%   Heuristica especial replicando el ejemplo 2 de la tarea:
%   si la oracion es UNICAMENTE adverbial (SA) y es afirmativa,
%   pero no menciona el tema esperado, se considera ambigua y se
%   pide repetir. ("Si mucho" -> "Me puedes repetir no entendi.")
%   En cambio "No mucho" si se acepta porque el rechazo es claro.
% ---------------------------------------------------------------------

interpretar(Tokens, Pol, Tema, ok) :-
    mejor_parseo(Tokens, _, _),
    polaridad(Tokens, Pol),
    Pol \= desconocido,
    tema_o_ninguno(Tokens, Tema),
    \+ caso_ambiguo(Tokens, Pol, Tema), !.

interpretar(_, _, _, no_entendido).

% caso_ambiguo: oracion solo adverbial afirmativa sin tema -> repetir.
caso_ambiguo(Tokens, afirmativo, ninguno) :-
    es_solo_adverbial(Tokens).

% Una lista es "solo adverbial" si todos sus elementos son adverbios.
es_solo_adverbial([]).
es_solo_adverbial([W|R]) :- adverbio(W), es_solo_adverbial(R).


% ---------------------------------------------------------------------
%   5) PUNTUACION DE PROFESIONES
%   Regla:
%     +2  si el tema es afinidad y la respuesta fue afirmativa.
%     +2  si el tema es antagonia y la respuesta fue negativa.
%     -2  si el tema es afinidad y la respuesta fue negativa.
%     -2  si el tema es antagonia y la respuesta fue afirmativa.
%      0  si el tema no aparece en ninguna lista.
% ---------------------------------------------------------------------

% miembro/2 (estilo libro pag. 1075)
miembro(X, [X|_]).
miembro(X, [_|R]) :- miembro(X, R).

aporte(Tema, afirmativo, Afin, _Antag,  2) :- miembro(Tema, Afin),  !.
aporte(Tema, afirmativo, _Afin, Antag, -2) :- miembro(Tema, Antag), !.
aporte(Tema, negativo,   _Afin, Antag,  2) :- miembro(Tema, Antag), !.
aporte(Tema, negativo,   Afin, _Antag, -2) :- miembro(Tema, Afin),  !.
aporte(_, _, _, _, 0).

% puntuar(Preferencias, Afin, Antag, Score)
% Preferencias = [ pref(Tema, Polaridad), pref(Tema, Polaridad), ... ]
puntuar([], _, _, 0).
puntuar([pref(T, P) | R], Afin, Antag, Score) :-
    aporte(T, P, Afin, Antag, A),
    puntuar(R, Afin, Antag, RestoScore),
    Score is A + RestoScore.

% mejor_profesion(+Preferencias, -Nombre, -Score)
% Recorre todas las profesiones, calcula su score y devuelve la de
% mayor puntaje.
mejor_profesion(Prefs, MejorNombre, MejorScore) :-
    findall(S-N,
            ( profesion(N, Afin, Antag),
              puntuar(Prefs, Afin, Antag, S) ),
            Lista),
    sort(0, @>=, Lista, [MejorScore-MejorNombre | _]).


% ---------------------------------------------------------------------
%   6) TERMINACION TEMPRANA
%   todos_cubiertos/2 verifica que cada tema de una lista tenga una
%   preferencia registrada en Prefs.
%   profesion_cubierta/2 tiene exito cuando la mejor profesion ya
%   tiene todas sus afinidades y antagonias cubiertas por las prefs.
% ---------------------------------------------------------------------

todos_cubiertos([], _).
todos_cubiertos([T | Resto], Prefs) :-
    miembro(pref(T, _), Prefs),
    todos_cubiertos(Resto, Prefs).

profesion_cubierta(Prefs, Nombre) :-
    mejor_profesion(Prefs, Nombre, _),
    profesion(Nombre, Afin, Antag),
    todos_cubiertos(Afin, Prefs),
    todos_cubiertos(Antag, Prefs).


% =====================================================================
%   FIN DE Logic.pl
% =====================================================================
