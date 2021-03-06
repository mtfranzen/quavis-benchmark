#!/bin/bash
SPHERICAL_QUAVIS_PATH=quavis/spherical/bin/quavis-generic-service
SPHERICAL_SHADERS_PATH=data/shaders/spherical

CUBE_QUAVIS_PATH=quavis/cube/bin/quavis-generic-service
CUBE_SHADERS_PATH=data/shaders/cube

TEST_CASES_PATH=data/test-cases
OUTPUT_FILE_OBJ=output/output.csv
OUTPUT_FILE_GEOJSON=output/output.geojson.csv

# Here, we specify the combinations for which the test is being run
# The functions used to evaluate each test case (see the computeshaders in data/shaders)
FUNCTIONS="spherical_area volume"
# The maximum rendering distances
RMAX="10000.0"
# The different alpha values
ALPHAS=$(python -c "from math import *; print ' '.join(map(str, [pi/x for x in range(1,301,10)]))")
# Handling degenrate primitives on/off
GEOM_OFF="0 1"
# Tessellation on/off
TESS_OFF="0 1"
# The number of times each point is rendered (for all benchmarks, used to average FPS)
REPEATS="100"
# The resolutions (width x width/2) the equirectangular map is tested
WIDTHS_SPHERICAL="2048 1024 512 256 128 64 32 16"
# The resolutions (width x width) with which the cubemap is tested
WIDTHS_CUBE="1024 512 256 128 64 32 16"

# compute total number of test run combinations
TOTAL_COMB=$(echo 1+$(echo $FUNCTIONS | grep -o ' ' | wc -l) | bc)
TOTAL_COMB=$(echo "$TOTAL_COMB*(1+$(echo $REPEATS | grep -o ' ' | wc -l))" | bc)
TOTAL_COMB=$(echo "$TOTAL_COMB*($(ls $TEST_CASES_PATH/*.obj | wc -l) + $(ls $TEST_CASES_PATH/*.geojson | wc -l))" | bc)
TOTAL_COMB_SPHERICAL=$(echo "$TOTAL_COMB*(1+$(echo $WIDTHS_SPHERICAL | grep -o ' ' | wc -l))" | bc)
TOTAL_COMB_SPHERICAL=$(echo "$TOTAL_COMB_SPHERICAL*(1+$(echo $ALPHAS | grep -o ' ' | wc -l))" | bc)
TOTAL_COMB_SPHERICAL=$(echo "$TOTAL_COMB_SPHERICAL*(1+$(echo $GEOM_OFF | grep -o ' ' | wc -l))" | bc)
TOTAL_COMB_SPHERICAL=$(echo "$TOTAL_COMB_SPHERICAL*(1+$(echo $TESS_OFF | grep -o ' ' | wc -l))" | bc)
TOTAL_COMB_CUBE=$(echo "$TOTAL_COMB*(1+$(echo $WIDTHS_CUBE | grep -o ' ' | wc -l))" | bc)

# Removing old output file and shaders
rm -f $OUTPUT_FILE_OBJ >> /dev/null
rm -f $OUTPUT_FILE_GEOJSON >> /dev/null
rm -f $SPHERICAL_SHADERS_PATH/auto* >> /dev/null

# Create and compile shaders for the equirectangular map
for rmax in $RMAX
do
  for function in $FUNCTIONS
  do
    for width in $WIDTHS_SPHERICAL
    do
      height=$(echo $width/2 | bc)
      f=$SPHERICAL_SHADERS_PATH/auto_$function.$width.$rmax.1.comp
      echo "#version 450
#define WIDTH $width
#define HEIGHT $height
#define R_MAX $rmax" > $f
      cat $SPHERICAL_SHADERS_PATH/$function.1.comp >> $f
      glslangValidator -V $f -o $f.spv

      f=$SPHERICAL_SHADERS_PATH/auto_$function.$width.$rmax.2.comp
      echo "#version 450
#define WIDTH $width
#define HEIGHT $height
#define R_MAX $rmax" > $f
      cat $SPHERICAL_SHADERS_PATH/$function.2.comp >> $f
      glslangValidator -V $f -o $f.spv
    done
  done
done

# Create and compile shaders for the cubemap
for rmax in $RMAX
do
  for function in $FUNCTIONS
  do
    for width in $WIDTHS_CUBE
    do
      f=$CUBE_SHADERS_PATH/auto_$function.$width.$rmax.1.comp
      echo "#version 450
#define WIDTH $width
#define HEIGHT $width
#define R_MAX $rmax" > $f
      cat $CUBE_SHADERS_PATH/$function.1.comp >> $f
      glslangValidator -V $f -o $f.spv

      f=$CUBE_SHADERS_PATH/auto_$function.$width.$rmax.2.comp
      echo "#version 450
#define WIDTH $width
#define HEIGHT $width
#define R_MAX $rmax" > $f
      cat $CUBE_SHADERS_PATH/$function.2.comp >> $f
      glslangValidator -V $f -o $f.spv
    done
  done
done

# Running spherical benchmark
i=1
echo "MAPPING;FUNCTION;OBJ;WIDTH;REPEATS;RMAX;GEOM_OFF?;TESS_OFF?;ALPHA;X;Y;Z;EXPECTED_RESULT;ACTUAL_RESULT;GRAPHICS_FPS;COMPUTE_FPS;" >> $OUTPUT_FILE_OBJ
echo "MAPPING;FUNCTION;OBJ;WIDTH;REPEATS;RMAX;GEOM_OFF?;TESS_OFF?;ALPHA;X;Y;Z;EXPECTED_RESULT;ACTUAL_RESULT;GRAPHICS_FPS;COMPUTE_FPS;" >> $OUTPUT_FILE_GEOJSON
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
              # Run OBJs
              for testcase in $TEST_CASES_PATH/*.obj
              do
                echo "Running Spherical..." $i/$TOTAL_COMB_SPHERICAL
                workgroups=$(echo $width/2 | bc)
                EXPECTED=$(cat $testcase.$function.out | sed "s/ /;/g")
                RESULT=$($SPHERICAL_QUAVIS_PATH -s $SPHERICAL_SHADERS_PATH/auto_$function.$width.$rmax.1.comp.spv -t $SPHERICAL_SHADERS_PATH/auto_$function.$width.$rmax.2.comp.spv -G $geom -T $tess -x $width -w $workgroups -a $alpha -u $repeat -r $rmax -f $testcase < $testcase.in | tail -n +2 | cut -d " " -f4-7 | sed "s/ /;/g")
                paste -d';' <(echo "$EXPECTED") <(echo "$RESULT") | while read line;
                do
                  echo "SPHERICAL;$function;${testcase##*/};$width;$repeat;$rmax;$geom;$tess;$alpha;$line" >> $OUTPUT_FILE_OBJ
                done
                i=$(echo $i+1 | bc)
              done

              # Run Geojson
              for testcase in $TEST_CASES_PATH/*.geojson
              do
                echo "Running Spherical..." $i/$TOTAL_COMB_SPHERICAL
                workgroups=$(echo $width/2 | bc)
                EXPECTED=$(cat $testcase.$function.out | sed "s/ /;/g")
                RESULT=$($SPHERICAL_QUAVIS_PATH -s $SPHERICAL_SHADERS_PATH/auto_$function.$width.$rmax.1.comp.spv -t $SPHERICAL_SHADERS_PATH/auto_$function.$width.$rmax.2.comp.spv -G $geom -T $tess -x $width -w $workgroups -a $alpha -u $repeat -r $rmax -f $testcase < $testcase.in | tail -n +2 | cut -d " " -f4-7 | sed "s/ /;/g")
                paste -d';' <(echo "$EXPECTED") <(echo "$RESULT") | while read line;
                do
                  echo "SPHERICAL;$function;${testcase##*/};$width;$repeat;$rmax;$geom;$tess;$alpha;$line" >> $OUTPUT_FILE_GEOJSON
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
          RESULT=$($CUBE_QUAVIS_PATH -s $CUBE_SHADERS_PATH/auto_$function.$width.$rmax.1.comp.spv -t $CUBE_SHADERS_PATH/auto_$function.$width.$rmax.2.comp.spv -G $geom -T $tess -x $width -w $workgroups -a $alpha -u $repeat -r $rmax -f $testcase < $testcase.in | tail -n +2 | cut -d " " -f4-7 | sed "s/ /;/g")
          paste -d';' <(echo "$EXPECTED") <(echo "$RESULT") | while read line;
          do
            echo "CUBE;$function;${testcase##*/};$width;$repeat;$rmax;;;;$line" >> $OUTPUT_FILE_OBJ
          done
          i=$(echo $i+1 | bc)
        done

        for testcase in $TEST_CASES_PATH/*.geojson
        do
          echo "Running Cubemap..." $i/$TOTAL_COMB_CUBE
          workgroups=$width
          EXPECTED=$(cat $testcase.$function.out | sed "s/ /;/g")
          RESULT=$($CUBE_QUAVIS_PATH -s $CUBE_SHADERS_PATH/auto_$function.$width.$rmax.1.comp.spv -t $CUBE_SHADERS_PATH/auto_$function.$width.$rmax.2.comp.spv -G $geom -T $tess -x $width -w $workgroups -a $alpha -u $repeat -r $rmax -f $testcase < $testcase.in | tail -n +2 | cut -d " " -f4-7 | sed "s/ /;/g")
          paste -d';' <(echo "$EXPECTED") <(echo "$RESULT") | while read line;
          do
            echo "CUBE;$function;${testcase##*/};$width;$repeat;$rmax;;;;$line" >> $OUTPUT_FILE_GEOJSON
          done
          i=$(echo $i+1 | bc)
        done
      done
    done
  done
done
