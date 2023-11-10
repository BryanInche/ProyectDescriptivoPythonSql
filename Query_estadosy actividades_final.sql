-- 1. Tabla principal estados (consulta recursiva)
select A.*, B.id_tipo_estad, B.nombre as estado_detalle,
(select nombre from public.ts_detal_estado where id=B.id_tipo_estad limit 1) as estado_secundario, 
(select nombre from public.ts_detal_estado where id = (select id_tipo_estad from public.ts_detal_estado where id=B.id_tipo_estad limit 1) limit 1) as estado_primario
from public.tp_estados A
left join public.ts_detal_estado B on A.id_detal_estado = B.id_detal_estado
--left join (select * from public.ts_detal_estado where id=B.id_tipo_estad limit 1) C on true
--where id_equipo = 32
order by tiempo_inicio
limit 10



select * from public.ts_detal_estado
limit 10


select b.nombre detalle,
(select nombre from public.ts_detal_estado where id_detal_estado=b.id_tipo_estad limit 1) as secundario
from public.tp_estados a
left join public.ts_detal_estado b
on a.id_detal_estado = b.id_detal_estado
limit 10




-- 2. Tabla Principal de Equipos (Consulta Recursiva)

-- flotas principales
select id, nombre from public.ts_equipos
where id_flota = 0 and tiem_elimin is null

-- flotas secundarias
select b.id,b.nombre principal, a.id, a.nombre secundario from public.ts_equipos a
inner join (select id, nombre from public.ts_equipos where id_flota = 0 and tiem_elimin is null) b
on b.id = a.id_flota
where a.tiem_elimin is null
order by b.id

--equipos
select d.id_principal, d.principal, d.id_secundario, d.secundario, c.id, c.nombre nombre_equipo, c.capacidad_vol,
c.capacidad_pes, c.capacidadtanque, c.fcorrec_efhod, c.fcorrec_efhdo, c.pesobruto, c.ishp, c.ancho, c.largo,
c.numeroejes, c.anho, c.tipoespecial, c.radiohexagonoequipo, c.radiohexagonocuchara
from public.ts_equipos c
inner join (select b.id id_principal , b.nombre principal, a.id id_secundario , a.nombre secundario from public.ts_equipos a
inner join (select id, nombre from public.ts_equipos where id_flota = 0 and tiem_elimin is null) b
on b.id = a.id_flota
where a.tiem_elimin is null) d
on d.id_secundario = c.id_flota
where c.id_flota <> 0 and c.isflota = false and c.tiem_elimin is null
order by d.id_principal


-- Mi query practice of recursive query 

select d.principal principal, d.nombre_principal nombre_principal ,d.secundario secundario, d.nombre_secundario nombre_secundario,
e.id_equipo, e.nombre nombre_equipo
from public.ts_equipos e
inner join (select  b.id_equipo principal, b.nombre nombre_principal ,a.id_equipo secundario, a.nombre nombre_secundario 
from public.ts_equipos a
inner join (select id_equipo, nombre from public.ts_equipos
where id_flota = 0 and tiem_elimin is null) b
on a.id_flota = b.id_equipo    -- id_flota es column que tiene la diferenciacion de los 3 niveles(principal, secun, equipo)
where a.id_flota <> 0 and a.isflota = 'true' and a.tiem_elimin is null) d
on e.id_flota = d.secundario
where e.id_flota <> 0 and e.isflota = false and e.tiem_elimin is null
order by d.principal






-- 3. Tabla principal Tiempo Ready por Actividad Acarreo
select id_equipo, tiem_llegada, tiem_esperando, tiem_cuadra, tiem_cuadrado, tiem_carga,
tiem_acarreo, tiem_cola, tiem_retro, tiem_listo, tiem_descarga, tiem_viajando, 
getreadytime(id_equipo, tiem_llegada, tiem_esperando) tiempo_ready_llegada_esperando,
getreadytime(id_equipo, tiem_esperando, tiem_cuadra) tiempo_ready_esperando_cuadra,
getreadytime(id_equipo, tiem_cuadra, tiem_cuadrado) tiempo_ready_cuadra_cuadrado,
getreadytime(id_equipo, tiem_cuadrado, tiem_carga) tiempo_ready_cuadrado_cargado,
getreadytime(id_equipo, tiem_carga, tiem_acarreo) tiempo_ready_carga_acarreo,
getreadytime(id_equipo, tiem_acarreo, tiem_cola) tiempo_ready_acarreo_cola,
getreadytime(id_equipo, tiem_cola, tiem_retro) tiempo_ready_cola_retro,
getreadytime(id_equipo, tiem_retro, tiem_listo) tiempo_ready_retro_listo,
getreadytime(id_equipo, tiem_listo, tiem_descarga) tiempo_ready_listo_descarga,
getreadytime(id_equipo, tiem_descarga, tiem_viajando) tiempo_ready_descarga_viajandovacio
from public.tp_cargadescarga
where id_equipo = 32 and tiem_llegada > '2022-12-03' and tiem_cuadra is not null
limit 100


-- 4. Tabla principal Tiempo Ready por Actividad Carguio
SELECT tp.id_equipo as id_equipo_carguio, 
tp.id_locacion, 
tp.id_poligono,
tcd1.tiem_carga as inicio_carga_carguio,
tcd1.tiem_acarreo as tiempo_esperando_carguio,
getreadytime( tp.id_equipo, tcd1.tiem_carga, tcd1.tiem_acarreo) tiempo_ready_cargando,
getreadytime( tp.id_equipo, 
			 lag(tcd1.tiem_acarreo) OVER (PARTITION BY (COALESCE(null, true)), tp.id_equipo ORDER BY tcd1.tiem_carga), 
			 tcd1.tiem_carga) tiempo_ready_esperando,
lag(tcd1.tiem_acarreo) OVER (PARTITION BY (COALESCE(null, true)), tp.id_equipo ORDER BY tcd1.tiem_carga) AS previous_esperando_pala,
tcd1.tiem_acarreo,
tcd1.tiem_carga,
tcd1.*
FROM tp_cargadescarga tcd1
LEFT JOIN tp_palas tp ON tp.id = (SELECT id 
						  FROM tp_palas 
						 	WHERE id_palas = tcd1.id_palas
						 	ORDER BY ID DESC LIMIT 1)
WHERE tcd1.tiem_elimin IS NULL
AND tcd1.tiem_viajando IS NOT NULL
and tp.id_equipo = 73
ORDER BY tcd1.ID, tcd1.tiem_llegada asc 
LIMIT 100

