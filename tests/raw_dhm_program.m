tic;

imgo = imread('test.tif'); % open hologram
[~, ~, img_dim] = size(imgo);
if img_dim ~= 1
    img = double(rgb2gray(imgo)); % double format
else
    img = double(imgo);
end
fftimg = fftshift(fft2(img)); % 2d fourier transform and translate to centre
imgsize = size(fftimg); %determine image size
logimg = log(abs(fftimg)); % for illustration purpose only?
logimgmaxmin = (logimg - min(min(logimg)))/(max(max(logimg))-min(min(logimg))); % normalise
% logimgplus1maxmin = (logimgplus1 - min(min(logimgplus1)))/(max(max(logimgplus1))-min(min(logimgplus1))); % normalise
% logimgplus1 = log(abs(fftimg)+1); % increase contrast?

fft = toc

% fft image gaussian fit and get global threshold level
sigma = 4;
logimg_filtered = imgaussfilt(logimgmaxmin, sigma);
global_thresh = graythresh(logimg_filtered);

% seperate noise region and order region
level = 10;
small_region = round((imgsize(1)/level) * (imgsize(2)/level)); % noise
big_region = round((imgsize(1)/2) * (imgsize(2)/2));

% threshold controls
num_object = 1;
thresh_increment = 0;
thresh_step = global_thresh/50;

% threshold loop
while num_object ~= 3
    bw = imbinarize(logimg_filtered, global_thresh + thresh_increment);
    bw_denoise = bwareaopen(bw, small_region); % remove noise region
    bw_prop = regionprops(bw_denoise); % get property of the only bright region
    num_object = size(bw_prop);
    if num_object == 3
        areas = [bw_prop(1, 1).Area, bw_prop(2, 1).Area, bw_prop(2, 1).Area];
        if (max(areas) > big_region) || (min(areas) < small_region)
            num_object = 1;
        end
    end
    thresh_increment = thresh_increment + thresh_step;
end

% get coordinates of region boundary
% boundaries = bwboundaries(bw_denoise);

recog = toc
% get region centroid and compare positions
pos_1 = bw_prop(1).Centroid;
pos_2 = bw_prop(2).Centroid;
pos_3 = bw_prop(3).Centroid;
cen_1 = abs(pos_1(1)) - abs(pos_1(2));
cen_2 = abs(pos_2(1)) - abs(pos_2(2));
cen_3 = abs(pos_3(1)) - abs(pos_3(2));
[~, index] = max([cen_1, cen_2, cen_3]);

% setup region box
region_pos = bw_prop(index).Centroid;
region_box = bw_prop(index).BoundingBox;
% region_boundary = boundaries{index};

region_half_x = abs(region_box(1) - region_pos(1));
region_half_y = abs(region_box(2) - region_pos(2));
region_half_acu_x = region_box(3)/2;
region_half_acu_y = region_box(4)/2;

% modify region box accoridng to relative centroid position
if region_half_x > region_half_acu_x
    region_box(3) = region_half_x * 2;
else
    region_box(1) = region_pos(1) - region_half_x; % no change to upper left x?
end

if region_half_y > region_half_acu_y
    region_box(4) = region_half_y * 2;
else
    region_box(2) = region_pos(2) - region_half_y; % no change to upper left y?
end

% enlarge region box according to threshold increment?
thresh_increment_amount = thresh_increment * 0;
region_box(1:2) = region_box(1:2) - region_box(3:4) * (thresh_increment_amount/2);
region_box(3:4) = region_box(3:4) + region_box(3:4) * (thresh_increment_amount);
region_box = floor(region_box);

% create filter mask based on selected region
if region_box(2) + region_box(4) > imgsize(1)
    region_box(4) = imgsize(1) - region_box(2);
end
if region_box(1) + region_box(3) > imgsize(2)
    region_box(3) = imgsize(2) - region_box(1);
end
if region_box(1) == 0
    region_box(1) = 1;
end
if region_box(2) == 0
    region_box(2) = 1;
end

mask = zeros(imgsize(1), imgsize(2));
mask(   region_box(2) : (region_box(2) + region_box(4)), ...
    region_box(1) : (region_box(1) + region_box(3))) = 1;

% apply mask
% logimgmaxmin_masked = logimgmaxmin .* mask;
fftimg_masked = fftimg .* mask;

% transfering fft region
centreimg = zeros(imgsize(1), imgsize(2)); % create a black image for placing first order;
region_box_dummy = region_box;
region_box_dummy(1) = round(imgsize(2)/2 - abs(region_pos(1) - region_box_dummy(1)));
region_box_dummy(2) = round(imgsize(1)/2 - abs(region_pos(2) - region_box_dummy(2)));

window = fftimg_masked( region_box(2) : (region_box(2) + region_box(4)), ...
    region_box(1) : (region_box(1) + region_box(3)));
centreimg(   region_box_dummy(2) : (region_box_dummy(2) + region_box_dummy(4)), ...
    region_box_dummy(1) : (region_box_dummy(1) + region_box_dummy(3))) = window;

% % illustration of mask on fft image
% window_illustration = logimgmaxmin_masked(  region_box(2) : (region_box(2) + region_box(4)), ...
%                                             region_box(1) : (region_box(1) + region_box(3)));
% logimgmaxmin_masked_windowed = zeros(imgsize(1), imgsize(2));
% logimgmaxmin_masked_windowed(   region_box_dummy(2) : (region_box_dummy(2) + region_box_dummy(4)), ...
%                                 region_box_dummy(1) : (region_box_dummy(1) + region_box_dummy(3))) = window_illustration;

masking = toc

% reconstruction
intensity = abs(ifft2(ifftshift(centreimg))); % intensity
phase = angle(ifft2(ifftshift(centreimg))); % phase

reconstruction = toc

% unwrap
phase_unwrap = double(Miguel_2D_unwrapper(single(phase)));

unwraping = toc

% % resize image by 10 pixel
% resize = 1;
% intensity = intensity(resize:(imgsize(1)-resize), resize:(imgsize(2)-resize));
% % phase = phase(resize:(imgsize(1)-resize), resize:(imgsize(2)-resize));
% phase_unwrap = phase_unwrap(resize:(imgsize(1)-resize), resize:(imgsize(2)-resize));

invert = 1;
if invert == 1
    phase_unwrap = - phase_unwrap;
end

% curve removal
curve_phase = curve(phase_unwrap);
curve_intensity = curve(intensity);
phase_unwrap_no_curve = phase_unwrap - curve_phase;
intensity_no_curve = intensity - curve_intensity;

curve_toc = toc

% thickness calculation
wavelength = 632 * 10^(-3);
refractive_index_diff = 0.06;
factor = wavelength/(2*pi*refractive_index_diff);
thickness = (factor * phase_unwrap_no_curve);

% caution!!! set negative thickness to 0
low_limit = 1;
if low_limit == 1
    thickness(thickness < 0) = 0;
end

% apply median filter for 5 neighbouring pixels
% thickness = medfilt2(thickness, [5, 5]);

% apply weighted moving average filter for 5 neighbouring
% pixels using conv2
conv_mask = ones(5, 5) / 5^2;
thickness = conv2(thickness, conv_mask, 'same');

% resize thickness based on pixel size
thickness = imresize(thickness, 0.3);

% highlight spatial region
% show_crop_region = logimgmaxmin_masked;

dimmed_fftimg = logimgmaxmin;
dimmed_fftimg(   region_box(2) : (region_box(2) + region_box(4)), ...
    region_box(1) : (region_box(1) + region_box(3))) = ...
    dimmed_fftimg(   region_box(2) : (region_box(2) + region_box(4)), ...
    region_box(1) : (region_box(1) + region_box(3))) + 0.2;

output = toc

% Upper/lower colorbar limit
up_limit = 1;
up_limit_value = 10;
if up_limit == 0
    upper_limit = max(thickness, [], 'all');
else
    upper_limit = up_limit_value;
end

lower_limit = min(thickness, [], 'all');

% display intensity, phase image and spatial frequency, no unwrapping
%             figure('name', 'Auto Cropping');
%             subplot(3, 3, 1), imagesc(imgo); title('Hologram');
%             subplot(3, 3, 2), imagesc(intensity); title('Intensity'); colorbar;
%             subplot(3, 3, 3), imagesc(intensity_no_curve); title('Intensity Curve Removed'); colorbar;
%             subplot(3, 3, 4), imagesc(phase); title('Phase'); colorbar;
%             subplot(3, 3, 5), imagesc(phase_unwrap); title('Phase Unwrapped'); colorbar;
%             subplot(3, 3, 6), imagesc(phase_unwrap_no_curve); title('Phase Unwrapped Curve Removed'); colorbar;
%             subplot(3, 3, 7), imagesc(show_crop_region); title('Spatial Frequency Cropping'); colorbar;
%             subplot(3, 3, 8), imagesc(thickness); title('Thickness'); colorbar;
%             subplot(3, 3, 9), mesh(thickness); view(-100,50); title('Thickness'); colorbar;
figure('name', 'Auto Cropping');
subplot(3, 2, 1); imagesc(imgo); title('Hologram');
subplot(3, 2, 2); imagesc(dimmed_fftimg); title('Spatial Frequency Cropping'); colorbar;
subplot(3, 2, 3); imagesc(intensity_no_curve); title('Intensity'); colorbar;
subplot(3, 2, 4); imagesc(phase_unwrap_no_curve); title('Phase'); colorbar;
subplot(3, 2, 5); imagesc(thickness); title('Thickness'); colorbar; zlim([lower_limit, upper_limit]); caxis([lower_limit, upper_limit]);
subplot(3, 2, 6); mesh(thickness); title('Thickness'); colorbar; zlim([lower_limit, upper_limit]); caxis([lower_limit, upper_limit]);