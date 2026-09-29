FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip instsall --no-cache-dir -r requirements.txt

COPY . . 

EXPOSE 5000

CMD ["python","app.py"]

