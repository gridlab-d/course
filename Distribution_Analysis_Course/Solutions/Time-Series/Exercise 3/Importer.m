clear all
clc

read_dir1=['C:\PNNL Work\Current Projects\AEP-Demo\Training Course\Time-Series 3\Week 1\'];
read_dir2=['C:\PNNL Work\Current Projects\AEP-Demo\Training Course\Time-Series 3\Week 2\'];

%% Read files in
file=['reg1_output.csv'];
read_file = [read_dir1,file];
Regulator_w1=csvread(read_file,9,1);

file=['V_tm_1.csv'];
read_file = [read_dir1,file];
V_House1_w1=csvread(read_file,9,1);

file=['V_tm_2.csv'];
read_file = [read_dir1,file];
V_House2_w1=csvread(read_file,9,1);

file=['reg1_output.csv'];
read_file = [read_dir2,file];
Regulator_w2=csvread(read_file,9,1);

file=['V_tm_1.csv'];
read_file = [read_dir2,file];
V_House1_w2=csvread(read_file,9,1);

file=['V_tm_2.csv'];
read_file = [read_dir2,file];
V_House2_w2=csvread(read_file,9,1);

%% Combine files

file_size=length(Regulator_w1);

for i=1:11
regulator(1:file_size,i)=Regulator_w1(1:file_size,i);
regulator(file_size+1:2*file_size,i)=Regulator_w2(1:file_size,i);
end

for i=1:6
V_House1(1:file_size,i)=V_House1_w1(1:file_size,i);
V_House1(file_size+1:2*file_size,i)=V_House1_w2(1:file_size,i);

V_House2(1:file_size,i)=V_House2_w1(1:file_size,i);
V_House2(file_size+1:2*file_size,i)=V_House2_w2(1:file_size,i);
end





%regulator(file_size+1:2*file_size,0:file_size)=Regulator_w1;

V_House1(:,7)=sqrt(V_House1(:,1).^2.+V_House1(:,2).^2); %Magnitude L1
V_House1(:,8)=sqrt(V_House1(:,3).^2.+V_House1(:,4).^2); %Magnitude L2
V_House1(:,9)=sqrt(V_House1(:,5).^2.+V_House1(:,6).^2); %Magnitude L12

V_House2(:,7)=sqrt(V_House2(:,1).^2.+V_House2(:,2).^2); %Magnitude L1
V_House2(:,8)=sqrt(V_House2(:,3).^2.+V_House2(:,4).^2); %Magnitude L2
V_House2(:,9)=sqrt(V_House2(:,5).^2.+V_House2(:,6).^2); %Magnitude L12

fclose all;


V_Diff=V_House1(:,7)-V_House2(:,7);