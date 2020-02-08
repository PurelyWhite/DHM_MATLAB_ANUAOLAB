classdef unwrapper
    %UNWRAPPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = unwrapper()
            
        end
        
        function unwrapped_img = gpu_miguel_unwrap(~, wrapped_img)
            unwrapped_img = double(GPU_Miguel_2D_unwrapper(single(wrapped_img)));
        end
        
        function unwrapped_img = cpu_miguel_unwrap(~, wrapped_img)
            unwrapped_img = double(Miguel_2D_unwrapper(single(wrapped_img)));
        end
        
        function unwrapped_img = unwrap(~,wrapped_img,use_gpu)
            if use_gpu
                unwrapped_img = gpu_miguel_unwrap(wrapped_img);
            else
                unwrapped_img = cpu_miguel_unwrap(wrapped_img);
            end  
        end
    end
end

