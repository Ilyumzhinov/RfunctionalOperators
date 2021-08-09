# lambda.r reference: 
# https://github.com/zatonovo/lambda.r/blob/master/NAMESPACE, 
# https://rdrr.io/cran/lambda.r/man/lambda.r-package.html
# https://nevrome.medium.com/haskell-in-r-an-experiment-with-the-r-package-lambda-r-78f21c0f9fe6
# require(lambda.r)
source("functional/baseFP.R")

# Operators reference:
# R operators precedence: https://stat.ethz.ch/R-manual/R-devel/library/base/html/Syntax.html
# Haskell operators precedence: https://rosettacode.org/wiki/Operator_precedence#Haskell
# Haskell . and $ operators: http://ics.p.lodz.pl/~stolarek/blog/2012/03/function-composition-and-dollar-operator-in-haskell/#footnote_1_161
# Haskell dollar sign operator: https://typeclasses.com/featured/dollar

# # MARK: Base operators
#' Haskell's function application operator (empty space), e.g. f x.
#' High precedence (higher than %any%), left associativeness.
#' (a -> b) -> a -> b
":" <- \(f, x) {
    # IF (eval == true) => f(x)
    # ELSE IF (eval == error) => FALSE => IF (x == Function) => \(...) f(x(...))
    # ELSE IF (eval == error) => FALSE => \(...) f(x, ...)
    testSimple <- tryCatch(
        !is.null(capture.output(eval(f(x)))),
        error = \(e) {
            # if (grepl("No valid function for", e[1], fixed = TRUE))
            #     stop(e)
            # else FALSE
            FALSE
        }
    )
    if (testSimple) {
        f(x)
    }
    else
        cur(f)(x)
}

#' Haskell's $ operator for function application.
#' Low precedence (lower than %any% and ^), right-associativity.
#' (a -> b) -> a -> b
"<<-" <- \(f, x) {
    f : x
}


# MARK: Utility functions
s(from,to) %::% numeric : numeric : numeric
s(from,to) %:=% { cur(seq, 2) : from : to } 


# MARK: Main
eq : 10 : 11

abs <<- add : -9.3 : 4
# Without currying
(\(f) \(x) \(y) f(x, y)) : divide : 3 : 4
# With automatic currying
(\(f, x, y) f(x, y)) : divide : 10 : 5

# \x −> (4*x+6) / 3 
(\(x) divide : (add : (mult : x : 4) : 6) : 3) : 10
# or
(\(x) divide : x : 3) <<- add : 6 <<- mult : 4 : 10
# or2
10 |> (mult : 4)() |> (add : 6)() |> (\(x) divide : x : 3)()


# divisible(divisors, n) %::% vector : numeric : logical
# divisible(divisors, n) %:=% 

contains : (cur(seq, 2) : 1 : 10) : (\(x) eq : (mod : x : 2) : 0)


cur : Find : 2 : (\(x) (x %% 2) == 0) : 1:10

Find : (\(x) (x %% 2) == 0) : 1:10

a <- \(f) \(g) \(x) f : g : x
a : add : 4 : 6
# a : (add : 1) : (divide : 2) : 3 # Supposed to be valid but is not

# MARK: Testing operator precedence
# Check the difference in evaluation when different operators used
# Reference: https://typeclasses.com/featured/dollar
c1 %++% c2 %:=% { c(c1, c2) }
# Sort first, then append
sort : c("j","u","l","i","e") %++% c("m","o","r","o","n","u","k","i")
# Append first, delay sort
sort <<- c("j","u","l","i","e") %++% c("m","o","r","o","n","u","k","i")

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
reversed(x) %:=% { sort(x, decreasing=TRUE) }
take(n, x) %:=% { cur(head, 2) : x : n }

take : 3 %.% reversed %.% cur(Filter, 2) : even <<- s : 1 : 10 # 10 8 6


# MARK: Combinator
Y(R) %:=% { R : (Y : R) }
fact <- \(f) \(n) if (n==1) 1 else n * f(n - 1)
Y : fact : 50
fib <- \(f) \(n) if (n==0) 0 else if (n<=1) 1 else f(n-1) + f(n-2)
Y : fib : 14
