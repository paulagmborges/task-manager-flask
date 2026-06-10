# [001] - Correção de dependências do Flask Task Manager (Python 3.14)

## Contexto
O projeto não iniciava. Ao rodar `todo_project/run.py` com o venv (Python 3.14):

```
ImportError: cannot import name 'safe_str_cmp' from 'werkzeug.security'
  flask_login/utils.py: from werkzeug.security import safe_str_cmp
```

Causa raiz: `Flask-Login==0.5.0` importa `safe_str_cmp`, removido do Werkzeug >= 2.1. O `requirements.txt` fixava `Flask==2.3.2` (Werkzeug 3.x), criando incompatibilidade. Outras dependências antigas (Flask-SQLAlchemy 2.4.1, WTForms 2.2.1, Flask-WTF 0.14.3, Flask-Bcrypt 0.7.1) também eram incompatíveis com a stack moderna e o Python 3.14.

## Escopo
### Incluído
- Realinhamento de versões em `requirements.txt`
- Reinstalação no venv compartilhado (`venv/bin/pip`)
- Inicialização do schema do banco no boot
- Atualização de API legada do SQLAlchemy no `user_loader`
- Validação subindo o servidor e testando as rotas

### Excluído
- Templates, CSS, lógica de negócio das rotas
- Migração/seed de dados
- Arquivo legado `todo_project/todo_project/site.db` (mantido intacto)

## Solução Implementada

### Arquitetura
Atualização coordenada de toda a stack Flask para versões compatíveis com Werkzeug 3.x e Python 3.14. Como o Flask-SQLAlchemy 3.x exige um application context ativo e não cria tabelas automaticamente, foi adicionado `db.create_all()` dentro de `app.app_context()` no fim do `__init__.py`. O `user_loader` passou a usar `db.session.get(User, id)` em vez do legado `User.query.get()`.

### Versões finais
| Pacote | Antes | Depois |
|--------|-------|--------|
| Flask | 2.3.2 | 3.0.3 |
| Flask-Login | 0.5.0 | 0.6.3 |
| Flask-SQLAlchemy | 2.4.1 | 3.1.1 |
| Flask-WTF | 0.14.3 | 1.2.1 |
| WTForms | 2.2.1 | 3.1.2 |
| Flask-Bcrypt | 0.7.1 | 1.0.1 |
| Werkzeug | 3.1.8 | 3.0.6 |
| Jinja2 | 3.1.6 | 3.1.4 |

### Arquivos Modificados
| Arquivo | Tipo de Mudança |
|---------|-----------------|
| `requirements.txt` | Modificado |
| `todo_project/todo_project/__init__.py` | Modificado |
| `todo_project/todo_project/models.py` | Modificado |

## Testes
Validação via `app.test_client()` (WSGI in-process — o sandbox bloqueia sockets de loopback) e boot real do servidor.

| Rota | Status observado |
|------|------------------|
| GET / | 200 |
| GET /about | 200 |
| GET /login | 200 |
| GET /register | 200 |
| GET /all_tasks | 302 (redirect login) |
| GET /account | 302 (redirect login) |
| GET /logout | 302 |

Boot real (`run.py`): servidor sobe em `http://127.0.0.1:5000`, sem ImportError, processo permanece ativo e `instance/site.db` é criado com as tabelas.

## Verificação de Qualidade
| Critério | Status |
|----------|--------|
| Boot sem ImportError | ✅ |
| Rotas principais respondendo | ✅ |
| Schema do banco criado | ✅ |
| Versões compatíveis entre si | ✅ |
| Mudanças dentro do escopo | ✅ |

---
**Verificado por:** Workflow Orchestrator
**Data:** 2026-06-10
**Status Final:** ✅ APROVADO
