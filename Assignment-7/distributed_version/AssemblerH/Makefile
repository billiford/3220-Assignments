CXX = g++

TARGET = assemblerh
OBJECTS = assemblerh.o
LDFLAGS =

all	: $(TARGET)

$(TARGET) : $(OBJECTS)
	$(CXX) -o $@ $(OBJECTS) $(LDFLAGS)

clean :
	rm *.o $(TARGET)
