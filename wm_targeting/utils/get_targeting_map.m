function t_map = get_targeting_map(fmri_dat, fn_dat, fn_lst, mask)

fmri_dat = single(fmri_dat);
fn_dat = single(fn_dat);

if nargin==4
    mask_vec = mask(:);
else
    mask = sum(fn_dat, 4) > 0;
    mask_vec = mask(:);
end

fn_dat(fn_dat<0.1) = 0;
fn_dat = fn_dat(:,:,:,fn_lst);

fn_tc = get_sbj_tc(fmri_dat, fn_dat);

num_t = size(fmri_dat, 4);
fmri_mat = reshape(fmri_dat, [], num_t);
fmri_mat = fmri_mat(mask_vec, :)';

fc_mat = corr(fmri_mat, fn_tc);
fc_mat(fc_mat<0) = 0;
fc_mat = mean(fc_mat,2);
fc_mat = (fc_mat-min(fc_mat)) ./ (max(fc_mat)-min(fc_mat));

img_sz = size(fmri_dat);
t_map = zeros(img_sz(1:3));
t_map(mask) = fc_mat;
