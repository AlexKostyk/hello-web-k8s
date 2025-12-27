# hello-web-k8s

### 1) Создание структуры проекта
mkdir -p hello-web-k8s/app
mkdir -p hello-web-k8s/k8s
cd hello-web-k8s

### 2) Создание HTML с Hello world
nano app/hello.html

<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Hello</title>
</head>
<body>
  <h1>Hello world</h1>
</body>
</html>

### 3) Создание Dockerfile
nano Dockerfile

FROM python:3.14-alpine

WORKDIR /app

COPY app/ /app/

RUN adduser -D -u 10001 appuser
USER 10001

EXPOSE 8000

CMD ["python", "-m", "http.server", "8000"]

### 4) Сбор Image
docker build -t simple-web:1.0.0 .

### 5) Запуск контейнера
docker run --rm -p 8000:8000 simple-web:1.0.0

### 6) Отправка image на Docker Hub
docker login
docker tag simple-web:1.0.0 alexkostyuk/simple-web:1.0.0
docker push alexkostyuk/simple-web:1.0.0

https://hub.docker.com/r/alexkostyuk/simple-web

### 7) Старт кластера minikube
minikube start --driver=docker

### 8) Создание и установка Kubernetes Deployment manifest
nano k8s/deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: web
          image: alexkostyuk/simple-web:1.0.0
          ports:
            - containerPort: 8000
          livenessProbe:
            httpGet:
              path: /hello.html
              port: 8000
            initialDelaySeconds: 5
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /hello.html
              port: 8000
            initialDelaySeconds: 2
            periodSeconds: 5

kubectl apply -f k8s/deployment.yaml

### 9) Сохранение вывода kubectl describe deployment web
kubectl describe deployment web | tee k8s/describe-deployment-web.txt

### 10) Доступ к приложению с помощью port-forward
kubectl port-forward deployment/web 8080:8000

Проверка доступа из другого терминала и сохранение в curl.txt:
curl -i http://127.0.0.1:8080/hello.html | tee k8s/curl.txt
