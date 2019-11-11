classdef recorder < handle
    properties
        diskLogger % disk object
    end
    methods
        function obj = recorder()
        end
        function start(obj, camera, path, filename)
            if exist(camera.vid, 'var')
                time = datetime('now');
                obj.diskLogger = VideoWriter(strcat(path, '_', string(time.Hour), '_', string(time.Minute), '_', filename), 'Grayscale AVI');
                obj.diskLogger.FrameRate = camera.src.AcquisitionResultingFrameRate;
                camera.vid.DiskLogger = obj.diskLogger;
                start(app.vid);
            end
        end
        function stop(~, camera)
            if exist(camera.vid, 'var')
                stop(camera.vid);
            end
        end
    end
end
