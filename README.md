# SoftwareEffortEstimation
This repository contains the code used fro the paper:

Liyan Song; Leandro L. Minku; Xin Yao. "Software Effort Interval Prediction via Bayesian Inference and Synthetic Bootstrap Resampling", ACM Transactions on Software Engineering Methodology, 28(1):1–46, Februray 2019.

Author of code:

Liyan Song, Southern University of Science and Technology, China.


The code only requires basic Matlab libraries, which can all be downloaded with a purchased Matlab licenses.

There are two folders as below:
  * "matlab/" -- containing the codes implementing this tool;
  * "data_example/" -- containing the edited software projects for SEE produced based on Nasa93.

To start the code, one needs to configure the files and paths by running the script "config.m" or type in the command window the following line

    >> config()

This function configures the directories between code scripts and the data set and among all scripts, so that the scripts can call each other and load the data set as if they are in a one-layer directory.


Examples of toy software effort estimations can be found in the folder "matlab/examples/".

A quick start of running the whole implementation of SynB-RVM can refer to the script "example_run_SynB_RVM.m" in this folder, by typing in the command window the following line

    >> example_run_SynB_RVM()

The foler "matlab/example-para_tune" contains the examples that tune the parameter of SynB-RVM. To run this example, the following command can be used
    
    >> experiment_para_tune()


Information about how the training and prediction algorithms are implemented can be found in Algorithm 2 and Algorithm 3 of the paper, respectively.


<p align="right">Enjoy~</p>

<p align="right">Liyan Song</p>

<p align="right">8th June 2021</p>


