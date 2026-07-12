+++
date = '2026-07-12T22:40:00+02:00'
draft = false
title = 'Half the Weyl Tensor Is Invisible to Dust'
useAlpine = false
loadNerdFont = false
series = "Weyl Tensor and All the Good Stuff that comes with it"
tags = [
    "weyl-tensor",
    "petrov-classification",
    "general-relativity",
    "gravitational-waves",
    "kerr",
    "frame-dragging",
    "tidal-forces",
    "gyroscope",
    "peeling-theorem",
    "newman-penrose",
    "blender",
    "scientific-visualization",
    "mathematica",
    "numerical-analysis"
]
+++

*On splitting the Weyl tensor into a tide and a twist, why a gyroscope knows the black hole is spinning when a speck of dust does not, and how every spacetime ends up a wave if you go far enough away.*

## Where Part II Left Us

Part II ended with a table. Six spacetimes, six rows, a Petrov type in the last column, and a moderately satisfying story about how a quartic has exactly six ways to collapse. Schwarzschild came out type D. Kerr came out type D. The pp-wave came out type N. And axisymmetric Kasner — a vacuum cosmology with nothing black-hole-shaped about it — also came out type D, which was the surprise the whole post was built around.

I published that, felt good about it for approximately one afternoon, and then the obvious question arrived and would not leave.

*So what?*

A Petrov type is the multiplicity structure of the roots of a quartic. Fine. It is a classification. But a classification of **what**? What does it mean, physically, to say that Schwarzschild is type D? If I hand you two spacetimes and tell you one is type D and one is type N, what — concretely, operationally, with instruments — is different about standing in them?

Part II could not answer that. The Weyl scalars $\Psi_0 \dots \Psi_4$ are numbers attached to a null tetrad. The quartic is an algebraic object. Nowhere in that machinery does anything *happen* to anything.

This post is the answer. It turns out that the Petrov type is not a label at all. It is a prediction about what a spacetime does to a body you drop into it — and, more surprisingly, a prediction about what it does to a body that *spins*, which is a strictly different thing that no amount of dust will ever tell you.

Along the way my MacBook got very hot.

## The Two Halves of the Weyl Tensor

Start with the thing you can actually feel.

Two nearby particles in free fall do not stay a fixed distance apart. Their separation $a^i$ obeys the geodesic deviation equation, and in a local Lorentz frame moving with the observer it takes an almost embarrassingly simple form:

$$\ddot a_i = -E_{ij} a_j, \qquad E_{ij} \equiv C_{i0j0}$$

That $E_{ij}$ is the **tidal tensor**, or the *gravito-electric* part of the Weyl tensor. It is real, symmetric, and traceless in vacuum, which means it carries five independent components. It is the thing that stretches you towards a black hole and squeezes you sideways. It is, essentially, the Newtonian tidal field $\partial_i \partial_j \Phi$ with the trace removed.

But the Weyl tensor has **ten** independent components, not five.

Where are the other five?

They are in the *gravito-magnetic* part:

$$B_{ij} \equiv \tfrac{1}{2} \epsilon_{ikl} C_{klj0}$$

also real, symmetric, traceless. Five more components. Together, $E$ and $B$ exhaust the Weyl tensor.

Now here is the fact this entire post is named after, and it took me embarrassingly long to appreciate how sharp it is.

{{< notice warning >}}

**Geodesic deviation contains $E$ and only $E$.**

Look at the equation again. $\ddot a_i = -E_{ij} a_j$. There is no $B$ in it. Anywhere.

A cloud of freely-falling dust — any cloud, of any shape, watched for any length of time — is *structurally incapable* of measuring the gravito-magnetic field. Half the Weyl tensor is invisible to it.

{{< /notice >}}

This is not a small caveat. In 1965 Peter Szekeres wrote a paper called *The Gravitational Compass*[^szekeres], in which he built the best possible instrument out of test masses: four bodies connected by six dynamometers, arranged so that the readings on the springs determine the eigenvalues and the principal directions of the tidal tensor completely. It is a beautiful device. It is the theoretical limit of what you can learn about curvature by watching things fall.

And it cannot see $B$. Not because Szekeres was careless. Because masses and springs *cannot*.

I want to be careful here, because I got this wrong in my own notes for about a week. I had been sloppily calling the gyroscope experiment further down "the gravitational compass", as if Szekeres' device were the thing that detects $B$. It is not. Szekeres' compass is an $E$-meter, and a perfect one. The honest framing is stronger than the sloppy one: *the best instrument you can build out of masses and springs is blind to half the field.*

So what isn't?

## Q = E + iB

Before we get to the instrument, we need the algebra, because the algebra turns out to be the whole story in disguise.

Define

$$\boxed{Q = E + iB}$$

a complex, symmetric, traceless $3\times 3$ matrix. Ten real components: exactly the Weyl tensor, repackaged.

Why should that combination be natural rather than a cheap trick? Because of the **self-dual Weyl tensor**. Define

$$\mathcal C_{abcd} = C_{abcd} + i {}^{\ast} C_{abcd}$$

Weyl's symmetries force $\mathcal{C}$ to be self-dual on *both* index pairs, which means it lives entirely on the three-complex-dimensional space of self-dual bivectors. And a symmetric object on a 3-dimensional complex space, with the trace removed, is exactly a symmetric traceless complex $3\times3$ matrix.

Now pick a basis for that 3-space. There are two obvious ones.

- **Cartesian basis:** $Z^{(i)} = e_0 \wedge e_i + \tfrac{i}{2}\epsilon_{ijk} e^j \wedge e^k$. The components of $\mathcal{C}$ in this basis are precisely $Q_{ij} = E_{ij} + iB_{ij}$.
- **Null basis:** $U = \bar{m}\wedge n$, $V = l \wedge m$, $W = l\wedge n + m \wedge \bar{m}$. The components of $\mathcal{C}$ in *this* basis are precisely $\Psi_0 \dots \Psi_4$.

{{< notice note >}}

$Q$ and the Weyl scalars are **not two independent routes to the Petrov classification**. They are two coordinate charts on one object.

This is the same $\mathfrak{so}(3,\mathbb{C}) \cong \mathfrak{sl}(2,\mathbb{C})$ isomorphism that let Part II factorise the Weyl spinor $\Psi_{ABCD}$ into four principal spinors. It has just put on a different suit.

{{< /notice >}}

So the dictionary between them is nothing more romantic than a change-of-basis matrix. With the tetrad convention fixed as in Part II —

$$l = \tfrac{e_0 + e_1}{\sqrt{2}}, \quad n = \tfrac{e_0 - e_1}{\sqrt{2}}, \quad m = \tfrac{e_2 + i e_3}{\sqrt{2}}, \qquad l\cdot n = -1, \quad m\cdot\bar{m} = +1$$

— and with $\epsilon_{0123} = +1$, it comes out as

$$
Q = \begin{pmatrix}
2\Psi_2 & \Psi_3 - \Psi_1 & i(\Psi_1 + \Psi_3) \\\\
\Psi_3 - \Psi_1 & \tfrac{\Psi_0+\Psi_4}{2} - \Psi_2 & -\tfrac{i(\Psi_0 - \Psi_4)}{2} \\\\
i(\Psi_1 + \Psi_3) & -\tfrac{i(\Psi_0 - \Psi_4)}{2} & -\tfrac{\Psi_0+\Psi_4}{2} - \Psi_2
\end{pmatrix}
$$

I did not derive this by hand and then check it on examples. I derived it *on a completely generic Weyl tensor*: build a symmetric $6\times6$ matrix on bivector index pairs (21 components), impose the first Bianchi identity (one condition) and tracelessness (ten conditions), watch ten survive — which is already a check, since ten is the right count for Weyl in 4D — then compute $E$, $B$ and the $\Psi$ from that generic object and subtract. The difference is the zero matrix, identically, in ten free symbols. That is a theorem, not a coincidence that happened to hold on five metrics.

Two things fall out for free.

**The invariants.** The Petrov invariants $I$ and $J$ are just

$$I = \tfrac{1}{2}\operatorname{tr} Q^2, \qquad J = -\tfrac{1}{2}\det Q$$

and these reproduce, *identically*, the standard Newman–Penrose expressions from Part II:

$$I = \Psi_0\Psi_4 - 4\Psi_1\Psi_3 + 3\Psi_2^2, \qquad
J = \det\begin{pmatrix}\Psi_4 & \Psi_3 & \Psi_2\\\\ \Psi_3 & \Psi_2 & \Psi_1\\\\ \Psi_2 & \Psi_1 & \Psi_0\end{pmatrix}$$

**The sign of $B$ is not a free choice.** Had I picked the opposite orientation for $\epsilon_{ijk}$ — equivalently, had I written $Q = E - iB$ — the invariant identity **fails**. It simply does not hold. So the convention is pinned by internal consistency, before a single metric is loaded. I ran that as an explicit control cell in the notebook, because a convention you cannot break is a convention you have not actually tested.

## Six Jordan Forms, Six Types

$Q$ is traceless, so its characteristic polynomial is

$$\lambda^3 - I\lambda + 2J = 0$$

whose discriminant is $4(I^3 - 27J^2)$.

Stop and look at that for a second. Part II spent a long section establishing that a spacetime is *algebraically special* exactly when the quartic has a repeated root, exactly when $I^3 = 27J^2$. And here is a **cubic**, in a completely different space, whose discriminant is the same number.

The quartic's discriminant and the cubic's discriminant are the same object. "Algebraically special" and "$Q$ has a repeated eigenvalue" are the same statement.

Which means the Petrov classification is the **Jordan normal form of $Q$**. Six Jordan structures for a traceless $3\times3$, six Petrov types:

{{< notice note >}}

| Type | Jordan structure of $Q$ | Eigenvalues |
|---|---|---|
| **I** | diagonalisable, distinct | $\lambda_1, \lambda_2, \lambda_3$ |
| **II** | repeated pair, **not** diagonalisable | $2\lambda, -\lambda, -\lambda$ |
| **D** | repeated pair, diagonalisable | $2\lambda, -\lambda, -\lambda$ |
| **III** | nilpotent, $Q^3 = 0$, $Q^2 \neq 0$ | $0,0,0$ |
| **N** | nilpotent, $Q^2 = 0$, $Q \neq 0$ | $0,0,0$ |
| **O** | $Q = 0$ | $0,0,0$ |

{{< /notice >}}

That is the fourth independent-looking route to the same six types in this series, and it is the one that finally has meat on it, because $E$ and $B$ are things you can *measure*.

## Spaghettification Is Not a Metaphor

Take Schwarzschild. Part II gave us $\Psi_2 = -M/r^3$, everything else zero. Feed that into the dictionary:

$$Q = \Psi_2 \mathrm{diag}(2,-1,-1) \quad\Longrightarrow\quad E = \mathrm{diag}\left(-\frac{2M}{r^3}, \frac{M}{r^3}, \frac{M}{r^3}\right), \qquad B = 0$$

Now put that into $\ddot a = -Ea$. The radial eigenvalue is negative, so $\ddot a_r = +\frac{2M}{r^3} a_r$: **radial stretch**. The two transverse eigenvalues are positive: **transverse squeeze**. And they are equal, at exactly half the radial value.

That 2:1:1 ratio *is* the type-D degeneracy. It is not an analogy for it, not a consequence of it, not a picture of it. The repeated eigenvalue of $Q$ and the fact that a black hole squeezes you equally from both sides while pulling your head from your feet are **the same fact, written twice**.

Spaghettification is the statement that black holes are type D.

![five dust clouds, one per Petrov type](/images/tides_types.gif)

{{< details summary="What the animation actually shows" >}}

Five spheres of test dust, one per type, deforming under $\ddot a = -Ea$. The yellow rod through each is the $e_1$ axis — the propagation direction for type N, the radial direction for type D. **It is not decoration**; see the next section.

Each $E$ has been normalised to unit spectral norm. That matters. The "pure types" are built by setting one $\Psi$ to unity, which fixes the tidal *magnitude* arbitrarily — unnormalised, the type D cloud grows $4.9\times$ while the type I cloud grows $1.3\times$ over the same proper time, they collide with their neighbours, and the whole thing invites you to compare tidal *strength* when the Petrov type is a statement about tidal *shape*. Normalising puts every type on the same tidal clock so that the only thing differing on screen is the shape. Which is the argument.

Proper time runs $0 \to \tau_{\text{max}} \to 0$ so the loop closes without a cut. That is a display convention, not physics.

{{< /details >}}

Two things this animation taught me that I did not know going in.

### Type II is literally D + N, added

Set $\Psi_2 = \Psi_4 = -1$ and read off the tide. Then compare it to the pure type D tide plus the pure type N tide. They are the same matrix. Not approximately — the difference is identically zero, because $Q$ is *linear* in the $\Psi$.

$$E(\mathrm{II}) = E(\mathrm{D}) + E(\mathrm{N})$$

Type II is a Coulomb tide with a wave riding on it. Its eigenvalues are $\\{2\lambda, -\lambda, -\lambda\\}$ — *identical to type D* — but where D has a diagonal matrix, II has a Jordan block. Same spectrum, different structure.

Part II declared, plainly, that types II and III were not covered because I had no metric for them. I still don't. But the *tide* of a pure type is a statement about $Q$, and $Q$ is available directly from the dictionary — so the animations can be honest about types II and III without my inventing a metric I do not have. They are points in the space of Weyl tensors, not solutions of Einstein's equations, and I would rather say that out loud than quietly show you a fake spacetime.

### N and III have the *same* tide

This one stopped me.

$$E(\mathrm{N}) : \text{eigenvalues } (-1, 0, +1) \qquad E(\mathrm{III}) : \text{eigenvalues } (-1, 0, +1)$$

Identical spectra. The dust ellipsoid is the same **shape** in a transverse gravitational wave and in a type III field. If you render the two clouds side by side with no reference axis — which is exactly what my first render did — you get two identical-looking blobs and the animation is worse than useless, because it is confidently wrong.

What separates them is *orientation relative to $e_1$*.

- **Type N:** the zero eigenvalue lies **along** $e_1$. The stretch and squeeze are purely **transverse** to the propagation direction. This is the ring of particles from every LIGO press release, doing the $+$ pattern.
- **Type III:** the principal axes sit at $45°$ in the $e_1$–$e_2$ plane. They **involve the longitudinal direction**.

That is what "longitudinal" *means*. It has no Newtonian analogue, and it is supposed to look wrong to your intuition, and you cannot see any of it without the axis on screen. So the axis is drawn, and it is load-bearing.

## What the Dust Cannot See

Now, finally, $B$.

A gyroscope is not a test particle. It has structure, and curvature couples to that structure. The Mathisson–Papapetrou–Dixon equations[^mpd] give a spinning body a **spin-curvature force**:

$$\frac{Dp_a}{d\tau} = -\tfrac{1}{2} R_{abcd} u^b S^{cd}$$

I evaluated this on the generic Weyl tensor in the notebook rather than lifting a coefficient out of a paper with its own conventions, and two things came out.

{{< notice note >}}

$$F^0 = 0 \quad\text{(identically)}, \qquad\qquad \boxed{F^i = -B^{ij} S_j}$$

{{< /notice >}}

The coefficient is exactly $-1$. No stray factor of two, no sign ambiguity. And the time component vanishes *identically*: the force on a gyroscope is purely spatial. There is no gravitational analogue of the work that Faraday induction does on a magnetic dipole. That is one of the sharper observations in Costa and Herdeiro's tidal-tensor formulation of the gravito-electromagnetic analogy[^costa], and it is pleasant to watch it drop out of a symbolic computation you wrote yourself.

So: **$E$ tells a mass how to fall. $B$ tells a spin how to fall.**

The parallel with the Lorentz force is not decorative. A magnetic field does nothing to a stationary charge; you need motion. The gravito-magnetic field does nothing to a speck of dust; you need spin. In both cases half the field is invisible to the simplest possible probe, and in both cases the fix is to bring a probe that turns.

### Kerr, and the imaginary part of $\Psi_2$

Here is where it pays off.

Both Schwarzschild and Kerr are type D. Both therefore have $Q = \Psi_2\mathrm{diag}(2,-1,-1)$. Splitting into real and imaginary parts:

$$E = \operatorname{Re}(\Psi_2)\mathrm{diag}(2,-1,-1), \qquad B = \operatorname{Im}(\Psi_2)\mathrm{diag}(2,-1,-1)$$

Schwarzschild has $\Psi_2 = -M/r^3$, which is **real**. So $B = 0$, exactly.

Kerr has $\Psi_2 = -M/(r - ia\cos\theta)^3$, which is **complex**. So $B \neq 0$.

{{< notice note >}}

**The imaginary part of $\Psi_2$ *is* the gravitomagnetic field.**

Rotation enters the Weyl tensor as a **phase**. And for any type D spacetime, $B \propto E$ with constant of proportionality $\tan(\arg \Psi_2)$ — the tide and the twist share their principal axes.

{{< /notice >}}

That sentence was sitting inside Part II's table the whole time, in the row I had already computed, and I did not see it. I had the complex number. I wrote it down. I even remarked in passing that it was "elegantly complex". I just never asked what the imaginary part was *for*.

At $M=1$, $a=0.9$, $r=10$, $\theta = \pi/3$, the ratio comes out to

$$\frac{|B|}{|E|} = \tan(\arg\Psi_2) = 0.1357$$

![Schwarzschild vs Kerr, dust vs gyroscopes](/images/tides_gyro.gif)

The animation shows two spacetimes side by side. In each, a blue cloud of dust and an orange cloud of gyroscopes, released from rest at the same place, with identical initial conditions. The tidal field has been normalised away — Schwarzschild and Kerr differ in $E$ by about 1.2% at these parameters, and I did not want that 1.2% to be doing any of the work — so **anything you see separating comes from $B$ and from nothing else**.

Schwarzschild: the clouds stay locked together. Forever. $B = 0$, and the code cannot fake a force that is not there.

Kerr: they come apart.

### The honest part about the gain

The spin-curvature force is $O(S)$, and for any physical body the dimensionless spin $s = S/(mM)$ is minute. The real separation would be invisible. So the force in the animation is **exaggerated by a declared factor**, and I want to be precise about how that factor was chosen, because "I turned the knob until it looked good" is not a method.

I declared the *target*: the final gyroscope-vs-dust separation should be $0.6$ cloud radii. The offset is exactly linear in the gain, so the gain follows by one division. It came out to **6.59**. The number is reproducible rather than fiddled, and — pleasingly — the same code hands back a gain of exactly $0.00$ for Schwarzschild, because there is no force to normalise.

And one thing I did not expect, which is worth more than the caveat it lives in:

{{< notice warning >}}

**The offset is not proportional to $|B|$.**

It obeys $\ddot p = -Ep + F$. And $E$ has its *negative* eigenvalue along $e_1$ — the stretching axis — which is precisely where the spin force points when the spin is radial.

So the tide **amplifies** the drift, exponentially. The spin kicks the cloud out; the tide then pulls it further out. At $\tau = 1.1$ that is about a factor of two over the naive free-drift estimate.

The gravitomagnetic effect is largest exactly where the gravitoelectric field is already pulling things apart. $E$ and $B$ are not independent contributions you add up. For type D they *share principal axes*, and the tide feeds the twist.

{{< /notice >}}

## Watching the Roots Collide

That is the tide. Now back to the quartic, because there is one animation Part II was crying out for and could not have.

The four principal null directions are the four roots of

$$\Psi_4 z^4 + 4\Psi_3 z^3 + 6\Psi_2 z^2 + 4\Psi_1 z + \Psi_0 = 0$$

stereographically projected onto the observer's celestial sphere. The Petrov type **is** the multiplicity structure of those roots. So watching them collide is watching the classification happen.

It has to be done on the sphere, not the plane. When $\Psi_4 \to 0$ the degree drops and roots run off to $z = \infty$; in the plane they fly off screen and Schwarzschild looks like type N, which is *precisely the bug I hit in Part II*. On the sphere, infinity is just the south pole. Nothing is lost. The bug becomes impossible to write.

And $z = 0$ is a root exactly when $\Psi_0 = 0$, which is exactly the condition that $l$ is a principal null direction. So the north pole **is** $l$ — the outgoing radial direction. That orientation is not aesthetic; it makes the next two sections read correctly.

### Kasner, in closed form

Part II's surprise was that axisymmetric Kasner is type D. It found the *fact*. It did not find the *reason*.

Kasner in the Lifshitz–Khalatnikov parametrisation[^lk] has $p_1 = -u/(1+u+u^2)$ and so on, with $u \geq 1$ covering every solution. Grind the Weyl scalars out as a function of $u$ and you get:

$$\Psi_2 = \frac{-u(u+1)^2}{2(1+u+u^2)^2t^2}, \qquad \Psi_0 = \Psi_4 = \frac{u(u-1)(u+1)}{2(1+u+u^2)^2t^2}, \qquad \Psi_1 = \Psi_3 = 0$$

Look at $\Psi_0$. There is a factor of $(u-1)$ sitting in it.

At $u = 1$ — the axisymmetric case — $\Psi_0$ and $\Psi_4$ **vanish**, and only $\Psi_2$ survives. Which is type D, by inspection.

The discriminant makes it official:

$$I^3 - 27J^2 = \frac{u^6(u-1)^2(u+1)^6(u+2)^2(2u+1)^2}{4t^{12}(1+u+u^2)^{12}}$$

Its only root for $u > 0$ is $u = 1$. A double root, exactly there. **Axisymmetric Kasner is the unique algebraically special Kasner**, and the $(u-1)$ factor is the reason.

Part II found this numerically, by running a case and being surprised. Part III can *factorise* it. That is what having the right object gets you.

![four PNDs migrating to the poles as u: 3 → 1](/images/pnd_kasner.gif)

Sweep $u$ from 3 down to 1 and watch. Four principal null directions, sliding along a great circle, colliding in pairs — two at the north pole, two at the south — at exactly $u = 1$. Partition $\\{2,2\\}$. Type D.

This is a **real vacuum solution** with **one real parameter**. Nothing is synthetic. The animation is the Kasner family, and the collision is the algebra.

### The ladder, and what it is not

![I → II → D → III → N → O](/images/pnd_ladder.gif)

The other Viz A sequence walks the roots through every type in order: I → II → D → III → N → O, watching them merge one at a time. It makes "type = root multiplicity" viscerally obvious in a way no table does.

It is also **synthetic**, and I want that in bold. I specified the *roots*, built the quartic from them, and read off the $\Psi$ via the binomial weights. That guarantees the multiplicities are exactly what I asked for and no numerical root-hunting is involved — but it is a path through the **space of Weyl tensors**, not a family of solutions of Einstein's equations. There is no metric behind it. Any impression that these six spacetimes smoothly deform into one another is an artefact of my animation and not a fact about general relativity.

## Peeling: Everything Becomes a Wave

Finally, the thing that closes the series.

Far from an isolated source, along an outgoing null geodesic, the Weyl scalars fall off at different rates — the **peeling theorem**[^sachs]:

$$\Psi_4 \sim \frac{1}{r}, \quad \Psi_3 \sim \frac{1}{r^2}, \quad \Psi_2 \sim \frac{1}{r^3}, \quad \Psi_1 \sim \frac{1}{r^4}, \quad \Psi_0 \sim \frac{1}{r^5}$$

The physical reading of the five scalars is Szekeres' — his paper is the one that assigns them roles[^szekeres]:

{{< notice note >}}

| Scalar | Role | Falloff |
|---|---|---|
| $\Psi_4$ | transverse wave, **outgoing** | $1/r$ |
| $\Psi_3$ | longitudinal wave, outgoing | $1/r^2$ |
| $\Psi_2$ | **Coulomb** — the Newtonian tidal field | $1/r^3$ |
| $\Psi_1$ | longitudinal, ingoing | $1/r^4$ |
| $\Psi_0$ | transverse wave, ingoing | $1/r^5$ |

{{< /notice >}}

Feed those falloffs into the quartic and let $r \to \infty$. $\Psi_4$ comes to dominate everything, $p(z) \to \Psi_4 z^4$, and all four roots pile up at $z = 0$.

Which is the north pole. Which is $l$. Which is the outgoing radial direction.

![four PNDs collapsing to the north pole as r → ∞](/images/pnd_peeling.gif)

**Every asymptotically flat spacetime becomes type N far enough away.** Radiation is what is left when the Coulomb field has decayed faster underneath it. LIGO measures $\Psi_4$ and nothing else — not because the other four scalars are uninteresting, but because by the time the signal reaches Hanford they are gone.

{{< details summary="A confession about the coefficients" >}}

The $c_k$ in $\Psi_k \sim c_k/r^{5-k}$ are arbitrary. This animation shows the *mechanism*, not a specific solution.

And my first choice of them was a disaster that looked like a triumph. I set them all to 1, because why not. The animation was gorgeous: four roots, perfectly merged, sitting at the pole, from the first frame to the last.

Which should have worried me immediately, and did not.

With $c_k = (1,1,1,1,1)$ the quartic is

$$r^{-1}z^4 + 4r^{-2}z^3 + 6r^{-3}z^2 + 4r^{-4}z + r^{-5} = \frac{1}{r}\left(z + \frac{1}{r}\right)^4$$

A perfect fourth power. **At every value of $r$.** The spacetime was type N the whole time and my beautiful peeling animation was showing nothing peeling. The binomial coefficients $(1,4,6,4,1)$ in the quartic are not decoration — hand them a geometric sequence and they will hand you back a perfect binomial, and it will look exactly like the result you were hoping for.

The current default $c_k$ is generic: type I at small $r$, peeling to N as $r$ grows.

{{< /details >}}

### Where the analogy stops being an analogy

Part I ended on this:

$$\nabla_d C^{abcd} = J^{abc} \qquad \longleftrightarrow \qquad \nabla_b F^{ab} = J^a$$

and I called it a resemblance. A suggestive parallel. The Weyl tensor obeys a Maxwell-like wave equation, so gravitational waves can be described without their sources, just as electromagnetic waves can.

Now watch what peeling does to $Q$.

Type N means $Q^2 = 0$: nilpotent. Nilpotent means every eigenvalue is zero. Which means

$$I = \tfrac{1}{2}\operatorname{tr}Q^2 = 0, \qquad J = -\tfrac{1}{2}\det Q = 0$$

Write those out in terms of $E$ and $B$:

$$\operatorname{tr}(E^2) = \operatorname{tr}(B^2), \qquad \operatorname{tr}(EB) = 0$$

That is: $|E| = |B|$, and $E \perp B$.

{{< notice note >}}

These are the **null field conditions of electromagnetism**, term for term:

$$F_{ab}F^{ab} = 0 \quad\Longleftrightarrow\quad |\mathbf{E}| = |\mathbf{B}|$$
$$F_{ab}\tilde{F}^{ab} = 0 \quad\Longleftrightarrow\quad \mathbf{E}\cdot\mathbf{B} = 0$$

{{< /notice >}}

A radiative electromagnetic field has equal-magnitude, perpendicular $E$ and $B$. A radiative *gravitational* field has equal-magnitude, perpendicular $E$ and $B$. Same invariants, same conditions, same structure.

Part I said gravitational waves can be described without their sources. Peeling is the quantitative version of that sentence, and $Q$ is what turns the analogy into an **identity of invariant structure**. It was never a resemblance. It was the same algebra, seen from a bad angle.

I verified this explicitly on the pp-wave, where $Q^2 = 0$ and both trace conditions come back as exact zeros. It also gives a satisfying explanation of the pp-wave's most obnoxious property, the one Part II flagged and left hanging: its Kretschmann scalar is **zero**. A curved vacuum spacetime, carrying real energy, that the most famous curvature invariant cannot see at all. Of course it can't. The field is null. The invariants of a null field vanish. That is what null *means*.

{{< details summary="One thing to be careful about with type N" >}}

For a real profile $h(u)$, the $B$ of a pp-wave comes out as $E$ rotated by $45°$ — which looks exactly like the $\times$ polarisation and is **not** the $\times$ polarisation.

The two polarisations live in the real and imaginary parts of $h(u)$. $B$ is not a second polarisation; it is the gravitomagnetic partner of whichever polarisation you have. Dust only ever feels $E$, and it feels the polarisation you actually put in.

I nearly wrote a paragraph claiming otherwise. It is a very inviting mistake.

{{< /details >}}

## The Part Where the Computer Fights Back

Three things went wrong that taught me physics or numerics. They stay. Several other things went wrong that only taught me that I am fallible, and Part II established the filter for those, so they are gone.

### You cannot classify a Petrov type by diagonalising Q numerically

Not "should not". **Cannot.**

Types N and III are nilpotent: every eigenvalue is exactly zero. So my first classifier normalised the computed eigenvalues by $\max|\lambda|$ and asked whether they were small.

For a nilpotent matrix, $\max|\lambda|$ *is* the numerical noise. I was dividing noise by noise and getting $O(1)$ garbage. Every type III and every type N read back as type I.

Fine, I thought — loosen the threshold. And then I learned the actual reason, which is much better than the bug:

{{< notice warning >}}

The eigenvalues of a matrix with a $3\times3$ nilpotent Jordan block are accurate only to the **cube root of machine epsilon**.

$\epsilon^{1/3} \approx 6\times10^{-6}$, not $10^{-16}$.

There is no threshold that both catches type III and is safe for a genuine type I with small eigenvalues. The information is not there to be had.

{{< /notice >}}

The fix is to stop asking the eigenvalues anything. $I$ and $J$ are *polynomials in the $\Psi$*. They carry no eigen-decomposition error at all. Classify on $I = J = 0$ (nilpotent), then $I^3 = 27J^2$ (repeated eigenvalue), and the numerics never enter.

Which is, I noticed with some irritation, **exactly the same lesson Part II already taught me** when I chose square-free decomposition over numerical root-finding for the quartic. I learned it, wrote it down, published it, and then walked straight into it again in a different costume six months later. The lesson is not "use exact arithmetic". The lesson is: *the degenerate cases are where the information lives, and they are precisely the cases where floating point has none.*

### The sign of $\Psi_2$ is physical

I built the pure types by setting the relevant $\Psi$ to $+1$, because it is the obvious normalisation and it does not change the Petrov type.

It does, however, change the sign of $E$. With $\Psi_2 = +1$ you get $E = \mathrm{diag}(+2,-1,-1)$, and the dust cloud squeezes radially while stretching sideways.

I rendered an anti-spaghettifying black hole and did not notice for a full day.

The physical black hole has $\Psi_2 = -M/r^3 < 0$. The sign is not a normalisation. It is which way the tide pulls.

### The renders

![btop during a Blender render (M3 Pro, GPU at 96%, 14G/18G](/images/btopBlender.png)

The Blender scripts do the physics in numpy and hand Blender nothing but geometry and keyframes. This is deliberate. `petrov_core.py` runs standalone and is checked against the Mathematica exports *before* a single frame is rendered, so if the physics is wrong I find out in two seconds rather than after twenty minutes of Eevee.

That discipline paid for itself several times over. It also did not stop the M3 Pro from becoming a small radiator.

Eevee on Metal, 1080p, 240 frames at roughly 1.3 seconds each, five sequences. The GPU sat pinned at 96%, 14 of 18 gigabytes of unified memory in use, and my laptop developed a warm patch above the function keys that I could feel through the keyboard. The fans on this machine are usually a rumour. They were not a rumour that evening.

![Blender writing out the peeling frames](/images/blenderRender.png)

There is something quietly absurd about the fact that the *physics* — a generic Weyl tensor, a Jordan classification, six exact solutions, a symbolic MPD derivation — costs milliseconds, and then drawing four orange dots on a translucent sphere costs twenty minutes and a hot laptop. The hard part was never the hard part.

{{< details summary="And a paragraph of pure toolchain complaining, which you may skip" >}}

Blender's Python API renamed the EEVEE render engine identifier from `BLENDER_EEVEE` to `BLENDER_EEVEE_NEXT` in 4.2, and then **back to `BLENDER_EEVEE`** in 5.1 once EEVEE Next became the only EEVEE. So hardcoding any one of the three strings is wrong on the other two. The fix is to ask the enum what it accepts:

```python
avail = {i.identifier for i in
         bpy.types.RenderSettings.bl_rna.properties['engine'].enum_items}
```

Then 4.4 moved F-curves out of `action.fcurves` and into `action.layers[].strips[].channelbags[].fcurves` as part of the slotted-actions rework, and 5.x removed the old accessor entirely, so it raises rather than returning empty.

Both of these are in `bpy_compat.py` in the repo. Neither taught me anything about general relativity. I include them only so that the next person who runs the scripts on whatever Blender exists by then has somewhere to start.

{{< /details >}}

## What I Am Not Telling You

The animations are geodesic deviation **in a local Lorentz frame**: a small sphere, a short proper time, and $E$ held constant. That is a linearised picture of a violently nonlinear object. A real cloud of dust falling into a real black hole does not experience a frozen tidal tensor, and the ellipsoid picture stops being trustworthy long before anything interesting happens.

$\Psi_0$ and $\Psi_4$ are **tetrad-dependent**. They carry boost weights $+2$ and $-2$, so a boosted observer reads different numbers. $\Psi_2$ has boost weight zero and is safe — which is why the Schwarzschild and Kerr results here agree exactly with Part II despite the two notebooks using different tetrads, and why the pp-wave and Kasner $u=2$ numbers do *not* agree, and should not. The **type** is invariant. The numbers are not. I spent an afternoon convinced I had a bug when what I had was a boost.

Types II and III still have no metric in this series. Their tides are pure-$Q$ constructions. I would rather show you an honest point in the space of Weyl tensors than a dishonest spacetime.

## The Tide Is the Type

I started this series because a tutorial exercise on the Riemann tensor's independent components annoyed me, and I have ended it watching a laptop GPU sweat over four orange dots that are, in the most literal sense, the answer to "what does a Petrov type mean".

Here is what I think the whole thing was actually about.

There is a way of doing physics where you compute a classification, put it in a table, and move on. Part II did that, and Part II was *right*, and Part II was not finished. Because a classification with nothing on the other end of it is bookkeeping. The moment you ask what the six types **do** — what they do to a body, to a ring of dust, to a spinning top — the classification stops being a taxonomy and starts being a set of predictions.

Type D says: you will be stretched one way and squeezed two, in a 2:1 ratio, forever, and if the thing you are falling into is spinning then your gyroscopes will drift and your dust will not.

Type N says: nothing happens along the direction of travel, and everything happens across it, and the invariants that usually tell you about curvature will tell you nothing at all, because a null field has no invariants to tell.

Type III says: something happens along the direction of travel, and you have no intuition for it, and you never will, because nothing in Newtonian gravity does that.

And the reason the classification has exactly six entries is that a $3\times3$ traceless complex matrix has exactly six Jordan forms. The reason the Weyl tensor splits into a tide and a twist is that the self-dual bivectors form a 3-dimensional complex space. The reason gravitational radiation obeys $|E| = |B|$, $E \perp B$ is that a null field is a null field whether the gauge group is $U(1)$ or the diffeomorphisms.

None of that is a metaphor for anything. It is all the same object, and the only thing that changes between Part I and Part III is how far around it I managed to walk.

Half the Weyl tensor is invisible to dust. It took a gyroscope, a Jordan form, and a very warm laptop to see the other half.

---

*All computations were performed on an M3 Pro MacBook Pro. Mathematica 14.3 for the symbolic work; the Part III notebook uses no `xAct` at all, deliberately, so that the Part II notebook (which does) serves as an independent cross-check rather than a shared point of failure. The two agree to machine precision. Blender 5.1 with Eevee on Metal for the renders. Everything is in the repository, including the mistakes.*

## Artifacts

- **`petrov_q.wl`** — the Part III notebook. Proves the $Q = E + iB$ dictionary on a generic Weyl tensor, derives the MPD spin-curvature force, runs all six metrics, exports `petrov_tides.json`. No `xAct`. [Download](/downloads/petrov_q.wl)
- **`petrov_classification.wl`** — the Part II notebook, for comparison. [Download](/downloads/petrov_classification.wl)
- **`petrov_viz`** — the visualisation repository: `petrov_core.py` (physics, pure numpy, no Blender), `validate_core.py`, and the two `bpy` scripts. [codeberg.org/abksh/petrov_viz](https://codeberg.org/abksh/petrov_viz)

Full-resolution renders (the inline GIFs above are compressed for the page):

- [PNDs colliding — Kasner sweep](/downloads/pnd_kasner.mp4)
- [PNDs colliding — the synthetic ladder](/downloads/pnd_ladder.mp4)
- [PNDs colliding — peeling](/downloads/pnd_peeling.mp4)
- [Tides of the five Petrov types](/downloads/tides_types.mp4)
- [Dust versus gyroscopes: Schwarzschild and Kerr](/downloads/tides_gyro.mp4)

[^szekeres]: P. Szekeres, "The Gravitational Compass", *Journal of Mathematical Physics* **6**, 1387 (1965). DOI: [10.1063/1.1704788](https://doi.org/10.1063/1.1704788). The paper that assigns physical roles to the five Weyl scalars, and the source of the "compass" of test masses and dynamometers.

[^mpd]: M. Mathisson, *Acta Physica Polonica* **6**, 163 (1937); A. Papapetrou, *Proceedings of the Royal Society A* **209**, 248 (1951); W. G. Dixon, *Proceedings of the Royal Society A* **314**, 499 (1970). The spin-curvature force is usually written $\frac{Dp_a}{d\tau} = -\tfrac{1}{2} R_{abcd} u^b S^{cd}$; I derived the frame form $F^i = -B^{ij}S_j$ symbolically rather than adopt anyone's sign conventions.

[^costa]: L. F. Costa and C. A. R. Herdeiro, "Gravitoelectromagnetic analogy based on tidal tensors", *Physical Review D* **78**, 024021 (2008). DOI: [10.1103/PhysRevD.78.024021](https://doi.org/10.1103/PhysRevD.78.024021). The cleanest statement I have found of what the gravitomagnetic tidal tensor does and does not do, including the observation that the force on a gyroscope is purely spatial.

[^lk]: E. M. Lifshitz and I. M. Khalatnikov, "Investigations in relativistic cosmology", *Advances in Physics* **12**, 185 (1963). The $u$-parametrisation of the Kasner exponents. Kasner is Bianchi type I; see Nastase Ch. 32.

[^sachs]: R. K. Sachs, "Gravitational waves in general relativity VIII. Waves in asymptotically flat space-time", *Proceedings of the Royal Society A* **270**, 103 (1962). The peeling theorem.

[^pirani]: F. A. E. Pirani, "On the physical significance of the Riemann tensor", *Acta Physica Polonica* **15**, 389 (1956). The paper that first insisted the Riemann tensor be interpreted through geodesic deviation rather than admired as geometry — which is, more or less, this entire post's thesis, written seventy years ago.

[^nastase]: H. Nastase, *General Relativity: A Graduate Course*, Cambridge University Press (2025). Ch. 30 (Newman–Penrose), Ch. 31 (the Petrov classification), Ch. 32 (Bianchi classification). DOI: [10.1017/9781009575737](https://doi.org/10.1017/9781009575737).

[^exact]: H. Stephani, D. Kramer, M. MacCallum, C. Hoenselaers and E. Herlt, *Exact Solutions of Einstein's Field Equations*, 2nd ed., Cambridge University Press (2003), §4 and §9. The reference for everything in the table, and the source of the observation that the Petrov type is a statement about symmetry rather than about black holes.

[^kerr]: R. P. Kerr, "Gravitational Field of a Spinning Mass as an Example of Algebraically Special Metrics", *Physical Review Letters* **11**, 237 (1963). The title remains the whole point.

[^xact]: J. M. Martín-García, *xAct: Efficient tensor computer algebra for Mathematica*. [xact.es](http://www.xact.es/). Used in Part II; deliberately not used in Part III.
