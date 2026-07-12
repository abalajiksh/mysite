+++
date = '2026-07-12T11:40:00+02:00'
draft = false
title = 'Petrov Classification: Six Ways for a Quartic to Collapse'
useAlpine = false
series = "Weyl Tensor and All the Good Stuff that comes with it"
tags = [
    "petrov-classification",
    "weyl-tensor",
    "general-relativity",
    "newman-penrose",
    "principal-null-directions",
    "kerr-metric",
    "kasner",
    "goldberg-sachs",
    "xact",
    "mathematica",
    "tensor-calculus"
]
+++

## Where We Left Off

At the end of the last article, I showed that the divergence of the Weyl tensor obeys

$$C^{abcd}_{;d} = J^{abc}$$

which looks suspiciously like Maxwell's $F^{ab}_{;b} = J^a$, and I promised more technical things about this tensor in upcoming articles. This is one of those articles.

The topic is the Petrov classification. I read Chapter 31 of Nastase's *General Relativity: A Graduate Course*[^1], which is six pages long and presents the classification the way most textbooks do: here are six types, here is a table of which Weyl scalars vanish for each, here are some example metrics.

{{< notice note >}}

| Type | Vanishing scalars | PND multiplicities |
|------|-------------------|--------------------|
| I    | $\Psi_0 = 0$ (in an aligned frame) | $\\{1,1,1,1\\}$ |
| II   | $\Psi_0 = \Psi_1 = 0$ | $\\{2,1,1\\}$ |
| D    | $\Psi_0 = \Psi_1 = \Psi_3 = \Psi_4 = 0$ | $\\{2,2\\}$ |
| III  | $\Psi_0 = \Psi_1 = \Psi_2 = 0$ | $\\{3,1\\}$ |
| N    | $\Psi_0 = \Psi_1 = \Psi_2 = \Psi_3 = 0$ | $\\{4\\}$ |
| O    | all $\Psi_i = 0$ | — |

{{< /notice >}}

Read it and it looks like a fact about the world that somebody went out and measured. Six types. Why six? Why not four, or nine? Why does D skip $\Psi_2$ when II and III don't? The middle column has the texture of an experimental result.

It isn't one. It is a fact about polynomials, and once you see that, the entire table becomes a thing you could have derived on the back of an envelope. The right-hand column is the one that matters, and it is the only one worth memorising.

So this article does two things. First, it explains why the classification exists at all, which takes about four paragraphs. Second, it computes the Petrov type of five exact solutions from scratch in Mathematica with `xAct`, because I do not believe a thing about tensors until I have watched a machine produce it. The notebook is attached at the end.

## Why Six? The Only Thing You Need to Know

Here is the entire classification in one move.

In the two-component spinor formalism, the Weyl tensor is repackaged into a spinor $\Psi_{ABCD}$ with four indices, and this spinor turns out to be **totally symmetric** — swapping any two indices changes nothing. Total symmetry plus two-component spinors is a very strong constraint, and it has a consequence that Nastase proves at the *end* of his chapter but which I think belongs at the beginning:

{{< notice note >}}

$$\Psi_{ABCD} = \alpha_{(A}\,\beta_B\,\gamma_C\,\delta_{D)}$$

The Weyl spinor always factorises into four one-index spinors, uniquely up to scale.

{{< /notice >}}

The proof is three lines and it is just the fundamental theorem of algebra in disguise. Contract $\Psi_{ABCD}$ with a general spinor $\xi^A = z\zeta^A + \eta^A$ four times. Because everything is symmetric, you get a *quartic polynomial in $z$*. A quartic over $\mathbb{C}$ factorises into four linear factors. Each factor gives you one of the $\alpha, \beta, \gamma, \delta$. Done.

Each of those four spinors corresponds to a null vector, and those are the **principal null directions** — the PNDs. So:

- Every spacetime has **exactly four** principal null directions. Never three. Never five.
- The only freedom left is whether some of them **coincide**.

And now count. A quartic has four roots. The ways four roots can be distributed among distinct values are the partitions of 4:

$$\\{1,1,1,1\\}, \quad \\{2,1,1\\}, \quad \\{2,2\\}, \quad \\{3,1\\}, \quad \\{4\\}$$

That is five. Add the degenerate case where the polynomial is identically zero — the Weyl tensor vanishes entirely — and you have **six**.

Six Petrov types, because a quartic has six ways to collapse. That's it. That's the classification.

Everything else in Chapter 31 — the table of vanishing $\Psi_i$, the three kinds of null rotation and how each $\Psi_i$ transforms, the bivector eigenvalue equation, the alternative characterisations in terms of $K^\mu K^\nu K_{[\rho}C_{\sigma]\mu\nu[\lambda}K_{\tau]} = 0$ — is bookkeeping downstream of that one fact. Useful bookkeeping. But bookkeeping.

## The Quartic You Actually Compute

In practice you do not manipulate spinors. You pick a **null tetrad** $(l, n, m, \bar{m})$ — two real null vectors and a complex one — normalised so that

$$l \cdot n = -1, \qquad m \cdot \bar{m} = +1$$

with every other inner product zero (signature $-+++$). Then you project the Weyl tensor onto it, which gives five complex numbers:

$$
\begin{aligned}
\Psi_0 &= C_{abcd}\, l^a m^b l^c m^d \\\\
\Psi_1 &= C_{abcd}\, l^a n^b l^c m^d \\\\
\Psi_2 &= C_{abcd}\, l^a m^b \bar{m}^c n^d \\\\
\Psi_3 &= C_{abcd}\, l^a n^b \bar{m}^c n^d \\\\
\Psi_4 &= C_{abcd}\, n^a \bar{m}^b n^c \bar{m}^d
\end{aligned}
$$

Ten independent components of Weyl in 4D, packed into five complex numbers. The bookkeeping is exact.

And the quartic from the previous section, written in these:

{{< notice note >}}

$$\Psi_4 z^4 + 4\Psi_3 z^3 + 6\Psi_2 z^2 + 4\Psi_1 z + \Psi_0 = 0$$

The four roots are the four principal null directions.

{{< /notice >}}

The geometric picture is worth pausing on. Fix an observer. The directions of incoming light rays form a sphere — the observer's celestial sphere, literally the sky. Stereographic projection maps that sphere to the complex plane, and $z$ is the coordinate on it. So **the four PNDs are four points in the sky**, and the Petrov type is the pattern in which those four points merge as you move through spacetime.

Type I: four separate stars. Type D: two double stars. Type N: all four on top of each other. Type O: the sky is blank.

## The Subtlety That Will Bite You

If $\Psi_4 = 0$, the polynomial is not a quartic anymore. Its degree drops.

The missing roots have not vanished — they have gone to $z = \infty$, which under stereographic projection is the north pole of the celestial sphere, which is the direction of $l$ itself. So:

$$\text{multiplicity of the root at } \infty = 4 - \deg(p)$$

Miss this and Schwarzschild, whose only nonzero scalar is $\Psi_2$, gives you the polynomial $6\Psi_2 z^2$, a double root at $z = 0$, partition $\\{2\\}$ — which is not a partition of 4 and is not any Petrov type. I built exactly this bug into my first version of the code and the classifier dutifully told me Schwarzschild was `UNRECOGNISED: {2}`. Correct answer: the degree dropped from 4 to 2, so there is also a double root at infinity, and the partition is $\\{2,2\\}$ — type D.

## Two Invariants and a Discriminant

There is a second route, which is the one most references lead with, and it is worth having as a cross-check:

$$I = \Psi_0\Psi_4 - 4\Psi_1\Psi_3 + 3\Psi_2^2, \qquad
J = \det\begin{pmatrix}\Psi_4 & \Psi_3 & \Psi_2\\\\ \Psi_3 & \Psi_2 & \Psi_1\\\\ \Psi_2 & \Psi_1 & \Psi_0\end{pmatrix}$$

These are genuine Lorentz invariants — they do not care which tetrad you chose. And the condition

$$I^3 = 27 J^2$$

is precisely the statement that the **discriminant of the quartic vanishes**, i.e. that it has a repeated root.

Which means: *"algebraically special"* and *"the quartic has a repeated root"* are the same sentence. A spacetime is algebraically special exactly when two of its principal null directions have merged. The jargon was hiding a triviality.

There are three further quantities $K, L, N$ that separate D from II and N from III, but they are only *covariant*, not invariant — the branch conditions carry a frame assumption that most textbooks quietly omit. I compute them in the notebook, but I trust the root multiplicities over them, because root multiplicities are exact and frame-independent by construction.

## Pinning the Convention Before Trusting Anything

The Weyl tensor has a sign convention, and sign conventions in GR are a swamp. Before computing a single $\Psi$, I made `xAct` tell me which one it uses:

```mathematica
WeylToRiemann[WeylCD[-a, -b, -c, -d]] // ToCanonical
```

which returns

$$C_{abcd} = R_{abcd} - \tfrac{1}{2}\left(g_{ac}R_{bd} - g_{ad}R_{bc} - g_{bc}R_{ad} + g_{bd}R_{ac}\right) + \tfrac{1}{6}R\left(g_{ac}g_{bd} - g_{ad}g_{bc}\right)$$

Expand the antisymmetrisers in the definition I published in the last article:

$$C_{abcd} = R_{abcd} - \left(g_{a[c}R_{d]b} - g_{b[c}R_{d]a}\right) + \tfrac{1}{3}R\,g_{a[c}g_{d]b}$$

and the two agree term for term. Good. Every sign downstream is now trustworthy, and if Schwarzschild comes back with $\Psi_2 = +M/r^3$ I will know the error is in my tetrad and not in the package.

This cell took two minutes to write and it is the single most valuable cell in the notebook. Convention errors are silent. They do not throw. They just hand you a beautifully typeset wrong answer.

## The Architecture, and Why It Is Not Pure xAct

I had intended to do everything in `xCoba`, xAct's component package. I didn't, for a boring engineering reason: xTensor is **stateful**. Defining five different metrics means five `DefMetric` calls on the same manifold, and you end up in `UndefMetric`/`UndefChart` purgatory, or restarting the kernel between examples, which makes the notebook non-linear and fragile for anybody who downloads it.

So the split is:

- **`xAct` does the abstract-index work** — the convention verification above, which is exactly what it is uniquely good at.
- **A thirty-line stateless engine** in plain Mathematica does Christoffel → Riemann → Ricci → Weyl from a metric matrix. No state to unwind.
- **`xCoba` cross-checks the engine once**, on Schwarzschild, via `MetricInBasis` + `MetricCompute`. We subtract the two Weyl arrays and demand `{0}`.

That last point is the one I care about. Two independent computations of the same tensor agreeing is a much stronger claim than one computation I happen to trust. It returned `{0}`. The engine also gives Kretschmann $= 48M^2/r^6$ and Ricci $= 0$ identically, which are convention-independent facts about Schwarzschild and therefore free external checks.

(Incidentally: `DefMetric` will not accept a `CTensor`. It errors with `Cannot declare a CTensor metric. Use SetCTensor for that.` I found this out the hard way. `MetricInBasis` + `MetricCompute` is the route.)

## Five Metrics

Then the tetrad contractions, the quartic, the square-free decomposition of its roots, and the type. I ran FLRW first, deliberately: it is conformally flat, so every $\Psi$ must vanish. If a conformally flat metric does not come back as type O, the pipeline is broken and I have learned it on the cheapest possible example instead of on Kerr.

### FLRW → Type O

$$\Psi_0 = \Psi_1 = \Psi_2 = \Psi_3 = \Psi_4 = 0$$

Nothing. The sky is blank. This is the machine confirming, in one line, the conformal-flatness identity I ground out by hand across three pages in the last article. Both are correct; only one of them taught me anything.

### Schwarzschild → Type D

$$\Psi_2 = -\frac{M}{r^3}, \qquad \text{all others } = 0$$

The Kinnersley tetrad puts $l$ and $n$ along the outgoing and ingoing radial null congruences, and those *are* the two principal null directions, each doubled. The quartic reduces to $-6Mz^2/r^3$: double root at $z=0$, double root at infinity, partition $\\{2,2\\}$.

Invariants: $I = 3M^2/r^6$, $J = M^3/r^9$, and $I^3 - 27J^2 = 0$ exactly. Algebraically special, as it must be.

### Kerr → Type D

This is the one I wanted.

$$\Psi_2 = -\frac{M}{(r - i a \cos\theta)^3}, \qquad \text{all others } = 0$$

Mathematica landed the closed form on its own — `Simplify[Ψ₂ + M/(rr - I aa0 Cos[th])^3]` returned exactly `0`, first try, no massaging. I had budgeted an evening for wrestling `FullSimplify` into submission and did not need it.

Stop and look at what that expression says. **The entire Weyl tensor of a rotating black hole is one complex number.** Ten independent components of curvature, in the most famous non-trivial solution in general relativity, and in the right frame nine of them are zero and the tenth is $-M/(r-ia\cos\theta)^3$.

The real part is the tidal field. The imaginary part is the frame dragging. The two are not separate phenomena bolted together — they are the real and imaginary parts of a single object, and the algebra knew that before we did. Set $a=0$ and the imaginary part disappears along with the rotation.

For the record, the Kretschmann scalar of Kerr fills half a page. The Weyl scalar fits in a tweet. Choosing the right observable is everything.

### pp-wave → Type N

Brinkmann form, $ds^2 = H(u,x,y)\,du^2 + 2\,du\,dv + dx^2 + dy^2$ with $H = h(u)(x^2-y^2)$:

$$\Psi_4 = -h(u), \qquad \text{all others } = 0$$

Kretschmann is **zero**, and the metric is still curved. All four PNDs have collapsed onto $l = \partial_v$ — the propagation direction of the wave. Partition $\\{4\\}$.

### Kasner → Type I, and a Surprise

Kasner is the anisotropic vacuum cosmology

$$ds^2 = -dt^2 + t^{2p_1}dx^2 + t^{2p_2}dy^2 + t^{2p_3}dz^2, \qquad \sum p_i = \sum p_i^2 = 1$$

I used the Lifshitz–Khalatnikov parametrisation, $u=2$, giving $p = (-\tfrac{2}{7}, \tfrac{3}{7}, \tfrac{6}{7})$. Three distinct exponents, no residual symmetry. Result:

$$\Psi_0 = \frac{3}{49t^2}, \quad \Psi_2 = -\frac{9}{49t^2}, \quad \Psi_4 = \frac{3}{49t^2}, \quad \Psi_1 = \Psi_3 = 0$$

The quartic becomes $z^4 - 18z^2 + 1$ after normalising, whose roots are $z^2 = 9 \pm 4\sqrt{5}$ — four distinct values. Partition $\\{1,1,1,1\\}$, type I. And the discriminant confirms it:

$$I^3 - 27J^2 = \frac{4665600}{13841287201\, t^{12}} \neq 0$$

Algebraically **general**. The only one of the five.

Then I tried $u=1$, which gives $p = (-\tfrac{1}{3}, \tfrac{2}{3}, \tfrac{2}{3})$ — the axisymmetric case, where two of the three exponents coincide. I genuinely did not know what would come out, and I refused to guess. Here is what the machine said:

$$\Psi_2 = -\frac{2}{9t^2}, \qquad \text{all others } = 0$$

**Type D.**

## What the Kasner Surprise Actually Means

An expanding, anisotropic, vacuum cosmology — no horizon, no mass, no rotation, nothing remotely like a black hole — and its Weyl tensor has the *same algebraic skeleton* as Schwarzschild's.

The single discrete symmetry $p_2 = p_3$ is doing all of the work. It forces $\Psi_0 = \Psi_4 = 0$, which drops the quartic from degree 4 to degree 2, which collapses four distinct principal null directions into two double ones. Break the symmetry — nudge $u$ from 1 to 2 — and the roots scatter straight back apart into four.

This is the thing the textbook table cannot tell you, and it is why I wanted to compute rather than read. **Petrov type is a statement about symmetry, not about black-hole-ness.** Type D is not a property of black holes. It is what happens to a quartic when you impose an axial symmetry on it. Schwarzschild and axisymmetric Kasner are both type D for the *same algebraic reason*, and that reason has nothing to do with either of them being a black hole.

(Kasner is Bianchi type I, which is Nastase's next chapter[^2]. The two classifications — Petrov by Weyl algebra, Bianchi by the Lie algebra of the symmetry group — are sitting right next to each other in the book, and the $u=1$ case is where they touch.)

## Goldberg–Sachs, or Why Any of This Was Worth Doing

Look at the tally. Four of my five metrics came back algebraically special. Only the generic Kasner did not. That is not an accident of which examples I happened to pick, and here is the theorem that explains it:

{{< notice note >}}

**Goldberg–Sachs.** A vacuum spacetime is algebraically special *if and only if* it admits a shear-free geodesic null congruence.

{{< /notice >}}

Degeneracy of the principal null directions is equivalent to the existence of a special family of light rays. An algebraic condition on a tensor and a geometric condition on a congruence of null geodesics turn out to be the same statement.

And this is not a curiosity, it is a **method**. It is how the Kerr metric was found. Kerr did not solve the Einstein equations in general and stumble across a rotating black hole. He *assumed* algebraic speciality, used Goldberg–Sachs to reduce the field equations to something a human could integrate, and integrated them.

Which is why almost every exact solution you can name by name — Schwarzschild, Kerr, Reissner–Nordström, Taub–NUT, the C-metric, pp-waves, Robinson–Trautman — is algebraically special. Type I exact solutions are vanishingly rare, and it is not because nature prefers degeneracy. It is because algebraic speciality is the only crowbar we have that makes the equations tractable. The classification is not a taxonomy we built after the fact to sort the solutions. **It is the tool we used to find them.**

That reframes the entire chapter. Petrov did not classify spacetimes. He handed us a way of guessing which ones we might be able to solve.

## What I Did Not Compute

My five metrics gave me types **I, D, N, and O**. They did not give me **II or III**, and I am not going to pretend otherwise or manufacture a fake example to fill the table.

Type III shows up in some Robinson–Trautman spacetimes — non-twisting, shear-free, expanding — and computing one honestly is a genuine piece of work that would roughly double the length of the notebook for one row in a summary table. Type II is similar. Nastase says of types I and II that they are "too general to be described or exemplified," which is a slightly unsatisfying dodge but not a wrong one.

So: the coverage is incomplete, deliberately. If you want the full zoo, Stephani *et al.*'s *Exact Solutions of Einstein's Field Equations*[^3] is the reference, and it is a phone book.

## The Notebook

Everything above is reproducible. The Mathematica notebook is [here](/downloads/petrov_classification.wl) — it is a `.wl` file, which is plain text and version-controllable; open it in Mathematica and it renders as a structured notebook with foldable sections.

It contains, in order: the `xAct` load and convention verification; the stateless curvature engine; the `xCoba` cross-check; the null tetrad machinery with two independent normalisation assertions (the ten inner products, *and* metric reconstruction from the tetrad, which is the stronger of the two); the quartic and its square-free decomposition; the invariants; and all six runs. It also exports the $\Psi$ values to JSON, which is not for you — it is for me, in the next article.

{{< details summary="Summary table from the run" >}}

| Metric | Nonzero $\Psi$ | PND multiplicities | Type |
|---|---|---|---|
| FLRW ($k=0$) | none | — | **O** |
| Schwarzschild | $\Psi_2$ | $\\{2,2\\}$ | **D** |
| Kerr | $\Psi_2$ | $\\{2,2\\}$ | **D** |
| pp-wave | $\Psi_4$ | $\\{4\\}$ | **N** |
| Kasner, $u=2$ | $\Psi_0, \Psi_2, \Psi_4$ | $\\{1,1,1,1\\}$ | **I** |
| Kasner, $u=1$ | $\Psi_2$ | $\\{2,2\\}$ | **D** |

{{< /details >}}

## What Comes Next

I have deliberately said almost nothing about what the five $\Psi_i$ *mean* physically. $\Psi_2$ turns out to be the Coulomb-like tidal field, $\Psi_4$ the outgoing transverse radiation, and so on — each one has a job, and there is a lovely construction due to Szekeres called the *gravitational compass* that makes the jobs visible by watching what a small sphere of test particles does under each.

That is the next article, and it will have moving pictures: the four roots colliding on the celestial sphere as a spacetime degenerates from type I down to type O, and a sphere of freely falling dust deforming under each pure Petrov type. Both are driven by the JSON file this notebook just wrote, because I am not going to hand-wave numbers into Blender and hope.

It will also end where this series has been heading since the Maxwell analogy in the last post. Far from any source, $\Psi_4$ falls off as $1/r$ while everything else falls off faster — so every asymptotically flat spacetime becomes **type N** at infinity. Gravitational radiation is what is left when the Coulomb field has decayed away underneath it. LIGO measures $\Psi_4$ and nothing else.

Which is the quantitative version of the sentence I ended the last article on: we can describe gravitational waves without knowing the masses that generated them. It took a quartic to explain why.

---

[^1]: Horatiu Nastase, *General Relativity: A Graduate Course*, Chapter 31, "The Petrov classification," pp. 348–353. Cambridge University Press, 2025. [DOI: 10.1017/9781009575737.034](https://www.cambridge.org/core/books/abs/general-relativity/petrov-classification/CD18B78CC2A82836AA2D2FB1D562DA23). Chapter 30 of the same book covers the Newman–Penrose formalism, which is the prerequisite.

[^2]: Nastase, *op. cit.*, Chapter 32, "The Bianchi classification of Lie algebras, Riemannian manifolds, and cosmologies."

[^3]: H. Stephani, D. Kramer, M. MacCallum, C. Hoenselaers, E. Herlt, *Exact Solutions of Einstein's Field Equations*, 2nd ed., Cambridge University Press, 2003. §4 and §9 for the Petrov classification and the invariant decision tree.

[^4]: J. M. Martín-García, *xAct: Efficient tensor computer algebra for the Wolfram Language*. [http://www.xact.es/](http://www.xact.es/)

[^5]: R. P. Kerr, "Gravitational Field of a Spinning Mass as an Example of Algebraically Special Metrics," *Phys. Rev. Lett.* **11**, 237 (1963). The title is the whole point.
