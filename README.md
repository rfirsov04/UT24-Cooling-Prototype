# UT24-Cooling-Prototype
Arduino-integrated data logging of Enepaq 6S5P VTC6 segment temperature

Run the ArduinoSensing.m file in tandem with the MATLAB Arduino extension. Make sure to set the correct USB port for your Arduino, you can get this information from the Arduino IDE. The logging will show real time data, but it will stop at the click of any key, so just keep that in mind. Make sure to change the file name you save to at the end of the code to not overwrite your data from the previous experiment.

Lines 5-10 help me see in the terminal if the initial temp readings are valid, but feel free to add semi-colons to the end of those statements to hide them. Also, the way I pre-initialize the logging vectors is to fill them up with 3600 empty rows using the zeros command. This means that you will only log about 1 hour of test data per run of code, so PLEASE keep this in mind before you start logging.

Run (what is now known as) Plots_200_250W.m to help process and display your data in a more recognizable set, reference the examples I have attached of PNGs.
