# Types and pattern matching
library(lambda.r)
# partial() used for the implementation of cur()
library(purrr)


# MARK: Base operators
# Operators reference:
# R operators precedence: https://stat.ethz.ch/R-manual/R-devel/library/base/html/Syntax.html
# Haskell operators precedence: https://rosettacode.org/wiki/Operator_precedence#Haskell
# Haskell . and $ operators: http://ics.p.lodz.pl/~stolarek/blog/2012/03/function-composition-and-dollar-operator-in-haskell/#footnote_1_161
# Haskell dollar sign operator: https://typeclasses.com/featured/dollar

#' Haskell's . dot operator for function composition.
#' (b -> c) -> (a -> b) -> (a -> c)
f %.% g %::% Function : Function : Function
f %.% g %:=% \(...) f(g(...))

#' Haskell's function application operator (empty space), e.g. f x.
#' High precedence (higher than %any%), left associativeness.
#' (a -> b) -> a -> b
':' <- \(f, x) {
    if (deparse(substitute(f))[[1]] %in% c("^", "%%", "*", "/", "+", "-", "<", ">", "<=", ">=", "==", "!=", "&", "&&", "|", "||"))
        \(rhs) f(x, rhs)
    else {
        if (f %isa% Curry) f(x)
        else cur(f)(x)
    }
}

#' Haskell's $ operator for function application.
#' Low precedence (lower than %any% and ^), right-associativity.
#' (a -> b) -> a -> b
'<<-' <- \(f, x) f : x


# MARK: Base functions
Delayed(lst) %:=% lst
#' New base function for delayed function arguments.
q <- \(...) Delayed(as.list(substitute(...())))

#' Naive currying that wraps around partial() and allows ellipsis argument passing.
#' Kind of like the shortcut syntax: \f.\x.\y.M = \fxy.M
#' Logic: cur(\(f,x,y) f(x,y)) => \(f) \(x) \(y) (\(f,x,y) f(x,y))(f)(x)(y)
#' @examples cur(\(f,x,y) f(x,y)) => \(f) \(x) \(y) f(x,y)
cur(.f) %::% Function : Function
cur(.f) %when% {
    .f %isa% lambdar.fun
} %:=% {
    args <- vector(mode = "list", length = length(attributes(.f)$variants[[1]]$fill.tokens) |> setNames(length(attributes(.f)$variants[[1]]$fill.tokens)))
    invisible(curInternal(.f, 1, length(args)))
}
cur(.f) %:=% {
    args <- formals(.f)
    c <- if(!is.na(Position(\(arg) deparse(arg) != "", args)))
            Position(\(arg) deparse(arg) != "", args) - 1
        else
            length(args)
    invisible(curInternal(.f, 1, c))
}

#' Same as cur() but forces application after a set number of arguments.
curn(.f, n_args) %::% Function : numeric : Function
curn(.f, n_args) %when% {
    n_args > 0
} %:=% {
    invisible(curInternal(.f, 1, n_args))
}

Curry(f) %::% Function : Function
Curry(f) %:=% f

curInternal(.f, i, c) %::% Function : numeric : numeric : Function
curInternal(.f, i, c) %:=% { Curry(\(x) {
    # Do not evaluate the quoted argument
    f <- if(x %isa% Delayed)
            partial(.f, !!!x)
        else partial(.f, x)
    # Execute if all
    if (i >= c) f()
    else invisible(curInternal(f, i + 1, c))
})}