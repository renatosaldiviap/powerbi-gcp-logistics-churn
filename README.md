# 🚚 Apex Logistics | Operational SLA & Churn Analytics (GCP + Power BI)

![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Google Cloud Platform](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white)
![BigQuery](https://img.shields.io/badge/BigQuery-669DF6?style=for-the-badge&logo=google&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-003B57?style=for-the-badge&logo=postgresql&logoColor=white)
![DAX](https://img.shields.io/badge/DAX-Yellow?style=for-the-badge)

## 📌 Executive Summary

Este proyecto implementa una solución analítica **End-to-End** orientada a cuantificar el impacto financiero de las fallas operativas de entregas en la tasa de cancelación de clientes (**Churn**) y el Ingreso Mensual Recurrente (**MRR**).

Mediante la integración de **Google Cloud Storage (GCS)**, **BigQuery** y **Power BI**, se diseñó una arquitectura desacoplada y un modelo en estrella (Star Schema) basado en metodología **Kimball**, permitiendo aislar retrasos críticos de transporte y correlacionarlos con pérdidas de cuentas corporativas.

---

## 🛠️ Tech Stack & Architecture

- **Cloud Storage (GCS):** Data lake de capas staging para almacenamiento bruto de logs de despachos y facturación.
- **Google BigQuery:** Data Warehouse para transformación, limpieza (DDL/DML) y creación de modelo dimensional (Dimensiones y Hechos) + Vistas analíticas.
- **Power BI Desktop:** Modelamiento estrella (1:*), desarrollo de lógica de negocio en **DAX** y maquetación UI/UX con enfoque "Card UI" para toma de decisiones ejecutivas.
- **Storage Mode:** `Import` con estrategia de actualización programada (Cost & Performance Optimization).

[ CSV Raw Data ]
│
▼
[ Google Cloud Storage ] (Bucket Staging)
│
▼
[ Google BigQuery ]   ──► SQL DDL/DML Transformations
──► Dim & Fact Tables (Kimball)
──► Analytical Views (vw_analisis_churn)
│
▼  (Import Mode)
[ Power BI ]         ──► Star Schema Relationships
──► DAX Measures (_medidas)
──► Executive UI/UX Dashboard

---

## 📊 Data Model & Architecture (Star Schema)

El modelo de datos se diseñó bajo las mejores prácticas de **Kimball**, separando procesos de negocio con distinta granularidad para evitar duplicación no deseada (*fan-out*):

- **`dim_clientes` (Dimensión):** Almacena el máster de cuentas, segmento (`tier_level`), zona geográfica y estado actual (`is_active`).
- **`fact_envios` (Hecho Operacional):** Registra eventos de transporte, identificadores de ruta, zonas y minutos de retraso (`tiempo_retraso_min`).
- **`fact_facturacion` (Hecho Financiero):** Registra transacciones de cobro y contratos recurrentes (`monto_mrr`).
- **`vw_analisis_churn` (Vista BigQuery):** Agregación consolidada a nivel de cliente para auditorías de alto nivel.

---

## 📐 Core DAX Measures

Se estructuró una tabla vacía dedicada (`_medidas`) para albergar la lógica de negocio central:

- **Tasa de Churn (`Tasa_Churn`):**
  ```dax
  Tasa_Churn = 
  DIVIDE(
      CALCULATE(COUNTROWS('dim_clientes'), 'dim_clientes'[is_active] = FALSE),
      COUNTROWS('dim_clientes'),
      0
  )

- MRR en Riesgo / Perdido (MRR_En_Riesgo):

    Fragmento de código
    MRR_En_Riesgo = 
    CALCULATE(
        SUM('fact_facturacion'[monto_mrr]),
        'dim_clientes'[is_active] = FALSE
    )

- Promedio de Retraso (Avg_Retraso_Minutos):

    Fragmento de código
    Avg_Retraso_Minutos = AVERAGE('fact_envios'[tiempo_retraso_min])

- Envíos Críticos (Envios_Criticos_Total):

    Fragmento de código
    Envios_Criticos_Total = 
    CALCULATE(
        COUNTROWS('fact_envios'),
        'fact_envios'[tiempo_retraso_min] > 45
    )

💡 Key Business Insights
1. Umbral Crítico de Tolerancia: Los clientes que registraron un promedio de retraso superior a 45 minutos presentaron una tasa de cancelación (Churn) del 100%.
2. Impacto Financiero Directo: El incumplimiento de SLA de transporte afectó de forma desproporcionada las cuentas Enterprise, representando el mayor porcentaje del MRR en Riesgo.
3. Foco Geográfico: La zona Centro concentró las mayores demoras operativas, convirtiéndose en el área prioritaria para renegociación de contratos logísticos.

🖼️ Dashboard Preview

![alt text](image.png)

