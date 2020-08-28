video_path = 'examples/NE00_18-11182019183813-0000.avi';

video = VideoReader(video_path);
first_frame = rgb2gray(read(video, 1));
[X,Y] = size(first_frame);
h.fig  = figure ;
h.ax   = handle(axes) ;                 %// create an empty axes that fills the figure
h.mesh = handle( mesh( NaN(2) ) ) ;     %// create an empty "surface" object
%Display the initial surface
set( h.mesh,'ZData', first_frame)
d = video.Duration;
tic
for i=1:(video.Duration*video.FrameRate)
    frame = rgb2gray(read(video,i));
    h.mesh.ZData = frame;
    %pause(1/video.FrameRate);
end
toc
