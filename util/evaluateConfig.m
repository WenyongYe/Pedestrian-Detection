function evaluateConfig(config)
disp("--Config--")
disp(["Sampling Count: ", config.samplingCount]); % 0 - Import all images
disp(["Balance Data: ", config.balanceData]);
disp(["Pre-processing?: ", config.prepro]);
if config.prepro == 1
    disp(["Pre-processing method: ",config.preproMethod]);
end
disp(["Feature Extraction?: ", config.featureExtraction]);
if config.featureExtraction == 1
    disp(["Feature Descriptor: ", config.featureDescriptor]);
end
disp(["Dividing Dataset: ", config.dd]);
disp(["Classifier: ", config.classifier]);

if strcmp(config.classifier,"KNN")
    disp(["KNN K val: ", config.knnVal]);
end

if config.swd == 1
    disp(["Sliding Window Detection: ", config.swd]);
end
end

