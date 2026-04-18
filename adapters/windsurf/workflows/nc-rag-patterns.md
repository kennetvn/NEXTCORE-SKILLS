---
description: Retrieval-augmented generation patterns. Use when designing chunking strategy, choosing embedding models, building hybrid search, dealing with hallucination via citations, or scaling RAG beyond a prototype.
auto_execution_mode: 1
---

# RAG Patterns

Most RAG fails because chunking + retrieval is wrong, not because the model is wrong. Spend 80% of effort there.

## When NOT to use RAG

- Total docs fit in 1 prompt → just include them
- Real-time data → use tools, not RAG
- Need exact answers from structured data → SQL, not RAG
- High-stakes legal/medical → RAG hides citations badly; consider human-in-loop

## RAG pipeline

```
Source docs
   │
   ↓
1. Parse / clean (PDF → text, strip boilerplate, OCR if needed)
   │
   ↓
2. Chunk (split into retrievable units)
   │
   ↓
3. Embed (vector representation)
   │
   ↓
4. Store (vector DB) — see nc-vector-db
   │
   ↓
[ Query time ]
   │
   ↓
5. Embed query
   │
   ↓
6. Retrieve top-K
   │
   ↓
7. Rerank (optional but powerful)
   │
   ↓
8. Construct prompt with retrieved context
   │
   ↓
9. Generate (with citations)
```

## Chunking strategy (the most important step)

### Bad: fixed character count

`text.split(/.{500}/)` → splits mid-word, mid-sentence, breaks meaning.

### Better: recursive split with separators

```python
from langchain.text_splitter import RecursiveCharacterTextSplitter
splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200,
    separators=["\n\n", "\n", ". ", " ", ""]
)
```

### Best for prose: semantic chunking

Split where embedding similarity drops below threshold (i.e., new topic). Slower to index but better retrieval.

### Best for structured docs: respect structure

- Markdown: split per heading
- Code: split per function/class
- Tables: keep full table per chunk (don't split rows from headers)
- PDFs with sections: respect section boundaries

### Chunk size rules of thumb

| Content type | Chunk size | Overlap |
|---|---|---|
| Q&A / FAQ | 200-400 tokens | 0-50 |
| Documentation | 500-1000 | 100-200 |
| Long-form articles | 800-1500 | 150-300 |
| Code | 1 function or 200 lines | None (atomic units) |

Smaller chunks → more precise retrieval, but lose context.
Bigger chunks → more context per hit, but dilute relevance.

Test both with `nc-ai-evaluation`.

## Embedding choice

| Model | Dim | Cost | When |
|---|---|---|---|
| `text-embedding-3-small` (OpenAI) | 1536 | $0.02/M | Default for English, cheap |
| `text-embedding-3-large` (OpenAI) | 3072 | $0.13/M | Higher accuracy, more cost |
| `voyage-3` (Voyage AI) | 1024 | $0.06/M | Often beats OpenAI on benchmarks |
| `bge-large-en-v1.5` (open-source) | 1024 | self-host | No API cost, on your hardware |
| `multilingual-e5-large` | 1024 | self-host | VN/EN/multi-lang |

Match embedder to query language. VN/EN mixed corpus → multilingual model.

Re-embedding on model change is expensive — pick once, stick with it.

## Retrieval

### Pure vector (cosine similarity)

```python
results = collection.query(
    query_embeddings=[embed(query)],
    n_results=10
)
```

Good baseline. Misses queries with rare terms or exact-match needs (proper nouns, IDs).

### Hybrid (vector + keyword/BM25)

```python
vector_results = collection.query(query_embed, n=10)
bm25_results = bm25_index.search(query, n=10)
merged = reciprocal_rank_fusion(vector_results, bm25_results)
```

Catches: rare terms, IDs, exact phrases, technical jargon. Recommended baseline.

### Rerank (the secret sauce)

Top-50 initial recall → rerank with cross-encoder → top-5 to LLM:

```python
# Cohere Rerank API
results = cohere.rerank(query=query, documents=top_50_chunks, top_n=5)
```

Cross-encoders see query + doc together → much better relevance than embedding similarity. Adds 100-500ms but worth it.

### Metadata filtering

Always store metadata with vectors:

```json
{
  "embedding": [...],
  "text": "...",
  "metadata": {
    "doc_id": "manual-v3",
    "section": "billing",
    "updated_at": "2026-01-15",
    "lang": "en"
  }
}
```

Query with filters: `where: { doc_id: "manual-v3", lang: "en" }`. Cuts wasted retrieval.

## Citation pattern

Make the model cite, then verify citations exist:

```
SYSTEM:
You answer questions using ONLY the context provided.
Format every claim as: <claim> [^chunk_N]
At the end, list cited chunks: [^N]: <first 80 chars of chunk N text>
If context doesn't answer the question, say "I don't know based on the provided context."

CONTEXT:
[Chunk 1] (source: manual-v3, billing section)
"""
{chunk 1 text}
"""

[Chunk 2] (source: faq, section 3)
"""
{chunk 2 text}
"""

USER: <question>
```

Server-side: validate that cited chunks were actually in the prompt. Drop or flag answers with invented citations.

## Scaling problems + fixes

| Symptom | Likely cause | Fix |
|---|---|---|
| "Says it doesn't know" too often | Top-K too small or chunks too narrow | Increase K, broaden chunks |
| Confident wrong answers | No grounding constraint, low recall | Add "use ONLY context" + improve retrieval |
| Slow at query time | No reranking caching, big prompts | Cache rerank, compress prompt |
| Slow at ingest | Synchronous embed | Batch + async |
| Stale answers | No re-index on doc update | Add hooks: doc change → re-embed |
| Missing rare terms | Pure vector miss | Add BM25 hybrid |
| Different langs mixed | Wrong embedder | Multilingual model |
| Cost too high | Embedding every query without cache | Cache embed by query hash |

## Production checklist

- [ ] Embeddings cached by content hash (don't re-embed identical text)
- [ ] Query embeddings cached too (frequent queries are repeated)
- [ ] Doc deletion: when source doc removed, vectors purged
- [ ] Versioning: doc updates create new vectors, old kept until cutover
- [ ] Monitoring: track recall@K via labeled eval set
- [ ] Failure mode: when retrieval returns 0, model knows to say "no info"
- [ ] Privacy: PII in chunks → access control on retrieval

## Anti-patterns

- Putting RAG in a chat UI without showing citations (looks like model knows things it doesn't)
- Re-embedding millions of vectors when changing chunking (expensive — version + dual-write)
- Using LLM to summarize before chunking (loses information; chunk first, then maybe summarize per chunk)
- Trusting LLM citations without server validation (model invents)
- Same vector store for hot data (changing) and cold data (static) — split for performance
- Top-K = 100 sent to LLM (cost explodes; rerank to 5)
- No eval set (can't tell if changes improve or regress)

## Integration

- `nc-vector-db` — storage layer
- `nc-llm-integration` — wrapping the generation step
- `nc-prompt-engineering` — the grounding prompt template
- `nc-ai-evaluation` — measure recall + answer quality
- `nc-databases` — metadata in relational DB alongside vectors
- `nc-observability` — track retrieval latency, hit rates
