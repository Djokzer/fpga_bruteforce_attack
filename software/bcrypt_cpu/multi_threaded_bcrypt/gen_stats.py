import subprocess
import concurrent.futures
import pandas as pd
import time

bin = "bcrypt_multicore"
cpu_count = [1, 2, 4, 8, 12, 14, 15, 16, 20, 24, 28, 32, 64]

def run_subprocess(bin_name, arg1, arg2):
        start = time.time()
        sp = subprocess.run([f"./build/{bin_name}", f"{arg1}", f"{arg2}"], capture_output=True)
        end = time.time()
        return end-start

df = pd.DataFrame()

for cpu in cpu_count:
        print(f"measuring : {bin}, {cpu} threads")
        
        times = []
        times.append(run_subprocess(bin, cpu, 10000))

        print(f"Time took : {times[0]}")

        df[f"{cpu}"] = times

df.to_csv("measures.csv")