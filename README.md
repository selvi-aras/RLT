# RLT
Data and codes of the paper _A Reformulation-Linearization Technique for Optimization over Simplices_ by _Aras Selvi, Dick den Hertog, and Wolfram Wiesemann (2021)_.

The preprint (version of 8 May 2021) is available on [Optimization Online](http://www.optimization-online.org/DB_FILE/2020/11/8098.pdf). The paper is presented at [OR63](https://www.theorsociety.com/events/annual-conference/).

Update: On 13 September 2021, this paper is accepted for a publication in _Mathematical Programming_. 

## Introduction
This repository provides the following:
- TBA

## Dependencies
**MATLAB** - 

**YALMIP** - 

**MOSEK** - 

## Description
The following is a guide to use this repository. All the scripts are in ".m" format (MATLAB script files). 

The folders are summarized below (click on the relevant Section to get more information):
<details>
  <summary> <b> Main </b> </summary>
  
  This folder is about the problem of non-convex maximization over a simplex. Here, the objective function can be written as f + g where f is the norm of a linear transformation (that is obtained by random sampling) of the decision vector and g is a concave barrier function. In other words, this folder is dedicated to Section 3 of the paper where the objective function is visualized in Figure 1.
  
  The function ```optim.m``` takes an input ```n``` and generates an example problem randomly by sampling a random diagonal matrix and a random uniform rotation matrix (see reference [18]). The problem data is stored by saving ```D``` and ```Q``` where the notation is analogous to the paper's notation. Then, the function solves the RLT relaxation and saves the results as ```rlt``` where ```rlt[0]``` gives the corresponding upper bound and ```rlt[1]``` gives the time it took for the solver (MOSEK) to solve this relaxation. Afterwards, the function solves the RLT/SDP relaxation simply by adding an LMI constraint, and saves the solution as ```rltsdp``` where similarly ```rltsdp[0]``` gives the corresponding upper bound and ```rltsdp[1]``` gives thte time it took for the solver (MOSEK) to solve this relaxation. Finally, the function solves the proposed relaxation in our paper (simply by substituting the matrix variable with its analytical solution and rewritig expressions), and saves the solution as ```our``` where similarly ```our[0]``` gives the corresponding upper bound and ```our[1]``` gives the time it took for the solver (MOSEK). As we prove in our work, ```rlt[0] = rltsdp[0] = our[0]``` holds for all instances, however we typically have ```our[1] << rlt[1] << rltsdp[1]```.
  
  In Figure 2 of Section 3, we compare the median of ```our[1]```, ```rlt[1]```, and ```rltsdp[1]``` for 25 randomly generated instances, for all `n` varying between 10 and 1000.
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
