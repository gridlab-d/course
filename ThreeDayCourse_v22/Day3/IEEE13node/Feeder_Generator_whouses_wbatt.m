clear;
clc;

extraction_file = 'C:\Users\d3x289\Desktop\NRECA_Training\Day3\IEEE13node\IEEE_13_mod.glm';
swing_node = '650';
nom_volt = 4160; % phase-to-phase

%% Batteries? - FINISHED
use_batt = 1; %1 = add a battery at every center tap, 2 = add at substation, 0 = none
              % also creates the correct file name
              % Define the size of the battery - distributed will divide by the number of batts created
if (use_batt == 2 || use_batt == 1)
    battery_energy = 1000000; % 10 MWh
    battery_power = 250000; % 1.5 MW
end

efficiency = 0.86;   %percent
parasitic_draw = 10; %Watts

%% Markets? - FINISHED
use_market = 0; % 0 = NONE, 1 = BIDDING, 2 = PASSIVE (NON-BIDDING)
                % NOTE: using passive overrides statistics in market_info
                % and defaults to 24 hour statistics
% MARKET T/F; market name, period, mean, stdev,slider setting (range: 0.001 - 1; NOTE: do not use zero;name of the price player/schedule)
market_info = {'MARKET';'Market_1';300;'current_price_mean_24h';'current_price_stdev_24h';0.5;'ExamplePrices2.player'};

%% VVC? - FINISHED
use_vvc = 0; % 0 = NONE, 1 = TRUE
output_volt = 2401;  % voltage to regulate to - 2401::120

%% Customer Billing? - FINISHED
use_billing = 0; %0 = NONE, 1 = FLAT, 2 = TIERED, 3 = RTP (gets price from auction)

monthly_fee = 10; % $ - applies to all cases
flat_price = 0.1; % $ / kWh - also first tier price
tier_energy = 500; % kWh - the transition between 1st and 2nd tier
second_tier_price = 0.08; % $ / kWh

%% Other parameters
% ZIP fractions and their power factors
z_pf = 1;
i_pf = 1;
p_pf = 1;
zfrac = 0.3;
ifrac = 0.3;
pfrac = 1-zfrac-ifrac;

% Determines how many houses to populate (bigger avg_house = less houses)
avg_house = 10000;

use_wh = 1; % waterheaters 1 = yes, 0 = no

% Breakdown of gas vs. heat pump vs. resistance - all have AC
perc_gas = 0.3;
perc_pump = 0.7;
perc_res = 1 - perc_pump - perc_gas;
      
% simulation start and end times -> please use format: yyyy-mm-dd HH:MM:SS
start_date = '2000-08-01 00:00:00';
end_date = '2000-08-02 00:00:00';

% How often do you want to measure?
meas_interval = 60;  %applies to everything
meas = datenum(end_date) - datenum(start_date); %days between start and end
meas2 = meas*24*60*60;  %seconds between start and end dates
meas_limit = ceil(meas2/meas_interval);

% Other recorders / collectors to use
measure_losses = 0; % 1 = yes, 0 = no
dump_bills = 0; % 1 = yes, 0 = no
dump_voltage = 0; % 1 = yes, 0 = no

%% NO MODIFICATIONS AFTER HERE
if (use_batt == 0)
    file = 'IEEE_13_house';
elseif (use_batt == 1)
    file = 'IEEE_13_house_batt_dist';
elseif (use_batt == 2)
    file = 'IEEE_13_house_batt_central';
else
    error('Bad use_batt variable - must be 0, 1, or 2');
end

if (use_market == 1)
    file2 = file;
    file = [file2,'_biddingDR'];
elseif (use_market == 2)
    file2 = file;
    file = [file2,'_passiveDR'];
end

if (use_vvc == 1)
    file2 = file;
    file = [file2,'_vvc'];
end

if (use_billing == 1)
    file2 = file;
    file = [file2,'_flat_bill'];
elseif (use_billing == 2)
    file2 = file;
    file = [file2,'_tier_bill'];
elseif (use_billing == 3)
    file2 = file;
    file = [file2,'_rtp_bill'];
end

filename = [file,'.glm'];

read_file = fopen(extraction_file,'r');

no = num2str(2);
fid_name = filename;
write_file = fopen(fid_name,'w');

test = textscan(read_file,'%s %s %s %s %s %s %s %s',39000);
[c,d] = size(test);
[a,b] = size(test{1});

% Initialize pseudo-random numbers
s2 = RandStream.create('mrg32k3a','NumStreams',3,'StreamIndices',2);
RandStream.setDefaultStream(s2);

% Split up the configurations and feeder information into 2 different
% arrays
for i=1:a
    % Remove id references and replace with names as neccessary    
    if (strfind(char(test{2}{i}),'fuse:') ~= 0)
        test{2}{i} = 'fuse';
    elseif (strfind(char(test{1}{i}),'current_limit') ~= 0)
        test{2}{i} = '1000;';
    elseif (strfind(char(test{2}{i}),'load:') ~= 0)
        test{2}{i} = 'load';
    elseif (strfind(char(test{2}{i}),'triplex_meter:') ~= 0)
        test{2}{i} = 'triplex_meter';
    elseif (strfind(char(test{2}{i}),'meter:') ~= 0)
        test{2}{i} = 'meter';
    elseif (strfind(char(test{2}{i}),'triplex_node:') ~= 0)
        test{2}{i} = 'triplex_node';
    elseif (strfind(char(test{2}{i}),'node:') ~= 0)
        test{2}{i} = 'node';
    elseif (strfind(char(test{2}{i}),'switch:') ~= 0)
        test{2}{i} = 'switch';
    elseif (strfind(char(test{2}{i}),'overhead_line:') ~= 0)
        test{2}{i} = 'overhead_line';
    elseif (strfind(char(test{2}{i}),'regulator:') ~= 0)
        test{2}{i} = 'regulator';
    elseif (strfind(char(test{2}{i}),'transformer:') ~= 0)
        test{2}{i} = 'transformer';
    elseif (strfind(char(test{2}{i}),'triplex_line_conductor:') ~= 0)
        if (strfind(char(test{1}{i}),'object') ~= 0)
            m = 0;
            while (strcmp(char(test{1}{i+m}),'}') ~= 1)
                for r=1:d
                    config{r}{i+m} = test{r}{i+m};
                    test{r}{i+m} = '';
                end
                m = m+1;
            end
            if (strcmp(char(test{1}{i+m}),'}') == 1)
                config{1}{i+m} = test{1}{i+m};
                for p=2:d
                    test{p}{i+m}= '';
                    config{p}{i+m}= '';
                end
                test{1}{i+m} = '';
            end
        elseif (strfind(char(test{1}{i}),'configuration') ~= 0)
            temp = strrep(test{2}{i},'triplex_line_conductor:','');
            temp2 = strcat('triplex_line_conductor_',temp);
            test{2}{i} = temp2;
        else
            disp('I missed something. Check line 75ish, i = %d',i);
        end
    elseif (strfind(char(test{2}{i}),'triplex_line:') ~= 0)
        test{2}{i} = 'triplex_line';
    elseif (strfind(char(test{2}{i}),'underground_line:') ~= 0)
        test{2}{i} = 'underground_line';
    % Move all of the configuration files into a different array
    elseif (strfind(char(test{2}{i}),'triplex_line_configuration:') ~= 0)
        if (strfind(char(test{1}{i}),'object') ~= 0)
            m = 0;
            while (strcmp(char(test{1}{i+m}),'}') ~= 1)
                for r=1:d
                    config{r}{i+m} = test{r}{i+m};
                    test{r}{i+m} = '';
                end
                m = m+1;
            end
            if (strcmp(char(test{1}{i+m}),'}') == 1)
                config{1}{i+m} = test{1}{i+m};
                for p=2:d
                    test{p}{i+m}= '';
                    config{p}{i+m}= '';
                end
                test{1}{i+m} = '';
            end
        elseif (strfind(char(test{1}{i}),'configuration') ~= 0)
            temp = strrep(test{2}{i},'triplex_line_configuration:','');
            temp2 = strcat('triplex_line_configuration_',temp);
            test{2}{i} = temp2;
        else
            disp('I missed something. Check line 50ish, i = %d',i);
        end
    elseif (strfind(char(test{2}{i}),'line_configuration:') ~= 0)
        if (strfind(char(test{1}{i}),'object') ~= 0)
            m = 0;
            while (strcmp(char(test{1}{i+m}),'}') ~= 1)
                for r=1:d
                    config{r}{i+m} = test{r}{i+m};
                    test{r}{i+m} = '';
                end
                m = m+1;
            end
            if (strcmp(char(test{1}{i+m}),'}') == 1)
                config{1}{i+m} = test{1}{i+m};
                for p=2:d
                    test{p}{i+m}= '';
                    config{p}{i+m}= '';
                end
                test{1}{i+m} = '';
            end
        elseif (strfind(char(test{1}{i}),'configuration') ~= 0)
            temp = strrep(test{2}{i},'line_configuration:','');
            temp2 = strcat('line_configuration_',temp);
            test{2}{i} = temp2;
        else
            disp('I missed something. Check line 131ish, i = %d',i);
        end
    elseif (strfind(char(test{2}{i}),'line_spacing:') ~= 0)
        if (strfind(char(test{1}{i}),'object') ~= 0)
            m = 0;
            while (strcmp(char(test{1}{i+m}),'}') ~= 1)
                for r=1:d
                    config{r}{i+m} = test{r}{i+m};
                    test{r}{i+m} = '';
                end
                m = m+1;
            end
            if (strcmp(char(test{1}{i+m}),'}') == 1)
                config{1}{i+m} = test{1}{i+m};
                for p=2:d
                    test{p}{i+m}= '';
                    config{p}{i+m}= '';
                end
                test{1}{i+m} = '';
            end
        else
            disp('I missed something. Check line 152ish, i = %d',i);
        end
    elseif (strfind(char(test{2}{i}),'overhead_line_conductor:') ~= 0)
        if (strfind(char(test{1}{i}),'object') ~= 0)
            m = 0;
            while (strcmp(char(test{1}{i+m}),'}') ~= 1)
                for r=1:d
                    config{r}{i+m} = test{r}{i+m};
                    test{r}{i+m} = '';
                end
                m = m+1;
            end
            if (strcmp(char(test{1}{i+m}),'}') == 1)
                config{1}{i+m} = test{1}{i+m};
                for p=2:d
                    test{p}{i+m}= '';
                    config{p}{i+m}= '';
                end
                test{1}{i+m} = '';
            end
        else
            disp('I missed something. Check line 173ish, i = %d',i);
        end
    elseif (strfind(char(test{2}{i}),'underground_line_conductor:') ~= 0)
        if (strfind(char(test{1}{i}),'object') ~= 0)
            m = 0;
            while (strcmp(char(test{1}{i+m}),'}') ~= 1)
                for r=1:d
                    config{r}{i+m} = test{r}{i+m};
                    test{r}{i+m} = '';
                end
                m = m+1;
            end
            if (strcmp(char(test{1}{i+m}),'}') == 1)
                config{1}{i+m} = test{1}{i+m};
                for p=2:d
                    test{p}{i+m}= '';
                    config{p}{i+m}= '';
                end
                test{1}{i+m} = '';
            end
        else
            disp('I missed something. Check line 194ish, i = %d',i);
        end 
    elseif (strfind(char(test{2}{i}),'regulator_configuration:') ~= 0)
        if (strfind(char(test{1}{i}),'object') ~= 0)
            m = 0;
            while (strcmp(char(test{1}{i+m}),'}') ~= 1)
                for r=1:d
                    config{r}{i+m} = test{r}{i+m};
                    test{r}{i+m} = '';
                end
                m = m+1;
            end
            if (strcmp(char(test{1}{i+m}),'}') == 1)
                config{1}{i+m} = test{1}{i+m};
                for p=2:d
                    test{p}{i+m}= '';
                    config{p}{i+m}= '';
                end
                test{1}{i+m} = '';
            end
        elseif (strfind(char(test{1}{i}),'configuration') ~= 0)
            temp = strrep(test{2}{i},'regulator_configuration:','');
            temp2 = strcat('regulator_configuration_',temp);
            test{2}{i} = temp2;    
        else
            disp('I missed something. Check line 220ish, i = %d',i);
        end
        elseif (strfind(char(test{2}{i}),'transformer_configuration:') ~= 0)
        if (strfind(char(test{1}{i}),'object') ~= 0)
            m = 0;
            while (strcmp(char(test{1}{i+m}),'}') ~= 1)
                for r=1:d
                    config{r}{i+m} = test{r}{i+m};
                    test{r}{i+m} = '';
                end
                m = m+1;
            end
            if (strcmp(char(test{1}{i+m}),'}') == 1)
                config{1}{i+m} = test{1}{i+m};
                for p=2:d
                    test{p}{i+m}= '';
                    config{p}{i+m}= '';
                end
                test{1}{i+m} = '';
            end
        elseif (strfind(char(test{1}{i}),'configuration') ~= 0)
            temp = strrep(test{2}{i},'transformer_configuration:','');
            temp2 = strcat('transformer_configuration_',temp);
            test{2}{i} = temp2;
        else
            disp('I missed something. Check line 245ish, i = %d',i);
        end
    elseif (strfind(char(test{2}{i}),'SWING') ~= 0)
        for kk=1:d
            test{kk}{i}='';
        end
    end
    
    
    % Strip off all of the stuff I don't want
    if (strfind(char(test{1}{i}),'//') ~= 0)
        for n=1:d
            test{n}{i} = '';
        end
    elseif (strfind(char(test{1}{i}),'clock') ~= 0)
        for n=1:d
            test{n}{i} = '';
        end
    elseif (strfind(char(test{1}{i}),'solver_method') ~= 0)
        for n=1:d
            test{n}{i} = '';
        end
    elseif (strfind(char(test{1}{i}),'module') ~= 0)
        for n=1:d
            test{n}{i} = '';
        end
    elseif (strfind(char(test{1}{i}),'timestamp') ~= 0)
        for n=1:d
            test{n}{i} = '';
        end
    elseif (strfind(char(test{1}{i}),'stoptime') ~= 0)
        for n=1:d
            test{n}{i} = '';
        end
    elseif (strfind(char(test{1}{i}),'#set') ~= 0)
        for n=1:d
            test{n}{i} = '';
        end
    elseif (strfind(char(test{1}{i}),'timezone') ~= 0)
        for n=1:d
            test{n}{i} = '';
            test{n}{i+1} = '';
        end
    elseif (strfind(char(test{1}{i}),'default_maximum_voltage_error') ~= 0)
        for n=1:d
            test{n}{i} = '';
            test{n}{i+1} = '';
        end
    end
end

% Get rid of all those pesky spaces in the "feeder" file
nn=1;
for i=1:a
    test_me = 0;
    for j=1:d
        if (strcmp(char(test{j}{i}),'')~=0)
            test_me = test_me+1;
        end
    end
    if (test_me == d)
        %do nothing cuz the lines are blank
    elseif (strfind(char(test{3}{i}),'{') ~= 0)
        for j=1:d
            glm_final{j}{nn} = test{j}{i};
        end
        nn = nn + 1;
    elseif (strfind(char(test{1}{i}),'}') ~= 0)
        for j=1:d
            glm_final{j}{nn} = test{j}{i};
        end
        nn = nn + 1;
    else
        for j=1:d
            if (j==1)
                glm_final{j}{nn} = '     ';
            else
                glm_final{j}{nn} = test{j-1}{i};
            end
        end
        nn = nn + 1;
    end
    
end

% Get rid of those nasty blank lines in the configuration file and re-name
% the configurations to get rid of all id references and use names
mm=1;
for i=1:a-47
    test_me = 0;
    for j=1:d
        if (strcmp(char(config{j}{i}),'')~=0)
            test_me = test_me+1;
        end
    end
    if (test_me == d)
        %do nothing cuz the lines are blank
    elseif (strfind(char(config{2}{i}),'triplex_line_configuration:') ~= 0)
        for j=1:d
            if (j==3)
                config_final{j}{mm} = config{j}{i};
                temp = strrep(config{2}{i},'triplex_line_configuration:','');
                temp2 = strcat('triplex_line_configuration_',temp,';');
                config_final{j}{mm+1} = temp2;
            elseif (j==2)
                config_final{2}{mm} = 'triplex_line_configuration';
                config_final{2}{mm+1} = 'name';
            elseif (j==1)
                config_final{j}{mm} = config{j}{i};
                config_final{j}{mm+1} ='     ';
            else    
                config_final{j}{mm} = config{j}{i};
                config_final{j}{mm+1} ='';
            end
        end
        mm = mm + 2;
    elseif (strfind(char(config{2}{i}),'line_configuration:') ~= 0)
        for j=1:d
            if (j==3)
                config_final{j}{mm} = config{j}{i};
                temp = strrep(config{2}{i},'line_configuration:','');
                temp2 = strcat('line_configuration_',temp,';');
                config_final{j}{mm+1} = temp2;
            elseif (j==2)
                config_final{2}{mm} = 'line_configuration';
                config_final{2}{mm+1} = 'name';
            elseif (j==1)
                config_final{j}{mm} = config{j}{i};
                config_final{j}{mm+1} ='     ';
            else    
                config_final{j}{mm} = config{j}{i};
                config_final{j}{mm+1} ='';
            end
        end
        mm = mm + 2;
    elseif (strfind(char(config{2}{i}),'transformer_configuration:') ~= 0)
        for j=1:d
            if (j==3)
                config_final{j}{mm} = config{j}{i};
                temp = strrep(config{2}{i},'transformer_configuration:','');
                temp2 = strcat('transformer_configuration_',temp,';');
                config_final{j}{mm+1} = temp2;
            elseif (j==2)
                config_final{2}{mm} = 'transformer_configuration';
                config_final{2}{mm+1} = 'name';
            elseif (j==1)
                config_final{j}{mm} = config{j}{i};
                config_final{j}{mm+1} ='     ';
            else    
                config_final{j}{mm} = config{j}{i};
                config_final{j}{mm+1} ='';
            end
        end
        mm = mm + 2;
    elseif (strfind(char(config{1}{i}),'}') ~= 0)
        for j=1:d
            config_final{j}{mm} = config{j}{i};
        end
        mm = mm + 1;
    elseif (strfind(char(config{2}{i}),'triplex_line_conductor:') ~= 0)
        for j=1:d
            if (j==2)
                config_final{j}{mm} = 'triplex_line_conductor';
            else
                config_final{j}{mm} = config{j}{i};
            end
        end
        mm = mm + 1;
    elseif (strfind(char(config{2}{i}),'underground_line_conductor:') ~= 0)
        if (strfind(char(config{1}{i}),'object') ~= 0)
            for j=1:d
                if (j==2)
                    config_final{j}{mm} = 'underground_line_conductor';
                    config_final{j}{mm+1} = 'name';
                elseif (j==1)
                    config_final{j}{mm} = config{j}{i};
                    config_final{j}{mm+1} = '     ';
                elseif (j==3)
                    config_final{j}{mm} = config{j}{i};
                    temp = strrep(config{2}{i},'underground_line_conductor:','');
                    temp2 = strcat('underground_line_conductor_',temp,';');
                    config_final{j}{mm+1} = temp2;
                else
                    config_final{j}{mm} = config{j}{i};
                end
            end
            mm = mm + 1;
        else
            for j=1:d
                if (j==3)
                    temp = strrep(config{2}{i},'underground_line_conductor:','');
                    temp2 = strcat('underground_line_conductor_',temp);
                    config_final{j}{mm} = temp2;
                elseif (j==1)
                    config_final{j}{mm} = '     ';
                else
                    config_final{j}{mm} = config{j-1}{i};
                end
            end
        end
        mm = mm + 1;
    elseif (strfind(char(config{2}{i}),'overhead_line_conductor:') ~= 0)
        if (strfind(char(config{1}{i}),'object') ~= 0)
            for j=1:d
                if (j==2)
                    config_final{j}{mm} = 'overhead_line_conductor';
                    config_final{j}{mm+1} = 'name';
                elseif (j==1)
                    config_final{j}{mm} = config{j}{i};
                    config_final{j}{mm+1} = '     ';
                elseif (j==3)
                    config_final{j}{mm} = config{j}{i};
                    temp = strrep(config{2}{i},'overhead_line_conductor:','');
                    temp2 = strcat('overhead_line_conductor_',temp,';');
                    config_final{j}{mm+1} = temp2;
                else
                    config_final{j}{mm} = config{j}{i};
                end
            end
            mm = mm + 1;
        else
            for j=1:d
                if (j==3)
                    temp = strrep(config{2}{i},'overhead_line_conductor:','');
                    temp2 = strcat('overhead_line_conductor_',temp);
                    config_final{j}{mm} = temp2;
                elseif (j==1)
                    config_final{j}{mm} = '     ';
                else
                    config_final{j}{mm} = config{j-1}{i};
                end
            end
        end
        mm = mm + 1;
    elseif (strfind(char(config{2}{i}),'regulator_configuration:') ~= 0)
        for j=1:d
            if (j==2)
                config_final{j}{mm} = 'regulator_configuration';
                config_final{j}{mm+1} = 'name';
            elseif (j==1)
                config_final{j}{mm} = config{j}{i};
                config_final{j}{mm+1} = '     ';
            elseif (j==3)
                config_final{j}{mm} = config{j}{i};
                temp = strrep(config{2}{i},'regulator_configuration:','');
                temp2 = strcat('regulator_configuration_',temp,';');
                config_final{j}{mm+1} = temp2;
            else
                config_final{j}{mm} = config{j}{i};
            end
        end
        mm = mm + 2;
    elseif (strfind(char(config{2}{i}),'line_spacing:') ~= 0)
        if (strfind(char(config{1}{i}),'spacing') ~= 0)
            for j=1:d
                if (j==3)
                    temp = strrep(config{2}{i},'line_spacing:','');
                    temp2 = strcat('line_spacing_',temp);
                    config_final{j}{mm} = temp2;
                elseif (j==1)
                    config_final{j}{mm} = '     ';
                else
                    config_final{j}{mm} = config{j-1}{i};
                end
            end
            mm = mm + 1;
        else
            for j=1:d
                if (j==3)
                    temp = strrep(config{2}{i},'line_spacing:','');
                    temp2 = strcat('line_spacing_',temp,';');
                    config_final{j}{mm+1} = temp2;
                    config_final{j}{mm} = config{j}{i};
                elseif (j==1)
                    config_final{j}{mm+1} = '     ';
                    config_final{j}{mm} = config{j}{i};
                elseif (j==2)
                    config_final{j}{mm+1} = 'name';
                    config_final{j}{mm} = 'line_spacing';
                else
                    config_final{j}{mm} = config{j}{i};
                    config_final{j}{mm+1} = '';
                end
            end
            mm = mm + 2;
        end
    else
        for j=1:d
            if (j==1)
                config_final{j}{mm} = '     ';
            else
                config_final{j}{mm} = config{j-1}{i};
            end
        end
        mm = mm + 1;
    end
    
end

% now have all info info in config_final{8}{mm} & glm_final{8}{nn}
fprintf(write_file,'//Input feeder information for IEEE 13 node with different cases.\n');
fprintf(write_file,'//Started on 10/21/09. This version created %s.\n\n',datestr(now));

fprintf(write_file,'clock {\n');
fprintf(write_file,'     timezone PST+8PDT;\n');
fprintf(write_file,'     starttime ''%s'';\n',start_date);
fprintf(write_file,'     stoptime ''%s'';\n',end_date);
fprintf(write_file,'}\n\n');

fprintf(write_file,'#include "light_schedule.glm";\n');
fprintf(write_file,'#include "water_and_setpoint_schedule.glm";\n');

if (use_batt == 1 || use_batt == 2)
	fprintf(write_file,'#include "battery_schedule.glm";\n');
end
fprintf(write_file,'#define stylesheet=http://gridlab-d.svn.sourceforge.net/viewvc/gridlab-d/trunk/core/gridlabd-2_0\n');
fprintf(write_file,'#set minimum_timestep=60;\n');
fprintf(write_file,'#set profiler=1;\n');
fprintf(write_file,'#set relax_naming_rules=1;\n\n');

fprintf(write_file,'module tape;\n');
fprintf(write_file,'module climate;\n');
fprintf(write_file,'module residential {\n');
fprintf(write_file,'     implicit_enduses NONE;\n');
fprintf(write_file,'};\n');
if (use_batt == 1 || use_batt == 2)
	fprintf(write_file,'module generators;\n');
end
fprintf(write_file,'module powerflow {\n');
fprintf(write_file,'     solver_method FBS;\n');
fprintf(write_file,'     NR_iteration_limit 50;\n');
fprintf(write_file,'};\n\n');

if (use_market == 1)
    fprintf(write_file,'module market;\n\n');
    fprintf(write_file,'class auction {\n');
    fprintf(write_file,'    double %s;\n',market_info{4});
    fprintf(write_file,'    double %s;\n',market_info{5});
    fprintf(write_file,'}\n');

    fprintf(write_file,'object auction {\n');
    fprintf(write_file,'    name %s;\n',market_info{2});
    fprintf(write_file,'    special_mode NONE;\n');
    fprintf(write_file,'    unit kW;\n');
    fprintf(write_file,'    period %.0f;\n',market_info{3});
    fprintf(write_file,'    init_price 30;\n');
    fprintf(write_file,'    init_stdev 5;\n');
    fprintf(write_file,'    capacity_reference_object substation_transformer;\n');
    fprintf(write_file,'    capacity_reference_property power_out_real;\n');
    fprintf(write_file,'    object player {\n');
    fprintf(write_file,'        property capacity_reference_bid_price;\n');
    fprintf(write_file,'        file %s;\n',market_info{7});
    fprintf(write_file,'        loop 150;\n');
    fprintf(write_file,'    };\n');
    fprintf(write_file,'    max_capacity_reference_bid_quantity 500000;\n');
    fprintf(write_file,'    warmup 0;\n');
    fprintf(write_file,'}\n\n');
elseif (use_market == 2)
    fprintf(write_file,'module market;\n\n');
    fprintf(write_file,'object stubauction {\n');
    fprintf(write_file,'     name %s;\n',market_info{2});
    fprintf(write_file,'     period %.0f;\n',market_info{3});
    fprintf(write_file,'     object player {\n');
    fprintf(write_file,'          file %s;\n',market_info{7});
    fprintf(write_file,'          loop 150;\n');
    fprintf(write_file,'          property next.P;\n');
    fprintf(write_file,'     };\n');
    fprintf(write_file,'     object recorder {\n');
    fprintf(write_file,'          property avg24,std24,last.P;\n');
    fprintf(write_file,'          limit %.0f;\n',meas_limit);
    fprintf(write_file,'          interval %.0f;\n',meas_interval);
    fprintf(write_file,'          file price_statistics.csv;\n');
    fprintf(write_file,'     };\n');
    fprintf(write_file,'}\n\n');
end

fprintf(write_file,'object climate {\n');
fprintf(write_file,'     name "Seattle WA";\n');
fprintf(write_file,'     tmyfile "WA-Seattle.tmy2";\n');
fprintf(write_file,'     interpolate QUADRATIC;\n');
fprintf(write_file,'};\n\n');

fprintf(write_file,'//Configurations\n\n');

for i=1:(mm-1)
    if (strcmp(char(config_final{1}{i}),'}') == 1)
        fprintf(write_file,'%s %s %s %s %s %s %s %s\n\n',char(config_final{1}{i}),char(config_final{2}{i}),char(config_final{3}{i}),char(config_final{4}{i}),char(config_final{5}{i}),char(config_final{6}{i}),char(config_final{7}{i}),char(config_final{8}{i}));    
    else
        fprintf(write_file,'%s %s %s %s %s %s %s %s\n',char(config_final{1}{i}),char(config_final{2}{i}),char(config_final{3}{i}),char(config_final{4}{i}),char(config_final{5}{i}),char(config_final{6}{i}),char(config_final{7}{i}),char(config_final{8}{i}));
    end
end

fprintf(write_file,'object transformer_configuration {\n');
fprintf(write_file,'     name trans_config_to_feeder;\n');
fprintf(write_file,'     connect_type WYE_WYE;\n');
fprintf(write_file,'     install_type PADMOUNT;\n');
fprintf(write_file,'     primary_voltage 33000;\n');
fprintf(write_file,'     secondary_voltage %.3f;\n',nom_volt/sqrt(3));
fprintf(write_file,'     power_rating 5 MVA;\n');
fprintf(write_file,'     impedance 0.00033+0.0022j;\n');
fprintf(write_file,'}\n\n');

house_no_A = 1;
house_no_B = 1;
house_no_C = 1;
house_no_S = 1;
total_houses = 0;
no_of_center_taps = 0;

%% Create the feeder

if use_vvc == 1
   disp('Adding CVR Controller')
   
   fprintf(write_file,'//Volt-Var object \n');
   fprintf(write_file,'object volt_var_control {\n');
   fprintf(write_file,'        name CVVC; \n');
   fprintf(write_file,'        control_method ACTIVE; \n');
   fprintf(write_file,'        capacitor_delay 60.0; \n');
   fprintf(write_file,'        regulator_delay 60.0; \n');
   fprintf(write_file,'        desired_pf 0.99; \n');
   fprintf(write_file,'        d_max 0.8; \n');
   fprintf(write_file,'        d_min 0.1; \n');
   fprintf(write_file,'        substation_link "Reg1"; \n');
   fprintf(write_file,'        regulator_list "Reg1"; \n');
   fprintf(write_file,'        capacitor_list "CAP1,CAP2"; \n');
   fprintf(write_file,'        voltage_measurements "652,680"; \n');
   fprintf(write_file,'        maximum_voltages 3500; \n');
   fprintf(write_file,'        minimum_voltages 2000; \n');
   fprintf(write_file,'        max_vdrop 50; \n');
   fprintf(write_file,'        high_load_deadband 30; \n');
   fprintf(write_file,'        desired_voltages %.1f; \n',output_volt);
   fprintf(write_file,'        low_load_deadband 30; \n');
   fprintf(write_file,'}\n');
   fprintf(write_file,'        \n');
end

fprintf(write_file,'object node {\n');
fprintf(write_file,'     name network_node;\n');
fprintf(write_file,'     bustype SWING;\n');
fprintf(write_file,'     nominal_voltage 33000;\n');
fprintf(write_file,'     phases ABCN;\n');
fprintf(write_file,'}\n\n');

fprintf(write_file,'object transformer {\n');
fprintf(write_file,'     name substation_transformer;\n');
fprintf(write_file,'     object recorder {\n');
fprintf(write_file,'          file %s_transformer_power.csv;\n',file);
fprintf(write_file,'          interval %d;\n',meas_interval);
fprintf(write_file,'          limit %d;\n',meas_limit);
fprintf(write_file,'          property power_in_A.real,power_in_A.imag,power_in_B.real,power_in_B.imag,power_in_C.real,power_in_C.imag,power_out_A.real,power_out_A.imag,power_out_B.real,power_out_B.imag,power_out_C.real,power_out_C.imag,power_losses_A.real,power_losses_A.imag;\n');
fprintf(write_file,'     };\n');
fprintf(write_file,'     groupid Distribution_Trans;\n');
fprintf(write_file,'     from network_node;\n');
fprintf(write_file,'     to %s;\n',swing_node);
fprintf(write_file,'     phases ABCN;\n');
fprintf(write_file,'     configuration trans_config_to_feeder;\n');  
% there's an extra close bracket coming.

transformer = 0;
phase_S_houses = 0;
m = 0;
no_loads = 0;
for j=1:(nn-1)
    if (m >= j)
        continue; % this is used to skip over certain lines
    end
    if (strcmp(char(glm_final{2}{j}),'name') ~= 0)
        named_object = char(glm_final{3}{j});
        fprintf(write_file,'%s %s %s %s %s %s %s %s\n',char(glm_final{1}{j}),char(glm_final{2}{j}),char(glm_final{3}{j}),char(glm_final{4}{j}),char(glm_final{5}{j}),char(glm_final{6}{j}),char(glm_final{7}{j}),char(glm_final{8}{j}));
    elseif (strcmp(char(glm_final{2}{j}),'to') ~= 0)
        fprintf(write_file,'%s %s %s %s %s %s %s %s\n',char(glm_final{1}{j}),char(glm_final{2}{j}),char(glm_final{3}{j}),char(glm_final{4}{j}),char(glm_final{5}{j}),char(glm_final{6}{j}),char(glm_final{7}{j}),char(glm_final{8}{j}));
    elseif (strcmp(char(glm_final{2}{j}),'from') ~= 0)
        fprintf(write_file,'%s %s %s %s %s %s %s %s\n',char(glm_final{1}{j}),char(glm_final{2}{j}),char(glm_final{3}{j}),char(glm_final{4}{j}),char(glm_final{5}{j}),char(glm_final{6}{j}),char(glm_final{7}{j}),char(glm_final{8}{j}));
    elseif (strcmp(char(glm_final{2}{j}),'triplex_node') ~= 0)
        fprintf(write_file,'object triplex_meter {\n');
    elseif (strcmp(char(glm_final{2}{j}),'parent') ~= 0)
        fprintf(write_file,'%s %s %s %s %s %s %s %s\n',char(glm_final{1}{j}),char(glm_final{2}{j}),char(glm_final{3}{j}),char(glm_final{4}{j}),char(glm_final{5}{j}),char(glm_final{6}{j}),char(glm_final{7}{j}),char(glm_final{8}{j}));
    elseif (strcmp(char(glm_final{2}{j}),'transformer') ~= 0)
        fprintf(write_file,'%s %s %s %s %s %s %s %s\n',char(glm_final{1}{j}),char(glm_final{2}{j}),char(glm_final{3}{j}),char(glm_final{4}{j}),char(glm_final{5}{j}),char(glm_final{6}{j}),char(glm_final{7}{j}),char(glm_final{8}{j}));
        fprintf(write_file,'      groupid Distribution_Trans;\n');
        transformer = 1;
    elseif (strcmp(char(glm_final{2}{j}),'triplex_line') ~= 0)
        fprintf(write_file,'%s %s %s %s %s %s %s %s\n',char(glm_final{1}{j}),char(glm_final{2}{j}),char(glm_final{3}{j}),char(glm_final{4}{j}),char(glm_final{5}{j}),char(glm_final{6}{j}),char(glm_final{7}{j}),char(glm_final{8}{j}));
        fprintf(write_file,'      groupid Triplex_Line;\n');
    elseif (strcmp(char(glm_final{2}{j}),'overhead_line') ~= 0)
        fprintf(write_file,'%s %s %s %s %s %s %s %s\n',char(glm_final{1}{j}),char(glm_final{2}{j}),char(glm_final{3}{j}),char(glm_final{4}{j}),char(glm_final{5}{j}),char(glm_final{6}{j}),char(glm_final{7}{j}),char(glm_final{8}{j}));
        fprintf(write_file,'      groupid Distribution_Line;\n');
    elseif (strcmp(char(glm_final{2}{j}),'underground_line') ~= 0)
        fprintf(write_file,'%s %s %s %s %s %s %s %s\n',char(glm_final{1}{j}),char(glm_final{2}{j}),char(glm_final{3}{j}),char(glm_final{4}{j}),char(glm_final{5}{j}),char(glm_final{6}{j}),char(glm_final{7}{j}),char(glm_final{8}{j}));
        fprintf(write_file,'      groupid Distribution_Line;\n');
    elseif (strcmp(char(glm_final{2}{j}),'phases') ~= 0)
        fprintf(write_file,'%s %s %s %s %s %s %s %s\n',char(glm_final{1}{j}),char(glm_final{2}{j}),char(glm_final{3}{j}),char(glm_final{4}{j}),char(glm_final{5}{j}),char(glm_final{6}{j}),char(glm_final{7}{j}),char(glm_final{8}{j}));
        phase = char(glm_final{3}{j});
        if (findstr(phase,'S') ~= 0)
            if (transformer == 1)
%                     fprintf(write_file,'      object recorder {\n');
%                     temp = strrep(named_object,';','');
%                     fprintf(write_file,'           file trans_%s.csv;\n',temp);
%                     fprintf(write_file,'           interval 900;\n');
%                     fprintf(write_file,'           limit 100000;\n');
%                     fprintf(write_file,'           property power_out.real,power_out.imag;\n');
%                     fprintf(write_file,'      };\n');
                transformer = 0;
            end
        end
    elseif (strcmp(char(glm_final{2}{j}),'load') ~= 0)
        fprintf(write_file,'\nobject node {\n');
        m = j;
        no_houses_A = 0;
        no_houses_B = 0;
        no_houses_C = 0;
        
        while (strcmp(char(glm_final{1}{m}),'}') == 0)
            if (strcmp(char(glm_final{2}{m}),'constant_power_A') ~= 0)
                bb_real = real(str2num(glm_final{3}{m}));
                bb_imag = imag(str2num(glm_final{3}{m}));

                no_houses_A = no_houses_A + ceil(sqrt(bb_real^2 + bb_imag^2) / avg_house);
            elseif (strcmp(char(glm_final{2}{m}),'constant_power_B') ~= 0)
                bb_real = real(str2num(glm_final{3}{m}));
                bb_imag = imag(str2num(glm_final{3}{m}));

                no_houses_B = no_houses_B + ceil(sqrt(bb_real^2 + bb_imag^2) / avg_house);
            elseif (strcmp(char(glm_final{2}{m}),'constant_power_C') ~= 0)
                bb_real = real(str2num(glm_final{3}{m}));
                bb_imag = imag(str2num(glm_final{3}{m}));

                no_houses_C = no_houses_C + ceil(sqrt(bb_real^2 + bb_imag^2) / avg_house);
            elseif (strcmp(char(glm_final{2}{m}),'constant_impedance_A') ~= 0)
                bb_real = real(str2num(glm_final{3}{m}));
                bb_imag = imag(str2num(glm_final{3}{m}));
                
                S_A = abs(nom_volt^2 / 3 / (bb_real * 1i*bb_imag));

                no_houses_A = no_houses_A + ceil(S_A / avg_house);
            elseif (strcmp(char(glm_final{2}{m}),'constant_impedance_B') ~= 0)
                bb_real = real(str2num(glm_final{3}{m}));
                bb_imag = imag(str2num(glm_final{3}{m}));
                
                S_B = abs(nom_volt^2 / 3 / (bb_real * 1i*bb_imag));

                no_houses_B = no_houses_B + ceil(S_B / avg_house);
            elseif (strcmp(char(glm_final{2}{m}),'constant_impedance_C') ~= 0)
                bb_real = real(str2num(glm_final{3}{m}));
                bb_imag = imag(str2num(glm_final{3}{m}));
                
                S_C = abs(nom_volt^2 / 3 / (bb_real * 1i*bb_imag));

                no_houses_C = no_houses_C + ceil(S_C / avg_house);
            elseif (strcmp(char(glm_final{2}{m}),'constant_current_A') ~= 0)
                bb_real = real(str2num(glm_final{3}{m}));
                bb_imag = imag(str2num(glm_final{3}{m}));
                
                S_A = abs(nom_volt * (bb_real * 1i*bb_imag));

                no_houses_A = no_houses_A + ceil(S_A / avg_house);
            elseif (strcmp(char(glm_final{2}{m}),'constant_current_B') ~= 0)
                bb_real = real(str2num(glm_final{3}{m}));
                bb_imag = imag(str2num(glm_final{3}{m}));
                
                S_B = abs(nom_volt * (bb_real * 1i*bb_imag));

                no_houses_B = no_houses_B + ceil(S_B / avg_house);
            elseif (strcmp(char(glm_final{2}{m}),'constant_current_C') ~= 0)
                bb_real = real(str2num(glm_final{3}{m}));
                bb_imag = imag(str2num(glm_final{3}{m}));
                
                S_C = abs(nom_volt * (bb_real * 1i*bb_imag));

                no_houses_C = no_houses_C + ceil(S_C / avg_house);
            elseif (strcmp(char(glm_final{2}{m}),'name') ~= 0)
                parent_name = char(glm_final{3}{m});
                fprintf(write_file,'%s %s %s %s %s %s %s %s\n',char(glm_final{1}{m}),char(glm_final{2}{m}),char(glm_final{3}{m}),char(glm_final{4}{m}),char(glm_final{5}{m}),char(glm_final{6}{m}),char(glm_final{7}{m}),char(glm_final{8}{m}));
            elseif (strcmp(char(glm_final{2}{m}),'phases') ~= 0)
                parent_phase = char(glm_final{3}{m});
                fprintf(write_file,'%s %s %s %s %s %s %s %s\n',char(glm_final{1}{m}),char(glm_final{2}{m}),char(glm_final{3}{m}),char(glm_final{4}{m}),char(glm_final{5}{m}),char(glm_final{6}{m}),char(glm_final{7}{m}),char(glm_final{8}{m}));
            elseif (strcmp(char(glm_final{2}{m}),'nominal_voltage') ~= 0)
                fprintf(write_file,'%s %s %s %s %s %s %s %s\n',char(glm_final{1}{m}),char(glm_final{2}{m}),char(glm_final{3}{m}),char(glm_final{4}{m}),char(glm_final{5}{m}),char(glm_final{6}{m}),char(glm_final{7}{m}),char(glm_final{8}{m}));        
            elseif (strcmp(char(glm_final{2}{m}),'parent') ~= 0)
                fprintf(write_file,'%s %s %s %s %s %s %s %s\n',char(glm_final{1}{m}),char(glm_final{2}{m}),char(glm_final{3}{m}),char(glm_final{4}{m}),char(glm_final{5}{m}),char(glm_final{6}{m}),char(glm_final{7}{m}),char(glm_final{8}{m}));        
            end   
          
            m = m + 1;
        end
        fprintf(write_file,'}\n\n');
        no_loads = no_loads + 1;
        
        load_houses{1}{no_loads} = no_houses_A;
        load_houses{2}{no_loads} = no_houses_B;
        load_houses{3}{no_loads} = no_houses_C;
        load_houses{4}{no_loads} = parent_name;
        load_houses{5}{no_loads} = parent_phase;         
            
    elseif (strcmp(char(glm_final{2}{j}),'power_1') ~= 0)
        bb_real = real(str2num(glm_final{3}{j}));
        bb_imag = imag(str2num(glm_final{3}{j}));

        bb = sqrt(bb_real^2 + bb_imag^2);
        no_of_houses = ceil(bb/avg_house);

        if (no_of_houses > 0)
            parent = ['f',num2str(i),'_',named_object];

            no_of_center_taps = no_of_center_taps + 1;
            center_taps{no_of_center_taps,1} = parent;

            phase_S_houses{house_no_S,1} = num2str(no_of_houses);
            phase_S_houses{house_no_S,2} = parent;
            phase_S_houses{house_no_S,3} = phase;
            house_no_S = house_no_S + 1;

            total_houses = total_houses + no_of_houses;
        end
    else
        fprintf(write_file,'%s %s %s %s %s %s %s %s\n',char(glm_final{1}{j}),char(glm_final{2}{j}),char(glm_final{3}{j}),char(glm_final{4}{j}),char(glm_final{5}{j}),char(glm_final{6}{j}),char(glm_final{7}{j}),char(glm_final{8}{j}));
    end
end

if (phase_S_houses ~= 0)
    [aS,bS] = size(phase_S_houses);

    for jj=1:aS
        feed = feed + 1; 
        parent = char(phase_S_houses(jj,2));
        no_houses = str2num(char(phase_S_houses(jj,1)));
        phase = char(phase_S_houses(jj,3));

        for kk=1:no_houses
            fprintf(write_file,'object house {\n');
            fprintf(write_file,'     parent %s\n',parent);
            fprintf(write_file,'     name house%d_%s\n',kk,parent);
                floor_area = 2100+300*randn(1);
            fprintf(write_file,'     floor_area %.0f;\n',floor_area);
            
            skew_value = 1800*randn(1);
            if (skew_value < -3600)
                skew_value = -3600;
            elseif (skew_value > 3600)
                skew_value = 3600;
            end
            
            fprintf(write_file,'     schedule_skew %.0f;\n',skew_value);
            
            heat_type = rand(1);
            h_COP = 2+1.5*rand(1);
            
            if (heat_type <= perc_gas)
                fprintf(write_file,'     heating_system_type GAS;\n');
            elseif (heat_type <= (perc_gas + perc_pump))
                fprintf(write_file,'     heating_system_type HEAT_PUMP;\n');                   
                fprintf(write_file,'     heating_COP %.1f;\n',h_COP);
            else
                fprintf(write_file,'     heating_system_type RESISTANCE;\n');
            end

            fprintf(write_file,'     cooling_system_type ELECTRIC;\n');
            
                cooling_set = ceil(8*rand(1));           
                heating_set = ceil(8*rand(1));
                
            if (use_market == 0)
                fprintf(write_file,'     cooling_setpoint cooling%d*1;\n',cooling_set);
                fprintf(write_file,'     heating_setpoint heating%d*1;\n',heating_set);
            elseif (use_market == 1)
                if (heat_type <= (perc_gas + perc_pump) && heat_type > perc_gas)
                    fprintf(write_file,'\n     object controller {\n');   
                    fprintf(write_file,'           schedule_skew %.0f;\n',skew_value);
                    fprintf(write_file,'           market %s;\n',market_info{2});
                    fprintf(write_file,'           bid_mode ON;\n');
                    fprintf(write_file,'           control_mode DOUBLE_RAMP;\n');
                    fprintf(write_file,'           resolve_mode DEADBAND;\n');
                    fprintf(write_file,'           slider_setting_heat %.3f;\n',market_info{6});
                    fprintf(write_file,'           slider_setting_cool %.3f;\n',market_info{6});
                    fprintf(write_file,'           heating_base_setpoint heating%d*1;\n',heating_set);
                    fprintf(write_file,'           cooling_base_setpoint cooling%d*1;\n',cooling_set);
                    fprintf(write_file,'           period %.0f;\n',market_info{3});
                    fprintf(write_file,'           average_target %s;\n',market_info{4});
                    fprintf(write_file,'           standard_deviation_target %s;\n',market_info{5});
                    fprintf(write_file,'           target air_temperature;\n');
                    fprintf(write_file,'           heating_setpoint heating_setpoint;\n');
                    fprintf(write_file,'           heating_demand last_heating_load;\n');
                    fprintf(write_file,'           cooling_setpoint cooling_setpoint;\n');
                    fprintf(write_file,'           cooling_demand last_cooling_load;\n');
                    fprintf(write_file,'           deadband thermostat_deadband;\n');
                    fprintf(write_file,'           total hvac_load;\n');
                    fprintf(write_file,'           load hvac_load;\n');
                    fprintf(write_file,'           state power_state;\n');
                    fprintf(write_file,'       };\n\n');
                else
                    fprintf(write_file,'\n     object controller {\n');
                    fprintf(write_file,'           schedule_skew %.0f;\n',skew_value);
                    fprintf(write_file,'           market %s;\n',market_info{2});
                    fprintf(write_file,'           bid_mode ON;\n');
                    fprintf(write_file,'           control_mode RAMP;\n');
                    fprintf(write_file,'           slider_setting_cool %.3f;\n',market_info{6});
                    fprintf(write_file,'           cooling_base_setpoint cooling%d*1;\n',cooling_set);
                    fprintf(write_file,'           period %.0f;\n',market_info{3});
                    fprintf(write_file,'           average_target %s;\n',market_info{4});
                    fprintf(write_file,'           standard_deviation_target %s;\n',market_info{5});
                    fprintf(write_file,'           target air_temperature;\n');
                    fprintf(write_file,'           cooling_setpoint cooling_setpoint;\n');
                    fprintf(write_file,'           cooling_demand last_cooling_load;\n');
                    fprintf(write_file,'           deadband thermostat_deadband;\n');
                    fprintf(write_file,'           total hvac_load;\n');
                    fprintf(write_file,'           load hvac_load;\n');
                    fprintf(write_file,'           state power_state;\n');
                    fprintf(write_file,'       };\n\n');
                end
            elseif (use_market == 2)
                cool_slider = market_info{6};
                sigma_cool = 1 + (3 - 1)*(1 - cool_slider);
 
                cool_high_limit = 5;
                range_high_cool = cool_high_limit - cool_high_limit*(1-cool_slider);
                k_high_cool = sigma_cool / range_high_cool;

                cool_low_limit = -3;
                range_low_cool = cool_low_limit - cool_low_limit*(1-cool_slider);
                k_low_cool = -sigma_cool / range_low_cool;
                
                fprintf(write_file,'          cooling_setpoint cooling%d*1;\n',cooling_set);
                fprintf(write_file,'          object passive_controller {\n');
                fprintf(write_file,'               base_setpoint cooling%d*1;\n',cooling_set);
				fprintf(write_file,'               schedule_skew %.0f;\n',skew_value);
                fprintf(write_file,'               control_mode RAMP;\n');
                fprintf(write_file,'               sensitivity 1;\n');  
                fprintf(write_file,'               expectation_obj %s;\n',market_info{2});
                fprintf(write_file,'               expectation_prop avg24;\n');
                fprintf(write_file,'               setpoint_prop cooling_setpoint;\n');
                fprintf(write_file,'               state_prop override;\n');
                fprintf(write_file,'               observation_obj %s;\n',market_info{2});
                fprintf(write_file,'               observation_prop next.P;\n');
                fprintf(write_file,'               mean_observation_prop avg24;\n');
                fprintf(write_file,'               stdev_observation_prop std24;\n\n');
                fprintf(write_file,'               // Standard deviation %.2f\n',sigma_cool);
                fprintf(write_file,'               range_low %.3f;\n',range_low_cool);
                fprintf(write_file,'               range_high %.3f;\n',range_high_cool);
                fprintf(write_file,'               ramp_low %.3f;\n',k_low_cool);
                fprintf(write_file,'               ramp_high %.3f;\n',k_high_cool);
                fprintf(write_file,'          };\n\n');
                
                if (heat_type > perc_gas) %we have electric/HP heat
                    heat_slider = market_info{6};
                    
                    sigma_heat = -1 + (-3 + 1)*(1 - heat_slider);
 
                    heat_high_limit = 3;
                    range_high_heat = heat_high_limit - heat_high_limit*(1-heat_slider);
                    k_high_heat = sigma_heat / range_high_heat;

                    heat_low_limit = -5;
                    range_low_heat = heat_low_limit - heat_low_limit*(1-heat_slider);
                    k_low_heat = -sigma_heat / range_low_heat;
                    
                    fprintf(write_file,'          heating_setpoint heating%d*1;\n',heating_set);
                    fprintf(write_file,'          object passive_controller {\n');
                    fprintf(write_file,'               base_setpoint heating%d*1;\n',heating_set);
					fprintf(write_file,'               schedule_skew %.0f;\n',skew_value);
                    fprintf(write_file,'               control_mode RAMP;\n');
                    fprintf(write_file,'               sensitivity 1;\n');  
                    fprintf(write_file,'               expectation_obj %s;\n',market_info{2});
                    fprintf(write_file,'               expectation_prop avg24;\n');
                    fprintf(write_file,'               setpoint_prop heating_setpoint;\n');
                    fprintf(write_file,'               state_prop override;\n');
                    fprintf(write_file,'               observation_obj %s;\n',market_info{2});
                    fprintf(write_file,'               observation_prop next.P;\n');
                    fprintf(write_file,'               mean_observation_prop avg24;\n');
                    fprintf(write_file,'               stdev_observation_prop std24;\n\n');
                    fprintf(write_file,'               // Standard deviation %.2f\n',sigma_heat);
                    fprintf(write_file,'               range_low %.3f;\n',range_low_heat);
                    fprintf(write_file,'               range_high %.3f;\n',range_high_heat);
                    fprintf(write_file,'               ramp_low %.3f;\n',k_low_heat);
                    fprintf(write_file,'               ramp_high %.3f;\n',k_high_heat);
                    fprintf(write_file,'          };\n\n');
                end
            end
            
                therm_int = ceil(4 + 1*randn(1));
                if (therm_int > 6)
                    therm_int = 6;
                elseif (therm_int < 1)
                    therm_int = 1;
                end
                
            fprintf(write_file,'     thermal_integrity_level %d;\n',therm_int);
            fprintf(write_file,'     air_temperature 70;\n');
            fprintf(write_file,'     mass_temperature 70;\n');
                 c_COP = 2.5 + 1.5*rand(1);
            fprintf(write_file,'     cooling_COP %.1f;\n',c_COP);
            
            fprintf(write_file,'     object ZIPload {\n');
                load_magnitude = floor_area/1.8/1000 + 0.2*randn(1);            
            fprintf(write_file,'           schedule_skew %.0f;\n',skew_value);
            fprintf(write_file,'           base_power LIGHTS*%.2f;\n',load_magnitude);
            fprintf(write_file,'           heatgain_fraction 0.9;\n');
            fprintf(write_file,'           power_pf %.3f;\n',p_pf);
            fprintf(write_file,'           current_pf %.3f;\n',i_pf);
            fprintf(write_file,'           impedance_pf %.3f;\n',z_pf);
            fprintf(write_file,'           impedance_fraction %f;\n',zfrac);
            fprintf(write_file,'           current_fraction %f;\n',ifrac);
            fprintf(write_file,'           power_fraction %f;\n',pfrac);
            fprintf(write_file,'     };\n');

            heat_element = 4.5 + 0.25*randn(1);
            tank_set = 132 + 4*randn(1);
            therm_dead = 2 + 4*rand(1);
            tank_UA = 2 + 2*rand(1);
            water_sch = ceil(20*rand(1));
            
            if (heat_type > perc_gas && use_wh == 1)
                fprintf(write_file,'     object waterheater {\n');        
                fprintf(write_file,'          schedule_skew %.0f;\n',skew_value);
                fprintf(write_file,'          tank_volume 50;\n');                  
                fprintf(write_file,'          heating_element_capacity %.1f kW;\n',heat_element);                    
                fprintf(write_file,'          tank_setpoint %.1f;\n',tank_set);
                fprintf(write_file,'          temperature 135;\n');                   
                fprintf(write_file,'          thermostat_deadband %.1f;\n',therm_dead);
                fprintf(write_file,'          location INSIDE;\n');                    
                fprintf(write_file,'          tank_UA %.1f;\n',tank_UA);                  
                fprintf(write_file,'          demand water%d*1;\n',water_sch);
                fprintf(write_file,'     };\n\n');
            end

            fprintf(write_file,'}\n\n'); %end house
        end   
    end
end

if (no_loads ~= 0)
    total_houses2 = 0;
    no_of_center_taps2 = 0;
    
    fprintf(write_file,'object triplex_line_configuration {\n');
    fprintf(write_file,'      name trip_line_config;\n');
    fprintf(write_file,'      conductor_1 object triplex_line_conductor {\n');
    fprintf(write_file,'            resistance 0.97;\n');
    fprintf(write_file,'            geometric_mean_radius 0.01111;\n');
    fprintf(write_file,'            };\n');
    fprintf(write_file,'      conductor_2 object triplex_line_conductor {\n');
    fprintf(write_file,'            resistance 0.97;\n');
    fprintf(write_file,'            geometric_mean_radius 0.01111;\n');
    fprintf(write_file,'            };\n');
    fprintf(write_file,'      conductor_N object triplex_line_conductor {\n');
    fprintf(write_file,'            resistance 0.97;\n');
    fprintf(write_file,'            geometric_mean_radius 0.01111;\n');
    fprintf(write_file,'            };\n');
    fprintf(write_file,'      insulation_thickness 0.08;\n');
    fprintf(write_file,'      diameter 0.368;\n');
    fprintf(write_file,'}\n');
    
    [r1,r2] = size(load_houses{5});
    for iii = 1:r2
        for jjj = 1:3
            if (jjj==1 && load_houses{1}{iii} ~= 0)
                phase = 'A';
            elseif (jjj==2 && load_houses{2}{iii} ~= 0)
                phase = 'B';
            elseif (jjj==3 && load_houses{3}{iii} ~= 0)
                phase = 'C';
            end
            
            if load_houses{jjj}{iii} ~= 0
                no_houses = load_houses{jjj}{iii};
                main_parent = load_houses{4}{iii};
                
                total_houses2 = total_houses2 + no_houses;
                no_of_center_taps2 = no_of_center_taps2 + 1;
                
                fprintf(write_file,'object transformer {\n');
                fprintf(write_file,'       name CTTF_%s_%s\n',phase,main_parent);
                fprintf(write_file,'       phases %sS;\n',phase);
                fprintf(write_file,'       from %s\n',main_parent);
                fprintf(write_file,'       to tn_%s_%s\n',phase,main_parent);
                fprintf(write_file,'       configuration object transformer_configuration {\n');
                fprintf(write_file,'            connect_type SINGLE_PHASE_CENTER_TAPPED;\n');
                fprintf(write_file,'            install_type POLETOP;\n');
                fprintf(write_file,'            shunt_impedance 10000+10000j;\n');
                fprintf(write_file,'            primary_voltage %.3f;\n',nom_volt/sqrt(3));
                fprintf(write_file,'            secondary_voltage 120;\n');
                fprintf(write_file,'            power%s_rating %.0f kVA;\n',phase,no_houses*5);
                fprintf(write_file,'            impedance 0.00033+0.0022j;\n');
                fprintf(write_file,'       };\n');
                fprintf(write_file,'       groupid %s;\n','Distribution_Trans');
                fprintf(write_file,'}\n\n');
           
                nnn = ['tn_',phase,'_',main_parent];
                center_taps2{no_of_center_taps2,1} = nnn;
                
                fprintf(write_file,'object triplex_meter {\n');
                fprintf(write_file,'       name %s\n',nnn);
                fprintf(write_file,'       phases %sS;\n',phase);
                fprintf(write_file,'       nominal_voltage 120;\n');
                fprintf(write_file,'}\n\n');
                
                for kk=1:no_houses
                    
                    skew_value = 1800*randn(1);
                    if (skew_value < -3600)
                        skew_value = -3600;
                    elseif (skew_value > 3600)
                        skew_value = 3600;
                    end
            
                    fprintf(write_file,'object triplex_line {\n');
                    fprintf(write_file,'       name tl_%s_%d_%s\n',phase,kk,main_parent);
                    fprintf(write_file,'       phases %sS;\n',phase);
                    fprintf(write_file,'       from tn_%s_%s\n',phase,main_parent);
                        new_parent = ['tm_',phase','_',num2str(kk),'_',main_parent];
                    fprintf(write_file,'       to %s\n',new_parent);
                    fprintf(write_file,'       length %.2f;\n',10+10*rand(1));
                    fprintf(write_file,'       configuration trip_line_config;\n');
                    fprintf(write_file,'       groupid %s;\n','Triplex_Line');
                    fprintf(write_file,'}\n\n');

                    fprintf(write_file,'object triplex_meter {\n');
                    fprintf(write_file,'       name %s\n',new_parent);
                    fprintf(write_file,'       phases %sS;\n',phase);
                    fprintf(write_file,'       nominal_voltage 120;\n');
                    fprintf(write_file,'       groupid %s;\n','House_Meter');
                    
                    if (use_billing == 1) % flat
                        fprintf(write_file,'     bill_mode UNIFORM;\n');
                        fprintf(write_file,'     price %f;\n',flat_price);
                        fprintf(write_file,'     bill_day 1;\n');
                        fprintf(write_file,'     monthly_fee %f;\n',monthly_fee);
                    elseif (use_billing == 2) %tiered
                        fprintf(write_file,'     bill_mode TIERED;\n');
                        fprintf(write_file,'     price %f;\n',flat_price);
                        fprintf(write_file,'     first_tier_price %f;\n',second_tier_price);
                        fprintf(write_file,'     first_tier_energy %f;\n',tier_energy);
                        fprintf(write_file,'     bill_day 1;\n');
                        fprintf(write_file,'     monthly_fee %f;\n',monthly_fee);
                    elseif (use_billing == 3) %RTP
                        fprintf(write_file,'     bill_mode HOURLY;\n');
                        fprintf(write_file,'     power_market %s;\n',market_info{2});
                        fprintf(write_file,'     bill_day 1;\n');
                        fprintf(write_file,'     monthly_fee %d;\n',monthly_fee);
                    end
                    
                    fprintf(write_file,'}\n\n');
                
                    fprintf(write_file,'object house {\n');
                    fprintf(write_file,'     parent %s\n',new_parent);
                    fprintf(write_file,'     name house%d%s_%s\n',kk,phase,new_parent);
                        floor_area = 2100+300*randn(1);
                    fprintf(write_file,'     floor_area %.0f;\n',floor_area);
                    fprintf(write_file,'     schedule_skew %.0f;\n',skew_value);
                    
                    heat_type = rand(1);
                    h_COP = 2+1.5*rand(1);

                    if (heat_type <= perc_gas)
                        fprintf(write_file,'     heating_system_type GAS;\n');
                    elseif (heat_type <= (perc_gas + perc_pump))
                        fprintf(write_file,'     heating_system_type HEAT_PUMP;\n');                          
                        fprintf(write_file,'     heating_COP %.1f;\n',h_COP);
                    else
                        fprintf(write_file,'     heating_system_type RESISTANCE;\n');
                    end

                    fprintf(write_file,'     cooling_system_type ELECTRIC;\n');

                        cooling_set = ceil(8*rand(1));           
                        heating_set = ceil(8*rand(1));

                    if (use_market == 0)
                        fprintf(write_file,'     cooling_setpoint cooling%d*1;\n',cooling_set);
                        fprintf(write_file,'     heating_setpoint heating%d*1;\n',heating_set);
                    elseif (use_market == 1)
                        if (heat_type > perc_gas)
                            fprintf(write_file,'\n     object controller {\n');
                            fprintf(write_file,'           schedule_skew %.0f;\n',skew_value);
                            fprintf(write_file,'           market %s;\n',market_info{2});
                            fprintf(write_file,'           bid_mode ON;\n');
                            fprintf(write_file,'           control_mode DOUBLE_RAMP;\n');
                            fprintf(write_file,'           resolve_mode DEADBAND;\n');
                            fprintf(write_file,'           slider_setting_heat %.3f;\n',market_info{6});
                            fprintf(write_file,'           slider_setting_cool %.3f;\n',market_info{6});
                            fprintf(write_file,'           heating_base_setpoint heating%d*1;\n',heating_set);
                            fprintf(write_file,'           cooling_base_setpoint cooling%d*1;\n',cooling_set);
                            fprintf(write_file,'           period %.0f;\n',market_info{3});
                            fprintf(write_file,'           average_target %s;\n',market_info{4});
                            fprintf(write_file,'           standard_deviation_target %s;\n',market_info{5});
                            fprintf(write_file,'           target air_temperature;\n');
                            fprintf(write_file,'           heating_setpoint heating_setpoint;\n');
                            fprintf(write_file,'           heating_demand last_heating_load;\n');
                            fprintf(write_file,'           cooling_setpoint cooling_setpoint;\n');
                            fprintf(write_file,'           cooling_demand last_cooling_load;\n');
                            fprintf(write_file,'           deadband thermostat_deadband;\n');
                            fprintf(write_file,'           total hvac_load;\n');
                            fprintf(write_file,'           load hvac_load;\n');
                            fprintf(write_file,'           state power_state;\n');
                            fprintf(write_file,'       };\n\n');
                        else
                            fprintf(write_file,'       heating_setpoint heating%d*1;\n',heating_set);
                            fprintf(write_file,'\n     object controller {\n');
                            fprintf(write_file,'           schedule_skew %.0f;\n',skew_value);
                            fprintf(write_file,'           market %s;\n',market_info{2});
                            fprintf(write_file,'           bid_mode ON;\n');
                            fprintf(write_file,'           control_mode RAMP;\n');
                            fprintf(write_file,'           slider_setting %.3f;\n',market_info{6});
                            fprintf(write_file,'           base_setpoint cooling%d*1;\n',cooling_set);
                            fprintf(write_file,'           period %.0f;\n',market_info{3});
                            fprintf(write_file,'           average_target %s;\n',market_info{4});
                            fprintf(write_file,'           standard_deviation_target %s;\n',market_info{5});
                            fprintf(write_file,'           target air_temperature;\n');
                            fprintf(write_file,'           setpoint cooling_setpoint;\n');
                            fprintf(write_file,'           demand last_cooling_load;\n');
                            fprintf(write_file,'           total hvac_load;\n');
                            fprintf(write_file,'           load hvac_load;\n');
                            fprintf(write_file,'           state power_state;\n');
                            fprintf(write_file,'           range_high 5;\n');
                            fprintf(write_file,'           range_low -3;\n');
                            fprintf(write_file,'       };\n\n');
                        end
                    elseif (use_market == 2)
                        cool_slider = market_info{6};
                        sigma_cool = 1 + (3 - 1)*(1 - cool_slider);

                        cool_high_limit = 5;
                        range_high_cool = cool_high_limit - cool_high_limit*(1-cool_slider);
                        k_high_cool = sigma_cool / range_high_cool;

                        cool_low_limit = -3;
                        range_low_cool = cool_low_limit - cool_low_limit*(1-cool_slider);
                        k_low_cool = -sigma_cool / range_low_cool;

                        fprintf(write_file,'          cooling_setpoint cooling%d*1;\n',cooling_set);
                        fprintf(write_file,'          object passive_controller {\n');
						fprintf(write_file,'               schedule_skew %.0f;\n',skew_value);
                        fprintf(write_file,'               base_setpoint cooling%d*1;\n',cooling_set);
                        fprintf(write_file,'               control_mode RAMP;\n');
                        fprintf(write_file,'               sensitivity 1;\n');  
                        fprintf(write_file,'               expectation_obj %s;\n',market_info{2});
                        fprintf(write_file,'               expectation_prop avg24;\n');
                        fprintf(write_file,'               setpoint_prop cooling_setpoint;\n');
                        fprintf(write_file,'               state_prop override;\n');
                        fprintf(write_file,'               observation_obj %s;\n',market_info{2});
                        fprintf(write_file,'               observation_prop next.P;\n');
                        fprintf(write_file,'               mean_observation_prop avg24;\n');
                        fprintf(write_file,'               stdev_observation_prop std24;\n\n');
                        fprintf(write_file,'               // Standard deviation %.2f\n',sigma_cool);
                        fprintf(write_file,'               range_low %.3f;\n',range_low_cool);
                        fprintf(write_file,'               range_high %.3f;\n',range_high_cool);
                        fprintf(write_file,'               ramp_low %.3f;\n',k_low_cool);
                        fprintf(write_file,'               ramp_high %.3f;\n',k_high_cool);
                        fprintf(write_file,'          };\n\n');

                        if (heat_type > perc_gas) %we have electric/HP heat
                            heat_slider = market_info{6};

                            sigma_heat = -1 + (-3 + 1)*(1 - heat_slider);

                            heat_high_limit = 3;
                            range_high_heat = heat_high_limit - heat_high_limit*(1-heat_slider);
                            k_high_heat = sigma_heat / range_high_heat;

                            heat_low_limit = -5;
                            range_low_heat = heat_low_limit - heat_low_limit*(1-heat_slider);
                            k_low_heat = -sigma_heat / range_low_heat;

                            fprintf(write_file,'          heating_setpoint heating%d*1;\n',heating_set);
                            fprintf(write_file,'          object passive_controller {\n');
							fprintf(write_file,'               schedule_skew %.0f;\n',skew_value);
                            fprintf(write_file,'               base_setpoint heating%d*1;\n',heating_set);
                            fprintf(write_file,'               control_mode RAMP;\n');
                            fprintf(write_file,'               sensitivity 1;\n');  
                            fprintf(write_file,'               expectation_obj %s;\n',market_info{2});
                            fprintf(write_file,'               expectation_prop avg24;\n');
                            fprintf(write_file,'               setpoint_prop heating_setpoint;\n');
                            fprintf(write_file,'               state_prop override;\n');
                            fprintf(write_file,'               observation_obj %s;\n',market_info{2});
                            fprintf(write_file,'               observation_prop next.P;\n');
                            fprintf(write_file,'               mean_observation_prop avg24;\n');
                            fprintf(write_file,'               stdev_observation_prop std24;\n\n');
                            fprintf(write_file,'               // Standard deviation %.2f\n',sigma_heat);
                            fprintf(write_file,'               range_low %.3f;\n',range_low_heat);
                            fprintf(write_file,'               range_high %.3f;\n',range_high_heat);
                            fprintf(write_file,'               ramp_low %.3f;\n',k_low_heat);
                            fprintf(write_file,'               ramp_high %.3f;\n',k_high_heat);
                            fprintf(write_file,'          };\n\n');
                        end
                    end

                        therm_int = ceil(4 + 1*randn(1));
                        if (therm_int > 6)
                            therm_int = 6;
                        elseif (therm_int < 1)
                            therm_int = 1;
                        end
                    fprintf(write_file,'     thermal_integrity_level %d;\n',therm_int);
                    fprintf(write_file,'     air_temperature 70;\n');
                    fprintf(write_file,'     mass_temperature 70;\n');
                         c_COP = 2.5 + 1.5*rand(1);
                    fprintf(write_file,'     cooling_COP %.1f;\n',c_COP);

                    fprintf(write_file,'     object ZIPload {\n');
                        load_magnitude = floor_area/1.8/1000 + 0.2*randn(1);
                    fprintf(write_file,'           base_power LIGHTS*%.2f;\n',load_magnitude);
                    fprintf(write_file,'           schedule_skew %.0f;\n',skew_value);
                    fprintf(write_file,'           heatgain_fraction 0.9;\n');
                    fprintf(write_file,'           power_pf %.3f;\n',p_pf);
                    fprintf(write_file,'           current_pf %.3f;\n',i_pf);
                    fprintf(write_file,'           impedance_pf %.3f;\n',z_pf);
                    fprintf(write_file,'           impedance_fraction %f;\n',zfrac);
                    fprintf(write_file,'           current_fraction %f;\n',ifrac);
                    fprintf(write_file,'           power_fraction %f;\n',pfrac);
                    fprintf(write_file,'     };\n');

                    heat_element = 4.5 + 0.25*randn(1);
                    tank_set = 132 + 4*randn(1);
                    therm_dead = 2 + 4*rand(1);
                    tank_UA = 2 + 2*rand(1);
                    water_sch = ceil(20*rand(1));
                    
                    if (heat_type > perc_gas && use_wh == 1)
                        fprintf(write_file,'     object waterheater {\n');
                        fprintf(write_file,'          schedule_skew %.0f;\n',skew_value);
                        fprintf(write_file,'          tank_volume 50;\n');                           
                        fprintf(write_file,'          heating_element_capacity %.1f kW;\n',heat_element);                          
                        fprintf(write_file,'          tank_setpoint %.1f;\n',tank_set);
                        fprintf(write_file,'          temperature 135;\n');                         
                        fprintf(write_file,'          thermostat_deadband %.1f;\n',therm_dead);
                        fprintf(write_file,'          location INSIDE;\n');                        
                        fprintf(write_file,'          tank_UA %.1f;\n',tank_UA);                         
                        fprintf(write_file,'          demand water%d*1;\n',water_sch);
                        
                        if ( use_market ~= 0 )
                            fprintf(write_file,'          object passive_controller {\n');
                            fprintf(write_file,'          	  period %.0f;\n',market_info{3});
                            fprintf(write_file,'              control_mode PROBABILITY_OFF;\n');
                            fprintf(write_file,'          	  distribution_type NORMAL;\n');
                            fprintf(write_file,'          	  observation_object %s;\n',market_info{2});
                            fprintf(write_file,'          	  expectation_object %s;\n',market_info{2});                           
                            fprintf(write_file,'          	  comfort_level %.2f;\n',2*market_info{6});
                            fprintf(write_file,'          	  state_property override;\n');
                            
                            if (use_market == 1)
                                fprintf(write_file,'          	  observation_property current_market.clearing_price;\n');
                                fprintf(write_file,'          	  stdev_observation_property %s;\n',market_info{5});
                                fprintf(write_file,'          	  expectation_property %s;\n',market_info{4});
                            else
                                fprintf(write_file,'          	  observation_property next.P;\n');
                                fprintf(write_file,'          	  stdev_observation_property std24;\n');
                                fprintf(write_file,'          	  expectation_property avg24;\n');
                            end
                            
                            fprintf(write_file,'          };\n');                
                        end
                        fprintf(write_file,'     };\n\n');
                    end

                    fprintf(write_file,'}\n\n'); %end house               
                end
            end
        end
    end
end

if (use_batt == 2) %centralized
    fprintf(write_file,'object meter {\n');
	fprintf(write_file,'     parent %s;\n',swing_node);
    fprintf(write_file,'     name battery_meter;\n');
    fprintf(write_file,'     nominal_voltage %.2f;\n',nom_volt/sqrt(3));
    fprintf(write_file,'     phases ABCN;\n');
    fprintf(write_file,'}\n\n');
    
    fprintf(write_file,'object battery {\n');
    fprintf(write_file,'	 parent battery_meter;\n');
    fprintf(write_file,'	 name battery_central;\n');
    fprintf(write_file,'     generator_mode CONSTANT_PQ;\n');
    fprintf(write_file,'     V_Max 8000;\n');
    fprintf(write_file,'     I_Max 250;\n');
    fprintf(write_file,'     P_Max %.0f;\n',battery_power);
    fprintf(write_file,'     E_Max %.0f;\n',battery_energy);
    fprintf(write_file,'     base_efficiency %.2f;\n',efficiency);
    fprintf(write_file,'     parasitic_power_draw %.0f W;\n',parasitic_draw*(no_of_center_taps+no_of_center_taps2));
    fprintf(write_file,'     power_type DC;\n');
    fprintf(write_file,'     generator_status ONLINE;\n');
    fprintf(write_file,'     Energy %.0f;\n',battery_energy); 
    fprintf(write_file,'	 scheduled_power battery_schedule*%.0f;\n',battery_power);
    fprintf(write_file,'	 power_factor 1.0;\n');
    fprintf(write_file,'}\n\n');
elseif (use_batt == 1) %decentralized
    for jj=1:no_of_center_taps
        parent = center_taps{jj,1};
        
        fprintf(write_file,'object battery {\n');
        fprintf(write_file,'	 parent %s\n',parent);
        fprintf(write_file,'	 name battery_%.0f;\n',jj);
        fprintf(write_file,'     generator_mode CONSTANT_PQ;\n');
        fprintf(write_file,'     V_Max 260;\n');
        fprintf(write_file,'     I_Max 100;\n');
		fprintf(write_file,'     P_Max %.0f;\n',battery_power/no_of_center_taps);
		fprintf(write_file,'     E_Max %.0f;\n',battery_energy/no_of_center_taps);
		fprintf(write_file,'     base_efficiency %.2f;\n',efficiency);
		fprintf(write_file,'     parasitic_power_draw %.0f W;\n',parasitic_draw);
		fprintf(write_file,'     power_type DC;\n');
		fprintf(write_file,'     generator_status ONLINE;\n');
		fprintf(write_file,'     Energy %.0f;\n',battery_energy/no_of_center_taps); 
		fprintf(write_file,'	 scheduled_power battery_schedule*%.0f;\n',battery_power/no_of_center_taps);
        fprintf(write_file,'	 power_factor 1.0;\n');
        fprintf(write_file,'}\n\n');
    end
    
    for jj=1:no_of_center_taps2
        parent = center_taps2{jj,1};
        
        fprintf(write_file,'object battery {\n');
        fprintf(write_file,'	 parent %s\n',parent);
        fprintf(write_file,'	 name battery_%.0f;\n',jj);
        fprintf(write_file,'     generator_mode CONSTANT_PQ;\n');
        fprintf(write_file,'     V_Max 260;\n');
        fprintf(write_file,'     I_Max 100;\n');
		fprintf(write_file,'     P_Max %.0f;\n',battery_power/no_of_center_taps2);
		fprintf(write_file,'     E_Max %.0f;\n',battery_energy/no_of_center_taps2);
		fprintf(write_file,'     base_efficiency %.2f;\n',efficiency);
		fprintf(write_file,'     parasitic_power_draw %.0f W;\n',parasitic_draw);
		fprintf(write_file,'     power_type DC;\n');
		fprintf(write_file,'     generator_status ONLINE;\n');
		fprintf(write_file,'     Energy %.0f;\n',battery_energy/no_of_center_taps2); 
		fprintf(write_file,'	 scheduled_power battery_schedule*%.0f;\n',battery_power/no_of_center_taps2);
        fprintf(write_file,'	 power_factor 1.0;\n');
        fprintf(write_file,'}\n\n');
    end
end

if (measure_losses == 1)
    fprintf(write_file,'object collector {\n');
    fprintf(write_file,'     group "class=overhead_line AND groupid=Distribution_Line";\n');
    fprintf(write_file,'     property sum(power_losses_A.real),sum(power_losses_A.imag),sum(power_losses_B.real),sum(power_losses_B.imag),sum(power_losses_C.real),sum(power_losses_C.imag);\n');
    fprintf(write_file,'     interval %d;\n',meas_interval);
    fprintf(write_file,'     limit %d;\n',meas_limit);
    fprintf(write_file,'     file %s_Distribution_OHLine_Losses.csv;\n',file);
    fprintf(write_file,'}\n\n');

    fprintf(write_file,'object collector {\n');
    fprintf(write_file,'     group "class=underground_line AND groupid=Distribution_Line";\n');
    fprintf(write_file,'     property sum(power_losses_A.real),sum(power_losses_A.imag),sum(power_losses_B.real),sum(power_losses_B.imag),sum(power_losses_C.real),sum(power_losses_C.imag);\n');
    fprintf(write_file,'     interval %d;\n',meas_interval);
    fprintf(write_file,'     limit %d;\n',meas_limit);
    fprintf(write_file,'     file %s_Distribution_UGLine_Losses.csv;\n',file);
    fprintf(write_file,'}\n\n');

    fprintf(write_file,'object collector {\n');
    fprintf(write_file,'     group "class=transformer AND groupid=Distribution_Trans";\n');
    fprintf(write_file,'     property sum(power_losses_A.real),sum(power_losses_A.imag),sum(power_losses_B.real),sum(power_losses_B.imag),sum(power_losses_C.real),sum(power_losses_C.imag);\n');
    fprintf(write_file,'     interval %d;\n',meas_interval);
    fprintf(write_file,'     limit %d;\n',meas_limit);
    fprintf(write_file,'     file %s_Distribution_Trans_Losses.csv;\n',file);
    fprintf(write_file,'}\n\n');

    fprintf(write_file,'object collector {\n');
    fprintf(write_file,'     group "class=triplex_line AND groupid=Triplex_Line";\n');
    fprintf(write_file,'     property sum(power_losses_A.real),sum(power_losses_A.imag),sum(power_losses_B.real),sum(power_losses_B.imag),sum(power_losses_C.real),sum(power_losses_C.imag);\n');
    fprintf(write_file,'     interval %d;\n',meas_interval);
    fprintf(write_file,'     limit %d;\n',meas_limit);
    fprintf(write_file,'     file %s_Triplex_Line_Losses.csv;\n',file);
    fprintf(write_file,'}\n\n');
end

if (use_billing ~= 0)
    fprintf(write_file,'object collector {\n');
    fprintf(write_file,'     group "class=triplex_meter AND groupid=House_Meter";\n');
    fprintf(write_file,'     property sum(measured_power.real),avg(monthly_bill),avg(monthly_energy);\n');
    fprintf(write_file,'     interval %d;\n',meas_interval);
    fprintf(write_file,'     limit %d;\n',meas_limit);
    fprintf(write_file,'     file %s_Triplex_Meters.csv;\n',file);
    fprintf(write_file,'}\n\n');
end

if (use_vvc ~= 0)
    fprintf(write_file,'object recorder {\n');
    fprintf(write_file,'     parent Reg1;\n');
    fprintf(write_file,'     file reg1_output.csv;\n');
    fprintf(write_file,'     interval %d;\n',meas_interval);
    fprintf(write_file,'     limit %d;\n',meas_limit);
    fprintf(write_file,'     property tap_A,tap_B,tap_C,power_in_A.real,power_in_A.imag,power_in_B.real,power_in_B.imag,power_in_C.real,power_in_C.imag,power_in.real,power_in.imag;\n');
    fprintf(write_file,'};\n');

    fprintf(write_file,'object recorder {\n');
    fprintf(write_file,'     parent 630;\n');
    fprintf(write_file,'     file Voltage_630.csv;\n');
    fprintf(write_file,'     interval %d;\n',meas_interval);
    fprintf(write_file,'     limit %d;\n',meas_limit);
    fprintf(write_file,'     property voltage_A.real,voltage_A.imag,voltage_B.real,voltage_B.imag,voltage_C.real,voltage_C.imag;\n');
    fprintf(write_file,'};\n');

    fprintf(write_file,'object recorder {\n');
    fprintf(write_file,'     parent 671;\n');
    fprintf(write_file,'     file Voltage_671.csv;\n');
    fprintf(write_file,'     interval %d;\n',meas_interval);
    fprintf(write_file,'     limit %d;\n',meas_limit);
    fprintf(write_file,'     property voltage_A.real,voltage_A.imag,voltage_B.real,voltage_B.imag,voltage_C.real,voltage_C.imag;\n');
    fprintf(write_file,'};\n');

    fprintf(write_file,'object recorder {\n');
    fprintf(write_file,'     parent 675;\n');
    fprintf(write_file,'     file Voltage_675.csv;\n');
    fprintf(write_file,'     interval %d;\n',meas_interval);
    fprintf(write_file,'     limit %d;\n',meas_limit);
    fprintf(write_file,'     property voltage_A.real,voltage_A.imag,voltage_B.real,voltage_B.imag,voltage_C.real,voltage_C.imag;\n');
    fprintf(write_file,'};\n');

    fprintf(write_file,'object recorder {\n');
    fprintf(write_file,'     parent 652;\n');
    fprintf(write_file,'     file Voltage_652.csv;\n');
    fprintf(write_file,'     interval %d;\n',meas_interval);
    fprintf(write_file,'     limit %d;\n',meas_limit);
    fprintf(write_file,'     property voltage_A.real,voltage_A.imag,voltage_B.real,voltage_B.imag,voltage_C.real,voltage_C.imag;\n');
    fprintf(write_file,'};\n');

    fprintf(write_file,'object recorder {\n');
    fprintf(write_file,'     parent 680;\n');
    fprintf(write_file,'     file Voltage_680.csv;\n');
    fprintf(write_file,'     interval %d;\n',meas_interval);
    fprintf(write_file,'     limit %d;\n',meas_limit);
    fprintf(write_file,'     property voltage_A.real,voltage_A.imag,voltage_B.real,voltage_B.imag,voltage_C.real,voltage_C.imag;\n');
    fprintf(write_file,'};\n');

    fprintf(write_file,'object recorder {\n');
    fprintf(write_file,'     parent CAP1;\n');
    fprintf(write_file,'     file capacitor1_output.csv;\n');
    fprintf(write_file,'     interval %d;\n',meas_interval);
    fprintf(write_file,'     limit %d;\n',meas_limit);
    fprintf(write_file,'     property switchA,switchB,switchC;\n');
    fprintf(write_file,'};\n');

    fprintf(write_file,'object recorder {\n');
    fprintf(write_file,'     parent CAP2;\n');
    fprintf(write_file,'     file capacitor2_output.csv;\n');
    fprintf(write_file,'     interval %d;\n',meas_interval);
    fprintf(write_file,'     limit %d;\n',meas_limit);
    fprintf(write_file,'     property switchA,switchB,switchC;\n');
    fprintf(write_file,'};\n');
end

if (dump_bills ~= 0)
    fprintf(write_file,'object billdump {\n');
    fprintf(write_file,'     runtime ''%s'';\n',end_date);
    fprintf(write_file,'     filename BillDump_%s.csv;\n',file);
    fprintf(write_file,'     group House_Meter;\n');
    fprintf(write_file,'}\n\n');
end
if (dump_voltage ~= 0)
    fprintf(write_file,'object voltdump {\n');
    fprintf(write_file,'     filename VoltDump_%s.csv;\n',file);
    fprintf(write_file,'     runtime ''%s'';\n',end_date);
    fprintf(write_file,'}\n\n');
end
    
disp('Back off man, I am done');
fclose('all');
