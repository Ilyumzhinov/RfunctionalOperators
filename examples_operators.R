# NOTE: Examples showcasing functional operators and Haskell code-style
# lambda.r reference:
# https://github.com/zatonovo/lambda.r/blob/master/NAMESPACE,
# https://rdrr.io/cran/lambda.r/man/lambda.r-package.html
source('funcOperators.R')
source('funcUtilities.R')


# MARK: Haskell: Lambda Expressions
# Reference: https://www.cs.bham.ac.uk/~vxs/teaching/Haskell/handouts/lambda.pdf
# Currying
plus3 <- `+` : 3
Map : plus3 : c(2,4,6) # 5,7,9
Map : (`+` : 3) : c(2,4,6) # 5,7,9

# λ notation
# With manual currying
(\(f) \(x) \(y) f(x, y)) : `+` : 3 : 4 # 7
# With explicit currying
cur(\(f, x, y) f(x, y)) : `+` : 3 : 4 # 7
# With implicit currying
(\(f, x, y) f(x, y)) : `+` : 3 : 4 # 7

# Usage
\(x) (4 * x + 6) / 3
(\(x) `/` : x : 3) %.% (`+` : 6) %.% (`*` : 4)
# or1
\(x) `/` : (`+` : (`*` : x : 4) : 6) : 3
# or2
\(x) x |> (`*` : 4)() |> (`+` : 6)() |> (\(x) `/` : x : 3)()

# Usage cont.
divisible(divisors, n) %::% numeric : numeric : logical
divisible(divisors, n) %:=% { anys : (\(d) (n %% d) == 0) : divisors }
divisible2(divisors, n) %::% numeric : numeric : logical
divisible2(divisors, n) %:=% { anys : ((`==` : 0) %.% (`%%` : n)) : divisors }
divisible : c(14,17) : 66 # FALSE
divisible2 : c(14,17) : 66 # FALSE

# Usage cont.2
head1(lst) %:=% { lst[[1]] }
Map : cur(\(x,y) (x * x) + (y * y)) : c(2,3,4) # [\y (2*2) + (y*y), \y (3*3) + (y*y), \y (4*4) + (y*y)]
(head1 <<- Map : cur(\(x,y) (x * x) + (y * y)) : c(2,3,4)) : 5 # 29

# More Higher Order
(\(f,g,x,y) g : (f : x : x) : (f : y : y)) : (\(x,y) x*y) : (\(x,y) x+y) : 2 : 5 # 29
(\(f,g,x,y) g : (f : x : x) : (f : y : y)) : (\(x,y) x+y) : (\(x,y) x*y) : 2 : 5 # 40

g(x) %:=% { x * x }
h(y) %:=% { g : (g : y) }
j <- h %.% h
j : 2 # 2^16 = 65536

# MARK: Testing operator precedence
# Check the difference in evaluation when different operators used
# Reference: https://typeclasses.com/featured/dollar
c1 %++% c2 %:=% { c(c1, c2) }
# Sort first, then append
sort : c("j", "u", "l", "i", "e") %++% c("m", "o", "r", "o", "n", "u", "k", "i") # eijlumoronuki
# Append first, delay sort
sort <<- c("j", "u", "l", "i", "e") %++% c("m", "o", "r", "o", "n", "u", "k", "i") # eiijklmnooruu

# Produce the same results
# Reference: https://nanxiao.me/en/differentiate-application-operator-and-function-composition-in-haskell/
words(str) %:=% { (strsplit : str : " ")[[1]] }
length <<- words : "a b c" # 3
(length %.% words) : "a b c" # 3
length %.% words <<- "a b c" # 3
length <<- words <<- "a b c" # 3

# Some more on function composition
# Reference: http://ics.p.lodz.pl/~stolarek/blog/2012/03/function-composition-and-dollar-operator-in-haskell/#footnote_1_161
even(x) %:=% { x %% 2 == 0 }
reversed(x) %:=% { curn(sort, 2) : x : TRUE }
take(n, x) %:=% { head : x : n }

take : 3 %.% reversed %.% Filter : even <<- seq(1,10) # 10 8 6


# MARK: Ellipsis argument test
library(dplyr)
data <- tibble(months = seq(1,3), temp = c(40,53,60), lets = c("jan", "feb", "mar"))

cur(select)(data)(q(temp, months))
select : data : q(temp, months)