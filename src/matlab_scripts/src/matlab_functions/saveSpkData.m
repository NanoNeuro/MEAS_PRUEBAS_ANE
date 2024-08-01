function [] = saveSpkData(AllSpikeData, ROOT, SAVE_FOLDER, CRow, CCol, ERow, ECol)
    filename = returnFilename(ROOT, SAVE_FOLDER, CRow, CCol, ERow, ECol);

    % GET ELECTRODE INFO FROM SPK
    ElectrodeSpkData = AllSpikeData{CRow, CCol, ERow, ECol};
       
    
    % Escribir esta información
    timeSpk = ElectrodeSpkData.GetTimeVector;
    filenameTimeSpk=strcat(filename, '_timeSpk.txt');
    writematrix(timeSpk, filenameTimeSpk);
    
    voltageSpk = ElectrodeSpkData.GetVoltageVector;
    filenamevoltageSpk=strcat(filename, '_voltageSpk.txt');
    writematrix(voltageSpk, filenamevoltageSpk);
end