CREATE TABLE cliente (
  id_cliente int PRIMARY KEY,
  nombre varchar(255),
  apellido varchar(255),
  email varchar(255),
  telefono varchar(255),
  id_comuna int,
  genero varchar(255)
);

CREATE TABLE comuna (
  id_comuna int PRIMARY KEY,
  nombre varchar(255)
);

CREATE TABLE sueldo (
  id_sueldo int PRIMARY KEY,
  monto int,
  fecha_pago timestamp
);

CREATE TABLE peluqueria (
  id_peluqueria int PRIMARY KEY,
  nombre varchar(255),
  direccion varchar(255),
  id_comuna int
);

CREATE TABLE empleado (
  id_empleado int PRIMARY KEY,
  nombre varchar(255),
  apellido varchar(255),
  email varchar(255),
  telefono varchar(255),
  id_peluqueria int,
  id_comuna int,
  id_sueldo int
);

CREATE TABLE peluquero (
  id_peluquero int PRIMARY KEY,
  id_empleado int,
  habilidad varchar(255)
);

CREATE TABLE cliente_pelu (
  id_cliente_pelu int PRIMARY KEY,
  id_cliente int,
  id_peluqueria int
);

CREATE TABLE horarios (
  id_horario int PRIMARY KEY,
  dia_semana varchar(255),
  bloque_horario int
);

CREATE TABLE cita (
  id_cita int PRIMARY KEY,
  id_cliente_pelu int,
  id_peluquero int,
  fecha_hora timestamp,
  id_horario int,
  duracion int
);

CREATE TABLE producto (
  id_producto int PRIMARY KEY,
  nombre varchar(255),
  precio int
);

CREATE TABLE servicio (
  id_servicio int PRIMARY KEY,
  nombre varchar(255),
  precio int
);

CREATE TABLE pago (
  id_pago int PRIMARY KEY,
  monto int,
  fecha_pago date
);

CREATE TABLE detalle (
  id_detalle int PRIMARY KEY,
  id_cita int,
  cantidad_producto int,
  cantidad_servicio int,
  id_pago int,
  id_producto int,
  id_servicio int
);

-- Ahora que todas las tablas principales están creadas, establecemos las relaciones de clave foránea
ALTER TABLE cliente ADD FOREIGN KEY (id_comuna) REFERENCES comuna (id_comuna);
ALTER TABLE peluqueria ADD FOREIGN KEY (id_comuna) REFERENCES comuna (id_comuna);
ALTER TABLE empleado ADD FOREIGN KEY (id_peluqueria) REFERENCES peluqueria (id_peluqueria);
ALTER TABLE empleado ADD FOREIGN KEY (id_sueldo) REFERENCES sueldo (id_sueldo);
ALTER TABLE empleado ADD FOREIGN KEY (id_comuna) REFERENCES comuna (id_comuna);
ALTER TABLE peluquero ADD FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado);
ALTER TABLE cliente_pelu ADD FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente);
ALTER TABLE cliente_pelu ADD FOREIGN KEY (id_peluqueria) REFERENCES peluqueria (id_peluqueria);
ALTER TABLE cita ADD FOREIGN KEY (id_cliente_pelu) REFERENCES cliente_pelu (id_cliente_pelu);
ALTER TABLE cita ADD FOREIGN KEY (id_peluquero) REFERENCES peluquero (id_peluquero);
ALTER TABLE cita ADD FOREIGN KEY (id_horario) REFERENCES horarios (id_horario);
ALTER TABLE detalle ADD FOREIGN KEY (id_cita) REFERENCES cita (id_cita);
ALTER TABLE detalle ADD FOREIGN KEY (id_pago) REFERENCES pago (id_pago);
ALTER TABLE detalle ADD FOREIGN KEY (id_producto) REFERENCES producto (id_producto);
ALTER TABLE detalle ADD FOREIGN KEY (id_servicio) REFERENCES servicio (id_servicio);
