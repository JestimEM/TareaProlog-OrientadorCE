% =====================================================================
%  BNF.pl  -  Interfaz conversacional del Orientador Vocacional
%  Tarea #3  -  Paradigmas de Programacion (CE3104) -  TEC 2026-1S
% ---------------------------------------------------------------------
%  Este archivo contiene UNICAMENTE la interaccion entre el Usuario y
%  OrientadorCE: saludos, preguntas, lectura de la respuesta del
%  usuario en LENGUAJE NATURAL (texto libre), tokenizacion, llamada al
%  parser de Logic.pl y entrega final de la recomendacion.
%
%  El usuario escribe texto plano (sin corchetes ni puntos finales)
%  y el sistema lo tokeniza automaticamente, por ejemplo:
%
%      Usuario: Yo amo las matematicas
%      Usuario: ¿Correcto, yo soy muy habil con la tecnologia?
%
%  La idea de leer caracter por caracter y construir atomos esta
%  basada en el Ejemplo 4.5 del libro (pag. 48), que utiliza name/2
%  y put/1 para manipular cadenas como listas de codigos ASCII.
%  Aqui usamos read_line_to_string/2 + atom_string/2 que son los
%  equivalentes modernos de SWI-Prolog para el mismo principio.
% =====================================================================

:- set_prolog_flag(encoding, utf8).

:- consult('BD.pl').
:- consult('Logic.pl').


% =====================================================================
%   Punto de entrada
% =====================================================================
iniciar :-
    saludo,
    dialogo([], [matematicas, tecnologia, personas, arte,
                 salud, naturaleza, problemas, negocios,
                 escuchar, hablar, idiomas, ensenanza,
                 leyes, construccion]),
    nl,
    write('--- Sesion finalizada ---'), nl.


% --------------------------- Saludo --------------------------------
saludo :-
    nl,
    write('================================================='), nl,
    write('  OrientadorCE - Sistema Experto Vocacional       '), nl,
    write('================================================='), nl,
    write('Hola, se que la tarea de buscar una carrera es '),
    write('dificil. Estamos aqui para ayudarte!'), nl,
    write('Dime que te gusta (escribe en lenguaje natural y '),
    write('presiona Enter al terminar).'), nl, nl,
    flush_output.


% =====================================================================
%   Bucle principal de dialogo
%
%   dialogo(+Preferencias, +TemasPendientes)
%
%   Preferencias    = [pref(Tema, Polaridad), ...] respuestas acumuladas
%   TemasPendientes = lista de temas sobre los que aun se preguntara
%
%   Cuando ya no quedan temas pendientes (o si se obtuvieron al menos
%   4 preferencias) se procede a la recomendacion final. Si alguna
%   respuesta no se entiende, se reformula la misma pregunta.
% =====================================================================

% Caso 1: ya no hay temas o se acumularon suficientes -> recomendar
dialogo(Prefs, []) :-
    !, recomendar(Prefs).

dialogo(Prefs, _) :-
    length(Prefs, N), N >= 14, !,
    recomendar(Prefs).

% Caso 2: la mejor profesion ya tiene todos sus temas cubiertos -> recomendar
dialogo(Prefs, _) :-
    profesion_cubierta(Prefs, _), !,
    recomendar(Prefs).

% Caso 2: aun quedan temas
dialogo(Prefs, [Tema | Resto]) :-
    preguntar(Tema),
    leer_oracion(Tokens),
    procesar(Tokens, Tema, Prefs, Resto, NuevasPrefs, NuevosTemas),
    dialogo(NuevasPrefs, NuevosTemas).


% --------------- Preguntas asociadas a cada tema -------------------
preguntar(matematicas) :-
    write('OrientadorCE: Cuentame, que te parecen las matematicas?'),
    nl, flush_output.
preguntar(tecnologia) :-
    write('OrientadorCE: Te gusta la tecnologia?'),
    nl, flush_output.
preguntar(personas) :-
    write('OrientadorCE: Tienes interes por las personas?'),
    nl, flush_output.
preguntar(problemas) :-
    write('OrientadorCE: Te gusta resolver problemas?'),
    nl, flush_output.
preguntar(escuchar) :-
    write('OrientadorCE: Te gusta escuchar a los demas cuando hablan?'),
    nl, flush_output.
preguntar(hablar) :-
    write('OrientadorCE: Te gusta hablar y expresarte con otras personas?'),
    nl, flush_output.
preguntar(arte) :-
    write('OrientadorCE: Te gusta el arte?'), nl, flush_output.
preguntar(naturaleza) :-
    write('OrientadorCE: Te gustan los animales y la naturaleza?'),
    nl, flush_output.
preguntar(salud) :-
    write('OrientadorCE: Te interesa el cuerpo humano y la salud?'),
    nl, flush_output.
preguntar(negocios) :-
    write('OrientadorCE: Te interesan los negocios y las empresas?'),
    nl, flush_output.
preguntar(idiomas) :-
    write('OrientadorCE: Te gustan los idiomas y las lenguas extranjeras?'),
    nl, flush_output.
preguntar(ensenanza) :-
    write('OrientadorCE: Te gustaria ensenar o transmitir conocimiento a otros?'),
    nl, flush_output.
preguntar(leyes) :-
    write('OrientadorCE: Te interesan las leyes y el sistema judicial?'),
    nl, flush_output.
preguntar(construccion) :-
    write('OrientadorCE: Te interesa construir o disenar estructuras y edificios?'),
    nl, flush_output.
preguntar(_) :-
    write('OrientadorCE: Cuentame mas sobre lo que te gusta.'),
    nl, flush_output.


% =====================================================================
%   Lectura de la respuesta del usuario en LENGUAJE NATURAL
%
%   leer_oracion(-Tokens)
%
%   Lee una linea completa del teclado y la convierte en una lista de
%   atomos en minusculas, sin tildes, sin signos de puntuacion. Por
%   ejemplo:
%      Entrada: "Yo amo las matematicas."
%      Salida : [yo, amo, las, matematicas]
%
%   IMPORTANTE: NO se escribe el prefijo 'Usuario: ' antes de leer.
%   Razon: en la consola GUI de SWI-Prolog (swipl-win.exe), el editor
%   de linea no rastrea correctamente la posicion del cursor cuando
%   hay texto previo en la misma linea. Eso causa que al presionar
%   backspace se borren caracteres incorrectamente o aparezcan
%   simbolos extranos. Al leer desde el inicio de una linea limpia
%   (despues del nl/0 de la pregunta), el editor funciona bien y
%   se puede borrar y corregir sin problemas.
%
%   Si la entrada esta vacia, vuelve a leer.
% =====================================================================

leer_oracion(Tokens) :-
    flush_output,
    read_line_to_string(user_input, Linea),
    ( Linea == end_of_file
    ->  Tokens = [fin]
    ;   procesar_linea(Linea, T1),
        ( T1 == [] ->
            % El usuario solo presiono Enter sin escribir nada;
            % volvemos a leer.
            leer_oracion(Tokens)
        ;   Tokens = T1
        )
    ).


% --- procesar_linea(+String, -ListaDeAtomos) ------------------------
%   1. Pasa el string a minusculas.
%   2. Quita tildes y reemplaza puntuacion por espacios (limpiar/2).
%   3. Divide por espacios.
%   4. Convierte cada palabra (string) a atomo.
procesar_linea(Linea, Tokens) :-
    string_lower(Linea, Min),
    string_chars(Min, Caracteres),
    limpiar(Caracteres, Limpios),
    string_chars(LineaLimpia, Limpios),
    split_string(LineaLimpia, " \t\r\n", " \t\r\n", Palabras),
    strings_a_atomos(Palabras, Tokens).


% --- limpiar/2 -------------------------------------------------------
%   Recorre la lista de caracteres y aplica transformar/2 a cada uno.
%   Si transformar/2 da una sustitucion, se usa; si no, el caracter
%   se conserva tal cual.
limpiar([], []).
limpiar([C | T], [C2 | T2]) :-
    transformar(C, C2), !,
    limpiar(T, T2).
limpiar([C | T], [C | T2]) :-
    limpiar(T, T2).


% --- Mapeo de transformaciones --------------------------------------
% Vocales acentuadas (minusculas; las mayusculas ya pasaron por
% string_lower, pero las incluimos por defensa):
transformar('á', 'a').
transformar('é', 'e').
transformar('í', 'i').
transformar('ó', 'o').
transformar('ú', 'u').
transformar('ü', 'u').
transformar('ñ', 'n').
transformar('Á', 'a').
transformar('É', 'e').
transformar('Í', 'i').
transformar('Ó', 'o').
transformar('Ú', 'u').
transformar('Ñ', 'n').
% Signos de puntuacion -> espacio
transformar('.', ' ').
transformar(',', ' ').
transformar(';', ' ').
transformar(':', ' ').
transformar('?', ' ').
transformar('!', ' ').
transformar('¿', ' ').
transformar('¡', ' ').
transformar('"', ' ').
transformar('\'', ' ').
transformar('(', ' ').
transformar(')', ' ').


% --- strings_a_atomos/2 ---------------------------------------------
%   Convierte una lista de strings a una lista de atomos, descartando
%   los strings vacios que quedan tras split_string.
strings_a_atomos([], []).
strings_a_atomos([""  | T], R) :- !, strings_a_atomos(T, R).
strings_a_atomos([S   | T], [A | R]) :-
    atom_string(A, S),
    strings_a_atomos(T, R).


% =====================================================================
%   Procesamiento de la respuesta
%
%   procesar(+Tokens, +Tema, +PrefsAcum, +TemasPend,
%            -NuevasPrefs, -NuevosTemas)
%
%   - Si interpretar/4 devuelve ok y el tema inferido coincide con el
%     preguntado (o no hay tema explicito): se registra la preferencia.
%   - Si el tema inferido es DIFERENTE al preguntado: se pide repetir,
%     ya que mezclar temas puede asignar polaridad incorrecta.
%   - Si devuelve no_entendido: se reformula la misma pregunta.
% =====================================================================

procesar(Tokens, Tema, Prefs, Resto, NuevasPrefs, NuevosTemas) :-
    interpretar(Tokens, Pol, TemaInferido, Estado),
    ( Estado == ok ->
        ( TemaInferido == ninguno ->
            % El usuario no menciono ningun tema explicito:
            % se asume que respondio a la pregunta hecha.
            agregar_preferencia(Tema, Pol, Prefs, NuevasPrefs),
            NuevosTemas = Resto
        ; TemaInferido == Tema ->
            % El usuario hablo del mismo tema que se pregunto.
            agregar_preferencia(Tema, Pol, Prefs, NuevasPrefs),
            NuevosTemas = Resto
        ;
            % El usuario menciono un tema distinto al preguntado:
            % se pide repetir para evitar asignar polaridad incorrecta.
            write('OrientadorCE: Me puedes repetir, no entendi.'), nl,
            flush_output,
            NuevasPrefs = Prefs,
            NuevosTemas = [Tema | Resto]
        )
    ;   write('OrientadorCE: Me puedes repetir, no entendi.'), nl,
        flush_output,
        NuevasPrefs = Prefs,
        NuevosTemas = [Tema | Resto] ).


% --- Agrega una preferencia evitando duplicados ----------------------
%  Si ya existe una preferencia para el mismo tema, no se agrega otra.
agregar_preferencia(T, _P, Prefs, Prefs) :-
    miembro(pref(T, _), Prefs), !.
agregar_preferencia(T, P, Prefs, [pref(T, P) | Prefs]).


% --- Elimina la primera ocurrencia de X en una lista -----------------
eliminar(_, [], []).
eliminar(X, [X|T], T) :- !.
eliminar(X, [Y|T], [Y|R]) :- eliminar(X, T, R).


% =====================================================================
%   Recomendacion final
% =====================================================================
recomendar(Prefs) :-
    nl,
    ( Prefs == [] ->
        write('OrientadorCE: No logre obtener informacion suficiente '),
        write('para darte una recomendacion.'), nl
    ;
        mejor_profesion(Prefs, Carrera, Score),
        write('OrientadorCE: Dadas tus preferencias '),
        write('te recomendaria estudiar '),
        write(Carrera), write('.'), nl,
        write('   (puntaje de afinidad obtenido: '),
        write(Score), write(')'), nl
    ),
    flush_output.


% =====================================================================
%   FIN DE BNF.pl
% =====================================================================
