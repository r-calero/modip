CREATE DATABASE  IF NOT EXISTS `censa` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `censa`;
-- MySQL dump 10.13  Distrib 5.5.40, for debian-linux-gnu (x86_64)
--
-- Host: 127.0.0.1    Database: censa
-- ------------------------------------------------------
-- Server version	5.5.40-0ubuntu0.14.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `assay_notification_types`
--

DROP TABLE IF EXISTS `assay_notification_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assay_notification_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `assay_notifications`
--

DROP TABLE IF EXISTS `assay_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assay_notifications` (
  `notification_id` int(11) NOT NULL,
  `aid` varchar(45) NOT NULL,
  `assay_notification_type_id` int(11) NOT NULL,
  KEY `fk1_notifications` (`notification_id`),
  KEY `fk1_assay_notifications` (`notification_id`),
  KEY `fk2_assay_notification_types` (`assay_notification_type_id`),
  CONSTRAINT `fk1_assay_notifications` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk2_assay_notification_types` FOREIGN KEY (`assay_notification_type_id`) REFERENCES `assay_notification_types` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `assays`
--

DROP TABLE IF EXISTS `assays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assays` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `target_id` int(11) NOT NULL,
  `aid` varchar(50) NOT NULL,
  `path` varchar(256) NOT NULL,
  `name` varchar(512) NOT NULL,
  `description` longtext NOT NULL,
  `number_of_tids` int(11) NOT NULL,
  `sid_all` int(11) DEFAULT '0',
  `sid_active` int(11) DEFAULT '0',
  `sid_inactive` int(11) DEFAULT '0',
  `cid_all` int(11) DEFAULT '0',
  `cid_active` int(11) DEFAULT '0',
  `cid_inactive` int(11) DEFAULT '0',
  `method` varchar(50) DEFAULT NULL,
  `last_date_change` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_targets` (`target_id`),
  CONSTRAINT `fk_targets` FOREIGN KEY (`target_id`) REFERENCES `targets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=832 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `assays_compounds`
--

DROP TABLE IF EXISTS `assays_compounds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assays_compounds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `assay_id` int(11) NOT NULL,
  `compound_id` int(11) NOT NULL,
  `bio_assay_source` varchar(45) DEFAULT NULL,
  `comment` varchar(45) DEFAULT NULL,
  `outcome` varchar(45) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk1_assays` (`assay_id`),
  KEY `fk2_compounds` (`compound_id`),
  CONSTRAINT `fk1_assays` FOREIGN KEY (`assay_id`) REFERENCES `assays` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk2_compounds` FOREIGN KEY (`compound_id`) REFERENCES `compounds` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=254529 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `column_descriptions`
--

DROP TABLE IF EXISTS `column_descriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `column_descriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `assay_id` int(11) NOT NULL,
  `heading` varchar(45) NOT NULL,
  `name` varchar(45) NOT NULL,
  `readout_type` varchar(45) NOT NULL,
  `tid` int(11) DEFAULT NULL,
  `description` longtext,
  `unit` varchar(45) DEFAULT NULL,
  `active_concentration` tinyint(1) DEFAULT NULL,
  `concentration` double DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk2_assays` (`assay_id`),
  CONSTRAINT `fk2_assays` FOREIGN KEY (`assay_id`) REFERENCES `assays` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6794 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `compound_notification_types`
--

DROP TABLE IF EXISTS `compound_notification_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `compound_notification_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `compound_notifications`
--

DROP TABLE IF EXISTS `compound_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `compound_notifications` (
  `notification_id` int(11) NOT NULL,
  `cid` varchar(45) NOT NULL,
  `compound_notification_type_id` int(11) NOT NULL,
  KEY `fk1_notification_types` (`notification_id`),
  KEY `fk1_compound_notifications` (`notification_id`),
  KEY `fk2_compound_notification_types` (`compound_notification_type_id`),
  CONSTRAINT `fk1_compound_notifications` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk2_compound_notification_types` FOREIGN KEY (`compound_notification_type_id`) REFERENCES `compound_notification_types` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `compounds`
--

DROP TABLE IF EXISTS `compounds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `compounds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` varchar(50) NOT NULL,
  `path` varchar(256) DEFAULT 'unknow',
  `coordinate` varchar(15) DEFAULT '2D Coordinates',
  `coordinate_source_id` int(11) NOT NULL,
  `coordinate_unit_id` int(11) NOT NULL,
  `molecular_weight` float DEFAULT '-1',
  `molecular_formula` varchar(50) DEFAULT 'unknow',
  `name` varchar(256) DEFAULT 'unknow',
  `xlogp3` float DEFAULT '-1',
  `hbond_donor` int(11) DEFAULT '0',
  `hbond_acceptor` int(11) DEFAULT '0',
  `rotatable_bond` int(11) DEFAULT '0',
  `smiles` varchar(50) DEFAULT 'unknow',
  `tpsa` int(11) DEFAULT '0',
  `heavy_atom_count` int(11) DEFAULT '0',
  `component_count` int(11) DEFAULT '0',
  `tauto_count` int(11) DEFAULT '0',
  `atom_number` int(11) DEFAULT '0',
  `traditional_name` varchar(50) DEFAULT 'unknow',
  `inchi` varchar(256) DEFAULT 'unknow',
  `date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk1_coordinate_source_id` (`coordinate_source_id`),
  KEY `fk2_coordinate_unit_id` (`coordinate_unit_id`),
  CONSTRAINT `fk1_coordinate_source_id` FOREIGN KEY (`coordinate_source_id`) REFERENCES `coordinate_sources` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk2_coordinate_unit_id` FOREIGN KEY (`coordinate_unit_id`) REFERENCES `coordinate_units` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=66927 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `coordinate_sources`
--

DROP TABLE IF EXISTS `coordinate_sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `coordinate_sources` (
  `id` int(11) NOT NULL,
  `source` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coordinate_sources`
--

LOCK TABLES `coordinate_sources` WRITE;
/*!40000 ALTER TABLE `coordinate_sources` DISABLE KEYS */;
INSERT INTO `coordinate_sources` VALUES (3,'Depositor provided coordinates'),(4,'Experimentally determined coordinates'),(5,'Coordinates were computed by PubChem'),(255,'Coordinate units are unknown or unspecified');
/*!40000 ALTER TABLE `coordinate_sources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coordinate_units`
--

DROP TABLE IF EXISTS `coordinate_units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `coordinate_units` (
  `id` int(11) NOT NULL,
  `unit` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coordinate_units`
--

LOCK TABLES `coordinate_units` WRITE;
/*!40000 ALTER TABLE `coordinate_units` DISABLE KEYS */;
INSERT INTO `coordinate_units` VALUES (10,'3D Coordinate units in Angstroms'),(11,'3D Coordinate units in nanometers'),(12,'2D Coordinate units in pixels'),(13,'2D Coordinate units in points'),(14,'2D Coordinate units in standard bond lengths '),(255,'Coordinate units are unknown or unspecified');
/*!40000 ALTER TABLE `coordinate_units` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `count_notifications`
--

DROP TABLE IF EXISTS `count_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `count_notifications` (
  `notification_id` int(11) NOT NULL,
  `total` int(11) NOT NULL,
  `element_count` varchar(45) NOT NULL,
  KEY `fk1_count_notifications` (`notification_id`),
  CONSTRAINT `fk1_count_notifications` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cycles`
--

DROP TABLE IF EXISTS `cycles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cycles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `time` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fields`
--

DROP TABLE IF EXISTS `fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(256) NOT NULL,
  `isDate` tinyint(1) NOT NULL DEFAULT '0',
  `isNumerical` tinyint(1) NOT NULL DEFAULT '0',
  `isHidden` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=244 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `finished_notifications`
--

DROP TABLE IF EXISTS `finished_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `finished_notifications` (
  `notification_id` int(11) NOT NULL,
  `time` time NOT NULL,
  KEY `fk1_finished_notifications` (`notification_id`),
  CONSTRAINT `fk1_finished_notifications` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `query_id` int(11) NOT NULL,
  `event` varchar(45) NOT NULL,
  `message` text,
  PRIMARY KEY (`id`),
  KEY `fk1_queries` (`query_id`),
  CONSTRAINT `fk1_queries` FOREIGN KEY (`query_id`) REFERENCES `queries` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=293 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `prepare_receptors`
--

DROP TABLE IF EXISTS `prepare_receptors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prepare_receptors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `target_id` int(11) NOT NULL,
  `receptor_type_id` int(11) NOT NULL,
  `receptor` varchar(512) NOT NULL,
  `ligand` varchar(512) DEFAULT NULL,
  `center_x` double NOT NULL,
  `center_y` double NOT NULL,
  `center_z` double NOT NULL,
  `size_x` int(11) NOT NULL,
  `size_y` int(11) NOT NULL,
  `size_z` int(11) NOT NULL,
  `energy_range` int(11) DEFAULT NULL,
  `number_of_conformer` int(11) DEFAULT NULL,
  `comment` tinytext,
  `cpu_number` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_target` (`target_id`),
  KEY `fk_receptor_type` (`receptor_type_id`),
  CONSTRAINT `fk_receptor_type` FOREIGN KEY (`receptor_type_id`) REFERENCES `receptor_types` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_target` FOREIGN KEY (`target_id`) REFERENCES `targets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `queries`
--

DROP TABLE IF EXISTS `queries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `target_id` int(11) NOT NULL,
  `query` text NOT NULL,
  `date` date NOT NULL,
  `user_id` int(11) NOT NULL,
  `outcome_assay_filter` varchar(256) NOT NULL,
  `min_date` varchar(45) DEFAULT NULL,
  `max_date` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk1_assays` (`target_id`),
  KEY `fk2_users` (`user_id`),
  CONSTRAINT `fk1_targets` FOREIGN KEY (`target_id`) REFERENCES `targets` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk2_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `receptor_compounds`
--

DROP TABLE IF EXISTS `receptor_compounds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `receptor_compounds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `prepare_receptor_id` int(11) NOT NULL,
  `compound_id` int(11) NOT NULL,
  `value` double NOT NULL,
  `path` varchar(512) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk1_prepare_receptor` (`prepare_receptor_id`),
  KEY `fk2_compound` (`compound_id`),
  KEY `fk_receptor_compounds_1` (`prepare_receptor_id`),
  KEY `fk_receptor_compounds_2` (`compound_id`),
  CONSTRAINT `fk_receptor_compounds_1` FOREIGN KEY (`prepare_receptor_id`) REFERENCES `prepare_receptors` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_receptor_compounds_2` FOREIGN KEY (`compound_id`) REFERENCES `compounds` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6787 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `receptor_types`
--

DROP TABLE IF EXISTS `receptor_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `receptor_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schedules`
--

DROP TABLE IF EXISTS `schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schedules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `query_id` int(11) NOT NULL,
  `cycle_id` int(11) NOT NULL,
  `initial_time` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_schedules_2` (`cycle_id`),
  KEY `fk_schedules_1` (`query_id`),
  CONSTRAINT `fk_schedules_1` FOREIGN KEY (`query_id`) REFERENCES `queries` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_schedules_2` FOREIGN KEY (`cycle_id`) REFERENCES `cycles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `targets`
--

DROP TABLE IF EXISTS `targets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `targets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `root` varchar(512) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tested_concentrations`
--

DROP TABLE IF EXISTS `tested_concentrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tested_concentrations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `concentration` double NOT NULL,
  `unit` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_readouts`
--

DROP TABLE IF EXISTS `user_readouts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_readouts` (
  `assay_compound_id` int(11) NOT NULL,
  `column_description_id` int(11) NOT NULL,
  `value` varchar(45) DEFAULT NULL,
  KEY `fk1_assays_compounds` (`assay_compound_id`),
  KEY `fk2_column_descriptions` (`column_description_id`),
  CONSTRAINT `fk1_assays_compounds` FOREIGN KEY (`assay_compound_id`) REFERENCES `assays_compounds` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk2_column_descriptions` FOREIGN KEY (`column_description_id`) REFERENCES `column_descriptions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `email` varchar(256) NOT NULL,
  `first_lastname` varchar(45) DEFAULT NULL,
  `second_lastname` varchar(45) DEFAULT NULL,
  `hashed_password` varchar(64) NOT NULL,
  `salt` varchar(64) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-11-24  9:11:32
