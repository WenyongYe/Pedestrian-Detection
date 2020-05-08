function image_hog_vector = applyHog(images, num_row, num_col)
    for i=1:size(images,1)
        % - Image vector to apply HOG to
        Im_vector = images(i,:);
        % - HOG implementation requires 2D images
        Im_reshape = reshape(Im_vector,num_row,num_col);
        % - Apply HOG
        image_hog_vector(i,:) = hog_feature_vector(Im_reshape);
    end
end

