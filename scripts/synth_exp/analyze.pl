#!/usr/bin/perl
# Copyright 2020 Mohamed Shalan
#
# Licensed under the Apache License, Version 2.0 (the "License");
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
open (myfile, $ARGV[0]) || die "couldn't open the file!";

$aw = 0.5;
$dw = 0.5;
$ascale = 100;
$minArea = 1000000000;
$minGates = $minArea;
$minDelay = $minArea;
$bestArea = "";
$bestDelay = "";
$sn = "";
while (<myfile>) {
  #print chomp($line);
  if(/none/){
    m/Delay\s+\=\s+(\S+)/;
    my $delay = $1;
    m/Area\s+\=\s+(\S+)/;
    my $area = $1;

    my @data = split;
    #print "$_";
    my $factor = $aw*$area/$ascale + $dw*$delay;
    #print "$data[6]\t$area\t$delay\n";
    if($area < $minArea) {
      $minArea = $area;
      $bestArea = $sn;
    }
    if($delay < $minDelay) {
      $minDelay = $delay;
      $bestDelay = $sn;
    }
    if($data[6] < $minGates) {
      $minGates = $data[6];
      $bestGates = $sn;
    }

  } else {
    my @data = split;
    #print "$_";
    #print "$data[3]\t\t";
    $sn = $data[3];
  }
}
#print "Best Gate Count: $minGates ($bestGates)\n";
#print "Best Area: $minArea ($bestArea)\n";
#print "Best Delay: $minDelay ($bestDelay)\n";

seek myfile, 0, 0;

#printf ("Startegy\tGates\tArea\tDelay\tGR\tAR\tDR\n");

print "
<html>

<head>
  <title>Scatter Chart</title>
  <link href='table.css' rel='stylesheet' type='text/css' media='screen' />
  <script src='https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.2/Chart.min.js'></script>
  <script src='utils.js'></script>
  <style>
  canvas {
    -moz-user-select: none;
    -webkit-user-select: none;
    -ms-user-select: none;
  }
  </style>
</head>

<body>
<div style='width:50%''>

<table cellspacing='0' cellpadding='0' class='demo-table' >
<tr>
  <th bgcolor='B0C4DE'>Best Area</th>
  <th bgcolor='B0C4DE'>Best Gate Count</th>
  <th bgcolor='B0C4DE'>Best Delay</th>
</tr>
<tr>
  <td>$minArea</td>
  <td>$minGates</td>
  <td>$minDelay</td>
</tr>
<tr>
  <td>$bestArea</td>
  <td>$bestGates</td>
  <td>$bestDelay</td>
</tr>
</table><br>

<table cellspacing='0' cellpadding='0' class='demo-table' >
<tr>
  <th bgcolor='B0C4DE'>Startegy</th>
  <th bgcolor='B0C4DE'>Gate Count</th>
  <th bgcolor='B0C4DE'>Area (um^2)</th>
  <th bgcolor='B0C4DE'>Delay (ps)</th>

  <th bgcolor='B0C4DE'>Gates Ratio</th>
  <th bgcolor='B0C4DE'>Area Ratio</th>
  <th bgcolor='B0C4DE'>Delay Ratio</th>

</tr>
";


my $cntr =0;
while (<myfile>) {
  #print chomp($line);
  if(/none/){

    $cntr++;
    print "<tr>\n";

    m/Delay\s+\=\s+(\S+)/;
    my $delay = $1;
    m/Area\s+\=\s+(\S+)/;
    my $area = $1;

    my @data = split;
    #print "$_";

    my $dfactor = 0.25*$area/$minArea + 0.75*$delay/$minDelay;
    my $afactor = 0.75*$area/$minArea + 0.25*$delay/$minDelay;

    $dratio = int($delay/$minDelay*1000)/1000;
    $aratio = int($area/$minArea*1000)/1000;
    $gratio = int($data[6]/$minGates*1000)/1000;

    #printf ("%.0f\t%.0f\t%.0f\t%.3f\t%.3f\t%.3f",$data[6],$area,$delay,$data[6]/$minGates,$area/$minArea,$delay/$minDelay);
    print "<td>S$cntr: $sn</td>\n";

    if($gratio < 1.0001) {
      print "<td bgcolor='#ccff99'>$data[6]</td>\n";
    } else {
      print "<td>$data[6]</td>\n";
    }

    if($aratio < 1.0001) {
      print "<td bgcolor='#ccff99'>$area</td>\n";
    } else {
      print "<td>$area</td>\n";
    }

    if($dratio < 1.0001) {
      print "<td bgcolor='#ccff99'>$delay</td>\n";
    } else {
      print "<td>$delay</td>\n";
    }

    if($gratio <= 1.1){
      print "<td bgcolor='#FFFACD'>$gratio</td>\n";
    } else {
      print "<td>$gratio</td>\n";
    }

    if($aratio <= 1.1) {
      print "<td bgcolor='#FFFACD'>$aratio</td>\n";
    } else {
      print "<td>$aratio</td>\n";
    }

    if($dratio <= 1.1) {
      print "<td bgcolor='#FFFACD'>$dratio</td>\n";
    } else {
      print "<td>$dratio</td>\n";
    }
    #print " + Best Area" if($aratio < 1.0001);
    #print " + Best Delay" if($dratio < 1.0001);

    print "</tr>\n";

    #if(($dratio < 1.15) && ($aratio < 1.15)){
    #  printf (" <== Best Ratio: %.3f - %.3f\n", $aratio, $dratio);
    #} else {
    #  print "\n";
    #}

  } else {
    my @data = split;
    #print "$_";
    #print "$data[3]\t";
    $sn = $data[3];
  }
}
print "</table>\n";

seek myfile, 0, 0;

#printf ("Startegy\tGates\tArea\tDelay\tGR\tAR\tDR\n");
my $cntr = 0;
my @colors = (  "red", "olive", "yellow",
                "green", "blue", "purple",
                "grey", "black", "aqua",
                "fuchsia" , "orange", "tan"
              );

print "
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

";
while (<myfile>) {
  #print chomp($line);

  if(/none/){
    $cntr = $cntr + 1;
    m/Delay\s+\=\s+(\S+)/;
    my $delay = $1;
    m/Area\s+\=\s+(\S+)/;
    my $area = $1;

    my @data = split;
    #print "$_";

    my $dfactor = 0.25*$area/$minArea + 0.75*$delay/$minDelay;
    my $afactor = 0.75*$area/$minArea + 0.25*$delay/$minDelay;

    #printf ("%.0f\t%.0f\t%.0f\t%.3f\t%.3f\t%.3f",$data[6],$area,$delay,$data[6]/$minGates,$area/$minArea,$delay/$minDelay);

    #$dratio = $delay/$minDelay;
    #$aratio = $area/$minArea;

    my $label = "S".$cntr;
    my $color = $colors[$cntr-1];

    print "{
        label: '$label',
        borderColor: window.chartColors.$color,
        backgroundColor: color(window.chartColors.$color).alpha(0.2).rgbString(),
        pointRadius: 7,
        data: [{
            x: $area,
            y: $delay
        }]
    },";


  } else {
    my @data = split;
    #print "$_";
    #print "$data[3]\t";
    $sn = $data[3];
  }
}
close(myfile);

print "
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

";

print "\n";
