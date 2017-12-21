# Lotka Volterra
index.html:
Models LK using chart.js. Using this for intro to game theory class.

Variables a-f are alpha-zeta in alphabetical order.
Delta t recommended to be at most .0001.

Time to implement e,f are the times t where the model incorporates harvest rates e,f.

ch(x,y)@t are times to manually change x,y at times t.
(x,y)ch are the values to change to for ch(x,y)@t (note that it sets e,f to 0).
Note this is to simulate shocks in the model (sudden increase/decrease in a population).

ch(e,f)@t are second times for harvest rates to be implemented.
(e,f)2 are the values to change to for ch(e,f)@t.
Note this is to implement a second harvest rate to deal with the shocks.

reader.html:
Takes in 2 data sets, and graphs it (used for data from processing sim)

Lotka-Volterra simulation made with Procession 3.0:
Located in the lv-sim/ folder.
Prey and predator simulation where predator eats prey, etc. Generates data and chart
which enforces the Lotka Volterra model.

Quadtree:
When prey population spikes to extreme amounts, the lag overwhelms the simulation. This is
solved by utilizing a Quadtree which reduces the amount of collision checks on each creature.

![](https://i.imgur.com/O09sw3X.png)
