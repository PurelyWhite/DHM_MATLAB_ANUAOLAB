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
            if obj.first
                obj.first = false;
                imwrite(im2uint8(getsnapshot(camera)),obj.filepath);
            else
                imwrite(im2uint8(getsnapshot(camera)),obj.filepath,'WriteMode','append');
            end
            flushdata(camera);
            %writeVideo(obj.diskLogger, im2uint8(getsnapshot(camera)));
        end
        
        function start(obj, camera, filepath, frame_grab_interval)
            %obj.diskLogger = VideoWriter(filepath, 'MPEG-4');
            %if strcmp(camera.model, 'blackfly_s')
            %    obj.diskLogger.FrameRate = camera.src.AcquisitionFrameRate/frame_grab_interval;
            %end
            %camera.vid.DiskLogger = obj.diskLogger;
            
            obj.filepath = filepath;
            camera.vid.FramesAcquiredFcnCount = frame_grab_interval;
            camera.vid.FramesAcquiredFcn = @obj.save_frame;
            
            start(camera.vid);
            %open(obj.diskLogger);
        end
        function stop(obj, camera)
            stop(camera.vid);
            %close(obj.diskLogger);
        end
        function [frame] = snap(~, camera)
            frame = getsnapshot(camera.vid);
        end
    end
end


