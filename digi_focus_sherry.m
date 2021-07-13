clear
% inten = imread('F:\dhm\2021-02-24\45\intensity\cropped_8801.tif');
% phase = imread('F:\dhm\2021-02-24\45\thickness\cropped_8801.tif');

% inten = imread('C:\Users\anuaolab\Desktop\PRP Control 1500 harry.avi_output_folder\intensity\cropped_15130.tif');
% phase = imread('C:\Users\anuaolab\Desktop\PRP Control 1500 harry.avi_output_folder\thickness\cropped_15130.tif');

inten = imread('I:\DHM_MATLAB_ANUAOLAB\examples\test3.tiff_output_folder\intensity.tif');
phase = imread('I:\DHM_MATLAB_ANUAOLAB\examples\test3.tiff_output_folder\thickness.tif');

inten = double(inten);
phase = double(phase);
%
% inten = double(inten(80:430,400:750));
% phase = double(phase(80:430,400:750));

laserWavelength = 512*(10^-9);

[imx,imy]=size(phase);
pixr=0.176e-6; % Already measured for processing.
kx0=linspace(-pi/pixr,pi/pixr,imy); 
ky0=linspace(-pi/pixr,pi/pixr,imx);
kx=repmat(kx0,imx,1);
ky=repmat(ky0.',1,imy);
k0=2*pi/laserWavelength;
kk=k0^2-kx.^2-ky.^2;
kk(kk<0) = 0;
start=-60e-6; % Need this
dist=1e-6; % Need this
time=140; % Need this?
im=1; %Need this?

writerObj = VideoWriter('I:\DHM_MATLAB_ANUAOLAB\examples\test3.tiff_output_folder\inten2.avi');
writerObj.FrameRate = 30; % How many frames per second.
open(writerObj);
figure1 = figure;
axes1 =axes('Parent',figure1,'YDir','reverse','Layer','top','DataAspectRatio',[1 1 1], 'CLim',[-4 10]);

for ii=1:time
    distance=dist*(ii-1);
    [ phase_out,intensity_out,shiftf,reald,slope,sharpness] = digitalfocus_unwrap(phase,inten,kk,start,distance);
    I= (intensity_out - min(min(intensity_out)))/(max(max(intensity_out))-min(min(intensity_out)));
    if im==1
        hold on
        imagesc(intensity_out);
        caxis([0 20500000])
        %         imagesc(shiftf)
        %         caxis([-100,100])
        %         imagesc(phase_out)
        %         caxis([-2 2])
        axis tight;
        
        colormap(jet)
        colorbar
        title(['propagation distance =',num2str(reald),'m'])
        pause(0.05)
        hold off
        frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
        writeVideo(writerObj, frame);
    end
    summ(ii)=sum(sum(I));
    sharp(ii)=sharpness;
    disp(ii)
end
close(writerObj);

phase1= imfilter(phase_out, fspecial('gaussian',[2 2],3));


xx=(start:dist:reald)/1e-6;
figure
[AX,H1,H2] = plotyy(xx,summ,xx,sharp);
legend('sum of intensity','sharpness of intensity')
title('intensity analysis')
%%
[M,I] = min(sharp(:));
reald=start+dist*(I-1);
[ phase,intensity,shiftf,reald,slope, sharpness] = digitalfocus_m(phase,inten,kk,0,reald);
% save( [path,filename,'DF_int.mat'], 'intensity');
% save( [path,filename,'DF_phase.mat'], 'phase');
%%
figure
image(intensity,'CDataMapping','scaled')
% caxis([-0.5,3]) % change caxis
colormap(gray(255));
title(['intensity image: propagation distance =',num2str(reald),'m']);
% saveas(gcf,[path,filename,'intensity.png']);
%%
abs_o=imfilter(phase , fspecial('gaussian',[1*2+1 1*2+1],1));
figure;imagesc(abs_o);
% view([-28.5 54]);
colorbar
title(['phase map: propagation distance =',num2str(reald),'m']);
% saveas(gcf,[path,filename,'phasemap.png']);
