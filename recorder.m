classdef recorder < handle
    properties
        diskLogger % disk object
    end
    methods
        function obj = recorder()
        end
        
        function save_frame(obj, camera, ~)
            obj.diskLogger(im2uint8(peekdata(camera,1)));
        end
        
        function start(obj, camera, filepath, frame_grab_interval)
            obj.diskLogger = VideoWriter(filepath, 'Grayscale AVI');
            obj.diskLogger = vision.VideoFileWriter(filepath, 'FrameRate',camera.src.AcquisitionFrameRate/frame_grab_interval);
            
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


