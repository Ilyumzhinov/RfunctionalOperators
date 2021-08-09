library(lambda.r)


# MARK: Base operators
#' Haskell's . dot operator for function composition.
#' (b -> c) -> (a -> b) -> (a -> c)
f %.% g %::% Function : Function : Function
f %.% g %:=% \(...) f(g(...))


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


# MARK: Utility functions
not(val) %::% logical : logical
not(val) %:=% !val
eq(lhs, rhs) %::% a : a : logical
eq(lhs, rhs) %:=% { lhs == rhs }

mod(lhs, rhs) %::% numeric : numeric : numeric
mod(lhs, rhs) %:=% { lhs %% rhs }

add(x, y) %::% numeric:numeric:numeric
add(x, y) %:=% { x + y }

minus(x, y) %::% numeric:numeric:numeric
minus(x, y) %:=% { x - y }

mult(x, y) %::% numeric:numeric:numeric
mult(x, y) %:=% { x * y }

divide(x, y) %::% numeric:numeric:numeric
divide(x, 0) %:=% { stop("Not divisible by 0") }
divide(x, y) %:=% {
    x / y
}

last(vect) %::% . : .
last(vect) %when% {
    length(vect) > 0
} %:=% { vect[length(vect)] }

# contains(vect, cond) %::% vector : Function : logical
contains(vect, cond) %:=% { not <<- is.null <<- Find(cond, vect) }