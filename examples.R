# lambda.r reference:
# https://github.com/zatonovo/lambda.r/blob/master/NAMESPACE,
# https://rdrr.io/cran/lambda.r/man/lambda.r-package.html
# https://nevrome.medium.com/haskell-in-r-an-experiment-with-the-r-package-lambda-r-78f21c0f9fe6
source("functionalOperators.R")


# MARK: Haskell: Lambda Expressions
# Reference: https://www.cs.bham.ac.uk/~vxs/teaching/Haskell/handouts/lambda.pdf
# Currying
plus3 <- `+` : 3
Map : plus3 : c(2,4,6)
Map : (`+` : 3) : c(2,4,6)

# λ notation
# With manual currying
(\(f) \(x) \(y) f(x, y)) : `+` : 3 : 4
# With explicit currying
cur(\(f, x, y) f(x, y)) : `+` : 3 : 4
# With implicit currying
(\(f, x, y) f(x, y)) : `+` : 3 : 4

# Usage
\(x) (4 * x + 6) / 3
(\(x) `/` : x : 3) %.% (`+` : 6) %.% (`*` : 4)
# or1
\(x) `/` : (`+` : (`*` : x : 4) : 6) : 3
# or2
\(x) x |> (`*` : 4)() |> (`+` : 6)() |> (\(x) `/` : x : 3)()

# 
divisible(divisors, n) %::% numeric : numeric : logical
divisible(divisors, n) %:=% { contains : divisors : (\(d) n %% d == 0) }
divisible2(divisors, n) %::% numeric : numeric : logical
divisible2(divisors, n) %:=% { contains : divisors : ((`==` : 0) %.% (`%%` : n)) }
divisible : c(14,17) : 66
divisible2 : c(14,17) : 66


# MARK: Testing operator precedence
# Check the difference in evaluation when different operators used
# Reference: https://typeclasses.com/featured/dollar
c1 %++% c2 %:=% { c(c1, c2) }
# Sort first, then append
sort : c("j", "u", "l", "i", "e") %++% c("m", "o", "r", "o", "n", "u", "k", "i")
# Append first, delay sort
sort <<- c("j", "u", "l", "i", "e") %++% c("m", "o", "r", "o", "n", "u", "k", "i")

# Produce the same results
# Reference: https://nanxiao.me/en/differentiate-application-operator-and-function-composition-in-haskell/
words(str) %:=% { strsplit(str, " ")[[1]] }
length <<- words : "a b c"
(length %.% words) : "a b c"
length %.% words <<- "a b c"
length <<- words <<- "a b c"

# Some more on function composition
# Reference: http://ics.p.lodz.pl/~stolarek/blog/2012/03/function-composition-and-dollar-operator-in-haskell/#footnote_1_161
even(x) %:=% { x %% 2 == 0 }
reversed(x) %:=% { cur(sort, 2) : x : TRUE }
take(n, x) %:=% { head : x : n }

take : 3 %.% reversed %.% Filter : even <<- s(1,10) # 10 8 6


# MARK: Ellipsis test
library(dplyr)
data <- tibble(months = seq(1,3), temp = c(40,53,60), lets = c("jan", "feb", "mar"))
my <- list(months = seq(1,3), temp = c(40,53,60), lets = c("jan", "feb", "mar"), exprs(abc, 123))

cur(\(x,y,z) (x+y)*z)(2)(3)(4)
(\(x,y,z) (x+y)*z) : 2 : 3 : 4

t <- \(a, b, ...) 10 + select(data, ...)
cur(t)(q(temp, months)) # elipsis arg

(t : 10 : 100) : q(temp, months)

(\(x) partial(partial(select, data), !!!x)() ) : q(temp, months)

sum : c(1,2,3)
cur(mean, 1) : c(1,2,3)

cur(select)(data)(q(temp, months))

select : data : q(temp, months)


# MARK: Combinator
Y(R) %:=% { R : (Y : R) }
fact <- \(f) \(n) if (n == 1) 1 else n * f(n - 1)
Y : fact : 5
fib <- \(f) \(n) if (n == 0) 0 else if (n <= 1) 1 else f(n - 1) + f(n - 2)
Y : fib : 14
