#!/bin/bash

CUBE_SHADER_PATH=data/shaders/cube
SPHERICAL_SHADER_PATH=data/shaders/spherical

for f in $CUBE_SHADER_PATH/*.comp
do
  glslangValidator -V $f -o $f.spv
done

for f in $SPHERICAL_SHADER_PATH/*.comp
do
  glslangValidator -V $f -o $f.spv
done
