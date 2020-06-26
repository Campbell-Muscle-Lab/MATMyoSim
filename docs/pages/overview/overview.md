---
title: Overview
has_children: False
nav_order: 4
---

# Overview

MATMyoSim is software that simulates the mechanical properties of half-sarcomeres using cross-bridge distribution techniques. It is designed as a research tool that can be used to test hypotheses and to help produce new insights into experimental data.

## Simulations

The calculations underlying the simulations are handled by the computer code. To run a simulation you only need to define:

+ a [model](../structures/model/model.html) - how the cross-bridges cycle, the passive elastic component, and whether or not multiple half-sarcomeres are linked in series to form a myofibril
+ a [protocol](../protocols/protocols.html) - a sequence of instructions that define the experiment including: the activating Ca<sup>2+</sup> concentration and any length changes or isotonic conditions that are imposed
+ [simulation options](../structures/simulation_options/simulation_options.html) - which describe how to display the data and run the calculations and display data

Once you have your model, protocol, and simulation options, you can run a simulation by passing your model, protocol, and options text files to a single MATLAB function.

## Other tools

[Batch structures](../structures/batch/batch.html) allow you to run several simulations in parallel. This is useful if you want to simulate a tension-pCa curve or investigate how a muscle responds to stretches of different speeds.

You can also fit models to experimental data using [optimization structures](../structures/optimization/optimization.html). This process adjusts the parameter values in your model until the model predictions match the experimental data to some desired tolerance.

## Next steps

To see examples, look at the [demos](../demos/demos.md)
+ [Getting started](../demos/getting_started/getting_started.html) is a good launching pad.
