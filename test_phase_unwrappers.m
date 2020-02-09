disp("GPU Min Normunwrapper");
tic
min_norm_unwrapped = GPU_Min_Norm_unwrapper(single(phase));
toc

% curve removal
curve_phase = downsampled_curve(min_norm_unwrapped);
% curve_intensity = curve(intensity);
min_norm_unwrapped_no_curve = (min_norm_unwrapped - curve_phase);

t = tiledlayout(2,1);
title(t,'GPU_Min_Norm_Unwrapper:');
nexttile;
imagesc(phase);
nexttile;
imagesc(min_norm_unwrapped_no_curve);
figure;

disp('Predef DCT Unwrapper');
tic
[N,M] = size(phase);
unwrapper = LeastSquares_Unwrapper(N,M);
p = gpuArray(phase);
matlab_leastSquares_nonWeighted_unwrapped = gather(unwrapper.unwrap(p));
toc

disp('Curve Removal');
tic
% curve removal
curve_phase = downsampled_curve(matlab_leastSquares_nonWeighted_unwrapped);
% curve_intensity = curve(intensity);
matlab_leastSquares_nonWeighted_no_curve = (matlab_leastSquares_nonWeighted_unwrapped - curve_phase);
toc
t = tiledlayout(2,1);
title(t,'Predef DCT Unwrapper:');
nexttile;
imagesc(phase);
nexttile;
imagesc(matlab_leastSquares_nonWeighted_no_curve);
figure();

disp('TIE DCT Iter Unwrapper');
tic
matlab_tie_iter_unwrapped = Unwrap_TIE_DCT_Iter(single(phase));
toc
t = tiledlayout(2,1);
title(t,'TIE DCT Iter Unwrapper:');
nexttile;
imagesc(phase);
nexttile;
imagesc(matlab_tie_iter_unwrapped);

disp("Non-GPU Miguel:");
tic;
phase_unwrap = Miguel_2D_unwrapper(single(phase));
toc;
%curve_phase = curve(phase_unwrap);
% curve_intensity = curve(intensity);
%phase_unwrap_no_curve = (phase_unwrap - curve_phase);
t = tiledlayout(2,1);
title(t,'Non-GPU Miguel:');
nexttile;
imagesc(phase);
nexttile;
imagesc(phase_unwrap);
figure();

disp("GPU Miguel:");
tic;
gpu_phase_unwrap = GPU_sort_Miguel_2D_unwrapper(single(phase));
single_phase = single(phase);
toc;
t = tiledlayout(2,1);
title(t,'GPU Miguel:');
nexttile;
imagesc(phase);
nexttile;
imagesc(gpu_phase_unwrap);
figure();