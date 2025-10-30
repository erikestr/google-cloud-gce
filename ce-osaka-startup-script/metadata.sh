#!/bin/bash

# Get the internal IP address
INTERNAL_IP=$(hostname -I | awk '{print $1}')

# Get the external IP address (if available)
EXTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)

# Get the instance name
INSTANCE_NAME=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name)

# Get the zone
ZONE=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone)

# Return the metadata as JSON in the apache directory
cat <<EOF > /var/www/html/metadata.json
{
    "internalIp": "$INTERNAL_IP",
    "externalIp": "$EXTERNAL_IP",
    "instanceName": "$INSTANCE_NAME",
    "zone": "$ZONE"
}
EOF

# Update package lists
apt update

# Install Apache web server
apt install apache2 -y

# Create a html that consumes the metadata.json in the apache directory and displays the information
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>GCP VM Instance Information</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
        }
        h1 {
            color: #333;
        }
        .metadata {
            background: #fff;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .metadata p {
            font-size: 18px;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <h1>GCP VM Instance Information</h1>
    <div class="metadata">
        <p><strong>Internal IP:</strong> <span id="internal-ip"></span></p>
        <p><strong>External IP:</strong> <span id="external-ip"></span></p>
        <p><strong>Instance Name:</strong> <span id="instance-name"></span></p>
        <p><strong>Zone:</strong> <span id="zone"></span></p>
    </div>
    <script>
        fetch('/metadata.json')
            .then(response => response.json())
            .then(data => {
                document.getElementById('internal-ip').textContent = data.internalIp;
                document.getElementById('external-ip').textContent = data.externalIp;
                document.getElementById('instance-name').textContent = data.instanceName;
                document.getElementById('zone').textContent = data.zone;
            });
    </script>
</body>
</html>
EOF

# Start Apache
systemctl start apache2

# Enable Apache to start on boot
systemctl enable apache2

# Log completion
echo "Startup script with acrylic card completed at $(date)" >> /var/log/startup-script.log
EOF