+++
title= "Calculus to Linear Algebra"
date= 2022-03-29T11:43:36+01:00
draft= false
tags= ["Mathematics", "Calculus", "Linear-Algebra", "Matrix"]
+++

![Calculus to LA](img/calculus-to-linear-algebra.png)

{{< details summary="Warning!" >}}
This article is one among many salvaged from my previous blog! It is not on par with my demands of quality but I didn't feel like abandoning it.
{{< /details >}}

Consider the anti-derivative of $e^x \sin x$ or more commonly called as integral of $e^x \sin x$.
$$
\int e^x \sin x d x
$$

## Calculus Method:
A traditional calculus course teaches us to implement this integral by using integration by parts:

$$
\int f d g=f g-\int g d f
$$
taking $f=\sin x$ and $d g=e^x d x$, we have $d f=\cos x d x$ and $g=e^x$. Substituting these results, we have
$$
\int e^x \sin x d x=e^x \sin x-\int e^x \cos x d x
$$
Let us take $I=\int e^x \sin x d x$ and implement integration by parts for the integral in RHS ( $\int e^x \cos x d x$ ). Doing so would yield the following,
$$
I=e^x \sin x-e^x \cos x-I+C
$$
where, $C$ is some constant. After rearranging for $I$, we have

$$
I=\int e^x \sin x d x=\frac{1}{2}\left(e^x \sin x-e^x \cos x\right)+C_2
$$
with $C_2=C / 2$. Quite a simple calculation you might say, but here is a more simpler method to get us to this solution. Let us employ Linear Algebra here.

## Linear Algebra Method

Consider a vector space $ V=\operatorname{span}\\{e^x \sin x, e^x \cos x\\}$. This is a 2-dimensional vector space. Let us take a linear transformation
$$
D: V \rightarrow V \text { s.t } D=\frac{d}{d x}
$$
a general element in $V$ can be written as $a e^x \sin x+b e^x \cos x$, and applying $D$ on this element we get:
$$
D\left(a e^x \sin x+b e^x \cos x\right)=(a+b) e^x \cos x+(a-b) e^x \sin x
$$
Now, our idea here is that any linear transformation on a finitedimensional vector space can be represented by a finite-dimensional matrix. If we are to entertain the infinite-dimensional vector spaces like in Quantum Mechanics, there are certain things we can and can't do, but we can discuss that in another article. So, let us represent $D$ as a matrix operator on $V$. We have taken $e^x \sin x$ and $e^x \cos x$ to be the basis vector of our vector space, hence, we can use a $2-\mathrm{d}$ matrix to represent $D$ and 2-d row vector for basis. Putting those words in the math, we can write the above transformation as
$$
D\left[\begin{array}{l}
a \\\\
b
\end{array}\right]=\left[\begin{array}{l}
a-b \\\\
a+b
\end{array}\right]
$$
we can deduce $D$ as follows:
$$
D=\left[\begin{array}{cc}
1 & -1 \\\\
1 & 1
\end{array}\right]
$$
Now, taking anti-derivative or integral is the reverse of derivative, hence, we need $D^{-1}$ to entertain such transformations. We have,
$$
D^{-1}=\frac{1}{2}\left[\begin{array}{cc}
1 & 1 \\\\
-1 & 1
\end{array}\right]
$$

Now, let us do our integral problem from the above:
$$
\int e^x \sin x d x
$$
This is as simple as applying the linear transformation of $D^{-1}$ now. The integral can be written as
$$
I \rightarrow\left[\begin{array}{l}
1 \\\\
0
\end{array}\right]
$$
and applying
$$D^{-1} I=\frac{1}{2}\left[\begin{array}{cc}
1 & 1 \\\\
-1 & 1
\end{array}\right]\left[\begin{array}{l}
1 \\\\
0
\end{array}\right]=\left[\begin{array}{c}
1 / 2 \\\\
-1 / 2
\end{array}\right]$$

translating the RHS to our bases, we have
$$
D^{-1} I=\frac{1}{2}\left(e^x \sin x-e^x \cos x\right)+C
$$

# But Why?
You may be wondering this method is much more complicated than the integration by parts. It is true, but this method is simpler to implement in computer algebra systems than the calculus we are so fond of! If you give it a thought about how to make a computer compute the integral, this sounds to be fairly simple than the first step. And in many situations when we are not able to solve integrals directly, we can do so using the above method. We just need to be creative enough to pick the right vector space.