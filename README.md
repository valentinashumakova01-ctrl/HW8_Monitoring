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
- docker-compose.yml - Запуск Prometheus + Grafana + ML-сервис
- Dockerfile - Сборка ML-сервиса
- ml_service.py - Flask-приложение с Prometheus-метриками
- prometheus.yml - Конфигурация сбора метрик
- alert_rules.yml - Правила алертинга (p95 > 1s, Error Rate > 1%, сервис down)
- grafana_dashboard.json - Дашборд для импорта в Grafana
- dqops_sql.sql - SQL, вызывающий инцидент качества данных
- HW8_Monitoring_Шумакова_Валентина.ipynb - заполненный блокнот

## Запуск
### 1. Клонировать репозиторий 
git clone https://github.com/valentinashumakova01-ctrl/HW8_Monitoring.git

### 2. Запустить сервисы
docker-compose up -d

### 3. ML-сервис
- curl http://localhost:8000/recommend?user_id=123
- curl http://localhost:8000/metrics

### 3. Prometheus
open http://localhost:9090/targets

### 4. Grafana
- open http://localhost:3000
- Логин: admin / Пароль: admin
- Data Sources - Add - Prometheus (URL: http://prometheus:9090)
- Dashboards - Import - grafana_dashboard.json

### 5. Тестирование алерта
- В docker-compose.yml изменить переменную: SIMULATE_HIGH_LATENCY=true
- Перезапустить ML-сервис: docker-compose up -d ml_service
- Алерт HighLatency перейдёт в состояние FIRING:
  - Проверить: http://localhost:9090/alerts
  - Grafana: http://localhost:3000/alerting
 
### 6. Data Quality
DQOps не разворачивался (требует GUI). Вместо этого:
- Создан dqops_sql.sql с демонстрацией инцидента качества данных
- Таблица recommendations заполнена чистыми данными
- Выполнены 3 типа нарушений: выход score за [0,1], NULL, дубликаты
- Проверки показывают все нарушения (скриншот)


