# R Functional Operators
Haskell-style operators in R for functional programming.

Created for experimental purposes such that it aims to explore the possibilities of R in allowing powerful functional programming syntax.

The library works in base R and uses S3 classes for type-checking. However, all examples rely on other experimental functional programming features provided by  `lambda.R`.

‼️ Disclaimer: in no way, shape or form is it suited for production code as it replaces existing **built-in operators** and has not been tested for stability or performance.



#### Status

**[X]** – Not implemented.

**[%]** – Work-in-progress.

**[*]** – Priority.

**[✅]** – Implemented.



#### Table of contents

[✅] Operators precedence

[✅] Curry function

[✅] Ellipsis argument

[X] Empty argument

[X] Normal-order strategy



### [✅] Operators precedence

| Operator                      | R functional operators | Haskell |
| ----------------------------- | ---------------------- | ------- |
| Function application: f(x)    | f : x                  | f x     |
| Function composition: f(g(x)) | f %.% g                | f . g   |
| Special function application  | f <<- g                | f $ g   |



### [✅] Curry function

To use existing multi-argument functions along with the new operators, use  `cur(f)`  function that splits an *n* arguments function into *n* functions with *1* argument allowing partial evaluation.

The function is based on  `purrr::partial()` but handles differently: (1) infix operators, (2) the amount of arguments and (3) ellipsis argument.

```R
# Without cur()
fun <- \(f,x,y) f(x,y)
fun(min) # Error, x and y missing
fun(min, 4, 3) # 3

# With cur()
funCur <- cur(fun) # \(f) \(x) \(y) f(x,y)
funCur(min) # \(x) \(y) min(x,y)
funCur(min)(4)(3) # 3
funCur : min : 4 : 3 # 3
```

Functional operators curry functions implicitly, however things like default and ellipsis arguments make function definitions messy. Therefore, a manual limit on the number of arguments for evaluation can be provided using the `curn(f, n_args)`.

```R
# Implicit currying with functional operators just works
fun : min : 4 : 3 # 3

# However, functions that have a bazillion arguments do not curry well
# and need explicit cur()
lm : (y ~ x) : data.frame(y = rnorm(10), x = seq(11,20)) # returns a function that expects 3 more arguments
curn(lm, 2) : (y ~ x) : data.frame(y = rnorm(10), x = seq(11,20)) # produces lm object
```

 

### [✅] Ellipsis argument

The R's  `...`  function argument can be passed via the provided  `q()`  function that delays evaluation until the actual function is invoked.

```R
sum : q(1,2,3,4)

# With dplyr
select : data : q(colA, colB)
mutate : data : q(colA + 1, newCol = colB / 2)
```



### [X] Empty argument

Control the position of arguments required by the resulting function.

```R
`/` : 10 # \(x) 10/x
`/` : {} : 10 # \(x) x/10
```



### [X] Normal-order strategy

Normal-order reduction strategy is considered an optimal strategy for evaluation in λ calculus. The strategy prioritises reducing redexes first.

It is the basis of lazy evaluation in Haskell. Because R is a lazy language as well, it should be possible to implement this strategy.

```R
# Second parameter is never used
k <- \(x, y) x

k : 42 : (stop : "error") # 42
```

