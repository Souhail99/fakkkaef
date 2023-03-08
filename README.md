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


const { exec } = require('child_process');

const input_data = 'my_input_data';
const script_path = '/path/to/your/script.py';

// execute the python script
exec(`python ${script_path} ${input_data}`, (error, stdout, stderr) => {
  if (error) {
    console.error(`error: ${error.message}`);
    return;
  }
  if (stderr) {
    console.error(`stderr: ${stderr}`);
    return;
  }
  console.log(`stdout: ${stdout}`);
});

/////////////

const { spawn } = require('child_process');

// Chemin vers le script Python que vous souhaitez exécuter
const pythonScriptPath = '/chemin/vers/le/script.py';

// Créez un objet ChildProcess en exécutant le script Python
const pythonProcess = spawn('python', [pythonScriptPath]);

// Gérez les événements "stdout" et "stderr" pour récupérer les sorties du script Python
pythonProcess.stdout.on('data', (data) => {
  console.log(`stdout: ${data}`);
});

pythonProcess.stderr.on('data', (data) => {
  console.error(`stderr: ${data}`);
});

// Envoyez des données au script Python en utilisant stdin
pythonProcess.stdin.write('paramètre 1\n');
pythonProcess.stdin.write('paramètre 2\n');

// Appeler une méthode avec un argument à l'intérieur du script Python
const argument = 'mon argument';
pythonProcess.stdin.write(`methode('${argument}')\n`);

// Fermer l'entrée standard (stdin) pour que le script Python sache que nous avons fini d'envoyer des données
pythonProcess.stdin.end();

