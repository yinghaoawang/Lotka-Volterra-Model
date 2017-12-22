# Lotka Volterra
## Web App
### index.html
Models LK using chart.js. Using this for intro to game theory class.
![](https://i.imgur.com/eRuyUSx.png)

Variables a-f are alpha-zeta in alphabetical order.
Delta t recommended to be at most .0001.

Time to implement e,f are the times t where the model incorporates harvest rates e,f.

ch(x,y)@t are times to manually change x,y at times t.
(x,y)ch are the values to change to for ch(x,y)@t (note that it sets e,f to 0).
Note this is to simulate shocks in the model (sudden increase/decrease in a population).

ch(e,f)@t are second times for harvest rates to be implemented.
(e,f)2 are the values to change to for ch(e,f)@t.
Note this is to implement a second harvest rate to deal with the shocks.

### reader.html:
Takes in 2 data sets, and graphs it (used for data from processing sim)

![](https://i.imgur.com/h3lkb9C.png)

### lv-sim.html:
Originally made with processing 3.0 (see below)
![](https://i.imgur.com/1POveXP.png)

## Visuals with Processing 3.0
### lv_sim.pde
Lotka-Volterra simulation made with Procession 3.0:
Located in the lv-sim/ folder.
#### Features
* Fully functioning prey and predator simulation
* Toggle visuals for predator/prey and graph
* Visual realtime graph of predator and prey data
* Generates data for reader.html in console

#### How it works-
* Predator and prey move in random directions at random speeds.
* If predator touches prey, it has b chance of killing it.
* If Predator kills a prey, it has d chance of reproducing.
* Prey reproduces with a chance and predator dies with c chance every deltaT.

![](https://i.imgur.com/oUM9atq.png)

### quadtree.pde
Quadtree:
When prey population spikes to extreme amounts, the lag overwhelms the simulation. This is
solved by utilizing a Quadtree which reduces the amount of collision checks on each creature.

![](https://i.imgur.com/O09sw3X.png)
