function images = enhanceContrastAGC(images, num_row, num_col)

    for i = 1:size(images,1)

        Iin_vector = images(i,:);
        Iin_reshape = reshape(Iin_vector,num_row,num_col);
        
    
        Iin = uint8(Iin_reshape);
    
        Iout = lin2rgb(Iin);
    
        Iout_reshape = reshape(Iout,1,num_row * num_col);
        
        images(i,:) = Iout_reshape;
        
    end    
end

