# About
**OceanShell** is a **software package** for oceanographic data storage, processing, visualization and analysis. OceanShell uses **Firebird database server** providing a fast data access. The software is designed to produce a scientific quality, duplicate-controlled database from multiple original data sources. Embedded **knowledge database** contains detailed metadata necessary for data description (countries, institutions, platforms, sources, units, principal investigators). 
A user-friendly graphical interface offers **tools** necessary for data **download** (multiple formats), oceanographic stations/cruises **selection** from a database (by time, region, data source, vessel name, variable name, interactively on a globe etc.), **editing** of metadata and profiles, **quality control** (three-levels quality control flag system), **import/export**, **database statistics**, and **visualization** (external graphical software Surfer and Grapher).  Additionally, the selections made can be stored in a **data catalog** (entry search). OceanShell includes Thermodynamic Equation Of Seawater - 2010 [(TEOS-10)](http://www.teos-10.org/) and supports the [netCDF](https://www.unidata.ucar.edu/software/netcdf/) format.

# Installation

## Supported systems (x64 only)
- Windows (v7 and above)
- Linux (tested on Ubuntu v16.0 and above)
- macOS (v10.15 and newer). 

### Windows
1. Download the binaries for [Windows](https://github.com/OceanShell/OceanShell/releases/download/v.0.1-alpha/windows_x86-64.zip)
2. Unpack the package in any folder which is accessible for writing (User's folder is preferred)
3. Download and install the latest [Firebird](https://github.com/FirebirdSQL/firebird/releases/download/R3_0_7/Firebird-3.0.7.33374_1_x64.exe) server

### Linux
1. Download the binaries for [Linux](https://github.com/OceanShell/OceanShell/releases/download/v.0.1-alpha/linux_x86-64.tar.gz)
2. Unpack the package in any folder which is accessible for writing (User's folder is preferred)
3. Install the latest Firebird server:
```
sudo apt-get install firebird3.0-server
sudo apt-get install firebird-dev
```
4. During installation you will be asked to set a password. Use the standard 'masterkey' one.

### macOS
1. Download the binaries for [macOS](https://github.com/OceanShell/OceanShell/releases/download/v.0.1-alpha/macos_x86-64.tar.gz)
2. Unpack the package in any folder which is accessible for writing (User's folder is preferred)
3. Download and install the latest available [Firebird](https://github.com/FirebirdSQL/firebird/releases/download/R3_0_7/Firebird-3.0.7-33374-x86_64.pkg) server
4. Use the standard 'masterkey' password during installation
