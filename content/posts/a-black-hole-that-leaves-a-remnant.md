+++
date = '2026-11-01T12:00:00+02:00'
draft = false
title = 'A Black Hole That Leaves a Remnant'
useAlpine = false
tags = [
    "research-workflow",
    "asymptotic-safety",
    "quantum-gravity",
    "reuter-fixed-point",
    "bonanno-reuter",
    "black-holes",
    "quadratic-gravity",
    "bach-tensor",
    "general-relativity",
    "mathematica",
    "cognee",
    "claude-code",
]
+++

I just worked through a small piece of quantum gravity end to end — the asymptotic-safety story of how a black hole might lose its singularity — and I want to use it to answer a question I get asked a lot and usually dodge: *what, exactly, does the AI do?*

The honest answer is not "it does the physics." It can't, not reliably. The honest answer is that I have spent a while building a workbench whose entire purpose is to let a confident, fast, frequently-wrong assistant do the mechanical parts while every load-bearing claim gets checked by something that doesn't lie. This post is that workbench, shown on a real problem, with an honest accounting of which parts were my thinking and which the machine genuinely sped up.

{{< notice note >}}

**Two audiences.** If you're here for the physics, the tooling sections explain themselves — skip to [the computation](#what-antiscreening-is). If you're here for the workflow, the physics is the thing being verified; the one idea to hold onto is that a language model is a liar with excellent diction, so the whole rig is built around verification instead of trust.

{{< /notice >}}

## What Antiscreening Is

In QED the vacuum *screens* charge: virtual pairs cluster around an electron, so you measure a weaker charge far away and a stronger one up close. Gravity, in the asymptotic-safety picture, does the opposite. Newton's "constant" runs with scale, and it runs the *antiscreening* way — gravity gets **weaker** at short distance. Follow that running up to arbitrarily high energy and the dimensionless couplings don't blow up; they approach a fixed point, and the theory stays predictive all the way to the UV. That's Weinberg's asymptotic safety, and the fixed point in the simplest truncation is the **Reuter fixed point**.

The project I'll draw from — I called it `antiscreen` — reproduces this story from the *Handbook of Quantum Gravity* chapters by Saueressig and Platania, in Mathematica, in Planck units ($G_0 = \hbar = c = 1$). Start with the flow itself. For the dimensionless couplings $g = G_k k^2$ and $\lambda = \Lambda_k/k^2$, the Einstein–Hilbert truncation with the optimised regulator gives a non-Gaussian fixed point. The machine found it, and these are the actual numbers:

$$g_* = 0.707, \qquad \lambda_* = 0.193, \qquad g_*\lambda_* = 0.137,$$
$$\theta = 1.48 \pm 3.04\,i, \qquad \eta_N\big|_* = -2.$$

The critical exponents $\theta$ come as a complex-conjugate pair with **positive real part** — positive means UV-attractive, and the imaginary part means trajectories *spiral* into the fixed point rather than running straight in. You can see the whole flow:

![Phase diagram of the RG flow in the (lambda, g) plane: streamlines with three trajectories spiralling into the red Reuter fixed point near (0.19, 0.71), and the Gaussian fixed point at the origin.](/images/antiscreen/phase-diagram.png)

*The flow in the $(\lambda, g)$ plane, arrows pointing toward the UV. Each trajectory starts in the classical regime and spirals into the Reuter fixed point (red); the Gaussian fixed point sits at the origin (black). Our universe lives on a trajectory with $G_0\Lambda_0 \sim 10^{-120}$, hugging the origin before it turns up.*

One consequence is quietly spectacular. The graviton anomalous dimension hits $\eta_N = -2$ at the fixed point, which makes the propagator go like $1/p^{2-\eta_N} = 1/p^4$, and a diffusing test particle then sees a **spectral dimension** of 2 instead of 4. Spacetime looks four-dimensional in the lab and two-dimensional at the Planck scale:

![Spectral dimension along a trajectory, running smoothly from 4 in the classical regime down to 2 at the fixed point.](/images/antiscreen/spectral-dimension.png)

*Dimensional reduction: $d_s = 2d/(2-\eta_N)$ runs from 4 to 2 as the trajectory climbs to the fixed point.*

## Resolving the Singularity

Now the payoff, and the part that's genuinely fun to compute. If $G$ weakens at short distance, then deep inside a black hole — where curvature is huge and the relevant scale $k$ is enormous — gravity is weaker than Schwarzschild assumed. RG-improving the metric (Bonanno–Reuter, as laid out in Platania's chapter) replaces $G_0$ with a running $G(r)$ and gives a lapse

$$f(r) = 1 - \frac{2mG(r)}{r}, \qquad G(r) = \frac{2r^3}{2r^3 + w(2r + 9m)},$$

with a single free parameter $w = 41/(10\pi) \approx 1.31$, fixed by matching the long-range correction to the Newton potential. Four things fall out, and I believed none of them until the machine produced each one and it passed a check I already trusted.

**The singularity is gone.** Near $r = 0$ the lapse is not Schwarzschild's $1 - 2m/r$ but de Sitter, $f \approx 1 - \tfrac{1}{3}\Lambda_{\text{eff}} r^2$ with $\Lambda_{\text{eff}} = 4/(3w) \approx 1.02$. A regular core instead of a point of infinite density.

![The lapse f(r) for several masses, each with a regular minimum, versus the Schwarzschild curve that plunges to minus infinity.](/images/antiscreen/lapse.png)

*The improved lapse for $m = 1,\ m_{\text{crit}},\ 4,\ 8$, against Schwarzschild ($m=8$, dashed). Below the critical mass there's no horizon at all.*

**There's a critical mass.** The horizon condition $f = 0$ is linear in $m$, so the horizon radius parametrises the mass, and $m(r_h)$ has a minimum: the **critical mass** $m_{\text{crit}} = 2.53$ at $r_{\text{crit}} = 3.24$, where the inner and outer horizons merge. Lighter objects never form a horizon.

**It ends cold.** The Hawking temperature $T_H = f'(r_h)/4\pi$ rises, peaks at $T_{\max} = 0.0092$ (near $m \approx 3.26$), and then *falls to zero* at the critical mass. A Schwarzschild hole runs away to infinite temperature as it shrinks; this one cools and stalls, leaving a cold Planck-mass remnant.

![Hawking temperature versus mass: the Bonanno-Reuter curve rises to a peak then drops to zero at the critical mass, unlike the Schwarzschild 1/(8 pi m) curve that diverges.](/images/antiscreen/temperature.png)

*Temperature against mass. The remnant is the point where the curve meets the axis — a black hole that can't finish evaporating.*

![Evaporation in time: the Bonanno-Reuter mass settles onto the critical-mass plateau while the Schwarzschild mass reaches zero in finite time.](/images/antiscreen/evaporation.png)

*Mass loss under a crude Stefan–Boltzmann law. Schwarzschild reaches zero; the improved hole stalls at $m_{\text{crit}}$.*

**The curvature stays finite.** Using the closed-form Kretschmann scalar (more on that function in a moment), the centre gives

$$\lim_{r\to 0} K = \frac{12800\,\pi^2}{45387} = \frac{8\Lambda_{\text{eff}}^2}{3},$$

the de Sitter value — exactly, symbolically — instead of Schwarzschild's $48m^2/r^6$ blowing up.

![Log-log plot of the Kretschmann scalar: Bonanno-Reuter flattens to a finite plateau at small r while Schwarzschild diverges as 1/r^6.](/images/antiscreen/kretschmann.png)

*Kretschmann scalar for $m = 10$. The improved core is finite; Schwarzschild diverges.*

One more number worth having. The first-law entropy $S = \int dm/T$, written as an integral over horizon radius, is the area law $\pi r_h^2$ plus corrections — and one of those is a **logarithmic** term $c \ln r_h$, with coefficient $c = 45.1$ here. Logarithmic corrections to black-hole entropy turn up across quantum-gravity approaches, so it's a small pleasure to watch one fall out of this toy improvement too.

![Entropy minus the area law, growing like c times log of the horizon radius, closely tracking the fitted logarithmic curve.](/images/antiscreen/entropy.png)

*The entropy with its area-law part subtracted, against $c\ln(r_h/r_{\text{crit}})$ — a clean logarithmic correction.*

There's a price, and it's the honest kind. A regular core has to violate an energy condition — the Hawking–Penrose singularity theorem assumes the strong energy condition, so dodging the singularity means breaking it. Reading Einstein's equations backwards turns the improved metric into an effective anisotropic fluid with

$$\rho = \frac{M'}{4\pi r^2}, \qquad p_r = -\rho, \qquad p_t = -\frac{M''}{8\pi r},$$

and the SEC combination $\rho + p_r + 2p_t \propto -M''$ does indeed go negative — here for $r < 3.12$, inside the outer horizon at $r = 19.8$. The theorem isn't violated; its hypothesis is.

![Energy-condition combinations times r-squared: the null/weak combination stays positive but the strong-energy combination dips negative inside the horizon.](/images/antiscreen/energy-conditions.png)

*The effective matter ($m = 10$). NEC/WEC hold; the SEC combination goes negative in the core, which is exactly what a regular centre requires.*

## The Rig, and Why Every Piece Exists to Keep the Machine Honest

None of the above is new physics — it's me working carefully through known results to learn them properly, which is most of what research actually is. Here's the workbench that made it fast without making it untrustworthy. Everything runs through [Claude Code](https://claude.com/claude-code).

**Cognee for grounded context.** The two *Handbook of Quantum Gravity* chapters, the exact-solutions references, and — most importantly — my own pinned conventions (signature $(-,+,+,+)$, MTW signs, index ordering) live in a self-hosted [Cognee](https://www.cognee.ai/) knowledge store, reachable as an MCP server. When I ask a question, the relevant passages get retrieved and put in front of the model, so its answer is anchored to the actual chapter instead of to the average of the internet. The failure it fixes is drift and invention: without it, a long session slowly detaches from the book and starts answering from half-remembered training data; with it, a recall returns the real passage, provenance line and all.

**cognee-ingest for getting the books in.** Those chapters are PDFs, and getting a maths-heavy PDF into Cognee with equations intact is not a drag-and-drop, so it's its own small service in my k3s cluster. A [docling](https://github.com/docling-project/docling) worker converts the PDF 20 pages at a time — equations become LaTeX so they're searchable *as maths*, every figure is cropped and stored by hash with its caption as alt text, scans get OCR. A splitter cuts the markdown into ≤8 KB chunks with provenance headers and a guarantee that the pieces reassemble the original exactly. A durable queue cognifies one document at a time, and a proxy makes sure that when I'm actually working, my interactive tool calls preempt the bulk ingest. The library loads itself in the background and never gets in the way of the foreground thinking.

**Mathematica as the ground truth — and no xAct this time.** This is where the real danger is, because a wrong tensor contraction looks exactly like a right one. My usual reach for abstract index work is [xAct](http://www.xact.es/); here the metrics are explicit matrices, so I did something more transparent — a roughly thirty-line curvature toolkit, Christoffel → Riemann → Ricci → Weyl → Bach, built on plain `D[]` and matrix algebra. The advantage of small and explicit is that you can read the whole engine. The danger is that you wrote it yourself, so the *first* thing in the file is a check: the toolkit computes the Kretschmann scalar of a general static lapse, and compares it to the closed form I already know it should be,

$$K = F''^2 + \frac{4F'^2}{r^2} + \frac{4(1-F)^2}{r^4}.$$

The difference came back `0`. Only after that did I trust a single number the toolkit produced. (The same Kretschmann function is what later gives the exact de Sitter-core value above — one verified tool, reused.) When the algebra gets abstract or index-heavy enough that an explicit toolkit stops being readable, that's when xAct earns its place; the principle is the same either way — **the model does not do the tensor algebra, it drives something that does, and I check the something against a known result before I believe it.**

## What's Mine, What's the Machine's

Here's the ledger, as honestly as I can draw it.

**Where the machine genuinely sped me up.** Boilerplate that is tedious but not deep: the curvature toolkit's scaffolding, the Fourier dictionary that turns the one-loop amplitude's non-analytic pieces into position-space potential terms, translating conventions between two chapters that don't quite agree, and recall over the ingested corpus far faster than flipping PDFs. Turning "compute the Bach tensor of a general static metric and check it's traceless" from an afternoon into a few minutes. This is real acceleration and I won't pretend otherwise.

**Where it lied, or where I had to go check.** The potential calibration is the cleanest example. The $1/r^3$ correction in the lapse has to be matched to the one-loop quantum correction — but that coefficient is *not* unique: it depends on whether you read it off the scattering potential or the one-loop-corrected metric, and on the gauge. The two give different $w$:

$$w_{\text{scattering}} = \frac{41}{10\pi} \approx 1.31, \qquad w_{\text{one-loop metric}} = \frac{31}{15\pi} \approx 0.66,$$

with even the *sign* of the comparison flipping between conventions. The code carries a note to myself in plain sight — *check the coefficient against the paper before relying on it* — because this is exactly the kind of thing a confident model will hand you with no warning label. Catching it was not the machine's doing.

And the subtler cost, the one that actually eats time: a derivation that *reads* perfectly and quietly drops a sign. One of mine put the wrong sign on the $p_t$ component of the effective stress tensor — beautifully typeset, completely wrong. The backward-Einstein reading caught it, but only because I'd already decided not to trust the hand version over the toolkit. A convention error never throws an exception; it just hands you the wrong answer in nice fonts.

**Where the thinking was mine, and only mine.** Choosing to chase the regular-core story at all. Knowing, before any algebra, that a non-singular centre *must* break the strong energy condition — so that when the SEC combination went negative, it read as confirmation rather than alarm. Every smell-test: does the core go de Sitter, does Schwarzschild fall out in the right limit, is the Bach tensor traceless as it must be. And the decision, upstream of everything, to build a toolkit I could verify instead of trusting one I couldn't. The machine cannot tell a profound result from a sign error; both look equally plausible to it. That discrimination is the job, and it stays with me.

## Which Solutions Survive Quadratic Gravity

One more computation, because it closes a loop with where I thought this essay was going before I did the work. Add curvature-squared terms to the action,

$$S = \int d^4x\ \sqrt{-g}\ \left( R + \alpha R^2 + \beta\ C^2 \right),$$

and the field equations pick up the **Bach tensor** $B_{ab} = \nabla^c\nabla^d C_{acbd} + \tfrac{1}{2}R^{cd}C_{acbd}$ (from $C^2$) plus terms from $R^2$. So any Einstein metric with vanishing Bach tensor solves the quadratic theory *unchanged*. The toolkit computes $B$ for a general static spherical metric, confirms it's traceless (it must be: `0`), and then specialises:

- **Schwarzschild**: $B_{ab} = 0$ — survives.
- **Schwarzschild–de Sitter**: $B_{ab} = 0$ — survives.
- **Bonanno–Reuter**: $B_{ab} \neq 0$ — the regular black hole does *not* solve quadratic gravity unchanged.
- **pp-waves**: the only Ricci component is $R_{uu} \propto \nabla^2_\perp H$, all scalar invariants vanish, and the Bach tensor of a harmonic profile is zero — a first step toward why vacuum pp-waves solve essentially any curvature theory ("universal" spacetimes).

That's the quadratic-gravity thread as a supporting act, which is where it belongs; the weight of the work is the asymptotic-safety side.

## The Part That Doesn't Exist Yet: Jenkins

As these computations get heavier, there's more than one way to compute a given object — different strategies, abstract versus component, different simplification paths — and "which is actually most effective" becomes a real question: fastest, most memory-frugal, least prone to a `Simplify` blowing up. That's a benchmarking problem, and benchmarking is what CI is for. The sketch is [Jenkins](https://www.jenkins.io/) (already running in my homelab, already building `cognee-ingest`) running each candidate algorithm across a parameter sweep and recording time, memory, and stability, so the choice of method has a data answer instead of a vibe. The pipelines aren't written yet. When they are, that's its own post.

## The Notebook

Everything above is reproducible. The Mathematica notebook is [here](/downloads/antiscreen.wl) — a `.wl` file, which is plain text and version-controllable; open it in Mathematica and it renders as a structured notebook with foldable sections. Like the Petrov Part III notebook, it uses no `xAct` at all: the thirty-line curvature toolkit is the whole engine, and the Kretschmann control cell at the top of it is the reason I trust everything below.

## Why the Workbench

There's a fair objection to all of this: it's a lot of infrastructure around a set of textbook reproductions. True. But the point of reproducing known results carefully is to build the judgement you'll need for the unknown ones, and the point of the workbench is that it lets me move fast through the mechanical parts *without* surrendering that judgement to a machine that doesn't have it. The AI wrote a lot of the code here. It did not decide what was worth computing, and it did not get to say what was true. Those stayed mine — and the rig is what makes it safe to keep them mine while still going quickly.
