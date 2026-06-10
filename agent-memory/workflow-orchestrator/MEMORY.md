# Agent Memory — workflow-orchestrator

## Padrões do Projeto
- Projeto Flask "Task-Manager-using-Flask". App em `todo_project/todo_project/` (factory implícito em `__init__.py`), entrypoint `todo_project/run.py`.
- Banco: SQLite `instance/site.db` (Flask-SQLAlchemy 3.x grava em `instance/` por padrão).
- venv compartilhado em `./venv` (raiz do repo, Python 3.14.2). Worktrees usam esse mesmo venv via caminho absoluto `venv/bin/python`.
- Código sem comentários (padrão self-documenting respeitado).

## Decisões Arquiteturais
- Stack alvo para Python 3.14 / Werkzeug 3.x: Flask 3.0.3, Flask-Login 0.6.3, Flask-SQLAlchemy 3.1.1, Flask-WTF 1.2.1, WTForms 3.1.2, Flask-Bcrypt 1.0.1, Werkzeug 3.0.6, Jinja2 3.1.4.
- `db.create_all()` é chamado dentro de `with app.app_context()` no fim do `__init__.py` (após import de routes e models) — Flask-SQLAlchemy 3.x exige app_context.
- `user_loader` usa `db.session.get(User, id)` em vez do legado `User.query.get()`.

## Erros Recorrentes & Soluções
- `ImportError: cannot import name 'safe_str_cmp'`: causado por Flask-Login < 0.6 com Werkzeug >= 2.1. Solução: Flask-Login >= 0.6.3.
- Flask-SQLAlchemy 2.x e WTForms 2.x são incompatíveis com a stack moderna; sempre atualizar em conjunto.

## Aprendizados de QA
- Validar rotas via `app.test_client()` em vez de curl no loopback: o sandbox bloqueia conexões TCP locais (retorna 403 em todas). O test client (WSGI in-process) reflete o comportamento real.
- Validação observada: `/`,`/about`,`/login`,`/register` -> 200; `/all_tasks`,`/account`,`/logout` -> 302 (redirect login). Server real sobe sem erro e cria `instance/site.db`.

## Dependências & Integrações
- Flask-Login, Flask-SQLAlchemy, Flask-WTF, Flask-Bcrypt — todos sensíveis à versão do Werkzeug.

## Observações
- FASE 0 worktree obrigatória: trabalho feito em `.worktrees/fix-flask-dependencies` (branch `fix-flask-dependencies`). Havia mudança não commitada em `requirements.txt` no master (stash `wip-requirements`).
- A Agent tool NÃO está disponível dentro de sub-agentes; quando rodando como sub-agente, executar diretamente com as tools disponíveis.
