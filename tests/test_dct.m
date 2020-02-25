tic
[N,M] = size(phase);
unwrapper = LeastSquares_Unwrapper(N,M);
matlab_leastSquares_nonWeighted_unwrapped = unwrapper.unwrap(gpuArray(phase));
p2 = gather(matlab_leastSquares_nonWeighted_unwrapped);
toc

tic
fft2(phase);
toc

tic
fft2(gpuArray(phase));
toc

tic
tester = gpuTester;
tester.test(phase);
toc