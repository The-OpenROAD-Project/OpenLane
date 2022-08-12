v {xschem version=3.0.0 file_version=1.2 }
G {}
K {}
V {}
S {}
E {}
N 170 10 300 10 {
lab=y}
N -0 150 430 150 {
lab=GND}
N 430 40 430 150 {
lab=GND}
N 300 70 300 150 {
lab=GND}
N 0 150 -0 170 {
lab=GND}
N -290 150 -0 150 {
lab=GND}
N -400 150 -290 150 {
lab=GND}
N -400 -30 -130 -30 {
lab=a}
N -400 30 -400 150 {
lab=GND}
N 170 -30 270 -30 {
lab=vpwr}
N 170 -10 270 -10 {
lab=vpwr}
N 270 -30 270 -10 {
lab=vpwr}
N 270 -30 430 -30 {
lab=vpwr}
N 430 -30 430 -10 {
lab=vpwr}
N 170 30 260 30 {
lab=GND}
N 170 50 260 50 {
lab=GND}
N 260 30 260 50 {
lab=GND}
N 260 50 260 150 {
lab=GND}
N -290 -10 -130 -10 {
lab=b}
N -290 90 -290 150 {
lab=GND}
N -290 -10 -290 30 {
lab=b}
C {my_nand.sym} 20 10 0 0 {name=x1}
C {devices/vsource.sym} -290 60 0 0 {name=V1 value="PULSE(0 vpwr_value 15ns 1ns 1ns 9ns 20ns)"}
C {devices/capa.sym} 300 40 0 0 {name=C1
m=1
value=16f
footprint=1206
device="ceramic capacitor"}
C {devices/gnd.sym} 0 170 0 0 {name=l1 lab=GND}
C {devices/vsource.sym} -400 0 0 0 {name=V2 value="PULSE(0 vpwr_value 5ns 1ns 1ns 4ns 10ns)"}
C {devices/vsource.sym} 430 20 0 0 {name=V3 value=vpwr_value}
C {devices/code_shown.sym} -180 260 0 0 {name=s1 only_toplevel=false value="
.param vpwr_value=1.65
"}
C {sky130_fd_pr/corner.sym} 590 40 0 0 {name=CORNER only_toplevel=false corner=ss}
C {devices/lab_wire.sym} 340 -30 0 0 {name=l2 sig_type=std_logic lab=vpwr}
C {devices/lab_wire.sym} 250 10 0 0 {name=l3 sig_type=std_logic lab=y}
C {devices/lab_wire.sym} -200 -30 0 0 {name=l4 sig_type=std_logic lab=a}
C {devices/lab_wire.sym} -200 -10 0 0 {name=l5 sig_type=std_logic lab=b}
C {devices/code_shown.sym} 130 260 0 0 {name=s2 only_toplevel=false value="
.temp 125


.control
tran 0.1n 60n
write
.endc

"}
C {devices/code_shown.sym} 290 250 0 0 {name=s3 only_toplevel=false value="
.meas tran rise_time TRIG v(y) VAL=vpwr_value*0.1 RISE=1 TARG v(y) VAL=vpwr_value*0.9 RISE=1
"}
