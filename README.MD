# Lotka Volterra
## Web App
### index.html
Models LK with the Euler method using chart.js.
![](https://i.imgur.com/eRuyUSx.png)

Variables a-f are alpha-zeta in alphabetical order.
Delta t recommended to be at most .0001.

#### Advanced Options
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
Originally made with processing 3.0 (see below).
Entirely object oriented.
#### Differences
- This implementation only uses a spatial hash
    - Has visual representation
- Has slight changes in the details of the creatures actions (ordering, infancy, etc.)
- Can retrieve logged data to paste onto chart reader
![](https://i.imgur.com/GoqS7Cu.png)

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

#### Effect on simulation
In processing, when not using a quadtree, the fps dropped as low as **6 fps** (max is 60 fps)
when there were 5000 prey and 1000 predator.
After using the quadtree and keeping all other factors equal, the largest frame drop was at **48 fps**
and remained at 60 fps when not at extreme creature values.

This is a tremendous increase in processing power from changing the collision detection algorithm.
If a quadtree is this powerful, a spatial hashing algorithm seems undoubtedly able to handle unrealistic
numbers of object collisions.

### spatial_hash.pde
Spatial Hash:
A common second option in collision detection algorithms. This one is much easier to implement, and
is more popular according to blogs and stack overflow.

![](https://i.imgur.com/1nCeY99.png)

#### Effect on simulation
Using the same variables in the brute force and quadtree tests, and using a cell size of (width/height)/2/40,
the spatial hash performed slightly worse than the quadtree. It averaged about **45 fps** compared to the
**48 fps** of the quadtree. I expected spatial hashing to perform better due to the hype on the internet.

### Conclusion on Collision Detection Methods
Brute force is clearly a terrible option when dealing with any project expecting to have at least a decent
amount of objects. There are pros and cons to both the quadtree and spatial hashing.

The spatial hash has a consistent space complexity and is easy to implement. The only problem is that the
space may become expensive in a large map with small amount of objects. That is when I would use a quadtree.

The quadtree performs similar to the spatial hash. It has variable spatial complexity, but is superior in
large maps with sparse objects. Compared to a hash map, a tree also requires less overhead to read.

Hopefully, I am able to find better algorithms and techniques to improve collision detections. Currently, I
am only confident in using these algorithms with squares and circles on a 2d plane. It has been a great
learning experience creating these data structures and putting them to use in a project I am working on.
