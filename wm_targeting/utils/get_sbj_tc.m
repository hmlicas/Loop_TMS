function tc = get_sbj_tc(fmri_dat, fn_dat)
% fmri_dat: fmri data, with size [X, Y, Z, T]
% fn_dat: functional network data, with size [X, Y, Z, K]

num_t = size(fmri_dat, 4);
num_k = size(fn_dat, 4);

fmri_mat = reshape(fmri_dat, [], num_t);
fn_mat = reshape(fn_dat, [], num_k);

tc = fmri_mat' * fn_mat;
tc = tc ./ repmat(sum(fn_mat),num_t,1);
