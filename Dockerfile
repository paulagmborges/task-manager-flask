FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

# Ajuste conforme o arquivo que realmente inicia sua aplicação
CMD ["python", "todo_project/run.py"]