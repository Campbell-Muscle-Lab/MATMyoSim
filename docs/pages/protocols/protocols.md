---
title: Protocols
has_children: False
nav_order: 7
---

# Protocols

In MATMyoSim, protocols are text files that contain 4 columns of data. Each row in the file defines the properties for the corresponding time-step in the simulation.

The fields are as follows
+ dt
  + the duration of the time-step in s
    + Note that this should be less than 1/(fastest rate) in your simulation
+ dhsl
  + the length-change in nm per half-sarcomere imposed during each time-step
+ pCa
  + the activating Ca<sup>2+</sup> concentration for the time-step where pCa = -log<sub>10</sub>[Ca<sup>2+</sup>]
+ Mode
  + one of:
    + -2 which means length control, that is the length of the muscle system is controlled
    + -1 which means _potentially_ slack, that is the system is under length control, but it could have fallen slack if the muscle is being shortened quickly.
      + If the muscle falls slack, the half-sarcomeres shorten at their V<sub>max</sub> and the total length of the half-sarcomeres will be longer than the length of the muscle system.
      + This is useful for simulations of k_<sub>tr</sub> maneuvers and muscles that are being shortened at or faster than V<sub>max</sub>.
    + x >= 0.0 which means tension control, that is the muscle system will change length so that the force per unit area is equal to the value of x


## Example

Here is an artificially simple example

````
dt     dhsl  Mode  pCa
0.001  0     -2    9
0.001  0     -2    9
0.001  0     -2    4.5
0.001  0     -2    4.5
0.001  0     -2    4.5
0.001  0.5   -2    4.5
0.001  0.5   -2    4.5
0.001  -10   -1    4.5
0.001  0     100    4.5
0.001  0     100    4.5
````

This protocol defines a simulation that lasts 10 ms (10 time-steps of 0.001 s)
+ The first 2 time-steps are at pCa 9.0 and isometric.
+ The next 3 time-steps are at pCa 4.5 and isometric.
+ The next 2 time-steps at at pCa 4.5 but the system is stretched by 0.5 nm per half-sarcomere in each one.
+ The next time step shortens the muscle by 10 nm per half-sarcomere and the software checks to see if the system has fallen slack.
+ The last 2 time-steps are under tension control so that the muscle adopts the length at which force per unit area is equal to 100 N m<sup>-2</sup>

## More examples

To see more examples, look at the [demos](../demos/demos.md)
+ [twitches_1](../demos/demos/twitches/twitches_1/twitches_1.html) is a good place to start

