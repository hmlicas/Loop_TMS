clc;
clear;

addpath('./utils');

tms_tar_pl = '/cbica/home/lihon/results/tms_fmri/test_targeting_pipeline/tms_targeting_pipeline';


% set input fMRI image (in MNI space, MNI152NLin2009cAsym, e.g., preprocessed 
% by fMRIPrep), and sbj id
sbj_id = 'sub-C181';

mri_dir = '/cbica/home/lihon/results/tms_fmri/test_targeting_pipeline/sm6_rs3_data_denoise';
sbj_fmri_file_1 = [mri_dir, '/rs3_sm6_', sbj_id, '_task-rest.nii.gz'];
sbj_fmri_file_2 = [mri_dir, '/rs3_sm6_', sbj_id, '_task-nbackLOOP.nii.gz'];
sbj_fmri_file_all = {sbj_fmri_file_1, sbj_fmri_file_2};

vox_sz = 3; 	% voxel size
vox_sz_str = [num2str(vox_sz), 'mm'];

% set output directory
out_dir = ['/cbica/home/lihon/results/tms_fmri/test_targeting_pipeline/targeting_res_dn/', sbj_id];
disp(sbj_id);
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end
sbj_out_file = [out_dir, filesep, sbj_id, '_targeting_map.nii.gz'];

% check fmri vox_sz
for fi=1:length(sbj_fmri_file_all)
    sbj_fmri_file = sbj_fmri_file_all{fi};

    sbj_fmri = load_untouch_header_only(sbj_fmri_file);
    if sbj_fmri.dime.pixdim(2)~=vox_sz
        [~, in_fn, ~] = fileparts(sbj_fmri_file);
        out_fn = [out_dir, filesep, 'rs', vox_sz_str, '_', in_fn, '.gz'];
        ref_fn = [tms_tar_pl, '/dat/grp_targeting_map_', vox_sz_str, '_r3.nii.gz'];

        if ~exist(out_fn, 'file')
            run_cmd = ['flirt -in ', sbj_fmri_file, ' -ref ', ref_fn, ' -applyisoxfm ', num2str(vox_sz), ' -nosearch -out ', out_fn];
            system(run_cmd);    
        end

        sbj_fmri_file{fi} = out_fn;
    end
end

% image file for functional networks, using the 2mm or 3mm one
% according to the fMRI data
fn_dir = '/cbica/home/lihon/results/tms_fmri/test_targeting_pipeline/nmf_res';
fn_file = [fn_dir, '/networks_50_3mm_r3_dn/SingleParcel_1by1/', sbj_id, '/', sbj_id, '_fn_49_4d_3mm_r3.nii.gz'];

% selected functional networks that contributed most to the decoding
fn_lst = [15, 45, 29, 21, 11];

% targeting mask at group level
grp_map_file = [tms_tar_pl, '/dat/grp_targeting_map_', vox_sz_str, '_r3.nii.gz'];
grp_map_nii = load_untouch_nii(grp_map_file);
grp_map = grp_map_nii.img;
grp_tar_vec = grp_map(grp_map>0);
thr_val = prctile(grp_tar_vec,90);

mask_img = grp_map;
mask_img(grp_map<thr_val) = 0;
mask_img(grp_map>=thr_val) = 1;
mask_img = logical(mask_img);

% computation starts here
sbj_fmri_img = [];
for fi=1:length(sbj_fmri_file_all)
    sbj_fmri_file = sbj_fmri_file_all{fi};
    sbj_fmri_nii = load_untouch_nii(sbj_fmri_file);

    fi_sz = size(sbj_fmri_nii.img);
    rep_sz = [1,1,1, fi_sz(4)];

    fi_m = mean(sbj_fmri_nii.img, 4);
    fi_s = std(sbj_fmri_nii.img, 0, 4);
    fi_mat = (sbj_fmri_nii.img-repmat(fi_m, rep_sz)) ./ (1e-6 + repmat(fi_s, rep_sz));

    sbj_fmri_img = cat(4, sbj_fmri_img, fi_mat);
end
sbj_fn_nii = load_untouch_nii(fn_file);

sbj_tar_map = get_targeting_map(sbj_fmri_img, sbj_fn_nii.img, fn_lst, mask_img);
if sum(isnan(sbj_tar_map(:)))>0
    sbj_tar_map(isnan(sbj_tar_map)) = 0;
end

out_nii = sbj_fn_nii;
out_nii.img = sbj_tar_map;
out_nii.hdr.dime.dim(1) = 3;
out_nii.hdr.dime.dim(5) = 1;

save_untouch_nii(out_nii, sbj_out_file);

disp('Finished.');
