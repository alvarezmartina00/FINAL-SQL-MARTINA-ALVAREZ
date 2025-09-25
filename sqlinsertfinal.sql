-- 2_insert_data_gestion_turnos.sql
USE gestion_turnos_final;

-- Insertar roles y usuarios
INSERT INTO rol (nombre_rol) VALUES ('admin'),('recepcion'),('medico');
INSERT INTO usuario (username, password_hash, id_rol, nombre, apellido)
VALUES ('admin','$2y$...hash_ejemplo',1,'Admin','Sistema'),
       ('recep1','$2y$...hash',2,'Ana','Lopez');

-- Especialidades y medicos
INSERT INTO especialidad (nombre) VALUES ('Cardiología'),('Pediatría'),('Dermatología'),('Traumatología'),('Endocrinología');

INSERT INTO medico (nombre, apellido, matricula, id_especialidad, telefono, email)
VALUES ('Juan','Pérez','MAT123',1,'1123456789','juan.perez@clinica.local'),
       ('María','Gómez','MAT456',2,'1134567890','maria.gomez@clinica.local'),
       ('Luis','Rodríguez','MAT789',3,'1145678901','luis.rodriguez@clinica.local');

-- Consultorios
INSERT INTO consultorio (nombre, piso) VALUES ('Consultorio A','1'),('Consultorio B','1'),('Consultorio C','2');

-- Pacientes
INSERT INTO paciente (nombre, apellido, dni, telefono, fecha_nacimiento, direccion, obra_social)
VALUES ('Carlos','Ramírez','30123456','1156789012','1985-04-15','Calle Falsa 123','OSDE'),
       ('Lucía','Martínez','40234567','1167890123','1990-07-20','Av. Siempre Viva 742','PAMI'),
       ('Marcos','Sosa','50345678','1178901234','2005-09-01','Calle Real 45','Ninguna');

-- Turnos (fechas futuras)
INSERT INTO turno (id_paciente, id_medico, id_consultorio, fecha, hora, duracion_min, estado, motivo)
VALUES (1,1,1,'2025-10-01','10:00:00',30,'pendiente','Control cardiología'),
       (2,2,2,'2025-10-01','11:00:00',30,'pendiente','Consulta pediatría'),
       (3,1,1,'2025-10-02','09:30:00',30,'pendiente','Revisión');

-- Llenar hecho_turno para esos turnos (si tu sp no lo hizo)
INSERT IGNORE INTO hecho_turno (id_turno,id_medico,id_paciente,fecha,hora,duracion_min,estado)
SELECT id_turno, id_medico, id_paciente, fecha, hora, duracion_min, estado FROM turno;

-- Medicamentos y prescripciones
INSERT INTO medicamento (nombre, principio_activo, presentacion) VALUES ('Ibuprofeno','Ibuprofeno','Tabletas 400mg');
INSERT INTO prescripcion (id_turno, observaciones) VALUES (1,'Tomar 1 c/8hs');
INSERT INTO prescripcion_medicamento (id_prescripcion, id_medicamento, dosis, frecuencia, duracion)
VALUES (1,1,'400mg','cada 8 horas','5 dias');

-- Examen y resultado
INSERT INTO examen (nombre_examen, instruccion_preparacion) VALUES ('Hemograma','Ayuno 8 horas');
INSERT INTO resultado_examen (id_turno, id_examen, fecha_resultado, resultado) VALUES (1,1,'2025-10-03','Hemograma normal');

-- Facturas y pagos
CALL sp_generar_factura_turno(1,250.00);
INSERT INTO pago (id_factura, fecha_pago, metodo, monto) VALUES (1,CURDATE(),'efectivo',250.00);


-- ========================================
-- NUEVOS PACIENTES (ID 4 en adelante)
-- ========================================
INSERT INTO paciente (id_paciente, nombre, apellido, dni, telefono, fecha_nacimiento, direccion) VALUES
(4, 'Ana', 'Fernández', '32456789', '1154321098', '1988-02-11', 'Pasaje Luna 555'),
(5, 'Pedro', 'Gómez', '28456123', '1145672345', '1975-10-30', 'Av. Libertad 234'),
(6, 'Marta', 'Díaz', '41567234', '1165432109', '1995-12-05', 'Calle Sol 999'),
(7, 'Sofía', 'Torres', '39567123', '1176543210', '1982-08-17', 'Bv. Central 800'),
(8, 'Jorge', 'Morales', '36543210', '1187654321', '1970-06-03', 'Ruta 8 km 12'),
(9, 'Valentina', 'Ríos', '40567890', '1198765432', '1993-03-25', 'Diagonal Sur 77'),
(10, 'Andrés', 'López', '37567890', '1112345678', '1987-11-12', 'Av. Patria 120'),
(11, 'Carla', 'Vega', '45567890', '1135678901', '1991-09-10', 'Calle Naranja 45'),
(12, 'Fernando', 'Molina', '48567890', '1145678902', '1983-01-15', 'Av. Azul 78'),
(13, 'Luciano', 'Campos', '49567891', '1155678903', '2000-07-21', 'Calle Verde 12'),
(14, 'Jimena', 'Paredes', '50567892', '1165678904', '1997-11-30', 'Bv. Amarillo 101'),
(15, 'Esteban', 'Rojas', '51567893', '1175678905', '1980-03-03', 'Av. Marrón 23'),
(16, 'Natalia', 'Fuentes', '52567894', '1185678906', '1992-05-19', 'Calle Gris 56'),
(17, 'Matías', 'Herrera', '53567895', '1195678907', '1986-08-08', 'Pasaje Rojo 89'),
(18, 'Gabriela', 'Santos', '54567896', '1115678908', '1999-12-12', 'Av. Lila 77'),
(19, 'Tomás', 'Ortiz', '55567897', '1125678909', '2001-02-02', 'Calle Fucsia 11'),
(20, 'Marina', 'Cabrera', '56567898', '1135678910', '1984-06-06', 'Av. Celeste 34');

-- ========================================
-- NUEVOS MÉDICOS (ID 4 en adelante)
-- ========================================
INSERT INTO medico (id_medico, nombre, apellido, matricula, id_especialidad, telefono, email) VALUES
(4, 'Laura', 'Benítez', 'MAT321', 4, '1156789012', 'laura.benitez@clinica.local'),
(5, 'Diego', 'Suárez', 'MAT654', 5, '1167890123', 'diego.suarez@clinica.local'),
(6, 'Claudia', 'Romero', 'MAT987', 1, '1178901234', 'claudia.romero@clinica.local'),
(7, 'Héctor', 'Navarro', 'MAT159', 2, '1189012345', 'hector.navarro@clinica.local'),
(8, 'Patricia', 'Iglesias', 'MAT753', 3, '1190123456', 'patricia.iglesias@clinica.local'),
(9, 'Ricardo', 'Vidal', 'MAT852', 4, '1111234567', 'ricardo.vidal@clinica.local');

-- ========================================
-- NUEVOS TURNOS (ID 16 en adelante)
-- ========================================
INSERT INTO turno (id_turno, id_paciente, id_medico, fecha, hora) VALUES
(16, 4, 4, '2025-09-29', '09:00:00'),
(17, 5, 5, '2025-09-29', '09:30:00'),
(18, 6, 1, '2025-09-29', '10:00:00'),
(19, 7, 2, '2025-09-29', '10:30:00'),
(20, 8, 3, '2025-09-29', '11:00:00'),
(21, 9, 4, '2025-09-29', '11:30:00'),
(22, 10, 5, '2025-09-29', '12:00:00'),
(23, 11, 6, '2025-09-30', '09:00:00'),
(24, 12, 7, '2025-09-30', '09:30:00'),
(25, 13, 8, '2025-09-30', '10:00:00'),
(26, 14, 9, '2025-09-30', '10:30:00'),
(27, 15, 4, '2025-09-30', '11:00:00'),
(28, 16, 5, '2025-09-30', '11:30:00'),
(29, 17, 6, '2025-10-01', '09:00:00'),
(30, 18, 7, '2025-10-01', '09:30:00'),
(31, 19, 8, '2025-10-01', '10:00:00'),
(32, 20, 9, '2025-10-01', '10:30:00');


-- Insertar facturas para los turnos indicados
INSERT INTO factura (id_turno, total, estado_pago) VALUES
(16, 250.00, 'pendiente'),
(17, 200.00, 'pagado'),
(18, 180.00, 'pendiente'),
(19, 220.00, 'pagado'),
(20, 210.00, 'pendiente'),
(21, 230.00, 'pagado'),
(22, 190.00, 'pendiente'),
(23, 205.00, 'pagado'),
(24, 180.00, 'pendiente'),
(25, 240.00, 'pagado'),
(26, 195.00, 'pendiente'),
(27, 210.00, 'pagado'),
(28, 170.00, 'pendiente'),
(29, 220.00, 'pagado'),
(30, 185.00, 'pendiente'),
(1, 250.00, 'pagado'),   -- Carlos Ramírez
(31, 200.00, 'pendiente'),
(32, 215.00, 'pagado'),
(2, 180.00, 'pendiente'), -- Lucía Martínez
(3, 200.00, 'pagado');    -- Marcos Sosa
