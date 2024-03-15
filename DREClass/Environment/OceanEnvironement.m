classdef OceanEnvironement < handle 

    properties 
        temperatureC
        salinity 
        pH 
        depth
    end 

    properties (Hidden)
        dBox 
        connectionFailed = 0;

        % TODO: check these values -> ocean mean values 
        defaultTemperatureC = 10;
        defaultSalinity = 35;
        defaultpH = 8;
    end

    %% Constructor 
    methods
        function obj = OceanEnvironement(mooring, rootSaveInput, bBox, tBox, dBox, loadFromFile) % Mooring is passed to the OceanEnvironment class to compute the paremeters for the given mooring site 
            obj.dBox = dBox;
            if loadFromFile
                [file_T, path_T] = uigetfile({'*.nc', 'NETCDF'}, ...
                                            'Select temperature file');
                [file_S, path_S] = uigetfile({'*.nc', 'NETCDF'}, ...
                                            'Select salinity file');
                [file_pH, path_pH] = uigetfile({'*.nc', 'NETCDF'}, ...
                            'Select pH file');
                
                data_T = getDataFromNETCDF(fullfile(path_T, file_T));
                data_S = getDataFromNETCDF(fullfile(path_S, file_S));
                data_pH = getDataFromNETCDF(fullfile(path_pH, file_pH));

                T = mean(data_T.thetao, [1, 2, 4], 'omitnan');
                S = mean(data_S.so, [1, 2, 4], 'omitnan');
                pH = mean(data_pH.ph, 'all', 'omitnan');
                D = data_T.depth;

            else
                try 
                    [T, S, D] = getTS(mooring, rootSaveInput, bBox, tBox, dBox);
                catch 
                    obj.connectionFailed = 1;
                end 

                try
                    pH = getPH(mooring, rootSaveInput, bBox, tBox, dBox);
                catch 
                    obj.connectionFailed = 1;
                end 
            end
                    
            sz = size(D);
            obj.temperatureC = reshape(T, sz);
            obj.salinity = reshape(S, sz);
            obj.depth = D;
            pH = repelem(pH, numel(D));
            pH = reshape(pH, sz);
            obj.pH = pH;

            % Fix for NaN values 
            % Temperature 
            idxNaN = isnan(obj.temperatureC);
            lastNotNaN = find(~idxNaN, 1, 'last');
            obj.temperatureC(idxNaN) = obj.temperatureC(lastNotNaN);
            % Salinity 
            idxNaN = isnan(obj.salinity);
            lastNotNaN = find(~idxNaN, 1, 'last');
            obj.salinity(idxNaN) = obj.salinity(lastNotNaN);
            % pH 
            idxNaN = isnan(obj.pH);
            lastNotNaN = find(~idxNaN, 1, 'last');
            obj.pH(idxNaN) = obj.pH(lastNotNaN);
                 
        end

        function setOfflineDefaultConfig(obj)
            % Properties used when using the app offline 
            % Set depth vector
            dz  = 5; 
            obj.depth = obj.dBox.min:dz:obj.dBox.max;
            obj.depth = obj.depth';
            n = numel(obj.depth);
            sz = size(obj.depth);
            
            obj.temperatureC = repelem(obj.defaultTemperatureC, n);
            obj.temperatureC = reshape(obj.temperatureC, sz);
            obj.salinity = repelem(obj.defaultSalinity, n);
            obj.salinity = reshape(obj.salinity, sz);
            obj.pH = repelem(obj.defaultpH, n);
            obj.pH = reshape(obj.pH, sz);
        end

    end

end 