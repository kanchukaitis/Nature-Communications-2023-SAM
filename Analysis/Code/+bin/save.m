function[] = save(fileName, varName, Vq, Vfill, coord, time, grid)
%% Saves the results of a binning operation to a .mat file and catalogues
% the results in a .grid file
%
% bin.save(fileName, varName, Vq, Vfill, coord, time, grid)
%
% ----- Inputs -----
%
% fileName: The name to use for the save file
%
% varName: The name to use for Vq in the save file
%
% Vq: The binned climate variable
%
% Vfill: The percent of each bin filled
%
% coord: Coordinate metadata for the binned variable
%
% time: Time metadata for the binned variable
%
% grid: The spatialGrid of the binned variable
%
% ----- Outputs -----
%
% Creates .mat and .grid files with the given filename

% Save mat file
s = struct(varName, Vq, 'percentFilled', Vfill, 'coord', coord, 'time', time, 'grid', grid);
save(fileName, '-struct', 's', '-v7.3');

% Gridfile
meta = gridfile.defineMetadata('coord', coord, 'time', time);
atts = struct('percentFilled', Vfill, 'grid', grid);
grid = gridfile.new(fileName, meta, atts, true);
grid.add('mat', sprintf('%s.mat',fileName), varName, ["coord","time"], meta);

end
