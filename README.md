# Cycles-Simulation-Matrix
Code and script to run Cycles simulation matrix.


The code and script can generate operation files, control files, and multi-mode files for the simulation matrix, and perform the simulations.
The input generator is adopted from [@PSUmodeling](https://github.com/PSUmodeling)'s [repository](https://github.com/PSUmodeling/Input-Generator).
`base.operation` is the base operation file that should be used to generate the operation files for the matrix.
The `config.txt` contains the information regarding the operation matrix.
For details of the input generator, please check their README file.

Weather files, soil files, and crop files should be provided by the user and put into the `input` directory.
A `Cycles` executable should also be provided.
A `locations.txt` file is needed, which contains all the locations in the simulation matrix.
Each location should correspond to one weather file in the `input` directory.
For example, for a location of `8.88Nx27.12E`, a `met8.88Nx27.12E.weather` should be provided.

Run `make` to compile the input generator, and run `run_matrix.sh` to run the simulation matrix.
