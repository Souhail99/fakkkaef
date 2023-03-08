# fakkkaef

from flask import Flask, request

app = Flask(__name__)

@app.route('/my-method', methods=['POST'])
def my_method():
    input_string = request.get_json()['inputString']
    # Faites quelque chose avec input_string, par exemple écrire dans un fichier
    with open('output.txt', 'w') as f:
        f.write(input_string)
    return {'success': True}


async function callPythonMethod(inputString) {
  const response = await fetch('/api/my-method', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      inputString: inputString
    })
  });
  const data = await response.json();
  if (data.success) {
    console.log('Python method called successfully!');
  } else {
    console.error('Error calling Python method:', data.error);
  }
}




async function callApi() {
  const response = await fetch('/api/my-method', {
    method: 'POST',
    body: JSON.stringify({ input: 'Hello World' }),
    headers: {
      'Content-Type': 'application/json'
    }
  })

  if (response.ok) {
    const result = await response.text()
    console.log('Result:', result) // affiche 'Success' dans la console
  } else {
    console.error('Error')
  }
}

callApi()



////

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

