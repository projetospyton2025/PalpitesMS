# PalpiteMS.ps1
# Script para configuração do projeto de Palpites da Mega-Sena

Write-Host "[SETUP] Iniciando configuração do projeto Mega-Sena..." -ForegroundColor Green

# Definir caminhos
$PROJETO_PATH = "J:\Meu Drive\ProjetosPython\Loterias\Estrategias\MegaSena\PalpitesMS"
$TEMP_DIR = "C:\palpites"

# Criar diretório temporário se não existir
if (-not (Test-Path $TEMP_DIR)) {
    New-Item -Path $TEMP_DIR -ItemType Directory -Force
    Write-Host "[SETUP] Diretório temporário criado: $TEMP_DIR" -ForegroundColor Yellow
}

# Criar diretório do projeto se não existir
if (-not (Test-Path $PROJETO_PATH)) {
    New-Item -Path $PROJETO_PATH -ItemType Directory -Force
    Write-Host "[SETUP] Diretório do projeto criado: $PROJETO_PATH" -ForegroundColor Yellow
}

# Criar estrutura de diretórios
$diretorios = @(
    "$PROJETO_PATH\static\css",
    "$PROJETO_PATH\static\js",
    "$PROJETO_PATH\templates",
    "$PROJETO_PATH\config",
    "$PROJETO_PATH\models",
    "$PROJETO_PATH\services"
)

foreach ($dir in $diretorios) {
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force
        Write-Host "[SETUP] Diretório criado: $dir" -ForegroundColor Yellow
    }
}

# Criar arquivo app.py
$appPyContent = @'
from flask import Flask, render_template, request, jsonify
import redis
from config.redis_config import RedisConfig
import requests

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

if __name__ == '__main__':
    app.run(debug=True)
'@

Set-Content -Path "$PROJETO_PATH\app.py" -Value $appPyContent -Encoding UTF8

# Criar arquivo redis_config.py
$redisConfigContent = @'
import os
from dotenv import load_dotenv

load_dotenv()

class RedisConfig:
    REDIS_HOST = os.getenv('REDIS_HOST')
    REDIS_PORT = int(os.getenv('REDIS_PORT'))
    REDIS_PASSWORD = os.getenv('REDIS_PASSWORD')
    REDIS_DB = int(os.getenv('REDIS_DB'))
'@

Set-Content -Path "$PROJETO_PATH\config\redis_config.py" -Value $redisConfigContent -Encoding UTF8

# Criar arquivo .env
$envContent = @'
REDIS_HOST=redis-13833.c336.samerica-east1-1.gce.redns.redis-cloud.com
REDIS_PORT=13833
REDIS_PASSWORD=B058xThhTvAbptQa0s25EAGk7A5u473O
REDIS_DB=0
FLASK_ENV=development
REDIS_URL=redis://default:B058xThhTvAbptQa0s25EAGk7A5u473O@redis-13833.c336.samerica-east1-1.gce.redns.redis-cloud.com:13833
'@

Set-Content -Path "$PROJETO_PATH\.env" -Value $envContent -Encoding UTF8

# Criar arquivo requirements.txt
$requirementsContent = @'
flask==2.0.1
redis==4.5.4
python-dotenv==0.19.0
requests==2.26.0
'@

Set-Content -Path "$PROJETO_PATH\requirements.txt" -Value $requirementsContent -Encoding UTF8

# Criar arquivo .gitignore
$gitignoreContent = @'
venv/
__pycache__/
*.pyc
.env
'@

Set-Content -Path "$PROJETO_PATH\.gitignore" -Value $gitignoreContent -Encoding UTF8

# Criar arquivo index.html
$indexHtmlContent = @'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mega-Sena Palpites</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='css/styles.css') }}">
</head>
<body>
    <div class="container">
        <div class="lottery-card">
            <h1>Mega-Sena</h1>
            <div class="concurso-info" id="concursoInfo">
            </div>
            <div class="numbers" id="sorteadosNumbers">
            </div>
        </div>
        
        <div class="palpites-card">
            <h2>Seus Palpites</h2>
            <div class="palpites-input">
                <div class="jogo">
                    <label>Jogo 1:</label>
                    <input type="text" class="palpite-input" id="jogo1" placeholder="01,02,03,04,05,06">
                </div>
                <div class="jogo" id="jogo2Container" style="display: none;">
                    <label>Jogo 2:</label>
                    <input type="text" class="palpite-input" id="jogo2" placeholder="01,02,03,04,05,06">
                </div>
                <div class="jogo" id="jogo3Container" style="display: none;">
                    <label>Jogo 3:</label>
                    <input type="text" class="palpite-input" id="jogo3" placeholder="01,02,03,04,05,06">
                </div>
            </div>
            <div class="concurso-input">
                <label>Número do Concurso:</label>
                <input type="number" id="concursoNumber" min="1">
                <button onclick="verificarPalpites()">Verificar</button>
            </div>
        </div>
    </div>
    <script src="{{ url_for('static', filename='js/script.js') }}"></script>
</body>
</html>
'@

Set-Content -Path "$PROJETO_PATH\templates\index.html" -Value $indexHtmlContent -Encoding UTF8

# Criar arquivo styles.css
$stylesContent = @'
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 20px;
    background-color: #f0f0f0;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    display: flex;
    gap: 20px;
    flex-wrap: wrap;
}

.lottery-card, .palpites-card {
    background: white;
    border-radius: 10px;
    padding: 20px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    flex: 1;
    min-width: 300px;
}

.numbers {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    margin: 20px 0;
}

.number {
    width: 40px;
    height: 40px;
    background: #00A650;
    color: white;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
}

.palpites-input {
    display: flex;
    flex-direction: column;
    gap: 15px;
}

.jogo {
    display: flex;
    gap: 10px;
    align-items: center;
}

.palpite-input {
    flex: 1;
    padding: 8px;
    border: 1px solid #ccc;
    border-radius: 4px;
}

.matched {
    background: #00A650 !important;
}

.close-higher {
    background: #FFA500 !important;
}

.close-lower {
    background: #FFD700 !important;
}

button {
    background: #00A650;
    color: white;
    border: none;
    padding: 10px 20px;
    border-radius: 4px;
    cursor: pointer;
}

button:hover {
    background: #008540;
}
'@

Set-Content -Path "$PROJETO_PATH\static\css\styles.css" -Value $stylesContent -Encoding UTF8

# Criar arquivo script.js
$scriptJsContent = @'
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('jogo1').addEventListener('input', function() {
        if (this.value.length > 0) {
            document.getElementById('jogo2Container').style.display = 'flex';
        }
    });

    document.getElementById('jogo2').addEventListener('input', function() {
        if (this.value.length > 0) {
            document.getElementById('jogo3Container').style.display = 'flex';
        }
    });
});

function validarJogo(numerosStr) {
    const numeros = numerosStr.split(',').map(n => parseInt(n.trim()));
    
    if (numeros.length !== 6) return false;
    if (!numeros.every(n => n >= 1 && n <= 60)) return false;
    if (new Set(numeros).size !== 6) return false;
    
    return true;
}

function verificarPalpites() {
    const concursoNum = document.getElementById('concursoNumber').value;
    if (!concursoNum) {
        alert('Por favor, insira o número do concurso!');
        return;
    }

    fetch(`/api/concurso/${concursoNum}`)
        .then(response => response.json())
        .then(data => {
            const numerosSorteados = data.dezenas.map(n => parseInt(n));
            
            for (let i = 1; i <= 3; i++) {
                const jogoInput = document.getElementById(`jogo${i}`);
                if (jogoInput.value) {
                    if (!validarJogo(jogoInput.value)) {
                        alert(`Jogo ${i} inválido! Insira 6 números diferentes entre 01 e 60.`);
                        return;
                    }
                    
                    const numerosJogo = jogoInput.value.split(',').map(n => parseInt(n.trim()));
                    verificarAcertos(numerosJogo, numerosSorteados);
                }
            }
        })
        .catch(error => {
            console.error('Erro:', error);
            alert('Erro ao buscar dados do concurso!');
        });
}

function verificarAcertos(palpite, sorteados) {
    palpite.forEach(numero => {
        if (sorteados.includes(numero)) {
            destacarNumero(numero, 'matched');
        } else {
            const diferenca = sorteados.map(s => Math.abs(s - numero));
            const menorDiferenca = Math.min(...diferenca);
            if (menorDiferenca <= 2) {
                const numeroProximo = sorteados[diferenca.indexOf(menorDiferenca)];
                if (numero > numeroProximo) {
                    destacarNumero(numero, 'close-lower');
                } else {
                    destacarNumero(numero, 'close-higher');
                }
            }
        }
    });
}

function destacarNumero(numero, classe) {
    const elementos = document.querySelectorAll('.number');
    elementos.forEach(el => {
        if (parseInt(el.textContent) === numero) {
            el.classList.add(classe);
        }
    });
}
'@

Set-Content -Path "$PROJETO_PATH\static\js\script.js" -Value $scriptJsContent -Encoding UTF8

# Criar ambiente virtual e instalar dependências
Write-Host "[SETUP] Criando ambiente virtual..." -ForegroundColor Yellow
python -m venv "$PROJETO_PATH\venv"

# Ativar ambiente virtual e instalar dependências
Write-Host "[SETUP] Instalando dependências..." -ForegroundColor Yellow
& "$PROJETO_PATH\venv\Scripts\pip" install -r "$PROJETO_PATH\requirements.txt"

Write-Host "[SETUP] Instalação concluída com sucesso!" -ForegroundColor Green
Write-Host "[SETUP] Para iniciar o projeto:" -ForegroundColor Green
Write-Host "1. Navegue até: $PROJETO_PATH" -ForegroundColor Yellow
Write-Host "2. Ative o ambiente virtual: .\venv\Scripts\activate" -ForegroundColor Yellow
Write-Host "3. Execute o projeto: python app.py" -ForegroundColor Yellow

# Limpar diretório temporário
Remove-Item -Path $TEMP_DIR -Recurse -Force
Write-Host "[SETUP] Limpeza concluída" -ForegroundColor Green