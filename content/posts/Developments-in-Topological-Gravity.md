+++
date = '2025-02-11T12:41:55+01:00'
draft = false
title = 'Developments in Topological Gravity'
tags= ["2D-Gravity", "Matrix Models", "Topological Gravity", "Intersection Theory", "Master Seminar"]
+++

## Introduction
Two simple candidates exist for Quantum Gravity in 2 space-time dimensions: intersection theory on the moduli of Riemann spaces, i.e., topological gravity and matrix models. The latter have been extensively studied since the 1980s. 

The equivalence between these two candidate theories was conjectured by Witten and first proved by Kontsevich. A little over a decade ago, Maryam Mirzakhani proved the same, however, with an enhanced understanding of the Weil-Petersson volumes of moduli spaces of hyperbolic Riemann surfaces with boundary. We will look at an overview of Maryam's work before delving into topological gravity.

We will face two problems when trying to deal with topological gravity, one is the non-orientability of moduli space of hyperbolic Riemann surface, and two being the moduli space itself being a manifold with a boundary, making difficulties in defining intersection numbers.

Then we have an overview of matrix models of 2d gravity and get expressions for intersection numbers in terms of Virasoro constraints.

## Weil-Petersson Volumes and Modular Invariance

### Initial Steps

Let $\Sigma$ be a closed Riemann surface of genus $g$ having marked points $p_1, p_2, \cdots, p_n$. Let $\mathcal{L}_i$ be the cotangent space to $p_i$ in $\Sigma$. $\mathcal{L}_i$ varies as a complex line bundle over $\mathcal{M}_{g,n}$, the moduli space of genus $g$ with $n$ punctures as $\Sigma$ and $p_i$ vary. We know for a fact that these line bundles naturally extend over $\bar{\mathcal{M}}_{g,n}$, the Deligne-Mumford compactification of $\mathcal{M}_{g,n}$. We define $\psi_i = c_1(\mathcal{L}_i)$ the first Chern class of $\mathcal{L}_i$ which is a two dimensional cohomology class. For a $d > 0$ we set $\tau_{i,d} = \psi^{d}_i$, a $2d$ dimensional cohomology class.

The correlation functions of 2d topological gravity are the intersection numbers

$$
    \langle\tau_{d_1}\tau_{d_2}\cdots \tau_{d_n}\rangle = \int_{\bar{\mathcal{M}}_{g,n}} \tau_{1, d_1}\tau_{2, d_2}\cdots \tau_{n, d_n} = \int_{\bar{\mathcal{M}}_{g,n}} \psi^{d_1}_1\psi^{d_2}_2\cdots \psi^{d_n}_n
$$