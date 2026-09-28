from sqlalchemy.orm import DeclarativeBase

# What is the equivalent this constructor in Dart? Does this mean class Base
# extends DeclarativeBase? If so why not creating User(DeclarativeBase), 
# Card(DeclarativeBase), etc.?
# From my understanding, DeclarativeBase is a form of class to make 
# interaction with database easier, all the classes inherits from it 
# has all the benefits of precoded functions and extensions to make 
# interaction with database easier am I correct? What's the line 'pass' ?
class Base(DeclarativeBase):
    pass