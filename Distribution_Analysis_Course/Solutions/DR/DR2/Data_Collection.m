clear all
clc
format long g
read_dir=['C:\PNNL Work\Current Projects\AEP-Demo\Training Course\DR2\'];
disp('DR2')
file=['reg1_output.csv'];
read_file = [read_dir,file];
Regulator=csvread(read_file,9,1,[9,1,2000,11]);

%% Regulator Values
disp(sprintf('Regulator Real Power %0.0f kWh',sum(Regulator(:,10))/60000));% Real power in kWh
disp(sprintf('Regulator Reactive Power %0.0f kVAR\n',sum(Regulator(:,11))/60000));% Reactive power in kVAR

pf=cos(atan(Regulator(:,11)./Regulator(:,10)));

%% Votlage Values

file=['Voltage_630.csv'];
read_file = [read_dir,file];
V630=csvread(read_file,9,1,[9,1,2000,6]);
V630(:,7)=sqrt(V630(:,1).^2.+V630(:,2).^2); 
V630(:,8)=sqrt(V630(:,3).^2.+V630(:,4).^2); 
V630(:,9)=sqrt(V630(:,5).^2.+V630(:,6).^2); 
disp(sprintf('630_Va_min %0.0f V 630_Vb_min %0.0f V 630_Vc_min %0.0f V',min(V630(:,7)),min(V630(:,8)),min(V630(:,9))));

file=['Voltage_652.csv'];
read_file = [read_dir,file];
V652=csvread(read_file,9,1,[9,1,2000,6]);
V652(:,7)=sqrt(V652(:,1).^2.+V652(:,2).^2); 
V652(:,8)=sqrt(V652(:,3).^2.+V652(:,4).^2); 
V652(:,9)=sqrt(V652(:,5).^2.+V652(:,6).^2); 
disp(sprintf('652_Va_min %0.0f V 652_Vb_min %0.0f V 652_Vc_min %0.0f V',min(V652(:,7)),min(V652(:,8)),min(V652(:,9))));

file=['Voltage_671.csv'];
read_file = [read_dir,file];
V671=csvread(read_file,9,1,[9,1,2000,6]);
V671(:,7)=sqrt(V671(:,1).^2.+V671(:,2).^2); 
V671(:,8)=sqrt(V671(:,3).^2.+V671(:,4).^2); 
V671(:,9)=sqrt(V671(:,5).^2.+V671(:,6).^2); 
disp(sprintf('671_Va_min %0.0f V 671_Vb_min %0.0f V 671_Vc_min %0.0f V',min(V671(:,7)),min(V671(:,8)),min(V671(:,9))));

file=['Voltage_675.csv'];
read_file = [read_dir,file];
V675=csvread(read_file,9,1,[9,1,2000,6]);
V675(:,7)=sqrt(V675(:,1).^2.+V675(:,2).^2); 
V675(:,8)=sqrt(V675(:,3).^2.+V675(:,4).^2); 
V675(:,9)=sqrt(V675(:,5).^2.+V675(:,6).^2); 
disp(sprintf('675_Va_min %0.0f V 675_Vb_min %0.0f V 675_Vc_min %0.0f V',min(V675(:,7)),min(V675(:,8)),min(V675(:,9))));

file=['Voltage_680.csv'];
read_file = [read_dir,file];
V680=csvread(read_file,9,1,[9,1,2000,6]);
V680(:,7)=sqrt(V680(:,1).^2.+V680(:,2).^2); 
V680(:,8)=sqrt(V680(:,3).^2.+V680(:,4).^2); 
V680(:,9)=sqrt(V680(:,5).^2.+V680(:,6).^2); 
disp(sprintf('680_Va_min %0.0f V 680_Vb_min %0.0f V 680_Vc_min %0.0f V\n',min(V680(:,7)),min(V680(:,8)),min(V680(:,9))));

%% Temperature
% file=['temperature.csv'];
% read_file = [read_dir,file];
% Temperature=csvread(read_file,9,1,[9,1,2000,1]);
%% Price Data
file=['price_statistics.csv'];
read_file = [read_dir,file];
Market_Values=csvread(read_file,9,1,[9,1,2000,1]);
%% Appliance Data
file=['HVAC_Data.csv'];
read_file = [read_dir,file];
HVAC_Data=csvread(read_file,9,1,[9,1,2000,5]);

file=['HVAC_Data2.csv'];
read_file = [read_dir,file];
HVAC_Data2=csvread(read_file,9,1,[9,1,2000,1]);

fclose all;