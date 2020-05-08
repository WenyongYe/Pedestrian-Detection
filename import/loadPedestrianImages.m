function [images, numPedestrians, num_row, num_col,bounding_boxes] = loadPedestrianImages(filename,sampling)

if nargin<2
    sampling =0;
end

fp = fopen(filename, 'rb');
assert(fp ~= -1, ['Could not open ', filename, '']);

line1=fgetl(fp); %unused

numberOfImages = str2num(fgetl(fp));

if sampling == 0
    sampling = numberOfImages;
end

images=[];
numPedestrians=[];
cntr = 0;
for im=1:sampling
    cntr = cntr +1;
    imfile = fscanf(fp, '%s',1);
    I=imread(imfile);
    if size(I,3)>1
        I=rgb2gray(I);
    end
    
    num_row = size(I,1);
    num_col = size(I,2);
    
    vector = reshape(I,1, num_row * num_col);
    vector = double(vector);
    
    images = [images; vector];
    
    numPedestrian = fscanf(fp,'%d',1);
    numPedestrians = [numPedestrians; numPedestrian];
    
    % - Temp dummy loop to avoid loading in pedestrian positions
    for i=1:numPedestrian
       for j=1:5
           temp_val = i*j;
           if j == 1
             temp_x = fscanf(fp,'%f',1);  
           elseif j == 2
             temp_y = fscanf(fp,'%f',1);
           elseif j == 3
             temp_w = fscanf(fp,'%f',1); 
           elseif j == 4
             temp_h = fscanf(fp,'%f',1);
           elseif j == 5
             temp = fscanf(fp,'%f',1);
          end
       end
       bounding_box = [temp_x,temp_y,temp_w,temp_h];
       bounding_boxes{cntr,i} = bounding_box; %#ok<AGROW>
    end     
 end
    
    % - Temp
    fclose(fp);
end



