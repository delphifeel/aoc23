# cr = n! / r!(n - r)!

```
?###??????? - 5,2,1 -> 4 sol.
.??..??...?##. 1,1,3 -> 4 sol.
.?#..??...?##. 1,1,3 -> 2 sol
???.### 1,1,3 -> 1 sol
```

# STEPS


1) Remove groups of `.` 
  - ??.??.?##  1,1,3
2) Calc min needed except first
  - 3 + 1 + 1 + 1 - 6
3) Calc what is left for first 
  - 9 - 6 = 3 (first 3 blocks)
  - Visually: ??. for first block
4) Calc vars
  - ?? --> 2 vars
5) Remove used blocks (account #)
  - ___??.?##  _,1,3
6) Goto 2

# Example 1
## .??..??...?##. 1,1,3 -> 4 sol.

- ??.??.?## 1,1,3 (9)
- ___??.?##   1,3 (6) (2 vars)
- ______?##     3 (3) (2|2 vars)
- _________           (2|2|1 vars)
2 * 2 * 1 = 4

# Example 2
## .??????...?##. 1,1,3 -> 10 sol.
- ??????.?##  1,1,3 (10)
- ??????.?##    1,3 (5) (4 vars)


- ____._??##  1,1,3 (10)
- #___._#?##
- #___._#?##

??.??  1,1
(2 1) x (2 1) = 4

??.???  1,1

#?.#??
#?.?#?
#?.??#

?#.#??
?#.?#?
?#.??#

??.#?#

{1 2 4 5 6}
1 4
1 5
1 6

2 4
2 5
2 6

4 5
4 6
4 4

(3 1) x (3 1) - 2 (count of items ?)
(4 2) + 1 ()

## 3^2 - duplicates + no order

## COMB 3! = 3x2x1 - sort (no duplicates + no order)
1 2 3
1 3 2
2 1 3
2 3 1
3 1 2
3 2 1


## GG
???? - 1,1 -> 3
#?#?
#??#
?#?#

1234


