 #!/bin/bash

source .env
 
curl -s -o /dev/null -H "Ocp-Apim-Subscription-Key: $apimkey" "https://apim-quackersbankl6ht6vt8.azure-api.net/appinsightstest/delay?delay=10" & \
curl -s -o /dev/null -H "Ocp-Apim-Subscription-Key: $apimkey" "https://apim-quackersbankl6ht6vt8.azure-api.net/appinsightstest/delay?delay=20" & \
curl -s -o /dev/null -H "Ocp-Apim-Subscription-Key: $apimkey" "https://apim-quackersbankl6ht6vt8.azure-api.net/appinsightstest/delay?delay=30" & \
curl -s -o /dev/null -H "Ocp-Apim-Subscription-Key: $apimkey" "https://apim-quackersbankl6ht6vt8.azure-api.net/appinsightstest/delay?delay=40" & \
curl -s -o /dev/null -H "Ocp-Apim-Subscription-Key: $apimkey" "https://apim-quackersbankl6ht6vt8.azure-api.net/appinsightstest/delay?delay=50" & \
curl -s -o /dev/null -H "Ocp-Apim-Subscription-Key: $apimkey" "https://apim-quackersbankl6ht6vt8.azure-api.net/appinsightstest/delay?delay=60" & \
curl -s -o /dev/null -H "Ocp-Apim-Subscription-Key: $apimkey" "https://apim-quackersbankl6ht6vt8.azure-api.net/appinsightstest/delay?delay=70" & \
curl -s -o /dev/null -H "Ocp-Apim-Subscription-Key: $apimkey" "https://apim-quackersbankl6ht6vt8.azure-api.net/appinsightstest/delay?delay=80" & \
curl -s -o /dev/null -H "Ocp-Apim-Subscription-Key: $apimkey" "https://apim-quackersbankl6ht6vt8.azure-api.net/appinsightstest/delay?delay=90" & \
curl -s -o /dev/null -H "Ocp-Apim-Subscription-Key: $apimkey" "https://apim-quackersbankl6ht6vt8.azure-api.net/appinsightstest/delay?delay=180" & \
curl -s -o /dev/null -H "Ocp-Apim-Subscription-Key: $apimkey" "https://apim-quackersbankl6ht6vt8.azure-api.net/appinsightstest/delay?delay=280" & \
curl -vvv -H "Ocp-Apim-Subscription-Key: $apimkey" "https://apim-quackersbankl6ht6vt8.azure-api.net/appinsightstest/delay?delay=1" 