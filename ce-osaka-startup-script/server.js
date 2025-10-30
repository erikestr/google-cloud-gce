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