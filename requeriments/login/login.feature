Feature: Login
Como um cliente
Quero poder acessar minha conta e me manter logado
Para que eu possa ver e responder enquetes de forma rápida

Cenário: Credencias Válidas
Dado que o cliente informou credenciais Válidas
Quando solicitar para fazer login
Então o sistema deve enviar o usuário para a tela de pesquisas

Cenário: Credenciais Inválidas
Dado que o cliente informou credenciais inválidas
Quando solicitar para fazer login
Então o sistema deve retornar uma mensagem de erro
