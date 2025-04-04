WITH All_IGF1 AS (
    SELECT 
        f.nfer_pid AS NFER_PID,
        f.nfer_dtm AS Test_Date,
        f.nfer_normalised_value AS Hba1c_Value,
        f.nfer_normalised_unit AS Unit,
        f.patient_age_at_event AS Age_At_Test
    FROM FACT_LAB_TEST f
    WHERE f.nfer_pid IN ({acromegaly_ids_str})
    AND (
        LOWER(CAST(f.lab_subtype_code AS STRING)) LIKE '%a1c%' 
        OR LOWER(CAST(f.lab_subtype_code AS STRING)) LIKE '%hba1c%'
    )
    AND (
        LOWER(f.nfer_variable_name) LIKE '%a1c%'
        OR LOWER(f.nfer_variable_name) LIKE '%hba1c%'
    )
    LIMIT 10000
),

Harmonized_Data AS (
    SELECT 
        h.nfer_pid AS NFER_PID,
        h.nfer_dtm AS Harmonized_Test_Date,
        h.result_txt AS Harmonized_Result,
        h.unit_of_measure_txt AS Harmonized_Unit
    FROM FACT_HARMONIZED_MEASUREMENTS h
    WHERE h.nfer_pid IN ({acromegaly_ids_str})
    AND (
        LOWER(h.measurement_subtype_description) LIKE '%a1c%'
        OR LOWER(h.measurement_subtype_description) LIKE '%hba1c%'
    )
    LIMIT 10000
)

SELECT 
    i.NFER_PID,
    i.Test_Date,
    i.Hba1c_Value,
    i.Unit,
    i.Age_At_Test,
    h.Harmonized_Test_Date,
    h.Harmonized_Result,
    h.Harmonized_Unit
FROM All_IGF1 i
LEFT JOIN Harmonized_Data h 
    ON i.NFER_PID = h.NFER_PID 
ORDER BY i.NFER_PID, i.Test_Date;
