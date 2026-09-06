#!/bin/bash
# Datos de usuario de la plantilla de lanzamiento de la Actividad 5.1.
# Es el mismo arranque-instancia.sh de la 4.1, con un anadido al final:
# instala y configura el agente de CloudWatch, que recoge memoria y disco
# (EC2 no las reporta por si solo) y envia escaparate.log a CloudWatch Logs.
#
# ANTES DE PEGAR ESTE SCRIPT EN LA PLANTILLA DE LANZAMIENTO, sustituye:
#   EDITA-ID-DE-TU-SISTEMA-EFS       -> el fs-xxxxxxxx del Paso 2 de la 4.1
#   EDITA-TU-IDENTIFICADOR           -> el mismo identificador de siempre
#   EDITA-URL-DE-TU-BUCKET-FRONTEND  -> el origen que ya usaste en CORS en la 3.3

set -e

EFS_ID="EDITA-ID-DE-TU-SISTEMA-EFS"
IDENTIFICADOR="EDITA-TU-IDENTIFICADOR"
ORIGEN_FRONTEND="EDITA-URL-DE-TU-BUCKET-FRONTEND"

# Monta EFS para las imagenes de producto, compartido entre todas las replicas
mkdir -p /mnt/escaparate/uploads
mount -t efs "${EFS_ID}:/" /mnt/escaparate/uploads
echo "${EFS_ID}:/ /mnt/escaparate/uploads efs _netdev,tls 0 0" >> /etc/fstab

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

# Almacenamiento compartido y origen autorizado por CORS
export APP_STORAGE_TYPE=filesystem
export APP_STORAGE_PATH=/mnt/escaparate/uploads
export APP_CORS_ALLOWED_ORIGINS="${ORIGEN_FRONTEND}"

cd /home/ec2-user
nohup java -jar escaparate.war > escaparate.log 2>&1 &

# --- Agente de CloudWatch (nuevo en la Actividad 5.1) ---
# Recoge memoria/disco (EC2 no las reporta por si solo) y centraliza escaparate.log
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
