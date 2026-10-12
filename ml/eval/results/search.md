### Product search (93 test queries; hybrid weight 0.7 chosen on 50 dev queries)

| System | Recall@5 | MRR@10 | nDCG@10 |
|---|---|---|---|
| keyword (BM25) | 0.451 | 0.460 | 0.432 |
| semantic (MiniLM) | 0.894 | 0.886 | 0.881 |
| hybrid (w=0.7) | 0.928 | 0.905 | 0.903 |
| hybrid, photo descriptions also indexed | 0.884 | 0.895 | 0.884 |

nDCG@10 by query kind (test):

| System | exact (10) | synonym (20) | need (33) | look (10) | misspelling (10) | broad (10) |
|---|---|---|---|---|---|---|
| keyword (BM25) | 1.000 | 0.307 | 0.334 | 1.000 | 0.100 | 0.198 |
| semantic (MiniLM) | 1.000 | 0.944 | 0.828 | 0.963 | 0.782 | 0.830 |
| hybrid (w=0.7) | 1.000 | 0.947 | 0.864 | 1.000 | 0.876 | 0.781 |
| hybrid, photo descriptions also indexed | 1.000 | 0.948 | 0.828 | 1.000 | 0.850 | 0.746 |

Photo descriptions in the index (decided on dev): nDCG@10 0.931 with, 0.935 without, so they are left out of the index.
The look queries all contain the product's name, so they do not test the descriptions.

Dev nDCG@10 by hybrid weight (1.0 = embeddings only, 0.0 = trigram BM25 only):

| weight | 0.0 | 0.1 | 0.2 | 0.3 | 0.4 | 0.5 | 0.6 | 0.7 | 0.8 | 0.9 | 1.0 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| nDCG@10 | 0.747 | 0.769 | 0.790 | 0.813 | 0.842 | 0.878 | 0.917 | 0.935 | 0.925 | 0.917 | 0.919 |
