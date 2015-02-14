TARGET 		= line
CXX 		= cc
CXXFLAGS 	= -O0 -g 
INC_DIR 	=  
LIB_DIR		=  
LIB 		= -lSDL 

.PHONY: default all clean

default: $(TARGET)
all: default

OBJECTS = $(patsubst %.c, %.o, $(wildcard *.c))
HEADERS = $(wildcard *.h)

%.o: %.c $(HEADERS)
	$(CXX) $(CXXFLAGS) -c $< $(INC_DIR) -o $@

.PRECIOUS: $(TARGET) $(OBJECTS)

$(TARGET): $(OBJECTS)
	$(CXX) $(OBJECTS) -Wall $(LIB_DIR) $(LIB) -o $@

clean:
	-rm -rf $(TARGET) $(OBJECTS)
