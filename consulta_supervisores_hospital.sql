-- Devolver el DNI de todos los supervisores que supervisan a todos los enfermeros del hospital en el que trabajan (él mismo no cuenta en esta condición).

-- Consideraciones extras:
-- Un supervisor tiene que supervisar al menos a una persona para ser considerado como tal.
-- Un supervisor puede ser tanto un enfermero como un médico.
-- Los enfermeros tienen el campo tipo_sanitario a False (0)

-- Por si os sirve de ayuda a la hora de encadenar consultas, podéis usar
-- create view view_name(attr1, ..., attrn) as select ... para almacenar el resultado de una consulta en una vista
-- y trabajar con ella como si fuese una tabla.

-- Indicación: la consulta debería devolver al menos '11190691H', puesto que supervisa a '39005828J' y a '44755402R', que son los otros
-- enfermeros del hospital '080399'.  Sin embargo, no debería devolver '33393248P', porque el enfermero '37554590Y'
-- a su mismo hospital ('080484') pero no está siendo supervisado por él