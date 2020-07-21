---
title: Batch
has_children: false
parent: Structures
nav_order: 3
---

# Batch

## Overview

Batch structures are stored in JSON format. MATMyoSim uses batch structures to run sets of simulations. An example would be generating a tension-pCa curve. Each simulation in the batch is a `job`.

## More details

Each job must define files describing
+ a [protocol](../../protocols/protocols.html)
+ a [model](../model/model.html)
+ [simulation options](../simulation_options/simulation_options.html)
+ an output file

## Caveat on figures

MATMyoSim uses a [parfor loop](https://www.mathworks.com/help/parallel-computing/parfor.html;jsessionid=20f5f321aa6f4a048088c320493c) to run jobs in parallel. As a result, it won't display figures defined in the [options structure](../simulation_options/simulation_options.html).

If you want to check individual jobs (which is nearly always a good idea), run them individually as opposed to using a batch strcture.

## Example

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
                "protocol_file_string": "sim_input/58/protocol_58.txt",
                "model_file_string": "sim_input/model_file.json",
                "options_file_string": "sim_input/sim_options.json",
                "results_file_string": "../../temp/sim_output/58/results_62.myo"
            },
            {
                "protocol_file_string": "sim_input/45/protocol_45.txt",
                "model_file_string": "sim_input/model_file.json",
                "options_file_string": "sim_input/sim_options.json",                
                "results_file_string": "../../temp/sim_output/45/results_45.myo"
            }
        ]
    }
}
````
