import matplotlib
import matplotlib.pyplot as plt
import csv
from matplotlib.ticker import FuncFormatter

ORANGE_COLOR = '#ff7f0e'
DARK_RED_COLOR = '#D60008'
GREEN_COLOR = '#5AB42E'

#---------------------------------

def to_percent(y, position):
    s = str(int(y))

    # The percent symbol needs escaping in latex
    if matplotlib.rcParams['text.usetex'] is True:
        return s + r'$\%$'
    else:
        return s + '%'

#---------------------------------

heading_names = []
Plots = []

with open('Results.csv','r') as csvfile:
    csv_reader = csv.reader(csvfile, delimiter=',')
    headings = next(csv_reader)
    for heading in headings:
        if heading and heading != '"':
            heading_names.append(heading)
            Plots.append([])
            Plots.append([])
    #counter = 0
    for row in csv_reader:
        #print(counter)

        val_index = 0
        for val in row:
            if val and val != '"':
                Plots[val_index].append(float(val))
            val_index += 1
        #counter += 1

fig = plt.figure(figsize=(10, 6))

num_of_plots = int(len(Plots)/2)
for i in range(num_of_plots):
    if 'RIDER' in heading_names[i]:
        if 'FREE' in heading_names[i]:
            plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1, linestyle='--', color=GREEN_COLOR, marker='x', markersize=7, markevery=30)
        elif 'XOR' in heading_names[i] and 'ECP4' in heading_names[i]:
            plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=2, linestyle='-', color=GREEN_COLOR, marker='o', markersize=7, markevery=1500)
        elif 'ECP4' in heading_names[i]:
            #pass
            plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1, linestyle='-', color=GREEN_COLOR, marker='o', markersize=7, markevery=100)
        elif 'XOR' in heading_names[i]:
            plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=2, linestyle='--', color=GREEN_COLOR, marker='^', markersize=7, markevery=1000)
        elif 'Aegis' in heading_names[i]:
            plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=2, linestyle='-.', color=GREEN_COLOR, marker='<', markersize=7, markevery=800)
        else: # Only RIDER
            plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1, linestyle='-', color=GREEN_COLOR, marker='', markersize=7, markevery=20)

    elif 'ECP2' in heading_names[i]:
        plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1, color='c')
    elif 'ECP6' in heading_names[i]:
        plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1, color='c')
    elif 'SAFER_32' in heading_names[i]:
        plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1, color='r')
    elif 'PAYG' in heading_names[i]:
        plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1, linestyle='-.', color='m')
    elif 'FREE' in heading_names[i]:
        plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1, color='b')
    elif 'Aegis' in heading_names[i]:
        plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=2, color=DARK_RED_COLOR)
    elif 'Zombie' in heading_names[i]:
        plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1, linestyle="--", color=ORANGE_COLOR)
    else:
        plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1, color='k')
    print(i)

ax = plt.plot()

plt.xlabel('Writes / page')
plt.ylabel("Available memory (%)")
plt.title('Available memory (%) vs Writes/page')
plt.legend(loc='upper right')

plt.xlim(left=0)
plt.ylim(bottom=0)

# format y values to %
formatter = FuncFormatter(to_percent)
plt.gca().yaxis.set_major_formatter(formatter)

plt.xscale('linear')

plt.show()
fig.savefig("figure9.pdf", bbox_inches="tight")

