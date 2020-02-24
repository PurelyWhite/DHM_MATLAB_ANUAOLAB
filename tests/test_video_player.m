videoplayer = vision.VideoPlayer();

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
% t = tiledlayout(2,1);
% title(t,'Predef DCT Unwrapper:');
% nexttile;
% imagesc(phase);
% nexttile;
% imagesc(matlab_leastSquares_nonWeighted_no_curve);
% figure();

m = surf(matlab_leastSquares_nonWeighted_no_curve);

step(videoplayer, m);
