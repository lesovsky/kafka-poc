# Kafka cluster PoC

## Index of content
- [Task](#task)
- [Notes](#notes)
- [Setup and usage](#setup-and-usage)

### Task
We need to test and prepare a proof-of-concept Kafka setup. Requirements are as follow:

It should be reliable (survive at least 1 node loss).
We should minimise latency between read and write operations as much as possible (so consumer should be able to read message as fast as possible after producer publish it)
At the end of the task we would like to have a document with a detailed description of setup.

### Notes
- Use [docker-compose](https://docs.docker.com/compose/install/) as a quick and simple tool for demo-PoCs
- Use Zookeeper instead of KRaft (due to Zookeeper maturity) 
- Use Zookeeper HA configuration for fault tolerance
- Use Kafka HA configuration for fault tolerance
- Kafka containers expose the 29093, 29094, 29095 ports, and they have to be free.   
- Grafana container exposes the 3000 port, and it has to be free.   
- Use `make` for basic setup operations and [trubka](https://github.com/xitonix/trubka) for generating test workload
- Use simple Prometheus/Grafana setup for collecting and visualizing metrics (with no detailed dashboards)

### Implementation
> It should be reliable (survive at least 1 node loss).

Reliability is achieved for particular topics. When topic is created its replication factor has to be specified. Default replication factor could be
also configured for auto-created topics in server configuration. Test topic used here is created with replication factor 3. 

*A common production setting is a replication factor of 3, i.e., there will always be three copies of your data. This replication is performed at the level of topic-partitions.* [Kafka docs](https://kafka.apache.org/documentation/#intro_concepts_and_terms).

> We should minimise latency between read and write operations as much as possible (so consumer should be able to read message
as fast as possible after producer publish it)*

Kafka default configuration is optimized for latency and almost all settings don't need to adjust.
At the same time, read/write latencies depend on number of partitions of topics. Due to this, test topic is created as a 
single partition to minimize latencies. All Kafka instances are running with min.insync.replicas: 1, which should improve 
producers latencies.

> At the end of the task we would like to have a document with a detailed description of setup.

### Setup and usage
The following tools are required and have to be present on system: `docker-compose`, `make`. 
Makefile is a wrapper over `docker-compose` and `trubka` utilities, it is possible to execute them directly for custom operations.  

1. Up the environment.
```shell
make docker/up
```

2. Create a test topic.
```shell
make kafka/create-topic
```

3. Start to consume from test topic.
```shell
make kafka/consume
```

4. Open a new terminal and start to produce messages into test topic.
```shell
make kafka/produce
```

5. Open a grafana [dashboard](http://localhost:3000/d/uxjb-Shnz/kafka-overview?orgId=1) in a browser (login: `admin` password: `password`)


6. Restart a random container with Kafka
```shell
make docker/restart/kafka
```

7. Press Ctrl+C to interrupt produce/consume processes.


8. Down the environment
```shell
make docker/down
```