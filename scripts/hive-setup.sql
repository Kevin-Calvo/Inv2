CREATE EXTERNAL TABLE IF NOT EXISTS web_logs (
  ip STRING,
  log_timestamp STRING,
  request STRING,
  status_code INT,
  response_size INT,
  referrer STRING,
  user_agent STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  "separatorChar" = ",",
  "quoteChar"     = "\""
)
STORED AS TEXTFILE
LOCATION '/data'
TBLPROPERTIES ("skip.header.line.count"="1");



-- Consultas HiveQL representativas
-- 1. Cantidad de registros
SELECT COUNT(*) FROM web_logs;

-- 2. Códigos de estado más comunes
SELECT status_code, COUNT(*) AS total FROM web_logs GROUP BY status_code ORDER BY total DESC;

-- 3. Promedio de tamaño de respuesta
SELECT AVG(response_size) FROM web_logs;

-- 4. Filtrar solo errores 500
SELECT * FROM web_logs WHERE status_code = 500;

-- 5. Agrupar por user agent
SELECT user_agent, COUNT(*) FROM web_logs GROUP BY user_agent;
