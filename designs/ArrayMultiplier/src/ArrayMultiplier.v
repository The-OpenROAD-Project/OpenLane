module Cell(output Cnext, Sthis, input xn, am, Slast, Cthis);

  wire t;
  and (t, xn, am);

  xor (Sthis, t, Slast, Cthis);
  xor (t1, Slast, Cthis);
  and (t2, t, t1);
  and (t3, Cthis, Slast);
  or (Cnext, t2, t3);
  
endmodule

module FACell(output Cnext, Sthis, input xn, am, Cthis);
  
  wire t1, t2, t3;
  xor (t1, am, xn);
  and (t2, t1, Cthis);
  and (t3, am, xn);
  or (Cnext, t2, t3);
  xor (Sthis, t1, Cthis);

endmodule

module ArrayMultiplier(product, a, x);
  
  parameter m = 64;
  parameter n = 64;
  output [m+n-1:0] product;
  input [m-1:0] a;
  input [n-1:0] x;
  
  wire c_partial[m*n:0] ;
  wire s_partial[m*n:0] ;
  
  // first line of the multiplier
  genvar i;
  generate
    for(i=0; i<m; i=i+1)
    begin
      Cell c_first(.Cnext(c_partial[i]), .Sthis(s_partial[i]),
                   .xn(x[0]), .am(a[i]), .Slast(1'b0), .Cthis(1'b0));
    end
  endgenerate
  
  
  // middle lines of the multiplier - except last column
  genvar j, k;
  generate
    for(k=0; k<n-1; k=k+1)
    begin
      for(j=0; j<m-1; j=j+1)
      begin
        Cell c_middle(c_partial[m*(k+1)+j], s_partial[m*(k+1)+j],
                      x[k+1], a[j], s_partial[m*(k+1)+j-m+1], c_partial[m*(k+1)+j-m]);
      end
    end
  endgenerate
  
  // middle lines of the multiplier - only last column
  genvar z;
  generate
    for(z=0; z<n-1; z=z+1)
    begin
      Cell c_middle_last_col(c_partial[m*(z+1)+(m-1)], s_partial[m*(z+1)+(m-1)],
                             x[z+1], a[+(m-1)], 1'b0, c_partial[m*(z+1)+(m-1)-m]);
    end
  endgenerate
  
  // last line of the multiplier
  wire c_last_partial[m-1:0] ;
  wire s_last_partial[m-2:0] ;
  buf (c_last_partial[0], 0);
  
  genvar l;
  generate
    for(l=0; l<m-1; l=l+1)
    begin
      FACell c_last(c_last_partial[l+1], s_last_partial[l],
                    c_partial[(n-1)*m+l], s_partial[(n-1)*m+l+1], c_last_partial[l]);
    end
  endgenerate
  
  
  // product bits from first and middle cells
  generate
    for(i=0; i<n; i=i+1)
    begin
      buf (product[i], s_partial[m*i]);
    end
  endgenerate
  
  // product bits from the last line of cells
  generate
    for(i=n; i<n+m-1; i=i+1)
    begin
      buf (product[i], s_last_partial[i-n]);
    end
  endgenerate
    
  // msb of product
  buf (product[m+n-1], c_last_partial[m-2]);

endmodule
