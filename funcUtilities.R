# NOTE: Functional utility functions
# Small functions that take advantage of the functional approach of lambda.r
library(lambda.r)

#' Checks if a vector contains an element where a condition function returns true.
anys(cond, vect) %::% Function : . : logical
anys(cond, vect) %:=% { !is.null(Find(cond, vect)) }

#' A wrapper around Reduce that uses the first element as initial element.
reduce1(f, xs) %when% { length(xs) > 0 } %:=% { Reduce(f, xs) }

#' A wrapper around list that (1) requires a non-empty list with (2) elements of the same type and (3) adds attribute for element type called Element.
Array(...) %::% a... : Array
Array() %:=% {
    stop("Array must not be empty")
}
Array(...) %:=% {
    vector <- list(...)
    vector@Element <- list(...)[[1]]
    class(vector) <- c('Array')
    vector
}