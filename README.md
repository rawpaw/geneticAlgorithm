# geneticAlgorithm
This project showcases the use of a genetic algorithm to solve a topological problem. 

# The problem
A number of deadzones (cirlces) are generated within a bounded area, and the genetic algorithm needs to find the largest circle that can fit between the deadzones (i.e no overlap/intersect). 

# Solution genome
A Chromosome is a possible solution (i.e circle that can fit between deadzones) where it's genome is a binary string representing the x,y and diameter of the cirlce.

Example:

{"y":44,"genome":"101011101000101100001010111","x":349,"diameter":87,"chunkSize":9}

ChunkSize is the length of each part of the genome representing a value. That is, the first chunkSize bits will be the **x** value, then the **y** value, then the **diameter**. 

# Further reading
https://en.wikipedia.org/wiki/Genetic_algorithm
