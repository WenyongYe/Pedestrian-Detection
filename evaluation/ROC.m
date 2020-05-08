function [] = ROC(predict, labels )
%Draw ROC curve and calculate AUC value

%  predict: predecition result of classifier
%  label: correct labels of dataset

%Start from location (x,y)=(1,0)
x = 1.0;
y = 1.0;

%Calculate the number of TP, FP
pos = sum(labels==1);
neg = sum(labels==-1);

%Calculate each step based on nummber of TP and FP
x_step = 1.0/neg;
y_step = 1.0/pos;

%Sort the resurt in ascending order
[predict,index] = sort(predict);
labels = labels(index);

%Identify the labels belong to FP or TP
%if labels=1,TP=TP-1, move down y_step on y axis
%if labels=-1,FP=FP-1, move down x_step on x axis
for i=1:length(labels)
    if labels(i) == 1
        y = y - y_step;
    else
        x = x - x_step;
    end
    X(i)=x;
    Y(i)=y;
end
%Draw the plot  
figure;
plot(X,Y,'-bo','LineWidth',2,'MarkerSize',3),xlabel('FP rate'),ylabel('TP rate'),title('ROC Curve');

%Calculate value of AUC, based on integration
AUC = -trapz(X,Y);    

%Display AUC result
disp("AUC value");
AUC

end
