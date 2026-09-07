#!/bin/bash
# Datos de usuario de la plantilla de lanzamiento de la Actividad 5.2.
# Mismo arranque que la 5.1 (con el agente de CloudWatch), pero cambia el
# almacenamiento de imagenes: de EFS (habia que montarlo a mano en cada
# replica) a S3 (compartido de forma nativa, sin punto de montaje). Ya no
# hace falta montar EFS para las imagenes de producto.
#
# ANTES DE PEGAR ESTE SCRIPT EN LA PLANTILLA DE LANZAMIENTO, sustituye:
#   EDITA-TU-IDENTIFICADOR             -> el mismo identificador de siempre
#   EDITA-URL-DE-TU-BUCKET-FRONTEND    -> el origen que ya usaste en CORS en la 3.3
#   EDITA-NOMBRE-DE-TU-BUCKET-IMAGENES -> el bucket que creas en el Paso 1 de hoy

set -e

IDENTIFICADOR="EDITA-TU-IDENTIFICADOR"
ORIGEN_FRONTEND="EDITA-URL-DE-TU-BUCKET-FRONTEND"
BUCKET_IMAGENES="EDITA-NOMBRE-DE-TU-BUCKET-IMAGENES"

# Identidad de esta replica concreta, para que /api/instancia distinga una de otra
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
export APP_INSTANCE_NAME=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)

# Endpoint y contrasena de RDS, obtenidos por CLI - nunca grabados en la imagen
export DB_HOST=$(aws rds describe-db-instances \
  --db-instance-identifier "escaparate-db-${IDENTIFICADOR}" \
  --query "DBInstances[0].Endpoint.Address" --output text)

DB_SECRET_ARN=$(aws rds describe-db-instances \
  --db-instance-identifier "escaparate-db-${IDENTIFICADOR}" \
  --query "DBInstances[0].MasterUserSecret.SecretArn" --output text)

export DB_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id "$DB_SECRET_ARN" \
  --query "SecretString" --output text | python3 -c "import sys,json; print(json.load(sys.stdin)['password'])")

export DB_PORT=5432
export DB_NAME=escaparate
export DB_USER=postgres

# Almacenamiento en S3 (nuevo en la Actividad 5.2) y origen autorizado por CORS
export APP_STORAGE_TYPE=s3
export APP_STORAGE_S3_BUCKET="${BUCKET_IMAGENES}"
export APP_CORS_ALLOWED_ORIGINS="${ORIGEN_FRONTEND}"

cd /home/ec2-user
nohup java -jar escaparate.war > escaparate.log 2>&1 &

# --- Agente de CloudWatch (de la Actividad 5.1, se mantiene) ---
dnf install -y amazon-cloudwatch-agent

mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<'EOF'
{
  "agent": { "metrics_collection_interval": 60 },
  "metrics": {
    "namespace": "CWAgent",
    "metrics_collected": {
      "mem": { "measurement": ["mem_used_percent"] },
      "disk": { "measurement": ["used_percent"], "resources": ["/"] }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/home/ec2-user/escaparate.log",
            "log_group_name": "/escaparate/app",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json
