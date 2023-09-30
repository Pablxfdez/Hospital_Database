-- 6. Restricciones CHECK y objetos almacenados. Parte 1: Disparadores, procedimientos almacenados y funciones
USE gestionOrganos; 

/* 1. Restricciones CHECK */
CREATE TABLE plantilla_tabla (
	ID_hospital			CHAR(6) NOT NULL,
    cantidad_sanitarios SMALLINT UNSIGNED NOT NULL DEFAULT 0 
    CONSTRAINT cantidad_limite CHECK (cantidad_sanitarios <= 10)
);
ALTER TABLE plantilla_tabla
   ADD CONSTRAINT plantillaPK PRIMARY KEY (ID_hospital);
ALTER TABLE plantilla_tabla
   ADD CONSTRAINT plantillaFK FOREIGN KEY (ID_hospital)
   REFERENCES hospitales(ID_hospital)
   ON DELETE CASCADE ON UPDATE CASCADE;   
INSERT INTO plantilla_tabla SELECT ID_hospital, COUNT(NIF_sanitario) FROM sanitarios GROUP BY ID_hospital;
SELECT * FROM plantilla_tabla;
# Prueba de las restricciones CHECK
UPDATE plantilla_tabla SET cantidad_sanitarios = 11 WHERE ID_hospital = "110012";
/* Error Code: 3819. Check constraint 'cantidad_limite' is violated */
CREATE VIEW plantilla_vista AS
	SELECT ID_hospital, COUNT(NIF_sanitario) FROM sanitarios GROUP BY ID_hospital;
SELECT * FROM plantilla_vista;

/* 2. Disparadores */
/* A trigger is a stored program invoked automatically in response to an event such as insert, update, or delete 
   that occurs in the associated permanent table. You cannot associate a trigger with a temporary table or a view. 
   1. A trigger can affect tables, but it is not permitted to modify a table that is already being used by the 
      statement that invoked the function or trigger.
   2. It is possible to define multiple triggers for a given table that have the same trigger event and action time. 
      - By default, triggers that have the same trigger event and action time activate in the order they were created. 
      - To affect trigger order, specify a clause after FOR EACH ROW that indicates FOLLOWS or PRECEDES and the name of 
        an existing trigger that also has the same trigger event and action time. 
   3. Cascaded foreign key actions do not activate triggers.
   4. Triggers are stored in the mysql.triggers system table, which is part of the data dictionary.
 */
DELIMITER $$
/* El delimitador se cambia a $$ para permitir que la definición completa del disparador se pase al servidor como una sola declaración. 
   Esto permite que el delimitador ; utilizado en el cuerpo del procedimiento pase al servidor en lugar de ser interpretado por MySQL. */
CREATE TRIGGER addSanitarioPlantilla BEFORE INSERT ON sanitarios FOR EACH ROW
BEGIN
	UPDATE plantilla_tabla SET cantidad_sanitarios = cantidad_sanitarios+1 WHERE ID_hospital = NEW.ID_hospital;
END $$
CREATE TRIGGER addSanitario AFTER INSERT ON sanitarios FOR EACH ROW 
BEGIN
	IF (NEW.tipo_sanitario IS NOT NULL) 
        THEN IF (NEW.tipo_sanitario) 
				THEN INSERT INTO medicos VALUE(NEW.NIF_sanitario,'GASTROENTEROLOGIA');
		        ELSE INSERT INTO enfermeros VALUE(NEW.NIF_sanitario,NULL);
             END IF;   
    END IF; 
END $$
DELIMITER ;
# Prueba de los disparadores
-- DROP TRIGGER IF EXISTS addSanitarioPlantilla;
-- DROP TRIGGER IF EXISTS addSanitario;
INSERT INTO sanitarios (NIF_sanitario,nombre_sanitario,primer_apellido_sanitario,segundo_apellido_sanitario,tipo_sanitario,ID_hospital) VALUES
   ("59147400W","Pijus","Magnificus",NULL,FALSE,"080399"),
   ("51210033G","Incontinencia","Summa",NULL,TRUE,"080399"),
   ("02415229E","Traviesus","Maximus",NULL,NULL,"110012");
-- DELETE FROM enfermeros WHERE NIF_enfermero = "59147400W";
-- DELETE FROM medicos WHERE NIF_medico = "51210033G";
-- DELETE FROM sanitarios WHERE NIF_sanitario IN ("59147400W","51210033G","02415229E");
SELECT * FROM plantilla_tabla;
SELECT * FROM plantilla_vista;
INSERT INTO sanitarios (NIF_sanitario,nombre_sanitario,primer_apellido_sanitario,segundo_apellido_sanitario,tipo_sanitario,ID_hospital) VALUES
   ("98608290E","Brian","de Nazareth",NULL,TRUE,"080399");
-- DROP TABLE IF EXISTS plantilla_tabla
-- DROP VIEW IF EXISTS plantilla_vista

/* 3. Procedimientos almacenados y funciones */
/* A stored procedure is a collection of pre-compiled SQL statements stored inside the database. 
   A stored function in MySQL is a set of SQL statements that perform some task/operation and return a single value. */ 
DELIMITER $$
CREATE PROCEDURE getHospitales_municipio(IN municipio VARCHAR(30),OUT cantidad INT)
BEGIN
	SELECT COUNT(ID_hospital) INTO cantidad FROM hospitales WHERE municipio_hospital = municipio;
END $$
CREATE FUNCTION getHospitales_municipio(municipio VARCHAR(30)) RETURNS INT READS SQL DATA
BEGIN
	DECLARE resultado INT;
    SELECT COUNT(ID_hospital) INTO resultado FROM hospitales WHERE municipio_hospital = municipio;
    RETURN resultado;
END $$
DELIMITER ;
# Prueba de los procedimientos almacenados y las funciones
-- DROP PROCEDURE IF EXISTS getHospitales_municipio;
-- DROP FUNCTION IF EXISTS getHospitales_municipio;
SET @cantidad = 0;
CALL getHospitales_municipio('MADRID',@cantidad);  # Llamada al procedimiento almacenado
SELECT @cantidad;                                  # Muestra de los resultados
SET @cantidad = getHospitales_municipio('HUESCA'); # Llamada a la función
SELECT @cantidad;                                  # Muestra de los resultados