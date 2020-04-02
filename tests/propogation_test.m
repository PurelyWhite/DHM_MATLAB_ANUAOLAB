phase = zeros(256,256);
phase(50:150,50:60) = 1;

proped = real(propogate(phase, 0));

[N,M] = size(phase);

unwrapper = LeastSquares_Unwrapper(N,M);

p = gpuArray(phase);
matlab_leastSquares_nonWeighted_unwrapped = gather(unwrapper.unwrap(p));

curve_phase = downsampled_curve(matlab_leastSquares_nonWeighted_unwrapped);
% curve_intensity = curve(intensity);
matlab_leastSquares_nonWeighted_no_curve = (matlab_leastSquares_nonWeighted_unwrapped - curve_phase);

h.fig  = figure ;
h.ax   = handle(axes) ;                 %// create an empty axes that fills the figure
h.mesh = handle( mesh( NaN(2) ) ) ;     %// create an empty "surface" object
%Display the initial surface
set( h.mesh,'ZData', proped)

focus_value = zeros(20);

for z = -10:10
    proped = real(propogate(matlab_leastSquares_nonWeighted_unwrapped, z));
    focus_value(z+11) = sum(log(1+abs(fft2(proped))),'all');
    h.mesh.ZData = proped;
    % im.title = num2str(z);
    pause(1);
end