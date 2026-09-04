#!/bin/bash
# Recrea el balanceador de carga y el grupo de destino de la Actividad 4.1
# tal como quedaron configurados en sus Pasos 3-4, tras haberlos borrado en
# el Cierre de la Actividad 4.2 para no pagar el balanceador mientras no se usa.
#
# Requisitos antes de ejecutarlo:
#   - El grupo de seguridad escaparate-alb-sg-<tu-identificador> de la 4.1 sigue existiendo
#     (no se borra en ningún Cierre, solo el balanceador y el grupo de destino).
#   - El grupo de Auto Scaling escaparate-asg-<tu-identificador> sigue existiendo
#     (aunque esté a capacidad 0), con su plantilla de lanzamiento.
#   - La RDS está arrancada (Disponible) antes de subir la capacidad del ASG,
#     o las instancias nuevas no arrancarán Escaparate correctamente.
#
# Sustituye los tres marcadores de abajo por tus valores reales antes de ejecutar.

set -e

IDENTIFICADOR="<tu-identificador>"
VPC_ID="<vpc_id-de-terraform>"
SUBNET_PUBLICA_A="<subnet_publica_a_id>"
SUBNET_PUBLICA_B="<subnet_publica_b_id>"

TG_NAME="escaparate-tg-${IDENTIFICADOR}"
ALB_NAME="escaparate-alb-${IDENTIFICADOR}"
ALB_SG_NAME="escaparate-alb-sg-${IDENTIFICADOR}"
ASG_NAME="escaparate-asg-${IDENTIFICADOR}"

echo "Buscando el grupo de seguridad del balanceador ($ALB_SG_NAME)..."
ALB_SG_ID=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=${ALB_SG_NAME}" \
  --query "SecurityGroups[0].GroupId" --output text)

if [ "$ALB_SG_ID" == "None" ] || [ -z "$ALB_SG_ID" ]; then
  echo "ERROR: no se ha encontrado el grupo de seguridad $ALB_SG_NAME."
  echo "Si has destruido también la red de Terraform, revisa antes el Paso 3 de la 4.1."
  exit 1
fi
echo "Encontrado: $ALB_SG_ID"

echo "Creando el grupo de destino..."
TG_ARN=$(aws elbv2 create-target-group \
  --name "$TG_NAME" \
  --protocol HTTP --port 8080 \
  --vpc-id "$VPC_ID" \
  --target-type instance \
  --health-check-protocol HTTP \
  --health-check-path /api/salud/listo \
  --matcher HttpCode=200 \
  --query "TargetGroups[0].TargetGroupArn" --output text)
echo "Grupo de destino creado: $TG_ARN"

echo "Creando el balanceador..."
ALB_ARN=$(aws elbv2 create-load-balancer \
  --name "$ALB_NAME" \
  --type application \
  --scheme internet-facing \
  --ip-address-type ipv4 \
  --subnets "$SUBNET_PUBLICA_A" "$SUBNET_PUBLICA_B" \
  --security-groups "$ALB_SG_ID" \
  --query "LoadBalancers[0].LoadBalancerArn" --output text)
echo "Balanceador creado: $ALB_ARN"

echo "Esperando a que el balanceador esté activo..."
aws elbv2 wait load-balancer-available --load-balancer-arns "$ALB_ARN"

echo "Creando el listener HTTP:80 -> grupo de destino..."
aws elbv2 create-listener \
  --load-balancer-arn "$ALB_ARN" \
  --protocol HTTP --port 80 \
  --default-actions Type=forward,TargetGroupArn="$TG_ARN" > /dev/null

echo "Enganchando el grupo de Auto Scaling ($ASG_NAME) al nuevo grupo de destino..."
aws autoscaling attach-load-balancer-target-groups \
  --auto-scaling-group-name "$ASG_NAME" \
  --target-group-arns "$TG_ARN"

DNS_NAME=$(aws elbv2 describe-load-balancers \
  --load-balancer-arns "$ALB_ARN" \
  --query "LoadBalancers[0].DNSName" --output text)

echo ""
echo "=== Balanceador recreado ==="
echo "DNS name nuevo: $DNS_NAME"
echo ""
echo "IMPORTANTE: este DNS es NUEVO, distinto al que tenías antes de cerrar la 4.2."
echo "Antes de seguir, actualiza:"
echo "  1. apiBase en config.js, en tu bucket de frontend (mismo paso que el Paso 8 de la 4.1)."
echo "  2. El registro Alias de tu zona Route 53, si sigues usando la de la 4.2."
echo ""
echo "Recuerda subir la capacidad del ASG (mínima 2, deseada 2) si la tenías a 0,"
echo "y esperar a que las instancias aparezcan healthy en el grupo de destino nuevo."
