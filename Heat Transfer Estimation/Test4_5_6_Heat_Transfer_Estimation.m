%% Data Import
%Test 4 was conducted with 15A of constant current on a single 4S segment
%with an 80mm fan for cooling

%Test 5 was conducted with 15A of constant current on two 2S segments with
%a single 80mm fan for cooling

%Test 6 was conducted with 15A of constant current on two 2S segments with
%an 80mm intake fan and a 60mm exhaust fan

% Import the cell SOC OCV curve
SOCOCV = importdata("Fine Murata VTC6 SOC OCV Curve.txt");

% Importing Test 4 data for single segment with 80mm fan
test4data = importdata("../Data\Test 4 - 15A 4S5P Fan\4S_80mmfan_15A_CC.mat");

% Importing Test 5 for dual segment with 80mm fan
test5data = importdata("../Data/Test 5 - 15A 4S5P Dual Segment Fan/tempzener15A4S.mat");

%Importing Test 6 for dual segment with 80mm intake and 60mm exhaust fans
test6data = importdata("../Data/Test 6 - 15A 4S5P Dual Segment Dual Fan/tempzener15A4Soutlet.mat");

% Taking the moving mean of the diode voltage to smooth out noise
% For Test 4
test4data.Vdiode1 = movmean(test4data.voltageA2, 10);
test4data.Vdiode2 = movmean(test4data.voltageA3, 10);
test4data.Vdiode3 = movmean(test4data.voltageA4, 10);
test4data.Vdiode4 = movmean(test4data.voltageA5, 10);

% For Test 5
test5data.Vdiode1 = movmean(test5data.voltageA2, 10);
test5data.Vdiode2 = movmean(test5data.voltageA3, 10);
test5data.Vdiode3 = movmean(test5data.voltageA4, 10);
test5data.Vdiode4 = movmean(test5data.voltageA5, 10);

%For Test 6
test6data.Vdiode1 = movmean(test6data.voltageA2, 10);
test6data.Vdiode2 = movmean(test6data.voltageA3, 10);
test6data.Vdiode3 = movmean(test6data.voltageA4, 10);
test6data.Vdiode4 = movmean(test6data.voltageA5, 10);

% Import the temp-voltage lookup table from the Enepaq datasheet
% Column 1 is temp (degC) and column 2 is voltage
enepaq_lookup_table = [0 2.17;5 2.11;10 2.05;15 1.99;20 1.92;25 1.86;30 1.80;35 1.74;40 1.68;45 1.63;50 1.59;55 1.55;60 1.51];

% Use the lookup table and interpolate to determine the cell temperatures
% For Test 4
test4data.T1 = interp1(enepaq_lookup_table(:,2),enepaq_lookup_table(:,1),test4data.Vdiode1);
test4data.T2 = interp1(enepaq_lookup_table(:,2),enepaq_lookup_table(:,1),test4data.Vdiode2);
test4data.T3 = interp1(enepaq_lookup_table(:,2),enepaq_lookup_table(:,1),test4data.Vdiode3);
test4data.T4 = interp1(enepaq_lookup_table(:,2),enepaq_lookup_table(:,1),test4data.Vdiode4);
test4data.Tavg = (test4data.T1 + test4data.T2 + test4data.T3 + test4data.T4)/4;
test4data.Tmax = max([test4data.T1 test4data.T2 test4data.T3 test4data.T4],[],2);

% For Test 5
test5data.T1 = interp1(enepaq_lookup_table(:,2),enepaq_lookup_table(:,1),test5data.Vdiode1);
test5data.T2 = interp1(enepaq_lookup_table(:,2),enepaq_lookup_table(:,1),test5data.Vdiode2);
test5data.T3 = interp1(enepaq_lookup_table(:,2),enepaq_lookup_table(:,1),test5data.Vdiode3);
test5data.T4 = interp1(enepaq_lookup_table(:,2),enepaq_lookup_table(:,1),test5data.Vdiode4);
test5data.Tavg = (test5data.T1 + test5data.T2 + test5data.T3 + test5data.T4)/4;
test5data.Tmax = max([test5data.T1 test5data.T2 test5data.T3 test5data.T4],[],2);

%For Test 6
test6data.T1 = interp1(enepaq_lookup_table(:,2),enepaq_lookup_table(:,1),test6data.Vdiode1);
test6data.T2 = interp1(enepaq_lookup_table(:,2),enepaq_lookup_table(:,1),test6data.Vdiode2);
test6data.T3 = interp1(enepaq_lookup_table(:,2),enepaq_lookup_table(:,1),test6data.Vdiode3);
test6data.T4 = interp1(enepaq_lookup_table(:,2),enepaq_lookup_table(:,1),test6data.Vdiode4);
test6data.Tavg = (test6data.T1 + test6data.T2 + test6data.T3 + test6data.T4)/4;
test6data.Tmax = max([test6data.T1 test6data.T2 test6data.T3 test6data.T4],[],2);

%% Setup Parameters

S_count = 6;                                    % Series configuration of bricks
Pcount = 5;                                     % Parallel count of cells per brick
R_cell = 0.025;                                 % Cell internal resistance in Ohm
V_initial = 24;                                 % Initial cell voltage
V_final = 16.4;                                 % Final cell voltage
Cp_batt = 960;                                  % Cell heat capacity in J/(kg*K)
m_batt = 46.6/1000;                             % Cell mass in kilograms
A_ht = pi * 0.018 * 0.0535 / 2;                 % Area of cell that transfers heat in m^2
T_amb_45 = 23.3;                                % Ambient temperature for tests 4 and 5
T_amb_6 = 21.1;                                 % Ambient temperature for test 6
mdot_air = 0.075;                                % Mass flow rate of air in kg/s
Cp_air = 1005;                                  % Specific heat capacity of air in J/(kg*K)

OCV_cell = V_initial/6;                         % Initial cell voltage assuming all are balanced
V_cell = OCV_cell;                              % Set initial V_cell to OCV
I_pack = 15;                                    % Pack current drawn in A
[val, idx] = min(abs(OCV_cell - SOCOCV(:,2)));  % Retrieve the index of the closest cell voltage
SOC = SOCOCV(idx,1);                            % Determine initial SOC based on the SOC-OCV curve
Q_batt = SOC * 3000;                            % Calculate the initial cell capacity in mAh
R_pack = S_count / Pcount * R_cell;             % Determine the pack resistance
T_cell_4 = T_amb_45;                            % Test 4 cell temperature
T_cell_5_1 = T_amb_45;                          % Test 5 cell temperature segment 1
T_cell_5_2 = T_amb_45;                          % Test 5 cell temperature segment 2
T_cell_6_1 = T_amb_6;                           % Test 6 cell temperature segment 1
T_cell_6_2 = T_amb_6;                           % Test 6 cell temperature segment 2
T_air_between_5 = T_amb_45;                     % Test 5 air temperature between the two segments
T_air_between_6 = T_amb_6;                       % Test 6 air temperature between the two segments
htc_for = 50;                                   % Forced convective cooling coefficient

time = 1;                                       % Start at time t=1
predicted_data = zeros(9);                      % Initialize matrix for storing time, heat gen, and temperature
%% Heat Transfer Calculations

while V_cell > V_final/6
    V_cell = OCV_cell - I_pack/Pcount * R_cell;

    %Calculating the cell heat generation
    Qgen_cell = R_cell*(I_pack/Pcount)^2;                   % Heat generated (W)
    
    %Test 4 convective cooling, accumulated heat and cell temperature
    Qcool_cell_4 = htc_for * A_ht * (T_cell_4 - T_amb_45);      % Heat lost through convective cooling (W)
    Qaccum_cell_4 = (Qgen_cell - Qcool_cell_4) * 1;             % Heat accumulated in the cell with forced cooling (J)
    T_cell_4 = T_cell_4 + Qaccum_cell_4/(Cp_batt*m_batt);

    %Test 5 convective cooling, accumulated heat and cell temperature
    %The _1 and _2 notation indicates cells in the first or second segment
    Qcool_cell_5_1 = htc_for * A_ht * (T_cell_5_1 - T_amb_45);      % Heat lost through convective cooling (W)
    Qaccum_cell_5_1 = (Qgen_cell - Qcool_cell_5_1) * 1;             % Heat accumulated in the cell with forced cooling (J)
    T_cell_5_1 = T_cell_5_1 + Qaccum_cell_5_1/(Cp_batt*m_batt);
    
    %Calculating the air temperature rise after the 1st segment for test 5
    T_air_between_5 = T_amb_45 + Qcool_cell_5_1/(mdot_air*Cp_air);

    %Calculating convective cooling, accumulated heat, cell temp in the 2nd segment
    Qcool_cell_5_2 = htc_for * A_ht * (T_cell_5_2 - T_air_between_5);   % Heat lost through convective cooling (W)
    Qaccum_cell_5_2 = (Qgen_cell - Qcool_cell_5_2) * 1;                 % Heat accumulated in the cell with forced cooling (J)
    T_cell_5_2 = T_cell_5_2 + Qaccum_cell_5_2/(Cp_batt*m_batt);
    
    %Test 6 convective cooling, accumulated heat and cell temperature
    %The _1 and _2 notation indicates cells in the first or second segment
    Qcool_cell_6_1 = htc_for * A_ht * (T_cell_6_1 - T_amb_6);      % Heat lost through convective cooling (W)
    Qaccum_cell_6_1 = (Qgen_cell - Qcool_cell_6_1) * 1;             % Heat accumulated in the cell with forced cooling (J)
    T_cell_6_1 = T_cell_6_1 + Qaccum_cell_6_1/(Cp_batt*m_batt);
    
    %Calculating the air temperature rise after the 1st segment for test 5
    T_air_between_6 = T_amb_6 + Qcool_cell_6_1/(mdot_air*Cp_air);

    %Calculating convective cooling, accumulated heat, cell temp in the 2nd segment
    Qcool_cell_6_2 = htc_for * A_ht * (T_cell_6_2 - T_air_between_6);   % Heat lost through convective cooling (W)
    Qaccum_cell_6_2 = (Qgen_cell - Qcool_cell_6_2) * 1;                 % Heat accumulated in the cell with forced cooling (J)
    T_cell_6_2 = T_cell_6_2 + Qaccum_cell_6_2/(Cp_batt*m_batt);

    %Storing results in the table
    predicted_data(time,1) = time;
    predicted_data(time,2) = Qgen_cell;
    predicted_data(time,3) = T_cell_4;
    predicted_data(time,4) = T_cell_5_1;
    predicted_data(time,5) = T_air_between_5;
    predicted_data(time,6) = T_cell_5_2;
    predicted_data(time,7) = T_cell_6_1;
    predicted_data(time,8) = T_air_between_6;
    predicted_data(time,9) = T_cell_6_2;


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
plot(predicted_data(:,1), test4data.Tavg(1:length(predicted_data)),'bo','MarkerFaceColor','w','MarkerSize',1);
plot(predicted_data(:,1), test5data.Tavg(1:length(predicted_data)),'go','MarkerFaceColor','w','MarkerSize',1);
plot(predicted_data(:,1), test5data.Tmax(1:length(predicted_data)),'ro','MarkerFaceColor','w','MarkerSize',1);
plot(predicted_data(:,1), predicted_data(:,3),'Color','b');     % Plot test 4 cell temperature
plot(predicted_data(:,1), predicted_data(:,4),'Color','g');     % Plot test 5 segment 1 cell temperature
plot(predicted_data(:,1), predicted_data(:,6),'Color','r');     % Plot test 5 segment 2 cell temperature
title("4S5P VTC6 15A Single vs. Dual Segment Temp Estimation")
xlabel("Time (seconds)")
ylabel('Temperature (degrees Celsius)')
saveas(current_figure, "Test 4,5 Heat Transfer Estimation.png")
hold off

current_figure = figure('visible','off','Units','centimeters','Position',[0 0 20 15]);
hold on
plot(predicted_data(:,1), test5data.Tmax(1:length(predicted_data)), 'ro','MarkerFaceColor','w','MarkerSize',1);
plot(predicted_data(:,1), test6data.Tmax(1:length(predicted_data)),'bo','MarkerFaceColor','w','MarkerSize',1);
plot(predicted_data(:,1), predicted_data(:,6),'Color','r');     % Plot test 5 segment 2 temperature
plot(predicted_data(:,1), predicted_data(:,9),'Color','b');     % Plot test 6 segment 2 temperature
title("4S5P VTC6 15A Dual Segment Single vs. Dual Fan Temp Estimation")
xlabel("Time (seconds)")
ylabel('Temperature (degrees Celsius)')
saveas(current_figure, "Test 5,6 Heat Transfer Estimation.png")