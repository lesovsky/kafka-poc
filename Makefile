BROKERS=localhost:29093,localhost:29094,localhost:29095
TOPIC=kfbench

all: help

help: ## Display this help
		@echo "Makefile available targets:"
		@grep -h -E '^[a-zA-Z_/%-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  * \033[36m%-32s\033[0m %s\n", $$1, $$2}'

docker/up: ## Up the compose environment
		docker-compose up -d

docker/down: ## Down the compose environment
		docker-compose down

kafka/create-topic: ## Create test topic
		./bin/trubka create topic -p 1 -r 3 -b ${BROKERS} ${TOPIC}

kafka/consume: ## Consume messages from test topic to stdout (press Ctrl+C to interrupt)
		./bin/trubka consume plain --kafka-version="3.0.0" -b ${BROKERS} ${TOPIC}

kafka/produce: ## Produce messages to test topic (press Ctrl+C to interrupt)
		./bin/trubka produce plain --kafka-version="3.0.0" -b ${BROKERS} -c 0 -s 1ms -g ${TOPIC} < ./etc/trubka/payload.json

docker/restart/kafka: ## Restart a random container with Kafka
		docker-compose restart kafka-$(shell shuf -i 1-3 -n 1)