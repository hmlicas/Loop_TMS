function [] = func_vol2surf(sbj_map_vol, sbj_hemi_lh, sbj_hemi_rh, ...
                            sbj_sulc_lh, sbj_sulc_rh, out_dir, sulc_thr, ...
                            num_target, min_dis)

if isempty(sulc_thr)
    sulc_thr = 0;
end
if isempty(num_target)
    num_target = 3;
end
if isempty(min_dis)
    min_dis = 15;
end
    
% load data
map_vol_nii = load_nifti(sbj_map_vol);

map_vol_orig = map_vol_nii.vol;
% smooth map_vol to avoid outliers
map_mask = map_vol_orig > 0;
conv_ker = ones(3,3,3);
map_vol_conv = convn(map_vol_orig.*map_mask, conv_ker, 'same') .* map_mask;
map_mask_conv = convn(map_mask, conv_ker, 'same') .* map_mask + eps;
map_vol = map_vol_conv ./ map_mask_conv;

[~,~,surf_ext] = fileparts(sbj_hemi_lh);
if strcmp(surf_ext, '.pial')
    [vx_lh, face_lh] = read_surf(sbj_hemi_lh);
    [vx_rh, face_rh] = read_surf(sbj_hemi_rh);
    face_lh = face_lh + 1;
    face_rh = face_rh + 1;
else
    surf_lh = gifti(sbj_hemi_lh);
    surf_rh = gifti(sbj_hemi_rh);
    
    vx_lh = surf_lh.vertices;
    vx_rh = surf_rh.vertices;
    face_lh = surf_lh.faces;
    face_rh = surf_rh.faces;
end

[~, ~, sulc_ext] = fileparts(sbj_sulc_lh);
if strcmp(sulc_ext, '.gii')
    sulc_lh_gii = gifti(sbj_sulc_lh);
    sulc_rh_gii = gifti(sbj_sulc_rh);
    sulc_lh = sulc_lh_gii.cdata;
    sulc_rh = sulc_rh_gii.cdata;
else
    sulc_lh = read_curv(sbj_sulc_lh);
    sulc_rh = read_curv(sbj_sulc_rh);
end

% sulc < 0: gyrus
sulc_lab_lh = zeros(size(sulc_lh));
sulc_lab_lh(sulc_lh<sulc_thr) = 1; 

sulc_lab_rh = zeros(size(sulc_rh));
sulc_lab_rh(sulc_rh<sulc_thr) = 1;

% map vol data to surf
sbj_xfm = map_vol_nii.vox2ras;

vx_vox_lh = sbj_xfm \ [vx_lh, ones(size(vx_lh,1),1)]'; 
vx_vox_rh = sbj_xfm \ [vx_rh, ones(size(vx_rh,1),1)]';

map_sz = size(map_vol);
[m_x, m_y, m_z] = ndgrid(1:map_sz(1), 1:map_sz(2), 1:map_sz(3));

surf_val_lh = interpn(m_x, m_y, m_z, map_vol, vx_vox_lh(1,:), vx_vox_lh(2,:), vx_vox_lh(3,:));
surf_val_rh = interpn(m_x, m_y, m_z, map_vol, vx_vox_rh(1,:), vx_vox_rh(2,:), vx_vox_rh(3,:));

% gyrus only
surf_val_lh_g = surf_val_lh' .* sulc_lab_lh;
surf_val_rh_g = surf_val_rh' .* sulc_lab_rh;

% % for test use
% figure; hold on;
% trisurf(face_lh, vx_lh(:,1), vx_lh(:,2), vx_lh(:,3), sulc_lab_lh);
% trisurf(face_rh, vx_rh(:,1), vx_rh(:,2), vx_rh(:,3), sulc_lab_rh);
% view(0, 90);
% axis equal;
% camlight(0, 0);
% axis vis3d off;
% lighting phong; 
% material dull;
% shading flat;

% get targeting locations
target_pos = zeros(num_target, 3);
target_vox_pos = zeros(num_target, 3);
target_hemi = zeros(num_target, 1);
target_val = zeros(num_target, 1);

surf_val_lr = [surf_val_lh_g; surf_val_rh_g];
vx_lr = [vx_lh; vx_rh];
vx_vox_lr = [vx_vox_lh(1:3,:)'; vx_vox_rh(1:3,:)'];
hemi_lr = [ones(length(surf_val_lh_g),1); 2*ones(length(surf_val_rh_g),1)];

for nti=1:num_target
    [val_max, ind_max] = max(surf_val_lr);
    vx_max = vx_lr(ind_max,:);
    vx_vox_max = vx_vox_lr(ind_max,:);

    target_pos(nti,:) = vx_max;
    target_vox_pos(nti,:) = vx_vox_max;
    target_hemi(nti,:) = hemi_lr(ind_max);
    target_val(nti,:) = val_max;
    
    % remove positions in the neighborhood of selected positions
    vx_repmat = repmat(vx_max, size(vx_lr,1), 1);
    vx_dis = sqrt(sum((vx_repmat-vx_lr).^2,2)); 
    ex_ind = vx_dis <= min_dis;
    
    surf_val_lr(ex_ind) = -100;
    
    if max(surf_val_lr)<=0
        break;
    end
end

% output targeting candidates
out_txt = [out_dir, filesep, 'targeting_location_list.txt'];
ofid = fopen(out_txt, 'w');

for tpi=1:size(target_pos,1)
    fprintf(ofid, '%d\t%0.2f\t%0.2f\t%0.2f\n', tpi, target_pos(tpi,1), ...
            target_pos(tpi,2), target_pos(tpi,3));
end
fclose(ofid);

% plot surface
fig = plot_surf_map_all(face_lh, vx_lh, surf_val_lh_g, face_rh, vx_rh, surf_val_rh_g, [], target_pos);
saveas(fig, [out_dir, filesep, 'targeting_location_fig.tif']);
savefig(fig, [out_dir, filesep, 'targeting_location_fig.fig']);

% output targeting candidates in image space
target_vox_pos = round(target_vox_pos);

out_txt = [out_dir, filesep, 'targeting_location_list_voxel.txt'];
ofid = fopen(out_txt, 'w');

for tpi=1:size(target_vox_pos,1)
    fprintf(ofid, '%d\t%0.2f\t%0.2f\t%0.2f\n', tpi, target_vox_pos(tpi,1), ...
            target_vox_pos(tpi,2), target_vox_pos(tpi,3));
end
fclose(ofid);

% save targeting candidates in .nii file
tar_nii = map_vol_nii;
tar_nii.vol = zeros(size(map_vol_nii.vol));
t_r = 3;
for tpi=1:size(target_vox_pos,1)
    tpi_ijk = target_vox_pos(tpi,:);
    for i=(tpi_ijk(1)-t_r):(tpi_ijk(1)+t_r)
        for j=(tpi_ijk(2)-t_r):(tpi_ijk(2)+t_r)
            for k=(tpi_ijk(3)-t_r):(tpi_ijk(3)+t_r)
                tar_nii.vol(i, j, k) = tpi;
            end
        end
    end
end
tar_nii_fn = [out_dir, filesep, 'targeting_location.nii.gz'];
save_nifti(tar_nii, tar_nii_fn);
