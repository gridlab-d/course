clear all
clc
format long g
read_dir=['C:\PNNL Work\Current Projects\AEP-Demo\Training Course\CVR 13 Node E3\'];

file=['reg1_output.csv'];
read_file = [read_dir,file];
Regulator=csvread(read_file,9,1,[9,1,10009,11]);

%% Regulator Values
disp(sprintf('Regulator Real Power %0.0f kWh',sum(Regulator(:,10))/60000));% Real power in kWh
disp(sprintf('Regulator Reactive Power %0.0f kVAR\n',sum(Regulator(:,11))/60000));% Reactive power in kVAR

pf=cos(atan(Regulator(:,11)./Regulator(:,10)));

%% Votlage Values
file=['Voltage_611.csv'];
read_file = [read_dir,file];
V611=csvread(read_file,9,1,[9,1,10009,6]);
V611(:,7)=sqrt(V611(:,1).^2.+V611(:,2).^2); 
V611(:,8)=sqrt(V611(:,3).^2.+V611(:,4).^2); 
V611(:,9)=sqrt(V611(:,5).^2.+V611(:,6).^2); 
disp(sprintf('611_Va_min %0.0f V 611_Vb_min %0.0f V 611_Vc_min %0.0f V',min(V611(:,7)),min(V611(:,8)),min(V611(:,9))));

file=['Voltage_630.csv'];
read_file = [read_dir,file];
V630=csvread(read_file,9,1,[9,1,10009,6]);
V630(:,7)=sqrt(V630(:,1).^2.+V630(:,2).^2); 
V630(:,8)=sqrt(V630(:,3).^2.+V630(:,4).^2); 
V630(:,9)=sqrt(V630(:,5).^2.+V630(:,6).^2); 
disp(sprintf('630_Va_min %0.0f V 630_Vb_min %0.0f V 630_Vc_min %0.0f V',min(V630(:,7)),min(V630(:,8)),min(V630(:,9))));

file=['Voltage_634.csv'];
read_file = [read_dir,file];
V634=csvread(read_file,9,1,[9,1,10009,6]);
V634(:,7)=sqrt(V634(:,1).^2.+V634(:,2).^2); 
V634(:,8)=sqrt(V634(:,3).^2.+V634(:,4).^2); 
V634(:,9)=sqrt(V634(:,5).^2.+V634(:,6).^2);
disp(sprintf('634_Va_min  %0.0f V 634_Vb_min  %0.0f V 634_Vc_min  %0.0f V',min(V634(:,7)),min(V634(:,8)),min(V634(:,9))));

file=['Voltage_646.csv'];
read_file = [read_dir,file];
V646=csvread(read_file,9,1,[9,1,10009,6]);
V646(:,7)=sqrt(V646(:,1).^2.+V646(:,2).^2); 
V646(:,8)=sqrt(V646(:,3).^2.+V646(:,4).^2); 
V646(:,9)=sqrt(V646(:,5).^2.+V646(:,6).^2); 
disp(sprintf('646_Va_min %0.0f V 646_Vb_min %0.0f V 646_Vc_min %0.0f V',min(V646(:,7)),min(V646(:,8)),min(V646(:,9))));

file=['Voltage_652.csv'];
read_file = [read_dir,file];
V652=csvread(read_file,9,1,[9,1,10009,6]);
V652(:,7)=sqrt(V652(:,1).^2.+V652(:,2).^2); 
V652(:,8)=sqrt(V652(:,3).^2.+V652(:,4).^2); 
V652(:,9)=sqrt(V652(:,5).^2.+V652(:,6).^2); 
disp(sprintf('652_Va_min %0.0f V 652_Vb_min %0.0f V 652_Vc_min %0.0f V',min(V652(:,7)),min(V652(:,8)),min(V652(:,9))));

file=['Voltage_671.csv'];
read_file = [read_dir,file];
V671=csvread(read_file,9,1,[9,1,10009,6]);
V671(:,7)=sqrt(V671(:,1).^2.+V671(:,2).^2); 
V671(:,8)=sqrt(V671(:,3).^2.+V671(:,4).^2); 
V671(:,9)=sqrt(V671(:,5).^2.+V671(:,6).^2); 
disp(sprintf('671_Va_min %0.0f V 671_Vb_min %0.0f V 671_Vc_min %0.0f V',min(V671(:,7)),min(V671(:,8)),min(V671(:,9))));

file=['Voltage_675.csv'];
read_file = [read_dir,file];
V675=csvread(read_file,9,1,[9,1,10009,6]);
V675(:,7)=sqrt(V675(:,1).^2.+V675(:,2).^2); 
V675(:,8)=sqrt(V675(:,3).^2.+V675(:,4).^2); 
V675(:,9)=sqrt(V675(:,5).^2.+V675(:,6).^2); 
disp(sprintf('675_Va_min %0.0f V 675_Vb_min %0.0f V 675_Vc_min %0.0f V',min(V675(:,7)),min(V675(:,8)),min(V675(:,9))));

file=['Voltage_680.csv'];
read_file = [read_dir,file];
V680=csvread(read_file,9,1,[9,1,10009,6]);
V680(:,7)=sqrt(V680(:,1).^2.+V680(:,2).^2); 
V680(:,8)=sqrt(V680(:,3).^2.+V680(:,4).^2); 
V680(:,9)=sqrt(V680(:,5).^2.+V680(:,6).^2); 
disp(sprintf('680_Va_min %0.0f V 680_Vb_min %0.0f V 680_Vc_min %0.0f V\n',min(V680(:,7)),min(V680(:,8)),min(V680(:,9))));

%% Loads
file=['Residential_Loads.csv']; % (P, Q)
read_file = [read_dir,file];
Residential_loads=csvread(read_file,9,1,[9,1,10009,2]);

disp(sprintf('Residential Loads (Real) %0.0f kWh',sum(Residential_loads(:,1)/60000)));
disp(sprintf('Residential Loads (Reactive) %0.0f kVAR\n',sum(Residential_loads(:,2)/60000)));

%% Losses
file=['Overhead_Line_Losses.csv']; %(Pa, Qa, Pb, Qb, Pc, Qc)
read_file = [read_dir,file];
OH_Losses=csvread(read_file,9,1,[9,1,10009,6]);
Losses(1,1)=sum(OH_Losses(:,1)+OH_Losses(:,3)+OH_Losses(:,5))/60000;
Losses(1,2)=sum(OH_Losses(:,2)+OH_Losses(:,4)+OH_Losses(:,5))/60000;
disp(sprintf('Overhead Losses (Real) %0.0f kWh',Losses(1,1)));
disp(sprintf('Overhead Losses (Reactive) %0.0f kVAR\n',Losses(1,2)));

file=['Underground_Line_Losses.csv'];%(Pa, Qa, Pb, Qb, Pc, Qc)
read_file = [read_dir,file];
UG_Losses=csvread(read_file,9,1,[9,1,10009,6]);
Losses(2,1)=sum(UG_Losses(:,1)+UG_Losses(:,3)+UG_Losses(:,5))/60000;
Losses(2,2)=sum(UG_Losses(:,2)+UG_Losses(:,4)+UG_Losses(:,5))/60000;
disp(sprintf('Underground Losses (Real) %0.0f kWh',Losses(2,1)));
disp(sprintf('Underground Losses (Reactive) %0.0f kVAR\n',Losses(2,2)));


file=['Distribution_Trans_Losses.csv'];
read_file = [read_dir,file];
XFMR_Losses=csvread(read_file,9,1,[9,1,10009,6]);%(Pa, Qa, Pb, Qb, Pc, Qc)
Losses(3,1)=sum(XFMR_Losses(:,1)+XFMR_Losses(:,3)+XFMR_Losses(:,5))/60000;
Losses(3,2)=sum(XFMR_Losses(:,2)+XFMR_Losses(:,4)+XFMR_Losses(:,5))/60000;
disp(sprintf('XFMR Losses (Real) %0.0f kWh',Losses(3,1)));
disp(sprintf('XFMR Losses (Reactive) %0.0f kVAR\n',Losses(3,2)));

file=['Triplex_Line_Losses.csv'];
read_file = [read_dir,file];
Triplex_Losses=csvread(read_file,9,1,[9,1,10009,6]);%(P_L1, Q_L1, NA, P_L2, Q_L2, NA)
Losses(4,1)=sum(Triplex_Losses(:,1)+Triplex_Losses(:,4))/60000;
Losses(4,2)=sum(XFMR_Losses(:,3)+XFMR_Losses(:,5))/60000;
disp(sprintf('Triplex Losses (Real) %0.0f kWh',Losses(4,1)));
disp(sprintf('Triplex Losses (Reactive) %0.0f kVAR\n',Losses(4,2)));

fclose all;