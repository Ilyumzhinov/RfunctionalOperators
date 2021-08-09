# lambda.r reference:
# https://github.com/zatonovo/lambda.r/blob/master/NAMESPACE,
# https://rdrr.io/cran/lambda.r/man/lambda.r-package.html
# https://nevrome.medium.com/haskell-in-r-an-experiment-with-the-r-package-lambda-r-78f21c0f9fe6
source("functional/baseFP.R")


# MARK: Main
abs <<- `+`:-9.3:4

# With manual currying
(\(f) \(x) \(y) f(x, y)):`/`:3:4
# With explicit currying
cur(\(f, x, y) f(x, y)):`/`:10:5
# With implicit currying
(\(f, x, y) f(x, y)):`/`:10:5

# \x −> (4*x+6) / 3
(4 * 10 + 6) / 3
# or1
(\(x) `/`:(`+`:(`*`:x:4):6):3):10
# or2
(\(x) `/`:x:3) <<- `+`:6 <<- `*`:4:10
# or3
10 |>
    (`*`:4)() |>
    (`+`:6)() |>
    (\(x) `/`:x:3)()

contains:(s:1:10):(\(x) x %% 2 == 0)


# MARK: Testing operator precedence
# Check the difference in evaluation when different operators used
# Reference: https://typeclasses.com/featured/dollar
c1 %++% c2 %:=% {
    c(c1, c2)
}
# Sort first, then append
sort:c("j", "u", "l", "i", "e") %++% c("m", "o", "r", "o", "n", "u", "k", "i")
# Append first, delay sort
sort <<- c("j", "u", "l", "i", "e") %++% c("m", "o", "r", "o", "n", "u", "k", "i")

# Produce the same results
# Reference: https://nanxiao.me/en/differentiate-application-operator-and-function-composition-in-haskell/
words(str) %:=% {
    strsplit(str, " ")[[1]]
}
length <<- words:"a b c"
(length %.% words):"a b c"
length %.% words <<- "a b c"
length <<- words <<- "a b c"

# Some more on function composition
# Reference: http://ics.p.lodz.pl/~stolarek/blog/2012/03/function-composition-and-dollar-operator-in-haskell/#footnote_1_161
even(x) %:=% {
    x %% 2 == 0
}
reversed(x) %:=% {
    sort(x, decreasing = TRUE)
}
take(n, x) %:=% {
    cur(head, 2):x:n
}

take:3 %.% reversed %.% cur(Filter, 2):even <<- s:1:10 # 10 8 6


# MARK: Combinator
Y(R) %:=% {
    R:(Y:R)
}
fact <- \(f) \(n) if (n == 1) 1 else n * f(n - 1)
Y:fact:50
fib <- \(f) \(n) if (n == 0) 0 else if (n <= 1) 1 else f(n - 1) + f(n - 2)
Y:fib:14