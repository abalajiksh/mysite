+++
date = '2025-05-13T11:48:01+02:00'
draft = true
title = 'Independent Components of a 4D Riemann Tensor et al.'
useAlpine = false
+++
## Introduction

I was at the tutorial session for General Relativity course. We were discussing about 2-sphere manifold, calculating the Riemann tensor, ricci tensor, ricci scalar and Einstein Tensor. The Instructor then asked us to compute the independent components of the Riemann Tensor in 4-Dimensions as a ~~fun~~ painful exercise to get a hang of it. And here we are!

## Riemann Tensor in 4-Dimensions

We have some (anti)symmetries we can exploit to reduce the number of independent components of the said tensor. Let me list them below:

{{< notice note >}}

$\forall i,j,k,l = \{1,2,3,4\}$, the following holds

1. $R_{ijkl} = - R_{jikl} \rightarrow R_{[ij]kl}$
2. $R_{ijkl} = - R_{ijlk} \rightarrow R_{ij[kl]}$
3. $R_{ijkl} = R_{klij} \rightarrow R_{([ij][kl])}$
4. Bianchi Identity: $R_{ijkl} + R_{iklj} + R_{iljk} = 0$

{{< /notice >}}



Let us use just the first two constraints and see how many variables we can reduce. I was lazy to count it by hand, so here is a Python code that will do just that for us.

{{< highlight text >}}

import itertools

def generate_riemann_components():
 # The Riemann tensor has 4 indices, each ranging from 0 to 3 (for 4 dimensions)
 indices = range(4)

 # We need to consider the antisymmetry of the first two indices and the last two indices
 # So we generate combinations for the first two indices and the last two indices
 first_two = list(itertools.combinations(indices, 2))
 last_two = list(itertools.combinations(indices, 2))

 # Generate all possible combinations of the first two and last two indices
 components = []
 for (i, j) in first_two:
 for (k, l) in last_two:
 # The Riemann tensor is antisymmetric in the first two indices and the last two indices
 # So we only consider the case where i < j and k < l
 components.append(((i, j), (k, l)))

 return components

# Generate and print the components
riemann_components = generate_riemann_components()
for component in riemann_components:
 print(f"R_{component[0][0]}{component[0][1]}{component[1][0]}{component[1][1]}")

{{< /highlight >}}

Running this script provides us with the following:

{{<notice info>}}

$$
\begin{align*}
R_{0101}, R_{0102}, R_{0103}, R_{0112}, R_{0113}, R_{0123}, \\
R_{0201}, R_{0202}, R_{0203}, R_{0212}, R_{0213}, R_{0223}, \\
R_{0301}, R_{0302}, R_{0303}, R_{0312}, R_{0313}, R_{0323}, \\
R_{1201}, R_{1202}, R_{1203}, R_{1212}, R_{1213}, R_{1223}, \\
R_{1301}, R_{1302}, R_{1303}, R_{1312}, R_{1313}, R_{1323}, \\
R_{2301}, R_{2302}, R_{2303}, R_{2312}, R_{2313}, R_{2323}
\end{align*}
$$


{{</notice>}}

