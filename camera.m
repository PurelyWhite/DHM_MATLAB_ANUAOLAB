classdef camera < handle
    properties (Access = public)
        model
        vid         % video object
        src         % record object
        blackfly_s_cam = 'mwspinnakerimaq_r2019b';  % to-do: create settings
        pixelfly_cam = 'pcocameraadaptor_r2019b';
        
    end
    methods
        function obj = camera(cam_model, exposure)
            hw_status = imaqhwinfo;
            if strcmp(cam_model, 'blackfly_s')
                if ismember(obj.blackfly_s_cam, hw_status.InstalledAdaptors)
                    device_id = cell2mat(imaqhwinfo(obj.blackfly_s_cam).DeviceIDs);
                    obj.model = 'blackfly_s';
                    obj.vid = videoinput(obj.blackfly_s_cam, device_id, 'Mono16');
                    obj.vid.FramesPerTrigger = Inf;
                    obj.vid.ReturnedColorspace = 'grayscale';
                    obj.vid.LoggingMode = 'disk';
                    obj.vid.ROIPosition = [384 368 1280 800];
                    triggerconfig(obj.vid, 'immediate');
                    
                    obj.src = getselectedsource(obj.vid);
                    obj.src.AdcBitDepth = 'Bit12';
                    obj.src.AcquisitionFrameRateEnable = 'True';
                    % if strcmp(obj.mode, 'Mono16')
                    obj.src.AcquisitionFrameRate = 45;  % currently preset to Mono16
                    % else
                    %     obj.src.AcquisitionFrameRate = 60;
                    % end
                    obj.src.ExposureAuto = 'Off';
                    obj.src.ExposureTime = exposure;    % 12 - 15003
                    obj.src.AutoAlgorithmSelector = 'Awb';
                    obj.src.GainAuto = 'Off';
                    obj.src.Gain = 0;
                    obj.src.GammaEnable = 'False';
                    obj.src.DefectCorrectStaticEnable = 'False';
                    obj.src.IspEnable = 'False';
                    obj.src.BlackLevelClampingEnable = 'False';
                    obj.src.BlackLevelSelector = 'All';
                    obj.src.BlackLevel = 0;
                    obj.src.CounterEventSource = 'Off';
                    obj.src.CounterTriggerSource = 'Off';
                    obj.src.DeviceIndicatorMode = 'ErrorStatus';
                    obj.src.DeviceLinkThroughputLimit = 500000000;
                    obj.src.ReverseX = 'False';
                    obj.src.ReverseY = 'False';
                    
                    diskLogger = VideoWriter('default.avi', 'Grayscale AVI');
                    diskLogger.FrameRate = obj.src.AcquisitionResultingFrameRate;
                    obj.vid.DiskLogger = diskLogger;
                end
            elseif strcmp(cam_model, 'pixelfly')
                if ismember(obj.pixelfly_cam, hw_status.InstalledAdaptors)
                    device_id = cell2mat(imaqhwinfo(obj.pixelfly_cam).DeviceIDs);
                    obj.model = 'pixelfly';
                    obj.vid = videoinput(obj.pixelfly_cam, device_id);
                    obj.vid.FramesPerTrigger = Inf;
                    obj.vid.ReturnedColorspace = 'grayscale';
                    obj.vid.LoggingMode = 'disk';
                    triggerconfig(obj.vid, 'immediate');
                    
                    obj.src = getselectedsource(obj.vid);
                    obj.src.B1BinningHorizontal = '01';
                    obj.src.B2BinningVertical = '01';
                    obj.src.CFConversionFactor_e_count = '1.00';
                    obj.src.D1DelayTime_unit = 'us';
                    obj.src.E1ExposureTime_unit = 'us';
                    obj.src.E2ExposureTime = exposure;
                    obj.src.IRMode = 'off';
                    obj.src.PCPixelclock_Hz = '24000000';
                    obj.src.TMTimestampMode = 'No Stamp';
                    
                    diskLogger = VideoWriter('default.avi', 'Grayscale AVI');
                    obj.vid.DiskLogger = diskLogger;
                end
            end
        end
    end
end
