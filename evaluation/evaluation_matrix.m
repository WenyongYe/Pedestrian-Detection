function [TP,FP,FN,TN]=evaluation_matrix(test_labels,prediction)
    %Create evaluation matrix and related values
    %calclulate value of TP, FP, FN, TN
    
    TP=sum((test_labels==(prediction==1))==1);
    [FP,pos]=size(intersect(find(test_labels==-1),find(prediction==1)));
    [FN,pos]=size(intersect(find(test_labels==1),find(prediction==-1)));
    [TN,pos]=size(intersect(find(test_labels==-1),find(prediction==-1)));
    
    %count the testing number
    count=size(test_labels,1);
    
    %create evaluation table
    Evaluation = table(TP,FP,TN,FN,count);
    
    %calculate values based on content of table 
    Recall=TP/(TP+FN);
    Precision=TP/(TP+FP);
    Specificity=TN/(TN+FP);
    F_measure=2*TP/(2*TP+FN+FP);
    False_alarm_rate=FP/(FP+TN);
    
    Parameter_Value=table(Recall,Precision,Specificity,F_measure,False_alarm_rate);
    
    %Display table in console
    disp("Evaluation Table"); 
    Evaluation
    
    disp("Parameter Value Table"); 
    Parameter_Value
    
end