# **LAB_CONTEXT.md – MySQL Lab Environment Overview**

## **Purpose of This Lab**

This folder (`mysql-lab/`) contains a fully self-contained MySQL 8 + PMM 3 monitoring environment used for:

* Learning & practicing MySQL DBA skills
* Running experiments (locking, semaphores, I/O stalls, etc.)
* Capturing metrics, QAN slow queries, and performance schema events
* Testing PMM configuration, exporters, and monitoring behaviors
* Running troubleshooting simulations (e.g., high concurrency, deadlocks, slow queries)

This environment is intentionally lightweight, reproducible, and disposable.

---

## **Stack Overview**

This lab uses **Docker Compose** to deploy three services:

### **1. MySQL 8.0 (`mysql80-lab`)**

* Default DB: `lab`
* User: `lab_user`
* Root password: `StrongRootPass123!`
* Exposed on host port **3306**
* Configuration overrides in `./conf.d/`
* Data stored in `./data/`

Used for:

* Stored procedure testing (e.g., `hammer()` loop)
* Running concurrency experiments
* Analyzing `SHOW ENGINE INNODB STATUS`
* Query performance testing
* Locking, semaphores, and InnoDB internals practice

---

### **2. PMM Server 3.x (`pmm-server`)**

* PMM UI available at: **[https://localhost:8443](https://localhost:8443)**
* No persistent volume (stateless by design for this lab)
* Auto-discovers PMM Client on startup

Used for:

* MySQL metrics dashboards
* Query Analytics (QAN)
* Showing InnoDB metrics, threads, connections
* Testing monitoring workflows

---

### **3. PMM Client 3.x (`pmm-client`)**

* Automatically connects to PMM Server
* Automatically registers MySQL on startup
* Uses a persistent volume for `/usr/local/percona/pmm/tmp` to avoid permission issues
* Handles exporters: mysqld_exporter, vmagent, pmm-agent, QAN, etc.

Used for:

* Exporting metrics from the MySQL container
* Enabling QAN (Performance Schema preferred)
* Testing various agent states (Running / Unknown / Failed)

---

## **Automatic Registration**

This lab is configured so PMM Client **automatically registers the MySQL instance** without manual commands.

It uses:

```
PMM_AGENT_PRERUN_SCRIPT
```

Which runs:

```bash
pmm-admin status --wait=30s &&
pmm-admin add mysql \
  --service-name=mysql80-lab \
  --username=root \
  --password=StrongRootPass123! \
  --host=mysql \
  --port=3306 \
  --query-source=perfschema \
  || echo "mysql80-lab already registered or add failed"
```

This ensures:

* MySQL metrics appear automatically in PMM
* QAN ingest starts without manual intervention

---

## **Common Issues & Fixes**

### **1. PMM Server shows “500 Internal Server Error” after restart**

Fix:

```bash
docker compose down -v
docker compose up -d
```

(Lights out approach: the PMM data dir can get corrupted.)

---

### **2. QAN shows “No data”**

Most common fixes:

* Enable Performance Schema ingestion
* Ensure MySQL user has required privileges
* Ensure `pmm-agent` and `qan-mysql-perfschema-agent` are Running
* Validate tmp directory permissions on pmm-client (this was a recurring issue)

---

### **3. PMM Client stuck in restart loop**

Usually caused by:

* Missing or undefined volume
* Bad permissions in `/usr/local/percona/pmm/tmp`
* PMM agent setup mismatches
* Attempting to run `pmm-admin add mysql` before PMM Server is ready

Solution implemented here:

* Persistent named volume (`pmm-client-data`)
* Proper `depends_on:` with `condition: service_healthy`
* PRERUN script waits for PMM readiness

---

## **Directory Layout**

```
mysql-lab/
│
├── docker-compose.yml     # Full stack definition
│
├── LAB_CONTEXT.md         # This context file :)
│
├── data/                  # MySQL datadir (auto-created)
│
├── conf.d/                # MySQL custom config overrides
│   ├── my.cnf
│   └── performance.cnf
│
├── scripts/               # DBA experiments, SPs, load generators
│   ├── hammer.sql
│   ├── deadlock_test.sql
│   ├── semaphore_sim.sh
│   └── connection_flooder.sh
│
└── notes/                 # Your personal troubleshooting notes
```

---

## **What I (Gio) Am Actively Working On**

This context is important for Copilot/Codex alignment.

### **Active Learning Topics**

* InnoDB internals: locks, semaphores, waits, contention
* Understanding `SHOW ENGINE INNODB STATUS`
* Using Percona QAN to analyze query performance
* Troubleshooting PMM agent states
* Setting up hands-on MySQL DBA exercises
* Automating lab setup and monitoring

### **Current Goals**

* Make the lab **100% auto-configuring**
* Avoid manual `pmm-admin add mysql` steps
* Build reusable practice scenarios
* Document issues/solutions for future reference
* Improve MySQL troubleshooting skills (DBA-level)

---

## **Quick Start**

From inside `mysql-lab/`:

```bash
docker compose up -d
```

Check logs:

```bash
docker logs -f pmm-server
docker logs -f pmm-client
docker logs -f mysql80-lab
```

Log into MySQL:

```bash
mysql -h127.0.0.1 -uroot -pStrongRootPass123!
```

Check PMM registration:

```bash
docker exec -it pmm-client pmm-admin list
```

Open PMM UI:

👉 [https://localhost:8443](https://localhost:8443)
(username: admin, password: admin)

---

## **Good to Know**

* This lab is **disposable** – it is safe to tear it down and rebuild.
* PMM Server does **not** persist data unless you add a volume.
* PMM Client *does* use a persistent tmp volume (important for stability).
* Most monitoring issues in the lab come from:

  * Permission issues
  * Ordering issues (PMM not ready)
  * Missing volumes
  * PRERUN script running too early

---

## **If Codex Needs to Help**

Codex should assume:

* You are testing MySQL performance & monitoring
* You want actionable DBA-level explanations
* Simplicity over production-hardening
* Everything inside this lab can be broken on purpose

