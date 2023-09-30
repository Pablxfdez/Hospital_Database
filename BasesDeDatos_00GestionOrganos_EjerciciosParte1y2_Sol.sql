-- 5. Consulta de datos. Parte 1: Consultas básicas, con criterio de selección y funciones de agregación 
/* Lenguaje de Modificación de Datos o DML (Data Manipulation Language)
   - SELECT: Consulta de datos.
 */
USE gestionOrganos;
/* Ejercicios resueltos */
-- 1. Datos de los órganos que tienen un receptor asignado.
SELECT * FROM organos WHERE NIF_receptor IS NOT NULL;
-- 2. Datos de los sanitarios que no pertenecen ni al colectivo de médicos ni al colectivo de enfermeros.
SELECT * FROM sanitarios WHERE tipo_sanitario IS NULL;
-- 3. Cantidad de médicos de cada una de las especialidades almacenadas.
SELECT especialidad_medico, COUNT(NIF_medico) AS cantidad_medicos FROM medicos
	GROUP BY especialidad_medico;
-- 4. Datos de los hospitales de tipo II cuyo nombre empieza por la palabra 'COMPLEJO'. 
SELECT * FROM hospitales
	WHERE tipo_hospital = 'II' AND nombre_hospital LIKE 'COMPLEJO%';
-- 4a. Datos de los hospitales de tipo II cuyo nombre empieza por la palabra 'COMPLEJO' o por la palabra 'HOSPITAL'. 
SELECT * FROM hospitales
	WHERE tipo_hospital = 'II' AND nombre_hospital LIKE 'COMPLEJO%' OR nombre_hospital LIKE 'HOSPITAL%';
-- 5. Cantidad de hospitales de cada una de las categorías almacenadas.
SELECT tipo_hospital, COUNT(ID_hospital) AS cantidad_hospitales FROM hospitales
	GROUP BY tipo_hospital;
-- 6. Datos de los municipios con más de dos hospitales.
SELECT municipio_hospital, COUNT(ID_hospital) as cantidad_hospitales FROM hospitales
	GROUP BY municipio_hospital
    HAVING cantidad_hospitales > 2;
-- 7. Cantidad de hospitales de tipo I de cada municipio.
SELECT municipio_hospital, COUNT(ID_hospital) AS cantidad_hospitales_tipoI FROM hospitales
	WHERE tipo_hospital = 'I'
    GROUP BY municipio_hospital;
-- 8. Datos de los municipios con más de un hospital de tipo I.
SELECT municipio_hospital, COUNT(ID_hospital) AS cantidad_hospitales_tipoI FROM hospitales
	WHERE tipo_hospital = 'I'
    GROUP BY municipio_hospital
    HAVING cantidad_hospitales_tipoI > 1;
-- 9. NIF de los pacientes que han realizado varias donaciones (esto es, han donado varios órganos).
SELECT NIF_donante, COUNT(ID_organo) AS cantidad_donaciones FROM organos
	GROUP BY NIF_donante
    HAVING cantidad_donaciones > 1;
-- 10. Datos de los hospitales con más de dos médicos.
SELECT H.*, COUNT(S.NIF_sanitario) AS cantidad_medicos 
	FROM sanitarios AS S INNER JOIN hospitales AS H ON S.ID_hospital = H.ID_hospital
	WHERE S.tipo_sanitario = 1
	GROUP BY H.ID_hospital
    HAVING cantidad_medicos > 2;
/* El operador LIKE comprueba condiciones de similitud para textos:
	- El símbolo % representa cualquier cantidad de caracteres, incluso ninguno.
	- El símbolo _ representa exactamente un carácter. 
 */
    SELECT * FROM hospitales WHERE municipio_hospital LIKE 'm%'; -- Las comparaciones de cadenas no distinguen entre mayúsculas y minúsculas
    SELECT * FROM hospitales WHERE municipio_hospital NOT LIKE 'm%';
	SELECT * FROM hospitales WHERE municipio_hospital LIKE 'M%D';
	SELECT * FROM hospitales WHERE municipio_hospital LIKE '______';
	SELECT nombre_hospital, nombre_hospital LIKE '%UNIVERSITARI%' AS esUniversitario FROM hospitales;
    SELECT 20 LIKE '2%';                                         -- MySQL permite el uso de LIKE con expresiones numéricas

-- 5. Consulta de datos. Parte 2: Consultas de composición de tablas
/* Lenguaje de Modificación de Datos o DML (Data Manipulation Language)
   - SELECT: Consulta de datos.
 */
USE gestionOrganos;
/* Ejercicios resueltos */
-- 1. Cantidad de donaciones de corazón.
SELECT COUNT(NIF_donante) AS donacionesCorazon FROM organos WHERE ID_organo = 'C';
-- 2. Cantidad de donaciones de cada uno de los órganos.
SELECT ID_organo, COUNT(NIF_donante) AS cantidadDonaciones FROM organos
   GROUP BY ID_organo;
-- 3. Código de los hospitales donde se ha realizado más de una implantación.
SELECT ID_hospital, COUNT(DISTINCT NIF_donante, ID_organo) AS cantidadImplantaciones
   FROM implantaciones
   GROUP BY ID_hospital
   HAVING cantidadImplantaciones > 1;
-- 4. Datos completos de los hospitales donde se ha realizado alguna implantación no cardíaca.
SELECT DISTINCT H.*
   FROM hospitales H INNER JOIN implantaciones I ON H.ID_hospital = I.ID_hospital
   WHERE I.ID_organo NOT LIKE 'C';
-- 5. Datos completos de los hospitales donde no se ha realizado ninguna implantación.
SELECT H.*
   FROM hospitales H LEFT JOIN implantaciones I ON H.ID_hospital = I.ID_hospital
   WHERE I.ID_organo IS NULL;
-- 6. Código de los equipos médicos con más de un sanitario perteneciente al colectivo de enfermeros.
SELECT SE.ID_equipoMedico, COUNT(E.NIF_enfermero) AS cantidadEnfermeros
   FROM sanitarios_equiposMedicos SE INNER JOIN enfermeros E ON SE.NIF_sanitario = E.NIF_enfermero
   GROUP BY SE.ID_equipoMedico
   HAVING cantidadEnfermeros > 1;
-- 6a. Cantidad de enfermeros de cada equipo médico
SELECT SE.ID_equipoMedico, COUNT(E.NIF_enfermero) AS cantidadEnfermeros
   FROM sanitarios_equiposMedicos SE LEFT JOIN enfermeros E ON SE.NIF_sanitario = E.NIF_enfermero
   GROUP BY SE.ID_equipoMedico;
-- 7. Datos completos de los coordinadores hospitalarios que forman parte de algún equipo médico.
SELECT DISTINCT S.NIF_sanitario, S.nombre_sanitario, S.primer_apellido_sanitario
   FROM (hospitales H INNER JOIN sanitarios_equiposMedicos SE ON H.NIF_coordinador = SE.NIF_sanitario) INNER JOIN sanitarios S ON H.NIF_coordinador = S.NIF_sanitario;
# Consulta equivalente
SELECT S.NIF_sanitario, S.nombre_sanitario, S.primer_apellido_sanitario, COUNT(SE.ID_equipoMedico) AS cantidadEquipos
   FROM (hospitales H INNER JOIN sanitarios_equiposMedicos SE ON H.NIF_coordinador = SE.NIF_sanitario) INNER JOIN sanitarios S ON H.NIF_coordinador = S.NIF_sanitario
   GROUP BY H.NIF_coordinador;
-- 8. Datos completos de los coordinadores hospitalarios que no forman parte de ningún equipo médico.
SELECT S.NIF_sanitario, S.nombre_sanitario, S.primer_apellido_sanitario
   FROM (hospitales H LEFT JOIN sanitarios_equiposMedicos SE ON H.NIF_coordinador = SE.NIF_sanitario) INNER JOIN sanitarios S ON H.NIF_coordinador = S.NIF_sanitario
   WHERE SE.NIF_sanitario IS NULL;
# Consulta equivalente (conteo de los equipos médicos de cada coordinador hospitalario)
SELECT S.NIF_sanitario, S.nombre_sanitario, S.primer_apellido_sanitario, COUNT(SE.ID_equipoMedico) AS cantidadEquipos
   FROM (hospitales H LEFT JOIN sanitarios_equiposMedicos SE ON H.NIF_coordinador = SE.NIF_sanitario) INNER JOIN sanitarios S ON H.NIF_coordinador = S.NIF_sanitario
   GROUP BY H.NIF_coordinador
   HAVING cantidadEquipos = 0;
-- 9. Datos completos de los coordinadores hospitalarios no madrileños que forman parte de algún equipo médico.
SELECT DISTINCT S.NIF_sanitario, S.nombre_sanitario, S.primer_apellido_sanitario, H.municipio_hospital
   FROM (hospitales H INNER JOIN sanitarios_equiposMedicos SE ON H.NIF_coordinador = SE.NIF_sanitario) INNER JOIN sanitarios S ON H.NIF_coordinador = S.NIF_sanitario
   WHERE H.municipio_hospital != 'MADRID';
-- 10. Datos completos de los coordinadores hospitalarios no madrileños que forman parte de más de un equipo médico.
SELECT S.NIF_sanitario, S.nombre_sanitario, S.primer_apellido_sanitario, H.municipio_hospital, COUNT(SE.ID_equipoMedico) AS cantidadEquipos
   FROM (hospitales H INNER JOIN sanitarios_equiposMedicos SE ON H.NIF_coordinador = SE.NIF_sanitario) INNER JOIN sanitarios S ON H.NIF_coordinador = S.NIF_sanitario
   WHERE H.municipio_hospital != 'MADRID'
   GROUP BY H.NIF_coordinador
   HAVING cantidadEquipos > 1;