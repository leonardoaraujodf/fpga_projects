from random import seed
from random import randint

seed(1)
file_in = open("mult_in.txt","w")
file_out = open("mult_out.txt","w")

for _ in range(512):
    value1 = randint(0,1023)
    value2 = randint(0,1023)
    file_in.write(f"{value1},{value2}\n")
    file_out.write(f"{value1*value2}\n")

file_in.close()
file_out.close()
