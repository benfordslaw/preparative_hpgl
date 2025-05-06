# A Text Stream Method for Fear-Preventative Collection Guidance

## Aim 
This project aims to produce visual directions for the collection of items that protect from some series of unknown threats.

## Methods

### Overview
A list of threats is generated, each prompting a second list of protective items.
Each protective item for the same threat is assigned a region in a neighborhood of the page
and sent over serial as a label to the plotter.
Continues until interrupted by user.

### Text generation
Uses two cases of `llama-cli` from `llama.cpp` with some relatively small `gguf`. 
One case generates fears via the prompt `a list of scary things:` 
and the other generates protective objects via the prompt
`a list of things to protect against [scary thing]`. 
The former is provided the grammar: `root ::= ("- " [a-z ]+ "\n")+`
and the latter: `root ::= ("- " [a-z ]+ "\n"){2,5}`.
Note the only difference being in the number of items per list. 

### Transformation into HPGL
HPGL is a vector graphics language for controlling pen plotters. 
General functions are generally conserved across HP machinery, at least from the same era,
but the more obscure functions are very device-specific. 
As a result of choosing to use the obscure functions, 
I've produced code which is likely to only work properly for the machine I've written it for: the HP7475a.

The prefix for each generation is `IN;IP;SP1;SS;SR0.3,0.8;DT.;PU1000,1000;`. 
This instantiates the stream and page, selects pen 1, selects the standard font, scales the font to an appropriate size, defines `.` as the label termination character, and moves the pen.

Each generated protective item is assigned an $x$, $y$ position within a range of $x_{group}$, $y_{group}$. The pen is moved to this point by `PU${x}${y};` 
with an additional offset relative to the character size for bullet placement: `CP2.5,1;`. 
A label for the generated item, with the bullet stripped via `cut`, is plotted with `LT;LB$(echo $ptoect | cut -d '-' -f 2).;`. 
Note the terminal `.` to signal the end of the label.
A bullet point to the lower left is plotted via `PU${x},${y};CP2,0.5;WG25,0,360;PU${x},${y};CP2,0.5;CI25;`.
The minimum and maximum $x$ and $y$ are stored for each label in a group to allow the group to be denoted by a leftward vertical bar.
The bar is drawn after all labels in a group via `PU${min_x},${max_y};CP1,2;FT1;RA${min_x},${min_y};`.

### Real-Time Plotter Control
HPGL is streamed as text which is processed by the plotter. 
Therefore, commands can simply be sent via `echo -n` to a tty device (in my case, USB: `/dev/tty/USB0`).
This means the script, which would by default print to STDOUT can be redirected via `>` to the device.
That's really all there is to it, aside from annoying device permissions.

## Results
A series of plots for the current version was generated.
The buffer fills rather quickly and I've built in no delay to the generation of list items, so they were simply run until the commands became garbled
(usually resulting in `LB` printing some command like `PU140,50;...` through the next label's terminal character. Below are three example groups.

| 1 | 2 | 3 |
|--|--|--|
|![group_1](https://github.com/user-attachments/assets/e0dbf4ee-ad40-4d85-b1fb-d5f868ca78ab) | ![group_2](https://github.com/user-attachments/assets/101875c4-44c7-49ea-b80c-e9dcd3109056) | ![group_3](https://github.com/user-attachments/assets/2521c230-3f81-468f-9efb-60207603dad9) |

