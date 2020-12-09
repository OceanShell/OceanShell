# About
**OceanShell** is a software package for the storage, interactive exploration, analysis and visualization of oceanographic data. OceanShell uses Firebird database server which provides very fast data access. The software runs on x64 systems like Windows (>7), Linux (Ubuntu >16.0) and macOS (>10.15). The software allows to produce a merged quality- and duplicate-controlled observed-level database with assigned QC flags.  It has a graphical user interface and provides users with selection, additional filtering, sorting, editing, statistics, export, import of oceanographic data, and tools for visualization and comprehensive oceanographic analysis. OceanShell provides complete technology for oceanographic data processing and analysis.

# Installation

## Windows
1. Download the binaries for [Windows](https://github.com/OceanShell/OceanShell/releases/download/v.0.1-alpha/windows_x86-64.zip)
2. Unpack the package in any folder which is accessible for writing (User's folder is preferred)
3. Download and install the latest [Firebird](https://github.com/FirebirdSQL/firebird/releases/download/R3_0_7/Firebird-3.0.7.33374_1_x64.exe) server

## Linux
1. Download the binaries for [Linux](https://github.com/OceanShell/OceanShell/releases/download/v.0.1-alpha/linux_x86-64.tar.gz)
2. Unpack the package in any folder which is accessible for writing (User's folder is preferred)
3. Install the latest Firebird server:
```
sudo apt-get install firebird3.0-server
sudo apt-get install firebird-dev
```
4. During installation you will be asked to set a password. Use the standard 'masterkey' one.

## macOS
1. Download the binaries for [macOS](https://github.com/OceanShell/OceanShell/releases/download/v.0.1-alpha/macos_x86-64.tar.gz)
2. Unpack the package in any folder which is accessible for writing (User's folder is preferred)
3. Download and install the latest available [Firebird](https://github.com/FirebirdSQL/firebird/releases/download/R3_0_7/Firebird-3.0.7-33374-x86_64.pkg) server
4. Use the standard 'masterkey' password during installation
