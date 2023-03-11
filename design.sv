// Code your design here

module Braun_multiplier(input [3:0]x,[3:0]y,output [7:0]p);
wire [3:0]t0;
wire [3:0]t1;
wire [3:0]t2;
wire [3:0]t3;

wire [3:0]c1;
wire [3:0]c2;
wire [3:0]c3;
wire [3:0]c4;

wire [3:0]s1;
wire [3:0]s2;
wire [3:0]s3;
wire [3:0]s4;

assign p[0]=t0[0];
assign p[1]=s1[0];
assign p[2]=s2[0];
assign p[3]=s3[0];
assign p[4]=s4[0];
assign p[5]=s4[1];
assign p[6]=s4[2];
assign p[7]=c4[2];



and x3y0 (t0[3],y[0],x[3]) ,             x2y0 (t0[2],y[0],x[2]),             x1y0 (t0[1],y[0],x[1]) ,             x0y0 (t0[0],y[0],x[0]);


and x3y1 (t1[3],y[1],x[3]) ,             x2y1 (t1[2],y[1],x[2]),             x1y1 (t1[1],y[1],x[1]) ,             x0y1 (t1[0],y[1],x[0]);

                             FA f21(t0[3],1'b0,t1[2],c1[2],s1[2]),  f11(t0[2],1'b0,t1[1],c1[1],s1[1]),   f01(t0[1],1'b0,t1[0],c1[0],s1[0]);


and x3y2 (t2[3],y[2],x[3]) ,              x2y2 (t2[2],y[2],x[2]),              x1y2 (t2[1],y[2],x[1]) ,              x0y2 (t2[0],y[2],x[0]);

                             FA f22(t1[3],c1[2],t2[2],c2[2],s2[2]),  f12(s1[2],c1[1],t2[1],c2[1],s2[1]),   f02(s1[1],c1[0],t2[0],c2[0],s2[0]);



and x3y3 (t3[3],y[3],x[3]) ,              x2y3 (t3[2],y[3],x[2]),              x1y3 (t3[1],y[3],x[1]) ,              x0y3 (t3[0],y[3],x[0]);

                             FA f23(t2[3],c2[2],t3[2],c3[2],s3[2]),  f13(s2[2],c2[1],t3[1],c3[1],s3[1]),   f03(s2[1],c2[0],t3[0],c3[0],s3[0]);


                
           FA p6(t3[3],c3[2],c4[1],c4[2],s4[2]),       p5(s3[2],c3[1],c4[0],c4[1],s4[1]),  p4(s3[1],1'b0,c3[0],c4[0],s4[0]);


endmodule









module FA(input x,z,y,output c,s);
    wire t1,t2,t3;
    xor x1(t1,x,y),x2(s,t1,z);
    and a1(t2,x,y),a2(t3,t1,z);
    or r1(c,t2,t3);
endmodule




interface IF;
  logic[3:0]x;
  logic[3:0]y;
  logic[7:0]p;
endinterface

