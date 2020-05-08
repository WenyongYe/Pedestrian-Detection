function [b_boxes] = apply_swd(images,img_num,num_row,num_col,model,scale,config)
    % - Image vector to apply HOG
    img_index = img_num;
    Im_vector = images(img_index,:);
    % - HOG implementation requires 2D images
    Im_reshape = reshape(Im_vector,num_row,num_col);
        
    [b_boxes] = sliding_window2(Im_reshape,scale,model,config); 
end

