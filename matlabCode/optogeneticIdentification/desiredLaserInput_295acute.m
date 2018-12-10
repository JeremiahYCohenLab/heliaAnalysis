function laserInput = desiredLaserInput_295acute(desiredOutput, laserSource, opticFiberTrans)
% laserInput = desiredLaserInput(desiredOutput, opticFiberTrans)
%   DESCRIPTION
%       Uses a calibration range from 1 to 10 fit with output = a*exp(b*input)
%   OUTPUT(S)
%       laserInput: knob setting for a given laser to achive a desired output
%   INPUT(S)
%       desiredOutput: output at most distal optic fiber (mW)
%       laserSource: integer; either '532' or '473'
%       opticFiberTrans: vector of transmission percentage for optic fiber(s)

if nargin < 3
    opticFiberTrans = 0.8;
end

% calibrated on 20181010 for split patch cords
if laserSource == 473
    p = [1.534 -9.007 (12.27 - desiredOutput*2/opticFiberTrans)];
    r = roots(p);
    laserInput = max(r);
elseif laserSource == 532
    p = [0.295 10.73 (-23.84 - desiredOutput*2/opticFiberTrans)];
    r = roots(p);
    laserInput = max(r);
else
    error('laserSource must be either 473 or 532')
end