function [value] = crop_confidence(box_in,img_box)
    %Return overlap_ratio between two boxes       
    box_intersect_area = rectint(box_in,img_box);
    union_area = (box_in(3)*box_in(4))+(img_box(3)*img_box(4))-box_intersect_area;
    value = box_intersect_area/union_area;
end