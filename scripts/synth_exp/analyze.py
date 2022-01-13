#!/usr/bin/python3
# Copyright 2021 Efabless Corporation
# Original File Copyright 2020 Mohamed Shalan
#
# Licensed under the Apache License, Version 2.0 (the "License")
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Direct-translated from Perl to Python by Donn.

import re
import click


@click.command()
@click.option("-o", "--output", required=True, help="Output HTML file")
@click.argument("input_file")
def cli(output, input_file):
    output_file_handle = open(output, "w")

    def write(string):
        print(string, file=output_file_handle)

    file_str = open(input_file).read()
    file_lines = file_str.split("\n")

    # aw = 0.5
    # dw = 0.5
    # ascale = 100
    minArea = 1000000000
    minGates = minArea
    minDelay = minArea
    bestArea = ""
    bestDelay = ""

    delay_rx = re.compile(r"Delay\s+\=\s+(\S+)")
    area_rx = re.compile(r"Area\s+\=\s+(\S+)")
    gates_rx = re.compile(r"Gates\s+\=\s+(\S+)")

    c = 0
    for line in file_lines:
        # print chomp(line)
        # data = line.split()
        if "none" in line:
            c += 1
            sn = f"S{c}"
            delay_m = delay_rx.search(line)
            delay = float(delay_m[1])
            area_m = area_rx.search(line)
            area = float(area_m[1])
            gates_m = gates_rx.search(line)
            gates = float(gates_m[1])
            # factor = aw * area / ascale + dw * delay
            if area < minArea:
                minArea = area
                bestArea = sn

            if delay < minDelay:
                minDelay = delay
                bestDelay = sn

            if gates < minGates:
                minGates = gates
                bestGates = sn

    # printf ("Startegy\tGates\tArea\tDelay\tGR\tAR\tDR\n")

    write(
        f"""
  <html>

  <head>
    <title>Scatter Chart</title>
    <link href='table.css' rel='stylesheet' type='text/css' media='screen' />
    <script src='https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.2/Chart.min.js'></script>
    <script src='utils.js'></script>
    <style>
    canvas {{
      -moz-user-select: none;
      -webkit-user-select: none;
      -ms-user-select: none;
    }}
    </style>
  </head>

  <body>
  <div style='width:50%''>

  <table cellspacing='0' cellpadding='0' class='demo-table' >
  <tr>
    <th bgcolor='b0c4de'>Best Area</th>
    <th bgcolor='b0c4de'>Best Gate Count</th>
    <th bgcolor='b0c4de'>Best Delay</th>
  </tr>
  <tr>
    <td>{minArea}</td>
    <td>{minGates}</td>
    <td>{minDelay}</td>
  </tr>
  <tr>
    <td>{bestArea}</td>
    <td>{bestGates}</td>
    <td>{bestDelay}</td>
  </tr>
  </table><br>

  <table cellspacing='0' cellpadding='0' class='demo-table' >
  <tr>
    <th bgcolor='b0c4de'>Startegy</th>
    <th bgcolor='b0c4de'>Gate Count</th>
    <th bgcolor='b0c4de'>Area (um^2)</th>
    <th bgcolor='b0c4de'>Delay (ps)</th>

    <th bgcolor='b0c4de'>Gates Ratio</th>
    <th bgcolor='b0c4de'>Area Ratio</th>
    <th bgcolor='b0c4de'>Delay Ratio</th>

  </tr>
  """
    )

    c = 0
    for line in file_lines:
        # print chomp(line)
        # data = line.split()
        if "none" in line:
            c += 1
            sn = f"S{c}"
            write("<tr>")

            delay_m = delay_rx.search(line)
            delay = float(delay_m[1])
            area_m = area_rx.search(line)
            area = float(area_m[1])
            gates_m = gates_rx.search(line)
            gates = float(gates_m[1])

            # dfactor = 0.25 * area / minArea + 0.75 * delay / minDelay
            # afactor = 0.75 * area / minArea + 0.25 * delay / minDelay

            dratio = int(delay / minDelay * 1000) / 1000
            aratio = int(area / minArea * 1000) / 1000
            gratio = int(gates / minGates * 1000) / 1000

            write(f"<td>{sn}</td>")

            if gratio < 1.0001:
                write(f"<td bgcolor='#ccff99'>{gates}</td>")
            else:
                write(f"<td>{gates}</td>")

            if aratio < 1.0001:
                write(f"<td bgcolor='#ccff99'>{area}</td>")
            else:
                write(f"<td>{area}</td>")

            if dratio < 1.0001:
                write(f"<td bgcolor='#ccff99'>{delay}</td>")
            else:
                write(f"<td>{delay}</td>\n")

            if gratio <= 1.1:
                write(f"<td bgcolor='#fffacd'>{gratio}</td>")
            else:
                write(f"<td>{gratio}</td>")

            if aratio <= 1.1:
                write(f"<td bgcolor='#fffacd'>{aratio}</td>")
            else:
                write(f"<td>{aratio}</td>")

            if dratio <= 1.1:
                write(f"<td bgcolor='#fffacd'>{dratio}</td>")
            else:
                write(f"<td>{dratio}</td>")
            # print " + Best Area" if(aratio < 1.0001)
            # print " + Best Delay" if(dratio < 1.0001)

            write("</tr>")

            # if((dratio < 1.15) && (aratio < 1.15)){
            #  printf (" <== Best Ratio: %.3f - %.3f\n", aratio, dratio)
            # } else {
            #  print "\n"
            # }
    write("</table>")

    # printf ("Startegy\tGates\tArea\tDelay\tGR\tAR\tDR\n")
    c = 0
    colors = [
        "red",
        "olive",
        "yellow",
        "green",
        "blue",
        "purple",
        "grey",
        "black",
        "aqua",
        "fuchsia",
        "orange",
        "tan",
    ]

    write(
        """
  </div>
    <div style='width:65%''>
      <canvas id='myChart'></canvas>
    </div>



  <script>
  var ctx = document.getElementById('myChart');
  var color = Chart.helpers.color;
  var scatterChart = new Chart(ctx, {
      type: 'scatter',

      data: {
          datasets: [

  """
    )

    for line in file_lines:
        # print chomp(line)
        # data = line.split()
        if "none" in line:
            c = c + 1

            delay_m = delay_rx.search(line)
            delay = float(delay_m[1])
            area_m = area_rx.search(line)
            area = float(area_m[1])

            # dfactor = 0.25 * area / minArea + 0.75 * delay / minDelay
            # afactor = 0.75 * area / minArea + 0.25 * delay / minDelay

            label = f"S{c}"
            color = colors[c - 1 % len(colors)]

            write(
                f"""{{
          label: '{label}',
          borderColor: window.chartColors.{color},
          backgroundColor: color(window.chartColors.{color}).alpha(0.2).rgbString(),
          pointRadius: 7,
          data: [{{
              x: {area},
              y: {delay}
          }}]
      }},"""
            )

    write(
        """
  ]
  },
  options: {
    title: {
          display: true,
          text: 'Synthesis Strategies Comparison'
      },
      scales: {
          xAxes: [{
              type: 'linear',
              position: 'bottom',
              scaleLabel: {
                display: true,
                labelString: 'Area'
              }
          }],
          yAxes: [{
              type: 'linear',
              position: 'left',
              scaleLabel: {
                display: true,
                labelString: 'Delay'
              }
          }]
      }
  }
  });
  </script>

  </body>

  </html>
  """
    )
    output_file_handle.close()


if __name__ == "__main__":
    cli()
