CREATE OR REPLACE VIEW `apex_retail_logistics.vw_analisis_churn` AS
WITH ResumenOperaciones AS (
    SELECT 
        cliente_id,
        COUNT(envio_id) AS total_envios,
        SUM(CASE WHEN tiempo_retraso_min > 45 THEN 1 ELSE 0 END) AS envios_criticos_atrasados,
        AVG(tiempo_retraso_min) AS retraso_promedio_min
    FROM `apex_retail_logistics.fact_envios`
    GROUP BY cliente_id
),
ResumenFinanciero AS (
    SELECT 
        cliente_id,
        SUM(monto_mrr) AS mrr_total,
        AVG(dias_mora) AS dias_mora_promedio
    FROM `apex_retail_logistics.fact_facturacion`
    GROUP BY cliente_id
)
SELECT 
    c.cliente_id,
    c.nombre_empresa,
    c.tier_level,
    c.fecha_registro,
    c.is_active,
    CASE WHEN c.is_active = FALSE THEN 1 ELSE 0 END AS flag_churn,
    COALESCE(o.total_envios, 0) AS total_envios,
    COALESCE(o.envios_criticos_atrasados, 0) AS envios_criticos_atrasados,
    COALESCE(o.retraso_promedio_min, 0) AS retraso_promedio_min,
    COALESCE(f.mrr_total, 0) AS mrr_total,
    COALESCE(f.dias_mora_promedio, 0) AS dias_mora_promedio
FROM `apex_retail_logistics.dim_clientes` c
LEFT JOIN ResumenOperaciones o ON c.cliente_id = o.cliente_id
LEFT JOIN ResumenFinanciero f ON c.cliente_id = f.cliente_id;