# ML Monitoring — Домашнее задание

Мониторинг ML-сервиса рекомендаций онлайн-кинотеатра с Prometheus, Grafana, детекцией дрифта и контролем качества данных.

## Дерево метрик и SLO
УВЕЛИЧИТЬ ВЫРУЧКУ ОНЛАЙН-КИНОТЕАТРА
├── БИЗНЕС (Product)
│ ├── Конверсия в просмотр — SLO: > 12%
│ └── Доход на 1000 показов — SLO: +5% MoM
├── ПРИЛОЖЕНИЕ (Frontend/API)
│ ├── Загрузка виджета p95 — SLO: < 500 мс
│ └── Ошибки API — SLO: Error Rate < 1%
├── ML-МОДЕЛЬ (Data Science)
│ ├── Точность Recall@20 — SLO: > 0.25
│ └── Свежесть данных — SLO: < 4 часа
└── ИНФРАСТРУКТУРА (DevOps)
├── Доступность сервиса — SLO: > 99.5%
└── Пропускная способность — SLO: 10 000 RPS

## Выбранный SLO для мониторинга

**Latency p95 < 1 секунда** — выбрана потому что напрямую влияет на конверсию: медленный виджет → пользователь уходит → бизнес теряет выручку.

## Структура проекта
docker-compose.yml - Запуск Prometheus + Grafana + ML-сервис
Dockerfile - Сборка ML-сервиса
ml_service.py - Flask-приложение с Prometheus-метриками
prometheus.yml - Конфигурация сбора метрик
alert_rules.yml - Правила алертинга (p95 > 1s, Error Rate > 1%, сервис down)
grafana_dashboard.json - Дашборд для импорта в Grafana
data_drift_report.html - Отчёт Evidently о дрифте данных
dqops_sql.sql - SQL, вызывающий инцидент качества данных

## Запуск
# 1. Клонировать репозиторий
git clone https://github.com/<user>/ml-monitoring-hw.git
cd ml-monitoring-hw

# 2. Запустить сервисы
docker-compose up -d

# 3. Проверить ML-сервис
curl http://localhost:8000/recommend?user_id=123
curl http://localhost:8000/metrics

# 4. Проверить Prometheus
open http://localhost:9090/targets

# 5. Открыть Grafana
open http://localhost:3000
