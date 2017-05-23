# Requirements for the application & the benchmark
 * libglm-dev
 * libvulkan-dev
 * [GlslangValidator](https://cvs.khronos.org/svn/repos/ogl/trunk/ecosystem/public/sdk/tools/glslang/Install/)
 * Vulkan capable graphics card

# Accessing the data
The data used in the paper which is generated using the benchmark script includes the following files:

* `output/output.csv` for the octahedron and the triangle test case.
* `output/output.geojson.csv` for the performance benchmark test case.

Each row in the CSV files contains the following rows:

 * `MAPPING`: The mapping used for the test (either `SPHERICAL` for the equirectangular projection, or `CUBE` for the cubemap)
 * `FUNCTION`: The function evaluated in the compute shader (either `spherical_area` or `volume`)
 * `OBJ`: The test case name
 * `WIDTH`: The resolution (width). For the equirectangular mapping, height:=0.5*width. For the cubemap, height:=width
 * `REPEATS`: The number of times a point was tested (it is used to average the performance)
 * `RMAX`: The maximum rendering distance
 * `GEOM_OFF?`: 1 iff the handling of degenerate primitives has been disabled
 * `TESS_OFF?`: 1 iff the tessellation has been disabled
 * `ALPHA`: The alpha constant used to control the tessellation and bound the error
 * `X`: The x-coordinate of the point being tested
 * `Y`: The Y-coordinate of the point being tested
 * `Z`: The z-coordinate of the point being tested
 * `EXPECTED_RESULT`: The expected result for the test-case. This value is correct in the two instances used for the error analysis in the paper:
  * `FUNCTION=spherical_area,OBJ=wide_triangle.obj`
  * `FUNCTION=volume,OBJ=octahedron.1.0.0.0.0.obj`
 * `ACTUAL_RESULT`: The result computed with our application
 * `GRAPHICS_FPS`: The average rendering FPS over the number of trials (column `REPEATS`)
 * `COMPUTE_FPS`: The average computing FPS over the number of trials (column `REPEATS`)

# Replicating the benchmark (tested on Ubuntu 16.04)
The benchmark script will automatically produce all necessary raw data, glsl shaders and binaries used to create the figures in the paper. It can be executed with the parameter space used in the paper using the command

`bash run.sh`

The parameter space can be adjusted in the file `scripts/run-quavis.sh`

# Running the equirectangular mapping as standalone
If you want to use the application yourself e.g. to produce rendered images, proceed as follows (tested under Ubuntu 16.04, GTX 1060)

1. If a computer is used without a monitor installed (such as a server instance), use the following commands to set up the environment:
 * `/usr/bin/X  :1 &> /dev/null & echo $!`
 * `export DISPLAY=:1`
2. Compile the two project using the following command.
 * `bash scripts/build-quavis.sh`
3. Compile the compute shader you want to use to SPIR-V (using the glslangValidator). The easiest way is to use one provided by the benchmark.
4. Run the analysis `quavis/spherical/bin/quavis-generic-service` where
 * `-a` is the maxium angle in radians
 * `-r` is the maximum visible distance
 * `-s` is the first-stage compute shader (aggregating row-wise)
 * `-t` is the second-stage compute shader (aggregating column-wise)
 * `-f` is the geojson file to be analysid
 * `-d 1` set to 1 to store debug images into the `images/` folder
 * `-l 1` set to 1 to store the images with lines-only (no filling). Note that the results become wrong in this mode
 * `-u <n>` the number of times each point should be benchmarked
 * `-x` the width
 * `-w` the workgroup size for the compute shader (this should be width/2)
 * `-G 1` to disable the geom-shader
 * `-T 1` to disable the tess-shader
 * *stdin* is the list of observation points in the format

```
x1 y1 z1
x2 y2 z2
...

Example:

`glslangValidator -V quavis/spherical/examples/shaders/shader.area.comp -o quavis/spherical/examples/shaders/shader.area.comp.spv`

`glslangValidator -V quavis/spherical/examples/shaders/shader.2.area.comp -o quavis/spherical/examples/shaders/shader.2.area.comp.spv`

`quavis/spherical/bin/quavis-generic-service -s "quavis/spherical/examples/shaders/shader.area.comp.spv" -t "quavis/spherical/examples/shaders/shader.2.area.comp.spv" -f "quavis/spherical/examples/data/mooctask.geojson" -d 1 -a 0.1 -r 100.0 -x 1024 -w 512 -u 10 < quavis/spherical/examples/data/mooktask_grid.txt`


# Running the cubemap as standalone

Proceed exactly the same as with the equirectangular map above, but use the directory `quavis/cube/` instead:

`glslangValidator -V quavis/cube/examples/shaders/shader.area.comp -o quavis/spherical/examples/shaders/shader.area.comp.spv`

`glslangValidator -V quavis/cube/examples/shaders/shader.2.area.comp -o quavis/cube/examples/shaders/shader.2.area.comp.spv`

`quavis/cube/bin/quavis-generic-service -s "quavis/cube/examples/shaders/shader.area.comp.spv" -t "quavis/cube/examples/shaders/shader.2.area.comp.spv" -f "quavis/cube/examples/data/mooctask.geojson" -d 1 -a 0.1 -r 100.0 -x 512 -w 512 -u 10 < quavis/cube/examples/data/mooktask_grid.txt`
