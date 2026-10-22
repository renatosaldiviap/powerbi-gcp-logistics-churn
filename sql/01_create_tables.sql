-- 1. Dimensión Clientes (Capa Limpia)
CREATE OR REPLACE TABLE `apex_retail_logistics.dim_clientes` AS
SELECT 
  CAST(client_id AS STRING) AS cliente_id,
  TRIM(company_name) AS nombre_empresa,
  tier_level,
  CAST(signup_date AS DATE) AS fecha_registro,
  is_active
FROM `apex_retail_logistics.stg_clientes`;

-- 2. Tabla de Hechos: Despachos y Operaciones
CREATE OR REPLACE TABLE `apex_retail_logistics.fact_envios` AS
SELECT 
  CAST(envio_id AS STRING) AS envio_id,
  CAST(client_id AS STRING) AS cliente_id,
  CAST(fecha_envio AS DATE) AS fecha_envio,
  CAST(tiempo_retraso_min AS INT64) AS tiempo_retraso_min,
  TRIM(estado_entrega) AS estado_entrega,
  TRIM(zona) AS zona
FROM `apex_retail_logistics.stg_despachos`;

-- 3. Tabla de Hechos: Facturación
CREATE OR REPLACE TABLE `apex_retail_logistics.fact_facturacion` AS
SELECT 
  CAST(factura_id AS STRING) AS factura_id,
  CAST(client_id AS STRING) AS cliente_id,
  CAST(monto_mrr AS NUMERIC) AS monto_mrr,
  CAST(fecha_pago AS DATE) AS fecha_pago,
  CAST(dias_mora AS INT64) AS dias_mora
FROM `apex_retail_logistics.stg_facturacion`;