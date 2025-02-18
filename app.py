from flask import Flask, render_template, request, jsonify
import redis
from config.redis_config import RedisConfig
import requests
import os

app = Flask(__name__)

# Redis Configuration
redis_config = RedisConfig()
redis_client = redis.Redis(
    host=redis_config.REDIS_HOST,
    port=redis_config.REDIS_PORT,
    password=redis_config.REDIS_PASSWORD,
    db=redis_config.REDIS_DB
)

API_BASE_URL = "https://loteriascaixa-api.herokuapp.com/api"

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/concurso/<numero>', methods=['GET'])
def get_concurso(numero):
    try:
        response = requests.get(f"{API_BASE_URL}/megasena/{numero}")
        return jsonify(response.json())
    except Exception as e:
        return jsonify({"error": str(e)}), 500
        
        
        
 # Primeiro, vamos adicionar uma nova rota no app.py para buscar o último concurso
@app.route('/api/ultimo-concurso', methods=['GET'])
def get_ultimo_concurso():
    try:
        response = requests.get(f"{API_BASE_URL}/megasena/latest")
        return jsonify(response.json())
    except Exception as e:
        return jsonify({"error": str(e)}), 500       


if __name__ == '__main__':
    port = int(os.environ.get("PORT", 10000))
    app.run(host="0.0.0.0", port=port)
    
"""    
if __name__ == '__main__':
    app.run(debug=True)
"""