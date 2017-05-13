#!/bin/bash
SPHERICAL_QUAVIS_PATH=quavis/spherical/bin/quavis-generic-service
SPHERICAL_SHADERS_PATH=data/shaders/spherical
SPHERICAL_OUTPUT_PATH=output/spherical

CUBE_QUAVIS_PATH=quavis/cube/bin/quavis-generic-service
CUBE_SHADERS_PATH=data/shaders/cube
CUBE_OUTPUT_PATH=output/cube

TEST_CASES_PATH=data/test-cases

# two shaders we test:
# TODO: Area
FUNCTIONS="volume"

# arguments
#TODO: WIDTHS
ALPHAS="0.01"
REPEATS=1
RMAX=10000

for function in $FUNCTIONS
do
    for alpha in $ALPHAS
    do
      for repeat in $REPEATS
      do
        for rmax in $RMAX
        do
          for testcase in $TEST_CASES_PATH/*.obj
          do
            FILENAME=$SPHERICAL_OUTPUT_PATH/${testcase##*/}.$function.$alpha.$repeat.$max.out
            $SPHERICAL_QUAVIS_PATH -s $SPHERICAL_SHADERS_PATH/$function.1.comp.spv -t $SPHERICAL_SHADERS_PATH/$function.2.comp.spv -a $alpha -u $repeat -r $rmax -f $testcase < $testcase.in > $FILENAME
          done
        done
    done
  done
done

for function in $FUNCTIONS
do
      for repeat in $REPEATS
      do
        for rmax in $RMAX
        do
          for testcase in $TEST_CASES_PATH/*.obj
          do
            FILENAME=$CUBE_OUTPUT_PATH/${testcase##*/}.$function.$alpha.$repeat.$max.out
            $CUBE_QUAVIS_PATH -s $CUBE_SHADERS_PATH/$function.1.comp.spv -t $CUBE_SHADERS_PATH/$function.2.comp.spv -u $repeat -r $rmax -f $testcase < $testcase.in > $FILENAME
          done
        done
    done
done
