function [b_boxes] = sliding_window2(image,scale,model,config)
    row = 1;
    col = 1;
    [maxCol, maxRow] = size(image);
    
    %divisor determines how much windows overlap. 
    %EG: 1 = no overlap
    col_sep = scale(2)/7;
    row_sep = scale(1)/7;

    windowMax = 1;
    for y = col:col_sep:maxCol-scale(2)   
        for x = row:row_sep:maxRow-scale(1)
            windowMax = windowMax+1;
        end
    end

    results = zeros(windowMax,1);
    boundingBox = zeros(windowMax,4);
    windowNumber = 1;
    
%PCA in swd if needed (time consuming)
%     %extract all crop images and pass them into PCA
%
%     imgs=[];
%      for y = col:col_sep:maxCol-scale(2)   
%         for x = row:row_sep:maxRow-scale(1)
%             po = [x, y, scale(1), scale(2)];
%             img = crop_img(po, image); 
%             img = imresize(img,[160,96]);
%            
%            %flat the image
%             img=reshape(img,1,[]);
%             imgs=[imgs;img];
%         end
%      end
%      %PCA running
%
%      cd ../feature-descriptor/PCA 
%      [eigenVectors, eigenvalues, meanX, feature_vectors] = PrincipalComponentAnalysis(imgs,5000);
%      cd ../
%      cd ../
%      
%      cd sliding-window
%      num=1;

    for y = col:col_sep:maxCol-scale(2)   
        for x = row:row_sep:maxRow-scale(1)
            po = [x, y, scale(1), scale(2)];
            img = crop_img(po, image); 
            img = imresize(img,[160,96]);
            cd ../
            %What feature destriptor will we use: HOG or PCA
            cd feature-descriptor
            if strcmp(config.featureDescriptor,"HOG")
                feature_vector = hog_feature_vector(img);
            end
%             if strcmp(config.featureDescriptor,"PCA")
%                 feature_vector=feature_vectors(num,:);
%                 num=num+1;
%             end
            cd ../
            %What classifier will we use: SVM or KNN

            %MODEL
            if strcmp(config.classifier,"SVM")
                cd classifier/svm
                if(strcmp(config.dd,"HH"))
                
                results(windowNumber) = SVMTesting(feature_vector,model);
                
                end
                
                if(strcmp(config.dd,"CV"))
                    results(windowNumber) = predict(model,feature_vector);
                end
                cd ../../
            end
            if strcmp(config.classifier,"KNN")
                cd classifier/KNN
                results(windowNumber) = KNNTesting(feature_vector,model);
                cd ../../
            end
            cd sliding-window
            boundingBox(windowNumber, 1) = x;
            boundingBox(windowNumber, 2) = y;
            boundingBox(windowNumber, 3) = scale(1);
            boundingBox(windowNumber, 4) = scale(2);
            windowNumber = windowNumber+1;
        end
    end
    b_boxes = boundingBox(results == 1, :);
end

