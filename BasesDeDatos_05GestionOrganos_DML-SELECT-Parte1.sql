-- 5. Consulta de datos. Parte 1: Consultas básicas, con criterio de selección y funciones de agregación 
/* Lenguaje de Manipulación de Datos o DML (Data Manipulation Language)
   - SELECT: Consulta de datos.
 */
USE gestionOrganos;
 
/* 1. Consultas básicas */
-- Selección completa de columnas
SELECT * FROM donantes; 
-- Selección parcial de columnas (sin y con alias de columnas)
SELECT NIF_donante, nombre_donante, primer_apellido_donante
    FROM donantes;
SELECT NIF_donante AS NIF, nombre_donante AS nombre, primer_apellido_donante AS primer_apellido
    FROM donantes; 
-- Selección con ordenación de resultados 
SELECT NIF_donante, nombre_donante, primer_apellido_donante
    FROM donantes
    ORDER BY nombre_donante;
SELECT NIF_donante, nombre_donante, primer_apellido_donante
    FROM donantes
    ORDER BY nombre_donante ASC, primer_apellido_donante DESC;
SELECT NIF_donante, ID_organo
    FROM organos
    ORDER BY NIF_donante ASC, ID_organo DESC;
-- Selección con repeticiones en el resultado
SELECT ID_organo FROM organos;
SELECT municipio_hospital, tipo_hospital FROM hospitales;
-- Selección con eliminación de repeticiones en el resultado
SELECT DISTINCT ID_organo FROM organos;
SELECT DISTINCT municipio_hospital, tipo_hospital FROM hospitales;
-- Selección con almacenamiento externo de resultados
/* La instrucción SELECT INTO OUTFILE permite volcar rápidamente una tabla en un archivo de texto en el servidor. */ 
SELECT * FROM receptores
    INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/resultados_receptores.csv'
    FIELDS TERMINATED BY ',' 
    LINES TERMINATED BY '\r\n';	
/* 2. Consultas con criterios de selección 
   - Operadores de comparación: = (equal), <=> (NULL-safe equal), <> (not equal), != (not equal), <=, <, >, >=, 
		IS [NOT] valorBooleano ({TRUE, FALSE, UNKNOWN}), IS [NOT] NULL, 
        expresión [NOT] IN (valor1,valor2,...valorN), expresión LIKE patrón (pattern matching)
   - Operadores lógicos: AND (logical AND), && (logical AND), NOT (logical NOT), ! (logical NOT), OR (logical OR), || (logical OR)
   IMPORTANTE: Debe estudiarse el comportamiento de los operadores respecto al valor NULL. 
   Ejemplo: El operador <=> realiza una comparación de igualdad como el operador =, pero devuelve 1 en lugar de NULL si ambos 
   operandos son NULL y 0 en lugar de NULL si un operando es NULL.
			SELECT NULL = NULL;
			SELECT NULL <=> NULL;
 */
SELECT NIF_donante, nombre_donante, primer_apellido_donante
    FROM donantes
	WHERE nombre_donante > 'John';
SELECT NIF_donante, nombre_donante, primer_apellido_donante
    FROM donantes
	WHERE nombre_donante LIKE 'J%';
SELECT * FROM organos 
    WHERE ID_organo IN ('E','I');
SELECT * FROM enfermeros
    WHERE NIF_supervisor IS NULL;     -- Tratamiento de valores nulos
SELECT * FROM enfermeros
    WHERE NIF_supervisor IS NOT NULL; -- Tratamiento de valores nulos
-- Selección con criterio compuesto
SELECT NIF_donante, nombre_donante, primer_apellido_donante 
    FROM donantes
    WHERE (nombre_donante > 'John') AND (primer_apellido_donante LIKE 'M%');
SELECT * FROM enfermeros
    WHERE (NIF_enfermero > '33393248P') AND (NIF_supervisor IS NULL); -- Tratamiento de valores nulos
/* Operador UNION: Las columnas seleccionadas en las posiciones correspondientes de cada instrucción SELECT deben tener el mismo tipo de datos. 
   - Los nombres de columna de la primera instrucción SELECT se utilizan como nombres de columna para los resultados devueltos.  
 */
SELECT * FROM organos WHERE ID_organo='E' 
    UNION 
SELECT * FROM organos WHERE ID_organo='I';
SELECT * FROM donantes 
    UNION 
SELECT * FROM receptores;
SELECT NIF_donante, nombre_donante, primer_apellido_donante FROM donantes
    UNION
SELECT NIF_donante, ID_organo, NIF_receptor FROM organos;

/* 3. Consultas con funciones de agregación */
-- Función agregada de aplicación conjunta
SELECT COUNT(ID_organo)
   FROM organos;
-- Función agregada de aplicación conjunta con eliminación de repeticiones   
SELECT COUNT(DISTINCT ID_organo)
   FROM organos;
-- Función agregada de aplicación por grupos (sin y con alias de columnas)
SELECT ID_organo, COUNT(NIF_donante)
   FROM organos
   GROUP BY ID_organo;
SELECT ID_organo, COUNT(NIF_donante) AS cantidad_donantes
   FROM organos
   GROUP BY ID_organo;
-- Función agregada de aplicación por grupos (sin y con alias de columnas) y selección de grupos
SELECT ID_organo, COUNT(NIF_donante) AS cantidad_donantes
   FROM organos
   GROUP BY ID_organo
   HAVING cantidad_donantes > 2;
/* Procesamiento de consultas con funciones de agregación:
   1. Obtención de la tabla especificada en la cláusula FROM. 
   2. Selección de sus filas según la cláusula WHERE.
   3. Agrupación de dichas filas según la cláusula GROUP BY.
   4. Por cada grupo, obtención de una fila mediante el cómputo de las funciones agregadas.
   5. Selección de las filas anteriores según la cláusula HAVING.
   6. Eliminación de las columnas no especificadas en la cláusula SELECT.
   7. Ordenación de las filas segun la cláusula ORDER BY.
 */  

/* Ejercicio:
   1. Datos de los órganos que tienen un receptor asignado.
   2. Datos de los sanitarios que no pertenecen ni al colectivo de médicos ni al colectivo de enfermeros.
   3. Cantidad de médicos de cada una de las especialidades almacenadas.
   4. Datos de los hospitales de tipo II cuyo nombre empieza por la palabra 'COMPLEJO'. 
   5. Cantidad de hospitales de cada una de las categorías almacenadas.
   6. Datos de los municipios con más de dos hospitales.
   7. Cantidad de hospitales de tipo I de cada municipio.
   8. Datos de los municipios con más de un hospital de tipo I.
   9. NIF de los pacientes que han realizado varias donaciones.
  10. Datos de los hospitales con más de dos médicos.
 */