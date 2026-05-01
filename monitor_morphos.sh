#!/bin/bash
# OMEGA SYSTEM - VM Health Sentinel
# Project: MORPHOS | Component: Evolution Engine

# Konfigurasi Vektor
RG="RG-MORPHOS-SOVEREIGN"
VM="VM-MORPHOS-DNA-SYNTH"

echo "------------------------------------------------"
echo "[STATUS] OMEGA SENTINEL: Memulakan Imbasan..."
echo "------------------------------------------------"

# 1. Semakan Status Kuasa (Power State)
STATUS=$(az vm get-instance-view --name $VM --resource-group $RG --query "instanceView.statuses[1].displayStatus" -o tsv 2>/dev/null)

if [ -z "$STATUS" ]; then
    echo "[ALERT] VM Belum Wujud atau Deployment Masih Berjalan."
    exit 1
fi

# 2. Semakan Alamat IP Private (Internal Bridge)
IP=$(az vm list-ip-addresses --name $VM --resource-group $RG --query "[0].virtualMachine.network.privateIpAddresses[0]" -o tsv)

# 3. Paparan Log Diagnostik
echo "VM NAME    : $VM"
echo "POWER STATE: $STATUS"
echo "PRIVATE IP : $IP"
echo "------------------------------------------------"

if [ "$STATUS" == "VM running" ]; then
    echo "[RESULT] OMEGA CORE ONLINE - Ready for DNA Synthesis."
else
    echo "[WARNING] OMEGA CORE OFFLINE - Sila semak Azure Portal."
fi
