function [value, grad] = misfitFuncSparse(dcoeff, synthesisOp, analysisOp, w, fs, nShots, dataDeltaFreq, greenFreqForShotSet, greenFreqForRecSet)
% MISFITFUNCSPARSE Calculate the least-squares misfit function with respect
% to the coefficients of perturbation model dm under sparse transform with
% transform function
%
% value = 1/2 * (L(invTransform(dcoeff)) - delta_d)' * (L(invTransform(dcoeff)) - delta_d)
% grad = transform(L'(L(transform(dcoeff)) - delta_d))
%
%
% This matlab source file is free for use in academic research.
% All rights reserved.
%
% Written by Lingchen Zhu (zhulingchen@gmail.com)
% Center for Signal and Information Processing, Center for Energy & Geo Processing
% Georgia Institute of Technology

nw = length(w);

% model after inverse transform (synthesis)
if ~(isa(synthesisOp, 'function_handle'))
    dm = synthesisOp * dcoeff;
else
    dm = synthesisOp(dcoeff);
end
nLength = length(dm);

% value of the cost function
value = 0;
% gradient of the cost function
grad = zeros(nLength, 1);

% update the velocity model with least-squares
parfor iw = 1:nw
    
    % fprintf('Processing f = %fHz ... ', w(iw)/(2*pi));
    % tic;
    
    greenFreqForShot = greenFreqForShotSet{iw};
    greenFreqForRec = greenFreqForRecSet{iw};
    
    fieldScatter = w(iw)^2 * (-fs(iw)) * (repmat(dm, 1, nShots) .* greenFreqForShot).' * greenFreqForRec;
    bias = fieldScatter - dataDeltaFreq(:, :, iw).';
    value = value + 1/2 * norm(bias, 'fro')^2;
    
    grad = grad + w(iw)^2 * (-fs(iw)) * sum(greenFreqForShot .* (greenFreqForRec * conj(bias.')), 2);
    
    % timePerFreq = toc;
    % fprintf('elapsed time = %fs\n', timePerFreq);
    
end

% analysis on grad
if ~(isa(analysisOp, 'function_handle'))
    grad = real(analysisOp * grad);
else
    grad = real(analysisOp(grad));
end

% fprintf('error function value = %f\n', value);

end