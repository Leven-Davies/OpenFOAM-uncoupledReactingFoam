#!/bin/bash
#SBATCH -A DEDOUSSI-SL3-CPU
#SBATCH -p icelake
#SBATCH --qos intr
#SBATCH -N 1
#SBATCH -n 8  # Matching requirements from example below. Tune according to your own needs.
#SBATCH -t 01:00:00
#SBATCH -o openfoam.out
#SBATCH -e openfoam.err
module purge
module load rhel8/cclake/base # Use on either cclake, icelake or sapphire, as it is designed to work for all RHEL8 CPU partitions.
module load openfoam/2312/gcc/intel-oneapi-mpi/2ioxyvgw

# Ensure the system can find your custom solver
export PATH=$HOME/OpenFOAM/ld642-v2312/platforms/linux64GccDPInt32-spack/bin:$PATH

. $WM_PROJECT_DIR/bin/tools/RunFunctions

# 1. Mesh the case
blockMesh

# 2. Decompose (Matching the -n 8 in SBATCH)
decomposePar -force

# 3. Run the NEW uncoupled solver
# We use the full path to be 100% sure it doesn't default back to reactingFoam
mpirun -np 8 uncoupledReactingFoam -parallel

# 4. Reconstruct
reconstructPar
