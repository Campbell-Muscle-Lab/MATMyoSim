---
title: Overview
has_children: False
nav_order: 4
---

# Overview

MATMyoSim is software that simulates the mechanical properties of half-sarcomeres using cross-bridge distribution techniques.

Before you run a simulation you need to create 3 text files which define
+ a [model](../structures/model/model.html) which describes
  + a muscle
    + 1 or more half-sarcomeres in series (that is, a myofibril) with the option of a series elastic componentand an optional series elastic component
  + a [kinetic scheme](../kinetic_schemes/kinetic_schemes.html)
    + the states that myosin heads can cycle between
  + the parallel elastic component responsible for resting tension
  + values for every parameter in the model
+ a [protocol](../protocols/protocols.html)
  + a sequence of instructions that define the following conditions for every time-step in the simulation
    + the duration of the time-step in s
    + the activating Ca<sup>2+</sup> concentration (defined as pCa = -log<sub>10</sub>[Ca<sup>2+</sup>])
    + the length-change in nm per half-sarcomere imposed during each time-step
    + the mode for the time-step, that is, whether the system is under
      + length control
      + tension control
      + potentially slack
+ [simulation options](../structures/simulation_options/simulation_options.html)
  + which describe how to run the calculations and display data

Once you have your model, protocol, and simulation options, you can run a simulation by passing your model, protocol, and options text files to a single MATLAB function.

To see examples, look at the [demos](../demos/demos.md)
+ [twitches_1](../demos/demos/twitches/twitches_1/twitches_1.html) is a good place to start
