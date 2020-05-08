function [] = swd_evaluation(miss,acc,av_miss,av_acc,most_miss_index,least_acc_index,scales,nms_overlap,nms_groundtruth,b_boxes,imgs,num_row,num_col,img_boxes)
        
    disp("--SWD EVALUATION: PARAMS--");
    disp(" ");
    %What were all the params (swd specific) that led to this result?
    %Scales used for window
    num_scales = size(scales,1);
    
     disp("--Scales used for window--");
     for i=1:size(scales,1)
        disp(i + ": ["+scales(i,1)+","+scales(i,2)+"]");
     end
    disp(" ");
    params = table(num_scales,nms_overlap,nms_groundtruth);
    disp(params);
       
    
    disp("--SWD EVALUATION: RESULTS--");
    average_misses = av_miss;
    average_accuracy = av_acc;
    disp("Misses: how many times detector doesn't pick up person within a certain ratio ");
    disp("Accuracy: ratio of positive pickups to false positive");
    disp(" ");
    results_table = table(average_misses,average_accuracy);
    disp(results_table);
   
    %Display least accurate image as figure 
    disp(" ");
    disp("Displaying the least accurate and image with the most box ratio misses");
    disp("Red bounding boxes represent people in image");
    
    figure();
    subplot(1,2,1)
    if least_acc_index ~= 0
        b_boxes_acc = b_boxes{1,least_acc_index};
        imshow(mat2gray(reshape(imgs(least_acc_index,:),num_row,num_col)));
        title("Image w/ highest false positive ratio (accuracy: "+acc+"%)")
        hold on
        for i=1:size(b_boxes_acc,1)
            bounding_box = b_boxes_acc(i,:);
            rectangle('Position',[bounding_box(1,1),bounding_box(1,2),bounding_box(1,3),bounding_box(1,4)],'EdgeColor', 'g','LineWidth',2)
        end
        daspect([1,1,1]);
        temp_boxes = img_boxes(least_acc_index,:);
        for i=1:size(temp_boxes,2)
            temp_cell = temp_boxes(i);
            for j=1:size(temp_cell,2)
                bounding_box2 = temp_cell{1,j}; 
                if ~(isempty(bounding_box2))
                    box_x = (bounding_box2(1)-(bounding_box2(3)/2));
                    box_y = (bounding_box2(2)-(bounding_box2(4)/2));
                    rectangle('Position',[box_x,box_y,bounding_box2(3),bounding_box2(4)],'EdgeColor', 'r','LineWidth',2)
                end
                daspect([1,1,1]);
            end
        end
    else
        disp("Detector maintained 100% accuracy throughout");
    end
    
    %Display image with most misses
     subplot(1,2,2) 
     if most_miss_index ~= 0
        b_boxes_miss = b_boxes{1,most_miss_index};
        imshow(mat2gray(reshape(imgs(most_miss_index,:),num_row,num_col)));
        title("Image that caused most misses with scale (misses: "+ miss+")")
        hold on
        for i=1:size(b_boxes_miss,1)
            bounding_box = b_boxes_miss(i,:);
            rectangle('Position',[bounding_box(1,1),bounding_box(1,2),bounding_box(1,3),bounding_box(1,4)],'EdgeColor', 'g','LineWidth',2)
        end
        daspect([1,1,1]);
        temp_boxes = img_boxes(most_miss_index,:);
        for i=1:size(temp_boxes,2)
            temp_cell = temp_boxes(i);
            for j=1:size(temp_cell,2)
                bounding_box2 = temp_cell{1,j}; 
                if ~(isempty(bounding_box2))
                    box_x = (bounding_box2(1)-(bounding_box2(3)/2));
                    box_y = (bounding_box2(2)-(bounding_box2(4)/2));
                    rectangle('Position',[box_x,box_y,bounding_box2(3),bounding_box2(4)],'EdgeColor', 'r','LineWidth',2)
                end
                daspect([1,1,1]);
            end
        end
     else
         disp("Nobody was missed in any of the images");
     end
end