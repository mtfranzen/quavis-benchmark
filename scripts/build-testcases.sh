#!/bin/bash
TEST_CASES_PATH=data/test-cases
rm $TEST_CASES_PATH/*

# OCTAHEDRON - TODO: Add rotation
OCTAHEDRON_RADIUS=100.0
OCTAHEDRON_ROTATION_THETA=0
OCTAHEDRON_ROTATION_PHI=0

FILENAME=octahedron.$OCTAHEDRON_RADIUS.$OCTAHEDRON_ROTATION_THETA.$OCTAHEDRON_ROTATION_PHI.obj
OBJ_PATH=$TEST_CASES_PATH/$FILENAME

# vertices
for i in $OCTAHEDRON_RADIUS -$OCTAHEDRON_RADIUS
do
  echo "v" $i 0 0 >> $OBJ_PATH
  echo "v" 0 $i 0 >> $OBJ_PATH
  echo "v" 0 0 $i >> $OBJ_PATH
done

# faces
for i in 1 4
do
  for j in 2 5
  do
    for k in 3 6
    do
      echo "f" $i $j $k > $OBJ_PATH
    done
  done
done

# observation points
echo "0 0 0" >> $OBJ_PATH.in

# correct result
echo $(python -c "import math;print math.sqrt(2)/3.0*$OCTAHEDRON_RADIUS*$OCTAHEDRON_RADIUS*$OCTAHEDRON_RADIUS") >> $OBJ_PATH.out
