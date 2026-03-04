PROGRAM Main
VAR
    bMotorRunning : BOOL := FALSE;  // Motor running status
    fDirection    : REAL := 0.0;   // Motor direction
    //bPrevToggle   : BOOL := FALSE;  // Stores last state of toggle
    iSensorReading : INT := 0;
    bVibrationAlert : BOOL := FALSE;
    //fMotorVoltage : REAL := 0.0;
    fScale: REAL:= 32767.0/10.0;
    iSynchronization : BOOL;    
    fMaxValue        : LREAL := 1.0;
    i   : INT :=1;

    //----------- Scale to Volt -------------
    fScaleToVolt16bit     : REAL := (5.0/32767.0 * 1.0)* 9.81;
    fScaleToVolt32bit : REAL := (5.0/8388607.0 * 1.0)* 9.81;
    fVolt_Vibration_CH1T1 : ARRAY [1..GVL_Constant.nOversampling] OF REAL;
    fVolt_Vibration_CH2T1 : ARRAY [1..GVL_Constant.nOversampling] OF REAL;
    fVolt_Vibration_CH1T2 : ARRAY [1..GVL_Constant.nOversampling] OF REAL;
    fVolt_Vibration_CH2T2 : ARRAY [1..GVL_Constant.nOversampling] OF REAL;
    fVolt_Vibration_CH1T3 : ARRAY [1..GVL_Constant.nOversampling] OF REAL;
    fVolt_Vibration_CH2T3 : ARRAY [1..GVL_Constant.nOversampling] OF REAL;
    iVolt_out1       : INT;  

    // Calibration factors m/s²
    fCal_Sensor_1 : REAL := 0.5/9.81 ; // 0.5V/g
    fCal_Sensor_2 : REAL := 0.5/9.81 ; // 0.5V/g
    fCal_Sensor_3 : REAL := 1.0/9.81 ; // 1V/g    
    fCal_Sensor_4 : REAL := 1.0/9.81 ; // 1V/g
    fCal_Sensor_5 : REAL := 0.5/9.81 ; // 0.5V/g
    fCal_Sensor_6 : REAL := 0.5/9.81 ; // 0.5V/g

    //--------- Oversampling ------------------
    aU1_Samples     AT%I* : ARRAY[0..9] OF INT;
    aU1_OutVolt     AT%Q* : ARRAY[0..9] OF INT;

    GVL_CAL: INT;

    // Motor rotational Speed
    fSensorVoltage      : REAL := 0.0;   // Voltage from the sensor
    fScalingFactor      : REAL := 1000.0; // Example: 1V = 1000 RPM 
    nMotorRPM           : INT := 0;    // Calculated motor speed in RPM
    bRotationDetected   : BOOL := FALSE;  // Flag for rotation detection
    fThresholdVoltage   : REAL := 1.0;    // Voltage threshold for detecting rotation
END_VAR

{attribute 'qualified_only'}
VAR_GLOBAL CONSTANT
    nOversampling : INT :=10;
END_VAR

VAR_GLOBAL
    bStartMotor AT %Q*  : BOOL;  // Start/Stop motor
    bToggleDir AT %Q* : BOOL := TRUE;  // Toggle direction CW/CCW
    fMotorSpeed   : REAL := 0.0;  // Motor speed (0-100%)
    iMotorVoltage  AT %Q* : INT;
    iVibrationThreshold : INT := 100;

    iVibrationLevel_CH1T1 AT %I* : ARRAY[1..GVL_Constant.nOversampling] OF INT;
    iVibrationLevel_CH2T1 AT %I* : ARRAY[1..GVL_Constant.nOversampling] OF INT;
    iVibrationLevel_CH1T2 AT %I* : ARRAY[1..GVL_Constant.nOversampling] OF DINT;
    iVibrationLevel_CH2T2 AT %I* : ARRAY[1..GVL_Constant.nOversampling] OF DINT;
    iVibrationLevel_CH1T3 AT %I* : ARRAY[1..GVL_Constant.nOversampling] OF DINT;
    iVibrationLevel_CH2T3 AT %I* : ARRAY[1..GVL_Constant.nOversampling] OF DINT;

    // Other global variables for digital input/output signals
    iVoltageOut1   AT%Q*  : INT;
    iVoltageOut2   AT%Q*  : INT;

    //Motor Rotational Speed
    bSensorReadingNew   AT %I* : BOOL;
END_VAR

// Detect button press to toggle direction
IF bToggleDir THEN
    fDirection := 1.0;  // Clockwise direction
ELSE
    fDirection := -1.0; // Anticlockwise direction
END_IF

// Start motor logic
IF bStartMotor THEN
    bMotorRunning := TRUE;
ELSE
    bMotorRunning := FALSE;
END_IF

// Checking if vibration exceeds threshold
IF iSensorReading > iVibrationThreshold THEN
    bVibrationAlert := TRUE;  // Trigger vibration alert
ELSE
    bVibrationAlert := FALSE;
END_IF

//Motor Voltage
IF bMotorRunning THEN
    IF bToggleDir THEN
        GVL.iMotorVoltage := REAL_TO_INT(fMotorSpeed*fDirection*fScale);
    ELSE
        GVL.iMotorVoltage := REAL_TO_INT(fMotorSpeed*fDirection*fScale);
    END_IF
END_IF

//---------- Scale to Voltage -----------
FOR i := 1 TO GVL_Constant.nOversampling DO
    // for 16-bit EL3632 cart
    fVolt_Vibration_CH1T1[i] := INT_TO_REAL(GVL.iVibrationLevel_CH1T1[i])*fScaleToVolt16bit*fCal_Sensor_1;
    fVolt_Vibration_CH2T1[i] := INT_TO_REAL(GVL.iVibrationLevel_CH2T1[i])*fScaleToVolt16bit*fCal_Sensor_2;
    // for 32-bit ELM3602-0002 cart
    fVolt_Vibration_CH1T2[i] := DINT_TO_REAL(GVL.iVibrationLevel_CH1T2[i])*fScaleToVolt32bit*fCal_Sensor_3;
    fVolt_Vibration_CH2T2[i] := DINT_TO_REAL(GVL.iVibrationLevel_CH2T2[i])*fScaleToVolt32bit*fCal_Sensor_4;
    fVolt_Vibration_CH1T3[i] := DINT_TO_REAL(GVL.iVibrationLevel_CH1T3[i])*fScaleToVolt32bit*fCal_Sensor_5;
    fVolt_Vibration_CH2T3[i] := DINT_TO_REAL(GVL.iVibrationLevel_CH2T3[i])*fScaleToVolt32bit*fCal_Sensor_6;
END_FOR;

//---------- Voltage Output Handling --------
iVoltageOut1 := iVolt_out1;

// Link the new sensor reading to the EL1859 module 
bSensorReadingNew := GVL.bSensorReadingNew;

// Convert the sensor reading to voltage
fSensorVoltage := BOOL_TO_INT(bSensorReadingNew) * fScaleToVolt16bit;

// Calculate RPM from voltage 
nMotorRPM := BOOL_TO_INT(GVL.bSensorReadingNew);

// Check if voltage exceeds the threshold (indicating a rotation)
IF fSensorVoltage > fThresholdVoltage THEN
    IF NOT bRotationDetected THEN
        bRotationDetected := TRUE;    // Rotation detected
    END_IF
ELSE
    bRotationDetected := FALSE;   // Reset flag after voltage drops below threshold
END_IF
