function prediction = KNNTesting(testImage, modelKNN, K)
   %KNN testing
   %testImage: image for testing
   %modelKNN: model
   %K: value of K
   %n0 is negative, n1 is positive
   n0=0;
   n1=0;
   array=[];
   %calculate Euclidean Distance
   for i=1:size(modelKNN.neighbours,1)
       array(i)=EuclideanDistance(testImage,modelKNN.neighbours(i,:));
   end
   %sort array in ascending order
   [vals, indxs] = sort(array);
   
   %Check if K is larger than number of elements
   if size(modelKNN.labels,1)<K
       K=size(modelKNN.labels,1);
   end
   %iterate each element in array
   for j=1:K
        if modelKNN.labels(indxs(j))==1
            n1=n1+1;
        else
            n0=n0+1;
        end
   end
   %define the predicted label of image
        if n0>n1
            prediction=-1;
        else
            prediction=1;
        end
        
end