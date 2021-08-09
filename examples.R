# lambda.r reference:
# https://github.com/zatonovo/lambda.r/blob/master/NAMESPACE,
# https://rdrr.io/cran/lambda.r/man/lambda.r-package.html
# https://nevrome.medium.com/haskell-in-r-an-experiment-with-the-r-package-lambda-r-78f21c0f9fe6
source("functional/baseFP.R")


# MARK: Haskell: Lambda Expressions
# Reference: www.cs.bham.ac.uk/~vxs/teaching/Haskell/handouts/lambda.pdf
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

cur(divisible)(c(14,17))(66)
Map : plus3 : c(2,4,6)

#' New base function for quoting multiple arguments
q <- \(...) exprs(...)

data <- tibble(months = seq(1,3), temp = c(40,53,60), lets = c("jan", "feb", "mar"))
t <- \(a,...) a+select(data, ...)
cur(t)(10)(q(temp)) # elipsis arg
cur(Position,2)(\(el) el > 0)(seq(-1,2)) # test cur n_args
cur(summary)(data)
cur(\(x,y,z) (x+y)*z)(2)(3)(4)
(\(x,y,z) (x+y)*z) : 2 : 3 : 4

my <- list(months = seq(1,3), temp = c(40,53,60), lets = c("jan", "feb", "mar"), exprs(abc, 123))

t(temp, a = 10)
t : 10 : q(temp, months)

fx <- \(f, dict, i, c) {
    print_lambda(dict, i)
    \(...) {
        dict[[i]] <- list(...)[[1]]
        cat(c, i, "\n")
        print(dict)
        # Execute if all
        if (i >= c) {
            if (("..." %in% names(dict)) && (length(dict) > 1)) {
                i_elip <- Position(\(arg) arg == "...", names(dict))

                f(dict[-i_elip], !!!dict[[i_elip]])
            }
            else do.call(f, dict)
        }
        else invisible(fx(f, dict, i + 1, c))
    }
}

cur(.f) %when% {
    .f %isa% lambdar.fun
} %:=% {
    args <- vector(mode = "list", length = length(last(attributes(.f)$variants)[[1]]$fill.tokens)) |> setNames(last(attributes(.f)$variants)[[1]]$fill.tokens)

    invisible(fx(.f, args, 1, length(args)))
}
cur(.f, n_args = NULL) %:=% {
    args <- formals(.f)
    c <- if (!is.null(n_args)) n_args
        else
            if(!is.na(Position(\(arg) deparse(arg) != "", args))) Position(\(arg) deparse(arg) != "", args) - 1
            else length(args)

    invisible(fx(.f, args[seq(1,c)], 1, c))
}
print_lambda <- \(dict, i) {
    lbls <- if (i>1) names(dict)[-seq(1, i-1)] else names(dict)
    cat("lambda:", paste0(Reduce(\(accum, arg) paste0(accum, paste0("λ", arg, ".")), lbls, init = ""), paste0(lbls, collapse = " "), "\n"))
}

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
take(n, x) %:=% { cur(head, 2) : x : n }

take : 3 %.% reversed %.% cur(Filter, 2) : even <<- s(1,10) # 10 8 6


# MARK: Combinator
Y(R) %:=% { R : (Y : R) }
fact <- \(f) \(n) if (n == 1) 1 else n * f(n - 1)
Y : fact : 5
fib <- \(f) \(n) if (n == 0) 0 else if (n <= 1) 1 else f(n - 1) + f(n - 2)
Y : fib : 14