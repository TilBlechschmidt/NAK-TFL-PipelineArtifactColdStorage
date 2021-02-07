import plotly.graph_objects as go
import plotly.io as pio

dpi = 7
dictionary_size = 112640
non_blocked_sizes = [
    10698391,
    9935330,
    9187955,
    9166648,
    8672369,
    8262038,
    7828300,
    7524751,
    7350628,
    6991179,
    6945485,
    6821913,
    6699799,
    6634818,
    6488481,
    6626436,
    5820874,
    5853894,
    5374710
]

block_sizes = []
levels = []
dict_ratios = []
reg_ratios = []
non_block_ratios = []

with open("blocked_results.csv") as f:
    for line in f.readlines()[1:]:
        block_size, level, dict_size, reg_size, uncomp_size, block_count = line.strip().split(",")
        metadata_size = int(block_count) * 8

        block_sizes.append(str(block_size) + " MB")
        levels.append(level)

        dict_ratio = 1 / \
            ((float(dict_size) + metadata_size + dictionary_size) / float(uncomp_size))
        reg_ratio = 1 / ((float(reg_size) + metadata_size) /
                         float(uncomp_size))

        non_block_ratio = 1 / \
            (float(non_blocked_sizes[int(level) - 1]) / float(uncomp_size))

        dict_ratios.append(dict_ratio)
        reg_ratios.append(reg_ratio)
        non_block_ratios.append(non_block_ratio)

        if level == "19":
            block_sizes.append(block_size)
            levels.append(None)
            dict_ratios.append(None)
            reg_ratios.append(None)
            non_block_ratios.append(None)

fig = go.Figure()

fig.add_trace(go.Scatter(
    x=[block_sizes, levels],
    y=dict_ratios,
    name="Dictionary"
))

fig.add_trace(go.Scatter(
    x=[block_sizes, levels],
    y=reg_ratios,
    name="Blocked"
))

fig.add_trace(go.Scatter(
    x=[block_sizes, levels],
    y=non_block_ratios,
    name="Regular"
))

fig.update_layout(xaxis_title='Block size',
                  yaxis_title='Compression ratio',
                  width=290 * dpi,
                  height=150 * dpi,
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
fig.write_image("../../src/images/lineplot-blocksize-compressionratio.pdf")
