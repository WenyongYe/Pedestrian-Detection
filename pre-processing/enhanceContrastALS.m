function images = enhanceContrastALS(images, num_row, num_col)
    %linear stretching without user input
    %automatically generate parameter m,c
    
    %Iin: input image
    %noise: number of noise pixels to be ignored
    
    %define the first and last 10 pixels as noise
    noise=10;
    %retrieve each image 
    for i = 1:size(images,1)
        
        Iin_vector = images(i,:);
        Iin_reshape = reshape(Iin_vector,num_row,num_col);       
        Iin = uint8(Iin_reshape);
        %Sort image pixels in ascending order
        sorted=sort(Iin(:));
        sorted=double(sorted);
        
        %min and max value used for linear stretching
        minVal = sorted(noise + 1);
        maxVal = sorted(size(sorted,1) - noise);   
        %calculate parameters
        coe=polyfit([minVal,maxVal],[0,255],1);
        %generate look-up table
        Lut = contrast_LS_LUT(coe(1),coe(2));
        Iout = intlut(Iin,Lut);        
        Iout_reshape = reshape(Iout,1,num_row * num_col);
        %output images
        images(i,:) = Iout_reshape;
    end
end