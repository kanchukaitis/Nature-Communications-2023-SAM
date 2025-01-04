function[] = FGOALS(mipvar, varName)
%% Organizes FGOALS model output into a .grid file
%
% organize.FGOALS(mipvar, varName)
%
% ----- Inputs -----
%
% mipvar: The variable name used by CMIP
%
% varName: The variable name to use for this study

f = sprintf('%s_Amon_FGOALS-gl_past1000_r1i1p1_100001-119912.nc', mipvar);
lat = ncread(f,'lat');
lon = ncread(f,'lon');
time = (datetime(1000,1,15):calmonths(1):datetime(1999,12,15))';

meta = gridfile.defineMetadata('lat',lat,'lon',lon,'time',time);
file = sprintf('%s-fgoals.grid', varName);
grid = gridfile.new(file, meta, [], true);
dimOrder = ["lon","lat","time"];

for k = 1000:200:1800
    f = sprintf('%s_Amon_FGOALS-gl_past1000_r1i1p1_%4.f01-%4.f12.nc', mipvar, k, k+199 );
    meta.time = time( year(time)>=k & year(time)<k+200 );
    grid.add('nc', f, mipvar, dimOrder, meta);
end

end