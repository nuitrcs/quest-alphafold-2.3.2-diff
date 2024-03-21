# Change Made to Alpha 2.3.2 for use on Northwestern Quest HPC
This repository holds the "patch" you can apply to AlphaFold 2.3.2 in order to obtain the version that is used on Northwestern Quest

# Pull the Container
A version of alphafold with these changes applied is available on DockerHub.

### Docker
```
docker pull mnballer1992/alphafold:2.3.2-quest
```

### Singularity
```
singularity pull docker://mnballer1992/alphafold:2.3.2-quest
```

# Example Slurm Submission Scripts
https://github.com/nuitrcs/examplejobs/tree/master/alphafold/v2.3.2

# Documentation
https://services.northwestern.edu/TDClient/30/Portal/KB/ArticleDet?ID=1251
