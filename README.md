# MATLAB Phase Retrieval for Digital Holographic Microscopy

![Screenshot](/wiki/blob/GUI_screenshot.PNG)

## About

Matlab App for Off-Axis Digital Holographic Microscopy phase retrieval. The program is intented to work for all off-axis DHM images. It also has a recording setup for the FLIR Blackfly S camera.

## System Requirement
### MATLAB Version
MATLAB R2019b preferred.

For imaging using FLIR Blackfly S, MATLAB R2019b is required, with [FLIR Spinnaker support](https://au.mathworks.com/matlabcentral/fileexchange/69202-flir-spinnaker-support-by-image-acquisition-toolbox) installed.

For processing, MATLAB R2019a and above is required.

## Installation & Running

1. Make sure the following add-ons have been installed into your Matlab installation:

		a. Image Processing Toolbox
		b. Parallel Computing Toolbox 
		c. Signals Processing Toolbox 
		d. Curve Fitting Toolbox

Help on how to install add-ons can be found [here](https://au.mathworks.com/help/matlab/matlab_env/get-add-ons.html)

2. Download latest version of "mlappinstall" file from [Releases](https://github.com/PurelyWhite/DHM_MATLAB_ANUAOLAB/releases)
3. Run installer
4. In Matlab, open Apps tab, expand app list and click on DHM with Blackfly S.

## Usage

For details on how to use the program, please click on the [Wiki](https://github.com/PurelyWhite/DHM_MATLAB_ANUAOLAB/wiki).

## GPU Processing

If a CUDA supported Nvidia GPU is available, the program will automatically use the GPU where appropriate.

CUDA can be installed via the the [Nvidia site](https://developer.nvidia.com/cuda-downloads).

## Bug submission

Please submit all bugs and feature requests via the [Issues](https://github.com/PurelyWhite/DHM_MATLAB_ANUAOLAB/issues) page, and attach screenshots where possible.

## Publications

For further usage details, please visit the [Wiki](https://github.com/PurelyWhite/DHM_MATLAB_ANUAOLAB/wiki) or our [SPIE conference proceeding](https://www.spiedigitallibrary.org/conference-proceedings-of-spie/11202/112021C/Software-package-for-off-axis-digital-holographic-microscopy-imaging-processing/10.1117/12.2539541.full)

If you have found this program to be useful in your research, we would be grateful if you could cite us using:

Tienan Xu, Xuefei He, Zhiduo Zhang, Samantha Montague, Elizabeth Gardiner, and Woie Ming Lee "Software package for off-axis digital holographic microscopy imaging processing", Proc. SPIE 11202, Biophotonics Australasia 2019, 112021C (30 December 2019); https://doi.org/10.1117/12.2539541 
