# fakkkaef

const { spawn } = require('child_process');

const pythonScriptPath = 'path/to/myPythonScript.py';
const inputString = 'Hello world!';

const pythonProcess = spawn('python', [pythonScriptPath, inputString]);

pythonProcess.stdout.on('data', (data) => {
  console.log(`stdout: ${data}`);
});

pythonProcess.stderr.on('data', (data) => {
  console.error(`stderr: ${data}`);
});

pythonProcess.on('close', (code) => {
  console.log(`child process exited with code ${code}`);
});
