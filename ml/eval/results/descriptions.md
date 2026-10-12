### Photo descriptions (assets/ai_descriptions.json)

Generated once by HuggingFaceTB/SmolVLM-256M-Instruct (`ml/tools/describe_images.py`),
then filtered by `ml/tools/check_descriptions.py`.

- **Quality gate:** 91 of 100 kept. Rejected: 2 with invented numbers ("a zoom of 100"),
  1 field list, 6 that say nothing about the look ("The honey is honey.").
- **Accuracy, checked by eye** against the photos for a random sample of 30 kept
  descriptions (seed 42): 29 accurate (colour and, where given, material or shape match
  the photo). The miss: "The olive oil is round." (too vague; the bottle is tall and
  dark). Partial but not wrong: the blouse (gives the collar, not the green colour) and
  the face mask (closer to white than light grey).
- The app speaks the kept description on the product page; for the 9 rejected products it
  uses the hand-written text. The descriptions are not used for search (on the dev
  queries they made ranking slightly worse).
