%% Code for computing aggregated STAI-S scores

clear;
% dataDir = 'E:\작업\SDC\ResearchNotes\01TUTA\01RESULTS\05_Questionnaires'; % directory of data files
dataDir = "G:\다른 컴퓨터\내 컴퓨터\SDC\ResearchNotes\01TUTA\01RESULTS\05_Questionnaires"
baseDir = 'G:\다른 컴퓨터\내 컴퓨터\SDC\ResearchNotes\01TUTA\02ANALYSIS\00Analyses';

analysisName = 'STAI_S'; % Name of the folder that saves results
% subsIncl = [1:63]; % change this to the subject numbers you want to include
%subsIncl = [56 57 58];
subsIncl = [3:14, 16:18, 20:22, 24:44, 46:55, 57:58, 61:63]; % change this to the subject numbers you want to include
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set up the Import Options and import the data

cd(dataDir);

opts = delimitedTextImportOptions("NumVariables", 24);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["subjectID", "session", "date", "sex", "stais01r", "stais02r", "stais03", "stais04", "stais05r", "stais06", "stais07", "stais08r", "stais09", "stais10r", "stais11r", "stais12", "stais13", "stais14", "stais15r", "stais16r", "stais17", "stais18", "stais19r", "stais20r"];
opts.VariableTypes = ["double", "double", "datetime", "categorical", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "sex", "EmptyFieldRule", "auto");
opts = setvaropts(opts, "date", "InputFormat", "yyyy-MM-dd");

data = readtable("ut_stai-s.csv", opts);


clear opts

%% 
cd(baseDir);
% computing reversed items
reverseitems = {'stais01r', 'stais02r', 'stais05r', 'stais08r', 'stais10r', 'stais11r', 'stais15r', 'stais16r', 'stais19r', 'stais20r'};
for ri = 1: length(reverseitems) % recode reverse items
    for rq = 1:length(data.(reverseitems{ri}))
        if  data.(reverseitems{ri})(rq) == 4
            data.(reverseitems{ri})(rq) = 1;
        elseif data.(reverseitems{ri})(rq) == 3
            data.(reverseitems{ri})(rq) = 2;
        elseif data.(reverseitems{ri})(rq) == 2
            data.(reverseitems{ri})(rq) = 3;
        elseif data.(reverseitems{ri})(rq) ==1
            data.(reverseitems{ri})(rq) =4;
        end
    end
end

% compute STAI-S score for each session
stai_sum = [];
for n = 1:height(data)
    stai_sum(end+1) = sum(table2array(data(n,5:24)));
end
stai_sum = stai_sum';
data = addvars(data, stai_sum, 'After', 'stais20r', 'NewVariableNames', {'stai_sum'});

% compute mean STAI-S score for each subject
score = varfun(@mean, data, "InputVariables","stai_sum", "GroupingVariables",["subjectID"]);
score = removevars(score,'GroupCount');

% delete excluded subject data
toexclude = [];
for ss = 1:height(score)
   if  ~ismember(score.subjectID(ss), subsIncl)
       toexclude(end+1) = ss;
   end
end
score(toexclude,:) = [];

%% Output

% Create output folder
cd(baseDir);
if (~exist(analysisName, 'dir')); mkdir(analysisName); end
cd(analysisName);

% Export data
filename = sprintf('STAI_S_SUMMARY%s.xlsx', datestr(now, 'yyyy-mm-dd'));
writetable(score, filename);

