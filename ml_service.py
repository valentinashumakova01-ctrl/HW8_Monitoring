# ML-сервис рекомендаций с Prometheus-метриками
# Имитирует работу рекомендательной системы
import time
import random
import os
from flask import Flask, request, jsonify
from prometheus_client import Histogram, Counter, Gauge, generate_latest, REGISTRY

app = Flask(__name__)

# prometheus метрики
# Latency (p95 < 1 сек — SLO)
REQUEST_LATENCY = Histogram(
    'request_latency_seconds',
    'Request latency in seconds',
    buckets=[0.01, 0.05, 0.1, 0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 5.0]
)

# Error Rate (< 1% — SLO)
REQUEST_COUNT = Counter('request_count_total', 'Total requests', ['status'])
ERROR_COUNT = Counter('error_count_total', 'Error requests')

# Доступность (> 99.5% — SLO)
SERVICE_UP = Gauge('service_up', 'Service availability', ['instance'])

# Бизнес-метрика: количество рекомендаций
RECOMMENDATIONS_SERVED = Counter('recommendations_served_total', 'Total recommendations served')

# ML-метрика: скор модели
MODEL_SCORE = Histogram('model_score', 'Model prediction score', buckets=[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9])

SERVICE_UP.labels(instance='ml_recommender:8000').set(1)


@app.route('/')
def index():
    return jsonify({'service': 'ML Recommender', 'status': 'running'})


@app.route('/recommend')
def recommend():
    start_time = time.time()

    try:
        user_id = request.args.get('user_id', default=1, type=int)

        # Проверка на искусственную задержку (для теста алерта)
        if os.environ.get('SIMULATE_HIGH_LATENCY', 'false').lower() == 'true':
            time.sleep(random.uniform(0.8, 2.5))  # задержка 0.8-2.5 сек
        else:
            time.sleep(random.uniform(0.05, 0.4))  # нормальная задержка

        # Имитация ошибок (1% ошибок)
        if random.random() < 0.01:
            raise Exception("Simulated service error")

        # Генерация рекомендаций
        movies = random.sample(range(1, 200), 10)
        scores = [round(random.beta(2, 5), 3) for _ in range(10)]

        for score in scores:
            MODEL_SCORE.observe(score)

        RECOMMENDATIONS_SERVED.inc()
        REQUEST_COUNT.labels(status='success').inc()

        latency = time.time() - start_time
        REQUEST_LATENCY.observe(latency)

        return jsonify({
            'user_id': user_id,
            'recommendations': [{'movie_id': m, 'score': s} for m, s in zip(movies, scores)],
            'latency_ms': round(latency * 1000, 2)
        })

    except Exception as e:
        ERROR_COUNT.inc()
        REQUEST_COUNT.labels(status='error').inc()
        latency = time.time() - start_time
        REQUEST_LATENCY.observe(latency)
        return jsonify({'error': str(e)}), 500


@app.route('/metrics')
def metrics():
    """Эндпоинт для Prometheus"""
    return generate_latest(REGISTRY), 200, {'Content-Type': 'text/plain; charset=utf-8'}


@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
