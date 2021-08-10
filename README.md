# R Functional Operators
Haskell-style operators in R for functional programming.

#### Status

**[X]** – Not implemented.

**[%]** – Work-in-progress.

**[*]** – Priority.

**[✅]** – Implementation ready.

#### Table of contents

[✅] Operators precedence

[✅] Ellipsis argument

[X] Empty argument

#### [✅] Operators precedence

| Operator                      | R functional operators | Haskell |
| ----------------------------- | ---------------------- | ------- |
| Function application: f(x)    | f : x                  | f x     |
| Function composition: f(g(x)) | f %.% g                | f . g   |
| Special function application  | f <<- g                | f $ g   |

#### [✅] Ellipsis argument

The R's  `...`  function argument can be passed via the provided  `q()`  function that delays evaluation until it is received inside the  `cur()`  function.

```R
sum : q(1,2,3,4)

# With dplyr
select : data : q(colA, colB)
mutate : data : q(colA + 1, newCol = colB / 2)
```

#### [X] Empty argument

Control the position of arguments required by the resulting function.

```R
`/` : 10 # f(x) = 10/x
`/` : {} : 10 # f(x) = x/10
```

 
