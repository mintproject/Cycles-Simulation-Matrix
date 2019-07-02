#!/bin/bash

######################
# Specify parameters #
######################
# Crop file
CROP_FILE=GenericCrops.crop

# Soil file
SOIL_FILE=pongo.soil

# Day of year for re-initialization
DOY=1

# Simulation start and end years
START_YEAR=2000
END_YEAR=2017

# Operation for baseline
BASE=CP1PD1FT1FR3

# Dimensions of simulation matrix
NCP=1
NPD=8
NFT=1
NFR=6
NWF=4

############################
# Generate operation files #
############################
# Need to generate operation files for no-weeds baselines
./input_gen base.operation config.txt ./input

# Generate operation files with weeds
./input_gen base_w_weeds.operation config_w_weeds.txt ./input

####################################
# Write locations to location file #
####################################
loc_file="locations.txt"

for f in input/*.weather
do
    str=${f#"input/met"}
    str=${str%".weather"}
    echo "${str}"
done > ${loc_file}

#########################################
# Generate control and multi-mode files #
#########################################
# Create input directory
mkdir -p input

while IFS= read -r line
do
    # Write control files
    cat << EOF > "input/${line}.ctrl"
SIMULATION_START_YEAR   ${START_YEAR}
SIMULATION_END_YEAR     ${END_YEAR}
ROTATION_SIZE           20

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
CROP_FILE               ${CROP_FILE}
OPERATION_FILE          ${BASE}.operation
SOIL_FILE               ${SOIL_FILE}
WEATHER_FILE            met${line}.weather
REINIT_FILE             N/A
EOF

    # Write multi-mode files
    cat << EOF > "input/${line}.multi"
SIM_CODE                        ROTATION_YEARS  START_YEAR  END_YEAR    USE_REINIT  CROP_FILE           OPERATION_FILE              SOIL_FILE   WEATHER_FILE            REINIT_FILE         HOURLY_INFILTRATION AUTOMATIC_NITROGEN
EOF

    for (( CP = 1; CP <= ${NCP}; CP++ ))
    do
        for (( PD = 1; PD <= ${NPD}; PD++ ))
        do
            for (( FT = 1; FT <= ${NFT}; FT++ ))
            do
                for (( FR = 1; FR <= ${NFR}; FR++ ))
                do
                    for (( WF = 1; WF <= ${NWF}; WF++ ))
                    do
                        cat << EOF >> "input/${line}.multi"
${line}.CP${CP}PD${PD}FT${FT}FR${FR}WF${WF}    20              ${START_YEAR}        ${END_YEAR}        1           ${CROP_FILE}   CP${CP}PD${PD}FT${FT}FR${FR}WF${WF}.operation   ${SOIL_FILE}  met${line}.weather ${line}.reinit 1                   0
EOF
                    done
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
