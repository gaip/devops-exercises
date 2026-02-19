FROM python:3.12-slim
WORKDIR /app
COPY . /app
RUN pip install flask

EXPOSE 5000

ENV NAMESPACE="default"
ENV ENVIRONMENT="unknown"
ENV DB_HOST="not-set"
ENV DEBUG="false"

CMD ["python", "app.py"]
