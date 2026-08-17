#!/bin/bash
# rompe_red.sh — Actividad 2.2, Parte B
#
# Aplica UNA avería al azar (de tres posibles) sobre tus propios recursos
# de pistas deportivas. No dice cuál — eso es lo que tienes que averiguar.
#
# Localiza tus recursos por la subred pública "pistas-publica-a" (el reparto
# fijo de la Actividad 2.1, igual para todo el grupo) — no depende de cómo
# hayas llamado tú a la instancia.

set -e

SUBNET_ID=$(aws ec2 describe-subnets \
  --filters "Name=tag:Name,Values=pistas-publica-a" \
  --query "Subnets[0].SubnetId" --output text)

if [ "$SUBNET_ID" == "None" ] || [ -z "$SUBNET_ID" ]; then
  echo "No se encuentra ninguna subred llamada pistas-publica-a. Revisa que sigues el reparto de la Actividad 2.1."
  exit 1
fi

INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=subnet-id,Values=$SUBNET_ID" "Name=instance-state-name,Values=running" \
  --query "Reservations[0].Instances[0].InstanceId" --output text)

if [ "$INSTANCE_ID" == "None" ] || [ -z "$INSTANCE_ID" ]; then
  echo "No se encuentra ninguna instancia en marcha en pistas-publica-a. Revisa que la hayas lanzado (Paso 1)."
  exit 1
fi

SG_ID=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" --output text)

RT_ID=$(aws ec2 describe-route-tables \
  --filters "Name=association.subnet-id,Values=$SUBNET_ID" \
  --query "RouteTables[0].RouteTableId" --output text)

NACL_ID=$(aws ec2 describe-network-acls \
  --filters "Name=association.subnet-id,Values=$SUBNET_ID" \
  --query "NetworkAcls[0].NetworkAclId" --output text)

AVERIA=$((RANDOM % 3))

case $AVERIA in
  0)
    aws ec2 delete-route --route-table-id "$RT_ID" --destination-cidr-block 0.0.0.0/0 >/dev/null
    ;;
  1)
    aws ec2 revoke-security-group-ingress --group-id "$SG_ID" \
      --protocol tcp --port 80 --cidr 0.0.0.0/0 >/dev/null
    ;;
  2)
    NACL_JSON=$(cat <<JSON
{"NetworkAclId":"$NACL_ID","RuleNumber":50,"Protocol":"6","RuleAction":"deny","Egress":false,"CidrBlock":"0.0.0.0/0","PortRange":{"From":80,"To":80}}
JSON
)
    aws ec2 create-network-acl-entry --cli-input-json "$NACL_JSON" >/dev/null
    ;;
esac

echo "Avería aplicada sobre tus propios recursos. A partir de aquí, diagnostica tú mismo — no vuelvas a mirar este script hasta que hayas terminado."
