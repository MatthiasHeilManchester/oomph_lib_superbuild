#! /bin/bash

CGAL_ROOT_DIR=$1
LOG_DIR=$2

echo "Entering CGAL root directory: ${CGAL_ROOT_DIR}"
cd ${CGAL_ROOT_DIR}

echo "Will log to directory: ${LOG_DIR}"

if [ -e oomph_test ]; then
    echo "Deleting oomph_test directory (resumably there from "
    echo "previous installation without wiping sources)"
    rm -rf oomph_test
fi

mkdir oomph_test
cp examples/Spatial_searching/nearest_neighbor_searching.cpp oomph_test
cd oomph_test

if [ ! -e ../scripts/cgal_create_CMakeLists ]; then
    echo "ERROR: The CGAL script "
    echo " "
    echo "   scripts/cgal_create_CMakeLists"
    echo " "
    echo "that we use to test our CGAL installation doesn't exist (any more?)"
    exit 1
fi

# Create CMakeLists file
../scripts/cgal_create_CMakeLists -s nearest_neighbor_searching &>"${LOG_DIR}/build.log"

# Configure
echo "Building CGAL test with compiler_spec_string: "$compiler_spec_string
echo "Building CGAL test with build_opts: "$build_opts
echo $compiler_spec_string" cmake -DCGAL_DIR=.. -DCMAKE_BUILD_TYPE=Release $build_opts .  2>&1 >> ${LOG_DIR}/build.log" >.full_build_file
source .full_build_file

# Build
echo " "
make 2>&1 >>"${LOG_DIR}/build.log"
if [ ! -e ./nearest_neighbor_searching ]; then
    echo "ERROR: CGAL test code "
    echo " "
    echo "  "$(pwd)"/nearest_neighbor_searching"
    echo " "
    echo "which was copied from "
    echo" "
    echo "    examples/Spatial_searching/"
    echo " "
    echo "failed to build. Check ${LOG_DIR}/build.log!"
else
    echo "Yay! CGAL test code "
    echo " "
    echo "  "$(pwd)"/nearest_neighbor_searching"
    echo " "
    echo "which was copied from examples/Spatial_searching/"
    echo "was built!"
    # run
    output=$(./nearest_neighbor_searching)
    echo " "
    if [ "$output" != "0 0 0" ]; then
        echo "ERROR: CGAL failed: Output should be: \"0 0 0\" but is \"$output\""
        exit 1
    else
        echo "Yay: CGAL test passed: Output should be: \"0 0 0\" and is \"$output\""
    fi
    echo " "
fi

exit 0
