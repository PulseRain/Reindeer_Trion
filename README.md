# PulseRain Reindeer for Efinix Trion T20 BGA256 Development Kit
----------------------------------------------------------------

PulseRain Reindeer is a soft CPU of Von Neumann architecture. It supports RISC-V RV32I[M] instruction set, and features a 2 x 2 pipeline. It strives to make a balance between speed and area, and offers a flexible choice for soft CPU across all FPGA platforms.

And at this point, it has also been successfully ported to the Efinix Trion T20 BGA256 Development Kit (“T20 Dev Kit” for the rest of the document), with the following configurations:
*	RV32I processor core, Von Neumann Architecture
*	48KB Block RAM for code and data
*	1 UART TX
*	32 bit GPIO 

![System Overview](https://github.com/PulseRain/Reindeer_Trion/raw/master/doc/system_overview.png "System Overview")

As shown above, to further facilitate the software development for RSIC-V, an Arduino board support package has been provided on GitHub for the T20 Dev Kit, with which the software developers can write code for RISC-V directly in Arduino IDE.  

# For more detail, please refer to the [**Quick Start Guide**](https://github.com/PulseRain/Reindeer_Trion/raw/master/doc/Reindeer_Trion_Quick_Start_Guide.pdf)
