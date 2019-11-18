classdef reconstructor < handle
    methods
        function obj = reconstructor()
        end
        
        function [imgo, logimgmaxmin, fftimg] = load_img(~,path,open)
            if open
                imgo = imread(path); % open hologram
            else
                imgo = path;
            end
            [~, ~, img_dim] = size(imgo);
            if img_dim ~= 1
                img = double(rgb2gray(imgo)); % double format
            else
                img = double(imgo);
            end
            fftimg = fftshift(fft2(img)); % 2d fourier transform and translate to centre
            logimg = log(abs(fftimg)); % for illustration purpose only?
            logimgmaxmin = (logimg - min(min(logimg)))/(max(max(logimg))-min(min(logimg))); % normalise
        end
        
        function [centreimg,first_order] = manual_crop(~, batch_process, preview, fftimg, first_order)
            if batch_process <= 1
                figure('name', 'Manual FFT Cropping');
                imagesc(preview);
                roi_manual = drawrectangle;
                first_order = floor(roi_manual.Position);
                close 'Manual FFT Cropping';
            end
            imgsize = size(fftimg); %determine image size
            fftimgcrop = fftimg(first_order(2):first_order(2) + first_order(4), first_order(1):first_order(1) + first_order(3)); % locate first order
            centreimg = zeros(imgsize(1), imgsize(2)); % create a black image for placing first order
            centreimg(floor(imgsize(1)/2):floor(imgsize(1)/2)+first_order(4), floor(imgsize(2)/2):floor(imgsize(2)/2)+first_order(3)) = fftimgcrop; % place first order at centre
        end
        
        function [centreimg,region_box] = auto_crop(~, fftimg, logimgmaxmin,noise_level)
            % fft image gaussian fit and get global threshold level
            sigma = 4;
            logimg_filtered = imgaussfilt(logimgmaxmin, sigma);
            global_thresh = graythresh(logimg_filtered);
            
            imgsize = size(logimgmaxmin); %determine image size
            
            % seperate noise region and order region
            small_region = round((imgsize(1)/noise_level) * (imgsize(2)/noise_level)); % noise
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
        end
        
        function [intensity_no_curve, phase_unwrap_no_curve, thickness, lower_limit, upper_limit, frame_peak_height, frame_volume] = process(~, batch_process, center_fft, uplimit, lowlimit, invert, wavelength, ri, pixel_size)
            
            % reconstruct = ifft2(fftshift(centreimg)); % inverse fourier transform
            reconstructed = ifft2(ifftshift(center_fft));
            intensity = reconstructed.*conj(reconstructed); % intensity
            phase = angle(reconstructed); % phase
            
            % unwrap
            phase_unwrap = double(Miguel_2D_unwrapper(single(phase)));
            
            %             % resize image by 10 pixel
            %             resize = 1;
            %             intensity = intensity(resize:(imgsize(1)-resize), resize:(imgsize(2)-resize));
            %             % phase = phase(resize:(imgsize(1)-resize), resize:(imgsize(2)-resize));
            %             phase_unwrap = phase_unwrap(resize:(imgsize(1)-resize), resize:(imgsize(2)-resize));
            
            if invert == 1
                phase_unwrap = - phase_unwrap;
            end
            
            imgsize = size(center_fft);
            resize = 10;
            intensity = intensity(resize:(imgsize(1)-resize), resize:(imgsize(2)-resize));
            phase_unwrap = phase_unwrap(resize:(imgsize(1)-resize), resize:(imgsize(2)-resize));
            
            % curve removal
            curve_phase = curve(phase_unwrap);
            % curve_intensity = curve(intensity);
            phase_unwrap_no_curve = (phase_unwrap - curve_phase);
            intensity_no_curve = intensity; % - curve_intensity;
            
            % thickness calculation
            wavelength = wavelength * 10^(-3);
            refractive_index_diff = ri;
            factor = wavelength/(2*pi*refractive_index_diff);
            thickness = (factor * phase_unwrap_no_curve)';
            
            % caution!!! set negative thickness to 0
            if lowlimit == 1
                thickness(thickness < 0) = 0;
                if wavelength == 0
                    phase_unwrap_no_curve(phase_unwrap_no_curve < 0) = 0;
                end
            end
            
            % apply median filter for 5 neighbouring pixels
            % thickness = medfilt2(thickness, [5, 5]);
            
            % apply weighted moving average filter for 5 neighbouring
            % pixels using conv2
            conv_mask = ones(5, 5) / 5^2;
            thickness = conv2(thickness, conv_mask, 'same');
            
            % resize thickness based on pixel size
            thickness = imresize(thickness, pixel_size);
            
            if batch_process == 1
                d_xy = pixel_size;
                frame_peak_height = max(thickness, [], 'all');
                frame_volume = sum(thickness * d_xy * d_xy, 'all');
            else
                frame_peak_height = [];
                frame_volume = [];
            end
            
            % Upper/lower colorbar limit
            if uplimit == 0
                upper_limit = max(thickness, [], 'all');
            else
                upper_limit = uplimit;
            end
            
            if wavelength == 0
                lower_limit = min(phase_unwrap_no_curve, [], 'all');
            else
                lower_limit = min(thickness, [], 'all');
            end
        end
        
        function [up, save_folder, image_folder_path] = batch_make_folder(~, desktop_path, image_folder_path, save_folder_name, save_height, save_volume)
            up = dir(strcat(image_folder_path, '\*.tif'));
            save_folder = strcat(desktop_path, save_folder_name);
            mkdir(save_folder);
            mkdir([save_folder '\intensity']);
            mkdir([save_folder '\thickness']);
            mkdir([save_folder '\fft']);
            mkdir([save_folder '\mesh']);
            
            if save_height == 1
                mkdir([save_folder '\thickness_data']);
            end
            
            if save_volume == 1
                mkdir([save_folder '\volume_data']);
            end
        end
        
        function [video, total_frames, save_folder, peak_height, volume, dim] = video_direct_batch_processing(~, desktop_path, save_folder_name, video_path, start, ending, skip)
            save_folder = strcat(desktop_path, save_folder_name);
            mkdir(save_folder);
            mkdir([save_folder '\Hologram']);
            mkdir([save_folder '\intensity']);
            mkdir([save_folder '\thickness']);
            mkdir([save_folder '\fft']);
            mkdir([save_folder '\mesh']);
            mkdir([save_folder '\thickness_data']);
            mkdir([save_folder '\volume_data']);
            
            video = VideoReader(video_path);
            video.CurrentTime = start;
            total_frames = video.FrameRate * (ending - start);
            
            peak_height = zeros(ceil(total_frames/skip), 2);
            volume = zeros(ceil(total_frames/skip), 2);
            dim = [.2 .5 .3 .3];
        end
        
        function [peak_height, volume, dim] = height_volume_data(~, up)
            peak_height = zeros(length(up), 2);
            volume = zeros(length(up), 2);
            dim = [.2 .5 .3 .3];
        end
        
        function [height_array, volume_array] = single_frame_data(~, file, save_height, save_volume, save_folder, count, height, height_array, volume, volume_array, thickness)
            if save_height == 1
                writematrix(thickness, [save_folder '\thickness_data\' erase(file, '.tif') '.csv']);
                height_array(count, 1) = count;
                height_array(count, 2) = height;
            end
            
            if save_volume == 1
                volume_array(count, 1) = count;
                volume_array(count, 2) = volume;
            end
        end
        
        function all_frame_data(~, save_height, save_volume, height, volume, save_folder)
            if save_height == 1
                writematrix(height, [save_folder '\thickness_data\peak_height.csv']);
            end
            
            if save_volume == 1
                writematrix(volume, [save_folder '\volume_data\volume.csv']);
            end
        end
        
        function [show_crop_region] = show_fft_crop(~, fftlogimg, roi, uiaxes)
            show_crop_region = fftlogimg;
            show_crop_region(roi(2):roi(2) + roi(4), roi(1):roi(1) + roi(3)) = ...
                show_crop_region(roi(2):roi(2) + roi(4), roi(1):roi(1) + roi(3)) + 0.2;
            imshow(show_crop_region, 'parent', uiaxes);
        end
        
    end
end