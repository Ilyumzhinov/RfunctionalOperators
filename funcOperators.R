# partial() used for the implementation of cur()
library(purrr)


# MARK: Base operators
# Operators reference:
# R operators precedence: https://stat.ethz.ch/R-manual/R-devel/library/base/html/Syntax.html
# Haskell operators precedence: https://rosettacode.org/wiki/Operator_precedence#Haskell
# Haskell . and $ operators: http://ics.p.lodz.pl/~stolarek/blog/2012/03/function-composition-and-dollar-operator-in-haskell/#footnote_1_161
# Haskell dollar sign operator: https://typeclasses.com/featured/dollar

#' Haskell's function application (empty space) operator, e.g. f x.
#' High precedence (higher than %any%), left-associativity.
#' @type (a -> b) -> a -> b
':' <- \(f, x) {
    # Process a special case when f is a binary operator
    if (deparse(substitute(f))[[1]] %in% c("^", "%%", "*", "/", "+", "-", "<", ">", "<=", ">=", "==", "!=", "&", "&&", "|", "||")) {
        # Process a special case when f is a binary operator and x is a placeholder (.)
        if(substitute(x) == ".")
            return(\(b) \(a) f(a, b))
        else return(\(b) f(x, b))
    }

    # Process a special case when x is a placeholder (.) by flipping the arguments
    if(substitute(x) == ".")
        return(\(b) \(a) cur(f)(a)(b))

    # Process a special case when x is a binary operator
    if (deparse(substitute(x))[[1]] %in% c("^", "%%", "*", "/", "+", "-", "<", ">", "<=", ">=", "==", "!=", "&", "&&", "|", "||"))
        return(
            if ("Curry" %in% class(f)) f(\(a) \(b) x(a,b))
            else cur(f)(\(a) \(b) x(a,b))
        )

    if ("Curry" %in% class(f)) f(x)
    else cur(f)(x)
}

#' Haskell's dollar ($) operator for function application.
#' Low precedence (lower than %any% and ^), right-associativity.
#' @type (a -> b) -> a -> b
'<<-' <- \(f, x) f : x

#' Haskell's dot (.) operator for function composition.
#' Average precedence, left-associativity.
#' @type (b -> c) -> (a -> b) -> (a -> c)
`%.%` <- \(f, g) \(...) f(g(...))


# MARK: Base functions
#' Delayed type constructor. Signals curInternal() to delay argument evaluation.
#' @type a -> Delayed a
Delayed <- \(x) structure(x, class = "Delayed")

#' New base function for delayed function arguments.
q <- \(...) Delayed(as.list(substitute(...())))

#' Naive currying that wraps around partial() and allows ellipsis argument passing.
#' Kind of like the shortcut syntax: \f.\x.\y.M = \fxy.M
#' Logic: cur(\(f,x,y) f(x,y)) => \(f) \(x) \(y) (\(f,x,y) f(x,y))(f)(x)(y)
#' @examples cur(\(f,x,y) f(x,y)) => \(f) \(x) \(y) f(x,y)
cur <- \(.f) {
    # Process a special case when .f is a lambda.R function
    if ("lambdar.fun" %in% class(.f))
        return(curLambdaR(.f))

    args <- formals(.f)
    c <- if(!is.na(Position(\(arg) deparse(arg) != "", args)))
            Position(\(arg) deparse(arg) != "", args) - 1
        else
            length(args)
    invisible(curInternal(.f, 1, c))
}

#' Same as cur() but forces application after a specific number of arguments.
curn <- \(.f, n_args) {
    if (n_args > 0)
        invisible(curInternal(.f, 1, n_args))
    else
        stop("curn(): n_args must be > 0")
}

#' Curry type constructor.
#' @type a -> Curry a
Curry <- \(f) structure(f, class = "Curry")

#' @type Function -> numeric -> numeric -> Curry
curInternal <- \(.f, i, c) Curry(
    \(x) {
        # Do not evaluate the quoted argument
        f <- if("Delayed" %in% class(x))
                partial(.f, !!!x)
            else partial(.f, x)
        # Execute if all
        if (i >= c) f()
        else invisible(curInternal(f, i + 1, c))
    }
)


# MARK: Extension for lambdar.R
curLambdaR <- \(.f) {
    require(lambda.r)
    c <- length(attributes(.f)$variants[[1]]$fill.tokens) |> setNames(length(attributes(.f)$variants[[1]]$fill.tokens))
    invisible(curInternal(.f, 1, c))
}