function getBathyData(obj)
    promptMsg = 'Loading bathymetry dataset';
    fprintf(promptMsg);
    fileCSV = 'Bathymetry.csv';

    % Query subset data from GEBCO global grid 
    if strcmp(obj.bathyEnvironment.source, 'GEBCO2021')
        bathyFile = extratBathybBoxFromGEBCOGlobal(obj.bBox, obj.rootSaveInput);
        obj.bathyEnvironment.bathyFile = bathyFile;
        obj.bathyEnvironment.rootBathy = obj.rootSaveInput;
        obj.bathyEnvironment.bathyFileType = 'NETCDF';
        obj.bathyEnvironment.inputCRS = 'WGS84';
        obj.bathyEnvironment.drBathy = 100;
    
        % Convert file to csv and save it in the input folder 
        fNETCDF = fullfile(obj.bathyEnvironment.rootBathy, obj.bathyEnvironment.bathyFile);
        fCSV = fullfile(obj.rootSaveInput, fileCSV);
        bathyNETCDFtoCSV(fNETCDF, fCSV)

    elseif strcmp(obj.bathyEnvironment.source, 'Userfile')

        rootBathy = obj.bathyEnvironment.rootBathy;
        bathyFile = obj.bathyEnvironment.bathyFile;
        if strcmp(obj.bathyEnvironment.bathyFileType, 'CSV') % File is a csv
            % Copy to input folder 
            copyfile(fullfile(rootBathy, bathyFile), fullfile(obj.rootSaveInput, fileCSV))
            
        elseif strcmp(obj.bathyEnvironment.bathyFileType, 'NETCDF') % File is a netcdf
            % Convert file to csv and save it in the input folder 
            fNETCDF = fullfile(rootBathy, bathyFile);
            fCSV = fullfile(obj.rootSaveInput, fileCSV);
            bathyNETCDFtoCSV(fNETCDF, fCSV)
        end 
        
        obj.bathyEnvironment.rootBathy = obj.rootSaveInput;
    end
    % obj.bathyEnvironment.rootBathy = obj.rootSaveInput;
    obj.dataBathy = loadBathy(obj.rootSaveInput, fileCSV, obj.bBoxENU, obj.mooring.mooringPos);

    linePts = repelem('.', 53 - numel(promptMsg));
    fprintf(' %s DONE\n', linePts);
end
