#!/bin/bash

# Update package lists
apt update

# Install Apache web server
apt install apache2 -y

# Create an enhanced HTML page with acrylic card design
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>

<head>
    <title>GCP VM Instance Information</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
    <div class="container">
        <div class="info">
            <h2>Instance Details</h2>
            <p><strong>Instance Name:</strong> <span id="instance-name">Loading...</span></p>
            <p><strong>Zone:</strong> <span id="zone">Loading...</span></p>
            <p><strong>Machine Type:</strong> <span id="machine-type">Loading...</span></p>
            <p><strong>Internal IP:</strong> <span id="internal-ip">Loading...</span></p>
            <p><strong>External IP:</strong> <span id="external-ip">Loading...</span></p>
        </div>
    </div>
    <script>
        async function fetchInstanceMetadata() {
            const metadataBaseUrl = 'http://metadata.google.internal/computeMetadata/v1/instance/';
            const headers = { 'Metadata-Flavor': 'Google' };
            const instanceName = await fetch(metadataBaseUrl + 'name', { headers })
                .then(res =>
                    res.text()
                );
            const zone = await fetch(metadataBaseUrl + 'zone', { headers })
                .then(res =>
                    res.text().then(text => text.split('/').pop())
                );
            const machineType = await fetch(metadataBaseUrl + 'machine-type', { headers })
                .then(res =>
                    res.text().then(text => text.split('/').pop())
                );
            const internalIp = await fetch(metadataBaseUrl + 'network-interfaces/0/ip', { headers })
                .then(res =>
                    res.text()
                );
            const externalIp = await fetch(metadataBaseUrl + 'network-interfaces/0/access-configs/0/external-ip', { headers })
                .then(res =>
                    res.text()
                );

            document.getElementById('instance-name').textContent = instanceName;
            document.getElementById('zone').textContent = zone;
            document.getElementById('machine-type').textContent = machineType;
            document.getElementById('internal-ip').textContent = internalIp;
            document.getElementById('external-ip').textContent = externalIp;
        }

        fetchInstanceMetadata();
    </script>
</body>

</html>
EOF

# Start Apache
systemctl start apache2
systemctl enable apache2

# Log completion
echo "Startup script with acrylic card completed at $(date)" >> /var/log/startup-script.log
EOF