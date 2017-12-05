#!/bin/bash
cd /home/simbody/build
source activate opensim-rl
cmake ..
make -j4
cp simbody-visualizer `which simbody-visualizer`
