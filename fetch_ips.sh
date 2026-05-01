#!/bin/bash
RG="RG-MORPHOS-SOVEREIGN"

echo "[STATUS] Mencari koordinat IP di Azure..."

# Cuba dapatkan Gateway IP
GATEWAY_IP=$(az network public-ip show -g $RG -n PIP-MORPHOS-GATEWAY --query ipAddress -o tsv 2>/dev/null)

# Cuba dapatkan Confidential VM IP
CONF_IP=$(az vm list-ip-addresses -g $RG -n VM-MORPHOS-DNA-SYNTH --query "[0].virtualMachine.network.privateIpAddresses[0]" -o tsv 2>/dev/null)

if [ -z "$GATEWAY_IP" ] || [ -z "$CONF_IP" ]; then
    echo "[ALERT] Koordinat tidak dijumpai. Pastikan GitHub Actions telah selesai."
else
    echo "------------------------------------------------"
    echo "GATEWAY PUBLIC IP : $GATEWAY_IP"
    echo "ENCLAVE PRIVATE IP: $CONF_IP"
    echo "------------------------------------------------"
    echo "ARAHAN AKSES:"
    echo "ssh -J tsa_architect@$GATEWAY_IP tsa_architect@$CONF_IP"
fi
