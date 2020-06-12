---
title: Simulation_options
has_children: false
parent: Structures
nav_order: 2
---

## Simulation options

Optimization structures are stored using the JSON format. Here is an example.

````
{
	"MyoSim_options":
	{
        "drawing_skip": 200,
        "figure_simulation_output": 1,
		"figure_rates": 2
	}
}
````
### drawing_skip

An integer, that defines the number of time-steps between updates to the simulation output figure

### figure_simulation_output

The number of a MATLAB figure showing the simulation output. Set to 0 to prevent showing the figure

### figure_rates

The number of a MATLAB figure showing the rate constants used for the simulation. Set to 0 to prevent showing the figure.