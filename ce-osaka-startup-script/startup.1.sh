#!/bin/bash

# Update package lists
apt update

# Install Apache web server
apt install apache2 -y

# Get the internal IP address
INTERNAL_IP=$(hostname -I | awk '{print $1}')

# Get the external IP address (if available)
EXTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)

# Get the instance name
INSTANCE_NAME=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name)

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>

<head>
    <title>GCP VM Instance Information</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- The style is a gradient background and the information is in a card that
     has blur style to show acrylic style -->
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            /* dark background with spheres in green color difuminated */
            background: linear-gradient(135deg, #0f2027, #203a43);
            height: 100vh;
            display: flex;
            flex-direction: column;
        }

        header {
            text-align: center;
            padding: 2rem;
            color: white;
        }

        .container {
            display: flex;
            justify-content: center;
            align-items: center;
            height: calc(100vh - 100px);
        }

        .info {
            background: rgba(255, 255, 255, 0.2);
            border-radius: 15px;
            padding: 2rem;
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.18);
            color: white;
        }

        h2 {
            margin-top: 0;
        }

        p {
            font-size: 1.2rem;
        }
    </style>
</head>

<body>
    <header>
        <h1>GCP VM Instance Information</h1>
    </header>
    <div id="metadata">
        <p>Loading metadata...</p>
    </div>
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