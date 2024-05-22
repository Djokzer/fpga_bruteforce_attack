import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

HASH_COUNT = 10000

df = pd.read_csv("measures.csv")

for col in df.columns[1:]:
    print(col)
    df[col] = 1 / (df[col] / (HASH_COUNT * float(col)))

df.iloc[0][1:].plot(kind="bar")
plt.savefig("stats.png")
plt.show()