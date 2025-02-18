document.addEventListener('DOMContentLoaded', function() {
    // Carregar último concurso ao iniciar
    carregarUltimoConcurso();

    // Eventos de input para cada jogo
    ['jogo1', 'jogo2', 'jogo3'].forEach((jogoId, index) => {
        document.getElementById(jogoId).addEventListener('input', function(e) {
            const numeros = e.target.value.split(/[\s,]+/).map(n => n.trim()).filter(n => n);
            
            if (numeros.length > 0) {
                if (index < 2) { // Se não for o último jogo, mostra o próximo container
                    document.getElementById(`jogo${index + 2}Container`).style.display = 'flex';
                }
                atualizarJogoDisplay(index + 1, numeros);
            }
        });
    });
});

async function carregarUltimoConcurso() {
    try {
        const response = await fetch('/api/ultimo-concurso');
        if (!response.ok) throw new Error('Erro ao buscar último concurso');
        
        const data = await response.json();
        document.querySelector('#concursoNumber').textContent = data.concurso;
        
        // Exibir números sorteados
        const sorteadosContainer = document.getElementById('sorteadosNumbers');
        sorteadosContainer.innerHTML = '';
        data.dezenas.forEach(numero => {
            const numberDiv = document.createElement('div');
            numberDiv.className = 'number';
            numberDiv.textContent = String(numero).padStart(2, '0');
            sorteadosContainer.appendChild(numberDiv);
        });

        // Verificar jogos existentes
        for (let i = 1; i <= 3; i++) {
            const jogoInput = document.getElementById(`jogo${i}`);
            if (jogoInput.value) {
                const numeros = jogoInput.value.split(/[\s,]+/).map(n => n.trim()).filter(n => n);
                if (numeros.length > 0) {
                    atualizarJogoDisplay(i, numeros);
                }
            }
        }
    } catch (error) {
        console.error('Erro:', error);
    }
}

function criarNumeroElemento(numero, classe = '') {
    const div = document.createElement('div');
    div.className = `number ${classe}`;
    div.textContent = String(numero).padStart(2, '0');
    return div;
}

async function atualizarJogoDisplay(jogoNum, numeros) {
    const jogoContainer = document.querySelector(`#jogo${jogoNum}Display .numbers`);
    if (!jogoContainer) return;

    jogoContainer.innerHTML = ''; // Limpa os números anteriores
    document.getElementById(`jogo${jogoNum}Display`).style.display = 'block';

    try {
        const response = await fetch('/api/ultimo-concurso');
        if (!response.ok) throw new Error('Erro na requisição');
        
        const data = await response.json();
        const numerosSorteados = data.dezenas.map(n => parseInt(n));

        // Processa e exibe cada número do jogo
        numeros.forEach(numero => {
            numero = parseInt(numero);
            if (isNaN(numero) || numero < 1 || numero > 60) return;

            let classe = '';
            if (numerosSorteados.includes(numero)) {
                classe = 'matched';
            } else {
                const diferenca = numerosSorteados.map(s => Math.abs(s - numero));
                const menorDiferenca = Math.min(...diferenca);
                if (menorDiferenca <= 2) {
                    const numeroProximo = numerosSorteados[diferenca.indexOf(menorDiferenca)];
                    classe = numero > numeroProximo ? 'close-higher' : 'close-lower';
                }
            }
            
            jogoContainer.appendChild(criarNumeroElemento(numero, classe));
        });
    } catch (error) {
        console.error('Erro:', error);
    }
}