function Lut = contrast_LS_LUT(m,c)
%Look-up table for linear stretching
array=zeros(1,256);   
%straight line equation
for i=0:255
    if i < -c/m
        Lut = 0;
    elseif i > (255 - c)/m
        Lut = 255;
    else
        Lut = m*i+ c;
    end
    
   array(i+1)=Lut;
end
%return look-up table
   Lut=uint8(array);
end