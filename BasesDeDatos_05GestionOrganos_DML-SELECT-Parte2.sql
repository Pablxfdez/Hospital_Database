-- 5. Consulta de datos. Parte 2: Consultas de composición de tablas
/* Lenguaje de Modificación de Datos o DML (Data Manipulation Language)
   - SELECT: Consulta de datos.
 */
USE gestionOrganos;

# ¿Datos completos de los donantes de órganos?
/* 1. Producto cartesiano */
/* 1.1. Producto cartesiano no condicionado */
SELECT * FROM donantes, organos;    
/* SELECT NIF_donante, ID_organo 
      FROM donantes, organos; 
   [ERROR DE AMBIGÜEDAD DE NOMBRES] Error Code: 1052. Column 'NIF_donante' in field list is ambiguous   
 */   
-- Empleo de nombres cualificados (nombre de la tabla más el nombre de la columna)
SELECT donantes.NIF_donante, ID_organo FROM donantes, organos;
SELECT donantes.*, ID_organo FROM donantes, organos;
-- Empleo de alias de tabla y nombres cualificados
SELECT D.NIF_donante, ID_organo FROM donantes AS D, organos AS O;
SELECT D.*, ID_organo FROM donantes AS D, organos AS O;
/* 1.2. Producto cartesiano condicionado */
SELECT *
   FROM donantes AS D, organos AS O
   WHERE D.NIF_donante = O.NIF_donante;

# ¿Datos completos de los receptores de órganos con/sin órgano asignado?
/* 2. Operador de reunión (JOIN) */
/* 2.1. Operador de reunión CROSS JOIN (producto cartesiano): 
        Combina cada fila de una tabla de base de datos con todas las filas de otra. */
SELECT * 
   FROM receptores AS R CROSS JOIN organos AS O;
/* 2.2. Operador de reunión INNER JOIN (reunión interna): 
        Devuelve las filas de ambas tablas que satisfacen la condición dada. */
SELECT * # Datos completos de los receptores de órganos con órgano asignado.
   FROM receptores AS R INNER JOIN organos AS O ON R.NIF_receptor = O.NIF_receptor;
SELECT *
   FROM receptores AS R INNER JOIN organos AS O USING (NIF_receptor); -- USING necesita tener nombres idénticos para las columnas coincidentes en ambas tablas.
/* 2.3. Operador de reunión {LEFT | RIGHT} JOIN (reunión externa):
        LEFT JOIN: Devuelve todas las filas de la tabla de la izquierda, incluso si no se han encontrado filas coincidentes 
                   en la tabla de la derecha. Donde no se encontraron coincidencias en la tabla de la derecha, se devuelve NULL. 
		RIGHT JOIN: Devuelve todas las filas de la tabla de la derecha, incluso si no se han encontrado filas coincidentes 
                    en la tabla de la izquierda. Donde no se encontraron coincidencias en la tabla de la izquierda, se devuelve NULL. */
SELECT * 
   FROM receptores AS R LEFT JOIN organos AS O ON R.NIF_receptor = O.NIF_receptor;
SELECT * # Datos completos de los receptores de órganos sin órgano asignado.
   FROM receptores AS R LEFT JOIN organos AS O ON R.NIF_receptor = O.NIF_receptor
   WHERE O.NIF_donante IS NULL;
SELECT *
   FROM receptores AS R RIGHT JOIN organos AS O ON R.NIF_receptor = O.NIF_receptor;
# ¿Datos completos de los coordinadores de los hospitales donde se han realizado implantaciones?
SELECT DISTINCT S.*
FROM (hospitales AS H INNER JOIN implantaciones AS I ON H.ID_hospital = I.ID_hospital) INNER JOIN sanitarios AS S 
     ON H.NIF_coordinador = S.NIF_sanitario;
# ¿Datos completos de los coordinadores de los hospitales no madrileños donde se han realizado implantaciones? 
SELECT DISTINCT S.*
FROM (hospitales AS H INNER JOIN implantaciones AS I ON H.ID_hospital = I.ID_hospital) INNER JOIN sanitarios AS S 
     ON H.NIF_coordinador = S.NIF_sanitario
WHERE H.municipio_hospital != 'MADRID';

/* Ejercicio: 
   1. Cantidad de donaciones de corazón.
   2. Cantidad de donaciones de cada uno de los órganos. 
   3. Código de los hospitales donde se ha realizado más de una implantación.
   4. Datos completos de los hospitales donde se ha realizado alguna implantación no cardíaca.
   5. Datos completos de los hospitales donde no se ha realizado ninguna implantación.
   6. Código de los equipos médicos con más de un sanitario perteneciente al colectivo de enfermeros.
   7. Datos completos de los coordinadores hospitalarios que forman parte de algún equipo médico.
   8. Datos completos de los coordinadores hospitalarios que no forman parte de ningún equipo médico.
   9. Datos completos de los coordinadores hospitalarios no madrileños que forman parte de algún equipo médico. 
  10. Datos completos de los coordinadores hospitalarios no madrileños que forman parte de más de un equipo médico.
 */