classdef Camera < handle
    properties (Access = public)
        mode
        vid         % video object
        src         % record object
        blackfly_s_cam = 'mwspinnakerimaq_r2019b';  % to-do: create settings
    end
    methods
        function obj = Camera(cam_mode, exposure)
            hw_status = imaqhwinfo;
            if ismember(obj.blackfly_s_cam, hw_status.InstalledAdaptors)
                obj.mode = cam_mode;
                obj.vid = videoinput(obj.blackfly_s_cam, 1, obj.mode);
                obj.vid.FramesPerTrigger = Inf;
                obj.vid.ReturnedColorspace = 'grayscale';
                obj.vid.LoggingMode = 'disk';
                obj.vid.ROIPosition = [512 384 1024 768];
                triggerconfig(obj.vid, 'immediate');
                
                obj.src = getselectedsource(obj.vid);
                obj.src.AdcBitDepth = 'Bit12';
                obj.src.AcquisitionFrameRateEnable = 'True';
                if strcmp(obj.mode, 'Mono16')
                    obj.src.AcquisitionFrameRate = 45;
                else
                    obj.src.AcquisitionFrameRate = 60;
                end
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
        end
    end
end