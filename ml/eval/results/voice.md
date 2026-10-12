### Voice commands (150 hand-written test commands)

Share of commands fully understood (intent and the slots it needs):

| | all (150) | rule-supported intents (85) | add (60) | remove (15) | open_category (15) | open_cart (10) | checkout (10) | search (15) | describe (15) | help (10) | intent accuracy |
|---|---|---|---|---|---|---|---|---|---|---|---|
| rule parser | 40.7% | 71.8% | 65.0% | 0.0% | 100.0% | 70.0% | 0.0% | 0.0% | 0.0% | 0.0% | 50.0% |
| voice model, first run (held out) | 88.7% | 85.9% | 81.7% | 93.3% | 100.0% | 90.0% | 90.0% | 100.0% | 93.3% | 80.0% | 93.3% |
| voice model, after two fixes | 90.7% | 89.4% | 86.7% | 93.3% | 100.0% | 90.0% | 90.0% | 100.0% | 93.3% | 80.0% | 93.3% |

The first run is the clean held-out result. Two generic fixes were made after seeing its errors: when no product word is tagged, search with the command's content words (misspellings and synonyms such as "hedphones", "mobile phone"); and a number right after "the" is not a quantity ("the cheaper of the two mixers").

Voice-model errors (14):

| Command | Expected | Got |
|---|---|---|
| put the bluetooth speaker in my basket | add 107 x1 | remove 107 x1 |
| throw a scarf in the cart | add 208 x1 | open_cart  x1 |
| add a pack of coffee | add 514 x1 | add 308 x1 |
| buy six bottles of juice | add 516 x6 | add 317 x6 |
| add a labtop | add 102 x1 | add 312 x1 |
| order some suncream | add 410 x1 | add 402 x1 |
| i'll take the stand mixer | add 319 x1 | remove 319 x1 |
| get the external drive | add 110 x1 | remove 110 x1 |
| i changed my mind about the projector | remove 119 x | describe 119 x1 |
| what have i added so far | open_cart  x | open_category  x1 |
| that's all i'm done | checkout  x | help  x1 |
| how much does a bag of rice cost | describe 501 x | add 501 x1 |
| how do i order something | help  x | checkout  x1 |
| can you help me shop | help  x | search  x1 |
