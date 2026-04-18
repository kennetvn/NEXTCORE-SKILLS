---
description: Vector database selection + operations. Use when choosing between pgvector / Pinecone / Qdrant / Chroma, designing index strategy (HNSW/IVF), filtering with metadata, or scaling beyond prototype.
---

# Vector DB Skill

Where embeddings live. Choice depends on scale + ops constraints, not "what's popular".

## Decision matrix

| Need | Pick |
|---|---|
| <1M vectors, already have Postgres | **pgvector** (no new infra) |
| <10M vectors, dev simplicity | **Chroma** (embedded, file-based) |
| 1M-100M vectors, hosted | **Pinecone** or **Qdrant Cloud** |
| Self-hosted at scale | **Qdrant** or **Weaviate** |
| Need built-in hybrid search | **Qdrant** or **Weaviate** |
| Multi-tenant SaaS | **Pinecone** (namespaces) or **Qdrant** (collections) |
| On-device / edge | **sqlite-vec** or **Chroma** |

Don't pick "the best benchmarks" — pick what your team can operate.

## pgvector (the safe default for most teams)

```sql
-- Setup
CREATE EXTENSION vector;

CREATE TABLE chunks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  doc_id UUID NOT NULL,
  text TEXT NOT NULL,
  embedding VECTOR(1536) NOT NULL,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index (HNSW: better for high-dim, faster query)
CREATE INDEX ON chunks USING hnsw (embedding vector_cosine_ops);

-- Query: cosine similarity, top 10
SELECT id, text, embedding <=> $1 AS distance
FROM chunks
WHERE metadata @> '{"lang": "en"}'
ORDER BY embedding <=> $1
LIMIT 10;
```

Operators:
- `<->` Euclidean
- `<=>` Cosine (most common for normalized embeddings)
- `<#>` Inner product

Tune HNSW: `WITH (m = 16, ef_construction = 64)` — defaults work for most.

For 1M+ vectors: consider `IVFFlat` instead (smaller index, slower build, faster filtered queries).

## Qdrant (when scaling out)

```python
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct

client = QdrantClient(url="http://localhost:6333")

client.create_collection(
    collection_name="docs",
    vectors_config=VectorParams(size=1536, distance=Distance.COSINE)
)

# Insert
client.upsert(
    collection_name="docs",
    points=[
        PointStruct(id=1, vector=embedding, payload={"text": "...", "lang": "en"})
    ]
)

# Query with filter
results = client.search(
    collection_name="docs",
    query_vector=query_embedding,
    query_filter={"must": [{"key": "lang", "match": {"value": "en"}}]},
    limit=10
)
```

Strengths: built-in hybrid (vector + payload), self-hostable, fast.

## Pinecone (managed, simple)

```python
from pinecone import Pinecone, ServerlessSpec

pc = Pinecone(api_key=os.environ["PINECONE_API_KEY"])
pc.create_index(
    name="docs",
    dimension=1536,
    metric="cosine",
    spec=ServerlessSpec(cloud="aws", region="us-east-1")
)
index = pc.Index("docs")

index.upsert(vectors=[
    ("chunk-1", embedding, {"text": "...", "lang": "en"})
])

results = index.query(
    vector=query_embedding,
    top_k=10,
    filter={"lang": "en"},
    include_metadata=True
)
```

Pay-per-use serverless tier good for low traffic. Costs scale with read volume.

## Index types

| Index | Build time | Query time | Memory | Use case |
|---|---|---|---|---|
| **Flat / Brute force** | Instant | Slow O(N) | Low | <100K vectors |
| **HNSW** | Slow | Fast | High (~2x vectors) | Read-heavy, frequent queries |
| **IVF / IVFFlat** | Medium | Medium | Low | Filtered queries dominant |
| **DiskANN** | Slow | Fast | Disk-based | >100M vectors, memory-constrained |

For most apps: HNSW. For huge corpora with budget constraints: DiskANN.

## Metadata filtering

Two strategies:

### Pre-filter (filter then search)
```sql
SELECT * FROM chunks
WHERE metadata @> '{"doc_id": "abc"}'  -- pre-filter
ORDER BY embedding <=> $1
LIMIT 10;
```

Fast when filter is selective (small subset matches). Slow when filter matches most rows.

### Post-filter (search then filter)
```sql
WITH candidates AS (
  SELECT * FROM chunks ORDER BY embedding <=> $1 LIMIT 100
)
SELECT * FROM candidates WHERE metadata @> '{"doc_id": "abc"}' LIMIT 10;
```

Risks missing relevant items if filter eliminates many top-100. Use `LIMIT 1000` to be safe.

Index your metadata fields (`CREATE INDEX ON chunks USING gin (metadata)`) for fast pre-filter.

## Multi-tenancy patterns

| Pattern | Pros | Cons |
|---|---|---|
| One collection per tenant | Strong isolation | Many small collections; can hit limits |
| Single collection + tenant_id metadata filter | Simple | Cross-tenant leak risk if filter forgotten |
| Namespace (Pinecone) | Built-in isolation, single index | Vendor lock-in |
| Database per tenant | Total isolation | Operational overhead |

For SaaS with 100+ tenants: namespace or shared collection + strict filter discipline.

## Versioning + updates

When source docs change, you have stale vectors. Options:

### Soft delete + re-embed
```sql
UPDATE chunks SET metadata = metadata || '{"deleted": true}' WHERE doc_id = $1;
INSERT INTO chunks (doc_id, text, embedding, metadata) VALUES (...);
-- Background job: DELETE WHERE deleted=true AND created_at < NOW() - INTERVAL '7 days'
```

### Atomic swap (better for big docs)
1. Create new chunks with `version_id = N+1`
2. Verify count + sample queries OK
3. Switch query filter to `version_id = N+1`
4. Delete old `version_id = N` after grace period

## Backups

- pgvector: just `pg_dump` (vectors are just bytea-ish)
- Qdrant: snapshot API → upload to S3
- Pinecone: export API (slow for large collections)
- Always backup BEFORE major reindex / schema change

## Cost / scale watch-points

| Resource | At what scale | Mitigation |
|---|---|---|
| Index memory | 1M vectors × 1536 dim × 4 bytes ≈ 6GB | DiskANN, scalar quantization |
| Query latency | Spikes when index doesn't fit RAM | Replicate, partition by tenant |
| Embed cost | 1M chunks × $0.02/1k = $20 (one-time, +updates) | Cache by content hash |
| Re-embed when changing model | 1M × full cost | Avoid model changes; if needed, dual-index during migration |

## Anti-patterns

- Storing vectors WITHOUT a primary key for source doc (can't update / delete)
- No metadata filter index → table scans on every query
- Using inner product on un-normalized embeddings (results meaningless)
- Re-embedding on every read (cache!)
- Different vector dimensions in same collection (errors)
- Sending raw vectors to logs (huge, useless to humans)
- Building HNSW index after data is loaded (slower than `with (build_in_memory)`)

## Integration

- `nc-rag-patterns` — chunking + retrieval pipeline that uses this
- `nc-llm-integration` — embedding API calls
- `nc-databases` — pgvector inside existing Postgres
- `nc-prompt-engineering` — what goes into the prompt
- `nc-backup-recovery` — pgvector backup is just pg_dump
- `nc-observability` — query latency + hit-rate metrics
