# 🔧 Predictive Maintenance System  
## Bearing Fault Detection using Vibration Analysis (TwinCAT + MATLAB)

**Master’s Thesis Project – 2025**  
Maheshwaran Nattamai  
M.Sc. Digitalization & Automation – PFH University of Applied Sciences  

---

## 📌 Project Overview

This project develops a real-time predictive maintenance system for detecting bearing faults in rotating machinery using industrial automation and advanced signal processing techniques.

The system integrates:

- Beckhoff PLC (CX2043)
- TwinCAT 3 (Structured Text Programming)
- IEPE Accelerometers
- EtherCAT High-Precision Measurement Modules
- MATLAB for advanced signal analysis

The goal is to compare vibration signals from a healthy and a defective bearing to accurately identify early-stage faults.

---

## 🎯 Business Problem

Industrial rotating machinery frequently experiences unexpected bearing failures due to:

- Lubrication loss  
- Cracks and surface defects  
- Misalignment  
- Fatigue wear  

Traditional maintenance strategies are:

- Reactive (too late)
- Preventive (unnecessary replacements)

This project implements a predictive maintenance approach to detect faults before catastrophic failure occurs.

---

# 🏗 System Architecture

## ⚙️ Mechanical Test Bench

- 2 × P004 20mm Pillow Block Bearings  
  - 1 Healthy (sealed & lubricated)  
  - 1 Defective (unsealed, cracked, grease removed)  

- Maxon RE 40 DC Motor  
- Custom 3D-Printed Shaft Coupling  
- 6 × IEPE Accelerometers  
- 1 × Magnetic Speed Sensor  

---

## 🖥 Control & Automation Layer

- Beckhoff CX2043 PLC  
- EtherCAT Terminals:
  - EL1859 (Digital I/O)
  - EL4034 (Analog Output)
  - EL3632 (IEPE Interface)
  - ELM3602-002 (High-Precision IEPE Module)

- TwinCAT 3.1
  - Structured Text PLC Programming
  - Oversampling configuration
  - Real-time vibration acquisition
  - Motor control logic
  - HMI Visualization
  - YT Scope monitoring

---

# 📊 Data Acquisition Strategy

- 6 vibration sensors placed around healthy and defective bearings
- 1 magnetic sensor for motor RPM validation
- Sampling frequency: 10 kHz
- Oversampling: 10 samples per cycle
- Real-time visualization using TwinCAT YT Scope
- Export to MATLAB for advanced analysis

---

# 📈 Signal Processing Methods

## 1️⃣ Fast Fourier Transform (FFT)

Used to transform time-domain vibration signals into frequency domain.

Identifies characteristic fault frequencies:

- BPFO – Ball Pass Frequency Outer Race  
- BPFI – Ball Pass Frequency Inner Race  
- BSF – Ball Spin Frequency  
- FTF – Fundamental Train Frequency  

Result:
- Damaged bearing showed clear high-amplitude peaks at fault frequencies
- Healthy bearing showed stable low-amplitude spectrum

---

## 2️⃣ Envelope Spectrum Analysis

Applied Hilbert Transform to detect modulated high-frequency impact signals.

Result:
- Damaged bearing showed strong periodic impact signatures
- Healthy bearing remained spectrally flat

---

## 3️⃣ Spectral Kurtosis

Used to detect non-Gaussian transient impulses.

Result:
- Damaged bearing → High kurtosis values
- Healthy bearing → Near-Gaussian stationary behavior

---

# 🧮 Bearing Fault Frequency Validation

Bearing parameters:

- Number of balls: 9
- Ball diameter: 7.94 mm
- Pitch diameter: 33.5 mm
- Shaft speed ≈ 676 rpm
- Motor speed ≈ 3044 rpm

Theoretical fault frequencies were calculated and validated against MATLAB FFT results.

---

# 🖥 PLC Implementation

The TwinCAT Structured Text program includes:

- Motor start/stop control
- Direction control (CW/CCW)
- Voltage scaling
- Sensor calibration (m/s² conversion)
- Oversampling logic
- RPM detection
- Vibration threshold alert system

---

# 📊 MATLAB Analysis Pipeline

MATLAB processing includes:

- Raw signal preprocessing
- FFT computation
- Spectrogram generation
- Waterfall analysis
- Envelope detection (Hilbert Transform)
- Kurtogram optimization
- Bandpass filtering
- Spectral kurtosis computation

---

# 📈 Results Summary

| Metric | Damaged Bearing | Healthy Bearing |
|--------|-----------------|----------------|
| FFT Peaks | High amplitude at BPFO/BPFI | Minimal peaks |
| Envelope Spectrum | Clear impact frequencies | Flat response |
| Spectral Kurtosis | High | Low |
| Spectrogram | Irregular transient bursts | Stable |

---

# 🚀 Key Contributions

✔ Real-time PLC-based vibration monitoring  
✔ Integration of automation and advanced signal processing  
✔ Experimental validation of theoretical bearing fault frequencies  
✔ Demonstration of Industry 4.0 predictive maintenance methodology  

---

# 🧠 Future Improvements

- Machine learning-based automatic fault classification  
- IoT-based real-time cloud monitoring  
- Automated fault severity scoring  
- Integration with enterprise maintenance systems  

---

# 🏷 Skills Demonstrated

- Industrial Automation  
- PLC Programming (Structured Text)  
- EtherCAT Configuration  
- Vibration Diagnostics  
- Signal Processing  
- MATLAB  
- Predictive Maintenance  
- Industry 4.0 System Design  

---

## 📬 Contact

Maheshwaran Nattamai  
Hamburg, Germany  
LinkedIn: www.linkedin.com/in/mahesh-waran-46b59a18a
