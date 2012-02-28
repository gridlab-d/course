clear all
clc

read_dir=['C:\PNNL Work\Current Projects\AEP-Demo\Training Course\Time-Series 2\'];

file=['reg1_output.csv'];
read_file = [read_dir,file];
Regulator=csvread(read_file,9,1);

file=['V_tm_1.csv'];
read_file = [read_dir,file];
V_House1=csvread(read_file,9,1);

V_House1(:,7)=sqrt(V_House1(:,1).^2.+V_House1(:,2).^2); %Magnitude L1
V_House1(:,8)=sqrt(V_House1(:,3).^2.+V_House1(:,4).^2); %Magnitude L2
V_House1(:,9)=sqrt(V_House1(:,5).^2.+V_House1(:,6).^2); %Magnitude L12

file=['V_tm_2.csv'];
read_file = [read_dir,file];
V_House2=csvread(read_file,9,1);

V_House2(:,7)=sqrt(V_House2(:,1).^2.+V_House2(:,2).^2); %Magnitude L1
V_House2(:,8)=sqrt(V_House2(:,3).^2.+V_House2(:,4).^2); %Magnitude L2
V_House2(:,9)=sqrt(V_House2(:,5).^2.+V_House2(:,6).^2); %Magnitude L12

fclose all

V_Diff=V_House1(:,7)-V_House2(:,7);