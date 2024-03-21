help([[
This package provides an implementation of the inference pipeline of AlphaFold v2. For simplicity, we refer to this model as AlphaFold throughout the rest of this document.

We also provide:

    - An implementation of AlphaFold-Multimer. This represents a work in progress and AlphaFold-Multimer isn't expected to be as stable as our monomer AlphaFold system. Read the guide for how to upgrade and update code.
    - The technical note containing the models and inference procedure for an updated AlphaFold v2.3.0.
    - A CASP15 baseline set of predictions along with documentation of any manual interventions performed.

Any publication that discloses findings arising from using this source code or the model parameters should cite the AlphaFold paper and, if applicable, the AlphaFold-Multimer paper.

Please also refer to the Supplementary Information for a detailed description of the method.

Below, we provide an example submission script for running AlphaFold on Quest.

#!/bin/bash
#SBATCH --account=pXXXX  ## YOUR ACCOUNT pXXXX or bXXXX
#SBATCH --partition=gengpu  ### PARTITION (buyin, short, normal, etc)
#SBATCH --nodes=1 ## how many computers do you need
#SBATCH --ntasks-per-node=12 ## how many cpus or processors do you need on each computer
#SBATCH --time=48:00:00 ## how long does this need to run (remember different partitions have restrictions on this param)
#SBATCH --mem=85G ## how much RAM do you need per CPU (this effects your FairShare score so be careful to not ask for more than you need))
#SBATCH --job-name=run_AlphaFold  ## When you run squeue -u NETID this is how you can identify the job
#SBATCH --output=AlphaFold.log ## standard out and standard error goes to this file
#SBATCH --mail-type=ALL ## you can receive e-mail alerts from SLURM when your job begins and when your job finishes (completed, failed, etc)
#SBATCH --mail-user=email@u.northwestern.edu ## your email

#########################################################################
### PLEASE NOTE:                                                      ###
### The above CPU, Memory, and GPU resources have been selected based ###
### on the computing resources that alphafold was tested on           ###
### which can be found here:                                          ###
### https://github.com/deepmind/alphafold#running-alphafold)          ###
### It is likely that you do not have to change anything above        ###
### besides your allocation, and email (if you want to be emailed).   ###
#########################################################################

module purge
module load alphafold/2.3.2-with-msas-only-and-config-yaml

# template monomer
# alphafold-monomer --fasta_paths=/full/path/to/fasta \
#    --output_dir=/full/path/to/outdir \
#    --max_template_date= \
#    --model_preset=[monomer|monomer_casp14|monomer_ptm] \
#    --enable_gpu_relax=[true|false]
#    --db_preset=full_dbs
### 
###         monomer: This is the original model used at CASP14 with no ensembling.
### 
###         monomer_casp14: This is the original model used at CASP14 with num_ensemble=8, matching our CASP14 configuration. This is largely provided for reproducibility as it is 8x more computationally expensive for limited accuracy gain (+0.1 average GDT gain on CASP14 domains).
### 
###         monomer_ptm: This is the original CASP14 model fine tuned with the pTM head, providing a pairwise confidence measure. It is slightly less accurate than the normal monomer model.
###
###         enable_gpu_relax: The relaxation step can be run on GPU (faster, but could be less stable) or CPU (slow, but stable). This can be controlled with --enable_gpu_relax=true (default) or --enable_gpu_relax=false.

# template multimer
# alphafold-multimer --fasta_paths=/full/path/to/fasta \
#    --output_dir=/full/path/to/outdir \
#    --max_template_date= \
#    --model_preset=multimer \
#    --enable_gpu_relax=[true|false]
#    --db_preset=full_dbs
### 
###         multimer: This is the AlphaFold-Multimer model. To use this model, provide a multi-sequence FASTA file. In addition, the UniProt database should have been downloaded.
###
###         enable_gpu_relax: The relaxation step can be run on GPU (faster, but could be less stable) or CPU (slow, but stable). This can be controlled with --enable_gpu_relax=true (default) or --enable_gpu_relax=false.


# real example monomer
alphafold-monomer --fasta_paths=/projects/intro/alphafold/T1050.fasta \
    --max_template_date=2022-01-01 \
    --model_preset=monomer \
    --db_preset=full_dbs \
    --output_dir=$(pwd)/out

# real example multimer
alphafold-multimer --fasta_paths=/projects/intro/alphafold/6E3K.fasta \
    --is_prokaryote_list=false \
    --max_template_date=2022-01-01 \
    --model_preset=multimer \
    --db_preset=full_dbs \
    --output_dir=$(pwd)/out
]])

local pkgName = "alphafold"
local version = "2.3.2-with-msas-only-and-config-yaml"

whatis("Name: " .. pkgName)
whatis("Version: " .. version)

depends_on("singularity")

setenv("ALPHAFOLD_DATA_PATH", "/software/AlphaFold/data/v2.3.2/")

local alphafoldMultimer = 'singularity run --env TF_FORCE_UNIFIED_MEMORY=1,XLA_PYTHON_CLIENT_MEM_FRACTION=4.0,OPENMM_CPU_THREADS=12,LD_LIBRARY_PATH="/opt/conda/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/.singularity.d/libs" -B /projects:/projects -B $(realpath $ALPHAFOLD_DATA_PATH):/data -B .:/etc  --pwd /app/alphafold --nv /software/AlphaFold/container/2.3.2/alphafold-2.3.2-with-msas-only-and-config-yaml.sif --data_dir=/data --uniref90_database_path=/data/uniref90/uniref90.fasta --mgnify_database_path=/data/mgnify/mgy_clusters_2022_05.fa --uniref30_database_path=/data/uniref30/UniRef30_2021_03 --bfd_database_path=/data/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt --pdb_seqres_database_path=/data/pdb_seqres/pdb_seqres.txt --uniprot_database_path=/data/uniprot/uniprot.fasta  --template_mmcif_dir=/data/pdb_mmcif/mmcif_files --obsolete_pdbs_path=/data/pdb_mmcif/obsolete.dat "$@"'

set_shell_function("alphafold-multimer", alphafoldMultimer)

local alphafoldMonomer = 'singularity run --env TF_FORCE_UNIFIED_MEMORY=1,XLA_PYTHON_CLIENT_MEM_FRACTION=4.0,OPENMM_CPU_THREADS=12,LD_LIBRARY_PATH="/opt/conda/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/.singularity.d/libs" -B /projects:/projects -B $(realpath $ALPHAFOLD_DATA_PATH):/data -B .:/etc  --pwd /app/alphafold --nv /software/AlphaFold/container/2.3.2/alphafold-2.3.2-with-msas-only-and-config-yaml.sif --data_dir=/data --uniref90_database_path=/data/uniref90/uniref90.fasta --mgnify_database_path=/data/mgnify/mgy_clusters_2022_05.fa --uniref30_database_path=/data/uniref30/UniRef30_2021_03 --bfd_database_path=/data/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt --pdb70_database_path=/data/pdb70/pdb70 --template_mmcif_dir=/data/pdb_mmcif/mmcif_files --obsolete_pdbs_path=/data/pdb_mmcif/obsolete.dat "$@"'

set_shell_function("alphafold-monomer", alphafoldMonomer)

local alphafoldReducedDBsMultimer = 'export ALPHAFOLD_DATA_PATH="/software/AlphaFold/data/reduced_dbs/v2.3.2/"; singularity run --env TF_FORCE_UNIFIED_MEMORY=1,XLA_PYTHON_CLIENT_MEM_FRACTION=4.0,OPENMM_CPU_THREADS=12,LD_LIBRARY_PATH="/opt/conda/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/.singularity.d/libs" -B /projects:/projects -B $(realpath $ALPHAFOLD_DATA_PATH):/data -B .:/etc  --pwd /app/alphafold --nv /software/AlphaFold/container/2.3.2/alphafold-2.3.2-with-msas-only-and-config-yaml.sif --data_dir=/data --uniref90_database_path=/data/uniref90/uniref90.fasta --mgnify_database_path=/data/mgnify/mgy_clusters_2022_05.fa --small_bfd_database_path=/data/small_bfd/bfd-first_non_consensus_sequences.fasta --pdb_seqres_database_path=/data/pdb_seqres/pdb_seqres.txt --uniprot_database_path=/data/uniprot/uniprot.fasta  --template_mmcif_dir=/data/pdb_mmcif/mmcif_files --obsolete_pdbs_path=/data/pdb_mmcif/obsolete.dat "$@"'

set_shell_function("alphafold-multimer-reduced-dbs", alphafoldReducedDBsMultimer)
