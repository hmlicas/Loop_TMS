clc;
clear;

addpath('./utils');


% set subject ID
sbj_id = 'sub-C181'; 

% set subject targeting map in native space (from script step 2)
sbj_map_vol = ['/cbica/home/lihon/results/tms_fmri/test_targeting_pipeline/targeting_res_dn/', sbj_id, '/', sbj_id, '_targeting_map_native.nii.gz'];

% set subject cortical surface (from freesurfer)
sbj_hemi_lh = ['/cbica/home/lihon/results/tms_fmri/test_targeting_pipeline/fmriprep_proc_4/', sbj_id, '/anat/', sbj_id, '_hemi-L_midthickness.surf.gii'];
sbj_hemi_rh = ['/cbica/home/lihon/results/tms_fmri/test_targeting_pipeline/fmriprep_proc_4/', sbj_id, '/anat/', sbj_id, '_hemi-R_midthickness.surf.gii'];

% set subject .sulc file (from freesurfer)
sbj_sulc_lh = ['/cbica/home/lihon/results/tms_fmri/test_targeting_pipeline/fmriprep_proc_4/', sbj_id, '/anat/', sbj_id, '_hemi-L_sulc.shape.gii'];
sbj_sulc_rh = ['/cbica/home/lihon/results/tms_fmri/test_targeting_pipeline/fmriprep_proc_4/', sbj_id, '/anat/', sbj_id, '_hemi-R_sulc.shape.gii'];

% set the threshold of sulc detph to obtain gyrus mask
% sulc < 0: gyrus, smaller value leads to locations more close to gyrus
sulc_thr = -5;
% set the number of peak positions for targeting (e.g. 2)
num_target = 2;
% set the minimal distance (in mm) between identified peaks 
% (so that peak positions will not be too close to each other)
min_dis = 15;

% set output directory. The candidate locations (FC peaks on gyrus) will be
% saved to out_dir/targeting_location_list.txt, and a simple visualization
% to out_dir/targeting_location_fig.tif, in the figure, the masked FC map
% (warmer color indicate larger FC value) and identified peaks (1st, 2nd, ...)
% are displayed.
out_dir = ['/cbica/home/lihon/results/tms_fmri/test_targeting_pipeline/targeting_res_dn/', sbj_id, '_midthickness'];
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

% run map vol to surf
func_vol2surf(sbj_map_vol, sbj_hemi_lh, sbj_hemi_rh, sbj_sulc_lh, sbj_sulc_rh, ...
              out_dir, sulc_thr, num_target, min_dis);

disp('Finished.');
