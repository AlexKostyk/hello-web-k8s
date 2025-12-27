FROM python:3.14-alpine

WORKDIR /app

COPY app/ /app/

RUN adduser -D -u 10001 appuser
USER 10001

EXPOSE 8000

CMD ["python", "-m", "http.server", "8000"]
