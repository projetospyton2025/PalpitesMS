document.addEventListener('DOMContentLoaded', function() {
    // Carregar último concurso ao iniciar
    carregarUltimoConcurso();

    // Adicionar listeners para cada input de jogo
    ['jogo1', 'jogo2', 'jogo3'].forEach((jogoId, index) => {
        document.getElementById(jogoId).addEventListener('input', function(e) {
            console.log(`Verificando jogo ${index + 1}`);
            const numerosTxt = e.target.value.trim();
            
            if (numerosTxt) {
                // Mostrar próximo container se não for o último jogo
                if (index < 2) {
                    document.getElementById(`jogo${index + 2}Container`).style.display = 'flex';
                }
                
                // Validar e processar números
                const numeros = numerosTxt.split(/[\s,]+/).map(n => parseInt(n.trim())).filter(n => !isNaN(n));
                verificarJogoIndividual(index + 1, numeros);
            }
        });
    });

    // Preencher automaticamente os jogos para teste
    setTimeout(() => {
        document.getElementById('jogo1').value = '13,22,38,46,51,56';
        document.getElementById('jogo2').value = '13,22,38,45,51,56';
        document.getElementById('jogo3').value = '13,22,38,47,51,56';
        
        // Disparar eventos de input para processar os jogos
        ['jogo1', 'jogo2', 'jogo3'].forEach(id => {
            const event = new Event('input');
            document.getElementById(id).dispatchEvent(event);
        });
    }, 1000);
});

async function carregarUltimoConcurso() {
    try {
        const response = await fetch('/api/ultimo-concurso');
        if (!response.ok) throw new Error('Erro ao buscar último concurso');
        
        const data = await response.json();
        console.log('Último concurso carregado:', data.concurso);
        
        document.getElementById('concursoNumber').textContent = data.concurso;
        
        // Exibir números sorteados
        const sorteadosContainer = document.getElementById('sorteadosNumbers');
        sorteadosContainer.innerHTML = '';
        data.dezenas.sort((a, b) => a - b).forEach(numero => {
            const numberDiv = document.createElement('div');
            numberDiv.className = 'number';
            numberDiv.textContent = String(numero).padStart(2, '0');
            sorteadosContainer.appendChild(numberDiv);
        });
    } catch (error) {
        console.error('Erro ao carregar último concurso:', error);
    }
}

async function verificarJogoIndividual(jogoNum, numeros) {
    console.log(`Processando jogo ${jogoNum}:`, numeros);
    if (numeros.length !== 6) return;

    try {
        const response = await fetch('/api/ultimo-concurso');
        if (!response.ok) throw new Error('Erro na requisição');
        
        const data = await response.json();
        const numerosSorteados = data.dezenas.map(n => parseInt(n));
        console.log('Números sorteados:', numerosSorteados);

        // Mostrar e limpar container do jogo
        const jogoContainer = document.querySelector(`#jogo${jogoNum}Display .numbers`);
        jogoContainer.innerHTML = '';
        document.getElementById(`jogo${jogoNum}Display`).style.display = 'block';

        // Processar cada número do jogo
        numeros.forEach(numero => {
            let classe = '';
            
            // Verificar se é um número exato
            if (numerosSorteados.includes(numero)) {
                classe = 'matched';
                console.log(`Número ${numero} é exato`);
            } else {
                // Verificar proximidade apenas se não for um número exato
                const diferenca = numerosSorteados.map(s => Math.abs(s - numero));
                const menorDiferenca = Math.min(...diferenca);
                if (menorDiferenca <= 2) {
                    const numeroProximo = numerosSorteados[diferenca.indexOf(menorDiferenca)];
                    classe = numero > numeroProximo ? 'close-higher' : 'close-lower';
                    console.log(`Número ${numero} está próximo de ${numeroProximo}`);
                }
            }
            
            const numberDiv = document.createElement('div');
            numberDiv.className = `number ${classe}`;
            numberDiv.textContent = String(numero).padStart(2, '0');
            jogoContainer.appendChild(numberDiv);
        });
    } catch (error) {
        console.error(`Erro ao verificar jogo ${jogoNum}:`, error);
    }
}