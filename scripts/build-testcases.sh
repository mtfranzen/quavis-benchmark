#!/bin/bash
TEST_CASES_PATH=data/test-cases

# WIDE-TRIANGLE TEST CASE
## OBJ
OBJ_PATH=$TEST_CASES_PATH/wide_triangle.obj
rm -f $OBJ_PATH* > /dev/null
echo v 1 1 0 >> $OBJ_PATH
echo v -1 1 0 >> $OBJ_PATH
echo v 0 0.01 0.001 >> $OBJ_PATH
echo vn 1 1 1 >> $OBJ_PATH
echo f 1//1 2//1 3//1 >> $OBJ_PATH
## INPUT
echo 0 0 0 >> $OBJ_PATH.in
## OUTPUT # TODO: Compute correct volume/spherical area
echo 0 0 0 0.0826248813482 >> $OBJ_PATH.spherical_area.out
echo 0 0 0 0 >> $OBJ_PATH.volume.out

# OCTAHEDRON TEST CASE
OCTAHEDRON_RADIUS="10"
OCTAHEDRON_THETA_X=$(python -c "from math import *; print ' '.join(map(str, [x/4.0*pi for x in range(1)]))")
OCTAHEDRON_THETA_Y=$(python -c "from math import *; print ' '.join(map(str, [x/4.0*pi for x in range(1)]))")
OCTAHEDRON_THETA_Z=$(python -c "from math import *; print ' '.join(map(str, [x/4.0*pi for x in range(1)]))")

for R in $OCTAHEDRON_RADIUS
do
  for TX in $OCTAHEDRON_THETA_X
  do
    for TY in $OCTAHEDRON_THETA_Y
    do
      for TZ in $OCTAHEDRON_THETA_Z
      do
        FILENAME=octahedron.$R.$TX.$TY.$TZ.obj
        OBJ_PATH=$TEST_CASES_PATH/$FILENAME
        rm -f $OBJ_PATH* > /dev/null

        # vertices
        for i in $R -$R
        do
          echo v $(python -c "from math import *;print $i*cos($TY)*cos($TZ), $i*(cos($TX)*sin($TZ)+sin($TX)*sin($TY)*cos($TZ)), $i*(sin($TX)*sin($TZ)-cos($TX)*sin($TY)*cos($TZ))") >> $OBJ_PATH
          echo v $(python -c "from math import *;print $i*-cos($TY)*sin($TZ), $i*(cos($TX)*cos($TZ)-sin($TX)*sin($TY)*sin($TZ)), $i*(sin($TX)*cos($TZ)+cos($TX)*sin($TY)*sin($TZ))") >> $OBJ_PATH
          echo v $(python -c "from math import *;print $i*sin($TY), $i*-sin($TX)*cos($TY), $i*cos($TX)*cos($TY)") >> $OBJ_PATH
        done

        # TODO normals
        echo vn 1.0 1.0 1.0 >> $OBJ_PATH

        # faces
        for i in 1 4
        do
          for j in 2 5
          do
            for k in 3 6
            do
              echo "f" $i $j $k >> $OBJ_PATH
            done
          done
        done

        # observation points
        echo "0 0 0" >> $OBJ_PATH.in

        # correct result
        A=$(python -c "import math;print math.sqrt(2)*$R") # edge length
        echo 0 0 0 $(python -c "import math;print 4*math.pi") >> $OBJ_PATH.spherical_area.out
        echo 0 0 0 $(python -c "import math;print math.sqrt(2)/3.0*$A*$A*$A") >> $OBJ_PATH.volume.out
      done
    done
  done
done
