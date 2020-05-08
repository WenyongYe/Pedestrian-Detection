function [correct] = correct_overlaps(b_boxes,img_boxes,nms_gt)
    %Store all boxes which cross overlap threshold with ground truth boxes (img_boxes) 
    correct = [];
    for i=1:size(img_boxes,1)
        %Check overlaps for each box
        cntr = 1;
        for j=1:size(b_boxes,1)
            b_box = b_boxes(j,:);
            img_box = img_boxes(i,:);
            box_intersect_area = rectint(b_box,img_box);
            union_area = (b_box(3)*b_box(4))+(img_box(3)*img_box(4))-box_intersect_area;
            overlap = box_intersect_area/union_area;
            
            if overlap >= nms_gt
                correct(i,cntr) = j;
                cntr = cntr + 1;           
            end
        end
    end
end

