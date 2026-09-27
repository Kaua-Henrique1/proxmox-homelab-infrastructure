const express = require('express');
const cors = require('cors');
const { exec } = require('child_process');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', service: 'Homelab Control Center API' });
});

app.post('/api/scripts/run', (req, res) => {
  const { scriptName } = req.body;
  
  if (scriptName !== 'enviar-jogo') {
    return res.status(400).json({ success: false, error: 'Script não autorizado.' });
  }

  exec(`/scripts/${scriptName}.sh`, (error, stdout, stderr) => {
    if (error) return res.status(500).json({ success: false, error: error.message });
    return res.json({ success: true, output: stdout });
  });
});

app.listen(3001, () => {
  console.log('Backend executando na porta 3001');
});
