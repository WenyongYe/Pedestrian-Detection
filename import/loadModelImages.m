function [images, labels, num_row, num_col] = loadModelImages(filename, sampling, balance)

if nargin<2
    sampling =0;
end


fp = fopen(filename, 'rb');
assert(fp ~= -1, ['Could not open ', filename, '']);


line1=fgetl(fp); %unused
line2=fgetl(fp); %unused

numberOfImages = fscanf(fp,'%d',1);

if sampling == 0
    sampling = numberOfImages;
end

images=[];
labels =[];

for im=1:sampling
    
    label = fscanf(fp,'%d',1);
    
    labels= [labels; label];
    
    imfile = fscanf(fp,'%s',1);
    I=imread(imfile);
    if size(I,3)>1
        I=rgb2gray(I);
    end
    vector = reshape(I,1, size(I, 1) * size(I, 2));
    vector = double(vector); % / 255;
    
    images= [images; vector]; % - ignore warning
    
    %We need to values for vector->image translation
    num_row = size(I,1);
    num_col = size(I,2);
end

if balance == 1
   numOccurrences = groupcounts(labels);
   
   balancedSize = min(numOccurrences);
   
   balancedImages = [];
   balancedLabels = [];
   
   numPos = 0;
   numNeg = 0;
   
   for i=1:size(images,1)
       
       if numPos==balancedSize && numNeg<balancedSize
           if labels(i,:)==1
              continue
           end
       end
       
       if numNeg==balancedSize && numPos<balancedSize
           if labels(i,:)==-1 
              continue
           end
       end
       
       if numPos==balancedSize && numNeg==balancedSize
           break
       end
       
       balancedImages = [balancedImages; images(i,:)];
       balancedLabels = [balancedLabels; labels(i,:)];
       
       if labels(i,:) == 1
           numPos = numPos + 1;
       else
           numNeg = numNeg + 1;
       end
       
   end
   
   images = balancedImages;
   labels = balancedLabels;
   
end

fclose(fp);
end