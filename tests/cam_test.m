imaqreset;
blackfly_s_cam = 'mwspinnakerimaq_r2019b';
mode = 'Mono10Packed'; % Mono8; Mono10Packed; Mono12Packed

% Mono16
% Auto Framerate: 45
% Exposure: 12 - 15003 us

% Mono8
% Auto Framerate: 60
% Exposure: 12 - 15003 us

% Mono10Packed
% Auto Framerate: 60
% Exposure: 12 - 15003 us

% Mono12Packed
% Auto Framerate: 60
% Exposure: 12 - 15003 us

vid = videoinput(blackfly_s_cam, 1, mode);
vid.FramesPerTrigger = Inf;
vid.ReturnedColorspace = 'grayscale';
vid.LoggingMode = 'disk';
triggerconfig(vid, 'immediate');

diskLogger = VideoWriter('C:\Users\Tienan Xu\Desktop\test.avi', 'Grayscale AVI');
diskLogger.FrameRate = 60;
vid.DiskLogger = diskLogger;

src = getselectedsource(vid);
src.AdcBitDepth = 'Bit12';
src.AcquisitionFrameRateEnable = 'True';
if strcmp(mode, 'Mono16')
    src.AcquisitionFrameRate = 45;
else
    src.AcquisitionFrameRate = 60;
end
src.ExposureAuto = 'Off';
src.ExposureTime = 5000;    % 12 - 15003
src.AutoAlgorithmSelector = 'Awb';
src.GainAuto = 'Off';
src.Gain = 0;
src.GammaEnable = 'False';
src.DefectCorrectStaticEnable = 'False';
src.IspEnable = 'False';
src.BlackLevelClampingEnable = 'False';
src.BlackLevelSelector = 'All';
src.BlackLevel = 0;
src.CounterEventSource = 'Off';
src.CounterTriggerSource = 'Off';
src.DeviceIndicatorMode = 'ErrorStatus';
src.DeviceLinkThroughputLimit = 500000000;
src.ReverseX = 'False';
src.ReverseY = 'False';

preview(vid);