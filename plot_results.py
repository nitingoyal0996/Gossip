import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Read the CSV file
df = pd.read_csv('results.csv')

# Convert 'Convergence Time (ms)' to numeric, replacing 'Timeout' with NaN
df['Convergence Time (ms)'] = pd.to_numeric(df['Convergence Time (ms)'], errors='coerce')

# Set up the plot style
sns.set_theme(style="darkgrid")

# Function to plot for a specific algorithm
def plot_algorithm(algorithm):
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(20, 8))
    
    for topology in df['Topology'].unique():
        data = df[(df['Algorithm'] == algorithm) & (df['Topology'] == topology)]
        
        # Linear scale plot
        ax1.plot(data['Num Nodes'], data['Convergence Time (ms)'], marker='o', label=topology)
        ax1.set_xlabel('Number of Nodes')
        ax1.set_ylabel('Convergence Time (ms)')
        ax1.set_title(f'{algorithm.capitalize()} Algorithm (Linear Scale)')
        ax1.legend()
        ax1.grid(True)
        ax1.set_xscale('log')
        ax1.set_yscale('linear')
        ax1.set_ylim(bottom=0)
        
        # Logarithmic scale plot
        ax2.plot(data['Num Nodes'], data['Convergence Time (ms)'], marker='o', label=topology)
        ax2.set_xlabel('Number of Nodes')
        ax2.set_ylabel('Convergence Time (ms)')
        ax2.set_title(f'{algorithm.capitalize()} Algorithm (Log Scale)')
        ax2.legend()
        ax2.grid(True)
        ax2.set_xscale('log')
        ax2.set_yscale('log')
    
    plt.tight_layout()
    plt.savefig(f'{algorithm}_convergence_time_plots.png', dpi=300, bbox_inches='tight')
    plt.close()

# Plot for Gossip algorithm
plot_algorithm('gossip')

# Plot for Push-Sum algorithm
plot_algorithm('push-sum')

print("Graphs with both linear and logarithmic scales for each algorithm have been generated and saved.")