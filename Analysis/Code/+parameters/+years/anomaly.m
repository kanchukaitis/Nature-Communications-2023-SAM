function[years] = anomaly
%% parameters.years.anomaly  Return the years used to compute proxy anomalies for the assimilation
% ----------
%   years = parameters.years.anomaly
%   Returns the years used to compute proxy anomalies. Before assimilation,
%   the absolute proxy records are converted to proxy record anomalies.
%   These years define the background period that is used to obtain the
%   anomalies.
% ----------
%   Outputs:
%       years (numeric vector): The years used as the background when
%           computing proxy record anomalies.

years = 851:1849;

end