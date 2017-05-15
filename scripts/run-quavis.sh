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
RMAX="10" # DO NOT CHANGE THIS!
ALPHAS="0.01"
GEOM_OFF="0"
TESS_OFF="0"
REPEATS="1000"
WIDTHS_SPHERICAL="1024"
WIDTHS_CUBE="256"

# compute total number of combinations for display
TOTAL_COMB=$(echo 1+$(echo $FUNCTIONS | grep -o ' ' | wc -l) | bc)
TOTAL_COMB=$(echo "$TOTAL_COMB*(1+$(echo $REPEATS | grep -o ' ' | wc -l))" | bc)
TOTAL_COMB=$(echo "$TOTAL_COMB*$(ls $TEST_CASES_PATH/*.obj | wc -l)" | bc)
TOTAL_COMB_SPHERICAL=$(echo "$TOTAL_COMB*(1+$(echo $WIDTHS_SPHERICAL | grep -o ' ' | wc -l))" | bc)
TOTAL_COMB_SPHERICAL=$(echo "$TOTAL_COMB_SPHERICAL*(1+$(echo $ALPHAS | grep -o ' ' | wc -l))" | bc)
TOTAL_COMB_SPHERICAL=$(echo "$TOTAL_COMB_SPHERICAL*(1+$(echo $GEOM_OFF | grep -o ' ' | wc -l))" | bc)
TOTAL_COMB_SPHERICAL=$(echo "$TOTAL_COMB_SPHERICAL*(1+$(echo $TESS_OFF | grep -o ' ' | wc -l))" | bc)
TOTAL_COMB_CUBE=$(echo "$TOTAL_COMB*(1+$(echo $WIDTHS_CUBE | grep -o ' ' | wc -l))" | bc)

# Removing old output file
rm -f $OUTPUT_FILE >> /dev/null

# Running spherical benchmark
i=1
echo "MAPPING;FUNCTION;OBJ;WIDTH;REPEATS;RMAX;ALPHA;GEOM_OFF?;TESS_OFF?;X;Y;Z;EXPECTED_RESULT;ACTUAL_RESULT;GRAPHICS_FPS;COMPUTE_FPS;" >> $OUTPUT_FILE
for function in $FUNCTIONS
do
  for alpha in $ALPHAS
  do
    for repeat in $REPEATS
    do
      for rmax in $RMAX
      do
        for geom in $GEOM_OFF
        do
          for tess in $TESS_OFF
          do
            for width in $WIDTHS_SPHERICAL
            do
              for testcase in $TEST_CASES_PATH/*.obj
              do
                echo "Running Spherical..." $i/$TOTAL_COMB_SPHERICAL
                workgroups=$(echo $width/2 | bc)
                EXPECTED=$(cat $testcase.$function.out | sed "s/ /;/g")
                RESULT=$($SPHERICAL_QUAVIS_PATH -s $SPHERICAL_SHADERS_PATH/$function.1.comp.spv -t $SPHERICAL_SHADERS_PATH/$function.2.comp.spv -G $geom -T $tess -x $width -w $workgroups -a $alpha -u $repeat -r $rmax -f $testcase < $testcase.in | tail -n +2 | cut -d " " -f4-7 | sed "s/ /;/g")
                paste -d';' <(echo "$EXPECTED") <(echo "$RESULT") | while read line;
                do
                  echo "SPHERICAL;$function;${testcase##*/};$width;$repeat;$rmax;$geom;$tess;$alpha;$line" >> $OUTPUT_FILE
                done
                i=$(echo $i+1 | bc)
              done
            done
          done
        done
      done
    done
  done
done

# Running cubemap benchmark
i=1
for function in $FUNCTIONS
do
  for repeat in $REPEATS
  do
    for rmax in $RMAX
    do
      for width in $WIDTHS_CUBE
      do
        for testcase in $TEST_CASES_PATH/*.obj
        do
          echo "Running Cubemap..." $i/$TOTAL_COMB_CUBE
          workgroups=$width
          EXPECTED=$(cat $testcase.$function.out | sed "s/ /;/g")
          RESULT=$($CUBE_QUAVIS_PATH -s $CUBE_SHADERS_PATH/$function.1.comp.spv -d 1 -t $CUBE_SHADERS_PATH/$function.2.comp.spv -G $geom -T $tess -x $width -w $workgroups -a $alpha -u $repeat -r $rmax -f $testcase < $testcase.in | tail -n +2 | cut -d " " -f4-7 | sed "s/ /;/g")
          paste -d';' <(echo "$EXPECTED") <(echo "$RESULT") | while read line;
          do
            echo "CUBE;$function;${testcase##*/};$width;$repeat;$rmax;;;;;$line" >> $OUTPUT_FILE
          done
          i=$(echo $i+1 | bc)
        done
      done
      done
    done
  done
done
