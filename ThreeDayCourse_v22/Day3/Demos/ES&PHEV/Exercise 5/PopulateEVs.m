%% This will write a bunch of PHEVs for different houses

FileOut='PHEVs.glm';

PopulationRatio=0.30;

Names={	'house1B_tm_B_1_node645';
		'house2B_tm_B_2_node645';
		'house3B_tm_B_3_node645';
		'house4B_tm_B_4_node645';
		'house5B_tm_B_5_node645';
		'house6B_tm_B_6_node645';
		'house7B_tm_B_7_node645';
		'house8B_tm_B_8_node645';
		'house9B_tm_B_9_node645';
		'house10B_tm_B_10_node645';
		'house11B_tm_B_11_node645';
		'house12B_tm_B_12_node645';
		'house13B_tm_B_13_node645';
		'house14B_tm_B_14_node645';
		'house15B_tm_B_15_node645';
		'house16B_tm_B_16_node645';
		'house17B_tm_B_17_node645';
		'house18B_tm_B_18_node645';
		'house19B_tm_B_19_node645';
		'house20B_tm_B_20_node645';
		'house21B_tm_B_21_node645';
		'house22B_tm_B_22_node645';
		'house1B_tm_B_1_node646';
		'house2B_tm_B_2_node646';
		'house3B_tm_B_3_node646';
		'house4B_tm_B_4_node646';
		'house5B_tm_B_5_node646';
		'house6B_tm_B_6_node646';
		'house7B_tm_B_7_node646';
		'house8B_tm_B_8_node646';
		'house9B_tm_B_9_node646';
		'house10B_tm_B_10_node646';
		'house11B_tm_B_11_node646';
		'house12B_tm_B_12_node646';
		'house13B_tm_B_13_node646';
		'house14B_tm_B_14_node646';
		'house15B_tm_B_15_node646';
		'house16B_tm_B_16_node646';
		'house17B_tm_B_17_node646';
		'house18B_tm_B_18_node646';
		'house19B_tm_B_19_node646';
		'house1A_tm_A_1_node652';
		'house2A_tm_A_2_node652';
		'house3A_tm_A_3_node652';
		'house4A_tm_A_4_node652';
		'house5A_tm_A_5_node652';
		'house6A_tm_A_6_node652';
		'house7A_tm_A_7_node652';
		'house8A_tm_A_8_node652';
		'house9A_tm_A_9_node652';
		'house10A_tm_A_10_node652';
		'house11A_tm_A_11_node652';
		'house12A_tm_A_12_node652';
		'house13A_tm_A_13_node652';
		'house14A_tm_A_14_node652';
		'house15A_tm_A_15_node652';
		'house16A_tm_A_16_node652';
		'house17A_tm_A_17_node652';
		'house18A_tm_A_18_node652';
		'house19A_tm_A_19_node652';
		'house20A_tm_A_20_node652';
		'house21A_tm_A_21_node652'};

    
%% Write the stuff

%% Create vector
PopIncVector=rand(length(Names),1);



fOutHandle=fopen(FileOut,'wt');

for loopVals=1:length(Names)
    if (PopIncVector(loopVals)<PopulationRatio)
        fprintf(fOutHandle,'object evcharger {\n');
        fprintf(fOutHandle,'\tname evc_%s;\n',char(Names{loopVals}));
        fprintf(fOutHandle,'\tparent %s;\n',char(Names{loopVals}));
        fprintf(fOutHandle,'\tgroupid ev_dumbcharge;\n');
        fprintf(fOutHandle,'\tcharger_type LOW;\n');
        fprintf(fOutHandle,'\tcharge_at_work false;\n');
        fprintf(fOutHandle,'}\n\n');
    end
end

%Close
fclose(fOutHandle);