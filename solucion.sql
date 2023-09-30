drop view if exists supervisor_hospital, par_enfermero_supervisor, sanitario_no_supervisor;

-- Creamos una vista con todos los supervisores (i.e. cuyos NIF aparecen en la tabla enfermeros con NIF_supervisor) y su hospital asociado
create view supervisor_hospital(NIF_supervisor, ID_hospital) as 
select distinct(NIF_supervisor), ID_hospital from enfermeros join sanitarios on enfermeros.NIF_supervisor = sanitarios.NIF_sanitario;

-- Hacemos el producto cartesiano de todos los enfermeros con todos los supervisores que trabajan en su mismo hospital.
-- El productor cartesiano devuelve todas las combinaciones enfermero/supervisor que se pueden formar, que luego usaremos
-- para comprobar si todas las combinaciones aparecen en la tabla enfermeros o no.
-- Para quedarnos solo con los enfermeros, usamos la condicion not enf.tipo_sanitario
-- Filtramos las tuplas supervisor/supervisor con la condicion enf.NIF_sanitario != sup.NIF_supervisor 
create view par_enfermero_supervisor(NIF_enfermero, NIF_supervisor) as
select enf.NIF_sanitario, sup.NIF_supervisor
from sanitarios enf cross join supervisor_hospital sup
where not enf.tipo_sanitario and enf.NIF_sanitario != sup.NIF_supervisor and enf.ID_hospital = sup.ID_hospital;

-- Si una combinación enfermero/supervisor no existe en la tabla enfermeros, entonces al hacer left join con el producto
-- cartesiano, esa combinación tendrá los campos a null. Si filtramos por esa condición, obtenemos los supervisores
-- que tienen a un enfermero al que no supervisan.
create view sanitario_no_supervisor(NIF_supervisor) as
select par_enfermero_supervisor.NIF_supervisor 
from par_enfermero_supervisor left join enfermeros on par_enfermero_supervisor.NIF_enfermero = enfermeros.NIF_enfermero 
and par_enfermero_supervisor.NIF_supervisor = enfermeros.NIF_supervisor where enfermeros.NIF_supervisor is null;

-- La condición de partida corresponde a la diferencia entre todos los supervisores y los supervisores de la consulta
-- anterior. MySQL no tiene el operador MINUS, así que tenemos que hacer un left join y preguntar por null para obtener el resultado
select supervisor_hospital.NIF_supervisor 
from supervisor_hospital left join sanitario_no_supervisor using (NIF_supervisor) 
where sanitario_no_supervisor.NIF_supervisor is null;
