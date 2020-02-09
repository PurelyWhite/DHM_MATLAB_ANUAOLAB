%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Unwrapping phase based on Ghiglia and Romero (1994) based on weighted and unweighted least-square method
% URL: https://doi.org/10.1364/JOSAA.11.000107
% Inputs:
%   * psi: wrapped phase from -pi to pi
%   * weight: weight of the phase (optional, default: all ones)
% Output:
%   * phi: unwrapped phase from the weighted (or unweighted) least-square phase unwrapping
% Author: Muhammad F. Kasim (University of Oxford, 2016)
% Download Source: https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/60345/versions/1/previews/phase_unwrap.m/index.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef LeastSquares_Unwrapper
    properties
        mult
    end
    methods
        function obj = LeastSquares_Unwrapper(N,M)
            [I, J] = meshgrid([0:M-1], [0:N-1]);
            arr = 2 .* (cos(pi*I/M) + cos(pi*J/N) - 2);
            obj.mult = gpuArray(arr);
        end
        
        function phi = unwrap(obj, psi)
            % get the wrapped differences of the wrapped values
            dx = [zeros([size(psi,1),1]), wrapToPi(diff(psi, 1, 2)), zeros([size(psi,1),1])];
            dy = [zeros([1,size(psi,2)]); wrapToPi(diff(psi, 1, 1)); zeros([1,size(psi,2)])];
            rho = diff(dx, 1, 2) + diff(dy, 1, 1);

            % get the result by solving the poisson equation
            phi = obj.solvePoisson(rho);
        end

        function phi = solvePoisson(obj, rho)
            % solve the poisson equation using dct  
            dctRho = transpose(dct(transpose(dct(rho))));
            
            dctPhi = dctRho ./ obj.mult;
            
            dctPhi(1,1) = 0; % handling the inf/nan value

            % now invert to get the result
            phi = transpose(idct(transpose(idct(dctPhi))));
        end

        % apply the transformation (A^T)(W^T)(W)(A) to 2D matrix
        function Qp = applyQ(~, p, WW)
            % apply (A)
            dx = [diff(p, 1, 2), zeros([size(p,1),1])];
            dy = [diff(p, 1, 1); zeros([1,size(p,2)])];

            % apply (W^T)(W)
            WWdx = WW .* dx;
            WWdy = WW .* dy;

            % apply (A^T)
            WWdx2 = [zeros([size(p,1),1]), WWdx];
            WWdy2 = [zeros([1,size(p,2)]); WWdy];
            Qp = diff(WWdx2,1,2) + diff(WWdy2,1,1);
        end
    end 
end