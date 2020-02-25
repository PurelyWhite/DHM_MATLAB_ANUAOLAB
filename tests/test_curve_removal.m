[yy,xx]=size(matlab_leastSquares_nonWeighted_unwrapped);
xxx=linspace(1,xx,xx);
yyy=linspace(1,yy,yy);
x_rep=repmat(xxx,yy,1);
y_rep=repmat(yyy',1,xx);

disp('Curve Removal Original');
tic
% curve removal
curve_phase_og = curve(matlab_leastSquares_nonWeighted_unwrapped);
% curve_intensity = curve(intensity);
original_curveless = matlab_leastSquares_nonWeighted_unwrapped - curve_phase_og;
toc

disp('Curve Removal Downsampled');
tic
% curve removal
curve_phase_ds = downsampled_curve(matlab_leastSquares_nonWeighted_unwrapped);
% curve_intensity = curve(intensity);
ds_curveless = matlab_leastSquares_nonWeighted_unwrapped - curve_phase_ds;
toc


D = abs(curve_phase_ds-curve_phase_og).^2;
MSE = sum(D(:))/numel(curve_phase_ds);
MSE

t = tiledlayout(2,1);
nexttile;
imagesc(original_curveless);
nexttile;
imagesc(ds_curveless);
figure();