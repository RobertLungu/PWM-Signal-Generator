#PWM Generator
Made by : Dumitrascu Olivia-Maria and Lungu Robert

*Documentation and comments will be in english for the sake of parity with the code template comments as well as for the sake of future repository viewing*

As of 1.2 Code mostly runs but there are problems with the PWM output

Most particular functionality of the project is outlined in either the received documents from the [Template Repository](https://github.com/cs-pub-ro/computer-architecture/tree/main/assignments/projects/pwmgen) or in the code itself through comments describing steps

A couple general peculiarities of the code is a slight excesive use of reg standi-ins due to inability to alter the head of the modules or the top, since the testebench would be structured differently. As such ever module has a reg declaration segment followed by a block of assigning 
"assign variable=variable_reg"

top.v although initially requested not to be modified had to be changed in a few places such as swapping the I/O status of the mosi and miso to their correct states and adding a couple wires the the module call sequences

1.4 - 2 things were really changed, formatting because one of us uses a different formatter, and some initializations because we forgot, now it should work fine
