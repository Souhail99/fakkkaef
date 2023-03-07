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







