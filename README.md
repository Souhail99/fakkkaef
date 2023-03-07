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










