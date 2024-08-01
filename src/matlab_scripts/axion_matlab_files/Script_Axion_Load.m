%Cargar datos de un recording
AllData_D14=AxisFile('D14(000)(000).spk').SpikeData.LoadData([100 200])

%Extraer datos de un pocillo
Data_D14_C2=[AllData_D14{3,2,:,:}]

%Extraer el array de Voltaje de ese pocillo
volt_D14_C2=Data_D14_C2.GetVoltageVector

%Extraer el array de tiempos de ese pocillo
time_D14_C2=Data_D14_C2.GetTimeVector
%% 

%Exportar cdv
writematrix(volt_D14_C2, 'volt_D13_C3.csv')
%% 

%Plotear los spikes de ese pocillo
plot(volt_D13_C3)
%% 

%%Raster plot
[nwr nwc nec ner] = size(AllData_D14); %Find the dimensions of AllData
for i = 1:nec
for j = 1:ner
%Select the spike times from each electrode in the well
if ~isempty(AllData_D14{3,2,i,j})
ts=[AllData_D14{3,2,i,j}(:).Start];
hold on;
plot([ts;ts],-(i-1)*ner-j+[0.75*ones(size(ts))...
;zeros(size(ts))],'k'); %Plot a vertical line at each
%timepoint corresponding to a spike
hold off;
end
end
end
