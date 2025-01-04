classdef spatialGrid
    %% spatialGrid  Implement spatial grids 
    % ----------
    %   The spatialGrid class helps to implement common spatial grids for
    %   gridded datasets at variable resolutions. The class records the the
    %   centroid and edges of latitude-longitude grid cells, and provides
    %   unique identifiers for different grids.
    %
    %   The class also implements methods to help bin grids of different
    %   resolutions to a common resolution
    % ----------
    %
    
    properties (SetAccess = private)
        lat;        % The latitudes of the centroids of the grid cell
        lon;        % The longitudes of the centroids of the grid cells
        
        latEdges;   % The latitudes of the edges of the grid cells
        lonEdges;   % The longitudes of the edges of the grid cells
        
        latID;      % The name of the data product used to define latitude points
        lonID;      % The name of the data product used to define longitude points
    end
    
    methods (Access = private)
        function[obj] = spatialGrid(lat, lon, latEdges, lonEdges, latID, lonID)
            obj.lat = double(lat);
            obj.lon = double(lon);
            obj.latEdges = double(latEdges);
            obj.lonEdges = double(lonEdges);
            obj.latID = string(latID);
            obj.lonID = string(lonID);
        end
    end
        
    methods (Static)
        function[obj] = atlas(name)
            %% Returns a spatial grid for a drought atlas
            %
            % obj = spatialGrid.atlas(name)
            %
            % ----- Inputs -----
            %
            % name: The name of the drought atlas
            %
            % ----- Outputs -----
            %
            % obj: The new spatialGrid object
            
            % Get the gridfile metadata
            [lats, lons] = spatialGrid.latlon(name);
            
            % Latitude spacing is constant
            halfLat = unique(diff(lats))/2;
            latEdges = [lats(1)-halfLat; lats+halfLat];
            
            % Longitude spacing is constant
            halfLon = diff(lons(1:2))/2;
            lonEdges = [lons(1)-halfLon; lons+halfLon];
            
            % Get the spatial grid
            obj = spatialGrid(lats, lons, latEdges, lonEdges, name, name);
        end
        function[obj] = model(name, var)
            %% Returns the spatial grid for a model or reanalysis
            %
            % obj = spatialGrid.model(name)
            % Returns the spatial grid for the SLP variable
            %
            % obj = spatialGrid.model(name, var)
            % Returns the spatial grid for the specified variable
            %
            % ----- Inputs -----
            %
            % name: The name of the model or reanalysis
            %
            % var: (Optional) The name of the variable to use
            
            % Default var
            if ~exist('var','var') || isempty(var)
                var = 'slp';
            end
            
            % Load the lat/lon metadata
            file = sprintf('%s-%s', var, name);
            [lats, lons] = spatialGrid.latlon(file);
            
            % Latitude edges have variable spacing and are bounded
            halfLat = diff(lats)/2;
            latEdges = [-90; lats(1:end-1)+halfLat; 90];

            % Longitude spacing is constant. Lon is modular
            halfLon = unique(diff(lons))/2;
            lonEdges = [lons(1)-halfLon; lons+halfLon];
            
            % Create the new grid
            obj = spatialGrid(lats, lons, latEdges, lonEdges, name, name);
        end
        function[lats, lons] = latlon(file)
            %% Loads sorted latitude and longitude metadata from a gridfile
            %
            % [lats, lons] = spatialGrid.latlon(file)
            %
            % ----- Inputs -----
            %
            % file: The name of the gridfile
            %
            % ----- Outputs -----
            %
            % lats: The gridfile latitude metadata
            %
            % lons: The gridfile longitude metadata
            file = sprintf('%s.grid', file);
            meta = gridfile(file).metadata;
            lats = sort(meta.lat);
            lons = sort(meta.lon);
        end
        function[obj] = new(name, var)
            %% Creates a new spatial grid object
            %
            % obj = spatialGrid(name)
            % Creates a spatial grid for a data product
            %
            % obj = spatialGrid(name, var)
            % Specify which variable from the dataset to use.
            %
            % ----- Inputs -----
            %
            % name: The name of a spatially gridded data product
            %
            % var: The name of a variable in the dataset
            %
            % ----- Outputs -----
            %
            % obj: The new spatialGrid object
            
            % Default variable name
            if ~exist('var','var') || isempty(var)
                var = 'slp';
            end
            file = sprintf('%s.grid', name);
            if ~exist(file, 'file')
                file = sprintf('%s-%s.grid', var, name);
            end
            
            % File metadata, always use sorted coordinates
            meta = gridfile(file).meta;
            lats = sort(meta.lat);
            lons = sort(meta.lon);
            
            % Latitude edges have variable spacing and are bounded
            halfLat = diff(lats)/2;
            latEdges = [-90; lats(1:end-1)+halfLat; 90];

            % Longitude spacing is constant. Lon is modular
            halfLon = unique(diff(lons))/2;
            lonEdges = [lons(1)-halfLon; lons+halfLon];
            
            % Create the new spatial grid
            obj = spatialGrid(lats, lons, latEdges, lonEdges, name, name);
        end
        function[grid] = DA( names )
            %% Returns the spatial grid for an assimilation
            %
            % grid = spatialGrid.DA( names )
            %
            % ----- Inputs -----
            %
            % names: The names of any targets, priors, and reanalyses
            %    associated with an assimilation
            %
            % ----- Outputs -----
            %
            % grid: The spatial grid to use for the assimilation
            
            % Get the lowest resolution across all the products
            names = string(names);
            grid = spatialGrid.model(names(1));
            for n = 2:numel(names)
                nextGrid = spatialGrid.model(names(n));
                grid = grid.lowestResolution(nextGrid);
            end
        end
        function[grids] = uniqueDA(models, reanalysis)
            %% Returns the unique spatial grids required to implement single-prior
            % DA for the listed models and reanalysis.
            %
            % grids = spatialGrid.allDA(models, reanalysis)
            
            % Use strings internally
            models = string(models);
            reanalysis = string(reanalysis);
            
            % Preallocate
            nModels = numel(models);
            nGrids = nModels * nModels;
            grids = cell(nGrids, 1);
            
            % Get the grid for each perfect and biased assimilation
            g = 0;
            for t = 1:nModels
                for p = 1:nModels
                    g = g+1;
                    grids{g} = spatialGrid.DA([models(t), models(p), reanalysis]);
                end
            end
            
            % Return the unique grids
            ids = spatialGrid.ids(grids);
            [~, use] = unique(ids);
            grids = grids(use);
        end
        function[names] = ids(grids)
            %% Takes a cell vector of spatialGrids and returns the associated grid IDs
            %
            % grids = spatialGrid.ids(grids)
            %
            % ----- Inputs -----
            %
            % grids: A cell vector of spatialGrid objects
            
            % Error check
            assert(iscell(grids) && isvector(grids), 'grids must be a cell vector');
            
            % Preallocate
            nGrids = numel(grids);
            names = strings(size(grids));
            
            % Get the ID for each grid
            for g = 1:nGrids
                assert(isa(grids{g},'spatialGrid') && isscalar(grids{g}), ...
                    'Element %.f is not a spatialGrid', g);
                names(g) = grids{g}.id;
            end
        end
    end
    
    methods (Static, Access = private)
        function[k] = lowResIndex(N1, N2, id1, id2)
            %% Returns the index of the spatial product with lower resolution
            % along an axis. If resolutions match, selects the first id
            % when sorted numerically
            %
            % ----- Inputs -----
            %
            % N1: The number of elements along grid 1
            %
            % N2: The number of elements along grid 2
            %
            % id1: The ID along the dimension for grid 1
            %
            % id2: The ID along the dimension for grid 2
            %
            % ----- Outputs -----
            %
            % k: The index of the grid with lower resolution
            
            if N1 < N2
                k = 1;
            elseif N1 == N2
                [~, k] = sort([id1, id2]);
                k = k(1);
            else
                k = 2;
            end
        end
    end
    
    methods
        function[lowres] = lowestResolution(obj, grid2)
            %% Returns the spatial grid with lowest resolution across two data products
            %
            % lowres = obj.lowestResolution(name2)
            %
            % ----- Input -----
            % 
            % name2: The name of a second data product
            %
            % ----- Output -----
            %
            % lowres: The spatial grid with lowest resolution
            
            % Check input
            assert(isa(grid2, 'spatialGrid') && isscalar(grid2), 'grid2 must be a scalar spatial grid');
            
            % Get lowest resolution latitude and longitude
            grids = [obj, grid2];
            klat = spatialGrid.lowResIndex( numel(grids(1).lat), numel(grids(2).lat), grids(1).latID, grids(2).latID );
            klon = spatialGrid.lowResIndex( numel(grids(1).lon), numel(grids(2).lon), grids(1).lonID, grids(2).lonID );
            
            % Create a spatial grid with the low resolution fields
            lowres = spatialGrid( grids(klat).lat, grids(klon).lon, grids(klat).latEdges, ...
                grids(klon).lonEdges, grids(klat).latID, grids(klon).lonID );
        end
        function[grid] = surround(obj, grid2)
            %% Restricts a grid to the elements that surround a second grid
            %
            % grid = obj.surround(grid2)
            %
            % ----- Inputs -----
            %
            % grid2: A second spatialGrid object
            
            % Check input
            assert(isa(grid2, 'spatialGrid') && isscalar(grid2), 'grid2 must be a scalar spatial grid');
            
            % Get the spatial boundary
            south = find(obj.latEdges <= grid2.latEdges(1), 1, 'last');
            north = find(obj.latEdges >= grid2.latEdges(end), 1, 'first');
            west = find(obj.lonEdges <= grid2.lonEdges(1), 1, 'last');
            east = find(obj.lonEdges >= grid2.lonEdges(end), 1, 'first');
            
            % Create the restricted grid
            newlat = obj.lat(south:north-1);
            newlon = obj.lon(west:east-1);
            newLatEdges = obj.latEdges(south:north);
            newLonEdges = obj.lonEdges(west:east);
            grid = spatialGrid(newlat, newlon, newLatEdges, newLonEdges, obj.latID, obj.lonID);
        end
        function[str] = id(obj)
            %% Returns an identifying string for the spatial grid
            %
            % str = obj.id
            str = sprintf('grid_%s_%s', obj.latID, obj.lonID);
        end
        function[latlim, lonlim] = limits(obj)
            %% Returns the limits of a spatial grid
            %
            % [latlim, lonlim] = obj.limits
            %
            % ----- Outputs -----
            %
            % latlim: The latitude limits of a grid. First element is the
            %     southern boundary, second element is the northern boundary
            %
            % lonlim: Longitude limits of a grid. First element is the
            %     western boundary, second element is the easter boundary.
            latlim = [min(obj.latEdges), max(obj.latEdges)];
            lonlim = [min(obj.lonEdges), max(obj.lonEdges)];
        end
        function[Vq, Vfill] = bin(obj, V, binGrid)
            %% Bins data on one spatial grid into a second, lower-resolution grid
            %
            % [Vq, Vfill] = obj.bin(V, grid2)
            %
            % ----- Inputs -----
            %
            % V: A (lat x lon x time) data array
            %
            % grid2: A spatial grid that surrounds
            
            % Error check
            obj.assertOnGrid(V, 'V');
            assert(ndims(V)<=3, 'V cannot have more than 3 dimensions');    
            
            % Preallocate
            nLats = numel(binGrid.lat);
            nLons = numel(binGrid.lon);
            nTime = size(V,3);
            
            latWeights = cell(nLats, 1);
            lonWeights = cell(nLons, 1);
            lats = cell(nLats, 1);
            lons = cell(nLons, 1);
            Vq = NaN(nLats, nLons, nTime);
            
            percentHeight = cell(nLats, 1);
            percentWidth = cell(nLons, 1);
            filledHeight = ones(nLats, 1);
            filledWidth = ones(nLons, 1);
            Vfill = NaN(nLats, nLons, nTime);
            
            % Find latitudes that fall at least partly into the bins
            for k = 1:nLats
                binEdges = [binGrid.latEdges(k), binGrid.latEdges(k+1)];
                inBin = find(obj.latEdges(1:end-1) < binEdges(2)  &  obj.latEdges(2:end) > binEdges(1));
                lats{k} = inBin;

                % Get the percent of each latitude cell within the bin
                % (Approximating individual cells as squares)
                height = obj.latEdges(inBin+1) - obj.latEdges(inBin);
                percentSouth = max(0, binEdges(1) - obj.latEdges(inBin)) ./ height;
                percentNorth = max(0, obj.latEdges(inBin+1) - binEdges(2)) ./ height;
                weight = 1 - percentNorth - percentSouth;

                % Get the percent height of each grid within the bin
                totalHeight = diff(binEdges);
                percentHeight{k} = height .* weight / totalHeight;

                % Apply a latitudinal area cosine weighting
                weight = weight .* cosd(obj.lat(inBin));
                latWeights{k} = weight;

                % Get the percent of the bin that is filled with the grid
                if k == 1
                    filledHeight(k) = 1 - max(0, obj.latEdges(inBin(1)) - binEdges(1)) / totalHeight;
                elseif k==nLats
                    filledHeight(k) = 1 - max(0, binEdges(2) - obj.latEdges(inBin(end)+1)) / totalHeight;
                end
            end
            
            % Find the grid longitudes that fall at least partially within each bin
            for k = 1:nLons
                binEdges = [binGrid.lonEdges(k), binGrid.lonEdges(k+1)];
                inBin = find(obj.lonEdges(1:end-1) < binEdges(2)  &  obj.lonEdges(2:end) > binEdges(1));
                lons{k} = inBin;

                % Get the percent of each longitude cell within the bin
                width = obj.lonEdges(inBin+1) - obj.lonEdges(inBin);
                percentWest = max(0, binEdges(1) - obj.lonEdges(inBin)) ./ width;
                percentEast = max(0, obj.lonEdges(inBin+1) - binEdges(2)) ./ width;
                lonWeights{k} = 1 - percentEast - percentWest;

                % Get the percent width of each grid
                totalWidth = diff(binEdges);
                percentWidth{k} = width .* lonWeights{k} / totalWidth;

                % Also get the percent of empty space between the grid and bin edges
                if k==1
                    filledWidth(k) = 1 - max(0, obj.lonEdges(inBin(1)) - binEdges(1)) / totalWidth;
                elseif k==nLons
                    filledWidth(k) = 1 - max(0, binEdges(2) - obj.lonEdges(inBin(end)+1)) / diff(binEdges);
                end
            end
            
            % Get grid values used in each bin
            for r = 1:nLats
                for c = 1:nLons
                    Vbin = V(lats{r}, lons{c}, :);
                    nans = isnan(Vbin);

                    % Get the weight matrix and match any NaNs
                    weights = latWeights{r} .* lonWeights{c}';
                    weights = repmat(weights, [1 1 nTime]);
                    weights(nans) = NaN;

                    % Take the weighted mean for each time step
                    Vq(r,c,:) = sum(weights.*Vbin, [1 2], 'omitnan') ./ sum(weights, [1 2], 'omitnan');

                    % Get the percent area of missing gridpoints in the bin
                    missingArea = percentHeight{r} .* percentWidth{c}';
                    missingArea = repmat(missingArea, [1 1 nTime]);
                    missingArea(~nans) = 0;
                    missingArea = sum(missingArea, [1 2]);

                    % Get the percent of each bin that is filled with data
                    filled = filledHeight(r)*filledWidth(c);
                    Vfill(r,c,:) = filled - missingArea;
                end
            end            
        end
        function[coord, varargout] = ungrid(obj, varargin)
            %% Converts spatially gridded datasets to coordinate arrays
            %
            % [coord, V1, V2, ... VN] = obj.ungrid(V1, V2, ..., VN)
            %
            % ----- Inputs -----
            %
            % VN: A (lat x lon x ...) spatially gridded dataset
            %
            % ----- Outputs -----
            %
            % coord: The coordinate metadata for the ungridded datasets.
            %     First column is latitude, second is longitude.
            %
            % VN: The reshaped dataset (coord x ...)
            
            % Get coordinates
            [lats, lons] = ndgrid(obj.lat, obj.lon);
            coord = double( [lats(:), lons(:)] );
            
            % Sizes
            nLat = numel(obj.lat);
            nLon = numel(obj.lon);
            
            % Error check each input
            for v = 1:numel(varargin)
                VN = varargin{v};
                obj.assertOnGrid(VN, sprintf('input %.f',v));
                
                % Reshape to coordinate array
                siz = size(VN);
                varargin{v} = reshape(varargin{v}, [nLat*nLon, siz(3:end)]);
            end
            varargout = varargin;
        end
        function[Vq] = regrid(obj, V, coord)
            %% Regrids a coordinate atlas grid to cartesian
            %
            % Vq = obj.regrid(V, coord)
            %
            % ----- Inputs -----
            %
            % V: A coordinate dataset on the spatial grid (nCoord x nTime)
            %
            % coord: The coordinates of the dataset
            %
            % ----- Outputs -----
            %
            % Vq: The dataset regridded to cartesian
            
            % Preallocate
            nLon = numel(obj.lon);
            nLat = numel(obj.lat);
            nTime = size(V, 2);
            Vq = NaN(nLat, nLon, nTime);
            
            % Infill each row
            for k = 1:size(V,1)
                r = obj.lat==coord(k,1);
                c = obj.lon==coord(k,2);
                Vq(r,c,:) = V(k,:);
            end
        end  
        function[] = assertOnGrid(obj, X, name)
            %% Checks that the first two dimensions of a data array match
            % the latitude and longitude sizes of the spatial grid
            %
            % obj.assertOnGrid(X)
            %
            % obj.assertOnGrid(X, name)
            %
            % ----- Inputs -----
            %
            % X: The input dataset
            %
            % name: An optional name for the data set for error messages
            
            % Default name
            if ~exist('name','var') || isempty(name)
                name = 'the input';
            end
            
            % Check sizes
            assert(size(X,1) == numel(obj.lat), 'The first dimension of %s does not match the number of latitude points', name);
            assert(size(X,2) == numel(obj.lon), 'The second dimension of %s does not match the number of longitude points', name);
        end
        function[latIndex, lonIndex] = loadOrder(obj, dataLats, dataLons)
            %% Returns lat and lon indices for sorted loading from a 
            % gridfile with data on the current spatial grid.
            %
            % [latIndex, lonIndex] = obj.loadOrder(lats, lons)
           
            % Check that all spatial grid points are in the data
            if any(~ismember(obj.lat, dataLats))
                missingPointsError('latitude');
            elseif any(~ismember(obj.lon, dataLons))
                missingPointsError('longitude');
            end
            
            % Get the load indices
            latIndex = loadIndex(dataLats, obj.lat);
            lonIndex = loadIndex(dataLons, obj.lon);
            
            function[index] = loadIndex(dataVals, vals)
                [ismem, order] = ismember(dataVals, vals);
                index = find(ismem);
                order = order(order~=0);
                index = index(order);
            end
            function[] = missingPointsError(type)
                error('The data is missing some of the %s points in the spatial grid', type);
            end
        end
        function[X, meta] = load(obj, file)
            %% Loads data from a gridfile that falls on the current spatial grid
            %
            % [X, meta] = obj.load(file)
            %
            % ----- Inputs -----
            %
            % file: The name of a .grid file            
            data = gridfile(file);
            [latOrder, lonOrder] = obj.loadOrder(data.meta.lat, data.meta.lon);
            [X, meta] = data.load(["lat","lon","time"], {latOrder, lonOrder, []});
        end
    end
end

            
    