classdef test_ui_combined_input_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        DHMGUIV32UIFigure              matlab.ui.Figure
        FileSaveNameEditFieldLabel     matlab.ui.control.Label
        FileSaveNameEditField          matlab.ui.control.EditField
        ImagingLabel                   matlab.ui.control.Label
        ProcessingLabel                matlab.ui.control.Label
        StartPreviewButton             matlab.ui.control.Button
        StartRecordButton              matlab.ui.control.Button
        StopRecordButton               matlab.ui.control.Button
        StopPreviewButton              matlab.ui.control.Button
        WavelengthnmEditFieldLabel     matlab.ui.control.Label
        WavelengthnmEditField          matlab.ui.control.NumericEditField
        RefracIndexDiffEditFieldLabel  matlab.ui.control.Label
        RefracIndexDiffEditField       matlab.ui.control.NumericEditField
        PixelSizemEditFieldLabel       matlab.ui.control.Label
        PixelSizemEditField            matlab.ui.control.NumericEditField
        ApplyChangesButton             matlab.ui.control.Button
        ExposuresEditField_2Label      matlab.ui.control.Label
        ExposuresEditField             matlab.ui.control.NumericEditField
        CameraModeDropDownLabel        matlab.ui.control.Label
        CameraModeDropDown             matlab.ui.control.DropDown
        FramerateLiveEditFieldLabel    matlab.ui.control.Label
        FramerateLiveEditField         matlab.ui.control.NumericEditField
        FramerateSaveEditFieldLabel    matlab.ui.control.Label
        FramerateSaveEditField         matlab.ui.control.NumericEditField
        ROISelectButton                matlab.ui.control.Button
        ROIResetButton                 matlab.ui.control.Button
        ShowFFTButton                  matlab.ui.control.Button
        CloseFFTButton                 matlab.ui.control.Button
        LiveReconButton                matlab.ui.control.Button
        CloseReconButton               matlab.ui.control.Button
        UpperLimitEditField_3Label     matlab.ui.control.Label
        UpperLimitEditField            matlab.ui.control.NumericEditField
        InvertZaxisCheckBox            matlab.ui.control.CheckBox
        LowerLimitCheckBox             matlab.ui.control.CheckBox
        PreviewButton                  matlab.ui.control.Button
        SelectFileButton               matlab.ui.control.Button
        TextArea                       matlab.ui.control.TextArea
        SetROIButton                   matlab.ui.control.Button
        UIAxes                         matlab.ui.control.UIAxes
        ConverttoimagesButton          matlab.ui.control.Button
        FrameSkipEditFieldLabel        matlab.ui.control.Label
        FrameSkipEditField             matlab.ui.control.NumericEditField
        StartsecEditFieldLabel         matlab.ui.control.Label
        StartsecEditField              matlab.ui.control.NumericEditField
        EndsecEditFieldLabel           matlab.ui.control.Label
        EndsecEditField                matlab.ui.control.NumericEditField
        NoiseLevelEditField_3Label     matlab.ui.control.Label
        NoiseLevelEditField            matlab.ui.control.NumericEditField
        RunAutoButton                  matlab.ui.control.Button
        RunManualButton                matlab.ui.control.Button
        ImageFolderEditFieldLabel      matlab.ui.control.Label
        ImageFolderEditField           matlab.ui.control.EditField
        OutputFolderEditFieldLabel     matlab.ui.control.Label
        OutputFolderEditField          matlab.ui.control.EditField
        SelectFolderButton             matlab.ui.control.Button
        Label                          matlab.ui.control.Label
        version                        matlab.ui.control.TextArea
        OutputRawResultImagesCheckBox  matlab.ui.control.CheckBox
    end

    
    properties (Access = public)
        file_path  % file selection
        image_status
        video_status
        image_folder_path   % image folder selection
        image_folder_status
        processing_roi
        desktop_path        % system desktop directory
        
        my_recorder
        my_camera
        my_reconstructor
        my_vid2img
        
        previewing = false;
        fft_check_control
        live_recon_control
    end
    
    methods (Access = private)
        function reset_input_selection(app)
            app.SelectFileButton.Enable = 'on';
            app.SelectFolderButton.Enable = 'on';
            app.PreviewButton.Enable = 'off';
            app.SetROIButton.Enable = 'off';
            app.ConverttoimagesButton.Enable = 'off';
            app.FrameSkipEditField.Enable = 'off';
            app.StartsecEditField.Enable = 'off';
            app.EndsecEditField.Enable = 'off';
            app.RunAutoButton.Enable = 'off';
            app.RunManualButton.Enable = 'off';
            app.TextArea.Value = '';
            app.ImageFolderEditField.Value = 'image_folder';
            app.OutputFolderEditField.Value = 'output_folder';
            app.image_status = 0;
            app.video_status = 0;
            app.image_folder_status = 0;
            cla(app.UIAxes);
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            [~, app.desktop_path] = system('echo %USERPROFILE%');
            app.desktop_path = strcat(app.desktop_path, '\Desktop\');
            app.my_recorder = recorder;
            app.my_reconstructor = reconstructor;
            app.my_vid2img = vid2img;
            
            app.StartPreviewButton.Enable = 'on';
            app.StopPreviewButton.Enable = 'off';
            app.StartRecordButton.Enable = 'off';
            app.StopRecordButton.Enable = 'off';
            app.ApplyChangesButton.Enable = 'off';
            app.ROISelectButton.Enable = 'off';
            app.ROIResetButton.Enable = 'off';
            app.ShowFFTButton.Enable = 'off';
            app.CloseFFTButton.Enable = 'off';
            app.LiveReconButton.Enable = 'off';
            app.CloseReconButton.Enable = 'off';
            
            app.SelectFileButton.Enable = 'on';
            app.SelectFolderButton.Enable = 'on';
            app.PreviewButton.Enable = 'off';
            app.SetROIButton.Enable = 'off';
            app.ConverttoimagesButton.Enable = 'off';
            app.FrameSkipEditField.Enable = 'off';
            app.StartsecEditField.Enable = 'off';
            app.EndsecEditField.Enable = 'off';
            app.RunAutoButton.Enable = 'off';
            app.RunManualButton.Enable = 'off';
        end

        % Button pushed function: StartPreviewButton
        function StartPreviewButtonPushed(app, event)
            imaqreset;
            app.my_camera = camera(app.CameraModeDropDown.Value, app.ExposuresEditField.Value); % to-do: put somewhere else
            
            preview(app.my_camera.vid);
            app.previewing = true;
            app.FramerateLiveEditField.Value = app.my_camera.src.AcquisitionResultingFrameRate;
            app.FramerateSaveEditField.Value = app.my_camera.src.AcquisitionResultingFrameRate;
            
            app.StartPreviewButton.Enable = 'off';
            app.StopPreviewButton.Enable = 'on';
            app.StartRecordButton.Enable = 'on';
            app.StopRecordButton.Enable = 'off';
            app.ApplyChangesButton.Enable = 'on';
            
            app.ROISelectButton.Enable = 'on';
            app.ROIResetButton.Enable = 'on';
            app.ShowFFTButton.Enable = 'on';
            app.CloseFFTButton.Enable = 'on';
            app.LiveReconButton.Enable = 'on';
            app.CloseReconButton.Enable = 'on';
        end

        % Button pushed function: StartRecordButton
        function StartRecordButtonPushed(app, event)
            if app.previewing == true
                app.my_recorder.start(app.my_camera,app.desktop_path,app.FileSaveNameEditField.Value);
                
                app.StartRecordButton.Enable = 'off';
                app.StopRecordButton.Enable = 'on';
                app.StartPreviewButton.Enable = 'off';
                app.StopPreviewButton.Enable = 'off';
                app.ApplyChangesButton.Enable = 'off';
                
                app.ROISelectButton.Enable = 'off';
                app.ROIResetButton.Enable = 'off';
                app.ShowFFTButton.Enable = 'off';
                app.CloseFFTButton.Enable = 'off';
                app.LiveReconButton.Enable = 'off';
                app.CloseReconButton.Enable = 'off';
            end
        end

        % Button pushed function: StopRecordButton
        function StopRecordButtonPushed(app, event)
            if app.previewing == true
                app.my_recorder.stop(app.my_camera);
                
                app.StartPreviewButton.Enable = 'off';
                app.StopPreviewButton.Enable = 'on';
                app.StartRecordButton.Enable = 'on';
                app.StopRecordButton.Enable = 'off';
                app.ApplyChangesButton.Enable = 'on';
                
                app.ROISelectButton.Enable = 'on';
                app.ROIResetButton.Enable = 'on';
                app.ShowFFTButton.Enable = 'on';
                app.CloseFFTButton.Enable = 'on';
                app.LiveReconButton.Enable = 'on';
                app.CloseReconButton.Enable = 'on';
            end
        end

        % Button pushed function: StopPreviewButton
        function StopPreviewButtonPushed(app, event)
            if app.previewing == true
                closepreview(app.my_camera.vid);
                app.previewing = false;
                
                app.StartPreviewButton.Enable = 'on';
                app.StopPreviewButton.Enable = 'off';
                app.StartRecordButton.Enable = 'off';
                app.StopRecordButton.Enable = 'off';
                app.ApplyChangesButton.Enable = 'off';
                
                app.ROISelectButton.Enable = 'off';
                app.ROIResetButton.Enable = 'off';
                app.ShowFFTButton.Enable = 'off';
                app.CloseFFTButton.Enable = 'off';
                app.LiveReconButton.Enable = 'off';
                app.CloseReconButton.Enable = 'off';
            end
            imaqreset;
        end

        % Button pushed function: ApplyChangesButton
        function ApplyChangesButtonPushed(app, event)
            if strcmp(app.my_camera.mode, app.CameraModeDropDown.Value)
                app.my_camera.src.ExposureTime = app.ExposuresEditField.Value;
            else
                StartPreviewButtonPushed(app, event);
            end
        end

        % Button pushed function: ROISelectButton
        function ROISelectButtonPushed(app, event)
            frame = getsnapshot(app.my_camera.vid);
            figure('Name', 'Preview ROI Select')
            imshow(frame, [min(frame(:)) max(frame(:))]);
            roi = drawrectangle;
            app.my_camera.vid.ROIPosition = floor(roi.Position);
            close 'Preview ROI Select';
        end

        % Button pushed function: ROIResetButton
        function ROIResetButtonPushed(app, event)
            app.my_camera.vid.ROIPosition = [384 368 1280 800];
        end

        % Button pushed function: ShowFFTButton
        function ShowFFTButtonPushed(app, event)
            app.fft_check_control = 1;
            figure('Name', 'FFT Check');
            while app.fft_check_control == 1
                img = getsnapshot(app.my_camera.vid);
                logimg = log(abs(fftshift(fft2(double(img)))));
                logimgmaxmin = (logimg - min(min(logimg)))/(max(max(logimg))-min(min(logimg))); % normalise
                imagesc(logimgmaxmin);
            end
            close 'FFT Check';
        end

        % Button pushed function: CloseFFTButton
        function CloseFFTButtonPushed(app, event)
            app.fft_check_control = 0;
        end

        % Button pushed function: LiveReconButton
        function LiveReconButtonPushed(app, event)
            
            figure('Name', 'FFT Cropping for Live Reconstruction');
            img = getsnapshot(app.my_camera.vid);
            
            try
                gpuDevice;
                img = gpuArray(img);
            catch ME
                warning("GPU not enabled.");
                ME;
            end
            
            app.live_recon_control = 1;
            logimg = log(abs(fftshift(fft2(double(img)))));
            logimgmaxmin = (logimg - min(min(logimg)))/(max(max(logimg))-min(min(logimg))); % normalise
            imshow(logimgmaxmin);
            roi_live = drawrectangle;
            first_order = floor(roi_live.Position);
            close 'FFT Cropping for Live Reconstruction';
            
            app.live_recon_control = 1;
            figure('Name', 'Live Reconstruction');
            while app.live_recon_control == 1
                tic
                img = getsnapshot(app.my_camera.vid);
                
                try
                    img = gpuArray(img);
                catch ME
                    
                end
                
                fftimg = fftshift(fft2(img)); % 2d fourier transform and translate to centre
                imgsize = size(fftimg); % determine image size
                
                fftimgcrop = fftimg(first_order(2):first_order(2) + first_order(4), first_order(1):first_order(1) + first_order(3)); % locate first order
                centreimg = gpuArray(zeros(imgsize(1), imgsize(2))); % create a black image for placing first order
                centreimg(floor(imgsize(1)/2):floor(imgsize(1)/2)+first_order(4), floor(imgsize(2)/2):floor(imgsize(2)/2)+first_order(3)) = fftimgcrop; % place first order at centre
                phase = angle(ifft2(ifftshift(centreimg))); % phase
                phase = gather(phase);
                phase_unwrap = double(Miguel_2D_unwrapper(single(phase)));
                %phase_unwrap = gather(phase_unwrap);
                %                 wavelength = app.WavelengthnmEditField.Value * 10^(-3);
                %                 refractive_index_diff = app.RefracIndexDiffEditField.Value;
                %                 factor = wavelength/(2*pi*refractive_index_diff);
                %                 thickness = (factor * phase_unwrap);
                %                 thickness(thickness < 0) = 0;
                %                 conv_mask = ones(5, 5) / 5^2;
                %                 thickness = conv2(thickness, conv_mask, 'same');
                %                 thickness = imresize(thickness, app.PixelSizemEditField.Value);
                imagesc(phase_unwrap); colorbar;
                toc
                pause(0.1); % to-do: why does this need to be here????
            end
        end

        % Button pushed function: CloseReconButton
        function CloseReconButtonPushed(app, event)
            app.live_recon_control = 0;
            close 'Live Reconstruction';
        end

        % Value changed function: ExposuresEditField
        function ExposuresEditFieldValueChanged(app, event)
            app.my_camera.src.ExposureTime = app.ExposuresEditField.Value;
        end

        % Close request function: DHMGUIV32UIFigure
        function DHMGUIV32UIFigureCloseRequest(app, event)
            if app.previewing == true
                closepreview(app.my_camera.vid);
                app.previewing = false;
            end
            delete(app);
            imaqreset;
        end

        % Button pushed function: SelectFileButton
        function SelectFileButtonPushed(app, event)
            [name, folder] = uigetfile({'*.avi; *.tif; *.tiff'}, 'Select image or video', app.desktop_path);
            drawnow;
            figure(app.DHMGUIV32UIFigure);
            if ~isequal(name,0)
                app.file_path = fullfile(folder, name);
                if strcmp(name(end-3:end), '.avi')
                    app.TextArea.Value = ['Video selected: ' app.file_path];
                    video = VideoReader(app.file_path);
                    app.EndsecEditField.Value = video.Duration;
                    app.ImageFolderEditField.Value = [name '_image_folder'];
                    app.OutputFolderEditField.Value = [name '_output_folder'];
                    
                    app.StartsecEditField.Enable = 'on';
                    app.EndsecEditField.Enable = 'on';
                    app.ConverttoimagesButton.Enable = 'off';
                    app.FrameSkipEditField.Enable = 'on';
                    app.ImageFolderEditField.Enable = 'on';
                    app.video_status = 1;
                    app.image_status = 0;
                    app.image_folder_status = 0;
                else
                    app.TextArea.Value = ['Image selected: ' app.file_path];
                    app.StartsecEditField.Enable = 'off';
                    app.EndsecEditField.Enable = 'off';
                    app.ConverttoimagesButton.Enable = 'off';
                    app.FrameSkipEditField.Enable = 'off';
                    app.ImageFolderEditField.Enable = 'off';
                    app.ImageFolderEditField.Value = 'image_folder';
                    app.OutputFolderEditField.Value = 'output_folder';
                    app.image_status = 1;
                    app.video_status = 0;
                    app.image_folder_status = 0;
                end
                app.PreviewButton.Enable = 'on';
                app.SetROIButton.Enable = 'on';
            else
                reset_input_selection(app);
            end
        end

        % Button pushed function: SelectFolderButton
        function SelectFolderButtonPushed(app, event)
            app.image_folder_path = uigetdir(app.desktop_path, 'Select image folder');
            drawnow;
            figure(app.DHMGUIV32UIFigure);
            if ~isequal(app.image_folder_path,0)
                contents = dir([app.image_folder_path '\*.tif']);
                if ~isempty(contents)
                    [~,name] = fileparts(app.image_folder_path);
                    app.TextArea.Value = ['Image Folder selected: ' app.image_folder_path];
                    app.OutputFolderEditField.Value = [name '_output_folder'];
                    app.StartsecEditField.Enable = 'off';
                    app.EndsecEditField.Enable = 'off';
                    app.ConverttoimagesButton.Enable = 'off';
                    app.FrameSkipEditField.Enable = 'off';
                    app.ImageFolderEditField.Enable = 'off';
                    app.ImageFolderEditField.Value = 'image_folder';
                    app.image_status = 0;
                    app.video_status = 0;
                    app.image_folder_status = 1;
                else
                    app.TextArea.Value = 'Folder is empty, select a new folder.';
                end
                app.SetROIButton.Enable = 'on';
            else
                reset_input_selection(app);
            end
        end

        % Button pushed function: PreviewButton
        function PreviewButtonPushed(app, event)
            if app.image_status
                figure('Name', 'Image Preview');
                imshow(app.file_path);
            end
            if app.video_status
                implay(app.file_path);
            end
        end

        % Button pushed function: SetROIButton
        function SetROIButtonPushed(app, event)
            if app.image_status
                image = imread(app.file_path);
                figure('name', 'Processing ROI Select');
                imshow(image);
                roi = drawrectangle;
                app.processing_roi = ceil(roi.Position);
                close 'Processing ROI Select';
                line_width = 10;
                image(app.processing_roi(2) : app.processing_roi(2) + app.processing_roi(4) - 1, app.processing_roi(1) : app.processing_roi(1) + line_width) = 255; % right
                image(app.processing_roi(2) : app.processing_roi(2) + app.processing_roi(4) - 1, app.processing_roi(1) + app.processing_roi(3) - 1 - line_width : app.processing_roi(1) + app.processing_roi(3) - 1) = 255; % left
                image(app.processing_roi(2) : app.processing_roi(2) + line_width, app.processing_roi(1) : app.processing_roi(1) + app.processing_roi(3) - 1) = 255; % top
                image(app.processing_roi(2) + app.processing_roi(4) - 1 - line_width : app.processing_roi(2) + app.processing_roi(4) - 1, app.processing_roi(1) : app.processing_roi(1) + app.processing_roi(3) - 1) = 255; % bot
                imshow(image, 'parent', app.UIAxes);
                app.RunAutoButton.Enable = 'on';
                app.RunManualButton.Enable = 'on';
            end
            if app.video_status
                video = VideoReader(app.file_path);
                video.CurrentTime = app.StartsecEditField.Value;
                frame = readFrame(video);
                figure('name', 'Processing ROI Select');
                imshow(frame);
                roi = drawrectangle;
                app.processing_roi = ceil(roi.Position);
                close 'Processing ROI Select';
                line_width = 10;
                frame(app.processing_roi(2) : app.processing_roi(2) + app.processing_roi(4) - 1, app.processing_roi(1) : app.processing_roi(1) + line_width) = 255; % right
                frame(app.processing_roi(2) : app.processing_roi(2) + app.processing_roi(4) - 1, app.processing_roi(1) + app.processing_roi(3) - 1 - line_width : app.processing_roi(1) + app.processing_roi(3) - 1) = 255; % left
                frame(app.processing_roi(2) : app.processing_roi(2) + line_width, app.processing_roi(1) : app.processing_roi(1) + app.processing_roi(3) - 1) = 255; % top
                frame(app.processing_roi(2) + app.processing_roi(4) - 1 - line_width : app.processing_roi(2) + app.processing_roi(4) - 1, app.processing_roi(1) : app.processing_roi(1) + app.processing_roi(3) - 1) = 255; % bot
                imshow(frame, 'parent', app.UIAxes);
                
                app.ConverttoimagesButton.Enable = 'on';
                app.RunAutoButton.Enable = 'on';
                app.RunManualButton.Enable = 'on';
            end
            if app.image_folder_status
                app.image_folder_path
                contents = dir([app.image_folder_path '\*.tif']);
                first_image_name = contents(1).name;
%                 image = imread([app.image_folder_path '\' first_image_name]);
                figure('name', 'Processing ROI Select');
                imshow(image);
                roi = drawrectangle;
                app.processing_roi = ceil(roi.Position);
                close 'Processing ROI Select';
                line_width = 10;
                image(app.processing_roi(2) : app.processing_roi(2) + app.processing_roi(4) - 1, app.processing_roi(1) : app.processing_roi(1) + line_width) = 255; % right
                image(app.processing_roi(2) : app.processing_roi(2) + app.processing_roi(4) - 1, app.processing_roi(1) + app.processing_roi(3) - 1 - line_width : app.processing_roi(1) + app.processing_roi(3) - 1) = 255; % left
                image(app.processing_roi(2) : app.processing_roi(2) + line_width, app.processing_roi(1) : app.processing_roi(1) + app.processing_roi(3) - 1) = 255; % top
                image(app.processing_roi(2) + app.processing_roi(4) - 1 - line_width : app.processing_roi(2) + app.processing_roi(4) - 1, app.processing_roi(1) : app.processing_roi(1) + app.processing_roi(3) - 1) = 255; % bot
                imshow(image, 'parent', app.UIAxes);
                app.RunAutoButton.Enable = 'on';
                app.RunManualButton.Enable = 'on';
            end
        end

        % Button pushed function: ConverttoimagesButton
        function ConverttoimagesButtonPushed(app, event)
            app.TextArea.Value = 'Converting...';
            pause(0.1);
            tic;
            [video, start_frame, end_frame] = app.my_vid2img.frame_calc(app.file_path, app.StartsecEditField.Value, app.EndsecEditField.Value);
            save_folder = app.my_vid2img.make_folder(app.desktop_path, app.ImageFolderEditField.Value);
            line_width = 5;
            app.my_vid2img.convert(save_folder, video, app.processing_roi, app.FrameSkipEditField.Value, start_frame, end_frame, line_width);
            t = toc;
            app.TextArea.Value = ['Done! Total time: ' num2str(t) 's'];
        end

        % Button pushed function: RunManualButton
        function RunManualButtonPushed(app, event)
            if app.image_status
                tic;
                
                batch_process = 0;
                first_order = [0 0 0 0];
                [imgo, preview, fftimg] = app.my_reconstructor.load_img(app.file_path, 1, app.processing_roi);
                [centreimg,first_order] = app.my_reconstructor.manual_crop(batch_process,preview,fftimg, first_order);
                [intensity_no_curve, phase_unwrap_no_curve, thickness, lower_limit, upper_limit, ~, ~] = app.my_reconstructor.process(batch_process, centreimg, app.UpperLimitEditField.Value, ...
                    app.LowerLimitCheckBox.Value, app.InvertZaxisCheckBox.Value, app.WavelengthnmEditField.Value, app.RefracIndexDiffEditField.Value, app.PixelSizemEditField.Value);
                
                % highlight spatial region
                [show_crop_region] = app.my_reconstructor.show_fft_crop(preview, first_order, app.UIAxes);
                
                figure('name', 'Manual Cropping');
                subplot(3, 2, 1), imagesc(imgo); title('Hologram');
                subplot(3, 2, 2), imagesc(show_crop_region); title('Spatial Frequency Cropping'); colorbar;
                subplot(3, 2, 3), imagesc(intensity_no_curve); title('Intensity'); colorbar;
                subplot(3, 2, 4), imagesc(phase_unwrap_no_curve); title('Phase'); colorbar;
                subplot(3, 2, 5), imagesc(thickness); title('Thickness'); colorbar; zlim([lower_limit, upper_limit]); caxis([lower_limit, upper_limit]);
                subplot(3, 2, 6), mesh(thickness); title('Thickness'); colorbar; zlim([lower_limit, upper_limit]); caxis([lower_limit, upper_limit]); set(gca,'Ydir','reverse');
                t = toc;
                
                app.TextArea.Value = ['Done! Manual cropping performed.' newline 'Total time: ' num2str(t) 's'];
                
            end
            if app.image_folder_status
                tic;
                
                [up, save_folder, input] = app.my_reconstructor.batch_make_folder(app.desktop_path, app.image_folder_path, ...
                    app.OutputFolderEditField.Value, 1, 1);
                
                % peak height and volume for frames
                [peak_height, volume, dim] = app.my_reconstructor.height_volume_data(up);
                
                count = 1;
                first_order = [0 0 0 0];
                
                for index = 1 : length(up)
                    close all;
                    file = up(index).name;
                    file_dir = strcat(input, '\', file);
                    
                    [~, logimgmaxmin, fftimg] = app.my_reconstructor.load_img(file_dir, 1, app.processing_roi);
                    [centreimg, first_order] = app.my_reconstructor.manual_crop(index, logimgmaxmin, fftimg, first_order);
                    
                    batch_process = 1;
                    [intensity_no_curve, ~, thickness, lower_limit, upper_limit, frame_peak_height, frame_volume] = app.my_reconstructor.process(batch_process, centreimg, app.UpperLimitEditField.Value, ...
                        app.LowerLimitCheckBox.Value, app.InvertZaxisCheckBox.Value, app.WavelengthnmEditField.Value, app.RefracIndexDiffEditField.Value, app.PixelSizemEditField.Value);
                    
                    % hightlight spatial region
                    [show_crop_region] = app.my_reconstructor.show_fft_crop(logimgmaxmin, first_order, app.UIAxes);
                    
                    % save intensity and thickness images
                    f = figure('visible','off');
                    imagesc(intensity_no_curve); title('Intensity'); colorbar;
                    saveas(gca, [save_folder '\intensity\' 'intensity_' file]); caxis([-10, 10]);
                    imagesc(thickness); title('Thickness'); colorbar; zlim([lower_limit, upper_limit]); caxis([lower_limit, upper_limit]);
                    saveas(gca, [save_folder '\thickness\' 'thickness_' file]);
                    imagesc(show_crop_region); title('Spatial Frequency'); colorbar;
                    saveas(gca, [save_folder '\fft\' 'fft_' file]);
                    mesh(thickness); colorbar; zlim([lower_limit, upper_limit]); caxis([lower_limit, upper_limit]); set(gca,'Ydir','reverse');
                    text = ['Peak Height: ' num2str(frame_peak_height) newline 'Volume: ' num2str(frame_volume)];
                    annotation('textbox', dim, 'String', text, 'FitBoxToText', 'on');
                    saveas(gca, [save_folder '\mesh\' 'mesh_' file]);
                    
                    % save .csv for thickness
                    [peak_height, volume] = app.my_reconstructor.single_frame_data(file, 1, 1, save_folder, ...
                        count, frame_peak_height, peak_height, frame_volume, volume, thickness); % natural file order bug
                    
                    app.TextArea.Value = ['(Manual) Currently processing image: ' file newline num2str(length(up) - count) ' images to go...'];
                    
                    count = count + 1;
                end
                
                app.my_reconstructor.all_frame_data(1, 1, peak_height, volume, save_folder);
                
                t = toc;
                
                destination = [save_folder '\Hologram'];
                copyfile(input, destination);
                
                app.TextArea.Value = ['Done! Total time: ' num2str(t) 's'];
                
            end
            if app.video_status
                tic

                [video, start_frame, total_frames, save_folder, peak_height, volume, dim] = app.my_reconstructor.video_direct_batch_processing(app.desktop_path, app.OutputFolderEditField.Value, ...
                    app.file_path, app.StartsecEditField.Value, app.EndsecEditField.Value, app.FrameSkipEditField.Value);
                
                count = 1;
                first_order = [0 0 0 0];
                
                for index = start_frame : app.FrameSkipEditField.Value : start_frame + total_frames - 1
                    close all;
                    frame = read(video, index);
                    frame_cropped = imcrop(frame, [app.processing_roi(1) app.processing_roi(2) app.processing_roi(3) app.processing_roi(4)]);
                    [~, logimgmaxmin, fftimg] = app.my_reconstructor.load_img(frame_cropped, 0, app.processing_roi);
                    [centreimg, first_order] = app.my_reconstructor.manual_crop(count, logimgmaxmin, fftimg, first_order);
                    
                    batch_process = 1;
                    [intensity_no_curve, ~, thickness, lower_limit, upper_limit, frame_peak_height, frame_volume] = app.my_reconstructor.process(batch_process, centreimg, app.UpperLimitEditField.Value, ...
                        app.LowerLimitCheckBox.Value, app.InvertZaxisCheckBox.Value, app.WavelengthnmEditField.Value, app.RefracIndexDiffEditField.Value, app.PixelSizemEditField.Value);
                    
                    % hightlight spatial region
                    [show_crop_region] = app.my_reconstructor.show_fft_crop(logimgmaxmin, first_order, app.UIAxes);
                    
                    % save intensity and thickness images
                    file = ['cropped_' int2str(index), '.tif'];
                    if app.OutputRawResultImagesCheckBox.Value
                        intensity_no_curve;
                        thickness;
                        show_crop_region;
                    else
                        f = figure('visible','off');
                        imagesc(intensity_no_curve); title('Intensity'); colorbar;
                        saveas(gca, [save_folder '\intensity\' 'intensity_' file]);
                        imagesc(thickness); title('Thickness'); colorbar; zlim([lower_limit, upper_limit]); caxis([lower_limit, upper_limit]);
                        saveas(gca, [save_folder '\thickness\' 'thickness_' file]);
                        imagesc(show_crop_region); title('Spatial Frequency'); colorbar;
                        saveas(gca, [save_folder '\fft\' 'fft_' file]);
                        mesh(thickness); colorbar; zlim([lower_limit, upper_limit]); caxis([lower_limit, upper_limit]); set(gca,'Ydir','reverse');
                        text = ['Peak Height: ' num2str(frame_peak_height) newline 'Volume: ' num2str(frame_volume)];
                        annotation('textbox', dim, 'String', text, 'FitBoxToText', 'on');
                        saveas(gca, [save_folder '\mesh\' 'mesh_' file]);
                    end
                    imwrite(frame_cropped, [save_folder '\Hologram\' file]);
                    
                    % save .csv for thickness
                    [peak_height, volume] = app.my_reconstructor.single_frame_data(file, 1, 1, save_folder, ...
                        count, frame_peak_height, peak_height, frame_volume, volume, thickness);
                    
                    app.TextArea.Value = ['(Manual) Currently processing image: ' file newline num2str(ceil(total_frames/app.FrameSkipEditField.Value) - count) ' images to go...'];
                    
                    count = count + 1;
                end
                
                app.my_reconstructor.all_frame_data(1, 1, peak_height, volume, save_folder);
                
                t = toc;
                
                app.TextArea.Value = ['Done! Total time: ' num2str(t) 's'];
                
            end
        end

        % Button pushed function: RunAutoButton
        function RunAutoButtonPushed(app, event)
            if app.image_status
                tic;
                
                [imgo, logimgmaxmin, fftimg] = app.my_reconstructor.load_img(app.file_path, 1, app.processing_roi);
                
                [centreimg,region_box] = app.my_reconstructor.auto_crop(fftimg,logimgmaxmin,app.NoiseLevelEditField.Value);
                
                batch_process = 0;
                [intensity_no_curve, phase_unwrap_no_curve, thickness, lower_limit, upper_limit, ~, ~] = app.my_reconstructor.process(batch_process, centreimg, app.UpperLimitEditField.Value, ...
                    app.LowerLimitCheckBox.Value, app.InvertZaxisCheckBox.Value, app.WavelengthnmEditField.Value, app.RefracIndexDiffEditField.Value, app.PixelSizemEditField.Value);
                
                [dimmed_fftimg] = app.my_reconstructor.show_fft_crop(logimgmaxmin, region_box, app.UIAxes);
                
                figure('name', 'Auto Cropping');
                subplot(3, 2, 1); imagesc(imgo); title('Hologram');
                subplot(3, 2, 2); imagesc(dimmed_fftimg); title('Spatial Frequency Cropping'); colorbar;
                subplot(3, 2, 3); imagesc(intensity_no_curve); title('Intensity'); colorbar;
                subplot(3, 2, 4); imagesc(phase_unwrap_no_curve); title('Phase'); colorbar;
                subplot(3, 2, 5); imagesc(thickness); title('Thickness'); colorbar; zlim([lower_limit, upper_limit]); caxis([lower_limit, upper_limit]);
                subplot(3, 2, 6); mesh(thickness); title('Thickness'); colorbar; zlim([lower_limit, upper_limit]); caxis([lower_limit, upper_limit]); set(gca,'Ydir','reverse');
                
                t = toc;
                app.TextArea.Value = ['Done! Auto cropping performed.' newline 'Total time: ' num2str(t) 's'];
                
            end
            if app.image_folder_status
                tic;
                
                [up, save_folder, input] = app.my_reconstructor.batch_make_folder(app.desktop_path, app.image_folder_path, ...
                    app.OutputFolderEditField.Value, 1, 1);
                
                % peak height and volume for frames
                [peak_height, volume, dim] = app.my_reconstructor.height_volume_data(up);
                
                count = 1;
                
                for index = 1 : length(up)
                    close all;
                    file = up(index).name;
                    file_dir = strcat(input, '\', file);
                    
                    [~, logimgmaxmin, fftimg] = app.my_reconstructor.load_img(file_dir, 1, app.processing_roi);
                    [centreimg,region_box] = app.my_reconstructor.auto_crop(fftimg, logimgmaxmin,app.NoiseLevelEditField.Value);
                    
                    batch_process = 1;
                    [intensity_no_curve, ~, thickness, lower_limit, upper_limit, frame_peak_height, frame_volume] = app.my_reconstructor.process(batch_process, centreimg, app.UpperLimitEditField.Value, ...
                        app.LowerLimitCheckBox.Value, app.InvertZaxisCheckBox.Value, app.WavelengthnmEditField.Value, app.RefracIndexDiffEditField.Value, app.PixelSizemEditField.Value);
                    
                    % hightlight spatial region
                    [dimmed_fftimg] = app.my_reconstructor.show_fft_crop(logimgmaxmin, region_box, app.UIAxes);
                    
                    % save intensity and thickness images
                    f = figure('visible','off');
                    imagesc(intensity_no_curve); title('Intensity'); colorbar;
                    saveas(gca, [save_folder '\intensity\' 'intensity_' file]); caxis([-10, 10]);
                    imagesc(thickness); title('Thickness'); colorbar; zlim([lower_limit, upper_limit]); caxis([lower_limit, upper_limit]);
                    saveas(gca, [save_folder '\thickness\' 'thickness_' file]);
                    imagesc(dimmed_fftimg); title('Spatial Frequency'); colorbar;
                    saveas(gca, [save_folder '\fft\' 'fft_' file]);
                    mesh(thickness); colorbar; zlim([lower_limit, upper_limit]); caxis([lower_limit, upper_limit]); set(gca,'Ydir','reverse');
                    text = ['Peak Height: ' num2str(frame_peak_height) newline 'Volume: ' num2str(frame_volume)];
                    annotation('textbox', dim, 'String', text, 'FitBoxToText', 'on');
                    saveas(gca, [save_folder '\mesh\' 'mesh_' file]);
                    
                    % save .csv for thickness
                    [peak_height, volume] = app.my_reconstructor.single_frame_data(file, 1, 1, save_folder, ...
                        count, frame_peak_height, peak_height, frame_volume, volume, thickness);
                    
                    app.TextArea.Value = ['(Manual) Currently processing image: ' file newline num2str(length(up) - count) ' images to go...'];
                    
                    count = count + 1;
                end
                
                app.my_reconstructor.all_frame_data(1, 1, peak_height, volume, save_folder);
                
                t = toc;
                
                destination = [save_folder '\Hologram'];
                copyfile(input, destination);
                
                app.TextArea.Value = ['Done! Total time: ' num2str(t) 's'];
                
            end
            if app.video_status
                tic
                
                [video, start_frame, total_frames, save_folder, peak_height, volume, dim] = app.my_reconstructor.video_direct_batch_processing(app.desktop_path, app.OutputFolderEditField.Value, ...
                    app.file_path, app.StartsecEditField.Value, app.EndsecEditField.Value, app.FrameSkipEditField.Value);
                
                count = 1;
                
                for index = start_frame : app.FrameSkipEditField.Value : start_frame + total_frames - 1
                    close all;
                    frame = read(video, index);
                    frame_cropped = imcrop(frame, [app.processing_roi(1) app.processing_roi(2) app.processing_roi(3) app.processing_roi(4)]);
                    [~, logimgmaxmin, fftimg] = app.my_reconstructor.load_img(frame_cropped, 0, 0);
                    [centreimg,region_box] = app.my_reconstructor.auto_crop(fftimg, logimgmaxmin,app.NoiseLevelEditField.Value);
                    
                    batch_process = 1;
                    [intensity_no_curve, ~, thickness, lower_limit, upper_limit, frame_peak_height, frame_volume] = app.my_reconstructor.process(batch_process, centreimg, app.UpperLimitEditField.Value, ...
                        app.LowerLimitCheckBox.Value, app.InvertZaxisCheckBox.Value, app.WavelengthnmEditField.Value, app.RefracIndexDiffEditField.Value, app.PixelSizemEditField.Value);
                    
                    % hightlight spatial region
                    [dimmed_fftimg] = app.my_reconstructor.show_fft_crop(logimgmaxmin, region_box, app.UIAxes);
                    
                    % save intensity and thickness images
                    file = ['cropped_' int2str(index), '.tif'];
                    f = figure('visible','off');
                    imagesc(intensity_no_curve); title('Intensity'); colorbar;
                    saveas(gca, [save_folder '\intensity\' 'intensity_' file]); caxis([-10, 10]);
                    imagesc(thickness); title('Thickness'); colorbar; zlim([lower_limit, upper_limit]); caxis([lower_limit, upper_limit]);
                    saveas(gca, [save_folder '\thickness\' 'thickness_' file]);
                    imagesc(dimmed_fftimg); title('Spatial Frequency'); colorbar;
                    saveas(gca, [save_folder '\fft\' 'fft_' file]);
                    mesh(thickness); colorbar; zlim([lower_limit, upper_limit]); caxis([lower_limit, upper_limit]); set(gca,'Ydir','reverse');
                    text = ['Peak Height: ' num2str(frame_peak_height) newline 'Volume: ' num2str(frame_volume)];
                    annotation('textbox', dim, 'String', text, 'FitBoxToText', 'on');
                    saveas(gca, [save_folder '\mesh\' 'mesh_' file]);
                    imwrite(frame_cropped, [save_folder '\Hologram\' file]);
                    
                    % save .csv for thickness
                    [peak_height, volume] = app.my_reconstructor.single_frame_data(file, 1, 1, save_folder, ...
                        count, frame_peak_height, peak_height, frame_volume, volume, thickness);
                    
                    app.TextArea.Value = ['(Manual) Currently processing image: ' file newline num2str(ceil(total_frames/app.FrameSkipEditField.Value) - count) ' images to go...'];
                    
                    count = count + 1;
                end
                
                app.my_reconstructor.all_frame_data(1, 1, peak_height, volume, save_folder);
                
                t = toc;
                
                app.TextArea.Value = ['Done! Total time: ' num2str(t) 's'];
                
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create DHMGUIV32UIFigure and hide until all components are created
            app.DHMGUIV32UIFigure = uifigure('Visible', 'off');
            app.DHMGUIV32UIFigure.AutoResizeChildren = 'off';
            app.DHMGUIV32UIFigure.Color = [0.9412 0.9412 0.9412];
            app.DHMGUIV32UIFigure.Position = [100 100 1043 400];
            app.DHMGUIV32UIFigure.Name = 'DHM GUI V3.2';
            app.DHMGUIV32UIFigure.Resize = 'off';
            app.DHMGUIV32UIFigure.CloseRequestFcn = createCallbackFcn(app, @DHMGUIV32UIFigureCloseRequest, true);

            % Create FileSaveNameEditFieldLabel
            app.FileSaveNameEditFieldLabel = uilabel(app.DHMGUIV32UIFigure);
            app.FileSaveNameEditFieldLabel.Position = [16 253 104 23];
            app.FileSaveNameEditFieldLabel.Text = 'File Save Name';

            % Create FileSaveNameEditField
            app.FileSaveNameEditField = uieditfield(app.DHMGUIV32UIFigure, 'text');
            app.FileSaveNameEditField.HorizontalAlignment = 'right';
            app.FileSaveNameEditField.Position = [119 253 87 22];
            app.FileSaveNameEditField.Value = 'video.avi';

            % Create ImagingLabel
            app.ImagingLabel = uilabel(app.DHMGUIV32UIFigure);
            app.ImagingLabel.BackgroundColor = [0.8 0.8 0.8];
            app.ImagingLabel.HorizontalAlignment = 'center';
            app.ImagingLabel.FontSize = 14;
            app.ImagingLabel.FontWeight = 'bold';
            app.ImagingLabel.Position = [1 371 440 30];
            app.ImagingLabel.Text = 'Imaging';

            % Create ProcessingLabel
            app.ProcessingLabel = uilabel(app.DHMGUIV32UIFigure);
            app.ProcessingLabel.BackgroundColor = [0.8 0.8 0.8];
            app.ProcessingLabel.HorizontalAlignment = 'center';
            app.ProcessingLabel.FontSize = 14;
            app.ProcessingLabel.FontWeight = 'bold';
            app.ProcessingLabel.Position = [440 371 604 30];
            app.ProcessingLabel.Text = 'Processing';

            % Create StartPreviewButton
            app.StartPreviewButton = uibutton(app.DHMGUIV32UIFigure, 'push');
            app.StartPreviewButton.ButtonPushedFcn = createCallbackFcn(app, @StartPreviewButtonPushed, true);
            app.StartPreviewButton.BackgroundColor = [1 0.749 0.749];
            app.StartPreviewButton.Position = [16 213 190 22];
            app.StartPreviewButton.Text = 'Start Preview';

            % Create StartRecordButton
            app.StartRecordButton = uibutton(app.DHMGUIV32UIFigure, 'push');
            app.StartRecordButton.ButtonPushedFcn = createCallbackFcn(app, @StartRecordButtonPushed, true);
            app.StartRecordButton.BackgroundColor = [0.749 0.749 1];
            app.StartRecordButton.Position = [236 213 190 22];
            app.StartRecordButton.Text = 'Start Record';

            % Create StopRecordButton
            app.StopRecordButton = uibutton(app.DHMGUIV32UIFigure, 'push');
            app.StopRecordButton.ButtonPushedFcn = createCallbackFcn(app, @StopRecordButtonPushed, true);
            app.StopRecordButton.BackgroundColor = [0.749 0.749 1];
            app.StopRecordButton.Position = [236 173 190 22];
            app.StopRecordButton.Text = 'Stop Record';

            % Create StopPreviewButton
            app.StopPreviewButton = uibutton(app.DHMGUIV32UIFigure, 'push');
            app.StopPreviewButton.ButtonPushedFcn = createCallbackFcn(app, @StopPreviewButtonPushed, true);
            app.StopPreviewButton.BackgroundColor = [1 0.749 0.749];
            app.StopPreviewButton.Position = [16 173 190 22];
            app.StopPreviewButton.Text = 'Stop Preview';

            % Create WavelengthnmEditFieldLabel
            app.WavelengthnmEditFieldLabel = uilabel(app.DHMGUIV32UIFigure);
            app.WavelengthnmEditFieldLabel.Position = [650 13 105 22];
            app.WavelengthnmEditFieldLabel.Text = 'Wavelength (nm)';

            % Create WavelengthnmEditField
            app.WavelengthnmEditField = uieditfield(app.DHMGUIV32UIFigure, 'numeric');
            app.WavelengthnmEditField.Limits = [1 Inf];
            app.WavelengthnmEditField.Position = [754 13 80 22];
            app.WavelengthnmEditField.Value = 514;

            % Create RefracIndexDiffEditFieldLabel
            app.RefracIndexDiffEditFieldLabel = uilabel(app.DHMGUIV32UIFigure);
            app.RefracIndexDiffEditFieldLabel.Position = [850 13 105 22];
            app.RefracIndexDiffEditFieldLabel.Text = 'Refrac. Index Diff.';

            % Create RefracIndexDiffEditField
            app.RefracIndexDiffEditField = uieditfield(app.DHMGUIV32UIFigure, 'numeric');
            app.RefracIndexDiffEditField.Limits = [0 1];
            app.RefracIndexDiffEditField.Position = [954 13 80 22];
            app.RefracIndexDiffEditField.Value = 0.06;

            % Create PixelSizemEditFieldLabel
            app.PixelSizemEditFieldLabel = uilabel(app.DHMGUIV32UIFigure);
            app.PixelSizemEditFieldLabel.Position = [450 13 105 22];
            app.PixelSizemEditFieldLabel.Text = 'Pixel Size (ÿm)';

            % Create PixelSizemEditField
            app.PixelSizemEditField = uieditfield(app.DHMGUIV32UIFigure, 'numeric');
            app.PixelSizemEditField.Limits = [0 Inf];
            app.PixelSizemEditField.Position = [554 13 80 22];
            app.PixelSizemEditField.Value = 0.5;

            % Create ApplyChangesButton
            app.ApplyChangesButton = uibutton(app.DHMGUIV32UIFigure, 'push');
            app.ApplyChangesButton.ButtonPushedFcn = createCallbackFcn(app, @ApplyChangesButtonPushed, true);
            app.ApplyChangesButton.BackgroundColor = [0.749 1 0.749];
            app.ApplyChangesButton.Position = [236 253 190 22];
            app.ApplyChangesButton.Text = 'Apply Changes';

            % Create ExposuresEditField_2Label
            app.ExposuresEditField_2Label = uilabel(app.DHMGUIV32UIFigure);
            app.ExposuresEditField_2Label.Position = [16 293 104 23];
            app.ExposuresEditField_2Label.Text = 'Exposure (ÿs)';

            % Create ExposuresEditField
            app.ExposuresEditField = uieditfield(app.DHMGUIV32UIFigure, 'numeric');
            app.ExposuresEditField.Limits = [12 15003];
            app.ExposuresEditField.ValueDisplayFormat = '%.0f';
            app.ExposuresEditField.ValueChangedFcn = createCallbackFcn(app, @ExposuresEditFieldValueChanged, true);
            app.ExposuresEditField.Position = [119 293 87 22];
            app.ExposuresEditField.Value = 500;

            % Create CameraModeDropDownLabel
            app.CameraModeDropDownLabel = uilabel(app.DHMGUIV32UIFigure);
            app.CameraModeDropDownLabel.Position = [16 333 85 23];
            app.CameraModeDropDownLabel.Text = 'Camera Mode';

            % Create CameraModeDropDown
            app.CameraModeDropDown = uidropdown(app.DHMGUIV32UIFigure);
            app.CameraModeDropDown.Items = {'Mono16', 'Mono8', 'Mono10Packed', 'Mono12Packed'};
            app.CameraModeDropDown.Position = [119 333 87 22];
            app.CameraModeDropDown.Value = 'Mono16';

            % Create FramerateLiveEditFieldLabel
            app.FramerateLiveEditFieldLabel = uilabel(app.DHMGUIV32UIFigure);
            app.FramerateLiveEditFieldLabel.Position = [236 333 104 23];
            app.FramerateLiveEditFieldLabel.Text = 'Framerate (Live)';

            % Create FramerateLiveEditField
            app.FramerateLiveEditField = uieditfield(app.DHMGUIV32UIFigure, 'numeric');
            app.FramerateLiveEditField.ValueDisplayFormat = '%.4f';
            app.FramerateLiveEditField.Editable = 'off';
            app.FramerateLiveEditField.Position = [339 333 87 22];

            % Create FramerateSaveEditFieldLabel
            app.FramerateSaveEditFieldLabel = uilabel(app.DHMGUIV32UIFigure);
            app.FramerateSaveEditFieldLabel.Position = [236 293 104 23];
            app.FramerateSaveEditFieldLabel.Text = 'Framerate (Save)';

            % Create FramerateSaveEditField
            app.FramerateSaveEditField = uieditfield(app.DHMGUIV32UIFigure, 'numeric');
            app.FramerateSaveEditField.ValueDisplayFormat = '%.4f';
            app.FramerateSaveEditField.Editable = 'off';
            app.FramerateSaveEditField.Position = [339 293 87 23];

            % Create ROISelectButton
            app.ROISelectButton = uibutton(app.DHMGUIV32UIFigure, 'push');
            app.ROISelectButton.ButtonPushedFcn = createCallbackFcn(app, @ROISelectButtonPushed, true);
            app.ROISelectButton.BackgroundColor = [1 0.902 0.4];
            app.ROISelectButton.Position = [16 93 84 62];
            app.ROISelectButton.Text = 'ROI Select';

            % Create ROIResetButton
            app.ROIResetButton = uibutton(app.DHMGUIV32UIFigure, 'push');
            app.ROIResetButton.ButtonPushedFcn = createCallbackFcn(app, @ROIResetButtonPushed, true);
            app.ROIResetButton.BackgroundColor = [1 0.902 0.4];
            app.ROIResetButton.Position = [122 93 84 62];
            app.ROIResetButton.Text = 'ROI Reset';

            % Create ShowFFTButton
            app.ShowFFTButton = uibutton(app.DHMGUIV32UIFigure, 'push');
            app.ShowFFTButton.ButtonPushedFcn = createCallbackFcn(app, @ShowFFTButtonPushed, true);
            app.ShowFFTButton.BackgroundColor = [1 0.8118 0.651];
            app.ShowFFTButton.Position = [234 133 84 22];
            app.ShowFFTButton.Text = 'Show FFT';

            % Create CloseFFTButton
            app.CloseFFTButton = uibutton(app.DHMGUIV32UIFigure, 'push');
            app.CloseFFTButton.ButtonPushedFcn = createCallbackFcn(app, @CloseFFTButtonPushed, true);
            app.CloseFFTButton.BackgroundColor = [1 0.8078 0.651];
            app.CloseFFTButton.Position = [234 93 84 22];
            app.CloseFFTButton.Text = 'Close FFT';

            % Create LiveReconButton
            app.LiveReconButton = uibutton(app.DHMGUIV32UIFigure, 'push');
            app.LiveReconButton.ButtonPushedFcn = createCallbackFcn(app, @LiveReconButtonPushed, true);
            app.LiveReconButton.BackgroundColor = [0.0588 1 1];
            app.LiveReconButton.Position = [342 133 84 22];
            app.LiveReconButton.Text = 'Live Recon';

            % Create CloseReconButton
            app.CloseReconButton = uibutton(app.DHMGUIV32UIFigure, 'push');
            app.CloseReconButton.ButtonPushedFcn = createCallbackFcn(app, @CloseReconButtonPushed, true);
            app.CloseReconButton.BackgroundColor = [0.0588 1 1];
            app.CloseReconButton.Position = [342 93 84 22];
            app.CloseReconButton.Text = 'Close Recon';

            % Create UpperLimitEditField_3Label
            app.UpperLimitEditField_3Label = uilabel(app.DHMGUIV32UIFigure);
            app.UpperLimitEditField_3Label.Position = [450 173 76 22];
            app.UpperLimitEditField_3Label.Text = 'Upper Limit';

            % Create UpperLimitEditField
            app.UpperLimitEditField = uieditfield(app.DHMGUIV32UIFigure, 'numeric');
            app.UpperLimitEditField.Limits = [0 Inf];
            app.UpperLimitEditField.Position = [525 173 52 22];
            app.UpperLimitEditField.Value = 20;

            % Create InvertZaxisCheckBox
            app.InvertZaxisCheckBox = uicheckbox(app.DHMGUIV32UIFigure);
            app.InvertZaxisCheckBox.Text = 'Invert Z-axis';
            app.InvertZaxisCheckBox.FontWeight = 'bold';
            app.InvertZaxisCheckBox.Position = [607 133 127 22];

            % Create LowerLimitCheckBox
            app.LowerLimitCheckBox = uicheckbox(app.DHMGUIV32UIFigure);
            app.LowerLimitCheckBox.Text = 'Lower Limit';
            app.LowerLimitCheckBox.FontWeight = 'bold';
            app.LowerLimitCheckBox.Position = [607 173 127 22];
            app.LowerLimitCheckBox.Value = true;

            % Create PreviewButton
            app.PreviewButton = uibutton(app.DHMGUIV32UIFigure, 'push');
            app.PreviewButton.ButtonPushedFcn = createCallbackFcn(app, @PreviewButtonPushed, true);
            app.PreviewButton.BackgroundColor = [1 0.902 0.4];
            app.PreviewButton.Position = [550 293 84 62];
            app.PreviewButton.Text = 'Preview';

            % Create SelectFileButton
            app.SelectFileButton = uibutton(app.DHMGUIV32UIFigure, 'push');
            app.SelectFileButton.ButtonPushedFcn = createCallbackFcn(app, @SelectFileButtonPushed, true);
            app.SelectFileButton.BackgroundColor = [1 0.749 0.749];
            app.SelectFileButton.Position = [450 333 84 22];
            app.SelectFileButton.Text = 'Select File';

            % Create TextArea
            app.TextArea = uitextarea(app.DHMGUIV32UIFigure);
            app.TextArea.Editable = 'off';
            app.TextArea.Position = [750 293 284 61];

            % Create SetROIButton
            app.SetROIButton = uibutton(app.DHMGUIV32UIFigure, 'push');
            app.SetROIButton.ButtonPushedFcn = createCallbackFcn(app, @SetROIButtonPushed, true);
            app.SetROIButton.BackgroundColor = [1 0.902 0.4];
            app.SetROIButton.Position = [650 293 84 62];
            app.SetROIButton.Text = 'Set ROI';

            % Create UIAxes
            app.UIAxes = uiaxes(app.DHMGUIV32UIFigure);
            title(app.UIAxes, '')
            xlabel(app.UIAxes, '')
            ylabel(app.UIAxes, '')
            app.UIAxes.GridColor = 'none';
            app.UIAxes.MinorGridColor = 'none';
            app.UIAxes.XColor = 'none';
            app.UIAxes.XTick = [];
            app.UIAxes.YColor = 'none';
            app.UIAxes.YTick = [];
            app.UIAxes.ZColor = 'none';
            app.UIAxes.ZTick = [];
            app.UIAxes.LabelFontSizeMultiplier = 1;
            app.UIAxes.TitleFontSizeMultiplier = 1;
            app.UIAxes.Position = [750 93 284 182];

            % Create ConverttoimagesButton
            app.ConverttoimagesButton = uibutton(app.DHMGUIV32UIFigure, 'push');
            app.ConverttoimagesButton.ButtonPushedFcn = createCallbackFcn(app, @ConverttoimagesButtonPushed, true);
            app.ConverttoimagesButton.BackgroundColor = [1 0.8118 0.651];
            app.ConverttoimagesButton.Position = [607 253 127 22];
            app.ConverttoimagesButton.Text = 'Convert to images';

            % Create FrameSkipEditFieldLabel
            app.FrameSkipEditFieldLabel = uilabel(app.DHMGUIV32UIFigure);
            app.FrameSkipEditFieldLabel.Position = [607 213 76 22];
            app.FrameSkipEditFieldLabel.Text = 'Frame Skip';

            % Create FrameSkipEditField
            app.FrameSkipEditField = uieditfield(app.DHMGUIV32UIFigure, 'numeric');
            app.FrameSkipEditField.Limits = [1 Inf];
            app.FrameSkipEditField.Position = [682 213 52 22];
            app.FrameSkipEditField.Value = 1;

            % Create StartsecEditFieldLabel
            app.StartsecEditFieldLabel = uilabel(app.DHMGUIV32UIFigure);
            app.StartsecEditFieldLabel.Position = [450 253 76 22];
            app.StartsecEditFieldLabel.Text = 'Start (sec)';

            % Create StartsecEditField
            app.StartsecEditField = uieditfield(app.DHMGUIV32UIFigure, 'numeric');
            app.StartsecEditField.Limits = [0 Inf];
            app.StartsecEditField.Position = [525 253 52 22];

            % Create EndsecEditFieldLabel
            app.EndsecEditFieldLabel = uilabel(app.DHMGUIV32UIFigure);
            app.EndsecEditFieldLabel.Position = [450 213 76 22];
            app.EndsecEditFieldLabel.Text = 'End (sec)';

            % Create EndsecEditField
            app.EndsecEditField = uieditfield(app.DHMGUIV32UIFigure, 'numeric');
            app.EndsecEditField.Limits = [0 Inf];
            app.EndsecEditField.Position = [525 213 52 22];

            % Create NoiseLevelEditField_3Label
            app.NoiseLevelEditField_3Label = uilabel(app.DHMGUIV32UIFigure);
            app.NoiseLevelEditField_3Label.Position = [450 133 76 22];
            app.NoiseLevelEditField_3Label.Text = 'Noise Level';

            % Create NoiseLevelEditField
            app.NoiseLevelEditField = uieditfield(app.DHMGUIV32UIFigure, 'numeric');
            app.NoiseLevelEditField.Limits = [0 100];
            app.NoiseLevelEditField.Position = [525 133 52 22];
            app.NoiseLevelEditField.Value = 30;

            % Create RunAutoButton
            app.RunAutoButton = uibutton(app.DHMGUIV32UIFigure, 'push');
            app.RunAutoButton.ButtonPushedFcn = createCallbackFcn(app, @RunAutoButtonPushed, true);
            app.RunAutoButton.BackgroundColor = [0.749 1 0.749];
            app.RunAutoButton.Position = [450 93 127 22];
            app.RunAutoButton.Text = 'Run Auto';

            % Create RunManualButton
            app.RunManualButton = uibutton(app.DHMGUIV32UIFigure, 'push');
            app.RunManualButton.ButtonPushedFcn = createCallbackFcn(app, @RunManualButtonPushed, true);
            app.RunManualButton.BackgroundColor = [0.749 1 0.749];
            app.RunManualButton.Position = [607 93 127 22];
            app.RunManualButton.Text = 'Run Manual';

            % Create ImageFolderEditFieldLabel
            app.ImageFolderEditFieldLabel = uilabel(app.DHMGUIV32UIFigure);
            app.ImageFolderEditFieldLabel.Position = [450 53 101 22];
            app.ImageFolderEditFieldLabel.Text = 'Image Folder';

            % Create ImageFolderEditField
            app.ImageFolderEditField = uieditfield(app.DHMGUIV32UIFigure, 'text');
            app.ImageFolderEditField.HorizontalAlignment = 'right';
            app.ImageFolderEditField.Position = [550 53 184 22];
            app.ImageFolderEditField.Value = 'image_folder';

            % Create OutputFolderEditFieldLabel
            app.OutputFolderEditFieldLabel = uilabel(app.DHMGUIV32UIFigure);
            app.OutputFolderEditFieldLabel.Position = [750 53 101 22];
            app.OutputFolderEditFieldLabel.Text = 'Output Folder';

            % Create OutputFolderEditField
            app.OutputFolderEditField = uieditfield(app.DHMGUIV32UIFigure, 'text');
            app.OutputFolderEditField.HorizontalAlignment = 'right';
            app.OutputFolderEditField.Position = [850 53 184 22];
            app.OutputFolderEditField.Value = 'output_folder';

            % Create SelectFolderButton
            app.SelectFolderButton = uibutton(app.DHMGUIV32UIFigure, 'push');
            app.SelectFolderButton.ButtonPushedFcn = createCallbackFcn(app, @SelectFolderButtonPushed, true);
            app.SelectFolderButton.BackgroundColor = [1 0.749 0.749];
            app.SelectFolderButton.Position = [450 293 84 22];
            app.SelectFolderButton.Text = 'Select Folder';

            % Create Label
            app.Label = uilabel(app.DHMGUIV32UIFigure);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Enable = 'off';
            app.Label.Position = [16 13 25 22];
            app.Label.Text = '';

            % Create version
            app.version = uitextarea(app.DHMGUIV32UIFigure);
            app.version.Editable = 'off';
            app.version.HorizontalAlignment = 'center';
            app.version.Enable = 'off';
            app.version.Position = [16 13 190 22];
            app.version.Value = {'DHM GUI with Blackfly S V3.2'};

            % Create OutputRawResultImagesCheckBox
            app.OutputRawResultImagesCheckBox = uicheckbox(app.DHMGUIV32UIFigure);
            app.OutputRawResultImagesCheckBox.Text = 'Output Raw Result Images';
            app.OutputRawResultImagesCheckBox.FontWeight = 'bold';
            app.OutputRawResultImagesCheckBox.Position = [236 13 190 22];
            app.OutputRawResultImagesCheckBox.Value = true;

            % Show the figure after all components are created
            app.DHMGUIV32UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = test_ui_combined_input_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.DHMGUIV32UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.DHMGUIV32UIFigure)
        end
    end
end