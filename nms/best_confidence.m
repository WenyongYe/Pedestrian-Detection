function [best_cv] = best_confidence(box_in,img_boxes)
    best_cv = 0;
    for i=1:size(img_boxes,1)
        img_box = img_boxes(i,:);
        box_intersect_area = rectint(box_in,img_box);
        union_area = (box_in(3)*box_in(4))+(img_box(3)*img_box(4))-box_intersect_area;
        value = box_intersect_area/union_area;
        
        if value > best_cv
            best_cv = value;
        end
    end
end

