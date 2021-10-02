# NOTE: Functional utility functions
# Small functions that take advantage of the functional approach
# and that are used throughout examples
library(lambda.r)

#' Same as !val
not(val) %::% logical : logical
not(val) %:=% !val

#' Returns the last vector element
last(vect) %::% . : .
last(vect) %when% {
    length(vect) > 0
} %:=% { vect[length(vect)] }

#' Checks if a vector contains an element where a condition function returns true.
contains(vect, cond) %::% . : Function : logical
contains(vect, cond) %:=% { !is.null(Find(cond, vect)) }

#' Checks if all elements in a list are EXACTLY the same type
allEqual(lst) %::% list : logical
allEqual(lst) %:=% { !contains(lst, \(el) !setequal(class(el), class(lst[[1]]))) }

#' A wrapper around list that (1) requires a non-empty list with (2) elements of the same type and (3) adds attribute for element type called Element.
Array(...) %::% ... : Array
Array(...) %when% {
    !is.na(list(...))
    length(list(...)) > 0
    allEqual(list(...))
} %:=% {
    vector <- list(...)
    vector@Element <- list(...)[[1]]
    class(vector) <- c('Array')
    vector
}