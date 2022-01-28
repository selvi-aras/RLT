# RLT
Data generation and optimization codes of the paper _A Reformulation-Linearization Technique for Optimization over Simplices_ by _Aras Selvi, Dick den Hertog, and Wolfram Wiesemann (2021)_.

The preprint (version of 8 May 2021) is available on [Optimization Online](http://www.optimization-online.org/DB_FILE/2020/11/8098.pdf). The paper is presented at [OR63](https://www.theorsociety.com/events/annual-conference/), and at the [2022 INFORMS Computing Society Conference](https://ics2022tampa.eng.usf.edu/).

Update: On 13 September 2021, this paper is accepted for a publication in _Mathematical Programming_. On 5 November 2021, it is published online (see [Springer Link page](https://rdcu.be/cATD4))

## Introduction
This repository provides functions that:
- generate the random data explained in Section 3, Appendix B.1, and Appendix B.2 of the paper
- provide helper functions (e.g., decomposing an indefinite matrix as a difference of two psd matrices)
- solve the RLT and RLT/SDP relaxations of the non-convex optimization problems that are studied in the experiments
- solve the relaxations that are proposed in this paper (including non-convex optimization over a simplex, a hypercube, cartesian product of a simplex and a hypercube, as well as indefinite quadratic optimization).

## Dependencies
**MATLAB** - We use MATLAB 2018b to run the scripts. The scripts are compatible with the [latest release](https://uk.mathworks.com/downloads/) 2021a of MATLAB.

**YALMIP** - We use [YALMIP R20200930](https://yalmip.github.io/download/) to formulate optimization problems and solve them. The scripts are compatible with the [latest release](https://github.com/yalmip/YALMIP/releases/tag/R20210331) (as of 26 October 2021) R20210331 of YALMIP.

**MOSEK** - We use [MOSEK 9.2.28](https://www.mosek.com/documentation/). The scripts are compatible with the [latest release](https://www.mosek.com/documentation/) (as of 26 October 2021). Version >= 9.0 is required for latest conic optimization features (i.e., in the paper we use logarithmic barrier functions that can be reformulated as exponential cones).

## Description
The following is a guide to use this repository. All the scripts are in ".m" format (MATLAB script files). 

The folders are summarized below (click on the relevant Section to get more information):
<details>
  <summary> <b> Main </b> </summary>
  
  This folder is about the problem of non-convex maximization over a simplex. Here, the objective function can be written as f + g where f is the norm of a linear transformation (that is obtained by random sampling) of the decision vector and g is a concave barrier function. In other words, this folder is dedicated to Section 3 of the paper where the objective function is visualized in Figure 1.
  
  The function ```optim.m``` takes an input ```n``` and generates an example problem randomly by sampling a random diagonal matrix and a random uniform rotation matrix (see reference [18]). The problem data is stored by saving ```D``` and ```Q``` where the notation is analogous to the paper's notation. Then, the function solves the RLT relaxation and saves the results as ```rlt``` where ```rlt[1]``` gives the corresponding upper bound and ```rlt[2]``` gives the time it took for the solver (MOSEK) to solve this relaxation. Afterwards, the function solves the RLT/SDP relaxation simply by adding an LMI constraint, and saves the solution as ```rltsdp``` where similarly ```rltsdp[1]``` gives the corresponding upper bound and ```rltsdp[2]``` gives thte time it took for the solver (MOSEK) to solve this relaxation. Finally, the function solves the proposed relaxation in our paper (simply by substituting the matrix variable with its analytical solution and rewritig expressions), and saves the solution as ```our``` where similarly ```our[1]``` gives the corresponding upper bound and ```our[2]``` gives the time it took for the solver (MOSEK). As we prove in our work, ```rlt[1] = rltsdp[1] = our[1]``` holds for all instances, however we typically have ```our[2] << rlt[2] << rltsdp[2]```.
  
  In Figure 2 of Section 3, we compare the median of ```our[2]```, ```rlt[2]```, and ```rltsdp[2]``` for 25 randomly generated instances, for all `n` varying between 10 and 1000.
</details>

<details>
  <summary> <b> Non-convex hypercubic optimization </b> </summary>
  
  This folder is about the problem of non-convex maximization over a hypercube. Here, the objective function is almost identical with the one in ```Main/optim.m```, with the only difference being we do not subtract a vector of 1/n's from the decision vector (since the feasible region is not a simplex anymore). In other words, this folder is dedicated to the **first** problem in Appendix Section B.1 of the paper.
  
  The function ```optim.m``` takes inputs ```n``` and ```rhs``` where in the paper we always take ```rhs = 1``` (i.e., we have a unit hypercube). The function then generates an example problem randomly similarly as in ```Main/optim.m```. The problem data is stored by saving ```D``` and ```Q``` where the notation is analogous to the paper's notation. Then, by using MOSEK solver, the function obtains the traditional RLT relaxation, the RLT/SDP relaxation, and the relaxation we propose, and saves these as ```rlt```, ```rltsdp```, and ```our```, respectively. As before, `rlt[1]` corresponds to the relaxation of the RLT relaxation, and `rlt[2]` corresponds to the solver time (same as `rltsdp` and `our`). As the original problem is not defined over a simplex, we do not have `rlt[1] = rltsdp[1]` anymore. However, as we proved in Theorem 3, we always have ```our[1] <= rltsdp[1] <= rlt[1]```, and our numerical experiments show that we have ```our[1] < rltsdp[1] < rlt[1]``` in general. Finally, our method uses exponentially many variables to reformulate the problem as a non-convex optimization problem over a simplex, hence the runtime of our method will depend on `n`, while we always have `rlt[2] <= rltsdp[2]` by definition. 
  
  In Figure 3 of Section B.1, we compare the median of solution times ```our[2]```, ```rlt[2]```, and ```rltsdp[2]``` as well as the median deviation of ```rlt[1]``` and ```rltsdp[1]``` from ```our[1]``` for 25 randomly generated instances, for all `n` varying between 2 and 10.
</details>
  
<details>
  <summary> <b> Non-convex over cube and simplex </b> </summary>
  
  This folder is about the problem of non-convex maximization over the cartesian product of a hypercube (of size `k`, this vector is called `y`) and a simplex (of size `n - k`, this vector is called `x`). Here, the objective function is a combination of the ones in ```Main/optim.m``` and ```Non-convex hypercubic optimization/optim.m```, namely the convex function f similarly is the norm of a linear transofmraion of the input, however 1/(n-k) is being subtracted from the components of `x`, as well as, the logarithmic barrier function slightly varies between `x` and `y` as their extreme points are different. This folder is dedicated to the **second** problem in Appendix Section B.1 of the paper.
  
  The function ```optim.m``` takes inputs ```n``` and `k`, where in the paper we always take ```k = 3``` (i.e., the hypercube is three dimensional). The function then generates an example problem randomly similarly as in ```Main/optim.m```. The problem data is stored by saving ```D``` and ```Q``` where the notation is analogous to the paper's notation. Then, by using MOSEK solver, the function obtains the traditional RLT relaxation, the RLT/SDP relaxation, and the relaxation we propose, and saves these as ```rlt```, ```rltsdp```, and ```our```, respectively. Here, our implementation does not define `x` and `y` separately, we rather keep only one vector `x` of size `n`, hence define some additional matrices (`TX`, `TY`, `MX`, `MY`) to be able to compactly define the relaxation problems (e.g., `TX * x` extracts the original `x` and `TY * x` extracts the original `y`). As before, `rlt[1]` corresponds to the relaxation of the RLT relaxation, and `rlt[2]` corresponds to the solver time (same as `rltsdp` and `our`). As the original problem is not defined over a simplex, we do not have `rlt[1] = rltsdp[1]` anymore. However, as we proved in Theorem 3, we always have ```our[1] <= rltsdp[1] <= rlt[1]```, and our numerical experiments show that we have ```our[1] < rltsdp[1] < rlt[1]``` in general. Finally, although our method uses exponentially many variables to reformulate the `y` variable, as `k` is fixed, the proposed relaxation is very fast for larger `n` values and it also outperforms the traditional RLT and RLT/SDP relaxations in terms of the runtimes.
  
  In Figure 4 of Section B.1, we compare the median of solution times ```our[2]```, ```rlt[2]```, and ```rltsdp[2]``` for 25 randomly generated instances, for all `n` varying between 10 and 1000.
</details>

<details>
  <summary> <b> Indefinite Quadratic Optimization </b> </summary>
  
  This folder is about the problem of indefinite quadratic maximization over a simplex. Here, the objective function is obtained via constructing a quadratic coefficient matrix by sampling its eigenvalues in certain ranges ([−7.5, 2.5] (type 1) or [−5, 5] (type 2)) as well as by sampling a uniformly sampled rotation matrix. This folder is dedicated to Appendix Section B.2 of the paper.
  
  The function ```optim.m``` takes inputs ```n``` and `type`, where the latter is either `1` or `2`. The function then generates an example problem randomly (see Section B.2 for the details). The problem data is stored by saving ```Q``` where the notation is analogous to the paper's notation (i.e., the objective function is `x' Q x`). The function then calls `eigen_trick.m` by inputting `Q` to obtain `Qplus` and `Qminus`, two psd matrices such that `Q = Qplus - Qminus`. The function then applies the traditional RLT and RLT/SDP relaxations to the whole non-convex term `x' Q x` (i.e., similar to `Main/optim.m` where g function is omitted), and these solutions are saves as `rlt` and `rltsdp`. Then, the function solves the proposed relaxation by simply decomposing f(x) = `x' Qplus x` and g(x) = `x' Qminus x` and applying the RLT relaxation only to the term f(x). As proven in the paper, applying RLT or RLT/SDP relaxation on f(x) are identical and we can also omit the matrix variable `X` by using `diag(x)` instead. Hence, we compare our method with `rlt` and `rltsdp` relaxations on the whole `x' Q x` function, and these techniques are in general incomparable. As our solution is using less variables and constraints than the RLT and RLT/SDP relaxations, we have `our[2] << rltsdp[2] << rlt[2]`. Moreover, the relaxations satisfy `rltsdp[1] <= rlt[1]` and `rltsdp[1] <= our [1]`, and comparison of `rlt[1]` and `our[1]` depends on the type of the problem.

  In Figure 5 of Section B.2, we compare the median relaxation gaps of `our[2]` and `rlt[2]` with respect to `rltsdp[2]` for 25 randomly generated instances of both problem types, for all `n` varying between 10 and 100. In Figure 6 of Section B.2, the median solution times of `rlt[1]`, `rltsdp[1]`, and `our[1]` are compared for 25 randomly generated instances of problem type 1 (in terms of the runtimes type 1 and type 2 are similar), for all `n` varying between 10 and 1000.
</details>  

## Final Notes
The following scripts are also available upon request:
- Global optimization of the original convex maximization problems via global optimization solvers
- Our simulation codes where we iteratively call the optimization functions provided here to randomly generate problems, solve them, save the solutions, and plot the results. 

## Thank You
Thank you for your interest in our work. If you found this work useful in your research and/or applications, please star this repository and cite:
```
@article{selvi2020reformulation,
  title={A Reformulation-Linearization Technique for Optimization over Simplices},
  author={Selvi, Aras and Den Hertog, Dick and Wiesemann, Wolfram},
  journal={Available on Optimization Online},
  volume={8098},
  year={2020}
}
```
Please contact Aras (a.selvi19@imperial.ac.uk) if you encounter any issues using the scripts. For any other comment or question, please do not hesitate to contact us:

[Aras Selvi](https://www.imperial.ac.uk/people/a.selvi19) _(a.selvi19@imperial.ac.uk)_

[Dick den Hertog](https://www.uva.nl/en/profile/h/e/d.denhertog/d.den-hertog.html) _(d.denhertog@uva.nl)_

[Wolfram Wiesemann](http://wp.doc.ic.ac.uk/wwiesema) _(ww@imperial.ac.uk)_
