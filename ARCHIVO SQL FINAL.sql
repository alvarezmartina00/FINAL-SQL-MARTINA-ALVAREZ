-- 1_create_schema_gestion_turnos.sql
-- CREAR BASE DE DATOS
DROP DATABASE IF EXISTS gestion_turnos_final;
CREATE DATABASE gestion_turnos_final CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE gestion_turnos_final;

-- TABLAS MAESTRAS / CATALOGOS
CREATE TABLE especialidad (
    id_especialidad INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE medico (
    id_medico INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    matricula VARCHAR(20) UNIQUE NOT NULL,
    id_especialidad INT NOT NULL,
    telefono VARCHAR(30),
    email VARCHAR(100),
    activo TINYINT(1) DEFAULT 1,
    FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad)
);

CREATE TABLE paciente (
    id_paciente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    dni VARCHAR(20) UNIQUE NOT NULL,
    telefono VARCHAR(30),
    fecha_nacimiento DATE,
    direccion VARCHAR(200),
    obra_social VARCHAR(100)
);

CREATE TABLE consultorio (
    id_consultorio INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    piso VARCHAR(10),
    observaciones VARCHAR(200)
);

CREATE TABLE rol (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    id_rol INT NOT NULL,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    activo TINYINT(1) DEFAULT 1,
    FOREIGN KEY (id_rol) REFERENCES rol(id_rol)
);

CREATE TABLE horario (
    id_horario INT AUTO_INCREMENT PRIMARY KEY,
    id_medico INT NOT NULL,
    dia_semana TINYINT NOT NULL, -- 1= lunes ... 7= domingo
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
);

CREATE TABLE seguro (
    id_seguro INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    telefono VARCHAR(50),
    direccion VARCHAR(200)
);

-- TRANSACCIONALES / OPERACIONALES
CREATE TABLE turno (
    id_turno INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,
    id_consultorio INT,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    duracion_min INT DEFAULT 30,
    estado ENUM('pendiente','atendido','cancelado','no_show') DEFAULT 'pendiente',
    motivo VARCHAR(255),
    creado_en DATETIME DEFAULT NOW(),
    actualizado_en DATETIME DEFAULT NOW() ON UPDATE NOW(),
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico),
    FOREIGN KEY (id_consultorio) REFERENCES consultorio(id_consultorio),
    UNIQUE (id_medico, fecha, hora) -- evita duplicados
);

-- Tabla de log de cambios de turno (ya tenías algo parecido)
CREATE TABLE log_cambios_turno (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_turno INT,
    estado_anterior VARCHAR(20),
    estado_nuevo VARCHAR(20),
    fecha_cambio DATETIME DEFAULT NOW(),
    usuario_id INT,
    FOREIGN KEY (id_turno) REFERENCES turno(id_turno),
    FOREIGN KEY (usuario_id) REFERENCES usuario(id_usuario)
);

-- FACT TABLE para análisis (hecho_turno)
CREATE TABLE hecho_turno (
    id_hecho INT AUTO_INCREMENT PRIMARY KEY,
    id_turno INT UNIQUE,
    id_medico INT,
    id_paciente INT,
    fecha DATE,
    hora TIME,
    duracion_min INT,
    estado VARCHAR(50),
    fact_costo DECIMAL(10,2) DEFAULT 0.00,
    created_at DATETIME DEFAULT NOW(),
    FOREIGN KEY (id_turno) REFERENCES turno(id_turno),
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico),
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente)
);

-- FACTURACION / PAGOS (transaccionales)
CREATE TABLE factura (
    id_factura INT AUTO_INCREMENT PRIMARY KEY,
    id_turno INT,
    fecha_emision DATE DEFAULT (CURRENT_DATE),
total DECIMAL(10,2) NOT NULL,
    estado_pago ENUM('pendiente','pagado','anulado') DEFAULT 'pendiente',
    FOREIGN KEY (id_turno) REFERENCES turno(id_turno)
);

CREATE TABLE pago (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_factura INT,
    fecha_pago DATE,
    metodo VARCHAR(50),
    monto DECIMAL(10,2),
    referencia VARCHAR(100),
    FOREIGN KEY (id_factura) REFERENCES factura(id_factura)
);

-- PRESCRIPCIONES Y MEDICAMENTOS
CREATE TABLE medicamento (
    id_medicamento INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150),
    principio_activo VARCHAR(150),
    presentacion VARCHAR(100)
);

CREATE TABLE prescripcion (
    id_prescripcion INT AUTO_INCREMENT PRIMARY KEY,
    id_turno INT,
    fecha DATE DEFAULT (CURRENT_DATE),
    observaciones TEXT,
    FOREIGN KEY (id_turno) REFERENCES turno(id_turno)
);

CREATE TABLE prescripcion_medicamento (
    id_prescripcion_med INT AUTO_INCREMENT PRIMARY KEY,
    id_prescripcion INT,
    id_medicamento INT,
    dosis VARCHAR(100),
    frecuencia VARCHAR(100),
    duracion VARCHAR(100),
    FOREIGN KEY (id_prescripcion) REFERENCES prescripcion(id_prescripcion),
    FOREIGN KEY (id_medicamento) REFERENCES medicamento(id_medicamento)
);

-- EXAMENES / RESULTADOS
CREATE TABLE examen (
    id_examen INT AUTO_INCREMENT PRIMARY KEY,
    nombre_examen VARCHAR(150),
    instruccion_preparacion VARCHAR(255)
);

CREATE TABLE resultado_examen (
    id_resultado INT AUTO_INCREMENT PRIMARY KEY,
    id_turno INT,
    id_examen INT,
    fecha_resultado DATE,
    resultado TEXT,
    archivo_url VARCHAR(255),
    FOREIGN KEY (id_turno) REFERENCES turno(id_turno),
    FOREIGN KEY (id_examen) REFERENCES examen(id_examen)
);

-- REFERENCIAS / DERIVACIONES
CREATE TABLE derivacion (
    id_derivacion INT AUTO_INCREMENT PRIMARY KEY,
    id_turno INT,
    hacia_especialidad_id INT,
    observacion TEXT,
    fecha_derivacion DATE,
    FOREIGN KEY (id_turno) REFERENCES turno(id_turno),
    FOREIGN KEY (hacia_especialidad_id) REFERENCES especialidad(id_especialidad)
);

-- INDICES Y VISTAS ADICIONALES
CREATE INDEX idx_turno_fecha ON turno(fecha);
CREATE INDEX idx_turno_medico ON turno(id_medico);

-- VISTAS (5+)
CREATE VIEW vista_turnos_detallados AS
SELECT t.id_turno, t.fecha, t.hora, t.estado, t.duracion_min,
       p.id_paciente, CONCAT(p.nombre,' ',p.apellido) AS paciente,
       m.id_medico, CONCAT(m.nombre,' ',m.apellido) AS medico,
       e.nombre AS especialidad, c.nombre AS consultorio
FROM turno t
JOIN paciente p ON t.id_paciente = p.id_paciente
JOIN medico m ON t.id_medico = m.id_medico
LEFT JOIN especialidad e ON m.id_especialidad = e.id_especialidad
LEFT JOIN consultorio c ON t.id_consultorio = c.id_consultorio;

CREATE VIEW vista_pacientes_edad AS
SELECT p.id_paciente, p.nombre, p.apellido, p.fecha_nacimiento,
       TIMESTAMPDIFF(YEAR, p.fecha_nacimiento, CURDATE()) AS edad
FROM paciente p;

CREATE VIEW vista_turnos_por_medico AS
SELECT m.id_medico, CONCAT(m.nombre,' ',m.apellido) AS medico,
       COUNT(t.id_turno) AS total_turnos
FROM medico m
LEFT JOIN turno t ON m.id_medico = t.id_medico
GROUP BY m.id_medico, m.nombre, m.apellido;

CREATE VIEW vista_facturacion_diaria AS
SELECT f.fecha_emision, COUNT(f.id_factura) AS cantidad_facturas, SUM(f.total) AS total_facturado
FROM factura f
GROUP BY f.fecha_emision
ORDER BY f.fecha_emision;

CREATE VIEW vista_turnos_estado_fecha AS
SELECT fecha, estado, COUNT(*) AS cantidad
FROM turno
GROUP BY fecha, estado;

-- FUNCIONES (2+)
DELIMITER //
CREATE FUNCTION fn_calcular_edad(fecha_nac DATE) 
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, fecha_nac, CURDATE());
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_nombre_completo_paciente(id INT)
RETURNS VARCHAR(200)
DETERMINISTIC
BEGIN
    DECLARE nombre_completo VARCHAR(200);
    SELECT CONCAT(nombre, ' ', apellido) INTO nombre_completo
    FROM paciente WHERE id_paciente = id;
    RETURN nombre_completo;
END //
DELIMITER ;

-- PROCEDIMIENTOS (2+)
DELIMITER //
CREATE PROCEDURE sp_registrar_turno(
    IN p_id_paciente INT,
    IN p_id_medico INT,
    IN p_consultorio INT,
    IN p_fecha DATE,
    IN p_hora TIME,
    IN p_duracion INT
)
BEGIN
    INSERT INTO turno (id_paciente, id_medico, id_consultorio, fecha, hora, duracion_min, estado)
    VALUES (p_id_paciente, p_id_medico, p_consultorio, p_fecha, p_hora, p_duracion, 'pendiente');
    -- Insertar en tabla de hechos para analítica
    INSERT INTO hecho_turno (id_turno, id_medico, id_paciente, fecha, hora, duracion_min, estado)
    VALUES (LAST_INSERT_ID(), p_id_medico, p_id_paciente, p_fecha, p_hora, p_duracion, 'pendiente');
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_cambiar_estado_turno(
    IN p_id_turno INT,
    IN p_estado VARCHAR(20),
    IN p_usuario INT
)
BEGIN
    DECLARE v_old_estado VARCHAR(20);
    SELECT estado INTO v_old_estado FROM turno WHERE id_turno = p_id_turno;
    UPDATE turno
    SET estado = p_estado
    WHERE id_turno = p_id_turno;
    -- registrar log
    INSERT INTO log_cambios_turno (id_turno, estado_anterior, estado_nuevo, fecha_cambio, usuario_id)
    VALUES (p_id_turno, v_old_estado, p_estado, NOW(), p_usuario);
    -- actualizar hecho_turno si existe
    UPDATE hecho_turno SET estado = p_estado WHERE id_turno = p_id_turno;
END //
DELIMITER ;

-- PROCEDIMIENTO: generar factura simple para un turno
DELIMITER //
CREATE PROCEDURE sp_generar_factura_turno(
    IN p_id_turno INT,
    IN p_total DECIMAL(10,2)
)
BEGIN
    INSERT INTO factura (id_turno, fecha_emision, total, estado_pago)
    VALUES (p_id_turno, CURDATE(), p_total, 'pendiente');
END //
DELIMITER ;

-- TRIGGERS (2+)
DELIMITER //
CREATE TRIGGER trg_validar_fecha_turno
BEFORE INSERT ON turno
FOR EACH ROW
BEGIN
    IF NEW.fecha < CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede asignar un turno en una fecha pasada';
    END IF;
END //
DELIMITER ;

-- Trigger log de cambios estado (antes subiste versión; la adapté)
DELIMITER //
CREATE TRIGGER trg_log_estado_turno
BEFORE UPDATE ON turno
FOR EACH ROW
BEGIN
    IF OLD.estado <> NEW.estado THEN
        INSERT INTO log_cambios_turno (id_turno, estado_anterior, estado_nuevo, fecha_cambio)
        VALUES (OLD.id_turno, OLD.estado, NEW.estado, NOW());
    END IF;
END //
DELIMITER ;

-- FIN DEL SCRIPT DE CREACION
