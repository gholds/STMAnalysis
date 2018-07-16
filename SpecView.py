#// Author(s): Zach Krebs, Greg Holdman 
#// E-mail: zkrebs@wisc.edu 


import numpy as np
import STMAnalysis.Measurements as meas


class PointSpectrum():

    def __init__(self, point, spectrum):
        self.location = point
        self.spectrum = spectrum 
        self.highlight, = left_ax.plot( [self.location[0]], [self.location[1]], marker='o', 
                                ms=12, alpha=0.4, color='yellow', visible=False )
        self.dIdV, = right_ax.plot(spectrum.signals['Bias calc'], 
                                spectrum.signals['LI Demod 1 X']['forward'], visible=False )

    def show(self):
        self.highlight.set_visible(True)
        self.dIdV.set_visible(True)

    def hide(self):
        self.highlight.set_visible(False)
        self.dIdV.set_visible(False)


class PointBrowser():

    def __init__(self, speclist):
        self.lastind = 0
        self.data = speclist

    def onpick(self, event):
        if event.artist != line:
            return True

        N = len(event.ind)
        if not N:
            return True

        # the click location
        x = event.mouseevent.xdata
        y = event.mouseevent.ydata

        distances = np.hypot(x - clickable_X[event.ind], y - clickable_Y[event.ind])
        indmin = distances.argmin()
        dataind = event.ind[indmin]

        self.lastind = dataind
        self.update()

    def update(self):
        if self.lastind is None:
            return

        legend_list = []
        legend_labels = []
        dataind = self.lastind
        selected_point = self.data[dataind]

        if selected_point.highlight.get_visible():
            selected_point.hide()
        else:
            selected_point.show()

        for i in range( len(self.data) ):
            if self.data[i].highlight.get_visible():
                legend_list.append(self.data[i].dIdV)
                legend_labels.append(str(i+1))

        if legend_list:
            right_ax.legend(legend_list, legend_labels)
        else:
            right_ax.legend_.remove()

        fig.canvas.draw()


def withinBox(point, center, width, height):
    if ((center[0] - width) < point[0] < (center[0] + height)) and ((center[1] - height) < point[1] < (center[1] + height)):
        return True 
    return False  

if __name__ == '__main__':
    import matplotlib as mpl 
    import matplotlib.pyplot as plt
    from tkinter import Tk
    from tkinter.filedialog import askopenfilename
    import glob, os 

    #Tk().withdraw()
    #sxmfile = askopenfilename()
    #print(sxmfile)
    #print(os.path.dirname(sxmfile))

    sxmfile = "/Users/zkrebs/brarlab/STMAnalysis/testing/4-20-18_BLG_on_HBN004.sxm"
    sxm = meas.Scan(sxmfile)
    header = sxm.scan.header

    fig, (left_ax, right_ax) = plt.subplots(1, 2)
    right_ax.set_ylabel("dI/dV")

    pointSpectrumList = []         # to be list of PointSpectrum objects 

    # Gather dimensional parameters from the .sxm data
    center = np.array(header['scan_offset'])
    extent = np.array(header['scan_range'])
    pixel_size = np.array(header['scan_pixels'])

    # Scrape all spectrum files in the same folder as the .sxm
    os.chdir(os.path.dirname(sxmfile))
    for specfile in glob.glob("*.dat"):
        spectrum = meas.Spectrum(specfile)
        # Check if spectrum location is within the scan region 
        if withinBox(spectrum.coords, center, extent[0]/2.0, extent[1]/2.0):
            # If so, initialize PointSpectrum object and add to master list 
            pixel_location = pixel_size*((spectrum.coords-center)/extent + 0.5)
            pointSpectrumList.append(PointSpectrum( pixel_location, spectrum))
            left_ax.text(pixel_location[0], pixel_location[1], str(len(pointSpectrumList)))

    # Pixel coordinates where there is a clickable object (e.g. PointSpectrum)
    clickable_X = np.array([ s.location[0] for s in pointSpectrumList ])
    clickable_Y = np.array([ s.location[1] for s in pointSpectrumList ])

    # Plot the PointSpectrums on the scan image and index them 
    left_ax.imshow(sxm.signals['Z']['average'], cmap='gray')
    line, = left_ax.plot(clickable_X, clickable_Y, 'o', picker=5) 

    # Initialize interactive clicking
    browser = PointBrowser(pointSpectrumList)
    fig.canvas.mpl_connect('pick_event', browser.onpick)

    plt.tight_layout()
    plt.show()




