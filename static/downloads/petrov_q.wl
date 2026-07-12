(* ::Package:: *)

(* ::Title:: *)
(*Q = E + i B: The Gravito-Electric and Gravito-Magnetic Weyl Tensor*)


(* ::Text:: *)
(*Companion notebook to Part III of the Weyl tensor series.*)
(*Splits the Weyl tensor into the tidal field E (what a ring of dust feels) and the*)
(*gravitomagnetic field B (what a gyroscope feels), assembles Q = E + i B, and shows*)
(*that the Petrov type is the Jordan normal form of Q.*)
(**)
(*Signature (-,+,+,+). Geometric units G = c = 1.*)
(**)
(*NO xAct. Deliberately. Part II already ran this ground with xAct in the loop; keeping*)
(*this notebook xAct-free makes the two an INDEPENDENT cross-check rather than a shared*)
(*point of failure.*)
(**)
(*Run cells in order in a FRESH kernel.*)
(**)
(*TWO LESSONS FROM PART II, RE-APPLIED (I re-learned both the hard way):*)
(*  - Iterator names are deliberately ugly (i1, i2, ...) so they cannot collide with a*)
(*    metric parameter. Writing Table[..., {a, 4}] while `a` is the Kerr spin produces*)
(*    garbage, silently.*)
(*  - Never name a local C, D, E, I, N, K or O. All Protected. Module[{C = ...}] fails*)
(*    without explaining itself. Hence elecPart / magPart / qmat below.*)


(* ::Chapter:: *)
(*1. Conventions, pinned*)


(* ::Text:: *)
(*Everything downstream depends on these. Change one and a sign flips somewhere and the*)
(*article becomes wrong, so they are written once, here, and never touched again.*)
(**)
(*  frame        e0 timelike, minkMat = diag(-1,1,1,1)*)
(*  NP tetrad    l = (e0+e1)/Sqrt2,  n = (e0-e1)/Sqrt2,  m = (e2 + I e3)/Sqrt2*)
(*               => l.n = -1,  m.mbar = +1        (same as Part II)*)
(*  eps_{0123}   = +1                             <-- THIS FIXES THE SIGN OF B*)
(*  E_ij         = C_{i0j0}*)
(*  B_ij         = (1/2) eps_ikl C_{klj0}*)
(*  Q            = E + I B*)
(**)
(*Frame indices are 0..3 in the text and 1..4 in Mathematica; spatial i,j,k are 1..3 in*)
(*the text and 2..4 in the arrays. Every "+1" below is that offset and nothing more.*)


Quit[]


Remove["Global`*"];

minkMat = DiagonalMatrix[{-1, 1, 1, 1}];

(* eps_{abcd} with eps_{0123} = +1. LeviCivitaTensor[4][[1,2,3,4]] = 1, so the array
   maps straight onto the convention with no relabelling. *)
epsDn4 = LeviCivitaTensor[4];

(* Raising four indices with minkMat costs Det[minkMat] = -1. *)
epsUp4 = -LeviCivitaTensor[4];

eps3 = LeviCivitaTensor[3];


(* ::Chapter:: *)
(*2. Component engine*)


(* ::Text:: *)
(*Identical to the Part II engine, reproduced verbatim, so that any disagreement between*)
(*the two notebooks is a disagreement about physics and not about arithmetic.*)
(*Stateless: takes a metric matrix and a coordinate list, returns arrays.*)


ChristoffelArr[gm_, xs_] := Module[{gi = Inverse[gm], nd = Length[xs]},
  Simplify @ Table[
    (1/2) Sum[
      gi[[i1, i4]] (D[gm[[i4, i2]], xs[[i3]]] + D[gm[[i4, i3]], xs[[i2]]]
                    - D[gm[[i2, i3]], xs[[i4]]]),
      {i4, nd}],
    {i1, nd}, {i2, nd}, {i3, nd}]
];


RiemannUpArr[gm_, xs_] := Module[{gam = ChristoffelArr[gm, xs], nd = Length[xs]},
  Simplify @ Table[
    D[gam[[i1, i2, i4]], xs[[i3]]] - D[gam[[i1, i2, i3]], xs[[i4]]]
      + Sum[gam[[i1, i3, i5]] gam[[i5, i2, i4]]
            - gam[[i1, i4, i5]] gam[[i5, i2, i3]], {i5, nd}],
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
  kret = Simplify @ Sum[
     rdn[[i1, i2, i3, i4]] rup[[i1, j2, j3, j4]] gi[[i2, j2]] gi[[i3, j3]] gi[[i4, j4]],
     {i1, nd}, {i2, nd}, {i3, nd}, {i4, nd}, {j2, nd}, {j3, nd}, {j4, nd}];
  <| "Metric" -> gm, "Coords" -> xs, "Riemann" -> rdn, "Ricci" -> ric,
     "RicciScalar" -> rs, "Weyl" -> weyl, "Kretschmann" -> kret |>
];


(* ::Chapter:: *)
(*3. Frames, and the projection of Weyl onto a frame*)


(* ::Text:: *)
(*A frame is four contravariant vectors {e0,e1,e2,e3}. FrameCheck must return a zero*)
(*matrix. If it does not, the frame is not orthonormal and every number after it is*)
(*meaningless -- so it is the first thing printed for every metric, on purpose.*)


FrameCheck[gm_, fr_] := Simplify[
  Table[fr[[i1]] . gm . fr[[i2]], {i1, 4}, {i2, 4}] - minkMat];


WeylInFrame[weyl_, fr_] := Simplify @ Table[
  Sum[weyl[[i5, i6, i7, i8]]
      fr[[i1, i5]] fr[[i2, i6]] fr[[i3, i7]] fr[[i4, i8]],
    {i5, 4}, {i6, 4}, {i7, 4}, {i8, 4}],
  {i1, 4}, {i2, 4}, {i3, 4}, {i4, 4}];


(* Same map Part II used, so both notebooks build the same tetrad from the same frame. *)
NullFromOrthonormal[e0_, e1_, e2_, e3_] := {
  (e0 + e1)/Sqrt[2],
  (e0 - e1)/Sqrt[2],
  (e2 + I e3)/Sqrt[2],
  (e2 - I e3)/Sqrt[2]
};


(* ::Chapter:: *)
(*4. E, B, Q, and the five Weyl scalars -- all from the frame Weyl*)


(* ::Text:: *)
(*Array slot i+1 is text index i, so cf[[i+1, 1, j+1, 1]] is C_{i 0 j 0}.*)


elecPart[cf_] := Simplify @ Table[cf[[i1 + 1, 1, i2 + 1, 1]], {i1, 3}, {i2, 3}];


magPart[cf_] := Simplify @ Table[
  (1/2) Sum[eps3[[i1, i3, i4]] cf[[i3 + 1, i4 + 1, i2 + 1, 1]], {i3, 3}, {i4, 3}],
  {i1, 3}, {i2, 3}];


qmat[cf_] := Simplify[elecPart[cf] + I magPart[cf]];


(* Psi scalars in the SAME frame as E and B. Same formulae as Part II. *)
PsiInFrame[cf_] := Module[{lv, nv, mv, mbv, ct},
  {lv, nv, mv, mbv} = NullFromOrthonormal[
     {1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}];
  ct[v1_, v2_, v3_, v4_] := Sum[
     cf[[i1, i2, i3, i4]] v1[[i1]] v2[[i2]] v3[[i3]] v4[[i4]],
     {i1, 4}, {i2, 4}, {i3, 4}, {i4, 4}];
  Simplify @ {
    ct[lv, mv,  lv,  mv ],
    ct[lv, nv,  lv,  mv ],
    ct[lv, mv,  mbv, nv ],
    ct[lv, nv,  mbv, nv ],
    ct[nv, mbv, nv,  mbv]
  }
];


(* ::Text:: *)
(*THE DICTIONARY. This is the claim of the whole post. Asserted here, PROVED in Section 5*)
(*against a completely generic Weyl tensor, then re-checked on every metric in 8-12.*)


qFromPsi[{p0_, p1_, p2_, p3_, p4_}] := {
  {2 p2,          p3 - p1,            I (p1 + p3)},
  {p3 - p1,       (p0 + p4)/2 - p2,  -I (p0 - p4)/2},
  {I (p1 + p3),  -I (p0 - p4)/2,     -(p0 + p4)/2 - p2}
};


(* ::Text:: *)
(*Invariants read straight off Q. The characteristic polynomial of a traceless 3x3 is*)
(**)
(*   lambda^3 - (1/2) Tr[Q.Q] lambda - Det[Q] = 0*)
(**)
(*so with invI = Tr[Q.Q]/2 and invJ = -Det[Q]/2 it reads lambda^3 - I lambda + 2J = 0,*)
(*whose discriminant is 4(I^3 - 27 J^2). The quartic's discriminant from Part II and this*)
(*cubic's discriminant are THE SAME NUMBER: "algebraically special" and "Q has a repeated*)
(*eigenvalue" are the same statement, wearing different clothes.*)


invI[qq_] := Simplify[(1/2) Tr[qq . qq]];
invJ[qq_] := Simplify[-(1/2) Det[qq]];


(* Petrov type = Jordan structure of Q. Six Jordan forms, six types. *)
PetrovFromQ[qq_] := Module[{zz3, evs, dis, rep, mm},
  zz3 = ConstantArray[0, {3, 3}];
  If[Simplify[qq] === zz3, Return["O"]];
  evs = Simplify @ Eigenvalues[qq];
  If[AllTrue[evs, PossibleZeroQ],
     Return[If[Simplify[qq . qq] === zz3, "N", "III"]]];
  dis = DeleteDuplicates[evs, PossibleZeroQ[Simplify[#1 - #2]] &];
  If[Length[dis] == 3, Return["I"]];
  rep = SelectFirst[dis, Count[evs, xq_ /; PossibleZeroQ[Simplify[xq - #]]] >= 2 &];
  mm  = Simplify[qq - rep IdentityMatrix[3]];
  If[MatrixRank[mm] == 1, "D", "II"]
];


(* ::Chapter:: *)
(*5. Proving the dictionary on a GENERIC Weyl tensor*)


(* ::Text:: *)
(*Not on an example. On the general algebraic object.*)
(**)
(*A tensor with Riemann's pair symmetries is a symmetric 6x6 matrix on bivector index*)
(*pairs: 21 components. Impose the first Bianchi identity (one further condition, the*)
(*totally antisymmetric part) and tracelessness (ten conditions), and ten survive. Ten is*)
(*the right count for Weyl in 4D -- which makes the count itself a check that the*)
(*construction is sound before any physics happens.*)
(**)
(*Then compute E, B and the Psi from that generic object and compare Q against*)
(*qFromPsi[Psi]. If the dictionary is a theorem, the difference is the zero matrix*)
(*IDENTICALLY in ten free symbols. If it is a coincidence of some example, it will not be.*)


bivPairs = {{1, 2}, {1, 3}, {1, 4}, {2, 3}, {2, 4}, {3, 4}};

sMat = Table[
   Symbol["sq" <> ToString[Min[i1, i2]] <> ToString[Max[i1, i2]]],
   {i1, 6}, {i2, 6}];

pairIndex[i1_, i2_] := Which[
   i1 === i2, {0, 0},
   MemberQ[bivPairs, {i1, i2}], {Position[bivPairs, {i1, i2}][[1, 1]],  1},
   True,                        {Position[bivPairs, {i2, i1}][[1, 1]], -1}];

genWeyl0 = Table[
   Module[{pa = pairIndex[i1, i2], pc = pairIndex[i3, i4]},
     If[pa[[1]] === 0 || pc[[1]] === 0, 0,
        pa[[2]] pc[[2]] sMat[[pa[[1]], pc[[1]]]]]],
   {i1, 4}, {i2, 4}, {i3, 4}, {i4, 4}];


bianchiEq = genWeyl0[[1, 2, 3, 4]] + genWeyl0[[1, 3, 4, 2]] + genWeyl0[[1, 4, 2, 3]] == 0;

traceEqs = Flatten @ Table[
   Sum[minkMat[[i1, i3]] genWeyl0[[i1, i2, i3, i4]], {i1, 4}, {i3, 4}] == 0,
   {i2, 4}, {i4, i2, 4}];

freeSyms = DeleteDuplicates @ Cases[sMat, _Symbol, {2}];

genSol  = First @ Solve[Join[{bianchiEq}, traceEqs], freeSyms];
genWeyl = Expand[genWeyl0 /. genSol];


(* Must print 10. *)
Print["free components after Bianchi + tracelessness: ",
  Length @ DeleteDuplicates @ Cases[genWeyl, _Symbol, Infinity]];


(* ::Text:: *)
(*E and B of the generic tensor. Both must come out symmetric AND traceless. Neither*)
(*property is imposed anywhere above, so both are genuine checks, not tautologies.*)


genE = elecPart[genWeyl];
genB = magPart[genWeyl];

Print["generic E symmetric? ",
  Simplify[genE - Transpose[genE]] === ConstantArray[0, {3, 3}],
  "   traceless? ", PossibleZeroQ @ Simplify @ Tr[genE]];

Print["generic B symmetric? ",
  Simplify[genB - Transpose[genB]] === ConstantArray[0, {3, 3}],
  "   traceless? ", PossibleZeroQ @ Simplify @ Tr[genB]];


(* ::Text:: *)
(*THE PROOF. Zero matrix expected.*)


genPsi = PsiInFrame[genWeyl];
genQ   = qmat[genWeyl];

Simplify[genQ - qFromPsi[genPsi]] // MatrixForm


(* ::Text:: *)
(*And the invariants, against the NP definitions Part II used. Both zero.*)


Print["I - (Psi0 Psi4 - 4 Psi1 Psi3 + 3 Psi2^2) = ",
  Simplify[invI[genQ]
    - (genPsi[[1]] genPsi[[5]] - 4 genPsi[[2]] genPsi[[4]] + 3 genPsi[[3]]^2)]];

Print["J - Det[{{P4,P3,P2},{P3,P2,P1},{P2,P1,P0}}] = ",
  Simplify[invJ[genQ] - Det[{
     {genPsi[[5]], genPsi[[4]], genPsi[[3]]},
     {genPsi[[4]], genPsi[[3]], genPsi[[2]]},
     {genPsi[[3]], genPsi[[2]], genPsi[[1]]}}]]];


(* ::Text:: *)
(*The control. Had the opposite orientation been chosen -- Q = E - iB -- the invariant*)
(*identity FAILS. Expect a NONZERO result from this cell. That failure is what pins*)
(*eps_{0123} = +1, and it pins it before Kerr is even loaded.*)


Print["control, Q -> E - iB:  I - I_NP = ",
  Simplify[invI[genE - I genB]
    - (genPsi[[1]] genPsi[[5]] - 4 genPsi[[2]] genPsi[[4]] + 3 genPsi[[3]]^2)]];


(* ::Chapter:: *)
(*6. What B does: the spin-curvature force*)


(* ::Text:: *)
(*A ring of dust obeys geodesic deviation, addot^i = -E^i_j a^j. It sees E and ONLY E.*)
(*Szekeres' gravitational compass -- four masses, six dynamometers -- measures the*)
(*eigenvalues and principal directions of E completely, and is structurally blind to B.*)
(*Half the Weyl tensor is invisible to anything that does not spin.*)
(**)
(*A gyroscope is not a test particle. Curvature couples to its spin.*)
(*Mathisson-Papapetrou-Dixon:*)
(**)
(*   F^a = -(1/2) R^a_bcd u^b S^cd,      S^cd = eps^cdab u_a S_b*)
(**)
(*Evaluate on the generic vacuum Weyl tensor (in vacuum Riemann = Weyl) and see what*)
(*falls out. The coefficient is not assumed; it is read off.*)


ClearAll[sp1, sp2, sp3];

uUp  = {1, 0, 0, 0};
uDn  = minkMat . uUp;
spUp = {0, sp1, sp2, sp3};
spDn = minkMat . spUp;

spinTensor = Table[
   Sum[epsUp4[[i1, i2, i3, i4]] uDn[[i3]] spDn[[i4]], {i3, 4}, {i4, 4}],
   {i1, 4}, {i2, 4}];

genWeylUp = Table[
   Sum[Inverse[minkMat][[i1, i5]] genWeyl[[i5, i2, i3, i4]], {i5, 4}],
   {i1, 4}, {i2, 4}, {i3, 4}, {i4, 4}];

mpdForce = Simplify @ Table[
   -(1/2) Sum[genWeylUp[[i1, i2, i3, i4]] uUp[[i2]] spinTensor[[i3, i4]],
      {i2, 4}, {i3, 4}, {i4, 4}],
   {i1, 4}];


(* ::Text:: *)
(*Two things to look at.*)
(**)
(*  (a) The time component must vanish IDENTICALLY. The force on a gyroscope is purely*)
(*      spatial: there is no gravitational analogue of the work Faraday induction does on*)
(*      a magnetic dipole. (Costa & Herdeiro, PRD 78, 024021.)*)
(**)
(*  (b) The spatial part must be exactly F^i = -B^ij S_j. No stray factor, no sign.*)


Print["F^0 = ", Simplify[mpdForce[[1]]], "     (expect 0)"];

Print["F^i - (-B.S) = ",
  Simplify[mpdForce[[2 ;; 4]] + genB . {sp1, sp2, sp3}], "     (expect {0,0,0})"];

Print["F^i - (+B.S) = ",
  Simplify[mpdForce[[2 ;; 4]] - genB . {sp1, sp2, sp3}], "     (expect NONZERO: control)"];


(* ::Chapter:: *)
(*7. Reporting harness*)


(* ::Text:: *)
(*One function, run on every metric. Frame check first, because if the frame is not*)
(*orthonormal then nothing below it means anything.*)


QReport[label_, gm_, xs_, fr_] := Module[
  {fc, dat, cf, psis, qq, qd, ii, jj, dsc, typ, ee, bb},
  fc = FrameCheck[gm, fr];
  Print[Style[label, Bold, 16]];
  Print["  frame orthonormal? ", fc === ConstantArray[0, {4, 4}]];
  dat  = CurvatureData[gm, xs];
  Print["  Ricci (vacuum?)   : ", Union @ Flatten @ Simplify @ dat["Ricci"]];
  Print["  Kretschmann       : ", dat["Kretschmann"]];
  cf   = WeylInFrame[dat["Weyl"], fr];
  psis = PsiInFrame[cf];
  qq   = qmat[cf];
  qd   = qFromPsi[psis];
  ee   = elecPart[cf];
  bb   = magPart[cf];
  ii   = invI[qq];
  jj   = invJ[qq];
  dsc  = Simplify[ii^3 - 27 jj^2];
  typ  = PetrovFromQ[qq];
  Print["  {Psi0..Psi4}      : ", psis];
  Print["  Q - qFromPsi[Psi] : ", Simplify[qq - qd], "   (expect all zero)"];
  Print["  E                 : ", MatrixForm[ee]];
  Print["  B                 : ", MatrixForm[bb]];
  Print["  B = 0 ?           : ", Simplify[bb] === ConstantArray[0, {3, 3}]];
  Print["  eigenvalues of Q  : ", Simplify @ Eigenvalues[qq]];
  Print["  I, J              : ", {ii, jj}];
  Print["  I^3 - 27 J^2      : ", dsc, "   -> ",
        If[PossibleZeroQ[dsc], "ALGEBRAICALLY SPECIAL", "algebraically general"]];
  Print["  PETROV TYPE       : ", Style[typ, Bold], "   (Jordan form of Q)"];
  Print[""];
  <| "Label" -> label, "Psis" -> psis, "Type" -> typ, "E" -> ee, "B" -> bb,
     "Q" -> qq, "I" -> ii, "J" -> jj, "Data" -> dat |>
];


(* ::Chapter:: *)
(*8. FLRW  (expect type O, Q = 0)*)


(* ::Text:: *)
(*Cheapest example first, as in Part II. Conformally flat, so Q must vanish entirely: no*)
(*tide, no frame-dragging, nothing for a compass OR a gyroscope to detect.*)


$Assumptions = {aa[eta] > 0, eta \[Element] Reals};

flrwCoords = {eta, xx, yy, zz};
flrwMetric = aa[eta]^2 DiagonalMatrix[{-1, 1, 1, 1}];
flrwFrame  = {
  {1/aa[eta], 0, 0, 0},
  {0, 1/aa[eta], 0, 0},
  {0, 0, 1/aa[eta], 0},
  {0, 0, 0, 1/aa[eta]}
};

resFLRW = QReport["FLRW (k=0, conformal time)", flrwMetric, flrwCoords, flrwFrame];


(* ::Chapter:: *)
(*9. Schwarzschild  (expect type D, B = 0)*)


(* ::Text:: *)
(*Static orthonormal frame: e0 along the Killing time, e1 radial.*)
(**)
(*Part II used the KINNERSLEY tetrad and got Psi2 = -M/r^3. The frame here is a boosted*)
(*version of that one. Psi2 has boost weight zero, so it must come out identical -- and*)
(*that agreement across two notebooks with different tetrads is a real check, not a*)
(*formality. (Psi0 and Psi4 carry weights +2 and -2 and would NOT survive a boost. They*)
(*vanish here, so there is nothing to compare.)*)
(**)
(*Expect Q = Psi2 diag(2,-1,-1), hence E = diag(-2M/r^3, M/r^3, M/r^3). Feed that into*)
(*addot = -E a: radial STRETCH 2M/r^3, transverse SQUEEZE M/r^3. The 2:1 ratio IS the*)
(*type-D degeneracy. Spaghettification is not a metaphor for the algebra. It is the*)
(*algebra.*)


$Assumptions = {MM > 0, rr > 2 MM, 0 < th < Pi};

schwCoords = {tt, rr, th, ph};
ff         = 1 - 2 MM/rr;
schwMetric = DiagonalMatrix[{-ff, 1/ff, rr^2, rr^2 Sin[th]^2}];
schwFrame  = {
  {1/Sqrt[ff], 0, 0, 0},
  {0, Sqrt[ff], 0, 0},
  {0, 0, 1/rr, 0},
  {0, 0, 0, 1/(rr Sin[th])}
};

resSchw = QReport["Schwarzschild (static frame)", schwMetric, schwCoords, schwFrame];


(* Cross-check against Part II's Kinnersley Psi2. Must be 0. *)
Simplify[resSchw["Psis"][[3]] + MM/rr^3]


(* Q against the predicted type-D form. Must be a zero matrix. *)
Simplify[resSchw["Q"] - resSchw["Psis"][[3]] DiagonalMatrix[{2, -1, -1}]]


(* ::Chapter:: *)
(*10. Kerr  (expect type D, B nonzero)*)


(* ::Text:: *)
(*Boyer-Lindquist, Carter orthonormal frame (the locally non-rotating observer):*)
(**)
(*   e0 = ((r^2+a^2) d_t + a d_phi) / Sqrt(Sigma Delta)*)
(*   e1 = Sqrt(Delta/Sigma) d_r*)
(*   e2 = d_theta / Sqrt(Sigma)*)
(*   e3 = (a sin^2(th) d_t + d_phi) / (Sqrt(Sigma) sin(th))*)
(**)
(*THIS IS THE CELL THE ARTICLE TURNS ON.*)
(**)
(*Part II found Psi2 = -M/(r - i a cos(th))^3 and stopped there. Here the complex number*)
(*gets split. Since Q = Psi2 diag(2,-1,-1) for ANY type D,*)
(**)
(*   E = Re(Psi2) diag(2,-1,-1),     B = Im(Psi2) diag(2,-1,-1)*)
(**)
(*so B is PROPORTIONAL to E, with ratio tan(arg Psi2). Schwarzschild has a = 0, Psi2 is*)
(*real, and B vanishes. Kerr has a nonzero, Psi2 is complex, and B does not.*)
(**)
(*The imaginary part of Psi2 IS the gravitomagnetic field. Rotation enters the Weyl*)
(*tensor as a phase.*)


$Assumptions = {MM > 0, aa0 > 0, aa0 < MM, rr > 2 MM, 0 < th < Pi,
                MM \[Element] Reals, aa0 \[Element] Reals};

kerrCoords = {tt, rr, th, ph};
sig = rr^2 + aa0^2 Cos[th]^2;
del = rr^2 - 2 MM rr + aa0^2;

kerrMetric = {
  {-(1 - 2 MM rr/sig),          0,       0,   -2 MM rr aa0 Sin[th]^2/sig},
  {0,                           sig/del, 0,   0},
  {0,                           0,       sig, 0},
  {-2 MM rr aa0 Sin[th]^2/sig,  0,       0,
     (rr^2 + aa0^2 + 2 MM rr aa0^2 Sin[th]^2/sig) Sin[th]^2}
};

kerrFrame = {
  {(rr^2 + aa0^2)/Sqrt[sig del], 0, 0, aa0/Sqrt[sig del]},
  {0, Sqrt[del/sig], 0, 0},
  {0, 0, 1/Sqrt[sig], 0},
  {aa0 Sin[th]/Sqrt[sig], 0, 0, 1/(Sqrt[sig] Sin[th])}
};

resKerr = QReport["Kerr (Boyer-Lindquist, Carter frame)", kerrMetric, kerrCoords, kerrFrame];


(* Psi2 against Part II's closed form. Must be 0 -- boost weight zero. *)
Simplify[resKerr["Psis"][[3]] + MM/(rr - I aa0 Cos[th])^3]


(* ::Text:: *)
(*The claim, tested. E and B are the real and imaginary parts of the same type-D matrix.*)
(*Both cells must give zero matrices.*)


psi2K = -MM/(rr - I aa0 Cos[th])^3;

Simplify[resKerr["E"] - ComplexExpand[Re[psi2K]] DiagonalMatrix[{2, -1, -1}]]

Simplify[resKerr["B"] - ComplexExpand[Im[psi2K]] DiagonalMatrix[{2, -1, -1}]]


(* The ratio that sets the exaggeration factor in the gyroscope render. *)
ratioBE = Simplify @ ComplexExpand[Im[psi2K]/Re[psi2K]];

Print["|B|/|E| = tan(arg Psi2) = ", ratioBE];
Print["   at M=1, a=0.9, r=10, th=Pi/3 : ",
  N[ratioBE /. {MM -> 1, aa0 -> 9/10, rr -> 10, th -> Pi/3}]];


(* ::Chapter:: *)
(*11. pp-wave  (expect type N, Q nilpotent)*)


(* ::Text:: *)
(*Brinkmann, H = h(u)(x^2 - y^2), the "+" polarisation. Same metric and tetrad as Part II;*)
(*the frame is built by inverting NullFromOrthonormal on that tetrad, so the two notebooks*)
(*are directly comparable.*)
(**)
(*Expect Q^2 = 0 exactly. Then I = J = 0, which means*)
(**)
(*   Tr[E.E] = Tr[B.B]     and     Tr[E.B] = 0*)
(**)
(*that is, |E| = |B| and E is orthogonal to B. Those are the NULL FIELD conditions of*)
(*electromagnetism, F^2 = F.Fdual = 0, term for term. Part I called the Maxwell*)
(*correspondence an analogy. Here it stops being one.*)
(**)
(*One thing to be honest about in the post: B comes out as E rotated by 45 degrees. That*)
(*is NOT a second polarisation. The "x" polarisation lives in Im(h), not in B. Say it*)
(*before a careful reader says it for me.*)


$Assumptions = {uu \[Element] Reals, vv \[Element] Reals,
                xx \[Element] Reals, yy \[Element] Reals};

ppCoords = {uu, vv, xx, yy};
Hf       = hh[uu] (xx^2 - yy^2);
ppMetric = {{Hf, 1, 0, 0}, {1, 0, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}};

lP = {0, 1, 0, 0};
nP = {-1, Hf/2, 0, 0};

(* invert NullFromOrthonormal: e0 = (l+n)/Sqrt2, e1 = (l-n)/Sqrt2 *)
ppFrame = {
  (lP + nP)/Sqrt[2],
  (lP - nP)/Sqrt[2],
  {0, 0, 1, 0},
  {0, 0, 0, 1}
};

resPP = QReport["pp-wave (Brinkmann, + polarisation)", ppMetric, ppCoords, ppFrame];


(* Nilpotent of index 2. Must be a zero matrix. *)
Simplify[resPP["Q"] . resPP["Q"]]


(* The null-field conditions, explicitly. Both must be 0. *)
Simplify[Tr[resPP["E"] . resPP["E"]] - Tr[resPP["B"] . resPP["B"]]]

Simplify[Tr[resPP["E"] . resPP["B"]]]


(* ::Chapter:: *)
(*12. Kasner  (u = 2 -> type I;  u = 1 -> type D)*)


(* ::Text:: *)
(*e1 is aligned with the p1 axis, which is the distinguished one when p2 = p3. That is*)
(*deliberate: Q's degenerate eigenvalue sits along e1, so if the axisymmetric case really*)
(*is type D it should come out as Psi2 diag(2,-1,-1) with no rotation needed.*)
(**)
(*Both cases have real Psi, hence B = 0: Kasner is a PURELY ELECTRIC vacuum. An*)
(*anisotropic cosmology with a tide and no frame-dragging whatsoever.*)
(**)
(*u = 1 was the Part II surprise -- axisymmetric Kasner is type D, the same algebraic*)
(*skeleton as a black hole. Here we get to see WHY: the tidal ellipsoid degenerates.*)


$Assumptions = {tG > 0};

kasnerSetup[{p1_, p2_, p3_}] := {
  DiagonalMatrix[{-1, tG^(2 p1), tG^(2 p2), tG^(2 p3)}],
  {tG, xG, yG, zG},
  {{1, 0, 0, 0}, {0, tG^(-p1), 0, 0}, {0, 0, tG^(-p2), 0}, {0, 0, 0, tG^(-p3)}}
};


{gKa, cKa, frKa} = kasnerSetup[{-2/7, 3/7, 6/7}];
resKas2 = QReport["Kasner u=2, p = (-2/7, 3/7, 6/7)", gKa, cKa, frKa];


(* The 11-digit integer from Part II, reproduced by a completely different route.
   Both cells: the first prints it, the second must give 0. *)
Simplify[resKas2["I"]^3 - 27 resKas2["J"]^2]

Simplify[resKas2["I"]^3 - 27 resKas2["J"]^2 - 4665600/(13841287201 tG^12)]


{gKb, cKb, frKb} = kasnerSetup[{-1/3, 2/3, 2/3}];
resKas1 = QReport["Kasner u=1, p = (-1/3, 2/3, 2/3), axisymmetric", gKb, cKb, frKb];


(* Type D form, degenerate axis along e1 as predicted. Must be zero. *)
Simplify[resKas1["Q"] - resKas1["Psis"][[3]] DiagonalMatrix[{2, -1, -1}]]


(* ::Chapter:: *)
(*13. Summary*)


allQ = {resFLRW, resSchw, resKerr, resPP, resKas2, resKas1};

TableForm[
  {#["Label"],
   #["Type"],
   Simplify @ Eigenvalues[#["Q"]],
   If[Simplify[#["B"]] === ConstantArray[0, {3, 3}], "0", "nonzero"]} & /@ allQ,
  TableHeadings -> {None,
    {"Metric", "Petrov type (Jordan form of Q)", "eigenvalues of Q", "B"}}
]


(* ::Text:: *)
(*Read the B column. It is zero for everything except Kerr and the pp-wave -- the only two*)
(*spacetimes here that are, respectively, rotating and radiating. Everything else in the*)
(*table is a purely electric vacuum, and a gyroscope in it feels nothing that a speck of*)
(*dust would not.*)


(* ::Chapter:: *)
(*14. Synthetic pure types, for the tide renders*)


(* ::Text:: *)
(*Types II and III have no metric above. Part II said so plainly and this post does not*)
(*pretend otherwise. But the TIDE of a pure type is a statement about Q, not about a*)
(*metric, and Q is available directly from the dictionary. So the renders can still be*)
(*honest: what follows are points in the space of Weyl tensors, NOT solutions of*)
(*Einstein's equations, and the post must say so exactly where the animations appear.*)
(**)
(*Note what type II turns out to be: eigenvalues {2 Psi2, -Psi2, -Psi2}, identical to type*)
(*D, but with a Jordan block where D has a diagonal one. A Coulomb tide with a wave riding*)
(*on it. That is how the Part II debt gets paid without inventing a metric.*)


pureTypes = <|
  "D"   -> {0, 0, 1, 0, 0},
  "N"   -> {0, 0, 0, 0, 1},
  "III" -> {0, 0, 0, 1, 0},
  "II"  -> {0, 0, 1, 0, 1},
  "I"   -> {1/16, 0, -3/16, 0, 1/16}    (* Kasner u=2 shape, normalised *)
|>;

TableForm[
  Table[
    Module[{qq = qFromPsi[pureTypes[[kk]]]},
      {Keys[pureTypes][[kk]], PetrovFromQ[qq], Simplify @ Eigenvalues[qq],
       MatrixForm @ Simplify @ Re[qq], MatrixForm @ Simplify @ Im[qq]}],
    {kk, Length[pureTypes]}],
  TableHeadings -> {None, {"claimed", "PetrovFromQ", "eigenvalues of Q", "E", "B"}}
]


(* ::Chapter:: *)
(*15. Export for the Blender post*)


(* ::Text:: *)
(*Viz A consumes petrov_psis.json from Part II -- the quartic and its roots.*)
(*Viz B consumes THIS file -- the tidal tensors, their eigensystems, and the pure types.*)
(**)
(*The conventions block travels with the data on purpose. If a Blender script ever*)
(*disagrees with the algebra, the contract is in the file and the argument is short.*)


numRules = {MM -> 1, aa0 -> 9/10, rr -> 10, th -> Pi/3,
            hh[uu] -> 1, tG -> 1, aa[eta] -> 1};

packTide[res_] := Module[{ee, bb, es},
  ee = N[res["E"] /. numRules];
  bb = N[res["B"] /. numRules];
  es = Eigensystem[ee];
  <| "label"     -> res["Label"],
     "type"      -> res["Type"],
     "E"         -> ee,
     "B"         -> bb,
     "E_eigvals" -> es[[1]],
     "E_eigvecs" -> es[[2]],
     "psi"       -> (N[{Re[#], Im[#]}] & /@ (res["Psis"] /. numRules)) |>
];

packPure[kk_] := Module[{qq = N @ qFromPsi[pureTypes[kk]], er},
  er = Re[qq];
  <| "label"     -> "pure type " <> kk,
     "type"      -> kk,
     "synthetic" -> True,
     "E"         -> er,
     "B"         -> Im[qq],
     "E_eigvals" -> Eigensystem[er][[1]],
     "E_eigvecs" -> Eigensystem[er][[2]] |>
];

outDir = If[$Notebooks && Quiet[Check[NotebookDirectory[], $Failed]] =!= $Failed,
   NotebookDirectory[], Directory[]];

Export[
  FileNameJoin[{outDir, "petrov_tides.json"}],
  <| "conventions" -> <|
       "signature" -> "(-,+,+,+)",
       "eps_0123"  -> 1,
       "tetrad"    -> "l=(e0+e1)/Sqrt2, n=(e0-e1)/Sqrt2, m=(e2+I e3)/Sqrt2",
       "E"         -> "C_{i0j0}",
       "B"         -> "(1/2) eps_ikl C_{klj0}",
       "Q"         -> "E + I B",
       "I"         -> "Tr[Q.Q]/2",
       "J"         -> "-Det[Q]/2",
       "deviation" -> "addot^i = -E^i_j a^j",
       "spinforce" -> "F^i = -B^ij S_j  (MPD, verified in section 6)" |>,
     "params"  -> <| "M" -> 1, "a" -> 0.9, "r" -> 10,
                     "theta" -> N[Pi/3], "t" -> 1, "h" -> 1 |>,
     "metrics" -> (packTide /@ allQ),
     "pure"    -> (packPure /@ Keys[pureTypes]) |>,
  "JSON"
]


Print["wrote petrov_tides.json to ", outDir];
