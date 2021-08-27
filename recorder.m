classdef recorder < handle
    properties
        diskLogger % disk object
    end
    methods
        function obj = recorder()
        end
        
        function save_frame(obj, camera, ~)
            frame = im2uint8(peekdata(camera,1));
            size(frame);
            writeVideo(obj.diskLogger, frame);
        end
        
        function start(obj, camera, filepath, frame_grab_interval)
            obj.diskLogger = VideoWriter(filepath, 'Grayscale AVI');
            if strcmp(camera.model, 'blackfly_s')
                obj.diskLogger.FrameRate = camera.src.AcquisitionFrameRate;
            end
            %camera.vid.DiskLogger = obj.diskLogger;
            
            
            camera.vid.FramesAcquiredFcnCount = frame_grab_interval;
            camera.vid.FramesAcquiredFcn = @obj.save_frame;
            
            start(camera.vid);
            open(obj.diskLogger);
        end
        function stop(obj, camera)
            stop(camera.vid);
            close(obj.diskLogger);
        end
        function [frame] = snap(~, camera)
            frame = getsnapshot(camera.vid);
        end
    end
end


