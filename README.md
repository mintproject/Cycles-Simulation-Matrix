# Cycles-Simulation-Matrix
Code and script to run Cycles simulation matrix.

The code and script can generate operation files, control files, and multi-mode files for the simulation matrix, and perform the simulations.
The input generator is adopted from [@PSUmodeling](https://github.com/PSUmodeling)'s [repository](https://github.com/PSUmodeling/Input-Generator).
It generates multiple input files by replacing keywords in a template with different options.
`base.operation` is the operation file template that should be used to generate the operation matrix.
The `config.txt` contains the different options to replace the keywords in the template.
For details of the input generator, please check their README file.

Weather files, soil files, and crop files used for the matrix should be provided by the user and put into the `input` directory.
A `Cycles` executable should also be provided.
It is assumed that each location is driven by a different weather file.
The weather files should have file names as `met*.weather`.
Currently it is assumed that all locations share the same soil file and crop file.
The soil and crop file names should be specified in the `run_matrix.sh`.

Run `make` to compile the input generator, and run `run_matrix.sh` to run the simulation matrix.
