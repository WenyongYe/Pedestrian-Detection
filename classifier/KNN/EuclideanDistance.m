function dEuc=EuclideanDistance(sample1, sample2)
    %Euclidean Distance
    dEuc=sqrt(sum((sample1-sample2).^2));
end