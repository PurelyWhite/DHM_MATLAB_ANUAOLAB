%u = fft2(256, 256);
function res = propogate(phase, z)
    u = phase;
    % z = 1; % this is the distance by which you wish to propagate

    dx = 1; % or whatever
    dy = 1;

    wavelen = 1; % or whatever
    wavenum = 2 * pi / wavelen;
    wavenum_sq = wavenum * wavenum;

    kx = fftfreq(size(u,1), dx / (2 * pi));
    ky = fftfreq(size(u,2), dy / (2 * pi));

    kz_sq = (kx .* kx)' + ky .* ky;
    mask = wavenum * wavenum > kz_sq;

    a = zeros(size(u));
    g = complex(a,0);

    g(mask) = exp(1j * sqrt(wavenum_sq - kz_sq(mask)) * z);

    res = ifft2(g .* fft2(u)); % this is the result
end