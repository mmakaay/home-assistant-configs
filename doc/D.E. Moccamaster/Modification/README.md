# D.E. Moccamaster - FIBARO switch project

This document describes a modification that I did, in order to make my
coffee maker machine controllable via home automation.

I started out by doing the obvious, and connecting the machine to a smart power plug.
That had an important drawback: you end up with two switches that must work in unison:
the switch on the plug and the switch on the coffee maker. This conflicted with the
two basic use cases that I wanted to support:

  1. Walk up to the machine, prepare it and turn it on by hand.
  2. Prepare the machine and turn it based on some home automation trigger.

For use case 1, it would be best when the power plug was already on, so using the
switch on the machine would turn it on right away, without having to fumble with
an app to turn on the power plug as well. Not to hard. A basic "if somebody walks
into the kitchen, turn on the power plug" would do. However, this does not work
for use case 2.

For use case 2, it is easy to turn on the power plug based on a trigger. However,
it is required that the switch on the machine is also turn on. When you forget
to turn that switch on during preparation, turn...
