 
 function [ phase_out,intensity_out,shiftf,reald,slope, sharpness] = digitalfocus_unwrap(phase,intensity,kk,start,dist)
%%
object_o=intensity.*exp(1j*phase);
obj_f_o = fftshift(fft2(object_o)); 
reald=start+dist;
shiftf=-sqrt(kk)*(reald);

ccdImfft0=abs(obj_f_o).*exp(1i*((angle(obj_f_o))+shiftf));
centeredImage_s = ifft2(fftshift(ccdImfft0));
%% unwrap the phase image 
intensity_out=(abs(centeredImage_s)).^2;

f=angle(centeredImage_s);
xx = size(phase,1);
yy = size(phase,2);
unwrapper = LeastSquares_Unwrapper(xx,yy);
phase_unwrap = unwrapper.unwrap(f);
phaseIms = gather(phase_unwrap);
% phaseIms = double(Miguel_2D_unwrapper(single(f)));
[slope,yy,xx] = cruveremoval( phaseIms);
phase_out= phaseIms-slope;
            abs_o=imfilter(intensity_out , fspecial('gaussian',[1*3+1 1*3+1],1));
            sharpness=std2(abs_o);
end

