SDK = xcrun -sdk macosx

all: compute.metallib compute

compute.metallib: Compute.metal
	# Metal intermediate representation (.air)
	$(SDK) metal -c -Wall -Wextra -std=osx-metal2.0 -o /tmp/Compute.air $^
	# Metal library (.metallib)
	$(SDK) metallib -o $@ /tmp/Compute.air

compute: compute.swift
	$(SDK) swiftc -o $@ $^

run: compute.metallib compute.swift
	swift compute.swift

clean:
	rm -f compute.metallib compute
