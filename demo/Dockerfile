FROM python:3.12-slim
COPY demo/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt
WORKDIR /workspace
ENTRYPOINT ["dbt"]
