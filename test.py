import subprocess
import csv
import time
from itertools import product

# Parameters to test
num_nodes_list = [500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2100, 2200, 2300, 2400, 2500, 2600, 2700, 2800, 2900, 3000]
topologies = ["full", "3D", "line", "imp3D"]
algorithms = ["gossip", "push-sum"]

# Output file
output_file = "results.csv"

# Function to run the Pony program and extract the convergence time
def run_project2(num_nodes, topology, algorithm):
    command = f"./src {num_nodes} {topology} {algorithm}"
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=300)  # 5-minute timeout
        output = result.stdout
        for line in output.split('\n'):
            if "Convergence time:" in line:
                return int(line.split(":")[1].strip().split()[0])
    except subprocess.TimeoutExpired:
        return "Timeout"
    except Exception as e:
        return f"Error: {str(e)}"
    return "No convergence time found"

# Run tests and save results
with open(output_file, 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow(["Num Nodes", "Topology", "Algorithm", "Convergence Time (ms)"])

    for num_nodes, topology, algorithm in product(num_nodes_list, topologies, algorithms):
        print(f"Running test: {num_nodes} nodes, {topology} topology, {algorithm} algorithm")
        convergence_time = run_project2(num_nodes, topology, algorithm)
        csvwriter.writerow([num_nodes, topology, algorithm, convergence_time])
        csvfile.flush()  # Ensure data is written immediately
        time.sleep(1)  # Small delay between runs

print(f"All tests completed. Results saved to {output_file}")