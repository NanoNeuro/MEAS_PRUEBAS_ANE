addpath('Z:\Nanoneuro\AxionFileLoader\AxionFileLoader\');
addpath('Z:\Nanoneuro\src\matlab_functions');


ROOT = 'Z:\Nanoneuro\data\Ane_2024_07_08';
FILENAME_BASIS = 'D52_POSTsiembra_P2_post experimento(000)' 


mkdir(ROOT, FILENAME_BASIS)

% LOAD ALL RAW AND SPIKE DATA
try
    FileDataRaw=AxisFile(strcat(ROOT, '\', FILENAME_BASIS, '.raw'));
    AllRawData=FileDataRaw.RawVoltageData.LoadData;
catch
    AllRawData = false;
end

try
    FileDataSpk=AxisFile(strcat(ROOT, '\', FILENAME_BASIS, '.spk'));
    AllSpikeData=FileDataSpk.SpikeData.LoadData;
catch
    AllSpikeData = false;
end





for CRow = 1:4 
    for CCol = 1:6 
        for ERow = 1:4
            for ECol = 1:4                   
               if not(isequal(AllRawData, false));
                    try
                        saveRawData(AllRawData, ROOT, FILENAME_BASIS, CRow, CCol, ERow, ECol, false, true);
                    catch
                        warning(strcat('Problem saving RAW data from Channel (', ...
                            num2str(CRow), ', ', num2str(CCol), ...
                            ') Electrode (', ...
                            num2str(ERow), ', ', num2str(ECol), ...
                            ')'))
                    end
                end
                
                if not(isequal(AllSpikeData, false));
                    try
                        saveSpkData(AllSpikeData, ROOT, FILENAME_BASIS, CRow, CCol, ERow, ECol);
                    catch
                        warning(strcat('Problem saving SPK data from Channel (', ...
                            num2str(CRow), ', ', num2str(CCol), ...
                            ') Electrode (', ...
                            num2str(ERow), ', ', num2str(ECol), ...
                            ')'))
                    end
                end
          
            end
        end
    end
end








% PARA SACAR LA INFO DE UNA LISTA DE ARCHIVOS!

ROOT = 'Z:\Nanoneuro\data\Ane_2024_07_08';
list_filenames = {"D38_postSIEMBRA_LINKER(000)", "D38_postSIEMBRA_post experimento(000)", "D38_POSTsiembra_pre experimento(000)"}
len_list=3

% CON EL WARNING
for idx = 1:len_list
    FILENAME_BASIS=list_filenames{idx}
    mkdir(ROOT, FILENAME_BASIS)

     
    xoxo=strcat(ROOT, '\', FILENAME_BASIS, '.raw')
    FileDataRaw=AxisFile(xoxo);
    AllRawData=FileDataRaw.RawVoltageData.LoadData;
    

   for CRow = 1:4 
    for CCol = 1:6 
        for ERow = 1:4
            for ECol = 1:4
               if not(isequal(AllRawData, false));
                    try
                        saveRawData(AllRawData, ROOT, FILENAME_BASIS, CRow, CCol, ERow, ECol, false, true);
                    catch
                        warning(strcat('Problem saving RAW data from Channel (', ...
                            num2str(CRow), ', ', num2str(CCol), ...
                            ') Electrode (', ...
                            num2str(ERow), ', ', num2str(ECol), ...
                            ')'))
                    end
                end
                
              
          
            end
        end
    end
   end
end



% SIN WARNING
for idx = 1:len_list
    FILENAME_BASIS=list_filenames{idx}
    mkdir(ROOT, FILENAME_BASIS)

     
    xoxo=strcat(ROOT, '\', FILENAME_BASIS, '.raw')
    FileDataRaw=AxisFile(xoxo);
    AllRawData=FileDataRaw.RawVoltageData.LoadData;
    

   for CRow = 1:4 
    for CCol = 1:6 
        for ERow = 1:4
            for ECol = 1:4

               if not(isequal(AllRawData, false));
                    saveRawData(AllRawData, ROOT, FILENAME_BASIS, CRow, CCol, ERow, ECol, false, true);
                end
                
              
          
            end
        end
    end
   end
end



















% PARA SACAR LOS TIEMPOS


list_filenames = {"D52_POSTsiembra_P2_A2_100(000)", "D52_POSTsiembra_P2_C3_100(000)", "D52_POSTsiembra_P2_A3_100(000)",  "D52_POSTsiembra_P2_C4_100(000)", "D52_POSTsiembra_P2_B2_200(000)",  "D52_POSTsiembra_P2_C5_200(000)", "D52_POSTsiembra_P2_B4_200(000)",  "D52_POSTsiembra_P2_C6_200(000)", "D52_POSTsiembra_P2_B5_500(000)",  "D52_POSTsiembra_P2_D3_500(000)", "D52_POSTsiembra_P2_C1_500(000)",  "D52_POSTsiembra_P2_D5_500(000)"}

ROOT = 'Z:\Nanoneuro\data\Ane_2024_06_07\Placa2';

fprintf('FileName, BlockVectorStartTime, ExperimentStartTime, AddedDate, ModifiedDate\n')
for idx = 1:100
    FILENAME_BASIS=list_filenames{idx};
    FileDataRaw=AxisFile(strcat(ROOT, '\', FILENAME_BASIS, '.raw'));
    time_BlockVectorStartTime=FileDataRaw.DataSets.BlockVectorStartTime;
    str_BlockVectorStartTime=sprintf('%d:%d:%d:%d', time_BlockVectorStartTime.Hour, time_BlockVectorStartTime.Minute, time_BlockVectorStartTime.Second, time_BlockVectorStartTime.Millisecond);
    time_ExperimentStartTime=FileDataRaw.DataSets.ExperimentStartTime;
    str_ExperimentStartTime=sprintf('%d:%d:%d:%d', time_ExperimentStartTime.Hour, time_ExperimentStartTime.Minute, time_ExperimentStartTime.Second, time_ExperimentStartTime.Millisecond);
    time_AddedDate=FileDataRaw.DataSets.AddedDate;
    str_AddedDate=sprintf('%d:%d:%d:%d', time_AddedDate.Hour, time_AddedDate.Minute, time_AddedDate.Second, time_AddedDate.Millisecond);
    time_ModifiedDate=FileDataRaw.DataSets.ModifiedDate;
    str_ModifiedDate=sprintf('%d:%d:%d:%d', time_ModifiedDate.Hour, time_ModifiedDate.Minute, time_ModifiedDate.Second, time_ModifiedDate.Millisecond);



    fprintf('%s, %s, %s, %s, %s\n',FILENAME_BASIS, str_BlockVectorStartTime, str_ExperimentStartTime, str_AddedDate, str_ModifiedDate)
   
end

