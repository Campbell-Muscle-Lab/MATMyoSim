---
title: Model
has_children: false
parent: Structures
nav_order: 1
---

# Model

Models are defined in JSON format. Here is an example.

````
{
    "MyoSim_model":
    {
        "muscle_props":
        {
            "no_of_half_sarcomeres": 1,
            "series_k_linear_per_hs": 0
        },
        "hs_props":
        {
            "kinetic_scheme": "3state_with_SRX_and_exp_k4",
            "hs_length": 1300,
            "myofilaments":
            {
                "bin_min": -10,
                "bin_max": 10,
                "bin_width": 0.5,
                "thick_filament_length": 815,
                "thin_filament_length": 1120,
                "bare_zone_length": 80,
                "k_falloff": 0
            },
            "parameters":
            {
                "k_1": 1,
                "k_force": 1e-4,
                "k_2": 100,
                "k_3": 200,
                "k_4_0": 100,
                "k_4_1": 1,
                "x_ps": 5,
                "k_on": 8e7,
                "k_off": 200,
                "k_coop": 1,
                "passive_force_mode": "linear",
                "passive_hsl_slack": 1265,
                "passive_k_linear": 14,
                "compliance_factor": 0.5,
                "cb_number_density": 6.9e16,
                "k_boltzmann": 1.38e-23,
                "temperature": 288,
                "max_rate": 5000
            }
        }
    }
}
````

## muscle_props

In MatMyoSim, a muscle is composed of 1 or more half-sarcomeres connected in series to form a myofibril. Optionally, the myofibril can be connected in series with a spring to mimic series compliance.

+ no_of_half_sarcomeres - an integer defining the number of half-sarcomeres in series in the myofibril
+ series_k_linear_per_hs - the stiffness in N m<sup>-1</sup> of the series spring normalized to each half-sarcomere
  + set to 0 for no spring (no series compliance)

Note that the total series compliance for a myofibril with n half-sarcomeres will be n * series_k_linear_per_hs. Defining the parameter in the model file relative to the half-sarcomere simplifies comparing simulations of myofibrils with different numbers of half-sarcomeres. (Each half-sarcomere will still shorten by the same amount if no_of_half_sarcomeres is changed.)


## hs_props

This structure defines the properties of the half-sarcomeres

+ kinetic_scheme - a string defining the kinetic scheme for myosin heads. Currently one of:
  + [3state_with_SRX](../../kinetics_schemes/3state_with_SRX/3state_with_SRX.html)
  + [3state_with_SRX_and_exp_k4](../../kinetic_schemes/3state_with_SRX_and_exp_k4/3state_with_SRX_and_exp_k4.html)
  + 4state_with_SRX

+ hs_length - the initial length in nm of a single half-sarcomere.
  + Note that the half-sarcomere will shorten below this value if there is a finite series compliance.
  + The total length of the system is `no_of_half_sarcomeres * hs_length`

### myofilaments

+ bin_min - the minimum possible value of x in nm for the cross-bridge distribution
+ bin_max - the maximum possible value of x in nm for the cross-bridge distribution
+ bin_width - the width of bins in the cross-bridge distribution. Smaller values of bin_width give cross-bridge distributions with finer resolution but take longer to calculate
+ filament lengths - all in nm. These are used to calculate the overlap of the thick and thin filaments, and thus thenumber of myosin heads that are able to interact with actin
  + thick_filament_length
  + thin_filament_length
  + bare_zone_length

### parameters

The parameters needed for this section depend on the [kinetic scheme](../../kinetic_schemes/kinetics_schemes.html) that is being used.

#### Passive force

if `passive_force_mode` is `linear`
+ F_pas = passive_k_linear * (hs_length - passive_hsl_slack)

if `passive_force_mode` is `exponential`
+ hs_length > passive_hsl_slack
  + F_pas = passive_sigma * exp((hs_length - passive_hsl_slack) / passive_L)
+ else
  + F_pas = passive_sigma * exp(-(hs_length - passive_hsl_slack) / passive_L)

#### Other

+ compliance_factor - a float defining the proportion of a change in half-sarcomere length that is transmitted to cross-bridges. (This is a perhaps-overly simple way of accounting for myofilament compliance.)
  + for example, if `compliance_factor` is 0.5, each myosin head will be stretched by 1 nm if the half-sarcomere length increases by 2 nm

+ max_rate - a float defining the maximum rate considered in the simulations. Rate values above this will be limited to max_rate.
  + for example, if max_rate is 5000, and the rate constant for an exponential function is calculated to be 7000 s<sup>-1</sup> for a large value of x, the calculations will constrain the rate to 5000 s<sup>-1</sup>. This speeds up the calculations when the differential equations are stiff. Note that calculations should also use a time-step smaller than (1 / max_rate) for accuracy.

