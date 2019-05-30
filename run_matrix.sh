#!/bin/bash

# generate operation files
./input_gen base.operation config.txt ./input

# locations for simulation matrix
loc_file="locations.txt"

# day of year for re-initialization
DOY=1

START_YEAR=2000
END_YEAR=2017

# operation for baseline
BASE=CP1PD1FT1FR3

# dimensions of simulation matrix
NCP=1
NPD=8
NFT=1
NFR=6

while IFS= read -r line
do
    # display $line or do somthing with $line
    printf '%s\n' "$line"

    # create input directory
    mkdir -p input

    # write control files
    cat << EOF > "input/$line.ctrl"
SIMULATION_START_YEAR   ${START_YEAR}
SIMULATION_END_YEAR     ${END_YEAR}
ROTATION_SIZE           1

## SIMULATION OPTIONS ##
USE_REINITIALIZATION    0
ADJUSTED_YIELDS         0
HOURLY_INFILTRATION     1
AUTOMATIC_NITROGEN      0
AUTOMATIC_PHOSPHORUS    0
AUTOMATIC_SULFUR        0
DAILY_WEATHER_OUT       1
DAILY_CROP_OUT          1
DAILY_RESIDUE_OUT       1
DAILY_WATER_OUT         1
DAILY_NITROGEN_OUT      1
DAILY_SOIL_CARBON_OUT   1
DAILY_SOIL_LYR_CN_OUT   1
ANNUAL_SOIL_OUT         1
ANNUAL_PROFILE_OUT      1
SEASON_OUT              1

## OTHER INPUT FILES ##
CROP_FILE               GenericCrops.crop
OPERATION_FILE          $BASE.operation
SOIL_FILE               pongo.soil
WEATHER_FILE            met$line.weather
REINIT_FILE             N/A
EOF

    # write multi-mode files
    cat << EOF > "input/$line.multi"
SIM_CODE                    ROTATION_YEARS  START_YEAR  END_YEAR    USE_REINIT  CROP_FILE           OPERATION_FILE          SOIL_FILE   WEATHER_FILE            REINIT_FILE         HOURLY_INFILTRATION AUTOMATIC_NITROGEN
EOF

    for (( CP = 1; CP <= $NCP; CP++ ))
    do
        for (( PD = 1; PD <= $NPD; PD++ ))
        do
            for (( FT = 1; FT <= $NFT; FT++ ))
            do
                for (( FR = 1; FR <= $NFR; FR++ ))
                do
                    cat << EOF >> "input/$line.multi"
${line}.CP${CP}PD${PD}FT${FT}FR${FR}   1               2000        2017        1           GenericCrops.crop   CP1PD${PD}FT1FR$FR.operation  pongo.soil  met8.88Nx27.12E.weather 8.88Nx27.12E.reinit 1                   0
EOF
                done
            done
        done
    done

# Run baseline simulation in baseline model with spinup
echo "Run baseline simulation in spin-up mode and generate re-initialization file"
./Cycles -s -l $DOY ${line}

# Copy generated re-initialization file into input directory
mv output/${line}/reinit.dat input/${line}.reinit

# Run batch simulation with re-initialization
echo "Run batch simulations using re-initialization"
./Cycles -m ${line}.multi

done <"$loc_file"
