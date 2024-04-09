-- Consultas SQL para el proyecto de base de datos
---------------------------------------------------------------------
-- 1. Horario con menos citas durante el día por peluquería, identificando la comuna.
SELECT 
    dia_semana, 
    bloque_horario, 
    peluqueria, 
    comuna, 
    num_citas
FROM (
    SELECT 
        h.dia_semana, 
        h.bloque_horario, 
        p.nombre AS peluqueria, 
        c.nombre AS comuna, 
        COUNT(ci.id_cita) AS num_citas,
        RANK() OVER (PARTITION BY p.nombre, c.nombre ORDER BY COUNT(ci.id_cita)) AS rnk
    FROM 
        cita ci
    JOIN 
        cliente_pelu cp ON ci.id_cliente_pelu = cp.id_cliente_pelu
    JOIN 
        peluqueria p ON cp.id_peluqueria = p.id_peluqueria
    JOIN 
        comuna c ON p.id_comuna = c.id_comuna
    JOIN 
        horarios h ON ci.id_horario = h.id_horario
    GROUP BY 
        h.dia_semana, h.bloque_horario, p.nombre, c.nombre
) AS subquery
WHERE 
    rnk = 1
ORDER BY 
    peluqueria, comuna, num_citas, dia_semana, bloque_horario;

-- 2. Lista de clientes que gastan más dinero mensual por peluquería, indicando la comuna del cliente y de la peluquería, además de cuanto gasto el cliente.

SELECT 
    sub.peluqueria, 
    sub.comuna_peluqueria, 
    sub.comuna_cliente, 
    sub.nombre, 
    sub.apellido, 
    sub.mes, 
    sub.total_gasto
FROM (
    SELECT 
        p.nombre AS peluqueria, 
        com1.nombre AS comuna_peluqueria, 
        com2.nombre AS comuna_cliente, 
        cl.nombre, 
        cl.apellido, 
        EXTRACT(MONTH FROM pa.fecha_pago) AS mes, 
        EXTRACT(YEAR FROM pa.fecha_pago) AS año, 
        SUM(pa.monto) AS total_gasto,
        RANK() OVER (PARTITION BY p.nombre, EXTRACT(MONTH FROM pa.fecha_pago), EXTRACT(YEAR FROM pa.fecha_pago) ORDER BY SUM(pa.monto) DESC) AS rank
    FROM 
        pago pa
    JOIN 
        detalle d ON pa.id_pago = d.id_pago
    JOIN 
        cita ci ON d.id_cita = ci.id_cita
    JOIN 
        cliente_pelu cp ON ci.id_cliente_pelu = cp.id_cliente_pelu
    JOIN 
        cliente cl ON cp.id_cliente = cl.id_cliente
    JOIN 
        peluqueria p ON cp.id_peluqueria = p.id_peluqueria
    JOIN 
        comuna com1 ON p.id_comuna = com1.id_comuna
    JOIN 
        comuna com2 ON cl.id_comuna = com2.id_comuna
    GROUP BY 
        p.nombre, com1.nombre, com2.nombre, cl.nombre, cl.apellido, EXTRACT(MONTH FROM pa.fecha_pago), EXTRACT(YEAR FROM pa.fecha_pago)
) sub
WHERE 
    sub.rank = 1
ORDER BY 
    sub.peluqueria, sub.mes, sub.año;

-- 3. Lista de peluqueros por peluquería que han ganado más por mes los últimos 3 años.

SELECT e.id_empleado, e.nombre, e.apellido, p.nombre AS peluqueria, 
       EXTRACT(YEAR FROM s.fecha_pago) AS año, 
       EXTRACT(MONTH FROM s.fecha_pago) AS mes, 
       MAX(s.monto) AS monto_maximo
FROM sueldo s
JOIN empleado e ON s.id_sueldo = e.id_sueldo
JOIN peluqueria p ON e.id_peluqueria = p.id_peluqueria
WHERE EXTRACT(YEAR FROM s.fecha_pago) >= EXTRACT(YEAR FROM CURRENT_DATE) - 3
GROUP BY e.id_empleado, e.nombre, e.apellido, p.nombre, EXTRACT(YEAR FROM s.fecha_pago), EXTRACT(MONTH FROM s.fecha_pago)
ORDER BY año, mes, monto_maximo DESC;

-- 4. Lista de clientes hombres que se cortan el pelo y la barba.
SELECT c.id_cliente, c.nombre, c.apellido
FROM cliente c
JOIN cliente_pelu cp ON c.id_cliente = cp.id_cliente
JOIN cita ci ON cp.id_cliente_pelu = ci.id_cliente_pelu
JOIN detalle d ON ci.id_cita = d.id_cita
JOIN servicio s ON d.id_servicio = s.id_servicio
WHERE c.genero = 'Masculino' AND s.nombre = 'Corte y Barba';


-- 5. Lista de clientes que se tiñen el pelo, indicando la comuna del cliente, la peluquería donde se atendió y el valor que pagó.

select distinct cl.nombre, com.nombre as comuna_cliente, pe.nombre as nombre_peluqueria, pa.monto
from servicio as s, cliente_pelu as cp, cita as ci, cliente as cl, 
     comuna as com, pago as pa, peluqueria as pe, detalle as de
where   s.nombre = 'Teñir Cabello' and s.id_servicio = de.id_servicio
		and de.id_cita = ci.id_cita and cp.id_cliente_pelu = ci.id_cliente_pelu 
		and cl.id_cliente = cp.id_cliente_pelu
		and cl.id_comuna = com.id_comuna and pe.id_peluqueria = cp.id_peluqueria 
		and pa.id_pago = de.id_pago

--6. Identificar el horario más concurrido por peluquería durante el 2018 y 2029, desagregados por mes.

SELECT EXTRACT(MONTH FROM c.fecha_hora) AS mes, id_horario , count(*) as concurrencia
FROM public.cita as c
JOIN public.cliente_pelu as cp ON cp.id_cliente_pelu = c.id_cliente_pelu
WHERE c.fecha_hora >= '2019-01-01' and c.fecha_hora <= '2029-12-30'
GROUP BY 
	id_horario,
	EXTRACT(MONTH FROM c.fecha_hora)
ORDER BY concurrencia Desc

-- 7. Identificar al cliente por peluquería que ha tenido las citas más largas por mes.

SELECT 
  p.nombre AS peluqueria, 
  cc.nombre AS cliente, 
  EXTRACT(MONTH FROM c.fecha_hora) AS mes, 
  EXTRACT(YEAR FROM c.fecha_hora) AS año, 
  c.duracion AS duracion_maxima
FROM 
  cita c
JOIN 
  cliente_pelu cp ON c.id_cliente_pelu = cp.id_cliente_pelu
JOIN 
  peluqueria p ON cp.id_peluqueria = p.id_peluqueria
JOIN 
  cliente cc ON cp.id_cliente = cc.id_cliente
WHERE 
  c.duracion = (
    SELECT MAX(c2.duracion)
    FROM cita c2
    WHERE c2.id_cliente_pelu = c.id_cliente_pelu
      AND EXTRACT(MONTH FROM c2.fecha_hora) = EXTRACT(MONTH FROM c.fecha_hora)
      AND EXTRACT(YEAR FROM c2.fecha_hora) = EXTRACT(YEAR FROM c.fecha_hora)
  )
ORDER BY 
  año, mes, p.nombre;

-- 8. Identificar servicio más caro por peluquería.

SELECT p.nombre AS nombre_peluqueria, s.nombre AS nombre_servicio, mx.precio_maximo
FROM (
    SELECT p.id_peluqueria, MAX(s.precio) AS precio_maximo
    FROM public.servicio AS s
    JOIN public.detalle AS d ON s.id_servicio = d.id_servicio
    JOIN public.cita AS c ON d.id_cita = c.id_cita
    JOIN public.cliente_pelu AS cp ON cp.id_cliente_pelu = c.id_cliente_pelu
    JOIN public.peluqueria AS p ON cp.id_peluqueria = p.id_peluqueria
    GROUP BY p.id_peluqueria
) AS mx
JOIN public.peluqueria AS p ON mx.id_peluqueria = p.id_peluqueria
JOIN public.servicio AS s ON mx.precio_maximo = s.precio;

-- 9. Identificar al peluquero que ha trabajado más por mes durante el 2021.

SELECT p.nombre AS peluqueria, em.nombre AS peluquero, EXTRACT(MONTH FROM c.fecha_hora) AS mes, EXTRACT(YEAR FROM c.fecha_hora) AS año, COUNT(*) AS cantidad_citas
FROM peluqueria p
JOIN empleado em ON p.id_peluqueria = em.id_peluqueria
JOIN peluquero pq ON em.id_empleado = pq.id_empleado
JOIN cita c ON pq.id_peluquero = c.id_peluquero
JOIN horarios h ON c.id_horario = h.id_horario
WHERE EXTRACT(YEAR FROM c.fecha_hora) = 2021
GROUP BY p.nombre, em.nombre, mes, año
ORDER BY cantidad_citas DESC
LIMIT 1;

-- 10. Identificar lista de total de peluquerías por comuna, cantidad de peluquerías, cantidad de clientes residentes en la comuna

SELECT 
    c.nombre AS Nombre_Comuna,
    COUNT(DISTINCT p.id_peluqueria) AS Total_Peluquerias,
    COUNT(DISTINCT cl.id_cliente) AS Cantidad_Clientes
FROM 
    comuna c
LEFT JOIN 
    peluqueria p ON c.id_comuna = p.id_comuna
LEFT JOIN 
    cliente cl ON c.id_comuna = cl.id_comuna
GROUP BY 
    c.nombre;


