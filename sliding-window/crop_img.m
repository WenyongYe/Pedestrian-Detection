%crop image using specified coords
function [out_img] = crop_img(po,in_img)
    %po == [x,y]
    out_img = imcrop(in_img,po);
end

