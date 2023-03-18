import pandas as pd
from matplotlib import pyplot as plt

#adjustable variables
path_to_binned_delay_count = 'path/to/binned_delay_count'

origin = pd.read_csv(path_to_binned_delay_count)
#mode is either dep or arr
def binned_delay_plot(mode, selected_year, selected_month):
    selected = origin[(origin['Year'] == selected_year) & (origin['Month'] == selected_month)]
    selected_series = selected.iloc[0]
    x = list(selected_series.index[2:])
    y = list(selected_series.values[2:])
    #dep and arr will have the same number of delay bins
    num_bins = int(len(x)/2)

    x_arr = x[0: num_bins]
    x_arr = list(map(lambda x: x[4:], x_arr))
    y_arr = y[0: num_bins]

    x_dep = x[num_bins: ]
    x_dep = list(map(lambda x: x[4:], x_dep))
    y_dep = y[num_bins: ]

    # function to add value labels
    def addlabels(x,y):
        for i in range(len(x)):
            plt.text(i - 0.3, y[i],y[i])

    if mode == 'dep':
        plt.bar(x_dep, y_dep)
        addlabels(x_dep, y_dep)
        plt.xticks(rotation = 90)
        plt.xlabel('Delay Time (minutes)')
        plt.ylabel('Delay Count')
        plt.title(f'Departure Flights Delay Data ({selected_month} {selected_year})', loc = 'left')

    elif mode == 'arr':
        plt.bar(x_arr, y_arr)
        addlabels(x_arr, y_arr)
        plt.xticks(rotation = 90)
        plt.xlabel('Delay Time (minutes)')
        plt.ylabel('Delay Count')
        plt.title(f'Arrival Flights Delay Data ({selected_month} {selected_year})', loc = 'left')

    plt.show()