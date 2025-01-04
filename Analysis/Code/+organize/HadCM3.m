function[] = HadCM3(mipvar, varName)
%% Organizes HadCM3 model output into a .grid file
%
% organize.HadCM3(mipvar, varName)
%
% ----- Inputs -----
%
% mipvar: The variable name used by CMIP
%
% varName: The variable name to use for this study

f = sprintf('%s_Amon_HadCM3_past1000_r1i1p1_085001-185012.nc', mipvar);
lat = ncread(f, 'lat');
lon = ncread(f, 'lon');
time = (datetime(850,1,15):calmonths(1):datetime(2005,12,15))';

meta = gridfile.defineMetadata('lon',lon,'lat',lat,'time',time);
file = sprintf('%s-hadcm3.grid', varName);
grid = gridfile.new(file, meta, [], true);
dimOrder = ["lon","lat","time"];

meta.time = time(1:12012);
grid.add('nc', f, mipvar, dimOrder, meta);

for k = 1859:25:1984
    f = sprintf('%s_Amon_HadCM3_historical_r1i1p1_%4.f12-%4.f11.nc', mipvar, k, k+25 );
    meta.time = ( datetime(k,12,15):calmonths(1):datetime(k+25,11,15) )';
    
    if k==1984
        f = sprintf('%s_Amon_HadCM3_historical_r1i1p1_%4.f12-%4.f12.nc', mipvar, k, k+21 );
        meta.time = ( datetime(k,12,15):calmonths(1):datetime(2005,12,15) )';
    end
    
    grid.add('nc', f, mipvar, dimOrder, meta);
end

end