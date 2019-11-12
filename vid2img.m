classdef vid2img < handle
    methods
        function obj = vid2img()
        end
        
        function folder_path = make_folder(~, desktop_path, folder_name)
            folder_path = strcat(desktop_path, folder_name);
            mkdir(folder_path);
            mkdir([folder_path '\cropped']);
            mkdir([folder_path '\original']);
        end
        
        function [video, start_frame, end_frame] = frame_calc(~, video_path, start_time, end_time)
            video = VideoReader(video_path);
            if start_time == 0
                start_frame = 1;
            else
                start_frame = start_time * video.FrameRate;
            end
            if end_time == 0
                end_frame = video.NumberOfFrames;
            elseif end_time >= round(video.Duration - 0.5)
                end_frame = video.NumberOfFrames;
            else
                end_frame = end_time * video.FrameRate;
            end
        end
        
        function convert(~, save_folder, video, roi, frame_interval, start_frame, end_frame, line_width)
            for count = start_frame : frame_interval : end_frame
                frame = read(video, count);
                img_original = frame;
                img_original(roi(2) : roi(2) + roi(4) - 1, roi(1) : roi(1) + line_width) = 255; % right
                img_original(roi(2) : roi(2) + roi(4) - 1, roi(1) + roi(3) - 1 - line_width : roi(1) + roi(3) - 1) = 255; % left
                img_original(roi(2) : roi(2) + line_width, roi(1) : roi(1) + roi(3) - 1) = 255; % top
                img_original(roi(2) + roi(4) - 1 - line_width : roi(2) + roi(4) - 1, roi(1) : roi(1) + roi(3) - 1) = 255; % bot
                img_cropped = imcrop(frame, [roi(1) roi(2) roi(3) roi(4)]);
                imwrite(img_original, [save_folder '\original\' 'original_' int2str(count), '.tif']);
                imwrite(img_cropped, [save_folder '\cropped\' 'cropped_' int2str(count), '.tif']);
                % Too fast, can't show...
                % app.ImagePathTextArea_2.Value = ['Extracting frame: Frame_index_' int2str(count)];
            end
        end
    end
end
