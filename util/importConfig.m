function config = importConfig(filename, dataLines)
%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 3);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["samplingCount","balanceData","prepro","preproMethod","featureExtraction","featureDescriptor","dd","classifier","knnVal","swd"];
opts.VariableTypes = ["double","double","double","string","double","string","string","string","double","double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
config = readtable(filename, opts);
%Print config data
evaluateConfig(config);
end