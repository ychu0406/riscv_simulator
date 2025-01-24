CC = gcc
CFLAGS = -g -Wall


SRC = s.c
OBJ = s.o
EXEC = riscv_simulator

all: $(EXEC)

$(EXEC): $(OBJ)
	$(CC) $(OBJ) -o $(EXEC)

$(OBJ): $(SRC)
	$(CC) $(CFLAGS) -c $(SRC)

clean:
	rm -f $(OBJ) $(EXEC)
