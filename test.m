dx = [zeros([size(phase,1),1]), wrapToPi(diff(phase, 1, 2)), zeros([size(phase,1),1])];
dy = [zeros([1,size(phase,2)]); wrapToPi(diff(phase, 1, 1)); zeros([1,size(phase,2)])];
rho = diff(dx, 1, 2) + diff(dy, 1, 1);

l_x = 1:10;

[X,Y] = meshgrid(l_x,l_x);
%phase = X.^2 + Y.^2;
[x,y] = size(rho);
%mirrored = zeros(x*2,y*2);
%mirrored(1:x,1:y) = rho;
%mirrored(1:x,y+1:end) = flip(rho,2);
%mirrored(x+1:end,1:y) = flip(rho);
%mirrored(x+1:end,y+1:end) = flip(flip(rho),2);

mirrored=[rho,fliplr(rho)];
mirrored=[mirrored',(flipud(mirrored))']';

[N, M] = size(mirrored);
[I, J] = meshgrid([0:M-1], [0:N-1]);
tic
gpuMirrored = gpuArray(mirrored);
toc
tic
fft_dct = fft2(gpuMirrored);
fft_dct_gathered = gather(fft_dct);
toc
dct_dct = dct2(mirrored);

dctPhi = dct_dct; %./ 2 ./ (cos(pi*I/M) + cos(pi*J/N) - 2);
dctPhi(1,1) = 0; % handling the inf/nan value

fftPhi = fft_dct %.* exp(((-1i * pi * I)/2*M) + ((-1i * pi * J)/2*N)); %./ 2 ./ (cos(pi*I/M) + cos(pi*J/N) - 2);
fftPhi_gathered = real(gather(fftPhi));
fftPhi(1,1) = 0; % handling the inf/nan value
tic
fft_unwrapped = real(ifft2(fftPhi));
fft_unwrapped = fft_unwrapped(1:x,1:y);
fft_unwrapped = gather(fft_unwrapped);
toc
dct_unwrapped = idct2(dctPhi);
dct_unwrapped = dct_unwrapped(1:x,1:y);

curve_phase_fft = downsampled_curve(fft_unwrapped);
fft_curveless = fft_unwrapped - curve_phase_fft;

curve_phase_dct = downsampled_curve(dct_unwrapped);
dct_curveless = dct_unwrapped - curve_phase_dct;

res = (dct_unwrapped - fft_unwrapped)/dct_unwrapped

t = tiledlayout(2,1);
nexttile;
imagesc(fft_unwrapped);
nexttile;
imagesc(dct_unwrapped);