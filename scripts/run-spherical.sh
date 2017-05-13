#!/bin/bash
QUAVIS_PATH=quavis/spherical/bin/quavis-generic-service
SHADERS_PATH=data/shaders/spherical
OUTPUT_PATH=output/spherical
TEST_CASES_PATH=data/test-cases

# two shaders we test:
# TODO: Area
FUNCTIONS="volume"

# arguments
#TODO: WIDTHS
ALPHAS="3 2 1 0.1 0.01"
REPEATS=10000
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
            FILENAME=$OUTPUT_PATH/${testcase##*/}.$function.$alpha.$repeat.$max.out
            $QUAVIS_PATH -s $SHADERS_PATH/$function.1.comp.spv -t $SHADERS_PATH/$function.2.comp.spv -a $alpha -u $repeat -r $rmax -f $testcase < $testcase.in > $FILENAME
          done
        done
    done
  done
done
