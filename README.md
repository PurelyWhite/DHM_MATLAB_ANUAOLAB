# MATLAB Phase Retrieval for Digital Holographic Microscopy

## About

Matlab App for Off-Axis Digital Holographic Microscopy phase retrieval. The program is intented to work for all off-axis DHM images. It also has a recording setup for the FLIR Blackfly S camera.

## Installation & Running

1. Download latest version [Releases](https://github.com/PurelyWhite/DHM_MATLAB_ANUAOLAB/releases) of "mlappinstall" file.
2. Run installer
3. In Matlab, open Apps tab, expand app list and click on DHM with Blackfly S.

## System Requirement
### MATLAB Version
MATLAB R2019b preferred.

For imaging using FLIR Blackfly S, MATLAB R2019b is required, with FLIR Spinnaker support installed (https://au.mathworks.com/matlabcentral/fileexchange/69202-flir-spinnaker-support-by-image-acquisition-toolbox).

For processing, MATLAB R2019a and above is required.

## GPU Processing

If a CUDA supported Nvidia GPU is available, the program will automatically use the GPU where appropriate.
