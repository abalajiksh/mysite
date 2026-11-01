(* ::Package:: *)

(* ::Title:: *)
(*Antiscreen*)

(* ::Text:: *)
(*Quick quantum-gravity calculations: the Reuter fixed point, an RG-improved black hole, the one-loop Newton potential, energy conditions of the effective matter, and which exact solutions survive quadratic gravity.*)

(* ::Text:: *)
(*Sources: F. Saueressig, "The Functional Renormalization Group in Quantum Gravity", and A. Platania, "Black Holes in Asymptotically Safe Gravity", both in Bambi, Modesto and Shapiro (eds.), Handbook of Quantum Gravity (Springer, 2024). Stephani et al., Exact Solutions of Einstein's Field Equations, 2nd ed., section 5.3 (energy conditions). Griffiths and Podolsky, Exact Space-Times, ch. 17 (pp-waves). Bjerrum-Bohr, Donoghue and Holstein, PRD 67, 084033 (2003) (one-loop potential). Units: G0 = hbar = c = 1, so lengths and masses are in Planck units.*)

(* ::Section:: *)
(*0. Curvature toolkit*)

(* ::Text:: *)
(*Minimal tensor code for 4D metrics given as matrices. riemann returns R^a_bcd; everything else has all indices down unless its name says otherwise. Signature (-,+,+,+), MTW sign conventions.*)

christoffel[g_, x_] := With[{gi = Inverse[g], n = Length[x]},
  Table[Simplify[1/2 Sum[gi[[a, d]] (D[g[[d, b]], x[[c]]] + D[g[[d, c]], x[[b]]] - D[g[[b, c]], x[[d]]]), {d, n}]], {a, n}, {b, n}, {c, n}]];
riemann[g_, x_] := With[{G = christoffel[g, x], n = Length[x]},
  Table[Simplify[D[G[[a, b, d]], x[[c]]] - D[G[[a, b, c]], x[[d]]] + Sum[G[[a, c, e]] G[[e, b, d]] - G[[a, d, e]] G[[e, b, c]], {e, n}]], {a, n}, {b, n}, {c, n}, {d, n}]];
ricci[g_, x_] := Simplify[TensorContract[riemann[g, x], {{1, 3}}]];
ricciScalar[g_, x_] := Simplify[Tr[Inverse[g] . ricci[g, x]]];
einsteinMixed[g_, x_] := Simplify[Inverse[g] . (ricci[g, x] - 1/2 ricciScalar[g, x] g)];
raiseAll[t4_, gi_] := Module[{s = t4 . gi},
  s = Transpose[Transpose[s, {1, 2, 4, 3}] . gi, {1, 2, 4, 3}];
  Transpose[Transpose[s, {1, 4, 3, 2}] . gi, {1, 4, 3, 2}]];
kretschmann[g_, x_] := With[{R = riemann[g, x]}, Simplify[Total[Flatten[(g . R) raiseAll[R, Inverse[g]]]]]];
weylDown[g_, x_] := Module[{R = riemann[g, x], Rd, Ric, Rs},
  Rd = g . R; Ric = TensorContract[R, {{1, 3}}]; Rs = Tr[Inverse[g] . Ric];
  Simplify@Table[Rd[[a, b, c, d]] - 1/2 (g[[a, c]] Ric[[b, d]] - g[[a, d]] Ric[[b, c]] - g[[b, c]] Ric[[a, d]] + g[[b, d]] Ric[[a, c]]) + Rs/6 (g[[a, c]] g[[b, d]] - g[[a, d]] g[[b, c]]), {a, 4}, {b, 4}, {c, 4}, {d, 4}]];
(* covariant derivative of an all-lower tensor; the new index comes first *)
covD[T_, g_, x_] := Module[{G = christoffel[g, x], k = ArrayDepth[T], n = Length[x]},
  Table[D[T, x[[e]]], {e, n}] - Sum[Transpose[TensorContract[TensorProduct[G, T], {{1, 3 + i}}], Join[{1, 1 + i}, Range[2, i], Range[i + 2, k + 1]]], {i, k}]];
bach[g_, x_] := Module[{gi = Inverse[g], weyl, ddw, ricUp},
  weyl = weylDown[g, x];
  ddw = covD[covD[weyl, g, x], g, x];
  ricUp = gi . ricci[g, x] . gi;
  Simplify@Table[Sum[gi[[c, e]] gi[[d, f]] ddw[[e, f, a, c, b, d]], {c, 4}, {d, 4}, {e, 4}, {f, 4}] + 1/2 Sum[ricUp[[c, d]] weyl[[a, c, b, d]], {c, 4}, {d, 4}], {a, 4}, {b, 4}]];
sph[F_] := DiagonalMatrix[{-F, 1/F, r^2, r^2 Sin[th]^2}];
xs = {t, r, th, ph};

(* ::Text:: *)
(*Sanity check: for a general static lapse F(r) the Kretschmann scalar should be F''^2 + 4 F'^2/r^2 + 4 (1 - F)^2/r^4.*)

Kgen = kretschmann[sph[F[r]], xs];
Simplify[Kgen - (F''[r]^2 + 4 F'[r]^2/r^2 + 4 (1 - F[r])^2/r^4)]

(* ::Section:: *)
(*1. The Reuter fixed point (Einstein-Hilbert truncation)*)

(* ::Text:: *)
(*Beta functions for the dimensionless couplings g = G_k k^2 and lambda = Lambda_k/k^2 with the optimised (Litim) regulator, as given in Saueressig's chapter. t = ln k, so the flow runs towards the UV as t grows.*)

bB1[l_] := 1/(3 Pi) (5/(1 - 2 l) - 9/(1 - 2 l)^2 - 7);
bB2[l_] := -1/(12 Pi) (5/(1 - 2 l) - 6/(1 - 2 l)^2);
etaN[g_, l_] := g bB1[l]/(1 - g bB2[l]);
betaG[g_, l_] := (2 + etaN[g, l]) g;
betaL[g_, l_] := (etaN[g, l] - 2) l + g/(12 Pi) (30/(1 - 2 l) - 24 - 5 etaN[g, l]/(1 - 2 l));

(* ::Text:: *)
(*The non-Gaussian fixed point and its critical exponents theta = -eig(stability matrix). A positive real part is a UV-attractive (relevant) direction; the complex pair means trajectories spiral into the fixed point.*)

fp = FindRoot[{betaG[g, l] == 0, betaL[g, l] == 0}, {{g, 0.7}, {l, 0.2}}];
{gStar, lStar} = {g, l} /. fp;
theta = -Eigenvalues[D[{betaG[g, l], betaL[g, l]}, {{g, l}}] /. fp];
<|"g*" -> gStar, "lambda*" -> lStar, "g* lambda*" -> gStar lStar, "theta" -> theta, "eta_N at FP" -> etaN[gStar, lStar]|>

(* ::Subsection:: *)
(*Phase diagram and trajectories*)

(* ::Text:: *)
(*Arrows point towards the UV. Each trajectory starts in the classical regime, g = 10^-2 with g lambda = G0 Lambda0 fixed, and is integrated both ways: towards the UV it spirals into the Reuter fixed point (red); towards the IR it runs into the lambda -> 1/2 singularity of this truncation. Smaller G0 Lambda0 brings the trajectory closer to the Gaussian fixed point (black); our universe has G0 Lambda0 ~ 10^-120.*)

traj[gl_] := NDSolve[{g'[t] == betaG[g[t], l[t]], l'[t] == betaL[g[t], l[t]], g[0] == 1/100, l[0] == 100 gl,
    WhenEvent[l[t] > 0.45 || 1 - g[t] bB2[l[t]] < 0.05, "StopIntegration"]}, {g, l}, {t, -20, 20}];
sols = traj /@ {10^-3, 10^-4, 10^-5};
dom[s_] := First[(g /. First[s])["Domain"]];
stream = StreamPlot[{betaL[g, l], betaG[g, l]}, {l, -0.3, 0.48}, {g, -0.2, 1.0},
   RegionFunction -> Function[{l, g}, Abs[1 - g bB2[l]] > 0.05], StreamStyle -> GrayLevel[0.7], FrameLabel -> {"lambda", "g"}];
Show[stream,
 Sequence @@ Table[ParametricPlot[Evaluate[{l[t], g[t]} /. First[sols[[i]]]], Evaluate[Flatten[{t, dom[sols[[i]]]}]], PlotStyle -> Directive[Thick, ColorData[97][i]]], {i, 3}],
 Graphics[{PointSize[Large], Red, Point[{lStar, gStar}], Black, Point[{0, 0}]}],
 PlotRange -> {{-0.3, 0.48}, {-0.2, 1.0}}]

(* ::Subsection:: *)
(*Spectral dimension along a trajectory*)

(* ::Text:: *)
(*With the graviton propagator going like 1/p^(2 - eta_N), a diffusing test particle sees d_s = 2d/(2 - eta_N): 4 in the classical regime, 2 at the fixed point where eta_N = -2.*)

With[{s = First[sols[[3]]], d = dom[sols[[3]]]},
 Plot[Evaluate[8/(2 - etaN[g[t], l[t]]) /. s], {t, d[[1]], d[[2]]}, PlotRange -> {0, 5}, AxesLabel -> {"t = ln k", "d_s"}, GridLines -> {None, {2, 4}}]]

(* ::Section:: *)
(*2. The Bonanno-Reuter black hole*)

(* ::Text:: *)
(*RG improvement replaces G0 by G(k) = G0/(1 + G0 k^2/g_star) with k = xi/D(r), D the radial proper distance. Platania's chapter gives the resulting lapse; w = xi^2/g_star is its one free parameter. Following the chapter, w = 41/(10 pi), chosen so the large-r expansion matches the size of the one-loop correction to the Newton potential. Bonanno and Reuter originally used 118/(15 pi).*)

w = 41/(10 Pi);
Gr[r_, m_] := 2 r^3/(2 r^3 + w (2 r + 9 m));
fBR[r_, m_] := 1 - 2 m Gr[r, m]/r;
Simplify[fBR[r, m]]

(* ::Text:: *)
(*Near r = 0 the metric is de Sitter with Lambda_eff = 4/(3 w); far away it is Schwarzschild plus a 1/r^3 correction.*)

{Normal@Series[fBR[r, m], {r, 0, 2}], -3 Coefficient[Normal@Series[fBR[r, m], {r, 0, 2}], r, 2] == 4/(3 w), Normal@Series[fBR[r, m], {r, Infinity, 3}]}

(* ::Text:: *)
(*f = 0 is linear in m, so the horizon radius parametrises the mass. The minimum of m(r_h) is the critical mass where the outer and inner horizons merge; lighter objects have no horizon at all.*)

mOfR[r_] = Simplify[m /. First@Solve[fBR[r, m] == 0, m]];
{rCrit, mCrit} = Module[{s = FindMinimum[mOfR[r], {r, 3}]}, {r /. s[[2]], s[[1]]}];
<|"m(r_h)" -> mOfR[rh], "r_crit" -> rCrit, "m_crit" -> mCrit|>

Plot[Evaluate[Append[Table[fBR[r, mm], {mm, {1, mCrit, 4, 8}}], 1 - 16/r]], {r, 0.01, 25}, PlotRange -> {-1.5, 1.1},
 PlotStyle -> {ColorData[97][1], ColorData[97][2], ColorData[97][3], ColorData[97][4], Directive[Gray, Dashed]},
 PlotLegends -> {"m = 1", "m = m_crit", "m = 4", "m = 8", "Schwarzschild, m = 8"}, AxesLabel -> {"r", "f(r)"}]

(* ::Subsection:: *)
(*Temperature, remnant and entropy*)

(* ::Text:: *)
(*T_H = f'(r_h)/(4 pi). It vanishes at m_crit, so the hole cools as it shrinks instead of heating up.*)

TofR[rh_] = Simplify[(D[fBR[r, m], r] /. m -> mOfR[r]) /. r -> rh]/(4 Pi);
<|"T at r_crit" -> Chop[TofR[rCrit]], "T_max" -> First@FindMaximum[TofR[r], {r, 4}], "m at T_max" -> mOfR[r /. Last@FindMaximum[TofR[r], {r, 4}]]|>

ParametricPlot[{{mOfR[r], TofR[r]}, {mOfR[r], 1/(8 Pi mOfR[r])}}, {r, rCrit, 40}, AspectRatio -> 0.6, PlotRange -> {{0, 20}, {0, 0.03}},
 AxesLabel -> {"m", "T_H"}, PlotLegends -> {"Bonanno-Reuter", "Schwarzschild 1/(8 pi m)"}]

(* ::Text:: *)
(*First-law entropy S = Integral dm/T, written as an integral over the horizon radius. At large r_h the integrand is 2 pi r_h plus corrections; a 1/r_h term in it becomes a logarithmic correction c ln r_h to the area law.*)

integrand[rh_] = Simplify[mOfR'[rh]/TofR[rh]];
{Normal@Series[integrand[rh], {rh, Infinity, 1}], cLog = SeriesCoefficient[integrand[rh], {rh, Infinity, 1}]}

entropy[rh_?NumericQ] := NIntegrate[integrand[x], {x, rCrit, rh}];
Plot[{entropy[rh] - Pi (rh^2 - rCrit^2), cLog Log[rh/rCrit]}, {rh, rCrit + 0.01, 30},
 PlotLegends -> {"S - pi (r_h^2 - r_crit^2)", "c ln (r_h/r_crit)"}, AxesLabel -> {"r_h", ""}]

(* ::Subsection:: *)
(*Evaporation*)

(* ::Text:: *)
(*Stefan-Boltzmann mass loss dm/dt = -sigma A T^4 with A = 4 pi r_h^2 and sigma = pi^2/60 (one bosonic degree of freedom, greybody factors ignored). A Schwarzschild hole evaporates completely in finite time; the Bonanno-Reuter hole stalls at m_crit and leaves a cold remnant.*)

sigma = Pi^2/60;
m0 = 8;
rh0 = r /. FindRoot[mOfR[r] == m0, {r, 2 m0}];
evap = NDSolve[{rh'[t] == -sigma 4 Pi rh[t]^2 TofR[rh[t]]^4/mOfR'[rh[t]], rh[0] == rh0}, rh, {t, 0, 10^9}];
tLife = 256 Pi^3 m0^3/(3 sigma);
LogLinearPlot[{mOfR[rh[t]] /. First[evap], If[t < tLife, (m0^3 - 3 sigma t/(256 Pi^3))^(1/3), 0], mCrit}, {t, 1, 10^9},
 PlotRange -> {0, m0 + 0.5}, PlotStyle -> {Automatic, Automatic, Directive[Gray, Dashed]},
 PlotLegends -> {"Bonanno-Reuter", "Schwarzschild", "m_crit"}, AxesLabel -> {"t", "m"}]

(* ::Subsection:: *)
(*Curvature stays finite*)

(* ::Text:: *)
(*Using the closed-form Kretschmann scalar from section 0: at the centre it tends to 8 Lambda_eff^2/3, the de Sitter value, instead of diverging like 48 m^2/r^6.*)

Kbr = Simplify[Kgen /. F -> Function[r, Evaluate[fBR[r, m]]]];
{Simplify[Limit[Kbr, r -> 0]], 8 (4/(3 w))^2/3}

LogLogPlot[{Kbr /. m -> 10, 48 100/r^6}, {r, 0.01, 100}, PlotLegends -> {"Bonanno-Reuter, m = 10", "Schwarzschild, m = 10"}, AxesLabel -> {"r", "K"}]

(* ::Section:: *)
(*3. The one-loop Newton potential and the w calibration*)

(* ::Text:: *)
(*Non-analytic terms in the one-loop amplitude become long-range terms in the potential. The 3D Fourier transform of q^s is Gamma(2+s) sin(pi (2+s)/2)/(2 pi^2 r^(3+s)) by analytic continuation, and Log[q^2] = 2 d/ds q^s at s = 0; contact terms at r = 0 drop out. The dictionary:*)

ftKernel[s_] := Gamma[2 + s] Sin[Pi (2 + s)/2]/(2 Pi^2 r^(3 + s));
ftTerm[term_] := Module[{k = Exponent[term, Log[qq^2]], rest, s, sig},
  rest = term /. Log[qq^2] -> 1; s = Exponent[rest, qq];
  (rest/qq^s) Limit[2^k D[ftKernel[sig], {sig, k}], sig -> s]];
ft3[expr_] := Simplify[Total[ftTerm /@ If[Head[#] === Plus, List @@ #, {#}] &[Expand[expr]]]];
{ft3[1/qq^2], ft3[1/qq], ft3[Log[qq^2]]}

(* ::Text:: *)
(*Bjerrum-Bohr, Donoghue and Holstein's one-loop potential, written as the momentum-space terms that produce it (masses m1, m2, hbar = 1):*)

Vq = -4 Pi m1 m2/qq^2 (1 + 3 Pi/2 (m1 + m2) qq - 41/(20 Pi) qq^2 Log[qq^2]);
Vr = Expand[ft3[Vq]]

(* ::Text:: *)
(*Now read the Bonanno-Reuter lapse as a potential, f = 1 + 2 Phi. Its 1/r^3 term has the same size as the quantum term in V/m1 but the opposite sign: antiscreening weakens gravity at short distance, while the BDH scattering potential is strengthened.*)

<|"G(r)/G0" -> Normal@Series[Gr[r, m], {r, Infinity, 3}], "Phi_BR" -> Normal@Series[(fBR[r, m] - 1)/2, {r, Infinity, 3}],
  "V/m1, 1/r^3 term" -> Coefficient[Vr/m1 /. m2 -> m, r, -3] r^-3|>

(* ::Text:: *)
(*The 1/r^3 coefficient is not unique, though: it depends on how the potential is defined and on the gauge. BDH also computed the one-loop-corrected metric itself (PRD 68, 084005 (2003)); in harmonic gauge its g_tt has a +62/(15 pi) G^2 m hbar/r^3 term, the same sign as Bonanno-Reuter (check the coefficient against the paper before relying on it). Since f contains +2 w m/r^3, matching that instead would set:*)

<|"w (BDH scattering potential, used here)" -> N[w], "w (BDH one-loop metric)" -> N[31/(15 Pi)]|>

(* ::Section:: *)
(*4. Energy conditions of the effective matter*)

(* ::Text:: *)
(*Read Einstein's equations backwards. For f = 1 - 2M(r)/r the effective source is an anisotropic fluid with rho = M'/(4 pi r^2), p_r = -rho and p_t = -M''/(8 pi r). The strong energy condition (Stephani et al., section 5.3) needs rho + p_r + 2 p_t >= 0, i.e. M'' <= 0. The Hawking-Penrose theorem assumes it, so a regular core has to break it.*)

Gmix = einsteinMixed[sph[1 - 2 M[r]/r], xs];
{rho, pr, pt} = Simplify[{-Gmix[[1, 1]], Gmix[[2, 2]], Gmix[[3, 3]]}/(8 Pi)]

Mbr[r_] := m Gr[r, m];
Mpp = D[Mbr[r], {r, 2}] /. m -> 10;
rSEC = r /. FindRoot[Mpp == 0, {r, 2}];
hor = r /. NSolve[fBR[r, 10] == 0 && r > 0, r, Reals];
<|"SEC fails for r <" -> rSEC, "horizons (m = 10)" -> hor|>

Plot[Evaluate[{r^2 rho, r^2 (rho + pt), r^2 (rho + pr + 2 pt)} /. M -> Function[r, Evaluate[Mbr[r]]] /. m -> 10], {r, 0, 12},
 PlotLegends -> {"rho", "rho + p_t (NEC, WEC)", "rho + sum p (SEC)"}, AxesLabel -> {"r", "r^2 x"}, GridLines -> {hor, {0}}]

(* ::Section:: *)
(*5. Which solutions survive quadratic gravity?*)

(* ::Text:: *)
(*In 4D the field equations of R + alpha R^2 + beta C^2 add the Bach tensor B_ab = grad^c grad^d C_acbd + R^cd C_acbd/2 (from C^2) and terms built from R and its derivatives (from R^2). So a Ricci-flat or Einstein metric with vanishing Bach tensor solves them unchanged. Compute B for a general static spherical metric, check it is traceless, then specialise.*)

bachF = bach[sph[F[r]], xs];
Simplify[Tr[Inverse[sph[F[r]]] . bachF]]

(* built with Apply so Mathematica doesn't rename the bound r *)
specialise[fr_] := Simplify[bachF /. F -> Function @@ {r, fr}];
<|"Schwarzschild" -> specialise[1 - 2 m/r], "Schwarzschild-de Sitter" -> specialise[1 - 2 m/r - lam r^2/3],
  "Bonanno-Reuter, B^t_t" -> Simplify[(Inverse[sph[F[r]]] . bachF)[[1, 1]] /. F -> Function[r, Evaluate[fBR[r, m]]]]|>

(* ::Subsection:: *)
(*pp-waves*)

(* ::Text:: *)
(*ds^2 = -2 du dv - H(u,x,y) du^2 + dx^2 + dy^2 (Griffiths and Podolsky, ch. 17). The only Ricci component is R_uu, proportional to the transverse Laplacian of H, and the scalar invariants vanish. That is the first step towards the statement that vacuum pp-waves solve any metric theory built from curvature and its derivatives (Horowitz and Steif 1990; Coley, Hervik, Pravda and Pravdova on universal spacetimes).*)

ppg = {{-H[u, x, y], -1, 0, 0}, {-1, 0, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}};
ppx = {u, v, x, y};
<|"Ricci" -> ricci[ppg, ppx], "R" -> ricciScalar[ppg, ppx], "Kretschmann" -> kretschmann[ppg, ppx]|>

ppBach = bach[ppg, ppx];
<|"Bach" -> ppBach, "Bach for harmonic H = A(u)(x^2 - y^2)" -> Simplify[ppBach /. H -> Function[{u, x, y}, A[u] (x^2 - y^2)]]|>
