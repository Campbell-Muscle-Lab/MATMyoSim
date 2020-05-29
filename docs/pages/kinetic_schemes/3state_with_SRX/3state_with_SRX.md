---
title: 3state_with_SRX
has_children: false
parent: Kinetic schemes
nav_order: 1
---

# 3state_with_SRX

This scheme is similar to that described in [PMC6084639](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6084639/). See the publication for additional details.

See [ramp_3](../../demos/ramps/ramp_3/ramp_3.html) for an example simulation using this scheme.

Myosin heads transition between an OFF, an ON, and a force-generating state. Binding sites on actin switch between states that are unavailable and available for myosin heads to attach to.

![kinetic_scheme](kinetic_scheme.png)

The fluxes are as defined in [PMC6084639](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6084639/) except that

J4 = k_4_0 + (k_4_1 * x<sup>4</sup>)

The model parameters that need to be defined in the [model file](..//..//structures//model//model.html) file are:

+ k_1
+ k_force
+ k_2
+ k_3
+ k_4_0
+ k_4_1
+ k_on
+ k_off
+ k_coop
