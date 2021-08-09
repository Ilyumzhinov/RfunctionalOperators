library(lambda.r)


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
":" <- \(f, x) {
    if (deparse(substitute(f)) %in% c("^", "%%", "*", "/", "+", "-", "<", ">", "<=", ">=", "==", "!=", "&", "&&", "|", "||"))
        return(\(rhs) f(x, rhs))

    # IF (eval == true) => f(x)
    # ELSE IF (eval == error) => FALSE => (cur f) x
    testSimple <- tryCatch(
        !is.null(capture.output(eval(f(x)))),
        error = \(e) FALSE
    )
    if (testSimple)
        f(x)
    else
        cur(f)(x)
}

#' Haskell's $ operator for function application.
#' Low precedence (lower than %any% and ^), right-associativity.
#' (a -> b) -> a -> b
"<<-" <- \(f, x) f : x


# MARK: Base functions
#' Naive currying that splits the function arg list into n_arg lambdas.
#' Kind of like the shortcut syntax: \f.\x.\y.M = \fxy.M
#' Logic: cur(\(f,x,y) f(x,y)) => \(f) \(x) \(y) (\(f,x,y) f(x,y))(f)(x)(y)
#' @examples cur(\(f,x,y) f(x,y)) => \(f) \(x) \(y) f(x,y)
cur(.f, n_args) %::% Function : . : Function
cur(.f, n_args = NULL) %:=% {
    fx <- \(f, dict, i, c) \(...) {
        dict <- append(dict, list(...))
        # Execute if all
        if (i >= c)
            do.call(f, dict)
        else
            fx(f, dict, i + 1, c)
    }
    c <- if (.f %isa% lambdar.fun) length(last(attributes(.f)$variants)[[1]]$fill.tokens)
        else if (is.null(n_args)) length(formals(.f))
        else n_args

    fx(.f, list(), 1, c)
}

#' Strives to make up for the lost n:m notation.
#' Creates a sequence from n to m.
s(from,to) %::% numeric : numeric : numeric
s(from,to) %:=% { cur(seq, 2) : from : to } 


# MARK: Utility functions
not(val) %::% logical : logical
not(val) %:=% !val

last(vect) %::% . : .
last(vect) %when% {
    length(vect) > 0
} %:=% { vect[length(vect)] }

contains(vect, cond) %::% . : Function : logical
contains(vect, cond) %:=% { not <<- is.null <<- Find(cond, vect) }