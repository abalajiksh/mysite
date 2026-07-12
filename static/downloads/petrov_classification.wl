(* ::Package:: *)

(* ::Title:: *)
(*Petrov Classification: Weyl Scalars, Invariants, and Principal Null Directions*)


(* ::Text:: *)
(*Companion notebook to the Weyl tensor series.*)
(*Computes the five Newman-Penrose Weyl scalars for five exact solutions, extracts the*)
(*principal null directions as roots of a quartic, and reads off the Petrov type.*)
(**)
(*Signature (-,+,+,+). Geometric units G = c = 1.*)
(**)
(*Run cells in order in a FRESH kernel. Section 1 must run before anything else touches*)
(*a tensor-shaped symbol, or xTensor's definitions get shadowed by Global` ghosts.*)


(* ::Chapter:: *)
(*1. Setup and convention verification*)


(* ::Text:: *)
(*xAct is loaded FIRST, before any symbol that might collide. Loading xCoba pulls in*)
(*xPerm and xTensor transitively; do not load them separately.*)


Quit[]


Remove["Global`*"];
<< xAct`xCoba`;
$PrePrint = ScreenDollarIndices;


(* ::Text:: *)
(*Abstract-index sanity. These are the only things we ask xTensor to do symbolically,*)
(*and they are what it is genuinely good at: canonicalisation under tensor symmetries.*)


DefManifold[M4, 4, {a, b, c, d, e}];
DefMetric[-1, g[-a, -b], CD, {";", "\[Del]"}];


(* Riemann antisymmetry in the first pair. Must be exactly 0. *)
ToCanonical[RiemannCD[-a, -b, -c, -d] + RiemannCD[-b, -a, -c, -d]]


(* Ricci symmetry. Must be exactly 0. *)
ToCanonical[RicciCD[-a, -b] - RicciCD[-b, -a]]


(* Weyl is traceless by construction in xTensor: contracting b must give 0. *)
ToCanonical[WeylCD[-a, -b, -c, b]]


(* ::Text:: *)
(*The one that matters. This pins xAct's Weyl convention so we can trust every Psi*)
(*downstream. Expanding the antisymmetrisers in the published definition*)
(**)
(*   C_abcd = R_abcd - (g_a[c R_d]b - g_b[c R_d]a) + (1/3) R g_a[c g_d]b*)
(**)
(*gives*)
(**)
(*   C_abcd = R_abcd - (1/2)(g_ac R_bd - g_ad R_bc - g_bc R_ad + g_bd R_ac)*)
(*                   + (1/6) R (g_ac g_bd - g_ad g_bc)*)
(**)
(*which is what the following should return, term for term. If it does not, every sign*)
(*below is suspect and we stop here.*)


WeylToRiemann[WeylCD[-a, -b, -c, -d]] // ToCanonical


(* ::Chapter:: *)
(*2. Component engine*)


(* ::Text:: *)
(*Stateless. Takes a metric matrix and a coordinate list, returns arrays. No xTensor*)
(*state to unwind between examples, which matters because we run five metrics.*)
(**)
(*Conventions:*)
(*   Gamma^l_mk  = (1/2) g^ls (d_k g_sm + d_m g_sk - d_s g_mk)*)
(*   R^a_bcd     = d_c Gamma^a_bd - d_d Gamma^a_bc + Gamma^a_ce Gamma^e_bd - Gamma^a_de Gamma^e_bc*)
(*   R_bd        = R^a_bad        (contract 1st and 3rd)*)
(**)
(*The Weyl formula is invariant under a simultaneous sign flip of Riemann and Ricci,*)
(*so it does not depend on which Riemann sign convention we picked. The empirical*)
(*checks in Section 3 catch any error anyway.*)


(* Iterator names are deliberately ugly (i1, i2, ...) so they cannot collide with
   anything an example defines -- e.g. the FLRW scale factor. *)

ChristoffelArr[gm_, xs_] := Module[{gi = Inverse[gm], nd = Length[xs]},
  Simplify @ Table[
    (1/2) Sum[
      gi[[i1, i4]] (D[gm[[i4, i2]], xs[[i3]]] + D[gm[[i4, i3]], xs[[i2]]] - D[gm[[i2, i3]], xs[[i4]]]),
      {i4, nd}],
    {i1, nd}, {i2, nd}, {i3, nd}]
];


RiemannUpArr[gm_, xs_] := Module[{gam = ChristoffelArr[gm, xs], nd = Length[xs]},
  Simplify @ Table[
    D[gam[[i1, i2, i4]], xs[[i3]]] - D[gam[[i1, i2, i3]], xs[[i4]]]
      + Sum[gam[[i1, i3, i5]] gam[[i5, i2, i4]] - gam[[i1, i4, i5]] gam[[i5, i2, i3]], {i5, nd}],
    {i1, nd}, {i2, nd}, {i3, nd}, {i4, nd}]
];


CurvatureData[gm_, xs_] := Module[
  {nd = Length[xs], rup, rdn, ric, rs, gi, weyl, kret},
  gi   = Inverse[gm];
  rup  = RiemannUpArr[gm, xs];
  rdn  = Simplify @ Table[Sum[gm[[i1, i5]] rup[[i5, i2, i3, i4]], {i5, nd}],
           {i1, nd}, {i2, nd}, {i3, nd}, {i4, nd}];
  ric  = Simplify @ Table[Sum[rup[[i5, i2, i5, i4]], {i5, nd}], {i2, nd}, {i4, nd}];
  rs   = Simplify @ Sum[gi[[i2, i4]] ric[[i2, i4]], {i2, nd}, {i4, nd}];
  weyl = Simplify @ Table[
     rdn[[i1, i2, i3, i4]]
     - (1/2) (gm[[i1, i3]] ric[[i2, i4]] - gm[[i1, i4]] ric[[i2, i3]]
              - gm[[i2, i3]] ric[[i1, i4]] + gm[[i2, i4]] ric[[i1, i3]])
     + (1/6) rs (gm[[i1, i3]] gm[[i2, i4]] - gm[[i1, i4]] gm[[i2, i3]]),
     {i1, nd}, {i2, nd}, {i3, nd}, {i4, nd}];
  (* Kretschmann: convention-independent, so it is a clean external check *)
  kret = Simplify @ Sum[
     rdn[[i1, i2, i3, i4]] rup[[i1, j2, j3, j4]] gi[[i2, j2]] gi[[i3, j3]] gi[[i4, j4]],
     {i1, nd}, {i2, nd}, {i3, nd}, {i4, nd}, {j2, nd}, {j3, nd}, {j4, nd}];
  <| "Metric" -> gm, "Coords" -> xs, "Riemann" -> rdn, "Ricci" -> ric,
     "RicciScalar" -> rs, "Weyl" -> weyl, "Kretschmann" -> kret |>
];


(* ::Chapter:: *)
(*3. Cross-check the engine against xCoba (Schwarzschild)*)


(* ::Text:: *)
(*The engine above is hand-rolled, so it gets validated against xAct once, on a metric*)
(*whose curvature is known. If these agree, the engine is trustworthy for the other four.*)
(**)
(*NOTE: this is the one cell whose xCoba idiom needs a first-run check. If*)
(*ComponentArray/ToValues does not produce the array, try the ToCTensor variant below.*)


(* The metric g was already defined ABSTRACTLY in Section 1. We do not define a
   second one. Instead we attach explicit components to a chart and let xCoba
   compute the curvature in that chart.

   DefMetric will NOT accept a CTensor -- it errors with "Use SetCTensor for that".
   The correct route is MetricInBasis (attach components) + MetricCompute (derive
   Christoffel, Riemann, Ricci, Weyl in that basis). *)

DefChart[sc, M4, {0, 1, 2, 3}, {t[], r[], \[Theta][], \[Phi][]}];

gscMat = DiagonalMatrix[{
   -(1 - 2 MM/r[]),
   1/(1 - 2 MM/r[]),
   r[]^2,
   r[]^2 Sin[\[Theta][]]^2
}];

MetricInBasis[g, -sc, gscMat];
MetricCompute[g, sc, All];


weylXAct = ComponentArray[
   WeylCD[{-a, -sc}, {-b, -sc}, {-c, -sc}, {-d, -sc}]
] // ToValues // Simplify;


(* Engine result on the same metric *)
schwCoords = {tt, rr, th, ph};
schwMetric = DiagonalMatrix[{
   -(1 - 2 MM/rr), 1/(1 - 2 MM/rr), rr^2, rr^2 Sin[th]^2}];
schwData = CurvatureData[schwMetric, schwCoords];


(* Compare, after mapping xCoba's scalar fields onto plain symbols. Must be 0. *)
Simplify[
  Flatten[weylXAct /. {t[] -> tt, r[] -> rr, \[Theta][] -> th, \[Phi][] -> ph}]
  - Flatten[schwData["Weyl"]]
] // Union


(* Independent check: Kretschmann must be 48 M^2 / r^6 *)
Simplify[schwData["Kretschmann"]]


(* Vacuum: Ricci must vanish identically *)
Simplify[schwData["Ricci"]] // Flatten // Union


(* ::Chapter:: *)
(*4. Null tetrads and the Weyl scalars*)


(* ::Text:: *)
(*Abstract xTensor cannot handle mbar gracefully (complex conjugation fights the index*)
(*machinery), so the tetrad contractions are done on explicit arrays.*)
(**)
(*Normalisation, signature (-,+,+,+):*)
(*   l.n = -1,   m.mbar = +1,   all other inner products zero.*)
(**)
(*Weyl scalars (Chandrasekhar / Wald):*)
(*   Psi0 = C_abcd l^a m^b l^c m^d*)
(*   Psi1 = C_abcd l^a n^b l^c m^d*)
(*   Psi2 = C_abcd l^a m^b mbar^c n^d*)
(*   Psi3 = C_abcd l^a n^b mbar^c n^d*)
(*   Psi4 = C_abcd n^a mbar^b n^c mbar^d*)


InnerProd[gm_, u_, v_] := Simplify @ Sum[gm[[i, j]] u[[i]] v[[j]], {i, 4}, {j, 4}];


(* Returns the ten inner products. Expected: {0,0,0,0, -1, 1, 0,0,0,0} *)
TetradCheck[gm_, lv_, nv_, mv_, mbv_] := Simplify @ {
   InnerProd[gm, lv, lv],  InnerProd[gm, nv, nv],
   InnerProd[gm, mv, mv],  InnerProd[gm, mbv, mbv],
   InnerProd[gm, lv, nv],  InnerProd[gm, mv, mbv],
   InnerProd[gm, lv, mv],  InnerProd[gm, lv, mbv],
   InnerProd[gm, nv, mv],  InnerProd[gm, nv, mbv]
};


(* Stronger check: the tetrad must reconstruct the metric.
   g_ab = -l_a n_b - n_a l_b + m_a mbar_b + mbar_a m_b   (indices lowered with g) *)
TetradReconstruct[gm_, lv_, nv_, mv_, mbv_] := Module[{lo, no, mo, mbo},
  lo  = gm . lv;  no = gm . nv;  mo = gm . mv;  mbo = gm . mbv;
  Simplify[
    Table[-lo[[i]] no[[j]] - no[[i]] lo[[j]] + mo[[i]] mbo[[j]] + mbo[[i]] mo[[j]],
      {i, 4}, {j, 4}] - gm
  ]
];


PsiScalars[weyl_, lv_, nv_, mv_, mbv_] := Module[{ct},
  ct[v1_, v2_, v3_, v4_] := Sum[
    weyl[[i, j, k, l]] v1[[i]] v2[[j]] v3[[k]] v4[[l]],
    {i, 4}, {j, 4}, {k, 4}, {l, 4}];
  Simplify @ {
    ct[lv, mv,  lv,  mv ],   (* Psi0 *)
    ct[lv, nv,  lv,  mv ],   (* Psi1 *)
    ct[lv, mv,  mbv, nv ],   (* Psi2 *)
    ct[lv, nv,  mbv, nv ],   (* Psi3 *)
    ct[nv, mbv, nv,  mbv]    (* Psi4 *)
  }
];


(* Generic construction: any orthonormal frame {e0,e1,e2,e3} -> null tetrad.
   Used for Kasner and FLRW, where there is no canonical Kinnersley-type tetrad. *)
NullFromOrthonormal[e0_, e1_, e2_, e3_] := {
  (e0 + e1)/Sqrt[2],
  (e0 - e1)/Sqrt[2],
  (e2 + I e3)/Sqrt[2],
  (e2 - I e3)/Sqrt[2]
};


(* ::Chapter:: *)
(*5. Classification: the quartic, and the invariants*)


(* ::Text:: *)
(*The classification IS the root-multiplicity structure of*)
(**)
(*   Psi4 z^4 + 4 Psi3 z^3 + 6 Psi2 z^2 + 4 Psi1 z + Psi0 = 0*)
(**)
(*Each root is a principal null direction, stereographically projected onto the*)
(*observer's celestial sphere. A quartic has six ways for its roots to collide, and*)
(*that is exactly why there are six Petrov types.*)
(**)
(*Subtlety worth stating out loud: if Psi4 = 0 the polynomial degree drops, and the*)
(*missing roots have gone to z = infinity, i.e. l itself is a PND. Multiplicity of the*)
(*root at infinity = 4 - deg(p). Miss this and Schwarzschild looks like type N.*)
(**)
(*Multiplicities are extracted by square-free decomposition, which is exact and works*)
(*on symbolic coefficients -- no numerical root-finding, no tolerance to tune.*)


RootPartition[psis_List] := Module[{p, deg, lead, pm, sf, parts, infMult, z},
  If[AllTrue[psis, PossibleZeroQ], Return[{}]];
  p = Collect[Together[Simplify[
        psis[[5]] z^4 + 4 psis[[4]] z^3 + 6 psis[[3]] z^2 + 4 psis[[2]] z + psis[[1]]
      ]], z];
  If[PossibleZeroQ[p], Return[{}]];
  deg     = Exponent[p, z];
  infMult = 4 - deg;
  (* Make monic in z. The coefficient ring carries rr, MM, tG, ... and without this
     the square-free decomposition can mistake those for polynomial content. *)
  lead = Coefficient[p, z, deg];
  pm   = Collect[Simplify[Expand[p/lead]], z];
  (* FactorSquareFreeList takes ONE argument. There is no [poly, var] form. *)
  sf    = FactorSquareFreeList[pm];
  parts = Join @@ Table[
     ConstantArray[sf[[i, 2]], Exponent[sf[[i, 1]], z]], {i, Length[sf]}];
  If[infMult > 0, parts = Join[parts, {infMult}]];
  Sort[parts, Greater]
];


PetrovFromPartition[part_] := Switch[part,
  {},           "O",
  {1, 1, 1, 1}, "I",
  {2, 1, 1},    "II",
  {2, 2},       "D",
  {3, 1},       "III",
  {4},          "N",
  _,            "UNRECOGNISED: " <> ToString[part]
];


(* ::Text:: *)
(*Cross-check via the curvature invariants. I and J are genuine Lorentz invariants;*)
(*K, L, N are only covariant, so the branch conditions below carry a frame assumption*)
(*that most references quietly omit. Treat this as a second opinion, not the ruling.*)
(**)
(*   I = Psi0 Psi4 - 4 Psi1 Psi3 + 3 Psi2^2*)
(*   J = det[[Psi4,Psi3,Psi2],[Psi3,Psi2,Psi1],[Psi2,Psi1,Psi0]]*)
(**)
(*I^3 == 27 J^2 is the vanishing discriminant of the quartic, i.e. a repeated root.*)
(*"Algebraically special" and "discriminant vanishes" are the same statement.*)


WeylInvariants[psis_] := Module[{p0, p1, p2, p3, p4, ii, jj, kk, ll, nn},
  {p0, p1, p2, p3, p4} = psis;
  ii = Simplify[p0 p4 - 4 p1 p3 + 3 p2^2];
  jj = Simplify[Det[{{p4, p3, p2}, {p3, p2, p1}, {p2, p1, p0}}]];
  kk = Simplify[p1 p4^2 - 3 p4 p3 p2 + 2 p3^3];
  ll = Simplify[p2 p4 - p3^2];
  nn = Simplify[12 ll^2 - p4^2 ii];
  <| "I" -> ii, "J" -> jj, "K" -> kk, "L" -> ll, "N" -> nn,
     "Discriminant" -> Simplify[ii^3 - 27 jj^2] |>
];


PetrovClassify[label_, gm_, xs_, lv_, nv_, mv_, mbv_] := Module[
  {dat, psis, part, typ, inv, tc, tr},
  dat  = CurvatureData[gm, xs];
  tc   = TetradCheck[gm, lv, nv, mv, mbv];
  tr   = TetradReconstruct[gm, lv, nv, mv, mbv] // Flatten // Union;
  psis = PsiScalars[dat["Weyl"], lv, nv, mv, mbv];
  part = RootPartition[psis];
  typ  = PetrovFromPartition[part];
  inv  = WeylInvariants[psis];
  Print[Style[label, Bold, 16]];
  Print["  tetrad norms  : ", tc, "   (expect {0,0,0,0,-1,1,0,0,0,0})"];
  Print["  metric rebuilt: ", tr, "   (expect {0})"];
  Print["  Ricci         : ", Union[Flatten[Simplify[dat["Ricci"]]]]];
  Print["  Kretschmann   : ", dat["Kretschmann"]];
  Print["  {Psi0..Psi4}  : ", psis];
  Print["  I, J          : ", {inv["I"], inv["J"]}];
  Print["  I^3 - 27 J^2  : ", inv["Discriminant"]];
  Print["  PND multipl.  : ", part];
  Print["  PETROV TYPE   : ", Style[typ, Bold]];
  Print[""];
  <| "Label" -> label, "Psis" -> psis, "Partition" -> part,
     "Type" -> typ, "Invariants" -> inv, "Data" -> dat |>
];


(* ::Chapter:: *)
(*6. Example 1: FLRW  (expect type O)*)


(* ::Text:: *)
(*Run first, deliberately. FLRW is conformally flat, so all five Psi must vanish*)
(*identically. If a conformally flat metric does not come back type O, the pipeline is*)
(*broken and we find out on the cheapest possible example rather than on Kerr.*)
(**)
(*This is also the machine confirming, in one line, the "Conformally Flat" identity*)
(*proved by hand in the previous post.*)


$Assumptions = {aa[eta] > 0, eta \[Element] Reals};

flrwCoords = {eta, xx, yy, zz};
flrwMetric = aa[eta]^2 DiagonalMatrix[{-1, 1, 1, 1}];

flrwFrame = {
  {1/aa[eta], 0, 0, 0},
  {0, 1/aa[eta], 0, 0},
  {0, 0, 1/aa[eta], 0},
  {0, 0, 0, 1/aa[eta]}
};

{lF, nF, mF, mbF} = NullFromOrthonormal @@ flrwFrame;

resFLRW = PetrovClassify["FLRW (k=0, conformal time)", flrwMetric, flrwCoords, lF, nF, mF, mbF];


(* ::Chapter:: *)
(*7. Example 2: Schwarzschild  (expect type D)*)


(* ::Text:: *)
(*Kinnersley tetrad, a -> 0 limit. l and n are the outgoing and ingoing radial null*)
(*congruences -- the two PNDs, each doubled.*)
(**)
(*Expect Psi2 = -M/r^3 and every other scalar exactly zero. The quartic collapses to*)
(*6 Psi2 z^2 = 0: a double root at z = 0, and a double root at infinity because the*)
(*degree dropped from 4 to 2. Partition {2,2} -> type D.*)


$Assumptions = {MM > 0, rr > 2 MM, 0 < th < Pi};

schwCoords = {tt, rr, th, ph};
schwMetric = DiagonalMatrix[{
   -(1 - 2 MM/rr), 1/(1 - 2 MM/rr), rr^2, rr^2 Sin[th]^2}];

ff = 1 - 2 MM/rr;

lS  = {1/ff, 1, 0, 0};
nS  = {1/2, -ff/2, 0, 0};
mS  = (1/(Sqrt[2] rr)) {0, 0, 1,  I/Sin[th]};
mbS = (1/(Sqrt[2] rr)) {0, 0, 1, -I/Sin[th]};

resSchw = PetrovClassify["Schwarzschild (Kinnersley tetrad)", schwMetric, schwCoords, lS, nS, mS, mbS];


(* ::Chapter:: *)
(*8. Example 3: Kerr  (expect type D)*)


(* ::Text:: *)
(*Boyer-Lindquist coordinates, Kinnersley tetrad.*)
(**)
(*   Sigma = r^2 + a^2 cos^2(theta),   Delta = r^2 - 2 M r + a^2*)
(**)
(*The expected result is the reason this post exists:*)
(**)
(*   Psi2 = -M / (r - i a cos(theta))^3,   all other Psi = 0.*)
(**)
(*The entire Weyl tensor of a rotating black hole is ONE complex number. The real part*)
(*is the tidal field; the imaginary part is frame-dragging. Whether Simplify actually*)
(*lands that closed form or hands back a mess we have to massage is itself worth*)
(*reporting.*)


$Assumptions = {MM > 0, aa0 > 0, rr > 0, 0 < th < Pi, MM \[Element] Reals, aa0 \[Element] Reals};

kerrCoords = {tt, rr, th, ph};

sig = rr^2 + aa0^2 Cos[th]^2;
del = rr^2 - 2 MM rr + aa0^2;

kerrMetric = {
  {-(1 - 2 MM rr/sig),      0,          0,   -2 MM rr aa0 Sin[th]^2/sig},
  {0,                       sig/del,    0,   0},
  {0,                       0,          sig, 0},
  {-2 MM rr aa0 Sin[th]^2/sig, 0,       0,   (rr^2 + aa0^2 + 2 MM rr aa0^2 Sin[th]^2/sig) Sin[th]^2}
};

lK  = {(rr^2 + aa0^2)/del, 1, 0, aa0/del};
nK  = {(rr^2 + aa0^2)/(2 sig), -del/(2 sig), 0, aa0/(2 sig)};
mK  = (1/(Sqrt[2] (rr + I aa0 Cos[th]))) {I aa0 Sin[th], 0, 1, I/Sin[th]};
mbK = (1/(Sqrt[2] (rr - I aa0 Cos[th]))) {-I aa0 Sin[th], 0, 1, -I/Sin[th]};

resKerr = PetrovClassify["Kerr (Boyer-Lindquist, Kinnersley tetrad)", kerrMetric, kerrCoords, lK, nK, mK, mbK];


(* Does Psi2 match the closed form? Must be 0. *)
Simplify[resKerr["Psis"][[3]] + MM/(rr - I aa0 Cos[th])^3]


(* Kretschmann for Kerr, for the record *)
Simplify[resKerr["Data"]["Kretschmann"]]


(* ::Chapter:: *)
(*9. Example 4: pp-wave  (expect type N)*)


(* ::Text:: *)
(*Brinkmann form:  ds^2 = H(u,x,y) du^2 + 2 du dv + dx^2 + dy^2*)
(**)
(*Vacuum requires H harmonic in the transverse plane: H_xx + H_yy = 0.*)
(*Take H = h(u) (x^2 - y^2), which is the "+" polarisation.*)
(**)
(*l = d/dv is the quadruple PND. Expect Psi4 nonzero, everything else zero.*)
(*Quartic becomes Psi4 z^4 = 0: a single root at z = 0 with multiplicity 4 -> type N.*)


$Assumptions = {uu \[Element] Reals, vv \[Element] Reals, xx \[Element] Reals, yy \[Element] Reals};

ppCoords = {uu, vv, xx, yy};
Hf = hh[uu] (xx^2 - yy^2);

ppMetric = {
  {Hf, 1, 0, 0},
  {1,  0, 0, 0},
  {0,  0, 1, 0},
  {0,  0, 0, 1}
};

lP  = {0, 1, 0, 0};
nP  = {-1, Hf/2, 0, 0};
mP  = (1/Sqrt[2]) {0, 0, 1, I};
mbP = (1/Sqrt[2]) {0, 0, 1, -I};

resPP = PetrovClassify["pp-wave (Brinkmann, + polarisation)", ppMetric, ppCoords, lP, nP, mP, mbP];


(* ::Chapter:: *)
(*10. Example 5: Kasner  (expect type I)*)


(* ::Text:: *)
(*ds^2 = -dt^2 + t^(2 p1) dx^2 + t^(2 p2) dy^2 + t^(2 p3) dz^2,*)
(*with sum p_i = 1 and sum p_i^2 = 1.*)
(**)
(*Lifshitz-Khalatnikov parametrisation:*)
(*   p1 = -u/(1+u+u^2),  p2 = (1+u)/(1+u+u^2),  p3 = u(1+u)/(1+u+u^2)*)
(**)
(*u = 2 gives p = (-2/7, 3/7, 6/7): three distinct exponents, no residual symmetry.*)
(*This is the one example we expect NOT to be algebraically special.*)
(**)
(*u = 1 gives p = (-1/3, 2/3, 2/3), which is axisymmetric. Whether the extra symmetry*)
(*collapses it to type D is left to the code rather than to my memory -- see below.*)


$Assumptions = {tG > 0};

kasner[{p1_, p2_, p3_}] := Module[{cs, gm, fr, l0, n0, m0, mb0},
  cs = {tG, xG, yG, zG};
  gm = DiagonalMatrix[{-1, tG^(2 p1), tG^(2 p2), tG^(2 p3)}];
  fr = {
    {1, 0, 0, 0},
    {0, tG^(-p1), 0, 0},
    {0, 0, tG^(-p2), 0},
    {0, 0, 0, tG^(-p3)}
  };
  {l0, n0, m0, mb0} = NullFromOrthonormal @@ fr;
  {gm, cs, l0, n0, m0, mb0}
];


(* Generic case, u = 2 *)
{gK1, cK1, lK1, nK1, mK1, mbK1} = kasner[{-2/7, 3/7, 6/7}];
resKasner = PetrovClassify["Kasner, u=2  p = (-2/7, 3/7, 6/7)", gK1, cK1, lK1, nK1, mK1, mbK1];


(* Axisymmetric case, u = 1. Type I or type D? Let the code answer. *)
{gK2, cK2, lK2, nK2, mK2, mbK2} = kasner[{-1/3, 2/3, 2/3}];
resKasnerLRS = PetrovClassify["Kasner, u=1  p = (-1/3, 2/3, 2/3), axisymmetric", gK2, cK2, lK2, nK2, mK2, mbK2];


(* ::Chapter:: *)
(*11. Summary*)


allResults = {resFLRW, resSchw, resKerr, resPP, resKasner, resKasnerLRS};

TableForm[
  {#["Label"], #["Psis"], #["Partition"], #["Type"]} & /@ allResults,
  TableHeadings -> {None, {"Metric", "{Psi0..Psi4}", "PND multiplicities", "Petrov type"}}
]


(* ::Text:: *)
(*Note which ones came out algebraically special, and which did not. That pattern is*)
(*Goldberg-Sachs, and it is the subject of the closing section of the article.*)


(* ::Chapter:: *)
(*12. Export for the visualisation post*)


(* ::Text:: *)
(*The Blender scripts in the follow-up post consume these. Psis are exported as*)
(*{Re, Im} pairs with the free parameters given concrete numeric values, since Blender*)
(*needs numbers, not symbols.*)


numRules = {MM -> 1, aa0 -> 9/10, rr -> 10, th -> Pi/3, hh[uu] -> 1, tG -> 1};

exportPsis[res_] := <|
  "label" -> res["Label"],
  "type"  -> res["Type"],
  "partition" -> res["Partition"],
  "psis"  -> (N[{Re[#], Im[#]}] & /@ (res["Psis"] /. numRules /. aa[eta] -> 1))
|>;

outDir = If[$Notebooks && Quiet[Check[NotebookDirectory[], $Failed]] =!= $Failed,
   NotebookDirectory[], Directory[]];

Export[
  FileNameJoin[{outDir, "petrov_psis.json"}],
  exportPsis /@ allResults,
  "JSON"
]
