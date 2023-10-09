%% Data Import

%Import the cell SOC OCV curve and measured temperature data
%Unfortunately temps were only being logged on 4 of 6 cells
SOCOCV = importdata("Fine Murata VTC6 SOC OCV Curve.txt");
%Data for pt1 goes until row 721
nofan_6S_data = importdata("../Data/Test 1 - 200 250W 6S5P/tempzener pt1.mat");
%Data for part 2 goes until row 2538
nofan_6S_data_pt2 = importdata("../Data/Test 1 - 200 250W 6S5P/tempzener pt2.mat");
singlefan_6S_data = importdata("../Data/Test 2 - 250W 6S5P Fan/zenervoltage_withfan.mat");

singlefan_6S_data.Vdiode1 = movmean(singlefan_6S_data.voltageA2, 10);
singlefan_6S_data.Vdiode2 = movmean(singlefan_6S_data.voltageA3, 10);
singlefan_6S_data.Vdiode3 = movmean(singlefan_6S_data.voltageA4, 10);
singlefan_6S_data.Vdiode4 = movmean(singlefan_6S_data.voltageA5, 10);

% Import the temp-voltage lookup table from the Enepaq datasheet
% Column 1 is temp (degC) and column 2 is voltage
enepaq_lookup_table = [0 2.17;5 2.11;10 2.05;15 1.99;20 1.92;25 1.86;30 1.80;35 1.74;40 1.68;45 1.63;50 1.59;55 1.55;60 1.51];

singlefan_6S_data.T1 = interp1(enepaq_lookup_table(:,2),enepaq_lookup_table(:,1),singlefan_6S_data.Vdiode1);
singlefan_6S_data.T2 = interp1(enepaq_lookup_table(:,2),enepaq_lookup_table(:,1),singlefan_6S_data.Vdiode2);
singlefan_6S_data.T3 = interp1(enepaq_lookup_table(:,2),enepaq_lookup_table(:,1),singlefan_6S_data.Vdiode3);
singlefan_6S_data.T4 = interp1(enepaq_lookup_table(:,2),enepaq_lookup_table(:,1),singlefan_6S_data.Vdiode4);
singlefan_6S_data.Tavg = (singlefan_6S_data.T1+singlefan_6S_data.T2+singlefan_6S_data.T3+singlefan_6S_data.T4)/4;

%% Setup Parameters

S_count = 6;                                    % Series configuration of bricks
Pcount = 5;                                     % Parallel count of cells per brick
R_cell = 0.0225;                                % Cell internal resistance in Ohm
V_initial = 24;                                 % Initial cell voltage
V_final = 16.4;                                 % Final cell voltage
Cp_batt = 960;                                  % Cell heat capacity in J/(kg*K)
m_batt = 46.6/1000;                             % Cell mass in kilograms
A_ht = pi * 0.018 * 0.0535 / 2;                 % Area of cell that transfers heat in m^2
T_amb = 27.5;                                   % Ambient temperature based on starting temp of cells

OCV_cell = V_initial/6;                         % Initial cell voltage assuming all are balanced
V_cell = OCV_cell;                              % Set initial V_cell to OCV
[val, idx] = min(abs(OCV_cell - SOCOCV(:,2)));  % Retrieve the index of the closest cell voltage
SOC = SOCOCV(idx,1);                            % Determine initial SOC based on the SOC-OCV curve
Q_batt = SOC * 3000;                            % Calculate the initial cell capacity in mAh
R_pack = S_count / Pcount * R_cell;             % Determine the pack resistance
T_cell_adiabatic = T_amb;                       % Adiabatic cell temperature
T_cell_nat = T_amb;                             % Natural convective cooled cell temperature
T_cell_for = T_amb;                             % Forced convective cooled cell temperature
htc_nat = 5;                                    % Natural convective cooling coefficient
htc_for = 20;                                   % Forced convective cooling coefficient

time = 1;                                       % Start at time t=1
predicted_data = zeros(6);                        % Initialize matrix for storing time, heat gen, and temperature
%% Heat Transfer Calculations

while V_cell > V_final/6
    % Calculating the pack current
    I_pack = (S_count*OCV_cell - sqrt((S_count*OCV_cell)^2 - 4*R_pack*250))/(2*R_pack);
    V_cell = OCV_cell - I_pack/Pcount * R_cell;

    %Calculating the cell heat generation, heat accumulation and heat loss
    Qgen_cell = R_cell*(I_pack/Pcount)^2;               % Heat generated (W)
    Qnat_cell = htc_nat * A_ht * (T_cell_nat - T_amb);  % Natural convective cooling (W)
    Qfor_cell = htc_for * A_ht * (T_cell_for - T_amb);  % Natural convective cooling (W)
    Qaccum_cell_adiabatic = Qgen_cell * 1;              % Heat accumulated in the cell under adiabatic conditions (J)
    Qaccum_cell_nat = (Qgen_cell - Qnat_cell) * 1;      % Heat accumulated in the cell with natural cooling (J) 
    Qaccum_cell_for = (Qgen_cell - Qfor_cell) * 1;      % Heat accumulated in the cell with forced cooling (J)
    
    %Calculating the cell temperature in degrees Celsius
    T_cell_adiabatic = T_cell_adiabatic + Qaccum_cell_adiabatic/(Cp_batt*m_batt);
    T_cell_nat = T_cell_nat + Qaccum_cell_nat/(Cp_batt*m_batt);
    T_cell_for = T_cell_for + Qaccum_cell_for/(Cp_batt*m_batt);

    %Storing results in the table
    predicted_data(time,1) = time;
    predicted_data(time,2) = I_pack;
    predicted_data(time,3) = Qgen_cell;
    predicted_data(time,4) = T_cell_adiabatic;
    predicted_data(time,5) = T_cell_nat;
    predicted_data(time,6) = T_cell_for;
    
    %Calculating the remaining charge and OCV of the cells
    Q_batt = Q_batt - I_pack/(3.6*Pcount);
    SOC = Q_batt/3000;
    [value, idx] = min(abs(SOCOCV(:,1)-SOC));
    OCV_cell = SOCOCV(idx,2);
    
    %Incrementing time steps of 1 second
    time = time + 1;
end

%% Plots

current_figure = figure('visible','off','Units','centimeters','Position',[0 0 20 15]);
hold on
plot(predicted_data(:,1), predicted_data(:,4),'Color','r');     % Plot adiabatic cell temperature
plot(predicted_data(:,1), predicted_data(:,5),'Color','y');     % Plot natural cooled cell temperature
plot(predicted_data(:,1), predicted_data(:,6),'Color','c');     % Plot force cooled cell temperature
plot(predicted_data(:,1),singlefan_6S_data.Tavg(1:length(predicted_data)),'ro','MarkerFaceColor','w');                  % Plot experimental average cell temperature
title("6S5P VTC6 250W Heat Transfer Coefficient Estimation")
xlabel("Time (seconds)")
ylabel('Temperature (degrees Celsius)')
saveas(current_figure, "Heat Transfer Coefficient Estimation.png")
