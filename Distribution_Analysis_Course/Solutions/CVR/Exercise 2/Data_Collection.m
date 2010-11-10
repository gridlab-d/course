clear all
clc
format long g
read_dir=['C:\Users\d3p313\Desktop\CVR 13 Node\'];

file=['reg1_output.csv'];
read_file = [read_dir,file];
Regulator=csvread(read_file,9,1);

Regulator_real_power=sum(Regulator(:,10))/60000; % Real power in kWh
Regulator_reactive_power=sum(Regulator(:,11))/60000;% Reactive power in kVAR
format long g

disp(sprintf('Regulator Real Power %0.0f kWh',Regulator_real_power));
disp(sprintf('Regulator Reactive Power %0.0f kWh',Regulator_reactive_power));

file=['Voltage_652.csv'];
read_file = [read_dir,file];
EOL_1=csvread(read_file,9,1);

EOL_1(:,7)=sqrt(EOL_1(:,1).^2.+EOL_1(:,2).^2); %Magnitude L1
EOL_1(:,8)=sqrt(EOL_1(:,3).^2.+EOL_1(:,4).^2); %Magnitude L2
EOL_1(:,9)=sqrt(EOL_1(:,5).^2.+EOL_1(:,6).^2); %Magnitude L12

file=['Voltage_680.csv'];
read_file = [read_dir,file];
EOL_2=csvread(read_file,9,1);

EOL_2(:,7)=sqrt(EOL_2(:,1).^2.+EOL_2(:,2).^2); %Magnitude L1
EOL_2(:,8)=sqrt(EOL_2(:,3).^2.+EOL_2(:,4).^2); %Magnitude L2
EOL_2(:,9)=sqrt(EOL_2(:,5).^2.+EOL_2(:,6).^2); %Magnitude L12

file=['Voltage_630.csv'];
read_file = [read_dir,file];
EOL_3=csvread(read_file,9,1);

EOL_2(:,7)=sqrt(EOL_3(:,1).^2.+EOL_3(:,2).^2); %Magnitude L1
EOL_3(:,8)=sqrt(EOL_3(:,3).^2.+EOL_3(:,4).^2); %Magnitude L2
EOL_3(:,9)=sqrt(EOL_3(:,5).^2.+EOL_3(:,6).^2); %Magnitude L12
file=['Voltage_671.csv'];
read_file = [read_dir,file];
EOL_4=csvread(read_file,9,1);

EOL_4(:,7)=sqrt(EOL_4(:,1).^2.+EOL_4(:,2).^2); %Magnitude L1
EOL_4(:,8)=sqrt(EOL_4(:,3).^2.+EOL_4(:,4).^2); %Magnitude L2
EOL_4(:,9)=sqrt(EOL_4(:,5).^2.+EOL_4(:,6).^2); %Magnitude L12
file=['Voltage_675.csv'];
read_file = [read_dir,file];
EOL_5=csvread(read_file,9,1);

EOL_5(:,7)=sqrt(EOL_5(:,1).^2.+EOL_5(:,2).^2); %Magnitude L1
EOL_5(:,8)=sqrt(EOL_5(:,3).^2.+EOL_5(:,4).^2); %Magnitude L2
EOL_5(:,9)=sqrt(EOL_5(:,5).^2.+EOL_5(:,6).^2); %Magnitude L12




fclose all;


