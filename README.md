# dudev7toftp

```markdown
# 🔄 Backup Automático do The Dude v7

Script RouterOS nativo para backup automático do banco de dados do **Dude** (Network Management System da MikroTik) com rotação automática de backups e suporte opcional a envio FTP.

---

## 📋 Características

✅ **Backup automático** do banco de dados do Dude  
✅ **Nomeação inteligente** com data/hora (formato: `DD-MM-YYYY_HHMM`)  
✅ **Compatível com múltiplos formatos de data** (ISO e abreviado)  
✅ **Rotação automática** - mantém apenas os N backups mais recentes  
✅ **Envio FTP opcional** para armazenamento remoto  
✅ **Log detalhado** de todas as operações  
✅ **Suporte a agendamento** via Scheduler do RouterOS  

---

## 🚀 Início Rápido

### 1️⃣ Acesse o RouterOS via WinBox

- Conecte-se ao seu servidor **MikroTik RouterOS v7.x**

### 2️⃣ Crie um novo Script

Navegue até: **System → Scripts**

- Clique no botão **+ (novo)**
- **Name:** `backup-dude`
- **Policy:** marque `read`, `write`, `policy`

### 3️⃣ Cole o Código

Copie todo o conteúdo do arquivo `backup-dude.rsc` e cole na aba **Script**

### 4️⃣ Configure os Parâmetros (opcional)

No início do script, personalize se necessário:

```routeros
:local retention 30          ;# quantos backups manter (mude conforme necessário)
:local ftpUpload false       ;# mude para true se quiser enviar ao FTP
:local ftpServer "192.0.2.10"
:local ftpUser "ftpuser"
:local ftpPass "ftppass"
:local ftpPath "/"
```

### 5️⃣ Teste Manualmente

- Clique em **Run Script** (ou pressione `Ctrl+R`)
- Verifique o **Log** para confirmar sucesso
- Os arquivos aparecem em **Files** (ex: `dude_backup_04-11-2025_1038.backup`)

### 6️⃣ Agende a Execução Automática

Navegue até: **System → Scheduler**

- Clique no botão **+ (novo)**
- **Name:** `runDudeBackup`
- **Start Time:** `02:00:00` (ou horário de sua preferência)
- **Interval:** `1d` (diariamente) ou `00:30:00` (a cada 30 minutos)
- **On Event:** `/system script run backup-dude`

Salve e pronto! ✅

---

## 📁 Estrutura de Arquivos

```
backup-dude-routeros/
├── README.md                 # Este arquivo
├── backup-dude.rsc          # Script RouterOS v7
└── CHANGELOG.md             # Histórico de versões
```

---

## ⚙️ Configuração Detalhada

### Parâmetros do Script

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `retention` | número | 30 | Quantos backups manter localmente antes de remover os antigos |
| `prefix` | texto | `dude_backup_` | Prefixo do nome de arquivo de backup |
| `ftpUpload` | booleano | `false` | Se `true`, envia backup ao servidor FTP |
| `ftpServer` | IP/Host | `192.0.2.10` | Endereço do servidor FTP |
| `ftpUser` | texto | `ftpuser` | Usuário FTP |
| `ftpPass` | texto | `ftppass` | Senha FTP |
| `ftpPath` | caminho | `/` | Pasta destino no servidor FTP |

### Exemplo: Envio ao FTP

Se deseja enviar os backups para um servidor FTP remoto:

```routeros
:local ftpUpload true
:local ftpServer "backup.exemplo.com"
:local ftpUser "seu_usuario"
:local ftpPass "sua_senha"
:local ftpPath "/backups/dude/"
```

### Exemplo: Manter Apenas 7 Dias

Para manter apenas 7 backups (útil se rodar diariamente):

```routeros
:local retention 7
```

---

## 📊 Formato do Nome de Arquivo

Os arquivos de backup são nomeados com a seguinte convenção:

```
dude_backup_DD-MM-YYYY_HHMM.backup
```

**Exemplos:**
- `dude_backup_04-11-2025_1038.backup` (4 de novembro de 2025 às 10:38)
- `dude_backup_15-03-2025_0200.backup` (15 de março de 2025 às 02:00)

Esse padrão permite:
- ✅ Identificar facilmente a data/hora do backup
- ✅ Ordenação cronológica automática
- ✅ Compatibilidade com ferramentas de backup

---

## 📝 Log de Execução

O script gera mensagens informativas que você pode visualizar em **System → Logs**:

```
[DudeBackup] Gerando backup: dude_backup_04-11-2025_1038
[DudeBackup] Banco de dados do Dude exportado.
[DudeBackup] Verificando backups antigos para remover (retendo os 30 mais recentes)...
[DudeBackup] Finalizado com sucesso
```

**Cores no Log:**
- 🔵 **info** - Operações normais
- 🟡 **warning** - Backups antigos sendo removidos
- 🔴 **error** - Falhas na execução

---

## 🔍 Troubleshooting

### ❌ "Script executou, mas não gerou arquivo"

**Solução:**
1. Verifique se o Dude está rodando: `/dude check-health`
2. Confirme permissões: Script Policy deve incluir `write`
3. Verifique logs: **System → Logs**

### ❌ "Erro ao enviar FTP"

**Solução:**
1. Teste conectividade: `ping <seu_ftpServer>`
2. Confirme credenciais FTP (usuário/senha)
3. Verifique se o caminho FTP existe

### ❌ "Backups não estão sendo removidos"

**Solução:**
1. Defina `retention` com um valor menor (ex: 5)
2. Aguarde até ter mais backups que o limite
3. Execute manualmente o script

---

## 🔐 Segurança

⚠️ **Recomendações Importantes:**

1. **Credenciais FTP:** Não commite senhas no repositório. Use variáveis de ambiente em produção.
2. **Permissões do Script:** Defina policy mínima necessária (`read`, `write`, `policy`)
3. **Local dos Backups:** Mantenha backups em local seguro e com backup redundante
4. **Acesso ao RouterOS:** Use SSH/WinBox apenas de IPs confiáveis

---

## 🐛 Compatibilidade

| Sistema | Versão | Status |
|---------|--------|--------|
| RouterOS | v7.x | ✅ Testado |
| RouterOS | v6.x | ❌ Não suportado |
| Dude | v7.x | ✅ Testado |
| Dude | v6.x | ⚠️ Não testado |

---

## 📚 Referências Úteis

- [Documentação MikroTik Dude](https://help.mikrotik.com/docs/display/ROS/Dude)
- [Documentação RouterOS v7](https://help.mikrotik.com/docs/display/ROS/RouterOS)
- [Scripting RouterOS](https://help.mikrotik.com/docs/display/ROS/Scripting)

---

## 🤝 Contribuições

Sugestões e melhorias são bem-vindas! 

Para reportar bugs ou sugerir features:
1. Abra uma **Issue** descrevendo o problema
2. Inclua sua versão do RouterOS e do Dude
3. Anexe o log relevante (se possível)

---

## 📄 Licença

Este script é fornecido como está, sem garantias. Use por sua conta e risco.

---

## 📞 Suporte

Dúvidas ou problemas?

- 💬 **GitHub Issues:** [Abrir issue](https://github.com/jocaplanaltonet/dudev7toftp/issues)
- 🔗 **Comunidade MikroTik:** [Forum MikroTik](https://forum.mikrotik.com)

---

## 📋 Changelog

### v8 (Atual)
- ✅ Suporte para múltiplos formatos de data (ISO e abreviado)
- ✅ Formato de nome DD-MM-YYYY
- ✅ Chaves e sintaxe validadas
- ✅ Suporte a envio FTP

### v7
- 🔧 Correções de parsing de data

### v6
- 🔄 Primeira versão estável com rotação de backups

---

**Última atualização:** Novembro de 2025  
**Versão do Script:** v8
```

---
