function[years] = regression
%% parameters.years.regression  Return the years used in the linear regression used to calibrate the PAGES2k forward models
% ----------
%   years = parameters.years.regression
%   Return the years used in the linear regression used to calibrate the 
%   PAGES2k forward models. This calibration regresses the reanalysis
%   dataset against the PAGES2k network in order to calculation linear
%   coefficients for the PAGES2k linear forward models.
% ----------
%   Outputs:
%       years (numeric vector): The years to use in the regression

years = 1951:2000;

end