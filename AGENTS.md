# Agent Instructions

This workspace is a micropython port for my board DNRA8P1, folder: `ports/renesas-ra8`, only edit files in this folder, **don't edit files in other folders**. DNRA8P1 is a board based on Renesas RA8P1, in my port, I using a dual core project(FSP solution) and e2studio to generate FSP files, rather than directly operate register like `ports/renesas`. For my board, this is FSP project positon:

- solution: `ports/renesas-ra8/boards/DNRA8P1/gcc_freertos` 
- CPU0 project: `ports/renesas-ra8/boards/DNRA8P1/gcc_freertos/_CPU0` 
- CPU1 project: `ports/renesas-ra8/boards/DNRA8P1/gcc_freertos/_CPU1` 

My board have schematic in this folder:

- DNRA8P1:
    - Core Board: `ports/renesas-ra8/boards/DNRA8P1/sch/ATK-CNRA8P1.pdf` 
    - Base Boaed: `ports/renesas-ra8/boards/DNRA8P1/sch/ATK-DNRA8P1.pdf` 

The parsing results of these files are placed in the folder `ports/renesas-ra8/boards/DNRA8P1/analyze_result` and marked accordingly, so that they can be used across sessions.When it is necessary to read these files, the existing parsing results will be searched for first. Only when there is no relevant content, will the PDF skills be used for reading.

## Build

- Almost my project are build with e2 studio, because the CLI build of e2studio will cause workspace conflicts with the current window. So when you want to build, just tell the developer to build in IDE, rather than build in CLI by yourself.
