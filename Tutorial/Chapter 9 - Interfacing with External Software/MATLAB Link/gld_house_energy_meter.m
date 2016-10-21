function gld_house_energy_meter(b1m1_house_power)
%Sums power to calculate energy
% GLD reports power in watts
% GLD is reporting a value every five seconds.
if b1m1_batt_soc < 0.1
    b1m1_batt_power = 3000;
elseif b1m1_batt_soc > 0.9
    b1m1_batt_power = 3000;
else
     b1m1_batt_power = 
end