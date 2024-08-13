#!/bin/bash

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. $USHdir/source_util_funcs.sh
source_config_for_task "task_gen_yaml" ${GLOBAL_VAR_DEFNS_FP}
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; . $USHdir/preamble.sh; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
scrfunc_fp=$( $READLINK -f "${BASH_SOURCE[0]}" )
scrfunc_fn=$( basename "${scrfunc_fp}" )
scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Print message indicating entry into script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
Entering script:  \"${scrfunc_fn}\"
In directory:     \"${scrfunc_dir}\"

This is the ex-script for the task that generates YAML file to run JEDI.
========================================================================"
#
#-----------------------------------------------------------------------
#
# This section is for generating YAML file
#
#-----------------------------------------------------------------------
#

if [ "${WORKFLOW_MANAGER}" = "ecflow" ]; then
  SDATE=$($NDATE -6 ${PDY}${cyc})
  PDYS_P1=$(echo $SDATE | cut -c1-8)
  cycs_p1=$(echo $SDATE | cut -c9-10)
  export PREV_CYCLE_DIR=$(compath.py ${NET}/${model_ver}/${RUN}.${PDYS_P1}/${cycs_p1})
fi

export PDY=${PDY}
export cyc=${cyc}
export PREV_CYCLE_DIR=${PREV_CYCLE_DIR}
export assim_freq=24

#Set PYTHONPATH to load 'wxflow' as a temporary hack
export PYTHONPATH=$PYTHONPATH:/home/Hyundeok.Choi/wxflow/src/

print_info_msg "
  print out HOMEaqm: ${HOMEaqm}"

GDAS_DIR=${HOMEaqm}/../GDASApp
export NCO_DIR=${HOMEaqm}/../nco_dirs

#need to add 'NET_dfv' to create ean experiment directory.

#generate diagB yaml

python ${GDAS_DIR}/ush/genYAML -i ${NCO_DIR}/trace_diagb_template.yaml -o ${NCO_DIR}/trace_diagb.yaml

#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#

    print_info_msg "
========================================================================

Successfully generated YAML for DiagB!!!

========================================================================"

#generate 3dvar nicas lam cmaq yaml

python ${GDAS_DIR}/ush/genYAML -i ${NCO_DIR}/3dvar_nicas_lam_cmaq_template.yaml -o ${NCO_DIR}/3dvar_nicas_lam_cmaq.yaml

#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
    print_info_msg "
========================================================================

Successfully generated YAML for JEDI!!!

========================================================================"

#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/func-
# tion.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1

