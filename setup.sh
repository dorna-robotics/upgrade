#!/bin/bash 
# api
cd api
sh setup.sh
cd ..

# firmware
cd dorna_lab
sh setup.sh
cd ..

# firmware
cd firmware
sh setup.sh
cd ..