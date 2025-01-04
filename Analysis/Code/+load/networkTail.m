function[tail] = networkTail(network, gridID)
%% Returns the filename tail for a proxy network
%
% tail = networkTail(network, gridID)
%
% ----- Inputs -----
%
% network: The name of a proxy network
%
% gridID: The ID of a spatial grid

tail = "";
if ~strcmpi(network, "pages")
    tail = sprintf("-%s", gridID);
end

end