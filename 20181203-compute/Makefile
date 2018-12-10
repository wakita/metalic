LIB = compute.metallib pi.metallib
TARGET = compute pi
XC = xcrun -sdk macosx

all: $(LIB) $(TARGET)

%.metallib: %.metal
	# Metal intermediate representation (.air)
	$(XC) metal -c -Wall -Wextra -std=osx-metal2.0 -o /tmp/$<.air $^
	# Metal library (.metallib)
	$(XC) metallib -o $@ /tmp/$<.air

pi.metallib: Loki/Loki/*.metal pi.metal
	$(XC) metal -c -Wall -Wextra -std=osx-metal2.0 -o /tmp/loki.air Loki/Loki/loki.metal
	$(XC) metal -c -Wall -Wextra -std=osx-metal2.0 -o /tmp/pi.air pi.metal
	$(XC) metallib -o $@ /tmp/loki.air /tmp/pi.air

%: %.swift
	$(XC) swiftc -o $@ $<

clean:
	rm -f *.metallib $(TARGET)
