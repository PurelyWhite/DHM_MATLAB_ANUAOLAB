function [rrrt] = downsampled_curve(matrix)
    max_curve_img_size = 256;

    if 1
        [yy,xx]=size(matrix);
        mat_min = min(min(matrix));
        matrix = matrix-mat_min;
        
        %Curve fitting doesn't need full sized image.
        s = max(1,min(floor(xx/max_curve_img_size),floor(yy/max_curve_img_size)));
        %ds_matrix = imresize(matrix,1/s);
        ds_matrix = matrix(1:s:end,1:s:end);
            
        %Calculate curve from downsampled input
        [yy,xx]=size(matrix);
        xxx=linspace(1,xx,xx);
        xxx=downsample(xxx,s);
        yyy=linspace(1,yy,yy);
        yyy=downsample(yyy,s);
        %x=repmat(xxx,yy,1);
        %y=repmat(yyy',1,xx);
        
        %%
        [xData, yData, zData] = prepareSurfaceData(xxx, yyy, ds_matrix);
        % Set up fittype and options.
        ft = fittype( 'a + b*x+c*y+d*x*y+e*x^2+f*y^2', 'independent', {'x', 'y'}, 'dependent', 'z' );
        opts = fitoptions( ft );
        opts.Algorithm = 'Levenberg-Marquardt';
        opts.StartPoint = [0,0,0,0,0,0];

        % Fit model to data.
        fitresult= fit( [xData, yData], zData, ft,  opts);
        a=coeffvalues(fitresult);
        
        %project parameters to original matrix
        [yy,xx]=size(matrix);
        xxx=linspace(1,xx,xx);
        yyy=linspace(1,yy,yy);
        x=repmat(xxx,yy,1);
        y=repmat(yyy',1,xx);
        rrrt=a(1)+ a(2).*x+a(3).*y+a(4).*x.*y+a(5).*x.^2+a(6).*y.^2+mat_min;
        %rrrt = imresize(rrrt,s);
    else
        % maximum number of iterations
        max_n_iterations = 20;

        % estimator id
        estimator_id = EstimatorID.MLE;

        % model ID
        model_id = ModelID.GAUSS_2D; 
        
        % tolerance
        tolerance = 1e-3;
        
        initial_parameters = [0,0,0,0,0];
        
        %% run Gpufit
        [parameters, states, chi_squares, n_iterations, time] = gpufit(matrix, [], ...
            model_id, initial_parameters, tolerance, max_n_iterations, [], estimator_id, []);

    end
end