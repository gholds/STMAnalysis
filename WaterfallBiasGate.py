#// Author: Zach Krebs 
#// E-mail: zkrebs@wisc.edu 


import numpy as np
import STMAnalysis.Measurements as meas
import matplotlib.pyplot as plt
from tkinter import filedialog
import glob, os, sys, fnmatch, re

# Specify the gate voltages 
lowGateVoltage = -50
highGateVoltage = 50
increment = 5
points = 800
gateVoltages = np.arange(lowGateVoltage, highGateVoltage+increment, increment)
offset=0


# Get name of folder containing relevant data
# First, check if folder name was already provided 
folderstring = sys.argv[1]
# If not, open tkinter dialogue box to choose 
if not folderstring:
	root = Tk()
	root.withdraw()
	folderstring = filedialog.askdirectory()
# Switch to that folder 
os.chdir(folderstring) 


# Search through directory for .dat files 
for spectrum_file in glob.glob("*.dat"):
	# Extract spectrum data from the .dat file 
	spectrum_data = meas.Spectrum(spectrum_file).signals['LI Demod 1 X']['backward']
	# Parse file string for gate voltage
	result = re.search("^[0-9]*_gate_(.*)V", spectrum_file)
	gateVal = int(result.group(1))
	# Plot each spectrum with a vertical offset (may need to change values here)
	offset = (0.3e-11)*(gateVal+50)/7
	plt.plot(np.linspace(-500,500,points), spectrum_data + offset, color='blue')
	# Show the gate voltage next to each dataset
	plt.text(580, offset+0.25e-11, str(gateVal)+'V')


plt.title("Gated BLG on hBN, dI/dV spectra")
plt.ylabel("dI/dV")
plt.xlabel("Bias (mV)")
plt.show()


	

	





