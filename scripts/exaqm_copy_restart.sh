#!/bin/bash

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. $USHdir/source_util_funcs.sh
source_config_for_task "task_copy_restart" ${GLOBAL_VAR_DEFNS_FP}
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

This is the ex-script for the task that copies JEDI Analyis to RESTART
directory initial condition files for the FV3 will be generated.
========================================================================"
#
#-----------------------------------------------------------------------
#
# Check if restart file exists
#
#-----------------------------------------------------------------------
#
if [ "${WORKFLOW_MANAGER}" = "ecflow" ]; then
  SDATE=$($NDATE -6 ${PDY}${cyc})
  PDYS_P1=$(echo $SDATE | cut -c1-8)
  cycs_p1=$(echo $SDATE | cut -c9-10)
  export PREV_CYCLE_DIR=$(compath.py ${NET}/${model_ver}/${RUN}.${PDYS_P1}/${cycs_p1})
fi
rst_dir=${PREV_CYCLE_DIR}/RESTART
rst_file=fv_tracer.res.tile1.nc
fv_tracer_file=${rst_dir}/${PDY}.${cyc}0000.${rst_file}
print_info_msg "
  Looking for tracer restart file: \"${fv_tracer_file}\""
if [ ! -r ${fv_tracer_file} ]; then
  if [ -r ${rst_dir}/coupler.res ]; then
    rst_info=( $( tail -n 1 ${rst_dir}/coupler.res ) )
    # Remove leading zeros from ${rst_info[1]}
    month="${rst_info[1]#"${rst_info[1]%%[!0]*}"}"
    # Remove leading zeros from ${rst_info[2]}
    day="${rst_info[2]#"${rst_info[2]%%[!0]*}"}"
    # Format the date without leading zeros
    rst_date=$(printf "%04d%02d%02d%02d" ${rst_info[0]} $((10#$month)) $((10#$day)) ${rst_info[3]})
    print_info_msg "
  Tracer file not found. Checking available restart date:
    requested date: \"${PDY}${cyc}\"
    available date: \"${rst_date}\""
    if [ "${rst_date}" = "${PDY}${cyc}" ] ; then
      fv_tracer_file=${rst_dir}/${rst_file}
      if [ -r ${fv_tracer_file} ]; then
        print_info_msg "
  Tracer file found: \"${fv_tracer_file}\""
      else
        message_txt="No suitable tracer restart file found."
          err_exit "${message_txt}"
      fi
    fi
  fi
fi
#
#
#------------------------------------------------------------------------------
#
# Copy JEDI Analysis file to a previous cycle restart directory  [Hyundeok]
#
#------------------------------------------------------------------------------
#

NCO_DIR=${HOMEaqm}/../nco_dirs

# JEDI Analysis
anal_dir=${NCO_DIR}/Data/analysis
anal_file=3dvar_lam_cmaq_no2.fv_tracer.res.nc
anal_fv_tracer_file=${anal_dir}/${PDY}.${cyc}0000.${anal_file}

# CMAQ RESTART
rst_dir=${PREV_CYCLE_DIR}/RESTART
rst_file=fv_tracer.res.tile1.nc
rst_fv_tracer_file=${rst_dir}/${PDY}.${cyc}0000.${rst_file}

# Keep the restart file before merging NO2 field
fcst_file=fcst.fv_tracer.res.tile1.nc
fcst_fv_tracer_file=${rst_dir}/${PDY}.${cyc}0000.${fcst_file}

# Temp File
temp_fv_tracer_file=${rst_dir}/${PDY}.${cyc}0000.${anal_file}

# copy JEDI analysis file to the previous cycle directory
cp ${anal_fv_tracer_file} ${temp_fv_tracer_file}
cp ${rst_fv_tracer_file} ${fcst_fv_tracer_file}

# merge JEDI no2 field with the restart file in the previous cycle
ncks -A -v no2 ${temp_fv_tracer_file} ${rst_fv_tracer_file}

#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
    print_info_msg "
========================================================================

Successfully copied JEDI analysis files to a restart directory!!!

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

