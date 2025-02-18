# Caminho do script: J:\Meu Drive\ProjetosPython\Loterias\Estrategias\MegaSena\PalpitesMS\palpitesms.ps1

# Gera um palpite aleatório de 6 dezenas para a Mega-Sena
function Gerar-Palpite {
    $palpite = 1..60 | Get-Random -Count 6 | Sort-Object
    return $palpite -join ", "
}

# Exibir o palpite
Write-Output "Palpite para Mega-Sena: $(Gerar-Palpite)"

# Aguarda entrada do usuário antes de fechar (opcional)
Read-Host "Pressione Enter para sair"
