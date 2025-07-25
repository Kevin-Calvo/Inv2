# Prueba de Caso Hive con Tabla Externa web_logs
## Descripción
Este proyecto monta un servicio Hive en Docker y crea una tabla externa web_logs que lee datos CSV desde un volumen local. Se incluye una serie de consultas HiveQL representativas para validar los datos.

## Requisitos Previos
Docker y Docker Compose instalados en el sistema.

Archivo CSV con datos de logs en formato CSV con encabezado, ubicado en ./data (mismo nivel donde está el docker-compose.yml).

Puerto 10000 libre para mapear HiveServer2.

## Estructura de Archivos
```plaintext
.
├── docker-compose.yml
├── data/
│   └── web_logs.csv      <-- archivo CSV con los datos (encabezado en primera línea)
└── scripts
│   └── hive_setup.sql  <-- (opcional) script para crear la tabla
```

## Paso 1: Preparar los Datos
Coloque su archivo CSV dentro de la carpeta ./data junto al archivo docker-compose.yml.
Ejemplo de archivo web_logs.csv:

```csv
ip,timestamp,request,status_code,response_size,referrer,user_agent
192.168.1.1,2025-06-17T12:34:56Z,"GET /index.html",200,1024,"http://example.com","Mozilla/5.0"
...
```

Nota: la tabla usa log_timestamp en lugar de timestamp, hay que asegurarse que el CSV tenga la columna timestamp igual, ya que se mapea ese dato a log_timestamp en la tabla.

## Paso 2: Levantar el Contenedor Hive
Ejecutar el siguiente comando para iniciar Hive Server:
```
docker-compose up -d --build
```
Esto hará que el contenedor hive-server esté corriendo y exponga HiveServer2 en el puerto 10000.

## Paso 4: Crear la Tabla Externa
Conectado al hive, se ejecuta la creación de la tabla:

```
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
```

## Paso 5: Ejecutar Consultas Representativas
Ejemplos de consultas para validar los datos:

### Cantidad total de registros:
```
SELECT COUNT(*) FROM web_logs;
```
### Códigos de estado más comunes:
```
SELECT status_code, COUNT(*) AS total FROM web_logs GROUP BY status_code ORDER BY total DESC;
```
### Promedio de tamaño de respuesta:
```
SELECT AVG(response_size) FROM web_logs;
```
### Filtrar solo errores 500:
```
SELECT * FROM web_logs WHERE status_code = 500;
```
### Agrupar por user agent:
```
SELECT user_agent, COUNT(*) FROM web_logs GROUP BY user_agent;
```
