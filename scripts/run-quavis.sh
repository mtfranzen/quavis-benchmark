#!/bin/bash
SPHERICAL_QUAVIS_PATH=quavis/spherical/bin/quavis-generic-service
SPHERICAL_SHADERS_PATH=data/shaders/spherical

CUBE_QUAVIS_PATH=quavis/cube/bin/quavis-generic-service
CUBE_SHADERS_PATH=data/shaders/cube

TEST_CASES_PATH=data/test-cases
OUTPUT_FILE=output/output.csv

# two shaders we test:
# TODO: Area
FUNCTIONS="spherical_area volume"

# arguments
#TODO: WIDTHS
ALPHAS="1 0.1 0.01"
REPEATS=1000
RMAX=10000 # DO NOT CHANGE THIS!

rm -f $OUTPUT_FILE >> /dev/null

echo "MAPPING;FUNCTION;OBJ;REPEATS;RMAX;ALPHA;X;Y;Z;EXPECTED_RESULT;ACTUAL_RESULT;GRAPHICS_FPS;COMPUTE_FPS;" >> $OUTPUT_FILE
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
          EXPECTED=$(cat $testcase.$function.out | sed "s/ /;/g")
          RESULT=$($SPHERICAL_QUAVIS_PATH -s $SPHERICAL_SHADERS_PATH/$function.1.comp.spv -t $SPHERICAL_SHADERS_PATH/$function.2.comp.spv -a $alpha -u $repeat -r $rmax -f $testcase < $testcase.in | tail -n +2 | cut -d " " -f4-7 | sed "s/ /;/g")
          paste -d';' <(echo "$EXPECTED") <(echo "$RESULT") | while read line;
          do
            echo "SPHERICAL;$function;${testcase##*/};$repeat;$rmax;$alpha;$line" >> $OUTPUT_FILE
          done
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
        EXPECTED=$(cat $testcase.$function.out | sed "s/ /;/g")
        RESULT=$($CUBE_QUAVIS_PATH -s $CUBE_SHADERS_PATH/$function.1.comp.spv -t $CUBE_SHADERS_PATH/$function.2.comp.spv -a $alpha -u $repeat -r $rmax -f $testcase < $testcase.in | tail -n +2 | cut -d " " -f4-7 | sed "s/ /;/g")
        paste -d';' <(echo "$EXPECTED") <(echo "$RESULT") | while read line;
        do
          echo "CUBE;$function;${testcase##*/};$repeat;$rmax;;$line" >> $OUTPUT_FILE
        done
      done
    done
  done
done
