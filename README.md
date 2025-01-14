# 🚀☁️👊 SendPortal Docker deployment

Marketing por e-mail autogerenciado de código aberto. Gerencie suas próprias newsletters a uma fração do custo.

```
**Versão do SendPortal: 2.0.0**
Mantenedor: https://mettle.io/
Licença: MIT - https://github.com/mettle/sendportal#MIT-1-ov-file
```

## ✅Requisitos
- Linux
- Docker Engine
- Docker Compose

## 📋Passos para implantação
1. Faça o clone deste repositório
2. Faça um cópia do arquivo [.env.template](.env.template) para outro nomeado como **.env**
3. Edite o arquivo **.env** e forneça as informações adequadas
4. Execute o comando abaixo para implantar:
	```bash
	bash up.sh
	```

	Na primeira execução da implantação será inicializado o banco de dados e a aplicação. Responda as questões solicitadas pelo script da implantação executado no passo 4 acima.

	Os dados criados na aplicação serão mantidos no diretorio ```./volumes``` do host Docker. Caso queria reiniciá-la e remover os seus dados, exclua esse diretório

## 🔗Endpoints
- SendPortal: http://localhost:8000
- MailPit: http://localhost:8025

## 📧Processamento dos e-mails

### Envio
O envio de mensagens é feito pelo comando abaixo. Ele está nesse exemplo de implantação agendadado para execução periódica dentro do container da aplicação a cada 1 minuto:

```bash
docker exec sendportal-app sh -c /usr/local/bin/php /var/www/html/artisan schedule:run
```

🛑*Esse comando não está preparado para permitir o recebimento do código do workspace à ser processado, portanto ao ser executado ele o fará sequencialmente o processamento de todos os processos agendados sequencialmente.*


## 🔬Análise técnica

**DATA DESTA AVALIÇÃO: 14/01/2025**

O [website](https://sendportal.io/) é um arquétipo de aplicação que pode ser utilizado para viabilizar o envio de e-mails em massa em outras aplicações. Foi construído em Laravel e utiliza amplamente os recursos do framework, mesmo que de forma simplificada.

⚠️ O uso em ambiente produtivo requer uma análise mais detalhada da robustez do código e dos processos criados. Considere-o como um acelerador.

### Documentação e versão

A versão atual do SendPortal está tagueada no Github como v3.0.2, porém a documentação do projeto recomenda a versão v2.0.0 e no repositório a última atualização desta versão está indicada no Github como v2.0.5

### Autenticação e Autorização
- Autenticação simples, não possui RBAC
- 🛑 O convite para um novo usuário continua ativo mesmo que ele seja excluído

### Regionalização
- Foram encontrados arquivos em:
	- ./vendor/mettle/sendportal-core/resources/lang/en.json
	- ./vendor/mettle/sendportal-core/node_modules/cacache/locales/en.json
	- ./vendor/mettle/sendportal-core/node_modules/webpack-cli/node_modules/yargs/locales/en.json
	- ./vendor/mettle/sendportal-core/node_modules/webpack-dev-server/node_modules/yargs/locales/en.json
	- ./vendor/mettle/sendportal-core/node_modules/yargs/locales/en.json

- Foram criadas cópias desses arquivos como "pt.json" nos mesmos diretórios e efetuadas alterações mínimas de tradução para avaliação.

-  Foi alterada a designação da lingua no arquivo ```./var/www/html/config/app.php``` para: ```'locale' => 'pt'```

- Foram executados os comandos:
	```bash
	cd /var/www/html

	php artisan config:cache

	php artisan config:clear

	php artisan cache:clear

	php artisan view:clear

	php artisan vendor:publish ---provider=Sendportal\\Base\\SendportalBaseServiceProvider
	```

🛑 *A nova lingua não foi exibida e não foram geradas mensagens de alerta ou erros correspondentes no arquivo ```storage/logs/laravel.log```*

### Multilocatário

A criação de inquilinos é feita por meio de código. Veja o exemplo no diretório ```./app``` deste repositório.

Cada inquilino poderá criar ```workspaces``` através da UI do SendPortal e poderá convidar quantos ```usuários``` quiser. Não há controle para habilitar ou limitar a criação de ```workspaces``` e novos usuários por meio da UI.

### Observações

🛑 Outros aspectos devem ser considerados para uso em ambiente produtivo e em campanhas de envio massivo de mensagens.

🛑 Há [bugs](https://github.com/mettle/sendportal-core/blob/master/src/Listeners/Webhooks/HandleSesWebhook.php) e [pull requests](https://github.com/mettle/sendportal-core/blob/master/src/Listeners/Webhooks/HandleSesWebhook.php) pendentes deste 2021 e a última atualização ocorreu em **08/05/2024**.

A [Meetle](https://mettle.io/), mantenedora da solução, é um empresa de consultores em PHP e Laravel e declara-se especialista em [Laravel](https://laravel.com/). Ela não faz menção ao projeto [SendPortal](https://sendportal.io/) em seu website.

🚀 Há uma iniciativa comercial do [SendPortal](https://sendportal.io/) oferecida pela [LaravelMail](https://laravelmail.com/buy) **baseada no [SendPortal](https://sendportal.io/)** que  disponibiliza atualizações, suporte e garantia. A indícios da solução comercializada na organização da empresa no GitHub: ```https://github.com/laravelcompany```

## 🔍 Outras soluções


Outras opções de código aberto mais robustas incluem:
- [Mautic](http://mautic.org)
- [DittoFeed](https://www.dittofeed.com/)

## 📚Referências
- SendPortal: [website](https://sendportal.io/)
- SendPortal: [github](https://github.com/mettle/sendportal-core)
- SendPortal: [documentação](https://sendportal.io/docs)
- LaravelMail: [website](https://laravelmail.com)
- LaravelMail: [github](https://github.com/laravelcompany)
- Laravel: [website](https://laravel.com/)

## 🛈 Notas finais
_Atenção: As soluções mencionadas são de propriedade intelectual dos seus respectivos mantenedores. É fundamental respeitar e seguir as licenças de uso associadas a cada uma delas._

_Esta implantação não é destinada ao uso em produção e não considera os requisitos essenciais para o processamento de campanhas massivas de e-mail. O objetivo deste projeto é permitir a avaliação funcional do SendPortal._

_Trata-se de uma análise superficial independente. O uso em ambiente produtivo requer uma análise mais detalhada da robustez do código e dos processos criados, bem como a avaliação de outros aspectos técnicos e operacionais. Considere-o como um acelerador._

_Isenção de Responsabilidade: Não nos responsabilizamos por qualquer dano, perda ou problema decorrente do uso das soluções mencionadas. O cumprimento das licenças de uso é de responsabilidade exclusiva dos usuários._

___

Feito com 💙 por [DevVanilla.guru](https://devopsvanilla.guru)