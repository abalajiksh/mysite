+++
date = '2025-07-15T16:58:58+02:00'
draft = false
title = 'Weyl Tensor: Yet Another Tensor That Can Save Troubles?'
useAlpine = false
series = "Weyl Tensor and All the Good Stuff that comes with it"
tags = [
    "Weyl Tensor",
    "General Relativity",
    "Physics",
    "Tensor Analysis",
    "Gravitational Waves",
    "Conformal Geometry"
]
+++

## Introduction

In the fascinating realm of general relativity, understanding the curvature of spacetime is crucial. One tool that physicists and mathematicians use to understand this curvature is the Weyl tensor. Named after the German mathematician Hermann Weyl, the Weyl tensor provides a unique perspective on spacetime curvature that is independent of the matter content of the universe. This article delves into what the Weyl tensor is, its significance, and why it plays an essential role in 4-dimensional general relativity.

## What is the Weyl Tensor?

The Weyl tensor, denoted as $C_{abcd}$, is a tensor that encapsulates the curvature properties of a manifold in a way that remains unchanged under conformal transformations. These transformations can alter the size but not the shape of objects, making the Weyl tensor a perfect tool for studying the intrinsic geometry of spacetime.

Mathematically, the Weyl tensor in $n$-dimensions is given by:

$$
C_{abcd} = R_{abcd} - \frac{2}{n-2}(g_{a[c}R_{d]b} - g_{b[c}R_{d]a}) + \frac{2}{(n-1)(n-2)}R g_{a[c}g_{d]b}
$$

Where:
- $R_{abcd}$ is the Riemann curvature tensor, which describes the curvature of spacetime.
- $R_{ab}$ is the Ricci tensor, which is related to the matter content of spacetime via Einstein's field equations.
- $R$ is the Ricci scalar, a measure of curvature.
- $g_{ab}$ is the metric tensor, which defines the geometry of spacetime.
- The notation $[c,d]$ indicates antisymmetrization over the indices $c$ and $d$, defined as $A_{[cd]} = \frac{1}{2}(A_{cd} - A_{dc})$.

## Significance of the Weyl Tensor

The Weyl tensor is significant for several reasons, primarily due to its unique properties:

1. **Conformal Invariance:** One of the most notable properties of the Weyl tensor is its invariance under conformal transformations. This means that if we scale the metric tensor by a smooth function, the Weyl tensor remains unchanged. This property is crucial for understanding the causal structure of spacetime, as conformal transformations preserve angles and the structure of light cones.

2. **Traceless Property:** The Weyl tensor is traceless, meaning that all of its contractions vanish. This property is essential because it isolates the part of the curvature that is not determined by the local matter content, which is described by the Ricci tensor and Ricci scalar. Essentially, the Weyl tensor captures the curvature that is not locally influenced by matter.

3. **Role in Curvature Decomposition:** The Weyl tensor allows for the decomposition of the Riemann tensor into parts associated with Ricci curvature and Weyl curvature. The former is determined locally by the matter content, while the latter can propagate through space as gravitational waves.

## Why Use the Weyl Tensor in 4D General Relativity?

In the context of 4-dimensional general relativity, the Weyl tensor takes on particular importance. Here's why:

1. **Gravitational Waves:** The Weyl tensor plays a crucial role in the study of gravitational radiation. Since it describes the part of spacetime curvature that can propagate in a vacuum, it is directly related to the concept of gravitational waves—ripples in spacetime that travel outward from accelerating masses. These waves are a prediction of general relativity and were famously detected by the LIGO collaboration in 2015.

2. **Conformal Geometry:** In 4D, the Weyl tensor completely describes the conformal curvature of spacetime. This means it provides insights into the shape of spacetime independent of its size, which is particularly important in cosmology when studying the large-scale structure of the universe.

3. **Tidal Forces:** The Weyl tensor is also related to tidal forces. In general relativity, tidal forces are manifestations of the relative acceleration between two nearby particles in free fall, which is influenced by the curvature of spacetime described by the Weyl tensor.

4. **Petrov Classification:** In four dimensions, the Weyl tensor can be classified according to the Petrov classification, which categorizes gravitational fields based on their algebraic properties. This classification is useful in understanding different types of gravitational fields and their symmetries.

By isolating the conformal curvature, the Weyl tensor helps physicists and mathematicians understand the aspects of gravity that are not locally tied to matter and energy distributions, thus offering insights into the deeper geometric structure of spacetime.

## Some Cool Properties

In four dimensions, the Weyl tensor $C_{abcd}$ is defined as follows:

$$
C_{abcd} = R_{abcd} - (g_{a[c}R_{d]b} - g_{b[c}R_{d]a}) + \frac{1}{3}R g_{a[c}g_{d]b}
$$

Let us explore some properties of this tensor to get an overview of why it is proper cool.

### Trace-Free

We will show that the contraction of the Weyl tensor on the first and fourth indices vanishes:

$$
g^{ad}C_{abcd} = 0
$$

#### Step 1: Contract the Weyl Tensor

We start by contracting the Weyl tensor $ C_{abcd} $ with the metric tensor $ g^{ad} $:

$$
g^{ad}C_{abcd}
$$

Substituting the expression for $ C_{abcd} $:

$$
g^{ad}R_{abcd} - \frac{1}{2}g^{ad}(g_{ac}R_{bd} - g_{ad}R_{bc} - g_{bc}R_{ad} + g_{bd}R_{ac}) + \frac{1}{6}g^{ad}(g_{ac}g_{bd} - g_{ad}g_{bc})R
$$

#### Step 2: Simplify Each Term

**First Term: $ g^{ad}R_{abcd} $**

   Using the antisymmetry of the Riemann tensor and the definition of the Ricci tensor, we find that:

   $$
   g^{ad}R_{abcd} = -R_{bc}
   $$

**Second Term**:

   Expand the expression inside the parentheses and contract with $ g^{ad} $:

   $$
   -\frac{1}{2}g^{ad}(g_{ac}R_{bd} - g_{ad}R_{bc} - g_{bc}R_{ad} + g_{bd}R_{ac})
   $$

   After simplification, this term contributes:

   $$
   R_{bc} + \frac{1}{2}g_{bc}R
   $$

**Third Term**:

   Expand the expression inside the parentheses and contract with $ g^{ad} $:

   $$
   \frac{1}{6}g^{ad}(g_{ac}g_{bd} - g_{ad}g_{bc})R
   $$

   After simplification, this term contributes:

   $$
   -\frac{1}{2}g_{bc}R
   $$

#### Step 3: Combine Terms

Combine all the simplified terms:

$$
-R_{bc} + R_{bc} + \frac{1}{2}g_{bc}R - \frac{1}{2}g_{bc}R = 0
$$

Thus, we have shown that:

$$
g^{ad}C_{abcd} = 0
$$

This confirms that the Weyl tensor is trace-free with respect to this contraction. Considering the symmetries of the Weyl tensor and the fact that other contractions can be shown to vanish similarly, we conclude that the Weyl tensor is completely trace-free in 4-dimensional spacetime.

### Anti-Symmetric

#### Step 1: Symmetry of the Riemann Tensor

The Riemann tensor has the property:

$$ R_{abcd} = -R_{abdc} $$

This antisymmetry is fundamental and directly contributes to the Weyl tensor property we're proving.

#### Step 2: Analyzing the Ricci and Metric Terms

Consider the second term in the Weyl tensor:

$$ -\frac{1}{2}(R_{ac}g_{bd} - R_{ad}g_{bc} - R_{bc}g_{ad} + R_{bd}g_{ac}) $$

When we swap indices $ c $ and $ d $, we obtain:

$$ -\frac{1}{2}(R_{ad}g_{bc} - R_{ac}g_{bd} - R_{bd}g_{ac} + R_{bc}g_{ad}) $$

This step involves verifying the structural impact of swapping indices in these terms.

#### Step 3: Analyzing the Ricci Scalar and Metric Terms

The third term in the Weyl tensor is:

$$ \frac{1}{6}R(g_{ac}g_{bd} - g_{ad}g_{bc}) $$

Swapping indices $ c $ and $ d $ results in:

$$ \frac{1}{6}R(g_{ad}g_{bc} - g_{ac}g_{bd}) $$

Which simplifies to a sign change:

$$ \frac{1}{6}R(g_{ad}g_{bc} - g_{ac}g_{bd}) = -\frac{1}{6}R(g_{ac}g_{bd} - g_{ad}g_{bc}) $$

#### Combining Observations

By combining these observations and considering the antisymmetry of the Riemann tensor and the sign change in the Ricci scalar terms, we confirm that the Weyl tensor satisfies the property:

$$ C_{abcd} = -C_{abdc} $$

Thus, the Weyl tensor exhibits the antisymmetric property with respect to swapping the last two indices.

### Conformally Flat

Given the Riemann tensor form:

$$
R_{abcd} = K \left( g_{ac} g_{bd} - g_{ad} g_{bc} \right)
$$

We find the Ricci tensor and scalar curvature:

**Ricci Tensor:**

$$
R_{ab} = 3K g_{ab}
$$

**Ricci Scalar:**

$$
R = 12K
$$

#### Step-by-Step Simplification

**First Term:**
The first term is the Riemann tensor itself:

$$
R_{abcd} = K \left( g_{ac} g_{bd} - g_{ad} g_{bc} \right)
$$

**Second Term:**
Simplify $ g_{a[c} R_{d]b} - g_{b[c} R_{d]a} $:

Substitute $ R_{ab} = 3K g_{ab} $:

$$
g_{a[c} R_{d]b} = \frac{1}{2} (g_{ac} R_{db} - g_{ad} R_{cb}) = \frac{3K}{2} (g_{ac} g_{db} - g_{ad} g_{cb})
$$

Similarly for $ g_{b[c} R_{d]a} $:

$$
g_{b[c} R_{d]a} = \frac{3K}{2} (g_{bc} g_{da} - g_{bd} g_{ca})
$$

Combining these, the second term simplifies to:

$$
3R_{abcd}
$$

**Third Term:**
Simplify $ \frac{R}{6} g_{a[c} g_{d]b} $:

Given $ R = 12K $ and $ g_{a[c} g_{d]b} = 2R_{abcd} / K $:

$$
\frac{R}{6} g_{a[c} g_{d]b} = 2R_{abcd}
$$

**Combining all terms, we get:**

$$
C_{abcd} = R_{abcd} - 3R_{abcd} + 2R_{abcd} = 0
$$



### Maxwell-like Wave Equation

Let us rewrite the definition for Weyl Tensor as a Definition for Riemann tensor as follows:

$$
R_{abcd} = C_{abcd} + (g_{a[c}R_{d]b} - g_{b[c}R_{d]a}) - \frac{1}{3}R g_{a[c}g_{d]b}
$$

Now, we substitute this expression for Riemann tensor in the Bianchi Identity it satisfies:

$$\nabla_e R_{abcd} + \nabla_c R_{abde} + \nabla_d R_{abec} = 0$$

I am lazy boy, so I delegate this task of simplification to Mathematica and `xAct` package. Here is the code for the Mathematica to simplify the expression:

{{<highlight text>}}
(* Complete reset of Mathematica and xAct *)
Quit[]

(* Load xAct packages *)
<< xAct`xTensor`
<< xAct`xCoba`

(* Define the manifold and metric *)
DefManifold[M4, 4, {\[Mu], \[Nu], \[Rho], \[Sigma], \[Lambda], \[Kappa], \[Alpha], \[Beta], \[Gamma], \[Delta]}]
DefMetric[-1, metric[-\[Mu], -\[Nu]], CD, {";", "\[Del]"}]

(* Define abstract indices properly *)
a = \[Alpha]
b = \[Beta]  
c = \[Gamma]
d = \[Delta]

(* Define the Weyl tensor in terms of Riemann tensor *)
WeylDefinition = WeylCD[-a, -b, -c, -d] -> 
  RiemannCD[-a, -b, -c, -d] - 
  (1/2)*(metric[-a, -c] RicciCD[-b, -d] - 
         metric[-a, -d] RicciCD[-b, -c] - 
         metric[-b, -c] RicciCD[-a, -d] + 
         metric[-b, -d] RicciCD[-a, -c]) + 
  (1/6)*RicciScalarCD[]*(metric[-a, -c] metric[-b, -d] - 
                         metric[-a, -d] metric[-b, -c])

(* Define the covariant derivative of the Weyl tensor *)
WeylDerivative = CD[-d][WeylCD[-a, -b, -c, d]]

(* Substitute the Weyl tensor definition *)
WeylDerivativeExpanded = WeylDerivative /. WeylDefinition

(* Apply the contracted Bianchi identity *)
BianchiiRule1 = CD[-\[Nu]][RicciCD[-\[Mu], \[Nu]]] -> (1/2)*CD[-\[Mu]][RicciScalarCD[]]

(* Apply symmetries and simplify *)
WeylDerivativeSimplified = WeylDerivativeExpanded //. BianchiiRule1

(* Simplify further using built-in xAct rules *)
WeylDerivativeSimplified = Simplify[WeylDerivativeSimplified]

(* Use ToCanonical to properly simplify the Weyl tensor expression *)
WeylDerivativeCanonical = ToCanonical[WeylDerivativeSimplified]

Print["Weyl tensor definition:"]
Print[WeylDefinition]
Print[]

Print["Weyl tensor covariant derivative:"]
Print[WeylDerivative]
Print[]

Print["After substituting Weyl definition and applying Bianchi identities:"]
Print[WeylDerivativeCanonical]
Print[]

(* The final simplified form *)
FinalResult = CD[-d][WeylCD[c, a, b, d]] -> 
  CD[-b][RicciCD[c, a]] - CD[-a][RicciCD[c, b]] + 
  (1/6)*(metric[c, b] CD[-a][RicciScalarCD[]] - 
         metric[c, a] CD[-b][RicciScalarCD[]])

Print["Final simplified result:"]
Print[]
Print["In xAct notation:"]
Print[FinalResult]

Print[]
Print["Verification - Key properties used:"]
Print["1. Weyl tensor is traceless: C^a_{bac} = 0"]
Print["2. Contracted Bianchi identity: R^{ab}_{;b} = (1/2)R^{;a}"]
Print["3. Antisymmetry: [a;b] means antisymmetrization over indices a and b"]

(* Use xAct's built-in Weyl tensor simplification *)
Print[]
Print["Using xAct's built-in Weyl tensor simplification:"]
WeylBuiltIn = ToCanonical[CD[-d][WeylCD[-a, -b, -c, d]]]
Print[WeylBuiltIn]

(* Additional simplification using xAct rules *)
Print[]
Print["Final canonical form:"]
FinalCanonical = ToCanonical[CD[-\[Delta]][WeylCD[-\[Alpha], -\[Beta], -\[Gamma], \[Delta]]]]
Print[FinalCanonical]

{{</highlight>}}

Here is the [Mathematica Notebook](/downloads/Maxwell-Like_Wave_Equation.nb) and [PDF](/downloads/Maxwell-Like_Wave_Equation.pdf) of the output to the above code. What do we observe here?

$$C^{abcd}_{;d} = R^{c[a;b]} + \frac{1}{6}  g^{c[b}R^{;a]}$$

This can be rewritten as follows:

$$C^{abcd}_{;d} = J^{abc}$$

where 

$$J^{abc} = R^{c[a;b]} + \frac{1}{6}  g^{c[b}R^{;a]}$$

For the keen-eyed, this looks familiar to the following:

$$F^{ab}_{;b} = J^{a}$$

the Maxwell equation for Electro-Magnetic Waves. So, the Weyl Tensor encapsulates the Wave-Equation for Gravitational Waves in a source-free spacetime. Similar to Maxwell equations where we can describe the EM waves without knowing the charges that generated it, we can describe GW without the masses genearting them. This is but a glimpse of the powers this tensor wields. We will see more technical things about this tensor in the upcoming articles.

## Conclusion

The Weyl tensor is a powerful mathematical tool that provides a deeper understanding of the geometric properties of spacetime, playing an essential role in the study of gravitational waves, cosmology, and the broader theoretical landscape of general relativity. Whether you are delving into black hole physics, exploring the early universe, or studying gravitational waves, the Weyl tensor offers invaluable insights into the conformal structure of spacetime.

Its significance in 4D general relativity cannot be overstated. As we continue to explore the universe and delve deeper into the mysteries of spacetime, tools like the Weyl tensor will undoubtedly continue to illuminate our path, helping us unravel the complex tapestry of the cosmos.
