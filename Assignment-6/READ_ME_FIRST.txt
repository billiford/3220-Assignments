We made a small edit the simulator.h file to allow for the trace_op
to store a floating point value.

If anything, this probably made it more difficult for us as we have
to convert an int to floating point then back, instead of just
converting an int to floating point in execute. We just noticed
our mistake an hour before turning it in.

Either way, there wasn't anything specific that said we couldn't make
a small modification to the .h file in the instructions, so we
repectfully request that you compile with both our .cc and
.h file and run it this way without a penalty to our grade.

