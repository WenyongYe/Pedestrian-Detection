function [] = create_video(swd_boxes, pp_imgs,imgs,num_row,num_col)
    disp("Processing Result Videos")
    close all;
   %% Pre Processed (What computer uses)
   % create the video writer 
   writerObj = VideoWriter('swd_results_pp');
   writerObj.FrameRate = 6;
   
   for i=1:length(swd_boxes)
       img_index = i;
       %Extract bounding boxes from cell
       img_boxes = swd_boxes{1,img_index};
       
       %Create results image 
       figure("Visible",false);
       imshow(mat2gray(reshape(pp_imgs(i,:),num_row,num_col)))
        hold on
        axis on
        for j=1:size(img_boxes,1)
            bounding_box = img_boxes(j,:);
            rectangle('Position',[bounding_box(1,1),bounding_box(1,2),bounding_box(1,3),bounding_box(1,4)],'EdgeColor', 'g','LineWidth',2)
            daspect([1,1,1]);
        end
        
        temp_frames(i) = getframe(gcf);
   end
   
   open(writerObj);
    for i=1:length(temp_frames)
        % convert the image to a frame
        frame = temp_frames(i) ;    
        writeVideo(writerObj, frame);
    end
    
    close(writerObj);
    
    
     %% Original images
   close all;
   % create the video writer 
   writerObj = VideoWriter('swd_results_original');
   writerObj.FrameRate = 6;
   
   for i=1:length(swd_boxes)
       img_index = i;
       %Extract bounding boxes from cell
       img_boxes = swd_boxes{1,img_index};
       
       %Create results image 
       figure("Visible",false);
       imshow(mat2gray(reshape(imgs(i,:),num_row,num_col)))
        hold on
        axis on
        for j=1:size(img_boxes,1)
            bounding_box = img_boxes(j,:);
            rectangle('Position',[bounding_box(1,1),bounding_box(1,2),bounding_box(1,3),bounding_box(1,4)],'EdgeColor', 'g','LineWidth',2)
            daspect([1,1,1]);
        end
        
        temp_frames_2(i) = getframe(gcf);
   end
   
   open(writerObj);
    for i=1:length(temp_frames_2)
        % convert the image to a frame
        frame = temp_frames_2(i) ;    
        writeVideo(writerObj, frame);
    end
    
    close(writerObj);
    disp("Videos located in: project/video/..");
end