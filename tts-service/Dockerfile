FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install minimal build/runtime deps
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       libnss3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
RUN pip install --no-cache-dir \
    fastapi \
    uvicorn[standard] \
    pydantic \
    edge-tts

# Copy app code
COPY main.py /app/main.py

EXPOSE 5000

# Run the FastAPI app on port 5000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]
