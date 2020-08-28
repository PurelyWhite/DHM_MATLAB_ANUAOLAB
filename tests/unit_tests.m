% On first start. Either run all tests or run the command 'addpath('.')'
% in the console

function tests = unit_tests()
    addpath('.')
    tests = functiontests(localfunctions);
end

% Individual Function Tests

function testHologram2WrappedPhase(testCase)
    first_order = [146,162,42,51];
    file_path = 'I:\DHM_MATLAB_ANUAOLAB\examples\small_bead\hologram.tif';
    exp_wrapped_phase = load('I:\DHM_MATLAB_ANUAOLAB\examples\small_bead\wrapped_phase.mat').wrapped_phase;

    processing_reconstructor = reconstructor;
    
    processing_roi = [1 1 272 273];
    [processing_reconstructor, ~, ~, fftimg] = processing_reconstructor.load_img(file_path, 1, processing_roi);            

    centreimg = processing_reconstructor.crop_fft(fftimg, first_order);
    reconstructed = gather(angle(ifft2(ifftshift(centreimg))));
    
    verifyEqual(testCase,reconstructed,exp_wrapped_phase)
end

function testHologram2Inten(testCase)
    first_order = [146,162,42,51];
    file_path = 'I:\DHM_MATLAB_ANUAOLAB\examples\small_bead\hologram.tif';
    exp_intensity = load('I:\DHM_MATLAB_ANUAOLAB\examples\small_bead\intensity.mat').intensity;

    processing_reconstructor = reconstructor;
    
    processing_roi = [1 1 272 273];
    [processing_reconstructor, ~, ~, fftimg] = processing_reconstructor.load_img(file_path, 1, processing_roi);            

    centreimg = processing_reconstructor.crop_fft(fftimg, first_order);
    reconstructed = gather(abs(ifft2(ifftshift(centreimg))));
    
    verifyEqual(testCase,reconstructed,exp_intensity)
end

% This is different atm???
function testCPUPhaseUnwrapping(testCase)
    wrapped_phase = load('I:\DHM_MATLAB_ANUAOLAB\examples\small_bead\wrapped_phase.mat').wrapped_phase;
    exp_unwrapped_phase = load('I:\DHM_MATLAB_ANUAOLAB\examples\small_bead\curveless_phase.mat').curveless_phase;
    
    unwrapped_phase = Miguel_2D_unwrapper(single(wrapped_phase));
    c = curve(unwrapped_phase);
    
    curveless_phase = unwrapped_phase-c;
    verifyEqual(testCase,curveless_phase,single(exp_unwrapped_phase))
end

function testGPUPhaseUnwrapping(testCase)
    wrapped_phase = load('I:\DHM_MATLAB_ANUAOLAB\examples\small_bead\wrapped_phase.mat').wrapped_phase;
    exp_unwrapped_phase = load('I:\DHM_MATLAB_ANUAOLAB\examples\small_bead\curveless_phase.mat').curveless_phase;
    
    [N,M] = size(wrapped_phase);
    unwrapper = LeastSquares_Unwrapper(N,M);
    p = gpuArray(wrapped_phase);
    unwrapped_phase = gather(unwrapper.unwrap(p));
    
    c = curve(unwrapped_phase);
    curveless_phase = double(unwrapped_phase-c);
    
    verifyEqual(testCase,mean(abs(curveless_phase),'All'),double(mean(abs(exp_unwrapped_phase),'All')),'RelTol',0.05)
end

function testDownsampledCurve(testCase)
    unwrapped_phase = load('I:\DHM_MATLAB_ANUAOLAB\examples\small_bead\unwrapped_phase.mat').unwrapped_phase;
    exp_curve = load('I:\DHM_MATLAB_ANUAOLAB\examples\small_bead\curve.mat').curve;
    
    actSolution = downsampled_curve(unwrapped_phase);
    expSolution = exp_curve;
    verifyEqual(testCase,double(actSolution),expSolution,'AbsTol',0.01)
end

function testCurve(testCase)
    unwrapped_phase = load('I:\DHM_MATLAB_ANUAOLAB\examples\small_bead\unwrapped_phase.mat').unwrapped_phase;
    exp_curve = load('I:\DHM_MATLAB_ANUAOLAB\examples\small_bead\curve.mat').curve;
    
    actSolution = curve(unwrapped_phase);
    expSolution = exp_curve;
    verifyEqual(testCase,actSolution,expSolution)
end

% Reconstructor Test Cases

function testHologram2UnwrappedPhase(testCase)
    %hologram = load('I:\DHM_MATLAB_ANUAOLAB\examples\small_bead\hologram.tif');
    exp_unwrapped_phase = load('I:\DHM_MATLAB_ANUAOLAB\examples\small_bead\curveless_phase.mat').curveless_phase;
    exp_intensity = load('I:\DHM_MATLAB_ANUAOLAB\examples\small_bead\intensity.mat').intensity;
    first_order = [146,162,42,51];
    file_path = 'I:\DHM_MATLAB_ANUAOLAB\examples\small_bead\hologram.tif';
    
    processing_reconstructor = reconstructor;
    
    processing_roi = [1 1 272 273];
    [processing_reconstructor, ~, ~, fftimg] = processing_reconstructor.load_img(file_path, 1, processing_roi);            
    
    
    centreimg = processing_reconstructor.crop_fft(fftimg, first_order);
    [intensity_no_curve, phase_unwrap_no_curve, ~, ~, ~, ~, ~] = processing_reconstructor.process(10, centreimg, 20, ...
        0, 0, 512, 0.06, 0.5);
    
    verifyEqual(testCase,mean(abs(phase_unwrap_no_curve),'All'),double(mean(abs(exp_unwrapped_phase),'All')),'RelTol',0.05)
    verifyEqual(testCase,mean(abs(intensity_no_curve),'All'),double(mean(abs(exp_intensity),'All')),'RelTol',0.05)
end

function testPreviewFunction(testCase)
    hologram = imread('I:\DHM_MATLAB_ANUAOLAB\examples\small_bead\hologram.tif'); % open hologram
    exp_unwrapped_phase = load('I:\DHM_MATLAB_ANUAOLAB\examples\small_bead\preview_unwrapped_phase.mat').preview_unwrapped_phase;
    first_order = [146,162,42,51];
    capture_reconstructor = reconstructor;

    [N,M] = size(hologram);
    capture_reconstructor.unwrapper = LeastSquares_Unwrapper(N,M);
    
    [~, unwrapped_phase] = capture_reconstructor.preview(hologram, first_order,100);

    verifyEqual(testCase,unwrapped_phase,exp_unwrapped_phase)
end