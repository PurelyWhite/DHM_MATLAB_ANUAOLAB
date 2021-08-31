classdef recorder < handle
    properties
        diskLogger % disk object
        first = true
        filepath
    end
    methods
        function obj = recorder()
        end
        
        function save_frame(obj, camera, ~)
            writeVideo(obj.diskLogger, im2uint8(getsnapshot(camera)));
            flushdata(camera);
        end
        
        function start(obj, camera, filepath, frame_grab_interval)
            obj.diskLogger = VideoWriter(filepath, 'Grayscale AVI');
            if strcmp(camera.model, 'blackfly_s')
                obj.diskLogger.FrameRate = camera.src.AcquisitionFrameRate/frame_grab_interval;
            end
            camera.vid.DiskLogger = obj.diskLogger;
            
            obj.filepath = filepath;
            camera.vid.FramesAcquiredFcnCount = frame_grab_interval;
            camera.vid.FramesAcquiredFcn = @obj.save_frame;
            
            start(camera.vid);
        end
        function stop(obj, camera)
            stop(camera.vid);
            release(obj.diskLogger);
        end
        function [frame] = snap(~, camera)
            frame = getsnapshot(camera.vid);
        end
    end
end


