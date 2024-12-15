/*
-- Deshabilitar verificaciones de claves foráneas
SET FOREIGN_KEY_CHECKS = 0;

-- Eliminar tablas en orden
DROP TABLE IF EXISTS MUNICIPIO;
DROP TABLE IF EXISTS VIVIENDA_PROPIETARIO;
DROP TABLE IF EXISTS VIVIENDA;
DROP TABLE IF EXISTS PERSONA;
DROP TABLE IF EXISTS DEPARTAMENTO;
DROP TABLE IF EXISTS TIPO_DOCUMENTO;

DROP TRIGGER IF EXISTS validate_gobernador_residence;

-- Habilitar nuevamente las verificaciones de claves foráneas
SET FOREIGN_KEY_CHECKS = 1;
*/

-- Crear Tablas
CREATE TABLE DEPARTAMENTO (
    id_departamento INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre_departamento VARCHAR(64) NOT NULL,
    id_gobernador INT UNSIGNED  
);

CREATE TABLE MUNICIPIO (
    id_municipio INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre_municipio VARCHAR(128) NOT NULL,
    id_departamento INT UNSIGNED NOT NULL  
);

CREATE TABLE VIVIENDA (
    id_vivienda INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    direccion VARCHAR(256) NOT NULL,
    id_municipio INT UNSIGNED NOT NULL  
);

CREATE TABLE TIPO_DOCUMENTO (
    id_tipo_documento INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo_documento VARCHAR(64) NOT NULL
);

CREATE TABLE PERSONA (
    id_persona INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_tipo_documento INT UNSIGNED NOT NULL,  
    dni VARCHAR(32) NOT NULL,
    nombre1 VARCHAR(64) NOT NULL,
    nombre2 VARCHAR(128),
    apellido1 VARCHAR(64) NOT NULL,
    apellido2 VARCHAR(128),
    mayor_de_edad BOOL NOT NULL,
    id_cabeza_familia INT UNSIGNED,  
    id_recidencia INT UNSIGNED NOT NULL  
);

CREATE TABLE VIVIENDA_PROPIETARIO (
    id_vivienda INT UNSIGNED NOT NULL,
    id_persona INT UNSIGNED NOT NULL,
    porcentaje_propiedad SMALLINT NOT NULL CHECK (porcentaje_propiedad >= 0 AND porcentaje_propiedad <= 100),
    PRIMARY KEY (id_vivienda, id_persona) 
);

-- Añadir claves foráneas
ALTER TABLE MUNICIPIO
ADD CONSTRAINT fk_municipio_departamento
FOREIGN KEY (id_departamento) REFERENCES DEPARTAMENTO(id_departamento);

ALTER TABLE VIVIENDA
ADD CONSTRAINT fk_vivienda_municipio
FOREIGN KEY (id_municipio) REFERENCES MUNICIPIO(id_municipio);

ALTER TABLE PERSONA
ADD CONSTRAINT fk_persona_tipo_documento
FOREIGN KEY (id_tipo_documento) REFERENCES TIPO_DOCUMENTO(id_tipo_documento),
ADD CONSTRAINT fk_persona_cabeza_familia
FOREIGN KEY (id_cabeza_familia) REFERENCES PERSONA(id_persona),
ADD CONSTRAINT fk_persona_recidencia
FOREIGN KEY (id_recidencia) REFERENCES VIVIENDA(id_vivienda);

ALTER TABLE DEPARTAMENTO
ADD CONSTRAINT fk_departamento_gobernador
FOREIGN KEY (id_gobernador) REFERENCES PERSONA(id_persona);

ALTER TABLE DEPARTAMENTO
ADD CONSTRAINT unique_gobernador UNIQUE (id_gobernador);

ALTER TABLE VIVIENDA_PROPIETARIO
ADD CONSTRAINT fk_vivienda_propietario_vivienda
FOREIGN KEY (id_vivienda) REFERENCES VIVIENDA(id_vivienda),
ADD CONSTRAINT fk_vivienda_propietario_persona
FOREIGN KEY (id_persona) REFERENCES PERSONA(id_persona);

-- Restricciones adicionales
-- Check para mayores de edad con C.C.
ALTER TABLE PERSONA
ADD CONSTRAINT chk_tipo_documento_mayor_de_edad
CHECK (
    (id_tipo_documento = 1 AND mayor_de_edad = TRUE) OR (id_tipo_documento <> 1)
);

ALTER TABLE PERSONA
ADD CONSTRAINT chk_gobernador_tipo_documento CHECK (id_tipo_documento = 1);

/*

DELIMITER $$

CREATE TRIGGER validate_gobernador_residence
BEFORE INSERT ON DEPARTAMENTO
FOR EACH ROW
BEGIN
    DECLARE id_departamento_gobernador INT;

    -- Verificar el departamento del gobernador
    SELECT m.id_departamento
    INTO id_departamento_gobernador
    FROM PERSONA p
    JOIN VIVIENDA v ON v.id_vivienda = p.id_recidencia
    JOIN MUNICIPIO m ON m.id_municipio = v.id_municipio
    WHERE p.id_persona = NEW.id_gobernador;

    -- Validar que el gobernador resida en el municipio del departamento que gobierna
    IF NEW.id_departamento <> id_departamento_gobernador THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El gobernador no reside en el municipio del departamento que gobierna.';
    END IF;
END$$
 
DELIMITER ;
/*