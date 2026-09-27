class_name WaveSequence
extends RefCounted

static func generate(rng: RandomNumberGenerator) -> Array[int]:
	# Rejection sampling over shuffled multisets keeps all valid orders possible.
	var sequence: Array[int] = [0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1]
	while true:
		for i: int in range(sequence.size() - 1, 0, -1):
			var other: int = rng.randi_range(0, i)
			var previous: int = sequence[i]
			sequence[i] = sequence[other]
			sequence[other] = previous
		if valid(sequence):
			return sequence
	return sequence

static func valid(sequence: Array[int]) -> bool:
	if sequence.size() != 12 or sequence.count(0) != 6 or sequence.count(1) != 6:
		return false
	for i: int in range(3, sequence.size()):
		if sequence[i] == sequence[i - 1] and sequence[i] == sequence[i - 2] and sequence[i] == sequence[i - 3]:
			return false
	return true
