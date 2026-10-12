# QuantumBuy ML service. The embedding model is downloaded at build time, so the
# container starts without network access.
#   docker build -t quantumbuy-ml -f ml/Dockerfile .      (from the repo root)
#   docker run -p 8080:8080 quantumbuy-ml                 -> docs at http://localhost:8080/docs
FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1 PIP_DISABLE_PIP_VERSION_CHECK=1 \
    QUANTUMBUY_MODEL_DIR=/models
WORKDIR /app
COPY ml/requirements.txt ml/requirements.txt
RUN pip install -r ml/requirements.txt
RUN python -c "from huggingface_hub import hf_hub_download as d; import shutil, os; os.makedirs('/models', exist_ok=True); \
r='sentence-transformers/all-MiniLM-L6-v2'; v='1110a243fdf4706b3f48f1d95db1a4f5529b4d41'; \
shutil.copy(d(r, 'onnx/model.onnx', revision=v), '/models/model.onnx'); shutil.copy(d(r, 'tokenizer.json', revision=v), '/models/tokenizer.json')"
# The service reads the catalogue from the app's Dart source and the photo descriptions.
COPY lib/data/product_catalog.dart lib/data/product_catalog.dart
COPY assets/ai_descriptions.json assets/ai_descriptions.json
COPY ml/quantumbuy_ml ml/quantumbuy_ml
WORKDIR /app/ml
USER nobody
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/health')"
CMD ["uvicorn", "quantumbuy_ml.api:app", "--host", "0.0.0.0", "--port", "8080"]
