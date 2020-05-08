function [nms_boxes,total_people,missed,accuracy] = nms(b_boxes, threshold, img_boxes,nms_gt)
         
    deleted = [];
    box_indexes = [];
    for i=1:size(b_boxes,1)
        box_indexes = [box_indexes;i];
    end
    
    %Extract indexes of img_boxes
    img_total = size(img_boxes,2);
    img_indexes = [];
    for i=1:img_total
        temp_box = img_boxes{1,i};
        if ~(isempty(temp_box))
            img_indexes = [img_indexes;i];
        end
    end  
    
    %Restructure img_boxes: img_indexes x 4
    img_boxes_rs = zeros(length(img_indexes),4);
    for i=1:length(img_indexes)
        temp_store = img_boxes(1,i);
        temp = temp_store{1,1};
        for j=1:length(temp)
            img_boxes_rs(i,j) = temp(j);
        end
    end
    
    %Edit restructured boxes to same system as b_boxes
    for i=1:size(img_boxes_rs,1)
        temp_box = img_boxes_rs(i,:);
        for j=1:4
            %Change each coord
            if j == 1
                img_boxes_rs(i,j) = (temp_box(1)-(temp_box(3)/2));
            end
            if j == 2
                img_boxes_rs(i,j) = (temp_box(2)-(temp_box(4)/2));
            end
            if j == 3
                img_boxes_rs(i,j) = temp_box(3);
            end
            if j == 4
                img_boxes_rs(i,j) = temp_box(4);
            end
        end
    end
                 
    %Ready for comparison

    
    %Loop will terminate when all indexes have been checked
    for i=1:size(b_boxes,1)
        cntr = 1;
        for j=1:size(b_boxes,1)
            if j ~= i               
                overlap = rectint(b_boxes(i,:),b_boxes(j,:));
                if overlap > threshold
                    overlapping_boxes(i,cntr) = j;
                    cntr = cntr + 1;
                end
            end
        end
    end
          
    %We now have record of overlaps for each b_box (overlapping_boxes)
    %For each of these overlaps we want confidence values

           
    
    %For each img_box: generate list of box indexes that overlap with it
    %This will be our list of 'ground-truth' boxes
    correct = correct_overlaps(b_boxes,img_boxes_rs,nms_gt);
    
    
    %Keep best fitting correct overlap
    kept_correct = [];
    
    
    
    %i = index of each img
    for i=1:size(correct,1)
        best_index = 0;
        best_cv = 0;
        best_area = 0;
        %j will iterate through all indexes of bbox recorded as correct for
        %i
        for j=1:size(correct,2)
            if j == 1 && correct(i,j) ~= 0 && ~(ismember(correct(i,j),deleted))
                best_index = correct(i,j);
                best_cv = crop_confidence(b_boxes(best_index,:),img_boxes_rs(i,:));
                best_area = (b_boxes(best_index,3)) * (b_boxes(best_index,4));
            else
                if correct(i,j) ~= 0 &&  ~(ismember(correct(i,j),deleted)) &&  ~(ismember(correct(i,j),kept_correct))
                    temp_index = correct(i,j);
                    temp_cv = crop_confidence(b_boxes(temp_index,:),img_boxes_rs(i,:));
                    temp_area = (b_boxes(temp_index,3)) * (b_boxes(temp_index,4));
                    if temp_cv > best_cv
                        best_index = temp_index;
                        best_cv = temp_cv;
                        best_area = temp_area;
                    else
                        if temp_cv == best_cv
                            if temp_area < best_area
                                best_index = temp_index;
                                best_cv = temp_cv;
                                best_area = temp_area;
                            end
                        end
                    end
                end
            end
        end
        %Add best_index to kept_correct
        kept_correct = [kept_correct; best_index];
    end
    
    
     for i=1:size(overlapping_boxes,1)
        box_i = b_boxes(i,:);
        cv_i = best_confidence(box_i,img_boxes_rs);
        area_i = box_i(3)*box_i(4);
        for j=1:size(overlapping_boxes,2)
            temp_index = overlapping_boxes(i,j);
            if temp_index ~= 0 && ~(ismember(i,deleted)) && ~(ismember(temp_index,deleted)) && ~(ismember(temp_index,kept_correct)) && ~(ismember(i,kept_correct))
                box_temp = b_boxes(temp_index,:);
                cv_temp = best_confidence(box_temp,img_boxes_rs);
                area_temp = box_temp(3)*box_temp(4);
                %Do we have to delete box_i or not
                if cv_temp > cv_i
                    %Delete box_i
                    deleted = [deleted;i];
                else
                    %If both have 0 cf, delete box_i if box is smaller
                    if cv_i == cv_temp 
                        if area_i <= area_temp
                            deleted = [deleted;i];
                        end
                    end
                end
            end
        end
     end
    
    
     %Any remaining overlap with our 'correct' boxes
     add_these = [];
     for i=1:size(overlapping_boxes,1)
         if ~(ismember(i,deleted)) && ~(ismember(i,kept_correct))
             for j=1:size(overlapping_boxes,2)
                 if (ismember(overlapping_boxes(i,j),kept_correct))
                     %delete i 
                     deleted = [deleted;i];
                     if ismember(overlapping_boxes(i,j),deleted)
                         %Add j 
                         add_these = [add_these;overlapping_boxes(i,j)];
                     end
                 end
             end
         end
     end
    
    
    %Create output box matrix
    cntr = 1;
    for i=1:size(b_boxes,1)
        if ~(ismember(i,deleted)) || (ismember(i,add_these))
            nms_boxes(cntr,:) = b_boxes(i,:);
            cntr = cntr + 1;
        end
    end 
    
    %EVALUATION STUFF
    %How many 'correct' boxes do we have
    num_correct = 0;
    for i=1:size(correct,1)
        present = false;
        for j=1:size(correct,2)
            if correct(i,j) ~= 0
                present = true;
            end
        end
        if present
            num_correct = num_correct + 1;
        end
    end
    %How many people are in the image
    total_people = size(img_boxes_rs,1);
        
    %Use nms_boxes as total amount of boxes since b_boxes will have
    %multiple scales picking up same false positive
    total_boxes = size(nms_boxes,1);
    
    %How many people did our detector miss
    missed = total_people - size(kept_correct,1);
    
    %Accuracy against false positives
    accuracy = (num_correct/total_boxes) * 100;
end