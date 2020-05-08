function Lut = contrast_HE_LUT(Iin)
    %% Init array: array
    array=zeros(1,256); 
    %% Gen Cumulative Histogram: ch
    histogram = imhist(Iin);
    ch = cumsum(histogram);
    %% Gen LUT using transfer function for each pixel value: Lut 
    for i=0:255
        Lut = max(0,round((256*ch(i+1)/numel(Iin)) - 1));
        array(i+1) = Lut;
    end
    %% Return: Lut
    Lut=uint8(array);
end

