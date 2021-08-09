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
        !is.null(capture.output(eval(do.call(f, x)))),
        error = \(e) {
            if (grepl("No valid function for", e[1], fixed = TRUE))
                stop(e)
            else FALSE
        }
    )
    if (testSimple)
        do.call(f, x)
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
cur(.f) %::% Function : Function
cur(.f) %when% {
    .f %isa% lambdar.fun
} %:=% {
    args <- vector(mode = "list", length = length(last(attributes(.f)$variants)[[1]]$fill.tokens)) |> setNames(last(attributes(.f)$variants)[[1]]$fill.tokens)
    invisible(fx(.f, list(), 1, length(args)))
}
cur(.f) %:=% {
    args <- formals(.f)
    c <- if(!is.na(Position(\(arg) deparse(arg) != "", args))) Position(\(arg) deparse(arg) != "", args) - 1
        else length(args)
    invisible(fx(.f, list(), 1, c))
}
cur(.f, n_args) %::% Function : numeric : Function
cur(.f, n_args) %when% {
    n_args > 0
} %:=% {
    args <- formals(.f)
    invisible(fx(.f, list(), 1, n_args))
}
print_lambda(dict, i) %:=% {
    lbls <- if (i>1 && length(names(dict))>1) names(dict)[-seq(1, i-1)] else names(dict)
    cat("lambda:", paste0(Reduce(\(accum, arg) paste0(accum, paste0("λ", arg, ".")), lbls, init = ""), paste0(lbls, collapse = " "), "\n"))
}
fx <- \(f, dict, i, c) {
    print_lambda(dict, i)
    \(...) {
        dict <- append(dict, list(...))
        # Execute if all
        if (i >= c)
            do.call(f, dict)
        else
            fx(f, dict, i + 1, c)
    }
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