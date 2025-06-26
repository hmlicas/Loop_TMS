
Dependency:
1. MATLAB and external MATLAB tools/packages including freesurfer/matlab, GIfTI library, and NIfTI_20140122. 
	(Add these tools to the search path of MATLAB)

2. ANTs for image registration, from Docker image fmriprep-22.1.1.simg


Usage (detailed usage is available in each script):
1. run step1_get_targeting_sbj_vol.m to obtain subject-specific FC map for targeting in MNI space.

2. run step2_register_sbj_vol_to_native.sh to deform the FC map in MNI space to subject native space.

3. run step3_map_sbj_vol_to_surf.m to get FC peaks on cortical surface for targeting.
