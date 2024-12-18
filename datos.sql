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
-- MySQL dump 10.13  Distrib 8.0.29, for Linux (x86_64)
--
-- Host: Lab0.mysql.pythonanywhere-services.com    Database: Lab0$default
-- ------------------------------------------------------
-- Server version	8.0.39

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `DEPARTAMENTO`
--

DROP TABLE IF EXISTS `DEPARTAMENTO`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `DEPARTAMENTO` (
  `id_departamento` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre_departamento` varchar(64) NOT NULL,
  `id_gobernador` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id_departamento`),
  UNIQUE KEY `unique_gobernador` (`id_gobernador`),
  UNIQUE KEY (nombre_departamento),
  CONSTRAINT `fk_departamento_gobernador` FOREIGN KEY (`id_gobernador`) REFERENCES `PERSONA` (`id_persona`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DEPARTAMENTO`
--

LOCK TABLES `DEPARTAMENTO` WRITE;
/*!40000 ALTER TABLE `DEPARTAMENTO` DISABLE KEYS */;
INSERT INTO `DEPARTAMENTO` VALUES (1,'Antioquia',10),(2,'Nariño',NULL),(6,'Meta',NULL);
/*!40000 ALTER TABLE `DEPARTAMENTO` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MUNICIPIO`
--

DROP TABLE IF EXISTS `MUNICIPIO`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `MUNICIPIO` (
  `id_municipio` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre_municipio` varchar(128) NOT NULL,
  `id_departamento` int unsigned NOT NULL,
  PRIMARY KEY (`id_municipio`),
  KEY `fk_municipio_departamento` (`id_departamento`),
  CONSTRAINT `fk_municipio_departamento` FOREIGN KEY (`id_departamento`) REFERENCES `DEPARTAMENTO` (`id_departamento`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MUNICIPIO`
--

LOCK TABLES `MUNICIPIO` WRITE;
/*!40000 ALTER TABLE `MUNICIPIO` DISABLE KEYS */;
INSERT INTO `MUNICIPIO` VALUES (1,'Medellíns',1),(2,'Barbacoas',2);
/*!40000 ALTER TABLE `MUNICIPIO` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PERSONA`
--

DROP TABLE IF EXISTS `PERSONA`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PERSONA` (
  `id_persona` int unsigned NOT NULL AUTO_INCREMENT,
  `id_tipo_documento` int unsigned NOT NULL,
  `dni` varchar(32) NOT NULL,
  `nombre1` varchar(64) NOT NULL,
  `nombre2` varchar(128) DEFAULT NULL,
  `apellido1` varchar(64) NOT NULL,
  `apellido2` varchar(128) DEFAULT NULL,
  `mayor_de_edad` tinyint(1) NOT NULL,
  `id_cabeza_familia` int unsigned DEFAULT NULL,
  `id_residencia` int unsigned NOT NULL,
  PRIMARY KEY (`id_persona`),
  UNIQUE KEY (dni),
  KEY `fk_persona_tipo_documento` (`id_tipo_documento`),
  KEY `fk_persona_cabeza_familia` (`id_cabeza_familia`),
  KEY `fk_persona_residencia` (`id_residencia`),
  CONSTRAINT `fk_persona_cabeza_familia` FOREIGN KEY (`id_cabeza_familia`) REFERENCES `PERSONA` (`id_persona`),
  CONSTRAINT `fk_persona_recidencia` FOREIGN KEY (`id_residencia`) REFERENCES `VIVIENDA` (`id_vivienda`),
  CONSTRAINT `fk_persona_residencia` FOREIGN KEY (`id_residencia`) REFERENCES `VIVIENDA` (`id_vivienda`),
  CONSTRAINT `fk_persona_tipo_documento` FOREIGN KEY (`id_tipo_documento`) REFERENCES `TIPO_DOCUMENTO` (`id_tipo_documento`),
  CONSTRAINT `chk_tipo_documento_validacion` CHECK ((`id_tipo_documento` in (1,2)))
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PERSONA`
--

LOCK TABLES `PERSONA` WRITE;
/*!40000 ALTER TABLE `PERSONA` DISABLE KEYS */;
INSERT INTO `PERSONA` VALUES (10,1,'1236545','John','Andres','Rua','Cortes',1,NULL,1),(12,1,'12365452','Hernando','','Rodriguez','Gonzalez',1,10,2),(14,1,'1','Fabio','','a','',1,NULL,2),(15,2,'12','Fabio','','2','',0,14,1);
/*!40000 ALTER TABLE `PERSONA` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `TIPO_DOCUMENTO`
--

DROP TABLE IF EXISTS `TIPO_DOCUMENTO`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `TIPO_DOCUMENTO` (
  `id_tipo_documento` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre_tipo_documento` varchar(64) NOT NULL,
  PRIMARY KEY (`id_tipo_documento`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `TIPO_DOCUMENTO`
--

LOCK TABLES `TIPO_DOCUMENTO` WRITE;
/*!40000 ALTER TABLE `TIPO_DOCUMENTO` DISABLE KEYS */;
INSERT INTO `TIPO_DOCUMENTO` VALUES (1,'Cédula de Ciudadanía'),(2,'Tarjeta de Identidad');
/*!40000 ALTER TABLE `TIPO_DOCUMENTO` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `VIVIENDA`
--

DROP TABLE IF EXISTS `VIVIENDA`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `VIVIENDA` (
  `id_vivienda` int unsigned NOT NULL AUTO_INCREMENT,
  `direccion` varchar(256) NOT NULL,
  `id_municipio` int unsigned NOT NULL,
  PRIMARY KEY (`id_vivienda`),
  KEY `fk_vivienda_municipio` (`id_municipio`),
  CONSTRAINT `fk_vivienda_municipio` FOREIGN KEY (`id_municipio`) REFERENCES `MUNICIPIO` (`id_municipio`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `VIVIENDA`
--

LOCK TABLES `VIVIENDA` WRITE;
/*!40000 ALTER TABLE `VIVIENDA` DISABLE KEYS */;
INSERT INTO `VIVIENDA` VALUES (1,'Calle 123 #45-67',1),(2,'Carrera 2 #9',2);
/*!40000 ALTER TABLE `VIVIENDA` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `VIVIENDA_PROPIETARIO`
--

DROP TABLE IF EXISTS `VIVIENDA_PROPIETARIO`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `VIVIENDA_PROPIETARIO` (
  `id_vivienda` int unsigned NOT NULL,
  `id_persona` int unsigned NOT NULL,
  `porcentaje_propiedad` smallint NOT NULL,
  PRIMARY KEY (`id_vivienda`,`id_persona`),
  KEY `fk_vivienda_propietario_persona` (`id_persona`),
  CONSTRAINT `fk_vivienda_propietario_persona` FOREIGN KEY (`id_persona`) REFERENCES `PERSONA` (`id_persona`),
  CONSTRAINT `fk_vivienda_propietario_vivienda` FOREIGN KEY (`id_vivienda`) REFERENCES `VIVIENDA` (`id_vivienda`),
  CONSTRAINT `VIVIENDA_PROPIETARIO_chk_1` CHECK (((`porcentaje_propiedad` >= 0) and (`porcentaje_propiedad` <= 100)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `VIVIENDA_PROPIETARIO`
--

LOCK TABLES `VIVIENDA_PROPIETARIO` WRITE;
/*!40000 ALTER TABLE `VIVIENDA_PROPIETARIO` DISABLE KEYS */;
/*!40000 ALTER TABLE `VIVIENDA_PROPIETARIO` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-12-16 23:17:13
