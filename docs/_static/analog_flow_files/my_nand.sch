v {xschem version=3.0.0 file_version=1.2 }
G {}
K {}
V {}
S {}
E {}
N 130 -50 200 -50 {
lab=VBN}
N 200 -60 200 -50 {
lab=VBN}
N 200 -60 240 -60 {
lab=VBN}
N 200 -50 200 60 {
lab=VBN}
N 130 60 200 60 {
lab=VBN}
N 130 90 130 180 {
lab=VGND}
N 130 180 170 180 {
lab=VGND}
N 130 -20 130 30 {
lab=#net1}
N 130 -130 130 -80 {
lab=Y}
N 410 -130 410 -100 {
lab=Y}
N 410 -100 490 -100 {
lab=Y}
N 130 -100 410 -100 {
lab=Y}
N 130 -160 260 -160 {
lab=VBP}
N 260 -160 410 -160 {
lab=VBP}
N 240 -260 260 -260 {
lab=VPWR}
N 240 -260 240 -220 {
lab=VPWR}
N 130 -220 130 -190 {
lab=VPWR}
N 410 -220 410 -190 {
lab=VPWR}
N 130 -220 410 -220 {
lab=VPWR}
N 20 -110 50 -110 {
lab=A}
N 50 -160 50 -110 {
lab=A}
N 50 -160 90 -160 {
lab=A}
N 50 -110 50 -50 {
lab=A}
N 50 -50 90 -50 {
lab=A}
N 450 -160 540 -160 {
lab=B}
N 10 60 90 60 {
lab=B}
C {sky130_fd_pr/nfet_01v8.sym} 110 -50 0 0 {name=M1
L=0.15
W=0.65
nf=1 
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/pfet_01v8.sym} 110 -160 0 0 {name=M2
L=0.15
W=1
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=pfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/pfet_01v8.sym} 430 -160 2 0 {name=M3
L=0.15
W=1
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=pfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet_01v8.sym} 110 60 0 0 {name=M4
L=0.15
W=0.65
nf=1 
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {devices/iopin.sym} 250 -260 0 0 {name=p1 lab=VPWR}
C {devices/iopin.sym} 250 -160 0 0 {name=p2 lab=VBP}
C {devices/iopin.sym} 230 -60 0 0 {name=p3 lab=VBN}
C {devices/iopin.sym} 160 180 0 0 {name=p4 lab=VGND}
C {devices/ipin.sym} 20 -110 0 0 {name=p5 lab=A}
C {devices/ipin.sym} 20 60 0 0 {name=p6 lab=B}
C {devices/opin.sym} 480 -100 0 0 {name=p7 lab=Y}
C {devices/lab_pin.sym} 540 -160 2 0 {name=l1 sig_type=std_logic lab=B}
