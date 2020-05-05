OBJECTS = ipc_cmd.o
LIBS = -lpthread -lrt

all: ipc_cmd

ipc_cmd.o: ipc_cmd.c $(HEADERS)
	$(CC) -c $< -fPIC -O2 -o $@

ipc_cmd: $(OBJECTS)
	$(CC) $(OBJECTS) $(LIBS) -fPIC -O2 -o $@
	$(STRIP) $@

.PHONY: clean

clean:
	rm -f ipc_cmd
	rm -f $(OBJECTS)
