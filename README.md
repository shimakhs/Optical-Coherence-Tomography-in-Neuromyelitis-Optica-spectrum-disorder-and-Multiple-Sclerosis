# Optical-Coherence-Tomography-in-Neuromyelitis-Optica-spectrum-disorder-and-Multiple-Sclerosis: A population based-study

If you use these codes please cite to our paper: https://www.sciencedirect.com/science/article/abs/pii/S2211034820306994


# OCT Retinal Layer Thickness Analysis
The sector.m code :
This MATLAB project processes optical coherence tomography (OCT) `.vol` files to compute retinal layer thickness. The script calculates and exports measurements for various retinal layers using boundary data from `.vol` files.

## Features

- Processes multiple `.vol` files in a directory.
- Calculates the thickness of 11 retinal layers based on boundary data.
- Applies a circular mask to exclude invalid regions.
- Handles cases with different numbers of segmentation boundaries.
- Outputs results in an Excel file (`test.xls`).

### Files
- Ensure `.vol` files are in the current working directory.


