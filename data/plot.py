import json
from sys import argv
import plotly.graph_objects as go
import plotly.io as pio

algorithms = ['brotli', 'bz2', 'gzip', 'lz4',
              'lzma', 'lzo', 'pixz', 'snappy', 'zip', 'zstd']
input_size = float(242911744)
dpi = 2


def read_data(algorithm):
    with open("generated/output-" + algorithm + ".json") as json_file:
        run_data = json.load(json_file)['results']

    with open("generated/sizes-" + algorithm + ".txt") as size_file:
        size_data = []
        for line in size_file.readlines():
            size = float(line.strip().split(' ')[0])
            size_data.append(size)

    assert(len(run_data) == len(size_data))

    x = []
    y = []
    y_upper = []
    y_lower = []
    for run in range(0, len(run_data)):
        size = size_data[run]
        ratio = input_size / size
        time = run_data[run]['median']
        time_upper = run_data[run]['max']
        time_lower = run_data[run]['min']
        x.append(ratio)
        y.append(time)
        y_upper.append(time_upper)
        y_lower.append(time_lower)

    return (x, y, y_upper, y_lower)


fig = go.Figure()

for (i, algorithm) in enumerate(algorithms):
    data = read_data(algorithm)
    x = data[0]
    y = data[1]
    y_upper = data[2]
    y_lower = data[3]
    error = [x1 - x2 for (x1, x2) in zip(y_upper, y)]
    error_minus = [x1 - x2 for (x1, x2) in zip(y, y_lower)]

    trace = fig.add_trace(go.Scatter(x=y, y=x,
                                     mode='lines+markers',
                                     name=algorithm,
                                     error_x=dict(
                                         type='data',
                                         symmetric=False,
                                         array=error,
                                         arrayminus=error_minus
                                     )))

fig.update_layout(xaxis_title='Algorithm runtime',
                  yaxis_title='Compression ratio',
                  width=290 * dpi,
                  height=210 * dpi,
                  margin=dict(
                      l=0,
                      r=0,
                      b=0,
                      t=0,
                      pad=4
                  ),
                  )

# fig.show()
pio.orca.config.executable = "/usr/local/bin/orca"
fig.write_image("../src/images/lineplot-runtime-compressionratio.pdf")
