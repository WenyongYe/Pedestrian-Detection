rng(3061);
clear all
close all

%Import Config and Training images
cd util
config = importConfig('config.txt');
cd ../import

disp("Loading Training Images..."); % - Takes a couple of minutes to load all 3000
 
%images is in the form of a vector where  each row is an image of length
%image_width * image_height. i.e. 96 by 160 image becomes a 15360 pixel vector  
[tt_images, tt_labels, num_row, num_col] = loadModelImages('model_images.cdataset', config.samplingCount, config.balanceData);
cd ../

images = tt_images;
labels = tt_labels;
disp("Finished Loading Training Images");

%Apply preprocessing
if config.prepro == 1
    cd pre-processing
    
    if strcmp(config.preproMethod,"ALS")
        disp("Automatic linear stretching");
        images = enhanceContrastALS(images, num_row, num_col);
    end
    
    if strcmp(config.preproMethod,"HE")
        disp("Histogram Equalisation");
        images = enhanceContrastHE(images, num_row, num_col);
    end 
   
    if strcmp(config.preproMethod,"AGC")
        disp("Gamma correction");
        images = enhanceContrastAGC(images, num_row, num_col);
    end
    
    cd ../
end

%Apply feature descriptor - if set to 0, raw images are used
if config.featureExtraction == 1
   cd feature-descriptor   
   %HOG
   if strcmp(config.featureDescriptor,"HOG")
      disp("HOG Feature Descriptor");
      image_hog_vector = applyHog(images, num_row, num_col);
   end
   
   %pca
   if strcmp(config.featureDescriptor,"PCA")
      disp("PCA Feature Descriptor");
      cd PCA
      [eigenVectors, eigenvalues, meanX, image_pca_vector] = PrincipalComponentAnalysis (images);
      cd ../
   end
   
   cd ../
end


% Dividing dataset into training and testing
% Two main options: Half/Half and Cross validation
if strcmp(config.dd,"HH")
    cd data-division
    disp("Splitting Dataset by half/half");
    
    % Split Images in half
    [train_images, test_images] = halfhalf(images);
    % Split labels in half
    [train_labels, test_labels] = halfhalf(labels);
    
    if config.featureExtraction == 1
    
    if strcmp(config.featureDescriptor,"HOG") % - If HOG fd is being used
        [train_hog_vector, test_hog_vector] = halfhalf(image_hog_vector);
    end
    
    
    if strcmp(config.featureDescriptor,"PCA") % - If PCA fd is being used
        [train_pca_vector, test_pca_vector] = halfhalf(image_pca_vector);
    end
   
    end
    cd ../
end


%Apply Classification

% SVM
if strcmp(config.classifier,"SVM")
   cd classifier/svm
   
   % - Start SVM-HH
   if strcmp(config.dd,"HH")
      disp("Training SVM Model w/ HH"); 
   
      if config.featureExtraction == 1
      %HOG
      if strcmp(config.featureDescriptor,"HOG")
          modelSVM = fitcsvm(train_hog_vector, train_labels); 
      end
   
      %PCA
      if strcmp(config.featureDescriptor,"PCA")
          modelSVM = fitcsvm(train_pca_vector, train_labels); 
      end
      
      else
          modelSVM = fitcsvm(train_images, train_labels);
      end
      
      disp("Testing SVM Model");
   
      for i=1:size(test_images,1)
          testnumber = i;
        
          if config.featureExtraction == 1
          %HOG
          if strcmp(config.featureDescriptor,"HOG")
              testnumber = test_hog_vector(i,:);
          end
          
           %PCA
          if strcmp(config.featureDescriptor,"PCA")
              testnumber = test_pca_vector(i,:);
          end
         
          else
             testnumber = test_images(i,:); 
          end
          classificationResult(i,:) = predict(modelSVM,testnumber);
      end
      
      labels = test_labels;
   
      disp("Finished SVM Model w/ HH");
   
   end
   % - End SVM-HH
   
   % - Start SVM-CV
   if strcmp(config.dd,"CV")
       
       disp("Training SVM Model w/ CV");
      
       if strcmp(config.featureDescriptor,"HOG")
        
        % - Hyper praramters based off analysis from report
        modelSVM = fitcsvm(image_hog_vector,labels,'BoxConstraint',0.0072031,'KernelScale', 0.0083882);
        cvmodelSVM = crossval(modelSVM,'KFold', 10);
       end
       
       if strcmp(config.featureDescriptor,"PCA")
           modelSVM = fitcsvm(image_pca_vector, labels);
           cvmodelSVM = crossval(modelSVM,'KFold', 10);
       end

       classificationResult = kfoldPredict(cvmodelSVM);
       
       model = modelSVM;
       disp("Finished SVM Model w/ CV");
   end
   % - End SVM-CV
   
   cd ../../
end




% KNN
if strcmp(config.classifier,"KNN")
    k_val = config.knnVal;
    cd classifier/KNN
    
    % - Start KNN-HH
    if strcmp(config.dd,"HH")
        disp("Training K-NN Model w/ HH"); 
        
        if strcmp(config.featureDescriptor,"HOG")
            modelKNN=KNNTraining(train_hog_vector,train_labels);
        end
        
        %PCA
        if strcmp(config.featureDescriptor,"PCA")
            modelKNN = KNNTraining(train_pca_vector, train_labels); 
        end
         
        disp("Testing KNN Model");
        
        for i=1:size(test_images,1)
            testnumber = i;
            
            if strcmp(config.featureDescriptor,"HOG")
              testnumber = test_hog_vector(i,:);
            end
            
            %PCA
            if strcmp(config.featureDescriptor,"PCA")
              testnumber = test_pca_vector(i,:);
            end

            classificationResult(i,:) = KNNTesting(testnumber,modelKNN,k_val);
        end
        
        labels = test_labels;
   
        disp("Finished KNN Model w/ HH");
    end
    % - End KNN-HH
    
    % - Start KNN-CV
    if strcmp(config.dd,"CV")
        disp("Training K-NN Model w/ CV"); 
        
        %HOG
        if strcmp(config.featureDescriptor,"HOG")
            modelKNN = fitcknn(image_hog_vector,labels,'NumNeighbors',k_val);
            cvmodelKNN = crossval(modelKNN,'Kfold',10);
        end
        
        %PCA
        if strcmp(config.featureDescriptor,"PCA")
           modelKNN = fitcknn(image_pca_vector,labels,'NumNeighbors',k_val);
           cvmodelKNN = crossval(modelKNN,'Kfold', 10);
        end

        classificationResult = kfoldPredict(cvmodelKNN);
        
        disp("Finished K-NN Model w/ CV");
    end
   cd ../../
end

% - Random Forest
if strcmp(config.classifier,"RF")
    disp("Training RF Model w/ HH"); 
    nTrees = 256;
    if config.featureExtraction == 1
        if strcmp(config.featureDescriptor,"HOG")
        modelRF = TreeBagger(nTrees, train_hog_vector, train_labels,'OOBPrediction','On','Method', 'classification');
        end
        
        if strcmp(config.featureDescriptor,"PCA")
        modelRF = TreeBagger(nTrees, train_pca_vector, train_labels,'OOBPrediction','On','Method', 'classification');
        end
    else
        modelRF = TreeBagger(nTrees, train_images, train_labels,'OOBPrediction','On','Method', 'classification');
    end
    for i = 1:size(test_images,1)
        
        if config.featureExtraction == 1
            if strcmp(config.featureDescriptor,"HOG")
            testnumber = test_hog_vector(i,:);
            end
            
            if strcmp(config.featureDescriptor,"PCA")
            testnumber = test_pca_vector(i,:);
            end
        else
           testnumber = test_images(i,:); 
        end
        
        predChar1 = modelRF.predict(testnumber);
        classificationResult(i,:) = str2double(predChar1);
    end
    
    labels = test_labels;
    
    model = modelRF;
    
    disp("Finished RF Model w/ HH"); 
end


%Evaluation
comparison = (labels==classificationResult);

Accuracy = sum(comparison)/length(comparison)

%Evaluation: Evaluation matrix
cd evaluation 

[TP,FP,FN,TN]=evaluation_matrix(labels,classificationResult);

%Evaluation: ROC curve
ROC(classificationResult,labels);

cd ../

if config.swd == 1
cd import
%Change number of images to be processed here: img_num
img_num = 100;
[pedestrian_images, numPedestrians, num_row, num_col,bounding_boxes] = loadPedestrianImages('pedestrian_images.cdataset',img_num);
cd ../



cd pre-processing
if strcmp(config.preproMethod,"AGC")
        disp("Gamma correction");
        pp_pedestrian_images = enhanceContrastAGC(pedestrian_images, num_row, num_col);
end

if strcmp(config.preproMethod,"ALS")
        disp("Automatical linear stretching");
        pp_pedestrian_images = enhanceContrastALS(pedestrian_images, num_row, num_col);
end

if strcmp(config.preproMethod,"HE")
        disp("Histogram equalization");
        pp_pedestrian_images = enhanceContrastHE(pedestrian_images, num_row, num_col);
end
cd ../


    disp("Beginning Sliding Window Detection");
    %Variables that need initialised: ignore
    swd_results = [];
    least_accurate = 100;
    least_accurate_index = 0;
    average_sum = 0;
    most_missed = 0;
    most_missed_index= 0;
    total_missed = 0;
    
    %Scales to use 
    %scales = [[108,180];[84,140];[96,160];[120,200];[132,220];[144,240];[156,260]];
    %scales = [[120,200];[96,160]];
    scales = [[20,40];[50,130];[90,240]];
    %NMS overlap threshold to use
    nms_ol = 0.5;
    
    %NMS ground truth threshold to use
    nms_gt = 0.2;
    
    total_people = 0;
    for i=1:img_num
        cd sliding-window
        disp("Image number: "+i);
        for j=1:size(scales,1)
            disp("Processing Scale: ["+scales(j,1)+","+scales(j,2)+"]");
            if j==1
                b_boxes = apply_swd(pp_pedestrian_images,i,num_row,num_col,modelSVM,scales(j,:),config);
            else
                b_boxes = [b_boxes; apply_swd(pp_pedestrian_images,img_num,num_row,num_col,modelSVM,scales(j,:),config)];
            end
        end
        cd ../
        cd nms
        disp("Processing NMS");
        disp(" ");        
        [b_boxes,total,missed,accuracy] = nms(b_boxes,nms_ol,bounding_boxes(i,:),nms_gt);
        %[b_boxes,total,missed,accuracy] = basic_nms(b_boxes,bounding_boxes(i,:),nms_ol,nms_gt);
        cd ../
        
        %Store the least accurate image and the one where we missed the
        %most people
        
        if missed > most_missed
            most_missed = missed;
            most_missed_index = i;
        end
        if accuracy < least_accurate
            least_accurate = accuracy;
            least_accurate_index = i;
        end
        
        total_people = total_people + total;
        total_missed = total_missed + missed;
        average_sum = average_sum + accuracy; 
        
         %Add results as cell to results
         swd_results{1,i} = b_boxes; %#ok<SAGROW>
     end
    %Averages
    if total_missed ~= 0
        average_missed = total_missed/total_people; 
    else
        average_missed = 0;
    end
    average_accuracy = average_sum/img_num;
        
    %Results Video
    cd video
    create_video(swd_results,pp_pedestrian_images,pedestrian_images,num_row,num_col);
    cd ../
    
    %SWD Evaluation
    cd evaluation
    swd_evaluation(most_missed,least_accurate,average_missed,average_accuracy,most_missed_index,least_accurate_index,scales,nms_ol,nms_gt,swd_results,pedestrian_images,num_row,num_col,bounding_boxes);
    cd ../
end