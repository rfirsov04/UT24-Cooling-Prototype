load('tempzener2.mat');
mystruc.voltage1 = zeros(3257, 1);
mystruc.voltage2 = zeros(3257, 1);
mystruc.voltage3 = zeros(3257, 1);
mystruc.voltage4 = zeros(3257, 1);
mystruc.voltage5 = zeros(3257, 1);
mystruc.voltage6 = zeros(3257, 1);

mystruc.voltage1(1:720) = voltageA0(2:721);
mystruc.voltage2(1:720) = voltageA1(2:721);
mystruc.voltage3(1:720) = voltageA2(2:721);
mystruc.voltage4(1:720) = voltageA3(2:721);
mystruc.voltage5(1:720) = voltageA4(2:721);
mystruc.voltage6(1:720) = voltageA5(2:721);

% plot(voltageA0(2:721), "b");

load('tempzener200_1.mat');

mystruc.voltage1(721:3257, 1) = voltageA0(2:2538, 1);
mystruc.voltage2(721:3257) = voltageA1(2:2538);
mystruc.voltage3(721:3257) = voltageA2(2:2538);
mystruc.voltage4(721:3257) = voltageA3(2:2538);
mystruc.voltage5(721:3257) = voltageA4(2:2538);
mystruc.voltage6(721:3257) = voltageA5(2:2538);

plot(mystruc.voltage1, "b");
hold on
plot(mystruc.voltage2, "r");
plot(mystruc.voltage3, "g");
plot(mystruc.voltage4, "c");
plot(mystruc.voltage5, "m");
plot(mystruc.voltage6, "y");
legend({'Voltage Sensor 1', 'Voltage Sensor 2', 'Voltage Sensor 3', 'Voltage Sensor 4', 'Voltage Sensor 5', 'Voltage Sensor 6'}, 'FontSize', 16, "FontName", "Cambria Math")
title('6S5P VTC6 200/250W Thermal Prototype', 'FontSize', 28, "FontName", "Cambria Math")
xlabel('Time (s)', 'FontSize', 24, "FontName", "Cambria Math")
ylabel('Voltage_{Zener Reading} (V)', 'FontSize', 24, "FontName", "Cambria Math")

mystruc.voltage1_flat = movmean(mystruc.voltage1.', 10);
mystruc.voltage2_flat = movmean(mystruc.voltage2.', 10);
mystruc.voltage3_flat = movmean(mystruc.voltage3.', 10);
mystruc.voltage4_flat = movmean(mystruc.voltage4.', 10);
mystruc.voltage5_flat = movmean(mystruc.voltage5.', 10);
mystruc.voltage6_flat = movmean(mystruc.voltage6.', 10);

figure(2)
plot(mystruc.voltage1_flat, "b");
hold on
plot(mystruc.voltage2_flat, "r");
plot(mystruc.voltage3_flat, "g");
plot(mystruc.voltage4_flat, "c");
plot(mystruc.voltage5_flat, "m");
plot(mystruc.voltage6_flat, "y");
legend({'Voltage Sensor 1', 'Voltage Sensor 2', 'Voltage Sensor 3', 'Voltage Sensor 4', 'Voltage Sensor 5', 'Voltage Sensor 6'}, 'FontSize', 16, "FontName", "Cambria Math")
title('6S5P VTC6 200/250W Thermal Prototype MOVING MEAN', 'FontSize', 28, "FontName", "Cambria Math")
xlabel('Time (s)', 'FontSize', 24, "FontName", "Cambria Math")
ylabel('Voltage_{Zener Reading} (V)', 'FontSize', 24, "FontName", "Cambria Math")