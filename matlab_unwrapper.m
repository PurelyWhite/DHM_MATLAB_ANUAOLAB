function unwrapped_phase = matlab_unwrapper(wrapped_phase)
    [m,n] = size(wrapped_phase);
    
    unwrapped_phase = zeros([m,n]);
    
    img_size = m*n;
    num_edges = m*(n-1) + n*(m-1);
    
    
    %initialise pixels
    pixel_increment = zeros([m,n]);
    num_pix_per_group = ones([m,n]);
    pixel_value = wrapped_phase;
    pixel_reliability = (ones([m,n]) * 99999999) + rand(m,n);
    pixel_head = reshape(1:m*n,m,n);
    pixel_last = reshape(1:m*n,m,n);
    pixel_next = zeros([m,n])-1;
    pixel_new_group = zeros([m,n]);
    pixel_group = zeros([m,n])-1;
    
    % calculate reliability
    
    
    % horizontal edge: 1x2 kernel convolution
    
    % vertical edge: 2x1 kernel convolution
    
    % gather pixels: challenging
    
    % unwrap image: simple
    
    % return image: simple
    
end