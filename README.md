# LONG NIGHT — One Page V5

Site público em uma página, formulário de compra sem cadastro, painel administrativo e portaria. HTML/CSS/JavaScript + Node.js 22.13+ + SQLite nativo. Nenhuma dependência npm externa; não usa Next.js nem Bootstrap. O servidor é necessário para o funcionamento real. A prévia offline é apenas visual.

## 1. Executar no Windows
1. Extraia todo o ZIP em uma pasta.
2. Com Node.js 22.13 ou superior instalado, execute `iniciar-windows.bat` (não é preciso rodar npm install).
3. Aguarde a mensagem de servidor iniciado. Abra http://localhost:3000 no navegador. Mantenha o terminal aberto.
Alternativa: abra o CMD na pasta do projeto (onde está package.json) e execute `npm start`.
Linux: `bash iniciar-linux.sh`.

## 2. Testar o fluxo
- Site: http://localhost:3000. Os eventos iniciais são fictícios, o pagamento é simulado e o banco fica em data/demo.
- Admin: http://localhost:3000/admin. Login `admin@longnight.local`, senha `LongNight2026!`.
- Portaria: http://localhost:3000/portaria. Login `portaria@longnight.local`, senha `Portaria2026!`.
- Comprador: escolha uma festa, clique Comprar ingresso, informe nome/e-mail, escolha quantidade e aceite os termos. Crie pedido de teste e simule pagamento aprovado. Abra QR Code ou salve PDF pelo navegador. Guarde o link privado, que também pode ser copiado na página do pedido.
- Administração: Eventos → Novo evento. Preencha nome, data de início/término, local, cidade, endereço, descrição, classificação, flyer (JPG/PNG/WebP até 3 MB), preço e capacidade. Publique. O evento aparece na homepage. Lotes são sequenciais; desative um lote para interromper vendas. Eventos com pedidos não podem ser simplesmente apagados. Cancelar exige tratar reembolsos.
- Portaria: selecione a festa e escaneie o QR Code (requer HTTPS em celulares e suporte à BarcodeDetector). Alternativamente digite o código ou busque nome/e-mail/pedido e confirme a identidade antes da entrada. Cada ingresso só pode ser usado uma vez. Câmera não homologada em iPhone; a busca manual funciona sem leitura óptica.
- No modo demo não há envio de e-mail. O link privado permite abrir o ingresso em outro aparelho; não compartilhe. A lista Meus ingressos mostra pedidos desta sessão do navegador, não é conta de cliente. Em produção o link também vai ao e-mail do comprador.

## 3. Integração Mercado Pago (configuração inicial pelo proprietário)
A implementação existente usa Checkout Pro por Preferências. O site cria a preferência em `POST /checkout/preferences` com preço calculado no backend, referência única, validade, URL de retorno e webhook. O cliente paga no ambiente do Mercado Pago. O webhook assinado é validado e o servidor consulta `GET /v1/payments/{id}` antes de emitir ingressos. A aprovação é idempotente. Pagamento atrasado com estoque insuficiente vai para revisão manual; não emite ingresso. A equipe deve tratar pagamentos duplicados, contestações e reembolsos no painel do provedor. Não basta abrir o link de retorno para confirmar a compra.

1. O dono acessa https://www.mercadopago.com.br/developers/panel na conta que receberá os valores, cria aplicação Checkout Pro por Preferências e disponibiliza credenciais de forma segura. Nunca envie senha ou token por chat ou GitHub.
2. Hospede o servidor Node em uma VPS ou plataforma com disco persistente e domínio HTTPS. Configure proxy HTTPS para localhost:3000. Configure BASE_URL para o domínio real, sem barra final; mantenha HOST=127.0.0.1 atrás do proxy. O GitHub armazena código; GitHub Pages não executa esse backend.
3. Copie `.env.example` para `.env` e configure no servidor: `PAYMENT_MODE=mercadopago`, `BASE_URL=https://seu-dominio`, `MP_ACCESS_TOKEN`, `MP_WEBHOOK_SECRET`, novas senhas admin/portaria com pelo menos 12 caracteres, `RESEND_API_KEY`, `EMAIL_FROM`. Configure e verifique o domínio de envio no Resend (https://resend.com). Os ingressos são enviados como links privados por e-mail, não como anexos. As notificações repetidas permitem nova tentativa de envio se a anterior falhar; monitore os logs. O modo real exige a configuração de e-mail.
4. Configure o webhook de Pagamentos da aplicação para `https://seu-dominio/api/webhooks/mercadopago`, com assinatura secreta correspondente. Documentação: https://www.mercadopago.com.br/developers/pt/docs/checkout-pro-preferences/payment-notifications e https://www.mercadopago.com.br/developers/pt/docs/checkout-pro-preferences/create-payment-preference .
5. Homologue com credenciais e usuários de teste em ambiente separado; use DATA_DIR independente para cada ambiente. A API simulada no teste automatizado não substitui o teste oficial. Teste Pix/cartão, pagamento pendente, cancelamento, reembolso, retorno, webhook, estoque, e-mail e portaria. Só depois utilize as credenciais reais. Não se pressupõe que o modo mercadopago seja seguro para publicar sem revisão.

## 4. Design e conteúdo
Logo SVG reconstruída da V4, paleta preta, dourada e branca. Eventos demo usam arte vetorial (não fotos de baixa resolução). A homepage usa fotografias ilustrativas do Unsplash por URLs de alta resolução. O ambiente de desenvolvimento bloqueou download e verificação dessas fotos; elas dependem da internet e têm fundos alternativos caso falhem. Antes de publicar, substitua pelas fotos oficiais em alta resolução, hospedadas localmente com autorização de uso. Galeria não é apresentada como registro de festas reais. Termos e privacidade são textos preliminares: insira dados do responsável, política aplicável, atendimento e revise LGPD/CDC antes de operar comercialmente.

## 5. Segurança e operação
- Não publique `.env`, data/, chaves de sessão, backups ou uploads com dados de clientes. O .gitignore já cobre os diretórios privados.
- Faça backup consistente do SQLite (incluindo o WAL quando aplicável), uploads e `.guest-key`; a chave é necessária para manter os links privados válidos. Proteja o backup.
- Não reutilize as senhas de demonstração. Alterações de senha após a criação do banco devem ser feitas pelo painel administrativo.
- Use uma instância do Node com armazenamento persistente; configure proxy e monitoramento. A limitação de requisições usa IP de conexão e deve ser ajustada para proxy e volume comercial; não é uma auditoria de segurança completa. Não registre links privados nem QR Codes em sistemas de analytics.
- O site conserva APIs administrativas e transacionais da V4, mas não usa o Next.js. As antigas rotas públicas apontam para as seções correspondentes. Não foi feita migração do banco da V4 existente: teste com cópia antes de importar dados reais.

## 6. Testes
`npm test` executa testes do backend. Verifica eventos, autenticação, permissões, compra, estoque, cupons legados, pagamento simulado, webhook assinado com API mock, QR Code, busca e check-in único, reembolso, contestação e acesso privado ao ingresso. O navegador do ambiente bloqueou a conexão com o servidor local. Prévia visual testada separadamente; homologação de ponta a ponta com navegador e Mercado Pago reais ainda necessária.
