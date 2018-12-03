import matplotlib
import matplotlib.pyplot as plt
import csv
from matplotlib.ticker import FuncFormatter

ORANGE_COLOR = '#ff7f0e'
DARK_RED_COLOR = '#D60008'

ECP_ONLY_COLOR = 'purple'
PAYG_COLOR = 'purple'
SAFER_COLOR = ORANGE_COLOR
FREEP_COLOR = '#2EE12D'
AEGIS_COLOR = ORANGE_COLOR
ZOMBIE_COLOR = ORANGE_COLOR#'#ff7f0e'
RIDER_COLOR = 'b' #'#8080BF'

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
                if val_index % 2 == 0:
                    Plots[val_index].append(float(val)/10**9)
                else:
                    Plots[val_index].append(float(val))
            val_index += 1
        #counter += 1

fig = plt.figure(figsize=(11, 5))

num_of_plots = int(len(Plots)/2)
for i in range(num_of_plots):
    if 'RIDER' in heading_names[i]:
        if 'FREE' in heading_names[i]:
            plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1.5, linestyle='-', color=RIDER_COLOR, marker='x', markersize=7, markevery=25)
        elif 'XOR' in heading_names[i] and 'ECP4' in heading_names[i]:
            plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1.5, linestyle='-', color=RIDER_COLOR, marker='^', markersize=7, markevery=1500, markerfacecolor='white')
        elif 'ECP4' in heading_names[i]:
            #pass
            plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1.5, linestyle=':', color=RIDER_COLOR, marker='s', markersize=7, markevery=70, markerfacecolor='white')
        elif 'XOR' in heading_names[i]:
            plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=2, linestyle='--', color=RIDER_COLOR, marker='^', markersize=6, markevery=1000, markerfacecolor='white')
        elif 'Aegis' in heading_names[i]:
            plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1.5, linestyle='-', color=RIDER_COLOR, marker='o', markersize=6, markevery=3500, markerfacecolor='white')
        else: # Only RIDER
            plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1.5, linestyle='-', color=RIDER_COLOR, marker='', markersize=7, markevery=20)

    elif 'ECP2' in heading_names[i]:
        plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linestyle='--', linewidth=1, color=ECP_ONLY_COLOR)
    elif 'ECP6' in heading_names[i]:
        plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1, color=ECP_ONLY_COLOR)
    elif 'SAFER_32' in heading_names[i]:
        plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1, color=SAFER_COLOR)
    elif 'PAYG' in heading_names[i]:
        plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1, linestyle='-.', color=PAYG_COLOR)
    elif 'FREE' in heading_names[i]:
        plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1, color=FREEP_COLOR, marker='x', markersize=9, markevery=15)
    elif 'Aegis' in heading_names[i]:
        plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1, linestyle='-', color=AEGIS_COLOR, marker='o', markersize=6, markevery=2000, markerfacecolor='white')
    elif 'Zombie' in heading_names[i]:
        plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1, linestyle="-", color=ZOMBIE_COLOR, marker='^', markersize=7, markevery=1500, markerfacecolor='white')
    else:
        plt.plot(Plots[2 * i], Plots[2 * i + 1], label=heading_names[i], linewidth=1, linestyle="--", color='k')
    print(i)

ax = plt.plot()

plt.xlabel('Writes / page (Billions)')
plt.ylabel("Available memory (%)")
#plt.title()
plt.legend(loc='upper right', labelspacing=0.1, framealpha=1)

plt.xlim(left=0)
plt.ylim(bottom=0)

# format y values to %
formatter = FuncFormatter(to_percent)
plt.gca().yaxis.set_major_formatter(formatter)

plt.grid(b=True, which='major', axis='y')

plt.show()
fig.savefig("figure9.pdf", bbox_inches="tight")

