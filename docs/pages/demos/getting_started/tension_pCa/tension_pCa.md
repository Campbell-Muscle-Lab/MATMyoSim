---
title: Tension-pCa
has_children: false
parent: Getting started
grand_parent: Demos
nav_order: 10
---

# Demo for tension-pCa

## Overview

This demo shows how to
+ simulate isometric contractions at different levels of Ca<sup>2+</sup> activation
+ fit a 4-parameter Hill-curve to the steady-state tension data

## How this works

The demo initiates a set of simulations using a [batch structure](../../../structures/batch/batch.html).

Each `job` in the batch defines a single simulation. A snippet of the file is shown here.

````
{
    "MyoSim_batch":
    {
        "job":
        [
            {
                "protocol_file_string": "sim_input/90/protocol_90.txt",
                "model_file_string": "sim_input/model_file.json",
                "options_file_string": "sim_input/sim_options.json",
                "results_file_string": "../../temp/sim_output/90/results_90.myo"
            },
            {
                "protocol_file_string": "sim_input/64/protocol_64.txt",
                "model_file_string": "sim_input/model_file.json",
                "options_file_string": "sim_input/sim_options.json",
                "results_file_string": "../../temp/sim_output/64/results_64.myo"
            },
            {
                "protocol_file_string": "sim_input/62/protocol_62.txt",
                "model_file_string": "sim_input/model_file.json",
                "options_file_string": "sim_input/sim_options.json",
                "results_file_string": "../../temp/sim_output/62/results_62.myo"
            },

            <SNIP>
        ]
    }
}
````

Note that every `job` uses the same
+ [model](../../../structures/model/model.html)
+ [simulation options](../../../simulation_options/simulation_options.html)
but a different
+ [protocol](../../../protocol/protocol.html)

The results for each job are also written to different output files

The function `run_batch(batch_structure)` uses a MATLAB parfor loop to run simulations on different threads in parallel. Once all of the jobs have finished, it is simple to extract the forces from each file and plot the resulting force-pCa curve.

## Instructions

+ Launch MATLAB
+ Change directory to the `<repo>\code\demos\getting_started\tension_pCa` folder in MATLAB
+ Open `demo_tension_pCa.m`
+ Press <kbd>F5</kbd> to run the demo

## Output

![tension_pCa_output](tension_pCa_output.png)

