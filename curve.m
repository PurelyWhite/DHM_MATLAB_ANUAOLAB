function [rrrt] = curve(matrix)
[yy,xx]=size(matrix);
xxx=linspace(1,xx,xx);
yyy=linspace(1,yy,yy);
x=repmat(xxx,yy,1);
y=repmat(yyy',1,xx);
%%
[xData, yData, zData] = prepareSurfaceData(xxx, yyy, matrix);
% Set up fittype and options.
ft = fittype( 'a + b*x+c*y+d*x*y+e*x^2+f*y^2', 'independent', {'x', 'y'}, 'dependent', 'z' );
opts = fitoptions( ft );
opts.Algorithm = 'Levenberg-Marquardt';
opts.StartPoint = [0,0,0,0,0,0];

% Fit model to data.
fitresult= fit( [xData, yData], zData, ft,  opts);
a=coeffvalues(fitresult);
rrrt=a(1)+ a(2).*x+a(3).*y+a(4).*x.*y+a(5).*x.^2+a(6).*y.^2;
end