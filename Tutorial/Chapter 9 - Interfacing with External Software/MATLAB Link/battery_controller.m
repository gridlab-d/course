function [b1m1_batt_power_in] = battery_controller(b1m1_batt_soc,b1m1_batt_power_out)
% Controls battery output to keep SOC within specified range

if b1m1_batt_soc < 0.1
    b1m1_batt_power_in = -3000;
elseif b1m1_batt_soc > 0.9
    b1m1_batt_power_in = 3000;
else
    b1m1_batt_power_in = b1m1_batt_power_out;
end

%Saving out battery state
dlmwrite('battery_state.csv',[b1m1_batt_soc b1m1_batt_power_in],'-append');