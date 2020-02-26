classdef recorder < handle
    properties
        diskLogger % disk object
    end
    methods
        function obj = recorder()
        end
        function start(obj, camera, filepath)
            obj.diskLogger = VideoWriter(filepath, 'Grayscale AVI');
            obj.diskLogger.FrameRate = camera.src.AcquisitionFrameRate;
            camera.vid.DiskLogger = obj.diskLogger;
            start(camera.vid);
        end
        function stop(~, camera)
            stop(camera.vid);
        end
        function [frame] = snap(~, camera)
            frame = getsnapshot(camera.vid);
        end
    end
end
