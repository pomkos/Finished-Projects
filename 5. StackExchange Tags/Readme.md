# Logic

## Question

__Possible choices:__ (1,2,3,4,5,...,45,46,47,48,49)

__Winning numbers:__ (42,32,22,12,2,8)

Question: Player choses 6 numbers from the set (1-49). Of these chosen numbers, what is the probability that *exactly five* are winners?

## Explanation

__Player's choice:__ (42,32,22,12,2,X), where X is an irrelevant number as we're only interested in the 5 numbers.

* Possible number of combinations for the player's 5 numbers from 6:

\begin{equation}
_6C_5 = {6 \choose 5} =  \frac{6!}{5!(6-5)!} =  6
\end{equation}

* The last number, X, can be any number without repeating our chosen numbers. Thus, there are `49-5 = 44` possible *correct* choices for the player to make. If the player gets (42,32,22,12,2,X) in their ticket, X can be anything that is not 42,32,22,12,2.
* We are interested in *exactly five* correct choices, the last number has to be wrong. This means `X != 8`. So the actual number of correct possibilities is `49-5-1=43`, where:
    * `49` represents the total number of possible choices in the set (1-49)
    * `5` represents the five numbers the player already chose, as they cannot be repeated
    * `1` represents the last actual winning number, which is 8. If the player selects 8 as their last number, would win the Big Win, not the Smaller Prize. For this reason 8 is excluded from the possible correct choices.
* Since there are six combinations possible of the player's correct choices, and each combination has 43 possible successful outcomes, the *total* number of successful outcomes is `6*43 = 258`.
* Finally, to calculate the probability of guessing 5 numbers correct on a six number ticket, we can use the probability formula: `p = s/f`:

\begin{equation}
P_{(5winning numbers)} = \frac{258}{49 \choose 6} = 0.00001845
\end{equation}

## Interpretation

The probability of choosing 6 numbers from the range of `1-49` where 5 of the 6 match the winning numbers, is `0.001845%`
