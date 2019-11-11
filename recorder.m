classdef recorder < handle
    properties
        diskLogger % disk object
    end
    methods
        function obj = recorder()
        end
        function start(obj, camera, path, filename)
            time = datetime('now');
            obj.diskLogger = VideoWriter(strcat(path, string(time.Hour), '_', string(time.Minute), '_', string(round(time.Second)), '_', filename), 'Grayscale AVI');
            camera.vid.DiskLogger = obj.diskLogger;
            start(camera.vid);
        end
        function stop(~, camera)
            stop(camera.vid);
        end
    end
end
