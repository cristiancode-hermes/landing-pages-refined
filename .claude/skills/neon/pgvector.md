# pgvector on Neon

pgvector ships on every Neon plan — embeddings live next to the data they
describe, inside transactions, behind RLS. For most products this replaces a
dedicated vector database.

## Schema & indexing

```sql
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE documents (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tenant_id  uuid NOT NULL,
  source_url text NOT NULL,
  chunk_no   int  NOT NULL,
  content    text NOT NULL,
  metadata   jsonb NOT NULL DEFAULT '{}',        -- incl. embedding model name!
  fts        tsvector GENERATED ALWAYS AS (to_tsvector('english', content)) STORED,
  embedding  vector(1536) NOT NULL,              -- MUST match your model's dims
  UNIQUE (tenant_id, source_url, chunk_no)
);

-- HNSW: the default — fast, no training step, good recall
CREATE INDEX docs_embedding_idx ON documents
  USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);

CREATE INDEX docs_fts_idx ON documents USING gin (fts);
CREATE INDEX docs_tenant_idx ON documents (tenant_id);
```

- **Dimension is schema**: changing embedding models = new column +
  backfill, not an in-place swap. Store the model name in `metadata` so
  mixed-era rows are detectable.
- **Opclass must match the query operator** or the index is silently
  ignored: `vector_cosine_ops` ↔ `<=>`, `vector_l2_ops` ↔ `<->`,
  `vector_ip_ops` ↔ `<#>`. Verify with `EXPLAIN`.
- Recall vs speed per session: `SET hnsw.ef_search = 100;` (default 40).
- Half the storage when quality allows: `halfvec(1536)` +
  `halfvec_cosine_ops`.

## Query patterns

```sql
-- kNN with tenant filter — WHERE applies, RLS applies, THEN ranking
SELECT id, content, embedding <=> $1 AS distance
FROM documents
WHERE tenant_id = $2
ORDER BY embedding <=> $1
LIMIT 10;
```

**Hybrid search** — vector + full-text fused with reciprocal rank fusion;
pure vector search misses exact identifiers, names, and codes:

```sql
WITH vec AS (
  SELECT id, row_number() OVER (ORDER BY embedding <=> $1) AS rank
  FROM documents WHERE tenant_id = $3
  ORDER BY embedding <=> $1 LIMIT 20
),
txt AS (
  SELECT id, row_number() OVER (ORDER BY ts_rank_cd(fts, q) DESC) AS rank
  FROM documents, plainto_tsquery('english', $2) q
  WHERE tenant_id = $3 AND fts @@ q
  LIMIT 20
)
SELECT d.id, d.content,
       coalesce(1.0/(60 + vec.rank), 0) + coalesce(1.0/(60 + txt.rank), 0) AS score
FROM vec FULL OUTER JOIN txt USING (id)
JOIN documents d USING (id)
ORDER BY score DESC
LIMIT 10;
```

From TypeScript with the serverless driver:

```ts
import { neon } from '@neondatabase/serverless';
const sql = neon(process.env.DATABASE_URL!);

const embedding = await embed(query);                    // your model call
const rows = await sql`
  SELECT id, content, embedding <=> ${JSON.stringify(embedding)}::vector AS distance
  FROM documents
  WHERE tenant_id = ${tenantId}
  ORDER BY distance
  LIMIT 10`;
```

## RAG pipeline notes

```python
# ingestion: chunk by structure, embed in batches, write atomically
for doc in corpus:
    chunks = split_by_headings(doc.text, target_tokens=400, overlap_tokens=60)
    embeddings = embed_batch([c.text for c in chunks])       # one API call
    with conn.transaction():                                  # no content-without-vector rows
        for chunk, emb in zip(chunks, embeddings):
            conn.execute(
                "INSERT INTO documents (tenant_id, source_url, chunk_no, content, metadata, embedding) "
                "VALUES (%s, %s, %s, %s, %s, %s) "
                "ON CONFLICT (tenant_id, source_url, chunk_no) DO UPDATE "
                "SET content = EXCLUDED.content, embedding = EXCLUDED.embedding, metadata = EXCLUDED.metadata",
                (tenant, doc.url, chunk.no, chunk.text,
                 Json({"model": EMBED_MODEL, "title": doc.title}), emb),
            )
```

- Store the source pointer in `metadata` for citations.
- **Measure retrieval, don't assume it**: keep a golden set of
  (query → expected doc ids); re-score recall@k after any change to
  chunking, model, or `ef_search`:

```python
hits = sum(any(d in retrieved(q, k=5) for d in expected) for q, expected in golden)
print(f"recall@5: {hits/len(golden):.2%}")     # gate CI on a floor, e.g. 85%
```

- Keep vectors behind the same RLS as their source rows — leaked embeddings
  leak the text (inversion attacks are practical).
