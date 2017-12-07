# Lotka Volterra
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

Demo here:
https://jsfiddle.net/yinghaowang/jxym6n7n/
