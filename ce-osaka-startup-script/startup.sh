#!/bin/bash

# Update package lists
apt update

# Install nvm and Node.js
apt install curl -y

# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# add to .bashrc to persist between sessions
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm' >> ~/.bashrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion' >> ~/.bashrc

# Reload bashrc
source ~/.bashrc

# Download and install Node.js v24.11.0:
nvm install 24.11.0

# Use Node.js v24.11.0:
nvm use 24.11.0

# Install express
npm install express

# Create a folder to host the server files in /var/
mkdir -p /var/server

# Create server javaScript file in var/server/server.js
cat <<EOF > /var/server/server.js
const express = require('express');
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

const app = express();

app.get('/', (req, res) => {
    res.sendFile(__dirname + '/index.html');
});

app.get('/api/metadata', async (req, res) => {
    try {
        // Using hostname -i command
        const { stdout: hostnameIp } = await execPromise('hostname -i');
        
        // Fetch from GCP metadata server
        const { stdout: instanceName } = await execPromise(
            'curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name'
        );
        
        const { stdout: zone } = await execPromise(
            'curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone'
        );
        
        const { stdout: internalIp } = await execPromise(
            'curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip'
        );
        
        const { stdout: externalIp } = await execPromise(
            'curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip'
        ).catch(() => ({ stdout: 'No external IP' }));

        res.json({
            hostnameIp: hostnameIp.trim(),
            instanceName: instanceName.trim(),
            zone: zone.trim().split('/').pop(),
            internalIp: internalIp.trim(),
            externalIp: externalIp.trim()
        });
    } catch (error) {
        res.status(500).json({ error: 'Failed to get metadata' });
    }
});

app.listen(3000, () => console.log('Server running on port 3000'));
EOF

# Adjust permissions
chmod +x /var/server/server.js

CURRENT_USER=$(whoami)
NODE_PATH=$(which node)
NVM_DIR="$HOME/.nvm"

# Create the service file
# ExecStart=/home/erikestrada37/.nvm/versions/node/v24.11.0/bin/node /var/server/server.js
cat > node-metadata.service << EOF
[Unit]
Description=Node.js Metadata Server
After=network.target

[Service]
Type=simple
User=erikestrada37
WorkingDirectory=/home/erikestrada37/server
ExecStart=/home/erikestrada37/.nvm/versions/node/v24.11.0/bin/node /home/erikestrada37/server/server.js
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=node-metadata-server

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload

# Enable (start on boot)
sudo systemctl enable node-metadata.service

# Start now
sudo systemctl start node-metadata.service

# Install Apache web server
apt install apache2 -y

# Create an simple HTML no style and no script
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>GCP VM Instance Information</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <h1>GCP VM Instance Information</h1>
    <div id="metadata">
        <p>Loading metadata...</p>
    </div>
</body>
</html>
EOF

# Reload systemd
sudo systemctl daemon-reload

# Enable (start on boot) apache2
sudo systemctl enable apache2

# Start Apache service
sudo systemctl start apache2

# Log completion
echo "Startup script with acrylic card completed at $(date)" >> /var/log/startup-script.log
EOF