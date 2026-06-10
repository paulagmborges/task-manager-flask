# Plano: Corrigir dependências do Flask Task Manager (Python 3.14)

## 🎯 SCOPE

### Arquivos Afetados
- [ ] requirements.txt (raiz) — realinhar versões compatíveis com Werkzeug 3.x / Python 3.14
- [ ] todo_project/todo_project/models.py — possível ajuste de API SQLAlchemy 2.x (User.query.get)
- [ ] venv (reinstalação de pacotes via venv/bin/pip)

### Fora do Escopo
- Templates HTML, CSS, lógica de negócio das rotas
- Migração de banco de dados / dados existentes (site.db)
- Mudança de arquitetura ou novas features

### Riscos de Impacto
- Risco 1: WTForms 2.2.1 incompatível com Flask-WTF moderno (DataRequired/render). Atualizar para WTForms 3.x.
- Risco 2: Flask-Login 0.5.0 importa safe_str_cmp (removido em Werkzeug 2.1+). Atualizar para Flask-Login >= 0.6.3.
- Risco 3: Flask-SQLAlchemy 2.4.1 incompatível com SQLAlchemy 2.x / Flask 2.3. Atualizar para 3.x.
- Risco 4: SQLAlchemy 2.x torna `Model.query.get()` legacy (LegacyAPIWarning) mas ainda funciona; `app_context` necessário para `db.create_all()`.

## 📋 REQUIREMENTS

### Requisitos Funcionais
- [x] RF01: `cd todo_project && ../venv/bin/python run.py` sobe o servidor sem ImportError
- [x] RF02: GET / retorna 200 (página about)
- [x] RF03: GET /login retorna 200
- [x] RF04: Banco site.db é criado/inicializado corretamente

### Requisitos Não-Funcionais
- [ ] RNF01: Versões compatíveis entre si e com Python 3.14
- [ ] RNF02: Sem warnings de erro que quebrem o boot

### Critérios de Aceitação
- [x] CA01: Quando rodar run.py, então servidor inicia e responde
- [x] CA02: Quando GET / e /login, então status 200

### Edge Cases
- EC01: Tabelas inexistentes no primeiro boot (db.create_all dentro de app_context)
- EC02: Flask-Login user_loader usando API legacy do SQLAlchemy

## 🏗️ DESIGN

### Padrões Utilizados
- Pinning de versões compatíveis testadas para Werkzeug 3.x stack
- Mínima alteração de código (somente o necessário para boot)

### Versões Alvo (requirements.txt)
- Flask==3.0.3
- Werkzeug>=3.0 (resolvido pelo Flask)
- Flask-Login==0.6.3
- Flask-SQLAlchemy==3.1.1
- Flask-WTF==1.2.1
- WTForms==3.1.2
- Flask-Bcrypt==1.0.1
- Jinja2 (resolvido pelo Flask)

### Inicialização do DB
- Garantir que tabelas sejam criadas: rodar db.create_all() dentro de app.app_context() (init script ou ajuste mínimo).

## 📝 TASKS

### Fase 1: Dependências
- [x] T1.1: [LOW] Atualizar requirements.txt com versões alvo
- [x] T1.2: [LOW] Reinstalar no venv (venv/bin/pip install -r requirements.txt)

### Fase 2: Ajustes de código
- [x] T2.1: [LOW] Garantir criação das tabelas (db.create_all em app_context) se necessário
- [x] T2.2: [LOW] Ajustar API SQLAlchemy 2.x apenas se quebrar o boot

### Fase 3: Validação
- [x] T3.1: [LOW] Subir servidor e testar GET / e GET /login (esperar 200)
