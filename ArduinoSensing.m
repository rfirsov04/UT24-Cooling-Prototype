clear
a = arduino('COM10', 'Uno');

i = 0;
v1 = readVoltage(a, 'A0')  %Analog input
v2 = readVoltage(a, 'A1')
v3 = readVoltage(a, 'A2')
v4 = readVoltage(a, 'A3')
v5 = readVoltage(a, 'A4')
v6 = readVoltage(a, 'A5')
flag = get(gcf,'CurrentCharacter');

%my_structure.time = zeros(3600, 1); if logging faster than once per second
my_structure.voltageA0 = zeros(3600, 1);
my_structure.voltageA1 = zeros(3600, 1);
my_structure.voltageA2 = zeros(3600, 1);
my_structure.voltageA3 = zeros(3600, 1);
my_structure.voltageA4 = zeros(3600, 1);
my_structure.voltageA5 = zeros(3600, 1);

ax = axes();
hold on;
line1 = line(i, v1);  %handle for line 1s
line2 = line(i, v2);
line3 = line(i, v3);
line4 = line(i, v4);
line5 = line(i, v5);
line6 = line(i, v6);

axis([0 inf 1.3 2.1]) %Chose those y-axis values because in normal conditions, temp is aprox 22ºC
i = i + 1;
while(isempty(flag) == 1) %For making the loop infinite
  v1=readVoltage(a, 'A0');  %Analog input for the first NTC temperature sensor
  v2=readVoltage(a, 'A1');
  v3=readVoltage(a, 'A2');
  v4=readVoltage(a, 'A3');
  v5=readVoltage(a, 'A4');
  v6=readVoltage(a, 'A5');
  pause(1.0);        
  line1.XData = [line1.XData i];
  line1.YData = [line1.YData v1];
  hold on
  line2.XData = [line2.XData i];
  line2.YData = [line2.YData v2];
  line3.XData = [line3.XData i];
  line3.YData = [line3.YData v3];
  line4.XData = [line4.XData i];
  line4.YData = [line4.YData v4];
  line5.XData = [line5.XData i];
  line5.YData = [line5.YData v5];
  line6.XData = [line6.XData i];
  line6.YData = [line6.YData v6];
  i = i + 1;
  %my_structure.time(i) = i;
  my_structure.voltageA0(i) = v1;
  my_structure.voltageA1(i) = v2;
  my_structure.voltageA2(i) = v3;
  my_structure.voltageA3(i) = v4;
  my_structure.voltageA4(i) = v5;
  my_structure.voltageA5(i) = v6;

  flag = get(gcf,'CurrentCharacter');
end

save tempzener200_2.mat -struct my_structure %or just save it every iteration of the while loop so we don't need flag which delays by like 10 seconds