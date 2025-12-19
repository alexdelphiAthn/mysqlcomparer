-- ========================================
-- SCRIPT DE SINCRONIZACIÓN
-- Generado: 19/12/2025 18:05:50
-- ========================================


-- Tabla nueva: codigo_postal
CREATE TABLE `codigo_postal` (

  `CODIGO_CLIENTE` varchar(255) NULL DEFAULT NULL,

  `CODIGO_POSTAL` varchar(255) NULL DEFAULT NULL

)



-- Modificar columna: suboc_clientes.TIPOID_INT_CLIENTE
ALTER TABLE `suboc_clientes` MODIFY COLUMN `TIPOID_INT_CLIENTE` varchar(20) NULL DEFAULT NULL COMMENT '''ID'' O ''PASAPORTE'' PARA EL TIPO DE IDENTIFICACIÓN INTERNACIONAL'

-- Modificar columna: suboc_facturas.TIPOID_INT_CLIENTE_FACTURA
ALTER TABLE `suboc_facturas` MODIFY COLUMN `TIPOID_INT_CLIENTE_FACTURA` varchar(20) NULL DEFAULT NULL COMMENT '''ID'' O ''PASAPORTE'' PARA EL TIPO DE IDENTIFICACIÓN INTERNACIONAL'

-- Modificar columna: suboc_facturas.CONSOLIDACION_FACTURA
ALTER TABLE `suboc_facturas` MODIFY COLUMN `CONSOLIDACION_FACTURA` varchar(1) NULL DEFAULT 'N' COMMENT '''S'' O ''N'' PARA SABER SI ESTÁ CONSOLIDADA LA FACTURA'

-- Modificar columna: suboc_facturas.FECHA_ULT_CONSO_FACTURA
ALTER TABLE `suboc_facturas` MODIFY COLUMN `FECHA_ULT_CONSO_FACTURA` datetime NULL DEFAULT NULL COMMENT 'FECHA DE CONSOLIDACION'

-- Modificar columna: suboc_facturas.FASE_CONSOLIDACION_FACTURA
ALTER TABLE `suboc_facturas` MODIFY COLUMN `FASE_CONSOLIDACION_FACTURA` varchar(100) NULL DEFAULT NULL COMMENT 'ONLINE, OFFLINE, VERIF1, VERIF2, ERROR_BORRADOR, ERROR_GRAVE'

-- Modificar columna: suboc_facturas.ESSIMPL_FACTURA
ALTER TABLE `suboc_facturas` MODIFY COLUMN `ESSIMPL_FACTURA` varchar(1) NULL DEFAULT 'N' COMMENT '''S'' O ''N'' PARA SABER SI ES FACTURA SIMPLIFICADA O NO'

-- Eliminar columna: suboc_facturas.NRO_FACTURA_ABONO_FACTURA
ALTER TABLE `suboc_facturas` DROP COLUMN `NRO_FACTURA_ABONO_FACTURA`

-- Eliminar columna: suboc_facturas.SERIE_FACTURA_ABONO_FACTURA
ALTER TABLE `suboc_facturas` DROP COLUMN `SERIE_FACTURA_ABONO_FACTURA`

-- Eliminar columna: suboc_facturas.DOCUMENTO_FACTURA
ALTER TABLE `suboc_facturas` DROP COLUMN `DOCUMENTO_FACTURA`

-- Eliminar índice: suboc_facturas.IDX_SERIE_CLIENTE
ALTER TABLE `suboc_facturas` DROP INDEX `IDX_SERIE_CLIENTE`

-- Modificar columna: suboc_facturas_lineas.NRO_FACTURA_LINEA
ALTER TABLE `suboc_facturas_lineas` MODIFY COLUMN `NRO_FACTURA_LINEA` int(8) NOT NULL

-- Modificar columna: suboc_presupuestos.TIPOID_INT_CLIENTE_FACTURA
ALTER TABLE `suboc_presupuestos` MODIFY COLUMN `TIPOID_INT_CLIENTE_FACTURA` varchar(20) NULL DEFAULT NULL COMMENT '''ID'' O ''PASAPORTE'' PARA EL TIPO DE IDENTIFICACIÓN INTERNACIONAL'

-- === VISTAS ===
-- Recreando vista: vu_suboc_historia
DROP VIEW IF EXISTS `vu_suboc_historia`

CREATE ALGORITHM=UNDEFINED  VIEW `vu_suboc_historia` AS select `h`.`ID` AS `ID`,`h`.`CODIGO_ARTICULO` AS `CODIGO_ARTICULO`,`h`.`DESCRIPCION_ARTICULO` AS `DESCRIPCION_ARTICULO`,`h`.`CODIGO_CLIENTE` AS `CODIGO_CLIENTE`,`h`.`PRECIOVENTA_ARTICULO` AS `PRECIOVENTA_ARTICULO`,`h`.`FECHA` AS `FECHA`,`h`.`ZONA` AS `ZONA`,`h`.`DESCRIPCION_HISTORIA` AS `DESCRIPCION_HISTORIA`,`h`.`NRO_FACTURA` AS `NRO_FACTURA`,`h`.`LINEA_LINEA` AS `LINEA_LINEA`,`h`.`ODONTOLOGO` AS `ODONTOLOGO`,`h`.`SERIE_FACTURA` AS `SERIE_FACTURA`,`h`.`CANTIDAD` AS `CANTIDAD`,`c`.`RAZONSOCIAL_CLIENTE` AS `RAZONSOCIAL_CLIENTE`,`c`.`MOVIL_CLIENTE` AS `MOVIL_CLIENTE`,`o`.`NOMBRE_ODONTOLOGO` AS `NOMBRE_ODONTOLOGO`,cast(`h`.`DESCRIPCION_HISTORIA` as char(100) charset utf8mb4) AS `DESHISVARCHAR` from ((`suboc_historia` `h` left join `suboc_clientes` `c` on(`h`.`CODIGO_CLIENTE` = `c`.`CODIGO_CLIENTE`)) left join `suboc_odontologos` `o` on(`h`.`ODONTOLOGO` = `o`.`ODONTOLOGO`)) order by `h`.`FECHA` desc

-- Recreando vista: v_suboc_cola_pendientes_summary
DROP VIEW IF EXISTS `v_suboc_cola_pendientes_summary`

CREATE ALGORITHM=UNDEFINED  VIEW `v_suboc_cola_pendientes_summary` AS select count(0) AS `TOTAL_PENDIENTES`,count(case when `suboc_verifactu_queue`.`FECHA_PROGRAMADA` <= current_timestamp() then 1 end) AS `READY_NOW`,count(case when `suboc_verifactu_queue`.`ESTADO_COLA` = 'PROCESANDO' then 1 end) AS `PROCESANDO`,count(case when `suboc_verifactu_queue`.`ESTADO_COLA` = 'ERROR' then 1 end) AS `CON_ERROR` from `suboc_verifactu_queue` where `suboc_verifactu_queue`.`ESTADO_COLA` in ('PENDIENTE','PROCESANDO','ERROR')

-- Recreando vista: v_suboc_cola_verifactu
DROP VIEW IF EXISTS `v_suboc_cola_verifactu`

CREATE ALGORITHM=UNDEFINED  VIEW `v_suboc_cola_verifactu` AS select `q`.`ID_QUEUE` AS `ID_QUEUE`,`q`.`TIPO_OPERACION` AS `TIPO_OPERACION`,`q`.`SERIE_FACTURA` AS `SERIE_FACTURA`,`q`.`NRO_FACTURA` AS `NRO_FACTURA`,`q`.`FECHA_PROGRAMADA` AS `FECHA_PROGRAMADA`,`q`.`FECHA_CREACION` AS `FECHA_CREACION`,`q`.`ESTADO_COLA` AS `ESTADO_COLA`,`q`.`INTENTOS` AS `INTENTOS`,`q`.`MAX_INTENTOS` AS `MAX_INTENTOS`,`q`.`PRIORIDAD` AS `PRIORIDAD`,`q`.`ERROR_MESSAGE` AS `ERROR_MESSAGE`,`q`.`FECHA_PROCESAMIENTO` AS `FECHA_PROCESAMIENTO`,`q`.`CREADO_POR` AS `CREADO_POR`,`q`.`NOTAS` AS `NOTAS`,`q`.`VERIFACTU_QUEUE_ID` AS `VERIFACTU_QUEUE_ID`,`q`.`VERIFACTU_REQUEST_ID` AS `VERIFACTU_REQUEST_ID`,`q`.`RESPUESTA_VERIFACTU` AS `RESPUESTA_VERIFACTU`,`q`.`CODIGO_ERROR_VERIFACTU` AS `CODIGO_ERROR_VERIFACTU`,`f`.`RAZONSOCIAL_CLIENTE_FACTURA` AS `RAZONSOCIAL_CLIENTE_FACTURA`,`f`.`TOTAL_LIQUIDO_FACTURA` AS `TOTAL_LIQUIDO_FACTURA`,`f`.`CONSOLIDACION_FACTURA` AS `CONSOLIDACION_FACTURA`,`f`.`FASE_CONSOLIDACION_FACTURA` AS `FASE_CONSOLIDACION_FACTURA`,case when `q`.`FECHA_PROGRAMADA` <= current_timestamp() then 'READY' else 'WAITING' end AS `STATUS_EJECUCION`,timestampdiff(SECOND,current_timestamp(),`q`.`FECHA_PROGRAMADA`) AS `SEGUNDOS_RESTANTES`,case `q`.`ESTADO_COLA` when 'PENDIENTE' then 1 when 'PROCESANDO' then 2 when 'COMPLETADO' then 3 when 'ERROR' then 4 when 'CANCELADO' then 5 else 6 end AS `ORDEN_ESTADO`,case when `q`.`CODIGO_ERROR_VERIFACTU` is not null then concat('ERROR VERIFACTU [',`q`.`CODIGO_ERROR_VERIFACTU`,']') when `q`.`ERROR_MESSAGE` is not null then concat('ERROR SISTEMA: ',left(`q`.`ERROR_MESSAGE`,50)) else 'SIN ERRORES' end AS `TIPO_ERROR` from (`suboc_verifactu_queue` `q` left join `suboc_facturas` `f` on(`q`.`SERIE_FACTURA` = `f`.`SERIE_FACTURA` and `q`.`NRO_FACTURA` = `f`.`NRO_FACTURA`)) order by `q`.`PRIORIDAD`,`q`.`FECHA_PROGRAMADA`

-- Recreando vista: v_suboc_facturas
DROP VIEW IF EXISTS `v_suboc_facturas`

CREATE ALGORITHM=UNDEFINED  VIEW `v_suboc_facturas` AS select `f`.`NRO_FACTURA` AS `NRO_FACTURA`,`f`.`SERIE_FACTURA` AS `SERIE_FACTURA`,`f`.`CODIGO_CLIENTE_FACTURA` AS `CODIGO_CLIENTE_FACTURA`,`f`.`RAZONSOCIAL_CLIENTE_FACTURA` AS `RAZONSOCIAL_CLIENTE_FACTURA`,`f`.`NIF_CLIENTE_FACTURA` AS `NIF_CLIENTE_FACTURA`,`f`.`MOVIL_CLIENTE_FACTURA` AS `MOVIL_CLIENTE_FACTURA`,`f`.`EMAIL_CLIENTE_FACTURA` AS `EMAIL_CLIENTE_FACTURA`,`f`.`DIRECCION1_CLIENTE_FACTURA` AS `DIRECCION1_CLIENTE_FACTURA`,`f`.`DIRECCION2_CLIENTE_FACTURA` AS `DIRECCION2_CLIENTE_FACTURA`,`f`.`POBLACION_CLIENTE_FACTURA` AS `POBLACION_CLIENTE_FACTURA`,`f`.`PROVINCIA_CLIENTE_FACTURA` AS `PROVINCIA_CLIENTE_FACTURA`,`f`.`CPOSTAL_CLIENTE_FACTURA` AS `CPOSTAL_CLIENTE_FACTURA`,`f`.`PAIS_CLIENTE_FACTURA` AS `PAIS_CLIENTE_FACTURA`,`f`.`TIPOID_INT_CLIENTE_FACTURA` AS `TIPOID_INT_CLIENTE_FACTURA`,`f`.`FECHA_FACTURA` AS `FECHA_FACTURA`,`f`.`TOTAL_LIQUIDO_FACTURA` AS `TOTAL_LIQUIDO_FACTURA`,`f`.`FORMA_PAGO_FACTURA` AS `FORMA_PAGO_FACTURA`,`f`.`COMENTARIOS_FACTURA` AS `COMENTARIOS_FACTURA`,`f`.`NOMBRE` AS `NOMBRE`,`f`.`APELLIDOS` AS `APELLIDOS`,`f`.`CONSOLIDACION_FACTURA` AS `CONSOLIDACION_FACTURA`,`c`.`REQUEST_ID` AS `REQUEST_ID`,`c`.`QUEUE_ID` AS `QUEUE_ID`,`c`.`ISSUER_IRS_ID` AS `ISSUER_IRS_ID`,`c`.`ISSUED_TIME` AS `ISSUED_TIME`,`c`.`CHAIN_NUMBER` AS `CHAIN_NUMBER`,`c`.`CHAIN_HASH` AS `CHAIN_HASH`,`c`.`VERIFACTU_URL` AS `VERIFACTU_URL`,`c`.`QRCODE_BASE64` AS `QRCODE_BASE64`,`c`.`QRCODE_PNG` AS `QRCODE_PNG`,`c`.`FECHA_PROCESAMIENTO` AS `FECHA_PROCESAMIENTO`,`c`.`ESTADO` AS `ESTADO`,`c`.`RESPUESTA_COMPLETA` AS `RESPUESTA_COMPLETA`,`c`.`PETICION_COMPLETA` AS `PETICION_COMPLETA`,`p`.`NOMBRE_SPA_PAIS` AS `NOMBRE_SPA_PAIS` from ((`suboc_facturas` `f` join `suboc_consolidacion` `c` on(`f`.`NRO_FACTURA` = `c`.`NRO_FACTURA` and `f`.`SERIE_FACTURA` = `c`.`SERIE_FACTURA`)) join `suboc_paises` `p` on(`f`.`PAIS_CLIENTE_FACTURA` = `p`.`COD_PAIS_ALPHA2`))

-- Recreando vista: v_suboc_presupuestos
DROP VIEW IF EXISTS `v_suboc_presupuestos`

CREATE ALGORITHM=UNDEFINED  VIEW `v_suboc_presupuestos` AS select `f`.`NRO_FACTURA` AS `NRO_FACTURA`,`f`.`SERIE_FACTURA` AS `SERIE_FACTURA`,`f`.`CODIGO_CLIENTE_FACTURA` AS `CODIGO_CLIENTE_FACTURA`,`f`.`RAZONSOCIAL_CLIENTE_FACTURA` AS `RAZONSOCIAL_CLIENTE_FACTURA`,`f`.`NIF_CLIENTE_FACTURA` AS `NIF_CLIENTE_FACTURA`,`f`.`MOVIL_CLIENTE_FACTURA` AS `MOVIL_CLIENTE_FACTURA`,`f`.`EMAIL_CLIENTE_FACTURA` AS `EMAIL_CLIENTE_FACTURA`,`f`.`DIRECCION1_CLIENTE_FACTURA` AS `DIRECCION1_CLIENTE_FACTURA`,`f`.`DIRECCION2_CLIENTE_FACTURA` AS `DIRECCION2_CLIENTE_FACTURA`,`f`.`POBLACION_CLIENTE_FACTURA` AS `POBLACION_CLIENTE_FACTURA`,`f`.`PROVINCIA_CLIENTE_FACTURA` AS `PROVINCIA_CLIENTE_FACTURA`,`f`.`CPOSTAL_CLIENTE_FACTURA` AS `CPOSTAL_CLIENTE_FACTURA`,`f`.`PAIS_CLIENTE_FACTURA` AS `PAIS_CLIENTE_FACTURA`,`f`.`FECHA_FACTURA` AS `FECHA_FACTURA`,`f`.`TOTAL_LIQUIDO_FACTURA` AS `TOTAL_LIQUIDO_FACTURA`,`f`.`FORMA_PAGO_FACTURA` AS `FORMA_PAGO_FACTURA`,`f`.`COMENTARIOS_FACTURA` AS `COMENTARIOS_FACTURA`,`f`.`NOMBRE` AS `NOMBRE`,`f`.`APELLIDOS` AS `APELLIDOS`,`c`.`DIBUJO_FACTURA` AS `DIBUJO_FACTURA` from (`suboc_presupuestos` `f` join `suboc_dibujos_presupuestos` `c` on(`f`.`NRO_FACTURA` = `c`.`NRO_FACTURA` and `f`.`SERIE_FACTURA` = `c`.`SERIE_FACTURA`))

-- === PROCEDIMIENTOS ===
-- Recreando procedimiento: GET_NEXT_CONT
DROP PROCEDURE IF EXISTS `GET_NEXT_CONT`

DELIMITER $$
CREATE  PROCEDURE `GET_NEXT_CONT`(IN pTipoDoc varchar(2), OUT pcont int)
BEGIN
START TRANSACTION;
    IF( (EXISTS(
             SELECT *
               FROM suboc_contadores 
              WHERE SERIE_CONTADOR = '-' 
                AND TIPODOC_CONTADOR = pTipoDoc ) ) ) THEN
	BEGIN
	 UPDATE suboc_contadores 
	    SET CONTADOR_CONTADOR = CONTADOR_CONTADOR + 1
	  WHERE SERIE_CONTADOR = '-' 
      AND TIPODOC_CONTADOR = pTipoDoc;
	SET pcont = (SELECT CONTADOR_CONTADOR - 1 
                 from suboc_contadores 
                where SERIE_CONTADOR = '-' 
                  and TIPODOC_CONTADOR = pTipoDoc LIMIT 1);
	END;
  ELSE
  BEGIN
    SET pcont = 1;
    INSERT INTO suboc_contadores
    (TIPODOC_CONTADOR, CONTADOR_CONTADOR, SERIE_CONTADOR, EJERCICIO_CONTADOR) 
    VALUES
    (pTipoDoc, 1, '-', '-');
  END;
  END IF;
COMMIT;
END $$
DELIMITER ;

-- Recreando procedimiento: GET_NEXT_CONT_FACT_SERIE
DROP PROCEDURE IF EXISTS `GET_NEXT_CONT_FACT_SERIE`

DELIMITER $$
CREATE  PROCEDURE `GET_NEXT_CONT_FACT_SERIE`(IN pserie varchar(10), IN pTipoDoc varchar(2), OUT pcont int)
BEGIN
START TRANSACTION;
	 UPDATE suboc_contadores 
	    SET CONTADOR_CONTADOR = CONTADOR_CONTADOR + 1
	  WHERE SERIE_CONTADOR = pserie 
      AND TIPODOC_CONTADOR = pTipoDoc;
	SET pcont = (SELECT CONTADOR_CONTADOR - 1 
                 from suboc_contadores 
                where SERIE_CONTADOR = pserie 
                  and TIPODOC_CONTADOR = pTipoDoc LIMIT 1);
COMMIT;
END $$
DELIMITER ;

-- Recreando procedimiento: PRC_CALCULAR_FACTURA
DROP PROCEDURE IF EXISTS `PRC_CALCULAR_FACTURA`

DELIMITER $$
CREATE  PROCEDURE `PRC_CALCULAR_FACTURA`(IN `pidseriefactura` varchar(200),
	IN `pidnumfactura` varchar(200))
BEGIN
  DECLARE suma_total decimal(18,6);
  START TRANSACTION;
  SET suma_total = (SELECT SUM(SUM_TOTAL_LINEA) FROM suboc_facturas_lineas WHERE NRO_FACTURA_LINEA=pidnumfactura AND SERIE_FACTURA_LINEA = pidseriefactura);
  UPDATE suboc_facturas 
	    SET TOTAL_LIQUIDO_FACTURA = suma_total
		WHERE NRO_FACTURA = pidnumfactura
		  AND SERIE_FACTURA = pidseriefactura;			
	COMMIT;
END $$
DELIMITER ;

-- Recreando procedimiento: PRC_CALCULAR_PRESUPUESTO
DROP PROCEDURE IF EXISTS `PRC_CALCULAR_PRESUPUESTO`

DELIMITER $$
CREATE  PROCEDURE `PRC_CALCULAR_PRESUPUESTO`(IN `pidseriefactura` varchar(200),
	IN `pidnumfactura` varchar(200))
BEGIN
  DECLARE suma_total decimal(18,6);
  START TRANSACTION;
  SET suma_total = (SELECT SUM(SUM_TOTAL_LINEA) FROM suboc_presupuestos_lineas WHERE NRO_FACTURA_LINEA=pidnumfactura AND SERIE_FACTURA_LINEA = pidseriefactura);
  UPDATE suboc_presupuestos 
	    SET TOTAL_LIQUIDO_FACTURA = suma_total
		WHERE NRO_FACTURA = pidnumfactura
		  AND SERIE_FACTURA = pidseriefactura;			
	COMMIT;
END $$
DELIMITER ;

-- Recreando procedimiento: PRC_CREAR_ACTUALIZAR_CLIENTE
DROP PROCEDURE IF EXISTS `PRC_CREAR_ACTUALIZAR_CLIENTE`

DELIMITER $$
CREATE  PROCEDURE `PRC_CREAR_ACTUALIZAR_CLIENTE`(IN `pCODIGO_CLIENTE` int(10),
	IN `pRAZONSOCIAL_CLIENTE` varchar(200),
	IN `pNOMBRE` varchar(100),
	IN `pAPELLIDOS` varchar(100),
	IN `pNIF_CLIENTE` varchar(50),
	IN `pMOVIL_CLIENTE` varchar(40),
	IN `pEMAIL_CLIENTE` varchar(200),
	IN `pDIRECCION1_CLIENTE` varchar(200),
	IN `pDIRECCION2_CLIENTE` varchar(200),
	IN `pPOBLACION_CLIENTE` varchar(200),
	IN `pPROVINCIA_CLIENTE` varchar(200),
	IN `pCPOSTAL_CLIENTE` varchar(15),
	IN `pPAIS_CLIENTE` varchar(150),
  IN `pTIPOID_INT_CLIENTE` varchar(150))
BEGIN
START TRANSACTION;
 IF( EXISTS(
             SELECT *
             FROM suboc_clientes
             WHERE `CODIGO_CLIENTE` =  pcodigo_cliente) ) THEN
	BEGIN
	  UPDATE suboc_clientes
	    SET     RAZONSOCIAL_CLIENTE   = pRAZONSOCIAL_CLIENTE ,
					NIF_CLIENTE           = pNIF_CLIENTE         ,
					NOMBRE                = pNOMBRE              , 
					APELLIDOS			  = pAPELLIDOS           , 
					MOVIL_CLIENTE         = pMOVIL_CLIENTE       ,
					EMAIL_CLIENTE         = pEMAIL_CLIENTE       ,
					DIRECCION1_CLIENTE    = pDIRECCION1_CLIENTE  ,
					DIRECCION2_CLIENTE    = pDIRECCION2_CLIENTE  ,
					POBLACION_CLIENTE     = pPOBLACION_CLIENTE   ,
					PROVINCIA_CLIENTE     = pPROVINCIA_CLIENTE   ,
					CPOSTAL_CLIENTE       = pCPOSTAL_CLIENTE     ,
					PAIS_CLIENTE          = pPAIS_CLIENTE        ,
          TIPOID_INT_CLIENTE    = pTIPOID_INT_CLIENTE
		WHERE CODIGO_cliente = pCODIGO_CLIENTE;
	END;
	ELSE
	BEGIN
	  INSERT INTO suboc_clientes (CODIGO_CLIENTE,
											NOMBRE,
											APELLIDOS,
											RAZONSOCIAL_CLIENTE,
											NIF_CLIENTE,
											MOVIL_CLIENTE,
											EMAIL_CLIENTE,
											DIRECCION1_CLIENTE,
											DIRECCION2_CLIENTE,
											POBLACION_CLIENTE,
											PROVINCIA_CLIENTE,
											CPOSTAL_CLIENTE,
											PAIS_CLIENTE,
                      TIPOID_INT_CLIENTE) VALUES
												     (pCODIGO_CLIENTE,
														pNOMBRE,
														pAPELLIDOS,
														pRAZONSOCIAL_CLIENTE,
														pNIF_CLIENTE,
														pMOVIL_CLIENTE,
														pEMAIL_CLIENTE,
														pDIRECCION1_CLIENTE,
														pDIRECCION2_CLIENTE,
														pPOBLACION_CLIENTE,
														pPROVINCIA_CLIENTE,
														pCPOSTAL_CLIENTE,
														pPAIS_CLIENTE,
                            pTIPOID_INT_CLIENTE);
	END;
  END IF;
	COMMIT;
END $$
DELIMITER ;

-- Recreando procedimiento: PRC_CREAR_ACTUALIZAR_HISTORIA_FACTURA
DROP PROCEDURE IF EXISTS `PRC_CREAR_ACTUALIZAR_HISTORIA_FACTURA`

DELIMITER $$
CREATE  PROCEDURE `PRC_CREAR_ACTUALIZAR_HISTORIA_FACTURA`(IN  `pID_HISTORIA` bigint,
	IN  `pSERIEin` varchar(4),
	IN  `pFECHAin` date,
	IN  `PFacturain` int,
	OUT `pNroFactura` int,
	OUT `pNroLinea` varchar(3))
BEGIN
	DECLARE  `pRAZONSOCIAL_CLIENTE` varchar(200);
	DECLARE  `pNOMBRE` varchar(100);
	DECLARE  `pAPELLIDOS` varchar(100);
	DECLARE  `pNIF_CLIENTE` varchar(50);
	DECLARE  `pMOVIL_CLIENTE` varchar(40);
	DECLARE  `pEMAIL_CLIENTE` varchar(200);
	DECLARE  `pDIRECCION1_CLIENTE` varchar(200);
	DECLARE  `pDIRECCION2_CLIENTE` varchar(200);
	DECLARE  `pPOBLACION_CLIENTE` varchar(200);
	DECLARE  `pPROVINCIA_CLIENTE` varchar(200);
	DECLARE  `pCPOSTAL_CLIENTE` varchar(15);
	DECLARE  `pPAIS_CLIENTE` varchar(150);
	DECLARE  `pODONTOLOGO` varchar(8);
	DECLARE  `pPRECIO_VENTA_ARTICULO` decimal(18,6); 
	DECLARE  `pCODIGO_ARTICULO` varchar(20);
	DECLARE  `pZONA` varchar(60);
	DECLARE  `pDESCRIPCION_ARTICULO` varchar(100);
	DECLARE  `pCANTIDAD` int;
	DECLARE  `pCODIGO_CLIENTE` int(10);
	
	START TRANSACTION;
	SELECT CODIGO_CLIENTE,
	       ODONTOLOGO,
	       PRECIOVENTA_ARTICULO,
				 CODIGO_ARTICULO,
				 DESCRIPCION_ARTICULO,
				 ZONA,
				 CANTIDAD
		 INTO
		    `pCODIGO_CLIENTE`,
				`pODONTOLOGO`,
				`pPRECIO_VENTA_ARTICULO`,
				`pCODIGO_ARTICULO`,
				`pDESCRIPCION_ARTICULO`,
				`pZONA`,
				`pCANTIDAD`
		FROM suboc_historia
	WHERE ID = `pID_HISTORIA`;
	SET @SerieFactura = pSERIEin;
	SET @pFecha = pFECHAin;
IF( NOT( EXISTS(
             SELECT *
               FROM suboc_facturas
              WHERE (`CODIGO_CLIENTE_FACTURA` =  pcodigo_cliente
						          AND  `FECHA_FACTURA`= @pFecha
						          AND  `SERIE_FACTURA` = @SerieFactura)		))) THEN
	BEGIN
		IF ((pFACTURAin = 0) AND ( NOT (EXISTS ( SELECT *
                                                  FROM suboc_facturas
												 WHERE NRO_FACTURA = pFACTURAin)))) THEN
	  BEGIN
		  CALL GET_NEXT_CONT_FACT_SERIE(@SerieFactura, 'FC', @cont); 
	  END;
	  ELSE
	  BEGIN	
		  SET @cont = pFACTURAin;
	  END;
	END IF;
	  SELECT  `RAZONSOCIAL_CLIENTE` 	
		       ,`NOMBRE` 				
		       ,`APELLIDOS` 			
		       ,`NIF_CLIENTE` 			
		       ,`MOVIL_CLIENTE` 		
		       ,`EMAIL_CLIENTE` 		
		       ,`DIRECCION1_CLIENTE` 	
		       ,`DIRECCION2_CLIENTE` 	
		       ,`POBLACION_CLIENTE` 	
		       ,`PROVINCIA_CLIENTE` 	
		       ,`PAIS_CLIENTE` 		
		       ,`CPOSTAL_CLIENTE` 		
		  INTO  `pRAZONSOCIAL_CLIENTE` 	
			     ,`pNOMBRE` 				
			     ,`pAPELLIDOS` 			
			     ,`pNIF_CLIENTE` 			
			     ,`pMOVIL_CLIENTE` 		
			     ,`pEMAIL_CLIENTE` 		
			     ,`pDIRECCION1_CLIENTE` 	
			     ,`pDIRECCION2_CLIENTE` 	
			     ,`pPOBLACION_CLIENTE` 	
			     ,`pPROVINCIA_CLIENTE` 	
			     ,`pPAIS_CLIENTE` 		
			     ,`pCPOSTAL_CLIENTE` 			            
			 FROM suboc_clientes
		WHERE CODIGO_cliente = pCODIGO_CLIENTE;
		INSERT INTO suboc_facturas (    `NRO_FACTURA` 							
																		,`SERIE_FACTURA` 
																		,`CODIGO_CLIENTE_FACTURA` 
																		,`RAZONSOCIAL_CLIENTE_FACTURA` 
																		,`NIF_CLIENTE_FACTURA` 
																		,`MOVIL_CLIENTE_FACTURA` 
																		,`EMAIL_CLIENTE_FACTURA` 
																		,`DIRECCION1_CLIENTE_FACTURA` 
																		,`DIRECCION2_CLIENTE_FACTURA` 
																		,`POBLACION_CLIENTE_FACTURA` 
																		,`PROVINCIA_CLIENTE_FACTURA` 
																		,`CPOSTAL_CLIENTE_FACTURA` 
																		,`PAIS_CLIENTE_FACTURA` 
																		,`FECHA_FACTURA` 
																		,`TOTAL_LIQUIDO_FACTURA` 
																		,`FORMA_PAGO_FACTURA` 
																		,`COMENTARIOS_FACTURA` 
																		,`NOMBRE` 
																		,`APELLIDOS` 
															) VALUES 
															(   @cont
																 ,@SerieFactura
																 ,`pCODIGO_CLIENTE`
															   ,`pRAZONSOCIAL_CLIENTE` 	 
															   ,`pNIF_CLIENTE` 			
															   ,`pMOVIL_CLIENTE` 		
															   ,`pEMAIL_CLIENTE` 		
															   ,`pDIRECCION1_CLIENTE` 
															   ,`pDIRECCION2_CLIENTE` 
															   ,`pPOBLACION_CLIENTE` 	
                                 ,`pPROVINCIA_CLIENTE` 	
		                             ,`pCPOSTAL_CLIENTE`
																 ,`pPAIS_CLIENTE` 		
		                             ,@pFecha
		                             ,0
																 ,'TARJETA'	
																 ,''
																 ,`pNOMBRE` 				
															   ,`pAPELLIDOS` 			
															 );
	END;
	ELSE
	  BEGIN
	    SELECT NRO_FACTURA
			  INTO @cont	
				FROM suboc_facturas
			 WHERE `CODIGO_CLIENTE_FACTURA` =  pcodigo_cliente
				 AND `FECHA_FACTURA`= @pFecha
				 AND `SERIE_FACTURA` = @SerieFactura
			ORDER BY NRO_FACTURA DESC
			LIMIT 1;
    END;
  END IF;
	SET pNroFactura = @cont;
  IF ((pCANTIDAD = 0) OR (pCANTIDAD IS NULL)) THEN 
	  SET pCANTIDAD = 1;
  END IF;
	SET @nrolinea = (SELECT `FNC_GET_NEXT_LINEA_FACTURA`(@cont, @SerieFactura));
	SET pNroLinea = @nrolinea;
	INSERT INTO suboc_facturas_lineas (   `SERIE_FACTURA_LINEA` 
																				,`NRO_FACTURA_LINEA` 
																				,`LINEA_LINEA` 
																				,`CODIGO_ARTICULO_LINEA` 
																				,`DESCRIPCION_ARTICULO_LINEA` 
																				,`ZONA` 
																				,`PRECIOVENTA_ARTICULO_LINEA` 
																				,`CANTIDAD_LINEA` 
																				,`SUM_TOTAL_LINEA` 
																				,`ODONTOLOGO` 
																		) VALUES 
																		(  @SerieFactura
																		  ,@cont
																		  ,@nrolinea
																			,`pCODIGO_ARTICULO`
																			,`pDESCRIPCION_ARTICULO`
																			,`pZONA`
																			,`pPRECIO_VENTA_ARTICULO`
																			,`pCANTIDAD`
																			,`pPRECIO_VENTA_ARTICULO`*`pCANTIDAD`
																			,`pODONTOLOGO`
																		);
	CALL `PRC_CALCULAR_FACTURA`(@SerieFactura, @cont);
	UPDATE suboc_historia
	   SET NRO_FACTURA = @cont,
				 SERIE_FACTURA = @SerieFactura,
				 LINEA_LINEA = @nrolinea
	 WHERE ID = `pID_HISTORIA`;
	COMMIT;
END $$
DELIMITER ;

-- Recreando procedimiento: PRC_CREAR_FACTURA_ABONO
DROP PROCEDURE IF EXISTS `PRC_CREAR_FACTURA_ABONO`

DELIMITER $$
CREATE  PROCEDURE `PRC_CREAR_FACTURA_ABONO`(IN `pidseriefactura` varchar(200),
	IN `pidnumfactura` varchar(200),
	IN `pidseriefacturaabono` varchar(200),
	IN `pfechafacturaabono` date,
	OUT `pidnumfacturaabono` varchar(200))
BEGIN
   DECLARE contadorped varchar(200);
   START TRANSACTION;
   CALL GET_NEXT_CONT_FACT_SERIE(pidseriefacturaabono, 'FC', @cont);   
   SET @pFecha = (SELECT DATE_FORMAT(pfechafacturaabono, '%Y-%m-%d'));
   SET contadorped = @cont;	   
   SET pidnumfacturaabono = contadorped;
   INSERT INTO suboc_facturas (`NRO_FACTURA`,
												`SERIE_FACTURA`,
												`CODIGO_CLIENTE_FACTURA`,
												`RAZONSOCIAL_CLIENTE_FACTURA`,
												`NIF_CLIENTE_FACTURA`,
												`MOVIL_CLIENTE_FACTURA`,
												`EMAIL_CLIENTE_FACTURA`,
												`DIRECCION1_CLIENTE_FACTURA`,
												`DIRECCION2_CLIENTE_FACTURA`,
												`POBLACION_CLIENTE_FACTURA`,
												`PROVINCIA_CLIENTE_FACTURA`,
												`CPOSTAL_CLIENTE_FACTURA`,
												`PAIS_CLIENTE_FACTURA`,
												`TIPOID_INT_CLIENTE_FACTURA`,
												`FECHA_FACTURA`,
												`TOTAL_LIQUIDO_FACTURA`,
												`FORMA_PAGO_FACTURA`,
												`NOMBRE`,
												`APELLIDOS`)
							           SELECT   contadorped,
												pidseriefacturaabono,
												`CODIGO_CLIENTE_FACTURA`,
												`RAZONSOCIAL_CLIENTE_FACTURA`,
												`NIF_CLIENTE_FACTURA`,
												`MOVIL_CLIENTE_FACTURA`,
												`EMAIL_CLIENTE_FACTURA`,
												`DIRECCION1_CLIENTE_FACTURA`,
												`DIRECCION2_CLIENTE_FACTURA`,
												`POBLACION_CLIENTE_FACTURA`,
												`PROVINCIA_CLIENTE_FACTURA`,
												`CPOSTAL_CLIENTE_FACTURA`,
												`PAIS_CLIENTE_FACTURA`,
												`TIPOID_INT_CLIENTE_FACTURA`,
												@pFecha,
												`TOTAL_LIQUIDO_FACTURA`*-1,
												`FORMA_PAGO_FACTURA`,
												`NOMBRE`,
												`APELLIDOS`
										FROM 	suboc_facturas 
										WHERE 	`NRO_FACTURA` = pidnumfactura 
										AND     `SERIE_FACTURA` = pidseriefactura;	
	INSERT INTO suboc_facturas_lineas (`SERIE_FACTURA_LINEA`,
							`NRO_FACTURA_LINEA`,
							`LINEA_LINEA`,
							`CODIGO_ARTICULO_LINEA`,
							`DESCRIPCION_ARTICULO_LINEA`,
							`PRECIOVENTA_ARTICULO_LINEA`,
							`CANTIDAD_LINEA`,
							`SUM_TOTAL_LINEA`)
	        SELECT 	 pidseriefacturaabono,
									 contadorped,
									`LINEA_LINEA`,
									`CODIGO_ARTICULO_LINEA`,
									`DESCRIPCION_ARTICULO_LINEA`,
									`PRECIOVENTA_ARTICULO_LINEA`,
									`CANTIDAD_LINEA`*-1,
									`SUM_TOTAL_LINEA`*-1
							  FROM suboc_facturas_lineas 
							 WHERE `SERIE_FACTURA_LINEA` = pidseriefactura  
							   AND `NRO_FACTURA_LINEA` = pidnumfactura;
		COMMIT;
END $$
DELIMITER ;

-- Recreando procedimiento: PRC_CREAR_FACTURA_DUPLICADA
DROP PROCEDURE IF EXISTS `PRC_CREAR_FACTURA_DUPLICADA`

DELIMITER $$
CREATE  PROCEDURE `PRC_CREAR_FACTURA_DUPLICADA`(IN `pidseriefactura` varchar(200),
	IN `pidnumfactura` varchar(200),
	IN `pidseriefacturaabono` varchar(200),
	IN `pfechafacturaabono` date,
	OUT `pidnumfacturaabono` varchar(200))
BEGIN
   DECLARE contadorped varchar(200);
   START TRANSACTION;
   CALL GET_NEXT_CONT_FACT_SERIE(pidseriefacturaabono, 'FC', @cont);   
   SET @pFecha = (SELECT DATE_FORMAT(pfechafacturaabono, '%Y-%m-%d'));
   SET contadorped = @cont;	   
   SET pidnumfacturaabono = contadorped;
   INSERT INTO suboc_facturas (`NRO_FACTURA`,
												`SERIE_FACTURA`,
												`CODIGO_CLIENTE_FACTURA`,
												`RAZONSOCIAL_CLIENTE_FACTURA`,
												`NIF_CLIENTE_FACTURA`,
												`MOVIL_CLIENTE_FACTURA`,
												`EMAIL_CLIENTE_FACTURA`,
												`DIRECCION1_CLIENTE_FACTURA`,
												`DIRECCION2_CLIENTE_FACTURA`,
												`POBLACION_CLIENTE_FACTURA`,
												`PROVINCIA_CLIENTE_FACTURA`,
												`CPOSTAL_CLIENTE_FACTURA`,
												`PAIS_CLIENTE_FACTURA`,
												`TIPOID_INT_CLIENTE_FACTURA`,
												`FECHA_FACTURA`,
												`TOTAL_LIQUIDO_FACTURA`,
												`FORMA_PAGO_FACTURA`,
												`NOMBRE`,
												`APELLIDOS`)
							           SELECT   contadorped,
												pidseriefacturaabono,
												`CODIGO_CLIENTE_FACTURA`,
												`RAZONSOCIAL_CLIENTE_FACTURA`,
												`NIF_CLIENTE_FACTURA`,
												`MOVIL_CLIENTE_FACTURA`,
												`EMAIL_CLIENTE_FACTURA`,
												`DIRECCION1_CLIENTE_FACTURA`,
												`DIRECCION2_CLIENTE_FACTURA`,
												`POBLACION_CLIENTE_FACTURA`,
												`PROVINCIA_CLIENTE_FACTURA`,
												`CPOSTAL_CLIENTE_FACTURA`,
												`PAIS_CLIENTE_FACTURA`,
                                                `TIPOID_INT_CLIENTE_FACTURA`,
												@pfecha,
												`TOTAL_LIQUIDO_FACTURA`,
												`FORMA_PAGO_FACTURA`,
												`NOMBRE`,
												`APELLIDOS`
										FROM 	suboc_facturas 
										WHERE 	`NRO_FACTURA` = pidnumfactura 
										AND     `SERIE_FACTURA` = pidseriefactura;	
	INSERT INTO suboc_facturas_lineas (`SERIE_FACTURA_LINEA`,
							`NRO_FACTURA_LINEA`,
							`LINEA_LINEA`,
							`CODIGO_ARTICULO_LINEA`,
							`DESCRIPCION_ARTICULO_LINEA`,
							`PRECIOVENTA_ARTICULO_LINEA`,
							`CANTIDAD_LINEA`,
							`SUM_TOTAL_LINEA`)
	        SELECT 	 pidseriefacturaabono,
									 contadorped,
									`LINEA_LINEA`,
									`CODIGO_ARTICULO_LINEA`,
									`DESCRIPCION_ARTICULO_LINEA`,
									`PRECIOVENTA_ARTICULO_LINEA`,
									`CANTIDAD_LINEA`,
									`SUM_TOTAL_LINEA`
							  FROM suboc_facturas_lineas 
							 WHERE `SERIE_FACTURA_LINEA` = pidseriefactura  
							   AND `NRO_FACTURA_LINEA` = pidnumfactura;
		COMMIT;
END $$
DELIMITER ;

-- Recreando procedimiento: PRC_CREAR_FACTURA_PRESUPUESTO
DROP PROCEDURE IF EXISTS `PRC_CREAR_FACTURA_PRESUPUESTO`

DELIMITER $$
CREATE  PROCEDURE `PRC_CREAR_FACTURA_PRESUPUESTO`(IN `pidseriepresupuesto` varchar(200),
	IN `pidnumpresupuesto` varchar(200),
	IN `pidseriefactura` varchar(200),
	IN `pfechafactura` date,
	IN `pidnumfactura` varchar(200),
	OUT `pidresulnumfac` varchar(200))
BEGIN
   DECLARE contadorped varchar(200);
  
	 IF pidnumfactura = 0 THEN
     CALL GET_NEXT_CONT_FACT_SERIE(pidseriefactura, 'FC', @cont);
		 SET pidresulnumfac = @cont;	   
     SET pidnumfactura = @cont;
	 END IF;
   SET @pFecha = (SELECT DATE_FORMAT(pfechafactura, '%Y-%m-%d'));
   INSERT INTO suboc_facturas (`NRO_FACTURA`,
												  `SERIE_FACTURA`,
												  `CODIGO_CLIENTE_FACTURA`,
												  `RAZONSOCIAL_CLIENTE_FACTURA`,
												  `NIF_CLIENTE_FACTURA`,
												  `MOVIL_CLIENTE_FACTURA`,
												  `EMAIL_CLIENTE_FACTURA`,
												  `DIRECCION1_CLIENTE_FACTURA`,
												  `DIRECCION2_CLIENTE_FACTURA`,
												  `POBLACION_CLIENTE_FACTURA`,
												  `PROVINCIA_CLIENTE_FACTURA`,
												  `CPOSTAL_CLIENTE_FACTURA`,
												  `PAIS_CLIENTE_FACTURA`,
                          `TIPOID_INT_CLIENTE_FACTURA`,
												  `FECHA_FACTURA`,
												  `TOTAL_LIQUIDO_FACTURA`,
												  `FORMA_PAGO_FACTURA`, 
													`NOMBRE`,
												  `APELLIDOS`)
						      SELECT   pidnumfactura,
												   pidseriefactura,
												  `CODIGO_CLIENTE_FACTURA`,
												  `RAZONSOCIAL_CLIENTE_FACTURA`,
												  `NIF_CLIENTE_FACTURA`,
												  `MOVIL_CLIENTE_FACTURA`,
												  `EMAIL_CLIENTE_FACTURA`,
												  `DIRECCION1_CLIENTE_FACTURA`,
												  `DIRECCION2_CLIENTE_FACTURA`,
												  `POBLACION_CLIENTE_FACTURA`,
												  `PROVINCIA_CLIENTE_FACTURA`,
												  `CPOSTAL_CLIENTE_FACTURA`,
												  `PAIS_CLIENTE_FACTURA`,
                          `TIPOID_INT_CLIENTE_FACTURA`,
												  @pfecha,
												  `TOTAL_LIQUIDO_FACTURA`,
												  `FORMA_PAGO_FACTURA`,
													`NOMBRE`,
												  `APELLIDOS`
										FROM   suboc_presupuestos 
										WHERE `NRO_FACTURA` = pidnumpresupuesto 
										AND     `SERIE_FACTURA` = pidseriepresupuesto;	
										
							INSERT INTO  suboc_facturas_lineas (`SERIE_FACTURA_LINEA`,
													`NRO_FACTURA_LINEA`,
													`LINEA_LINEA`,
													`CODIGO_ARTICULO_LINEA`,
													`DESCRIPCION_ARTICULO_LINEA`,
													`PRECIOVENTA_ARTICULO_LINEA`,
													`CANTIDAD_LINEA`,
													`SUM_TOTAL_LINEA`)
									SELECT 	 pidseriefactura,
													 pidnumfactura,
													`LINEA_LINEA`,
													`CODIGO_ARTICULO_LINEA`,
													`DESCRIPCION_ARTICULO_LINEA`,
													`PRECIOVENTA_ARTICULO_LINEA`,
													`CANTIDAD_LINEA`,
													`SUM_TOTAL_LINEA`
										  FROM suboc_presupuestos_lineas
										 WHERE `SERIE_FACTURA_LINEA` = pidseriepresupuesto  
											 AND `NRO_FACTURA_LINEA` = pidnumpresupuesto;
END $$
DELIMITER ;

-- Recreando procedimiento: PRC_CREAR_RECIBOS_FACTURA
DROP PROCEDURE IF EXISTS `PRC_CREAR_RECIBOS_FACTURA`

DELIMITER $$
CREATE  PROCEDURE `PRC_CREAR_RECIBOS_FACTURA`(IN `pSERIE_FACTURA` varchar(8),
	                                                                         IN `pNRO_FACTURA` int(8))
BEGIN
  DECLARE pCODIGO_FORMAPAGO VARCHAR(10);
	DECLARE pFORMA_PAGO_FACTURA VARCHAR(100);
	DECLARE pN_PLAZOS int(10); 
	DECLARE I int(10);
	DECLARE pDIAS_ENTRE_PLAZOS int(10);
	DECLARE pPORCEN_ANTICIPO decimal(5,2);
	DECLARE pCODIGO_CLIENTE  int(10);
	DECLARE pIBAN varchar(34);
	DECLARE pRAZONSOCIAL_CLIENTE varchar(200);
	DECLARE pDIRECCION1_CLIENTE  varchar(200);
	DECLARE pPOBLACION_CLIENTE  varchar(200);
	DECLARE pPROVINCIA_CLIENTE  varchar(200);
	DECLARE pCPOSTAL_CLIENTE  varchar(15);
	DECLARE pIMPORTE_LETRA  varchar(150);
	DECLARE pTOTAL_LIQUIDO_FACTURA decimal(18,6);
	DECLARE pIMPORTE_RECIBO decimal(18,6);
	DECLARE pIMPORTE_RESTO decimal(18,6);
	DECLARE pIMPORTE_ANTICIPO decimal(18,6);
	DECLARE pFECHA_VENCIMIENTO date;
	DECLARE pFECHA_FACTURA date;
	DECLARE finished INTEGER DEFAULT 0;
	DECLARE pTRATAMIENTO_LINEA VARCHAR(100);
  DECLARE pTRATAMIENTOS varchar(1000) DEFAULT '';
  DECLARE curTratamientos 
        CURSOR FOR 
            SELECT DESCRIPCION_ARTICULO_LINEA 
						  FROM suboc_facturas_lineas 
						 WHERE SERIE_FACTURA_LINEA = pSERIE_FACTURA 
						   AND NRO_FACTURA_LINEA = pNRO_FACTURA;
  DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;
	START TRANSACTION;
	DELETE FROM suboc_recibos 
   WHERE NRO_FACTURA = pNRO_FACTURA
	   AND SERIE_FACTURA = pSERIE_FACTURA;	
  OPEN curTratamientos;
  getTratamientos: LOOP
		FETCH curTratamientos INTO pTRATAMIENTO_LINEA;
		IF finished = 1 THEN 
				LEAVE getTratamientos;
		END IF;
		/* build email list */
		SET pTRATAMIENTOS = CONCAT(pTRATAMIENTOS,'\n',pTRATAMIENTO_LINEA);
  END LOOP getTratamientos;
	
	SELECT FORMA_PAGO_FACTURA, 
				 CODIGO_CLIENTE_FACTURA,
				 TOTAL_LIQUIDO_FACTURA,
				 RAZONSOCIAL_CLIENTE_FACTURA,
				 DIRECCION1_CLIENTE_FACTURA,
				 POBLACION_CLIENTE_FACTURA,
				 PROVINCIA_CLIENTE_FACTURA,
				 CPOSTAL_CLIENTE_FACTURA,
				 FECHA_FACTURA 
		INTO pFORMA_PAGO_FACTURA,
				 pCODIGO_CLIENTE,
				 pTOTAL_LIQUIDO_FACTURA,
				 pRAZONSOCIAL_CLIENTE,
				 pDIRECCION1_CLIENTE,
				 pPOBLACION_CLIENTE,
				 pPROVINCIA_CLIENTE,
				 pCPOSTAL_CLIENTE,
				 pFECHA_FACTURA
		FROM suboc_facturas
   WHERE SERIE_FACTURA = pSERIE_FACTURA
	   AND NRO_FACTURA = pNRO_FACTURA;
		 
		 SELECT IBAN 
		  INTO pIBAN
		 FROM suboc_clientes
		 WHERE CODIGO_CLIENTE = pCODIGO_CLIENTE;
		 
		 IF( EXISTS(
							 SELECT *
							 FROM suboc_formapago
							 WHERE DESCRIPCION_FORMAPAGO =  pFORMA_PAGO_FACTURA) ) THEN
		BEGIN
			SELECT CODIGO_FORMAPAGO, 
			       N_PLAZOS, 
						 DIAS_ENTRE_PLAZOS, 
						 PORCEN_ANTICIPO 
				INTO pCODIGO_FORMAPAGO,
				     pN_PLAZOS, 
						 pDIAS_ENTRE_PLAZOS,  
						 pPORCEN_ANTICIPO
				FROM suboc_formapago
				WHERE DESCRIPCION_FORMAPAGO = pFORMA_PAGO_FACTURA;
				
			IF ((pPORCEN_ANTICIPO = 100)) THEN
			BEGIN
				SELECT GET_NUMEROS_A_LETRAS(pTOTAL_LIQUIDO_FACTURA) 
			         INTO pIMPORTE_LETRA;		 
				INSERT INTO  suboc_recibos 
				       (NRO_FACTURA					         ,
								SERIE_FACTURA                ,
								NRO_PLAZO_RECIBO             ,
								FORMA_PAGO_ORIGEN            ,
								FORMA_PAGO_DESCRIPCION_ORIGEN,								
								EUROS_RECIBO                 ,
								ESTADO_RECIBO                ,
								FECHA_EXPEDICION             ,
								FECHA_VENCIMIENTO            ,
								IBAN                         ,
								FECHA_PAGO                   ,
								LOCALIDAD_EXPEDICION         ,
								CODIGO_CLIENTE               ,
								RAZONSOCIAL_CLIENTE          ,
								DIRECCION1_CLIENTE           ,
								POBLACION_CLIENTE            ,
								PROVINCIA_CLIENTE            ,
								CPOSTAL_CLIENTE              ,
								IMPORTE_LETRA                ,
							  TRATAMIENTOS	)
				VALUES( pNRO_FACTURA,
				        pSERIE_FACTURA,
								1,
								pCODIGO_FORMAPAGO,
								pFORMA_PAGO_FACTURA,
								pTOTAL_LIQUIDO_FACTURA,
								'Pagado',
								pFECHA_FACTURA,
								pFECHA_FACTURA,
								pIBAN,
								pFECHA_FACTURA,
								'Zamora',
								pCODIGO_CLIENTE,
								pRAZONSOCIAL_CLIENTE,
								pDIRECCION1_CLIENTE,
								pPOBLACION_CLIENTE,
								pPROVINCIA_CLIENTE,
								pCPOSTAL_CLIENTE,
								pIMPORTE_LETRA,
								pTRATAMIENTOS
							);
			END;
			ELSE 
			  IF (pN_PLAZOS >= 1) THEN
				BEGIN
			    SET I = 1;
					WHILE (I<=pN_PLAZOS) DO
					BEGIN
					      IF I = 1 THEN 
								BEGIN
								  SET pFECHA_VENCIMIENTO  = pFECHA_FACTURA;
								  SET pIMPORTE_ANTICIPO = pTOTAL_LIQUIDO_FACTURA * (pPORCEN_ANTICIPO/100);
									SET pIMPORTE_RESTO = (pTOTAL_LIQUIDO_FACTURA - pIMPORTE_ANTICIPO);
								  
								END;
								END IF;									
								IF ((I= 1) AND (pPORCEN_ANTICIPO > 0)) THEN								  
									SET pIMPORTE_RECIBO = pIMPORTE_ANTICIPO;
								ELSE
								  IF pN_PLAZOS > 1 THEN 
									  SET pIMPORTE_RECIBO = pIMPORTE_RESTO / (pN_PLAZOS - 1);
									ELSE
										SET pIMPORTE_RECIBO = pIMPORTE_RESTO;
									END IF;
								END IF;
							  SELECT GET_NUMEROS_A_LETRAS(pIMPORTE_RECIBO) 
     			        INTO pIMPORTE_LETRA;	
								IF (I <> 1) THEN
								  SET pFECHA_VENCIMIENTO = ADDDATE(pFECHA_VENCIMIENTO, INTERVAL pDIAS_ENTRE_PLAZOS DAY);
								END IF;
								
								INSERT INTO  suboc_recibos 
												 (NRO_FACTURA					         ,
													SERIE_FACTURA                ,
													NRO_PLAZO_RECIBO             ,
													FORMA_PAGO_ORIGEN            ,													
													FORMA_PAGO_DESCRIPCION_ORIGEN,
													EUROS_RECIBO                 ,
													ESTADO_RECIBO                ,
													FECHA_EXPEDICION             ,
													FECHA_VENCIMIENTO            ,
													IBAN                         ,
													FECHA_PAGO                   ,
													LOCALIDAD_EXPEDICION         ,
													CODIGO_CLIENTE               ,
													RAZONSOCIAL_CLIENTE          ,
													DIRECCION1_CLIENTE           ,
													POBLACION_CLIENTE            ,
													PROVINCIA_CLIENTE            ,
													CPOSTAL_CLIENTE              ,
													IMPORTE_LETRA                ,
													TRATAMIENTOS	)
								VALUES( pNRO_FACTURA,
													pSERIE_FACTURA,
													I,
													pCODIGO_FORMAPAGO,										
													pFORMA_PAGO_FACTURA,
													pIMPORTE_RECIBO,
													'Emitido',
													pFECHA_FACTURA,
													pFECHA_VENCIMIENTO,
													pIBAN,
													NULL,
													'Zamora',
													pCODIGO_CLIENTE,
													pRAZONSOCIAL_CLIENTE,
													pDIRECCION1_CLIENTE,
													pPOBLACION_CLIENTE,
													pPROVINCIA_CLIENTE,
													pCPOSTAL_CLIENTE,
													pIMPORTE_LETRA,
													pTRATAMIENTOS
												);
								SET I = I + 1;
					END;
					END WHILE;
				END;
				END IF;
			END IF;
		END;
		END IF;
		COMMIT;
END $$
DELIMITER ;

-- Recreando procedimiento: PRC_CREAR_RECIBOS_PRESUPUESTO
DROP PROCEDURE IF EXISTS `PRC_CREAR_RECIBOS_PRESUPUESTO`

DELIMITER $$
CREATE  PROCEDURE `PRC_CREAR_RECIBOS_PRESUPUESTO`(IN `pSERIE_FACTURA` varchar(8),
	                                                                         IN `pNRO_FACTURA` int(8))
BEGIN
  DECLARE pCODIGO_FORMAPAGO VARCHAR(10);
	DECLARE pFORMA_PAGO_FACTURA VARCHAR(100);
	DECLARE pN_PLAZOS int(10); 
	DECLARE I int(10);
	DECLARE pDIAS_ENTRE_PLAZOS int(10);
	DECLARE pPORCEN_ANTICIPO decimal(5,2);
	DECLARE pCODIGO_CLIENTE  int(10);
	DECLARE pIBAN varchar(34);
	DECLARE pRAZONSOCIAL_CLIENTE varchar(200);
	DECLARE pDIRECCION1_CLIENTE  varchar(200);
	DECLARE pPOBLACION_CLIENTE  varchar(200);
	DECLARE pPROVINCIA_CLIENTE  varchar(200);
	DECLARE pCPOSTAL_CLIENTE  varchar(15);
	DECLARE pIMPORTE_LETRA  varchar(150);
	DECLARE pTOTAL_LIQUIDO_FACTURA decimal(18,6);
	DECLARE pIMPORTE_RECIBO decimal(18,6);
	DECLARE pIMPORTE_RESTO decimal(18,6);
	DECLARE pIMPORTE_ANTICIPO decimal(18,6);
	DECLARE pFECHA_VENCIMIENTO date;
	DECLARE pFECHA_FACTURA date;
	DECLARE finished INTEGER DEFAULT 0;
	DECLARE pTRATAMIENTO_LINEA VARCHAR(100);
  DECLARE pTRATAMIENTOS varchar(1000) DEFAULT '';
  DECLARE curTratamientos 
        CURSOR FOR 
            SELECT DESCRIPCION_ARTICULO_LINEA 
						  FROM suboc_presupuestos_lineas 
						 WHERE SERIE_FACTURA_LINEA = pSERIE_FACTURA 
						   AND NRO_FACTURA_LINEA = pNRO_FACTURA;
  DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;
	START TRANSACTION;
	DELETE FROM suboc_recibos 
   WHERE NRO_FACTURA = pNRO_FACTURA
	   AND SERIE_FACTURA = pSERIE_FACTURA;	
  OPEN curTratamientos;
  getTratamientos: LOOP
		FETCH curTratamientos INTO pTRATAMIENTO_LINEA;
		IF finished = 1 THEN 
				LEAVE getTratamientos;
		END IF;
		/* build email list */
		SET pTRATAMIENTOS = CONCAT(pTRATAMIENTOS,'\n',pTRATAMIENTO_LINEA);
  END LOOP getTratamientos;
	
	SELECT FORMA_PAGO_FACTURA, 
				 CODIGO_CLIENTE_FACTURA,
				 TOTAL_LIQUIDO_FACTURA,
				 RAZONSOCIAL_CLIENTE_FACTURA,
				 DIRECCION1_CLIENTE_FACTURA,
				 POBLACION_CLIENTE_FACTURA,
				 PROVINCIA_CLIENTE_FACTURA,
				 CPOSTAL_CLIENTE_FACTURA,
				 FECHA_FACTURA 
		INTO pFORMA_PAGO_FACTURA,
				 pCODIGO_CLIENTE,
				 pTOTAL_LIQUIDO_FACTURA,
				 pRAZONSOCIAL_CLIENTE,
				 pDIRECCION1_CLIENTE,
				 pPOBLACION_CLIENTE,
				 pPROVINCIA_CLIENTE,
				 pCPOSTAL_CLIENTE,
				 pFECHA_FACTURA
		FROM suboc_presupuestos
   WHERE SERIE_FACTURA = pSERIE_FACTURA
	   AND NRO_FACTURA = pNRO_FACTURA;
		 
		 SELECT IBAN 
		  INTO pIBAN
		 FROM suboc_clientes
		 WHERE CODIGO_CLIENTE = pCODIGO_CLIENTE;
		 
		 IF( EXISTS(
							 SELECT *
							 FROM suboc_formapago
							 WHERE DESCRIPCION_FORMAPAGO =  pFORMA_PAGO_FACTURA) ) THEN
		BEGIN
			SELECT CODIGO_FORMAPAGO, 
			       N_PLAZOS, 
						 DIAS_ENTRE_PLAZOS, 
						 PORCEN_ANTICIPO 
				INTO pCODIGO_FORMAPAGO,
				     pN_PLAZOS, 
						 pDIAS_ENTRE_PLAZOS,  
						 pPORCEN_ANTICIPO
				FROM suboc_formapago
				WHERE DESCRIPCION_FORMAPAGO = pFORMA_PAGO_FACTURA;
				
			IF ((pPORCEN_ANTICIPO = 100)) THEN
			BEGIN
				SELECT GET_NUMEROS_A_LETRAS(pTOTAL_LIQUIDO_FACTURA) 
			         INTO pIMPORTE_LETRA;		 
				INSERT INTO  suboc_recibos 
				       (NRO_FACTURA					         ,
								SERIE_FACTURA                ,
								NRO_PLAZO_RECIBO             ,
								FORMA_PAGO_ORIGEN            ,
								FORMA_PAGO_DESCRIPCION_ORIGEN,								
								EUROS_RECIBO                 ,
								ESTADO_RECIBO                ,
								FECHA_EXPEDICION             ,
								FECHA_VENCIMIENTO            ,
								IBAN                         ,
								FECHA_PAGO                   ,
								LOCALIDAD_EXPEDICION         ,
								CODIGO_CLIENTE               ,
								RAZONSOCIAL_CLIENTE          ,
								DIRECCION1_CLIENTE           ,
								POBLACION_CLIENTE            ,
								PROVINCIA_CLIENTE            ,
								CPOSTAL_CLIENTE              ,
								IMPORTE_LETRA                ,
							  TRATAMIENTOS	)
				VALUES( pNRO_FACTURA,
				        pSERIE_FACTURA,
								1,
								pCODIGO_FORMAPAGO,
								pFORMA_PAGO_FACTURA,
								pTOTAL_LIQUIDO_FACTURA,
								'Pagado',
								pFECHA_FACTURA,
								pFECHA_FACTURA,
								pIBAN,
								pFECHA_FACTURA,
								'Zamora',
								pCODIGO_CLIENTE,
								pRAZONSOCIAL_CLIENTE,
								pDIRECCION1_CLIENTE,
								pPOBLACION_CLIENTE,
								pPROVINCIA_CLIENTE,
								pCPOSTAL_CLIENTE,
								pIMPORTE_LETRA,
								pTRATAMIENTOS
							);
			END;
			ELSE 
			  IF (pN_PLAZOS >= 1) THEN
				BEGIN
			    SET I = 1;
					WHILE (I<=pN_PLAZOS) DO
					BEGIN
					      IF I = 1 THEN 
								BEGIN
								  SET pFECHA_VENCIMIENTO  = pFECHA_FACTURA;
								  SET pIMPORTE_ANTICIPO = pTOTAL_LIQUIDO_FACTURA * (pPORCEN_ANTICIPO/100);
									SET pIMPORTE_RESTO = (pTOTAL_LIQUIDO_FACTURA - pIMPORTE_ANTICIPO);
								  
								END;
								END IF;									
								IF ((I= 1) AND (pPORCEN_ANTICIPO > 0)) THEN								  
									SET pIMPORTE_RECIBO = pIMPORTE_ANTICIPO;
								ELSE
								  IF pN_PLAZOS > 1 THEN 
									  SET pIMPORTE_RECIBO = pIMPORTE_RESTO / (pN_PLAZOS - 1);
									ELSE
										SET pIMPORTE_RECIBO = pIMPORTE_RESTO;
									END IF;
								END IF;
							  SELECT GET_NUMEROS_A_LETRAS(pIMPORTE_RECIBO) 
     			        INTO pIMPORTE_LETRA;	
								IF (I <> 1) THEN
								  SET pFECHA_VENCIMIENTO = ADDDATE(pFECHA_VENCIMIENTO, INTERVAL pDIAS_ENTRE_PLAZOS DAY);
								END IF;
								
								INSERT INTO  suboc_recibos 
												 (NRO_FACTURA					         ,
													SERIE_FACTURA                ,
													NRO_PLAZO_RECIBO             ,
													FORMA_PAGO_ORIGEN            ,													
													FORMA_PAGO_DESCRIPCION_ORIGEN,
													EUROS_RECIBO                 ,
													ESTADO_RECIBO                ,
													FECHA_EXPEDICION             ,
													FECHA_VENCIMIENTO            ,
													IBAN                         ,
													FECHA_PAGO                   ,
													LOCALIDAD_EXPEDICION         ,
													CODIGO_CLIENTE               ,
													RAZONSOCIAL_CLIENTE          ,
													DIRECCION1_CLIENTE           ,
													POBLACION_CLIENTE            ,
													PROVINCIA_CLIENTE            ,
													CPOSTAL_CLIENTE              ,
													IMPORTE_LETRA                ,
													TRATAMIENTOS	)
								VALUES( pNRO_FACTURA,
													pSERIE_FACTURA,
													I,
													pCODIGO_FORMAPAGO,										
													pFORMA_PAGO_FACTURA,
													pIMPORTE_RECIBO,
													'Emitido',
													pFECHA_FACTURA,
													pFECHA_VENCIMIENTO,
													pIBAN,
													NULL,
													'Zamora',
													pCODIGO_CLIENTE,
													pRAZONSOCIAL_CLIENTE,
													pDIRECCION1_CLIENTE,
													pPOBLACION_CLIENTE,
													pPROVINCIA_CLIENTE,
													pCPOSTAL_CLIENTE,
													pIMPORTE_LETRA,
													pTRATAMIENTOS
												);
								SET I = I + 1;
					END;
					END WHILE;
				END;
				END IF;
			END IF;
		END;
		END IF;
		COMMIT;
END $$
DELIMITER ;

-- Recreando procedimiento: PRC_GET_DATA_ARTICULO
DROP PROCEDURE IF EXISTS `PRC_GET_DATA_ARTICULO`

DELIMITER $$
CREATE  PROCEDURE `PRC_GET_DATA_ARTICULO`(IN pidcodarticulo varchar(200), 
											OUT pidnomarticulo varchar(200), 
											OUT pidprecioventa decimal(18,6))
BEGIN
   IF( EXISTS(
             SELECT *
             FROM suboc_articulos
             WHERE `CODIGO_ARTICULO` =  pidcodarticulo) ) THEN
	BEGIN
	  SELECT DESCRIPCION_ARTICULO, PRECIOVENTA_ARTICULO 
      INTO pidnomarticulo, pidprecioventa	      
      FROM suboc_articulos
	   WHERE CODIGO_ARTICULO = pidcodarticulo;
	END;
	ELSE
	BEGIN
	  SET pidnomarticulo = '';
	  SET pidprecioventa = 0.00;
	END;
  END IF;
END $$
DELIMITER ;

-- Recreando procedimiento: PRC_GET_DATA_CLIENTE
DROP PROCEDURE IF EXISTS `PRC_GET_DATA_CLIENTE`

DELIMITER $$
CREATE  PROCEDURE `PRC_GET_DATA_CLIENTE`(
    IN `pCODIGO_CLIENTE` int(10),
    OUT `pRAZONSOCIAL_CLIENTE` varchar(200),
    OUT `pNOMBRE` varchar(100),
    OUT `pAPELLIDOS` varchar(100),
    OUT `pNIF_CLIENTE` varchar(50),
    OUT `pMOVIL_CLIENTE` varchar(40),
    OUT `pEMAIL_CLIENTE` varchar(200),
    OUT `pDIRECCION1_CLIENTE` varchar(200),
    OUT `pDIRECCION2_CLIENTE` varchar(200),
    OUT `pPOBLACION_CLIENTE` varchar(200),
    OUT `pPROVINCIA_CLIENTE` varchar(200),
    OUT `pCPOSTAL_CLIENTE` varchar(15),
    OUT `pPAIS_CLIENTE` varchar(150),
    OUT `pTIPOID_INT_CLIENTE` varchar(20) )
BEGIN
  IF EXISTS(SELECT 1 
            FROM suboc_clientes
            WHERE `CODIGO_CLIENTE` = pCODIGO_CLIENTE) THEN
    
    SELECT `RAZONSOCIAL_CLIENTE`,
           `NOMBRE`,
           `APELLIDOS`,
           `NIF_CLIENTE`,
           `MOVIL_CLIENTE`,
           `EMAIL_CLIENTE`,
           `DIRECCION1_CLIENTE`,
           `DIRECCION2_CLIENTE`,
           `POBLACION_CLIENTE`,
           `PROVINCIA_CLIENTE`,
           `CPOSTAL_CLIENTE`,
           `PAIS_CLIENTE`,
           `TIPOID_INT_CLIENTE`
    INTO   pRAZONSOCIAL_CLIENTE,
           pNOMBRE,
           pAPELLIDOS,
           pNIF_CLIENTE,
           pMOVIL_CLIENTE,
           pEMAIL_CLIENTE,
           pDIRECCION1_CLIENTE,
           pDIRECCION2_CLIENTE,
           pPOBLACION_CLIENTE,
           pPROVINCIA_CLIENTE,
           pCPOSTAL_CLIENTE,
           pPAIS_CLIENTE,
           pTIPOID_INT_CLIENTE
    FROM suboc_clientes
    WHERE `CODIGO_CLIENTE` = pCODIGO_CLIENTE;
    
  ELSE
    -- Inicializar todas las variables OUT, no solo una
    SET pRAZONSOCIAL_CLIENTE = '';
    SET pNOMBRE = '';
    SET pAPELLIDOS = '';
    SET pNIF_CLIENTE = '';
    SET pMOVIL_CLIENTE = '';
    SET pEMAIL_CLIENTE = '';
    SET pDIRECCION1_CLIENTE = '';
    SET pDIRECCION2_CLIENTE = '';
    SET pPOBLACION_CLIENTE = '';
    SET pPROVINCIA_CLIENTE = '';
    SET pCPOSTAL_CLIENTE = '';
    SET pPAIS_CLIENTE = '';
    SET pTIPOID_INT_CLIENTE = '';
  END IF;
END $$
DELIMITER ;

-- Recreando procedimiento: PRC_GET_EMPTY_FACTURA_PARA_VALIDAR
DROP PROCEDURE IF EXISTS `PRC_GET_EMPTY_FACTURA_PARA_VALIDAR`

DELIMITER $$
CREATE  PROCEDURE `PRC_GET_EMPTY_FACTURA_PARA_VALIDAR`(IN `pNif` varchar(10),
    IN `pRazonSocial` varchar(200),
    OUT `pJsonResult` longtext)
BEGIN
    DECLARE vTotalFactura decimal(18,6);
    DECLARE vTotalIVA decimal(18,6);
    
    /* Calcular valores (simplificado) */
    SET vTotalIVA = 0;
    SET vTotalFactura = 0;
    
    /* Construir JSON básico */
    SET pJsonResult = JSON_OBJECT(
        'invoice', JSON_OBJECT(
            'id', JSON_OBJECT(
                'number', CONCAT(CONCAT('VALID_NIF_',pNIF) , '/', '1'),
                'issuedTime', DATE_FORMAT(CURRENT_DATE, '%Y-%m-%d')
            ),
            'type', 'F1',
            'description', JSON_OBJECT(
                'text', 'Factura de servicios odontológicos',
                'operationDate', DATE_FORMAT(CURRENT_DATE, '%Y-%m-%d')
            ),
            'recipient', JSON_OBJECT(
                'irsId', pNIF,
                'name', pRazonSocial,
                'country', 'ES'
            ),
            'vatLines', JSON_ARRAY(
                JSON_OBJECT(
                    'vatOperation', 'E1',
                    'base', 0,
                    'rate', 0,
                    'amount', 0,
                    'vatKey', '01'
                )
            ),
            'total', 0,
            'amount', 0
        )
    );
END $$
DELIMITER ;

-- Recreando procedimiento: PRC_RESUMEN_ERRORES_VERIFACTU
DROP PROCEDURE IF EXISTS `PRC_RESUMEN_ERRORES_VERIFACTU`

DELIMITER $$
CREATE  PROCEDURE `PRC_RESUMEN_ERRORES_VERIFACTU`()
BEGIN
    SELECT 
        'ERRORES DE VERIFACTU POR CÓDIGO' as TITULO,
        '' as SEPARADOR;
    
    SELECT 
        CODIGO_ERROR_VERIFACTU as CODIGO_ERROR,
        COUNT(*) as CANTIDAD_ERRORES,
        GROUP_CONCAT(DISTINCT CONCAT(SERIE_FACTURA, '/', NRO_FACTURA) SEPARATOR ', ') as FACTURAS_AFECTADAS,
        MAX(FECHA_PROCESAMIENTO) as ULTIMO_ERROR
    FROM suboc_verifactu_queue 
    WHERE CODIGO_ERROR_VERIFACTU IS NOT NULL
    GROUP BY CODIGO_ERROR_VERIFACTU
    ORDER BY CANTIDAD_ERRORES DESC;
    
    SELECT 
        'OPERACIONES CON QUEUE_ID DE VERIFACTU' as TITULO,
        '' as SEPARADOR;
        
    SELECT 
        COUNT(CASE WHEN VERIFACTU_QUEUE_ID IS NOT NULL THEN 1 END) as CON_QUEUE_ID,
        COUNT(CASE WHEN VERIFACTU_QUEUE_ID IS NULL THEN 1 END) as SIN_QUEUE_ID,
        COUNT(*) as TOTAL_OPERACIONES
    FROM suboc_verifactu_queue 
    WHERE ESTADO_COLA = 'COMPLETADO';
END $$
DELIMITER ;

-- Recreando procedimiento: SET_CONSOLIDACION_FASE
DROP PROCEDURE IF EXISTS `SET_CONSOLIDACION_FASE`

DELIMITER $$
CREATE  PROCEDURE `SET_CONSOLIDACION_FASE`(IN pNumFactura int(8), 
                                           IN pSerieFactura varchar(8), 
                                           IN pFaseConso varchar(20), 
                                           IN pConso varchar(1))
BEGIN
  START TRANSACTION;
	 UPDATE suboc_facturas 
	    SET CONSOLIDACION_FACTURA = pConso,
          FASE_CONSOLIDACION_FACTURA = pFaseConso, 
          FECHA_ULT_CONSO_FACTURA = CURRENT_TIMESTAMP
	  WHERE NRO_FACTURA = pNumFactura 
      AND SERIE_FACTURA = pSerieFactura;
	COMMIT;
END $$
DELIMITER ;

-- === FUNCIONES ===
-- Recreando función: FNC_BUSCAR_POR_VERIFACTU_QUEUE_ID
DROP FUNCTION IF EXISTS `FNC_BUSCAR_POR_VERIFACTU_QUEUE_ID`

DELIMITER $$
CREATE  FUNCTION `FNC_BUSCAR_POR_VERIFACTU_QUEUE_ID`(pQueueId INT) RETURNS varchar(100) CHARSET utf8mb4 COLLATE utf8mb4_spanish_ci
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE vFactura VARCHAR(100) DEFAULT '';
    
    SELECT CONCAT(SERIE_FACTURA, '/', NRO_FACTURA) 
    INTO vFactura
    FROM suboc_verifactu_queue 
    WHERE VERIFACTU_QUEUE_ID = pQueueId
    LIMIT 1;
    
    RETURN COALESCE(vFactura, 'NO ENCONTRADA');
END $$
DELIMITER ;

-- Recreando función: FNC_GET_NEXT_LINEA_FACTURA
DROP FUNCTION IF EXISTS `FNC_GET_NEXT_LINEA_FACTURA`

DELIMITER $$
CREATE  FUNCTION `FNC_GET_NEXT_LINEA_FACTURA`(pnumfac varchar(8), 
                                             pserie varchar(8)) RETURNS varchar(3) CHARSET utf8 COLLATE utf8_spanish_ci
BEGIN
 DECLARE ppresul varchar(3);
 DECLARE pnextnum varchar(3);
 SET pnextnum = (select lpad((max(LINEA_LINEA)+10),3,'0' ) 
                   from suboc_facturas_lineas 
                  where NRO_FACTURA_LINEA = pnumfac 
                    AND SERIE_FACTURA_LINEA = pserie);
 IF (pnextnum IS NULL) THEN
   SET ppresul = '010';
 ELSE
   SET ppresul = pnextnum;
 END IF;
 RETURN ppresul;
END $$
DELIMITER ;

-- Recreando función: FNC_GET_NEXT_LINEA_PRESUPUESTO
DROP FUNCTION IF EXISTS `FNC_GET_NEXT_LINEA_PRESUPUESTO`

DELIMITER $$
CREATE  FUNCTION `FNC_GET_NEXT_LINEA_PRESUPUESTO`(pnumfac varchar(8), 
                                             pserie varchar(8)) RETURNS varchar(3) CHARSET utf8 COLLATE utf8_spanish_ci
BEGIN
 DECLARE ppresul varchar(3);
 DECLARE pnextnum varchar(3);
 SET pnextnum = (select lpad((max(LINEA_LINEA)+10),3,'0' ) 
                   from suboc_presupuestos_lineas 
                  where NRO_FACTURA_LINEA = pnumfac 
                    AND SERIE_FACTURA_LINEA = pserie);
 IF (pnextnum IS NULL) THEN
   SET ppresul = '010';
 ELSE
   SET ppresul = pnextnum;
 END IF;
 RETURN ppresul;
END $$
DELIMITER ;

-- Recreando función: GET_NUMEROS_A_LETRAS
DROP FUNCTION IF EXISTS `GET_NUMEROS_A_LETRAS`

DELIMITER $$
CREATE  FUNCTION `GET_NUMEROS_A_LETRAS`(NUMERO DECIMAL(12,2)) RETURNS varchar(200) CHARSET utf8mb4 COLLATE utf8mb4_spanish_ci
BEGIN
	DECLARE MILLARES INT;
	DECLARE CENTENAS INT;
	DECLARE CENTIMOS INT;
	DECLARE CENTIMO_AUX VARCHAR(200);
	DECLARE CENTIMO_AUX_CON VARCHAR(200);
	DECLARE MIL_AUX VARCHAR(200);
	DECLARE EN_LETRAS VARCHAR(200);
	DECLARE ENTERO INT;
	DECLARE AUX VARCHAR(15);
	DECLARE PRUEBA VARCHAR(200);
	
	SET EN_LETRAS = '';
	SET CENTIMO_AUX_CON = '';
	SET ENTERO = TRUNCATE(NUMERO,0);
	SET MILLARES = TRUNCATE(ENTERO / 1000,0);
	SET CENTENAS = ENTERO MOD 1000;
	SET CENTIMOS = (TRUNCATE(NUMERO,2) * 100) MOD 100;
	
	IF ((MILLARES = 1)) THEN
		SET EN_LETRAS = 'MIL ';
	ELSE 
		IF (MILLARES > 0) THEN
				SET EN_LETRAS = CONCAT(EN_LETRAS , GET_NUMERO_MENOR_MIL(MILLARES) ,'MIL ');
				SET EN_LETRAS = REPLACE(EN_LETRAS,'UNO ','UN ');
		END IF;
	END IF;
	
	IF ((CENTENAS > 0) OR ((ENTERO = 0) AND (CENTIMOS = 0))) THEN
		BEGIN
			SET EN_LETRAS = CONCAT(EN_LETRAS, GET_NUMERO_MENOR_MIL(CENTENAS));			
		END;
	END IF;
	IF (CENTIMOS > 0) THEN
	BEGIN
		IF (CENTIMOS = 1) THEN
			SET  AUX = 'CÉNTIMO ';
		ELSE
			SET AUX = 'CÉNTIMOS ';
		END IF;	
		IF (CENTIMOS > 0) THEN
			SET CENTIMO_AUX = GET_NUMERO_MENOR_MIL(CENTIMOS);
			SET CENTIMO_AUX = REPLACE(CENTIMO_AUX,'UNO ','UN '); 
			IF ENTERO <> 0 THEN 
			  SET CENTIMO_AUX_CON = 'CON ' ; 
			END IF;
			SET EN_LETRAS = CONCAT(EN_LETRAS, CENTIMO_AUX_CON, CENTIMO_AUX , AUX);
		ELSE
			SET EN_LETRAS = CONCAT(EN_LETRAS, CENTIMO_AUX, AUX);		
		END IF;
	END;
	END IF;
	RETURN(EN_LETRAS);
END $$
DELIMITER ;

-- Recreando función: GET_NUMERO_MENOR_MIL
DROP FUNCTION IF EXISTS `GET_NUMERO_MENOR_MIL`

DELIMITER $$
CREATE  FUNCTION `GET_NUMERO_MENOR_MIL`(NUMERO DECIMAL(4)) RETURNS varchar(100) CHARSET utf8mb4 COLLATE utf8mb4_spanish_ci
BEGIN
       DECLARE CENTENAS INT;
       DECLARE DECENAS INT;
       DECLARE UNIDADES INT;
       DECLARE EN_LETRAS VARCHAR(100);
       DECLARE UNIR VARCHAR(2);
			 SET EN_LETRAS = '';
        IF (NUMERO = 100) THEN
            RETURN ('CIEN ');
        ELSEIF NUMERO = 0 THEN
            RETURN ('CERO ');
        ELSEIF NUMERO = 1 THEN
            RETURN ('UNO ');
        ELSE
            SET CENTENAS = TRUNCATE(NUMERO / 100,0);
            SET DECENAS  = TRUNCATE((NUMERO MOD 100)/10,0);
            SET UNIDADES = NUMERO MOD 10;
            SET UNIR = 'Y ';
            
						IF CENTENAS = 1 THEN
                SET EN_LETRAS = 'CIENTO ';
            ELSEIF CENTENAS = 2 THEN
                SET EN_LETRAS = 'DOSCIENTOS ';
            ELSEIF CENTENAS = 3 THEN
                SET EN_LETRAS = 'TRESCIENTOS ';
            ELSEIF CENTENAS = 4 THEN
                SET EN_LETRAS = 'CUATROCIENTOS ';
            ELSEIF CENTENAS = 5 THEN
                SET EN_LETRAS = 'QUINIENTOS ';
            ELSEIF CENTENAS = 6 THEN
                SET EN_LETRAS = 'SEISCIENTOS ';
            ELSEIF CENTENAS = 7 THEN
                SET EN_LETRAS = 'SETECIENTOS ';
            ELSEIF CENTENAS = 8 THEN
                SET EN_LETRAS = 'OCHOCIENTOS ';
            ELSEIF CENTENAS = 9 THEN
                SET EN_LETRAS = 'NOVECIENTOS ';
            END IF;
            
						IF DECENAS = 3 THEN
                SET EN_LETRAS = CONCAT(EN_LETRAS , 'TREINTA ');
            ELSEIF DECENAS = 4 THEN
                SET EN_LETRAS = CONCAT(EN_LETRAS , 'CUARENTA ');
            ELSEIF DECENAS = 5 THEN
                SET EN_LETRAS = CONCAT(EN_LETRAS , 'CINCUENTA ');
            ELSEIF DECENAS = 6 THEN
                SET EN_LETRAS = CONCAT(EN_LETRAS , 'SESENTA ');
            ELSEIF DECENAS = 7 THEN
                SET EN_LETRAS = CONCAT(EN_LETRAS , 'SETENTA ');
            ELSEIF DECENAS = 8 THEN
                SET EN_LETRAS = CONCAT(EN_LETRAS , 'OCHENTA ');
            ELSEIF DECENAS = 9 THEN
                SET EN_LETRAS = CONCAT(EN_LETRAS , 'NOVENTA ');
            ELSEIF DECENAS = 1 THEN
                IF UNIDADES < 6 THEN
                    IF UNIDADES = 0 THEN
                        SET EN_LETRAS = CONCAT(EN_LETRAS , 'DIEZ ');
                    ELSEIF UNIDADES = 1 THEN
                        SET EN_LETRAS = CONCAT(EN_LETRAS , 'ONCE ');
                    ELSEIF UNIDADES = 2 THEN
                        SET EN_LETRAS = CONCAT(EN_LETRAS , 'DOCE ');
                    ELSEIF UNIDADES = 3 THEN
                        SET EN_LETRAS = CONCAT(EN_LETRAS , 'TRECE ');
                    ELSEIF UNIDADES = 4 THEN
                        SET EN_LETRAS = CONCAT(EN_LETRAS , 'CATORCE ');
                    ELSEIF UNIDADES = 5 THEN
                        SET EN_LETRAS = CONCAT(EN_LETRAS , 'QUINCE ');
                    END IF;
                    SET UNIDADES = 0;
                ELSE
                    SET EN_LETRAS = CONCAT(EN_LETRAS, 'DIECI');
                    SET UNIR = '';
                END IF;
            ELSEIF (DECENAS = 2) THEN
                IF (UNIDADES = 0) THEN
                    SET EN_LETRAS = CONCAT(EN_LETRAS, 'VEINTE ');
                ELSE
                    SET EN_LETRAS = CONCAT(EN_LETRAS, 'VEINTI');
                END IF;
                SET UNIR = '';
            ELSEIF (DECENAS = 0) THEN
                SET UNIR = '';
            END IF;
						
            IF (UNIDADES = 1) THEN
                SET EN_LETRAS = CONCAT(EN_LETRAS, UNIR, 'UNO ');
            ELSEIF UNIDADES = 2 THEN
                SET EN_LETRAS = CONCAT(EN_LETRAS, UNIR, 'DOS ');
            ELSEIF UNIDADES = 3 THEN
                SET EN_LETRAS = CONCAT(EN_LETRAS, UNIR, 'TRES ');
            ELSEIF UNIDADES = 4 THEN
                SET EN_LETRAS = CONCAT(EN_LETRAS, UNIR, 'CUATRO ');
            ELSEIF UNIDADES = 5 THEN
                SET EN_LETRAS = CONCAT(EN_LETRAS, UNIR, 'CINCO ');
            ELSEIF UNIDADES = 6 THEN
                SET EN_LETRAS = CONCAT(EN_LETRAS, UNIR, 'SEIS ');
            ELSEIF UNIDADES = 7 THEN
                SET EN_LETRAS = CONCAT(EN_LETRAS, UNIR, 'SIETE ');
            ELSEIF UNIDADES = 8 THEN
                SET EN_LETRAS = CONCAT(EN_LETRAS, UNIR, 'OCHO ');
            ELSEIF UNIDADES = 9 THEN
                SET EN_LETRAS = CONCAT(EN_LETRAS , UNIR , 'NUEVE ');
            END IF;
        END IF;
        RETURN(EN_LETRAS);
    END $$
DELIMITER ;


