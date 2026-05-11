# The idea

The idea is to make Vehicle a base class with an abstract property. Child classes override the abstract property to specify what type of vehicle it is. One could also get the name of the type directly through `.GetType().Name`, but this limits the output to the name of the class.
