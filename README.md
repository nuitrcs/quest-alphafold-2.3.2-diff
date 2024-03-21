# Change Made to Alpha 2.3.2 for use on Northwestern Quest HPC
This repository holds [the "patch"](https://github.com/nuitrcs/quest-alphafold-2.3.2-diff/blob/main/2.3.2-changes.diff) you can apply to AlphaFold 2.3.2 in order to obtain the version that is used on Northwestern Quest

# Pull the Container
A version of alphafold with these changes applied is available [on DockerHub](https://hub.docker.com/r/mnballer1992/alphafold).

### Docker
```
docker pull mnballer1992/alphafold:2.3.2-quest
```

### Singularity
```
singularity pull docker://mnballer1992/alphafold:2.3.2-quest
```

# Create a module to wrap call to the container

### Create a local folder that can be used to hold the module file
mkdir -p modules/alphafold/

### Navigate to the folder and download the module file
cd modules/alphafold
wget https://raw.githubusercontent.com/nuitrcs/quest-alphafold-2.3.2-diff/main/2.3.2-with-msas-only-and-config-yaml.lua

### You must edit the following parts of the modules file
* The line `setenv("ALPHAFOLD_DATA_PATH", "/software/AlphaFold/data/v2.3.2/")` must be change to the location of the AlphaFold 2.3.2 databases on your system.
* Your need to change every instance of `/software/AlphaFold/container/2.3.2/alphafold-2.3.2-with-msas-only-and-config-yaml.sif` to the absolutely path to the singularity image file on your system. The `sif` will exist on your system wherever your ran the `singularity pull` command from above.

### Now you can use the module in your submission scripts by doing the following
```
module use modules/
module load alphafold/2.3.2-with-msas-only-and-config-yaml
```

For more details on how to use these helper function to run AlphaFold please see the example submission scripts and documentation below.

# Example Slurm Submission Scripts
[Example of Submitting separate CPU and GPU AlphaFold v2.3.2](https://github.com/nuitrcs/examplejobs/tree/master/alphafold/v2.3.2)

# Documentation
https://services.northwestern.edu/TDClient/30/Portal/KB/ArticleDet?ID=1251

# Example of using it in a Nextflow Pipeline
https://github.com/nuitrcs/nextflow-workshop/tree/main/blast-example
