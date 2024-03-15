function setOceanEnvironment(obj)
    obj.oceanEnvironment = OceanEnvironement(obj.mooring, obj.rootSaveInput, obj.bBox, obj.tBox, obj.dBox, obj.load_cmems_FromFile); % setup ocean parameters by querying data from CMEMS 
end