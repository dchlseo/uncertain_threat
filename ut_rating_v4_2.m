%% Code for processing in-task rating measures (valence, arousal, worry)

clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Adjust file location & number of subjects to include in the analysis
dataDir = 'G:\다른 컴퓨터\내 컴퓨터\SDC\ResearchNotes\01TUTA\01RESULTS\03Rating'; % directory of data files
baseDir = 'G:\다른 컴퓨터\내 컴퓨터\SDC\ResearchNotes\01TUTA\02ANALYSIS\00Analyses'; % directory for output and code
%dataDir = 'E:\작업\SDC\ResearchNotes\01TUTA\01RESULTS\03Rating'; % directory of data files
%baseDir = 'E:\작업\SDC\ResearchNotes\01TUTA\02ANALYSIS\00Analyses'; % directory for output and code
analysisName = '220705_rating_Z'; % Name of the folder that saves results
% subsIncl = [1:63]; % change this to the subject numbers you want to include
%subsIncl = [56 57 58];
subsIncl = [3:14, 16:18, 20:22, 24:44, 46:55, 57:58, 61:63]; % change this to the subject numbers you want to include
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Import settings

opts = delimitedTextImportOptions("NumVariables", 12, "Encoding", "UTF-8");

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["subject", "session", "cb", "run", "block", "type", "npu", "certainty", "load", "valence", "arousal", "worry"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "categorical", "categorical", "categorical", "categorical", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["type", "npu", "certainty", "load"], "EmptyFieldRule", "auto");

%% Import rating data

cd(dataDir);

path_directory=pwd; % current directory that contains rating data and this matfile
original_files=dir([path_directory '/*RATING.csv']);

nameSubfiles = {}; 
fprintf("uploaded files:" + '\n')
for i = subsIncl
    for j=1:length(original_files)
        filename=[original_files(j).name];
        if str2double(filename(2:3)) == i
            disp(original_files(j).name)
            nameSubfiles{end+1} = filename; % return filenames to import
        end
    end 
end

data = {};
for k= nameSubfiles % import selected files
    data{end+1} = readtable(char(k), opts); % each table gets put into 'data'
end 

clear opts

%% processing for selected subjects

% Calculate standardize scores for each participant
for ss = 1:length(data)
   
    raw_val = data{ss}.valence;
    raw_aro = data{ss}.arousal;
    raw_wor = data{ss}.worry;
    z_valence = (raw_val-nanmean(raw_val))/nanstd(raw_val);
    z_arousal = (raw_aro-nanmean(raw_aro))/nanstd(raw_aro);
    z_worry = (raw_wor-nanmean(raw_wor))/nanstd(raw_wor);
    
    data{ss} = addvars(data{ss}, z_valence, z_arousal, z_worry, 'After', 'worry', ...
        'NewVariableNames', {'z_valence', 'z_arousal', 'z_worry'}); 
end

valence_cell = {};
worry_cell = {};
arousal_cell = {};

z_valence_cell = {};
z_worry_cell = {};
z_arousal_cell = {};

n = length(subsIncl);
    disp(['--- N = ', num2str(n), ' ---']);

for ss = 1:length(data)
    
    disp(['--- Processing subject: ', num2str(unique(data{ss}.subject)), ' ---']);
    singledata = data{ss};
    valence = varfun(@mean, singledata, "InputVariables","valence", "GroupingVariables",["subject","type", "npu", "certainty", "load"]);
    arousal = varfun(@mean, singledata, "InputVariables","arousal", "GroupingVariables",["subject","type", "npu", "certainty", "load"]);
    worry = varfun(@mean, singledata, "InputVariables","worry", "GroupingVariables",["subject","type", "npu", "certainty", "load"]);
    valence = removevars(valence, 'GroupCount');
    arousal = removevars(arousal, 'GroupCount');
    worry = removevars(worry, 'GroupCount');

    z_valence = varfun(@mean, singledata, "InputVariables","z_valence", "GroupingVariables",["subject","type", "npu", "certainty", "load"]);
    z_arousal = varfun(@mean, singledata, "InputVariables","z_arousal", "GroupingVariables",["subject","type", "npu", "certainty", "load"]);
    z_worry = varfun(@mean, singledata, "InputVariables","z_worry", "GroupingVariables",["subject","type", "npu", "certainty", "load"]);
    z_valence = removevars(z_valence, 'GroupCount');
    z_arousal = removevars(z_arousal, 'GroupCount');
    z_worry = removevars(z_worry, 'GroupCount');
    
    % Valence
    subject = unique(valence.subject);
    v_n_cert_low = valence.mean_valence(valence.type == 'v' & valence.npu == 'n' & valence.certainty == 'certain' & valence.load == 'low');
    v_n_cert_high = valence.mean_valence(valence.type == 'v' & valence.npu == 'n' & valence.certainty == 'certain' & valence.load == 'high');
    v_n_uncert_low = valence.mean_valence(valence.type == 'v' & valence.npu == 'n' & valence.certainty == 'uncertain' & valence.load == 'low');
    v_n_uncert_high = valence.mean_valence(valence.type == 'v' & valence.npu == 'n' & valence.certainty == 'uncertain' & valence.load == 'high');
    
    v_p_cert_low = valence.mean_valence(valence.type == 'v' & valence.npu == 'p' & valence.certainty == 'certain' & valence.load == 'low');
    v_p_cert_high = valence.mean_valence(valence.type == 'v' & valence.npu == 'p' & valence.certainty == 'certain' & valence.load == 'high');
    v_p_uncert_low = valence.mean_valence(valence.type == 'v' & valence.npu == 'p' & valence.certainty == 'uncertain' & valence.load == 'low');
    v_p_uncert_high = valence.mean_valence(valence.type == 'v' & valence.npu == 'p' & valence.certainty == 'uncertain' & valence.load == 'high');  
    
    v_u_cert_low = valence.mean_valence(valence.type == 'v' & valence.npu == 'u' & valence.certainty == 'certain' & valence.load == 'low');
    v_u_cert_high = valence.mean_valence(valence.type == 'v' & valence.npu == 'u' & valence.certainty == 'certain' & valence.load == 'high');
    v_u_uncert_low = valence.mean_valence(valence.type == 'v' & valence.npu == 'u' & valence.certainty == 'uncertain' & valence.load == 'low');
    v_u_uncert_high = valence.mean_valence(valence.type == 'v' & valence.npu == 'u' & valence.certainty == 'uncertain' & valence.load == 'high');
    
    s_n_cert_low = valence.mean_valence(valence.type == 's' & valence.npu == 'n' & valence.certainty == 'certain' & valence.load == 'low');
    s_n_cert_high = valence.mean_valence(valence.type == 's' & valence.npu == 'n' & valence.certainty == 'certain' & valence.load == 'high');
    s_n_uncert_low = valence.mean_valence(valence.type == 's' & valence.npu == 'n' & valence.certainty == 'uncertain' & valence.load == 'low');
    s_n_uncert_high = valence.mean_valence(valence.type == 's' & valence.npu == 'n' & valence.certainty == 'uncertain' & valence.load == 'high');
    
    s_p_cert_low = valence.mean_valence(valence.type == 's' & valence.npu == 'p' & valence.certainty == 'certain' & valence.load == 'low');
    s_p_cert_high = valence.mean_valence(valence.type == 's' & valence.npu == 'p' & valence.certainty == 'certain' & valence.load == 'high');
    s_p_uncert_low = valence.mean_valence(valence.type == 's' & valence.npu == 'p' & valence.certainty == 'uncertain' & valence.load == 'low');
    s_p_uncert_high = valence.mean_valence(valence.type == 's' & valence.npu == 'p' & valence.certainty == 'uncertain' & valence.load == 'high');  
    
    s_u_cert_low = valence.mean_valence(valence.type == 's' & valence.npu == 'u' & valence.certainty == 'certain' & valence.load == 'low');
    s_u_cert_high = valence.mean_valence(valence.type == 's' & valence.npu == 'u' & valence.certainty == 'certain' & valence.load == 'high');
    s_u_uncert_low = valence.mean_valence(valence.type == 's' & valence.npu == 'u' & valence.certainty == 'uncertain' & valence.load == 'low');
    s_u_uncert_high = valence.mean_valence(valence.type == 's' & valence.npu == 'u' & valence.certainty == 'uncertain' & valence.load == 'high');
 
    subject_valence = table(subject, v_n_cert_low, v_n_cert_high, v_n_uncert_low, v_n_uncert_high, ...
        v_p_cert_low, v_p_cert_high, v_p_uncert_low, v_p_uncert_high, ...
        v_u_cert_low, v_u_cert_high, v_u_uncert_low, v_u_uncert_high, ... 
        s_n_cert_low, s_n_cert_high, s_n_uncert_low, s_n_uncert_high, ...
        s_p_cert_low, s_p_cert_high, s_p_uncert_low, s_p_uncert_high, ...
        s_u_cert_low, s_u_cert_high, s_u_uncert_low, s_u_uncert_high);   
   
    valence_cell{end+1} = subject_valence; % processed data goes into this cell.

    
 % Arousal   
    subject = unique(arousal.subject);
    v_n_cert_low = arousal.mean_arousal(arousal.type == 'v' & arousal.npu == 'n' & arousal.certainty == 'certain' & arousal.load == 'low');
    v_n_cert_high = arousal.mean_arousal(arousal.type == 'v' & arousal.npu == 'n' & arousal.certainty == 'certain' & arousal.load == 'high');
    v_n_uncert_low = arousal.mean_arousal(arousal.type == 'v' & arousal.npu == 'n' & arousal.certainty == 'uncertain' & arousal.load == 'low');
    v_n_uncert_high = arousal.mean_arousal(arousal.type == 'v' & arousal.npu == 'n' & arousal.certainty == 'uncertain' & arousal.load == 'high');
    
    v_p_cert_low = arousal.mean_arousal(arousal.type == 'v' & arousal.npu == 'p' & arousal.certainty == 'certain' & arousal.load == 'low');
    v_p_cert_high = arousal.mean_arousal(arousal.type == 'v' & arousal.npu == 'p' & arousal.certainty == 'certain' & arousal.load == 'high');
    v_p_uncert_low = arousal.mean_arousal(arousal.type == 'v' & arousal.npu == 'p' & arousal.certainty == 'uncertain' & arousal.load == 'low');
    v_p_uncert_high = arousal.mean_arousal(arousal.type == 'v' & arousal.npu == 'p' & arousal.certainty == 'uncertain' & arousal.load == 'high');  
    
    v_u_cert_low = arousal.mean_arousal(arousal.type == 'v' & arousal.npu == 'u' & arousal.certainty == 'certain' & arousal.load == 'low');
    v_u_cert_high = arousal.mean_arousal(arousal.type == 'v' & arousal.npu == 'u' & arousal.certainty == 'certain' & arousal.load == 'high');
    v_u_uncert_low = arousal.mean_arousal(arousal.type == 'v' & arousal.npu == 'u' & arousal.certainty == 'uncertain' & arousal.load == 'low');
    v_u_uncert_high = arousal.mean_arousal(arousal.type == 'v' & arousal.npu == 'u' & arousal.certainty == 'uncertain' & arousal.load == 'high');
    
    s_n_cert_low = arousal.mean_arousal(arousal.type == 's' & arousal.npu == 'n' & arousal.certainty == 'certain' & arousal.load == 'low');
    s_n_cert_high = arousal.mean_arousal(arousal.type == 's' & arousal.npu == 'n' & arousal.certainty == 'certain' & arousal.load == 'high');
    s_n_uncert_low = arousal.mean_arousal(arousal.type == 's' & arousal.npu == 'n' & arousal.certainty == 'uncertain' & arousal.load == 'low');
    s_n_uncert_high = arousal.mean_arousal(arousal.type == 's' & arousal.npu == 'n' & arousal.certainty == 'uncertain' & arousal.load == 'high');
    
    s_p_cert_low = arousal.mean_arousal(arousal.type == 's' & arousal.npu == 'p' & arousal.certainty == 'certain' & arousal.load == 'low');
    s_p_cert_high = arousal.mean_arousal(arousal.type == 's' & arousal.npu == 'p' & arousal.certainty == 'certain' & arousal.load == 'high');
    s_p_uncert_low = arousal.mean_arousal(arousal.type == 's' & arousal.npu == 'p' & arousal.certainty == 'uncertain' & arousal.load == 'low');
    s_p_uncert_high = arousal.mean_arousal(arousal.type == 's' & arousal.npu == 'p' & arousal.certainty == 'uncertain' & arousal.load == 'high');  
    
    s_u_cert_low = arousal.mean_arousal(arousal.type == 's' & arousal.npu == 'u' & arousal.certainty == 'certain' & arousal.load == 'low');
    s_u_cert_high = arousal.mean_arousal(arousal.type == 's' & arousal.npu == 'u' & arousal.certainty == 'certain' & arousal.load == 'high');
    s_u_uncert_low = arousal.mean_arousal(arousal.type == 's' & arousal.npu == 'u' & arousal.certainty == 'uncertain' & arousal.load == 'low');
    s_u_uncert_high = arousal.mean_arousal(arousal.type == 's' & arousal.npu == 'u' & arousal.certainty == 'uncertain' & arousal.load == 'high');   
    
    
    subject_arousal = table(subject, v_n_cert_low, v_n_cert_high, v_n_uncert_low, v_n_uncert_high, ...
        v_p_cert_low, v_p_cert_high, v_p_uncert_low, v_p_uncert_high, ...
        v_u_cert_low, v_u_cert_high, v_u_uncert_low, v_u_uncert_high, ... 
        s_n_cert_low, s_n_cert_high, s_n_uncert_low, s_n_uncert_high, ...
        s_p_cert_low, s_p_cert_high, s_p_uncert_low, s_p_uncert_high, ...
        s_u_cert_low, s_u_cert_high, s_u_uncert_low, s_u_uncert_high); 
 
    arousal_cell{end+1} = subject_arousal; % processed data goes into this cell.
    
% Worry   
    subject = unique(worry.subject);
    v_n_cert_low = worry.mean_worry(worry.type == 'v' & worry.npu == 'n' & worry.certainty == 'certain' & worry.load == 'low');
    v_n_cert_high = worry.mean_worry(worry.type == 'v' & worry.npu == 'n' & worry.certainty == 'certain' & worry.load == 'high');
    v_n_uncert_low = worry.mean_worry(worry.type == 'v' & worry.npu == 'n' & worry.certainty == 'uncertain' & worry.load == 'low');
    v_n_uncert_high = worry.mean_worry(worry.type == 'v' & worry.npu == 'n' & worry.certainty == 'uncertain' & worry.load == 'high');
    
    v_p_cert_low = worry.mean_worry(worry.type == 'v' & worry.npu == 'p' & worry.certainty == 'certain' & worry.load == 'low');
    v_p_cert_high = worry.mean_worry(worry.type == 'v' & worry.npu == 'p' & worry.certainty == 'certain' & worry.load == 'high');
    v_p_uncert_low = worry.mean_worry(worry.type == 'v' & worry.npu == 'p' & worry.certainty == 'uncertain' & worry.load == 'low');
    v_p_uncert_high = worry.mean_worry(worry.type == 'v' & worry.npu == 'p' & worry.certainty == 'uncertain' & worry.load == 'high');  
    
    v_u_cert_low = worry.mean_worry(worry.type == 'v' & worry.npu == 'u' & worry.certainty == 'certain' & worry.load == 'low');
    v_u_cert_high = worry.mean_worry(worry.type == 'v' & worry.npu == 'u' & worry.certainty == 'certain' & worry.load == 'high');
    v_u_uncert_low = worry.mean_worry(worry.type == 'v' & worry.npu == 'u' & worry.certainty == 'uncertain' & worry.load == 'low');
    v_u_uncert_high = worry.mean_worry(worry.type == 'v' & worry.npu == 'u' & worry.certainty == 'uncertain' & worry.load == 'high');
    
    s_n_cert_low = worry.mean_worry(worry.type == 's' & worry.npu == 'n' & worry.certainty == 'certain' & worry.load == 'low');
    s_n_cert_high = worry.mean_worry(worry.type == 's' & worry.npu == 'n' & worry.certainty == 'certain' & worry.load == 'high');
    s_n_uncert_low = worry.mean_worry(worry.type == 's' & worry.npu == 'n' & worry.certainty == 'uncertain' & worry.load == 'low');
    s_n_uncert_high = worry.mean_worry(worry.type == 's' & worry.npu == 'n' & worry.certainty == 'uncertain' & worry.load == 'high');
    
    s_p_cert_low = worry.mean_worry(worry.type == 's' & worry.npu == 'p' & worry.certainty == 'certain' & worry.load == 'low');
    s_p_cert_high = worry.mean_worry(worry.type == 's' & worry.npu == 'p' & worry.certainty == 'certain' & worry.load == 'high');
    s_p_uncert_low = worry.mean_worry(worry.type == 's' & worry.npu == 'p' & worry.certainty == 'uncertain' & worry.load == 'low');
    s_p_uncert_high = worry.mean_worry(worry.type == 's' & worry.npu == 'p' & worry.certainty == 'uncertain' & worry.load == 'high');  
    
    s_u_cert_low = worry.mean_worry(worry.type == 's' & worry.npu == 'u' & worry.certainty == 'certain' & worry.load == 'low');
    s_u_cert_high = worry.mean_worry(worry.type == 's' & worry.npu == 'u' & worry.certainty == 'certain' & worry.load == 'high');
    s_u_uncert_low = worry.mean_worry(worry.type == 's' & worry.npu == 'u' & worry.certainty == 'uncertain' & worry.load == 'low');
    s_u_uncert_high = worry.mean_worry(worry.type == 's' & worry.npu == 'u' & worry.certainty == 'uncertain' & worry.load == 'high');   
    
    
    subject_worry = table(subject, v_n_cert_low, v_n_cert_high, v_n_uncert_low, v_n_uncert_high, ...
        v_p_cert_low, v_p_cert_high, v_p_uncert_low, v_p_uncert_high, ...
        v_u_cert_low, v_u_cert_high, v_u_uncert_low, v_u_uncert_high, ... 
        s_n_cert_low, s_n_cert_high, s_n_uncert_low, s_n_uncert_high, ...
        s_p_cert_low, s_p_cert_high, s_p_uncert_low, s_p_uncert_high, ...
        s_u_cert_low, s_u_cert_high, s_u_uncert_low, s_u_uncert_high);
    
    worry_cell{end+1} = subject_worry; % processed data goes into this cell.

    
    % Z-Valence
    subject = unique(z_valence.subject);
    v_n_cert_low = z_valence.mean_z_valence(z_valence.type == 'v' & z_valence.npu == 'n' & z_valence.certainty == 'certain' & z_valence.load == 'low');
    v_n_cert_high = z_valence.mean_z_valence(z_valence.type == 'v' & z_valence.npu == 'n' & z_valence.certainty == 'certain' & z_valence.load == 'high');
    v_n_uncert_low = z_valence.mean_z_valence(z_valence.type == 'v' & z_valence.npu == 'n' & z_valence.certainty == 'uncertain' & z_valence.load == 'low');
    v_n_uncert_high = z_valence.mean_z_valence(z_valence.type == 'v' & z_valence.npu == 'n' & z_valence.certainty == 'uncertain' & z_valence.load == 'high');
    
    v_p_cert_low = z_valence.mean_z_valence(z_valence.type == 'v' & z_valence.npu == 'p' & z_valence.certainty == 'certain' & z_valence.load == 'low');
    v_p_cert_high = z_valence.mean_z_valence(z_valence.type == 'v' & z_valence.npu == 'p' & z_valence.certainty == 'certain' & z_valence.load == 'high');
    v_p_uncert_low = z_valence.mean_z_valence(z_valence.type == 'v' & z_valence.npu == 'p' & z_valence.certainty == 'uncertain' & z_valence.load == 'low');
    v_p_uncert_high = z_valence.mean_z_valence(z_valence.type == 'v' & z_valence.npu == 'p' & z_valence.certainty == 'uncertain' & z_valence.load == 'high');  
    
    v_u_cert_low = z_valence.mean_z_valence(z_valence.type == 'v' & z_valence.npu == 'u' & z_valence.certainty == 'certain' & z_valence.load == 'low');
    v_u_cert_high = z_valence.mean_z_valence(z_valence.type == 'v' & z_valence.npu == 'u' & z_valence.certainty == 'certain' & z_valence.load == 'high');
    v_u_uncert_low = z_valence.mean_z_valence(z_valence.type == 'v' & z_valence.npu == 'u' & z_valence.certainty == 'uncertain' & z_valence.load == 'low');
    v_u_uncert_high = z_valence.mean_z_valence(z_valence.type == 'v' & z_valence.npu == 'u' & z_valence.certainty == 'uncertain' & z_valence.load == 'high');
    
    s_n_cert_low = z_valence.mean_z_valence(z_valence.type == 's' & z_valence.npu == 'n' & z_valence.certainty == 'certain' & z_valence.load == 'low');
    s_n_cert_high = z_valence.mean_z_valence(z_valence.type == 's' & z_valence.npu == 'n' & z_valence.certainty == 'certain' & z_valence.load == 'high');
    s_n_uncert_low = z_valence.mean_z_valence(z_valence.type == 's' & z_valence.npu == 'n' & z_valence.certainty == 'uncertain' & z_valence.load == 'low');
    s_n_uncert_high = z_valence.mean_z_valence(z_valence.type == 's' & z_valence.npu == 'n' & z_valence.certainty == 'uncertain' & z_valence.load == 'high');
    
    s_p_cert_low = z_valence.mean_z_valence(z_valence.type == 's' & z_valence.npu == 'p' & z_valence.certainty == 'certain' & z_valence.load == 'low');
    s_p_cert_high = z_valence.mean_z_valence(z_valence.type == 's' & z_valence.npu == 'p' & z_valence.certainty == 'certain' & z_valence.load == 'high');
    s_p_uncert_low = z_valence.mean_z_valence(z_valence.type == 's' & z_valence.npu == 'p' & z_valence.certainty == 'uncertain' & z_valence.load == 'low');
    s_p_uncert_high = z_valence.mean_z_valence(z_valence.type == 's' & z_valence.npu == 'p' & z_valence.certainty == 'uncertain' & z_valence.load == 'high');  
    
    s_u_cert_low = z_valence.mean_z_valence(z_valence.type == 's' & z_valence.npu == 'u' & z_valence.certainty == 'certain' & z_valence.load == 'low');
    s_u_cert_high = z_valence.mean_z_valence(z_valence.type == 's' & z_valence.npu == 'u' & z_valence.certainty == 'certain' & z_valence.load == 'high');
    s_u_uncert_low = z_valence.mean_z_valence(z_valence.type == 's' & z_valence.npu == 'u' & z_valence.certainty == 'uncertain' & z_valence.load == 'low');
    s_u_uncert_high = z_valence.mean_z_valence(z_valence.type == 's' & z_valence.npu == 'u' & z_valence.certainty == 'uncertain' & z_valence.load == 'high');
 
    subject_z_valence = table(subject, v_n_cert_low, v_n_cert_high, v_n_uncert_low, v_n_uncert_high, ...
        v_p_cert_low, v_p_cert_high, v_p_uncert_low, v_p_uncert_high, ...
        v_u_cert_low, v_u_cert_high, v_u_uncert_low, v_u_uncert_high, ... 
        s_n_cert_low, s_n_cert_high, s_n_uncert_low, s_n_uncert_high, ...
        s_p_cert_low, s_p_cert_high, s_p_uncert_low, s_p_uncert_high, ...
        s_u_cert_low, s_u_cert_high, s_u_uncert_low, s_u_uncert_high);   
   
    z_valence_cell{end+1} = subject_z_valence; % processed data goes into this cell.
    
    % z_arousal   
    subject = unique(z_arousal.subject);
    v_n_cert_low = z_arousal.mean_z_arousal(z_arousal.type == 'v' & z_arousal.npu == 'n' & z_arousal.certainty == 'certain' & z_arousal.load == 'low');
    v_n_cert_high = z_arousal.mean_z_arousal(z_arousal.type == 'v' & z_arousal.npu == 'n' & z_arousal.certainty == 'certain' & z_arousal.load == 'high');
    v_n_uncert_low = z_arousal.mean_z_arousal(z_arousal.type == 'v' & z_arousal.npu == 'n' & z_arousal.certainty == 'uncertain' & z_arousal.load == 'low');
    v_n_uncert_high = z_arousal.mean_z_arousal(z_arousal.type == 'v' & z_arousal.npu == 'n' & z_arousal.certainty == 'uncertain' & z_arousal.load == 'high');
    
    v_p_cert_low = z_arousal.mean_z_arousal(z_arousal.type == 'v' & z_arousal.npu == 'p' & z_arousal.certainty == 'certain' & z_arousal.load == 'low');
    v_p_cert_high = z_arousal.mean_z_arousal(z_arousal.type == 'v' & z_arousal.npu == 'p' & z_arousal.certainty == 'certain' & z_arousal.load == 'high');
    v_p_uncert_low = z_arousal.mean_z_arousal(z_arousal.type == 'v' & z_arousal.npu == 'p' & z_arousal.certainty == 'uncertain' & z_arousal.load == 'low');
    v_p_uncert_high = z_arousal.mean_z_arousal(z_arousal.type == 'v' & z_arousal.npu == 'p' & z_arousal.certainty == 'uncertain' & z_arousal.load == 'high');  
    
    v_u_cert_low = z_arousal.mean_z_arousal(z_arousal.type == 'v' & z_arousal.npu == 'u' & z_arousal.certainty == 'certain' & z_arousal.load == 'low');
    v_u_cert_high = z_arousal.mean_z_arousal(z_arousal.type == 'v' & z_arousal.npu == 'u' & z_arousal.certainty == 'certain' & z_arousal.load == 'high');
    v_u_uncert_low = z_arousal.mean_z_arousal(z_arousal.type == 'v' & z_arousal.npu == 'u' & z_arousal.certainty == 'uncertain' & z_arousal.load == 'low');
    v_u_uncert_high = z_arousal.mean_z_arousal(z_arousal.type == 'v' & z_arousal.npu == 'u' & z_arousal.certainty == 'uncertain' & z_arousal.load == 'high');
    
    s_n_cert_low = z_arousal.mean_z_arousal(z_arousal.type == 's' & z_arousal.npu == 'n' & z_arousal.certainty == 'certain' & z_arousal.load == 'low');
    s_n_cert_high = z_arousal.mean_z_arousal(z_arousal.type == 's' & z_arousal.npu == 'n' & z_arousal.certainty == 'certain' & z_arousal.load == 'high');
    s_n_uncert_low = z_arousal.mean_z_arousal(z_arousal.type == 's' & z_arousal.npu == 'n' & z_arousal.certainty == 'uncertain' & z_arousal.load == 'low');
    s_n_uncert_high = z_arousal.mean_z_arousal(z_arousal.type == 's' & z_arousal.npu == 'n' & z_arousal.certainty == 'uncertain' & z_arousal.load == 'high');
    
    s_p_cert_low = z_arousal.mean_z_arousal(z_arousal.type == 's' & z_arousal.npu == 'p' & z_arousal.certainty == 'certain' & z_arousal.load == 'low');
    s_p_cert_high = z_arousal.mean_z_arousal(z_arousal.type == 's' & z_arousal.npu == 'p' & z_arousal.certainty == 'certain' & z_arousal.load == 'high');
    s_p_uncert_low = z_arousal.mean_z_arousal(z_arousal.type == 's' & z_arousal.npu == 'p' & z_arousal.certainty == 'uncertain' & z_arousal.load == 'low');
    s_p_uncert_high = z_arousal.mean_z_arousal(z_arousal.type == 's' & z_arousal.npu == 'p' & z_arousal.certainty == 'uncertain' & z_arousal.load == 'high');  
    
    s_u_cert_low = z_arousal.mean_z_arousal(z_arousal.type == 's' & z_arousal.npu == 'u' & z_arousal.certainty == 'certain' & z_arousal.load == 'low');
    s_u_cert_high = z_arousal.mean_z_arousal(z_arousal.type == 's' & z_arousal.npu == 'u' & z_arousal.certainty == 'certain' & z_arousal.load == 'high');
    s_u_uncert_low = z_arousal.mean_z_arousal(z_arousal.type == 's' & z_arousal.npu == 'u' & z_arousal.certainty == 'uncertain' & z_arousal.load == 'low');
    s_u_uncert_high = z_arousal.mean_z_arousal(z_arousal.type == 's' & z_arousal.npu == 'u' & z_arousal.certainty == 'uncertain' & z_arousal.load == 'high');   
    
    
    subject_z_arousal = table(subject, v_n_cert_low, v_n_cert_high, v_n_uncert_low, v_n_uncert_high, ...
        v_p_cert_low, v_p_cert_high, v_p_uncert_low, v_p_uncert_high, ...
        v_u_cert_low, v_u_cert_high, v_u_uncert_low, v_u_uncert_high, ... 
        s_n_cert_low, s_n_cert_high, s_n_uncert_low, s_n_uncert_high, ...
        s_p_cert_low, s_p_cert_high, s_p_uncert_low, s_p_uncert_high, ...
        s_u_cert_low, s_u_cert_high, s_u_uncert_low, s_u_uncert_high); 
 
    z_arousal_cell{end+1} = subject_z_arousal; % processed data goes into this cell.
    
    % T-Worry   
    subject = unique(z_worry.subject);
    v_n_cert_low = z_worry.mean_z_worry(z_worry.type == 'v' & z_worry.npu == 'n' & z_worry.certainty == 'certain' & z_worry.load == 'low');
    v_n_cert_high = z_worry.mean_z_worry(z_worry.type == 'v' & z_worry.npu == 'n' & z_worry.certainty == 'certain' & z_worry.load == 'high');
    v_n_uncert_low = z_worry.mean_z_worry(z_worry.type == 'v' & z_worry.npu == 'n' & z_worry.certainty == 'uncertain' & z_worry.load == 'low');
    v_n_uncert_high = z_worry.mean_z_worry(z_worry.type == 'v' & z_worry.npu == 'n' & z_worry.certainty == 'uncertain' & z_worry.load == 'high');
    
    v_p_cert_low = z_worry.mean_z_worry(z_worry.type == 'v' & z_worry.npu == 'p' & z_worry.certainty == 'certain' & z_worry.load == 'low');
    v_p_cert_high = z_worry.mean_z_worry(z_worry.type == 'v' & z_worry.npu == 'p' & z_worry.certainty == 'certain' & z_worry.load == 'high');
    v_p_uncert_low = z_worry.mean_z_worry(z_worry.type == 'v' & z_worry.npu == 'p' & z_worry.certainty == 'uncertain' & z_worry.load == 'low');
    v_p_uncert_high = z_worry.mean_z_worry(z_worry.type == 'v' & z_worry.npu == 'p' & z_worry.certainty == 'uncertain' & z_worry.load == 'high');  
    
    v_u_cert_low = z_worry.mean_z_worry(z_worry.type == 'v' & z_worry.npu == 'u' & z_worry.certainty == 'certain' & z_worry.load == 'low');
    v_u_cert_high = z_worry.mean_z_worry(z_worry.type == 'v' & z_worry.npu == 'u' & z_worry.certainty == 'certain' & z_worry.load == 'high');
    v_u_uncert_low = z_worry.mean_z_worry(z_worry.type == 'v' & z_worry.npu == 'u' & z_worry.certainty == 'uncertain' & z_worry.load == 'low');
    v_u_uncert_high = z_worry.mean_z_worry(z_worry.type == 'v' & z_worry.npu == 'u' & z_worry.certainty == 'uncertain' & z_worry.load == 'high');
    
    s_n_cert_low = z_worry.mean_z_worry(z_worry.type == 's' & z_worry.npu == 'n' & z_worry.certainty == 'certain' & z_worry.load == 'low');
    s_n_cert_high = z_worry.mean_z_worry(z_worry.type == 's' & z_worry.npu == 'n' & z_worry.certainty == 'certain' & z_worry.load == 'high');
    s_n_uncert_low = z_worry.mean_z_worry(z_worry.type == 's' & z_worry.npu == 'n' & z_worry.certainty == 'uncertain' & z_worry.load == 'low');
    s_n_uncert_high = z_worry.mean_z_worry(z_worry.type == 's' & z_worry.npu == 'n' & z_worry.certainty == 'uncertain' & z_worry.load == 'high');
    
    s_p_cert_low = z_worry.mean_z_worry(z_worry.type == 's' & z_worry.npu == 'p' & z_worry.certainty == 'certain' & z_worry.load == 'low');
    s_p_cert_high = z_worry.mean_z_worry(z_worry.type == 's' & z_worry.npu == 'p' & z_worry.certainty == 'certain' & z_worry.load == 'high');
    s_p_uncert_low = z_worry.mean_z_worry(z_worry.type == 's' & z_worry.npu == 'p' & z_worry.certainty == 'uncertain' & z_worry.load == 'low');
    s_p_uncert_high = z_worry.mean_z_worry(z_worry.type == 's' & z_worry.npu == 'p' & z_worry.certainty == 'uncertain' & z_worry.load == 'high');  
    
    s_u_cert_low = z_worry.mean_z_worry(z_worry.type == 's' & z_worry.npu == 'u' & z_worry.certainty == 'certain' & z_worry.load == 'low');
    s_u_cert_high = z_worry.mean_z_worry(z_worry.type == 's' & z_worry.npu == 'u' & z_worry.certainty == 'certain' & z_worry.load == 'high');
    s_u_uncert_low = z_worry.mean_z_worry(z_worry.type == 's' & z_worry.npu == 'u' & z_worry.certainty == 'uncertain' & z_worry.load == 'low');
    s_u_uncert_high = z_worry.mean_z_worry(z_worry.type == 's' & z_worry.npu == 'u' & z_worry.certainty == 'uncertain' & z_worry.load == 'high');   
    
    
    subject_z_worry = table(subject, v_n_cert_low, v_n_cert_high, v_n_uncert_low, v_n_uncert_high, ...
        v_p_cert_low, v_p_cert_high, v_p_uncert_low, v_p_uncert_high, ...
        v_u_cert_low, v_u_cert_high, v_u_uncert_low, v_u_uncert_high, ... 
        s_n_cert_low, s_n_cert_high, s_n_uncert_low, s_n_uncert_high, ...
        s_p_cert_low, s_p_cert_high, s_p_uncert_low, s_p_uncert_high, ...
        s_u_cert_low, s_u_cert_high, s_u_uncert_low, s_u_uncert_high);
    
    z_worry_cell{end+1} = subject_z_worry; % processed data goes into this cell.
    
    
end

output_valence = vertcat(valence_cell{:});
output_arousal = vertcat(arousal_cell{:});
output_worry = vertcat(worry_cell{:});
output_z_valence = vertcat(z_valence_cell{:});
output_z_arousal = vertcat(z_arousal_cell{:});
output_z_worry = vertcat(z_worry_cell{:});
%% Output

% Create output folder
cd(baseDir);
if (~exist(analysisName, 'dir')); mkdir(analysisName); end
cd(analysisName);

% Export data
filename_v = sprintf('data_valence_%s.xlsx', datestr(now, 'yyyy-mm-dd'));
writetable(output_valence, filename_v);
filename_a = sprintf('data_arousal_%s.xlsx', datestr(now, 'yyyy-mm-dd'));
writetable(output_arousal, filename_a);
filename_w = sprintf('data_worry_%s.xlsx', datestr(now, 'yyyy-mm-dd'));
writetable(output_worry, filename_w);

filename_vt = sprintf('data_valence_z_%s.xlsx', datestr(now, 'yyyy-mm-dd'));
writetable(output_z_valence, filename_vt);
filename_at = sprintf('data_arousal_z_%s.xlsx', datestr(now, 'yyyy-mm-dd'));
writetable(output_z_arousal, filename_at);
filename_wt = sprintf('data_worry_z_%s.xlsx', datestr(now, 'yyyy-mm-dd'));
writetable(output_z_worry, filename_wt);
