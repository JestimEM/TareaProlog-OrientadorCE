% =====================================================================
%  BD.pl  -  Base de datos del Orientador Vocacional (OrientadorCE)
%  Tarea #3  -  Paradigmas de Programacion (CE3104) -  TEC 2026-1S
% ---------------------------------------------------------------------
%  Este archivo contiene UNICAMENTE los hechos (lexico + profesiones)
%  que necesita el parser de Logic.pl. No contiene reglas de inferencia
%  ni de interaccion con el usuario.
%
%  Convencion: todas las palabras del lexico se almacenan SIN TILDES y
%  en minusculas. La normalizacion (paso a minusculas, eliminacion de
%  tildes y de signos de puntuacion) la realiza el caller en BNF.pl
%  ANTES de pasar la lista al parser.
%
%  Estructura de datos (Documentacion Tecnica 1.2):
%   pronombre(P).           hecho atomico simple.
%   determinante(D).
%   nombre(Palabra, Tema).  cada nombre se asocia a un tema (afinidad).
%   verbo_gusto(V).         verbos que expresan afinidad (amo, disfruto)
%   verbo_disgusto(V).      verbos que expresan rechazo (odio, detesto)
%   verbo_neutro(V).        verbos estructurales (soy, es, podria...)
%   verbo_topico(V, Tema).  verbos que son por si mismos un topico.
%   adverbio_afirm(A).      adverbios afirmativos (si, claro, mucho).
%   adverbio_neg(A).        adverbios negativos (no, nunca, nada).
%   adverbio_neutro(A).     adverbios neutros (muy, tan, bien).
%   preposicion(P).
%   adjetivo(A).
%   profesion(Nombre, ListaAfinidades, ListaAntagonias).
% =====================================================================


% --------------------------- Pronombres -----------------------------
pronombre(yo).
pronombre(me).
pronombre(tu).
pronombre(usted).
pronombre(nosotros).


% -------------------------- Determinantes ---------------------------
determinante(el).
determinante(la).
determinante(los).
determinante(las).
determinante(un).
determinante(una).
determinante(unos).
determinante(unas).
determinante(mi).
determinante(mis).


% -------------- Nombres asociados a su tema (afinidad) --------------
% Matematicas
nombre(matematicas, matematicas).
nombre(numeros,     matematicas).
nombre(calculo,     matematicas).
nombre(algebra,     matematicas).

% Tecnologia
nombre(tecnologia,   tecnologia).
nombre(computador,   tecnologia).
nombre(computadora,  tecnologia).
nombre(computadoras, tecnologia).
nombre(computadores, tecnologia).
nombre(ordenador,    tecnologia).
nombre(software,     tecnologia).
nombre(programacion, tecnologia).

% Personas
nombre(personas, personas).
nombre(gente,    personas).
nombre(humanos,  personas).
nombre(ninos,    personas).
nombre(demas,    personas).

% Problemas
nombre(problemas,  problemas).
nombre(problema,   problemas).
nombre(acertijos,  problemas).

% Arte
nombre(arte,    arte).
nombre(musica,  arte).
nombre(dibujo,  arte).
nombre(pintura, arte).

% Naturaleza
nombre(animales,      naturaleza).
nombre(plantas,       naturaleza).
nombre(naturaleza,    naturaleza).
nombre(medioambiente, naturaleza).

% Negocios
nombre(dinero,   negocios).
nombre(empresas, negocios).
nombre(negocios, negocios).

% Salud
nombre(medicina, salud).
nombre(salud,    salud).
nombre(cuerpo,   salud).

% Leyes
nombre(leyes,    leyes).
nombre(justicia, leyes).
nombre(derecho,  leyes).

% Construccion
nombre(edificios,   construccion).
nombre(casas,       construccion).
nombre(estructuras, construccion).
nombre(maquinas,    construccion).

% Idiomas
nombre(idiomas, idiomas).
nombre(lenguas, idiomas).

% Ensenanza
nombre(ensenanza, ensenanza).


% --------------------------- Verbos --------------------------------
% Verbos que expresan AFINIDAD (gusto):
verbo_gusto(amo).
verbo_gusto(amar).
verbo_gusto(adoro).
verbo_gusto(disfruto).
verbo_gusto(disfrutar).
verbo_gusto(encanta).
verbo_gusto(encantan).
verbo_gusto(fascina).
verbo_gusto(fascinan).
verbo_gusto(gusta).
verbo_gusto(gustan).
verbo_gusto(prefiero).
verbo_gusto(preferir).
verbo_gusto(intereso).
verbo_gusto(interesa).
verbo_gusto(interesan).
verbo_gusto(quiero).

% Verbos que expresan ANTAGONIA (rechazo):
verbo_disgusto(odio).
verbo_disgusto(odiar).
verbo_disgusto(detesto).
verbo_disgusto(detestar).
verbo_disgusto(aburre).
verbo_disgusto(aburren).
verbo_disgusto(aburro).
verbo_disgusto(aborrezco).

% Verbos estructurales o neutros (soy, podria, paso...):
verbo_neutro(soy).
verbo_neutro(ser).
verbo_neutro(estoy).
verbo_neutro(estar).
verbo_neutro(es).
verbo_neutro(son).
verbo_neutro(podria).
verbo_neutro(puedo).
verbo_neutro(pudiera).
verbo_neutro(tengo).
verbo_neutro(tiene).
verbo_neutro(tener).
verbo_neutro(hago).
verbo_neutro(hacer).
verbo_neutro(veo).
verbo_neutro(pasar).
verbo_neutro(paso).
verbo_neutro(trabajar).
verbo_neutro(trabajo).
verbo_neutro(estudiar).
verbo_neutro(estudio).

% Verbos que son por si mismos un TOPICO (actividad-tema):
%   "yo prefiero ESCUCHAR" -> tema: escuchar
%   "disfruto RESOLVER problemas" -> tema: problemas (via verbo_topico)
verbo_topico(escuchar,  escuchar).
verbo_topico(escucho,   escuchar).
verbo_topico(hablar,    hablar).
verbo_topico(hablo,     hablar).
verbo_topico(ayudar,    ayudar).
verbo_topico(ayudo,     ayudar).
verbo_topico(ensenar,   ensenanza).
verbo_topico(enseno,    ensenanza).
verbo_topico(construir, construccion).
verbo_topico(construyo, construccion).
verbo_topico(resolver,  problemas).
verbo_topico(resuelvo,  problemas).
verbo_topico(crear,     arte).
verbo_topico(creo,      arte).


% --------------------------- Adverbios -----------------------------
% Adverbios AFIRMATIVOS:
adverbio_afirm(si).
adverbio_afirm(claro).
adverbio_afirm(correcto).
adverbio_afirm(exacto).
adverbio_afirm(mucho).
adverbio_afirm(bastante).
adverbio_afirm(demasiado).
adverbio_afirm(siempre).
adverbio_afirm(totalmente).
adverbio_afirm(completamente).

% Adverbios NEGATIVOS:
adverbio_neg(no).
adverbio_neg(nunca).
adverbio_neg(jamas).
adverbio_neg(nada).
adverbio_neg(tampoco).
adverbio_neg(poco).

% Adverbios NEUTROS (no aportan polaridad):
adverbio_neutro(muy).
adverbio_neutro(tan).
adverbio_neutro(asi).
adverbio_neutro(bien).
adverbio_neutro(mal).


% -------------------------- Preposiciones --------------------------
preposicion(a).
preposicion(de).
preposicion(por).
preposicion(con).
preposicion(para).
preposicion(en).
preposicion(sobre).
preposicion(entre).
preposicion(hacia).
preposicion(desde).


% --------------------------- Adjetivos -----------------------------
adjetivo(habil).
adjetivo(habiles).
adjetivo(bueno).
adjetivo(buena).
adjetivo(buenos).
adjetivo(buenas).
adjetivo(malo).
adjetivo(mala).
adjetivo(excelente).
adjetivo(capaz).
adjetivo(incapaz).
adjetivo(experto).
adjetivo(experta).
adjetivo(hermoso).
adjetivo(feo).


% =====================================================================
%   Profesiones del Orientador Vocacional
%   profesion( NombreVisible, Afinidades, Antagonias )
% =====================================================================

profesion('Ingenieria en Computadores',
          [matematicas, tecnologia, problemas, negocios],
          [personas, arte, naturaleza, hablar]).

profesion('Psicologia',
          [personas, escuchar, problemas, salud, hablar],
          [matematicas, tecnologia, construccion]).

profesion('Medicina',
          [personas, salud, problemas],
          [arte, construccion, negocios]).

profesion('Derecho',
          [personas, leyes, hablar, problemas, negocios],
          [matematicas, tecnologia, naturaleza, construccion]).

profesion('Arquitectura',
          [arte, construccion, matematicas, tecnologia, negocios, problemas],
          [personas, leyes]).

profesion('Artes',
          [arte, naturaleza, personas, idiomas],
          [matematicas, tecnologia, leyes, construccion]).

profesion('Administracion de Empresas',
          [negocios, personas, hablar, problemas, leyes],
          [arte, naturaleza, construccion]).

profesion('Educacion / Ensenanza',
          [personas, ensenanza, hablar, tecnologia],
          [negocios, construccion]).

profesion('Matematicas',
          [matematicas, problemas, tecnologia],
          [personas, arte, naturaleza, hablar]).

profesion('Biologia',
          [naturaleza, salud, problemas, matematicas],
          [leyes, construccion]).

profesion('Filologia / Idiomas',
          [idiomas, hablar, personas, arte, ensenanza],
          [matematicas, tecnologia, construccion]).

% =====================================================================
%   FIN DE BD.pl
% =====================================================================
