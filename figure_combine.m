classdef figure_combine < handle
    methods
        function [status_box] = process(~, common_dir, desktop_path, folder_name, check_status_box, status_box)
            tic;
            save_folder = strcat(desktop_path, folder_name);
            mkdir(save_folder);
            
            original_input = strcat(common_dir, '\Hologram');
            fft_input = strcat(common_dir, '\fft');
            intensity_input = strcat(common_dir, '\intensity');
            thickness_input = strcat(common_dir, '\mesh');
            
            original_up = dir(strcat(original_input, '\*.tif'));
            fft_up = dir(strcat(fft_input, '\*.tif'));
            intensity_up = dir(strcat(intensity_input, '\*.tif'));
            thickness_up = dir(strcat(thickness_input, '\*.tif'));
            
            if length(original_up) == length(fft_up) && length(original_up) == length(intensity_up) && ...
                    length(original_up) == length(thickness_up) && length(fft_up) == length(intensity_up) && ...
                    length(fft_up) == length(thickness_up) && length(intensity_up) == length(thickness_up)
                up = length(original_up);
                
                count = 1;
                
                for index = 1 : up
                    close all;
                    original = original_up(index).name;
                    fft = fft_up(index).name;
                    intensity = intensity_up(index).name;
                    thickness = thickness_up(index).name;
                    
                    original_dir = strcat(original_input, '\', original);
                    fft_dir = strcat(fft_input, '\', fft);
                    intensity_dir = strcat(intensity_input, '\', intensity);
                    thickness_dir = strcat(thickness_input, '\', thickness);
                    
                    original_img = imread(original_dir);
                    fft_img = imread(fft_dir);
                    intensity_img = imread(intensity_dir);
                    thickness_img = imread(thickness_dir);
                    
                    combine = imtile({original_img, fft_img, intensity_img, thickness_img}, 'BackgroundColor', 'white', 'GridSize', [2 2]);
                    f = figure('visible','off');
                    original = erase(original, 'cropped_');
                    imshow(combine); title(['Frame ' erase(original, '.tif')])
                    saveas(gcf, [save_folder '\' 'combined_' original])
                    
                    if check_status_box == 1
                        status_box = ['Currently processing: ' erase(original, 'cropped_') newline num2str(up - count) ' images to go...'];
                    end
                    count = count + 1;
                end
                t = toc;
                status_box = ['Done! Total time: ' num2str(t) 's'];
            else
                status_box = ["Something is wrong. Did you copy and paste 'original' folder?" newline 'Or, check if numbers of figures across folders are equal.'];
            end
        end
    end
end