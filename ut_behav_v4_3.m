%% Code for processing task performance measures (response time, accuracy)

clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Adjust file location & number of subjects to include in the analysis
dataDir = 'G:\다른 컴퓨터\내 컴퓨터\SDC\ResearchNotes\01TUTA\01RESULTS\02Performance'; % directory of data files
baseDir = 'G:\다른 컴퓨터\내 컴퓨터\SDC\ResearchNotes\01TUTA\02ANALYSIS\00Analyses'; % directory for output and code
%dataDir = 'E:\작업\SDC\ResearchNotes\01TUTA\01RESULTS\02Performance';
%baseDir = 'E:\작업\SDC\ResearchNotes\01TUTA\02ANALYSIS\00Analyses';
analysisName = '220617'; % Name of the folder that saves results
% subsIncl = [1:63]; % change this to the subject numbers you want to include
subsIncl = [2:14, 16:18, 20:22, 24:44, 46:58, 61:63];
%subsIncl = [1 56 62]; % change this to the subject numbers you want to include
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Import settings

opts = delimitedTextImportOptions("NumVariables", 31);
 
% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = "\t";
 
% Specify column names and types
opts.VariableNames = ["subject", "visit", "order", "cb", "run", "wm_type", "shock_level", "date_time", "trial", "trial_start_time", "startle_time", "target_time", "shock_time", "instructions", "npu", "certain", "load", "cue", "discard_trial", "before_startle_trial", "shock_trial", "startle_trial", "match", "letter_presented", "nback_letter", "spatial_quadrant", "nback_spatial", "target_button", "actual_button", "reaction_time", "accuracy"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "categorical", "double", "categorical", "double", "double", "double", "double", "double", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "double", "double", "double", "categorical"];
 
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
 
% Specify variable properties
opts = setvaropts(opts, ["wm_type", "date_time", "instructions", "npu", "certain", "load", "cue", "discard_trial", "before_startle_trial", "shock_trial", "startle_trial", "match", "letter_presented", "nback_letter", "spatial_quadrant", "nback_spatial", "accuracy"], "EmptyFieldRule", "auto");

%% Import performance data

cd(dataDir);
path_directory=pwd; % current directory that contains behavioral data
original_files=dir([path_directory '/*summary.txt']);
fprintf("uploaded files:" + '\n')

nameSubfiles = {}; 
for i = subsIncl % creates list of filenames to include
    for x=1:length(original_files)
        filename=[original_files(x).name];
        if str2double(filename(2:3)) == i
            disp(filename)
            nameSubfiles{end+1} = filename;
        end
    end
end

data = {};
for k= nameSubfiles % import selected files
    data{end+1} = readtable(char(k), opts); % each table gets put into 'data'
end 

subjectData = {};
for m = subsIncl
    subjectIndx = [];
    for n = 1:length(data)
        if unique(data{n}.subject) == m
            subjectIndx(end+1) = n;
        end
    end
    subjectData{end+1} = vertcat(data{subjectIndx}); % concatenate tables for each subject runs   
end 

clear opts


%% MAIN PROCESSING

acc_cell = {};
rt_cell = {};
vars_acc_cell = {};
vars_rt_cell = {};

for ss = 1:length(subjectData)
    singledata = subjectData{ss};
    
    % Data reduction
    singledata = singledata((singledata.discard_trial == 'keeptrial'), :); % filter out 'discard trials' (e.g. instruction trials, beginning trials, etc.)
 
    %%% Compute ACCURACY
    for x=1:length(singledata.accuracy) % Convert text to numbers (Correct = 1; Incorrect/NoResponse = 0)
        if singledata.accuracy(x) == 'correct'
            singledata.accuracy(x) = '1';
        elseif singledata.accuracy(x) == 'incorrect'
            singledata.accuracy(x) = '0';
        elseif singledata.accuracy(x) == 'noresponse'
            singledata.accuracy(x) = '0';
        end
    end
    singledata.accuracy = str2double(string(singledata.accuracy));
    full_acc = varfun(@mean, singledata, "InputVariables","accuracy", ...
        "GroupingVariables",["subject","wm_type", "npu", "certain", "load", "cue"]); % Compute accuracy
    full_acc = removevars(full_acc, 'GroupCount');
    
    %%% Compute RT (for correct trials only)
    deleterow = int16.empty; % indicates row number of inaccurate trials to be deleted
    for y=1:length(singledata.accuracy)
        if singledata.accuracy(y,1) == 0
            deleterow(end+1) = y;
        end
    end
    correcttrials = singledata;
    correcttrials(deleterow,:) = []; % deletes inaccurate rows
    full_rt = varfun(@mean, correcttrials, "InputVariables","reaction_time", "GroupingVariables",["subject","wm_type", "npu", "certain", "load", "cue"]); % using the data with only correct trials, compute RT per condition
    full_rt = removevars(full_rt, 'GroupCount');    
    
    % Data formatting
    subject = unique(singledata.subject);
    
    %%% Accuracy        
    %%%%% verbal
    v_n_cert_low_noq = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'n' & full_acc.certain == 'certain' & full_acc.load == 'low' & full_acc.cue == 'nocolortrial');
    v_n_cert_low_q = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'n' & full_acc.certain == 'certain' & full_acc.load == 'low' & full_acc.cue == 'colortrial');
    v_n_cert_high_noq = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'n' & full_acc.certain == 'certain' & full_acc.load == 'high' & full_acc.cue == 'nocolortrial');
    v_n_cert_high_q = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'n' & full_acc.certain == 'certain' & full_acc.load == 'high' & full_acc.cue == 'colortrial');
    
    v_n_uncert_low_noq = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'n' & full_acc.certain == 'uncertain' & full_acc.load == 'low' & full_acc.cue == 'nocolortrial');
    v_n_uncert_low_q = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'n' & full_acc.certain == 'uncertain' & full_acc.load == 'low' & full_acc.cue == 'colortrial');
    v_n_uncert_high_noq = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'n' & full_acc.certain == 'uncertain' & full_acc.load == 'high' & full_acc.cue == 'nocolortrial');
    v_n_uncert_high_q = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'n' & full_acc.certain == 'uncertain' & full_acc.load == 'high' & full_acc.cue == 'colortrial');  

    v_p_cert_low_noq = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'p' & full_acc.certain == 'certain' & full_acc.load == 'low' & full_acc.cue == 'nocolortrial');
    v_p_cert_low_q = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'p' & full_acc.certain == 'certain' & full_acc.load == 'low' & full_acc.cue == 'colortrial');
    v_p_cert_high_noq = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'p' & full_acc.certain == 'certain' & full_acc.load == 'high' & full_acc.cue == 'nocolortrial');
    v_p_cert_high_q = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'p' & full_acc.certain == 'certain' & full_acc.load == 'high' & full_acc.cue == 'colortrial');

    v_p_uncert_low_noq = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'p' & full_acc.certain == 'uncertain' & full_acc.load == 'low' & full_acc.cue == 'nocolortrial');
    v_p_uncert_low_q = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'p' & full_acc.certain == 'uncertain' & full_acc.load == 'low' & full_acc.cue == 'colortrial');
    v_p_uncert_high_noq = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'p' & full_acc.certain == 'uncertain' & full_acc.load == 'high' & full_acc.cue == 'nocolortrial');
    v_p_uncert_high_q = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'p' & full_acc.certain == 'uncertain' & full_acc.load == 'high' & full_acc.cue == 'colortrial');       

    v_u_cert_low_noq = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'u' & full_acc.certain == 'certain' & full_acc.load == 'low' & full_acc.cue == 'nocolortrial');
    v_u_cert_low_q = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'u' & full_acc.certain == 'certain' & full_acc.load == 'low' & full_acc.cue == 'colortrial');
    v_u_cert_high_noq = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'u' & full_acc.certain == 'certain' & full_acc.load == 'high' & full_acc.cue == 'nocolortrial');
    v_u_cert_high_q = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'u' & full_acc.certain == 'certain' & full_acc.load == 'high' & full_acc.cue == 'colortrial');

    v_u_uncert_low_noq = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'u' & full_acc.certain == 'uncertain' & full_acc.load == 'low' & full_acc.cue == 'nocolortrial');
    v_u_uncert_low_q = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'u' & full_acc.certain == 'uncertain' & full_acc.load == 'low' & full_acc.cue == 'colortrial');
    v_u_uncert_high_noq = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'u' & full_acc.certain == 'uncertain' & full_acc.load == 'high' & full_acc.cue == 'nocolortrial');
    v_u_uncert_high_q = full_acc.mean_accuracy(full_acc.wm_type == 'verbal' & full_acc.npu == 'u' & full_acc.certain == 'uncertain' & full_acc.load == 'high' & full_acc.cue == 'colortrial');       

    %%%%% spatial
    s_n_cert_low_noq = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'n' & full_acc.certain == 'certain' & full_acc.load == 'low' & full_acc.cue == 'nocolortrial');
    s_n_cert_low_q = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'n' & full_acc.certain == 'certain' & full_acc.load == 'low' & full_acc.cue == 'colortrial');
    s_n_cert_high_noq = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'n' & full_acc.certain == 'certain' & full_acc.load == 'high' & full_acc.cue == 'nocolortrial');
    s_n_cert_high_q = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'n' & full_acc.certain == 'certain' & full_acc.load == 'high' & full_acc.cue == 'colortrial');

    s_n_uncert_low_noq = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'n' & full_acc.certain == 'uncertain' & full_acc.load == 'low' & full_acc.cue == 'nocolortrial');
    s_n_uncert_low_q = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'n' & full_acc.certain == 'uncertain' & full_acc.load == 'low' & full_acc.cue == 'colortrial');
    s_n_uncert_high_noq = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'n' & full_acc.certain == 'uncertain' & full_acc.load == 'high' & full_acc.cue == 'nocolortrial');
    s_n_uncert_high_q = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'n' & full_acc.certain == 'uncertain' & full_acc.load == 'high' & full_acc.cue == 'colortrial');  

    s_p_cert_low_noq = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'p' & full_acc.certain == 'certain' & full_acc.load == 'low' & full_acc.cue == 'nocolortrial');
    s_p_cert_low_q = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'p' & full_acc.certain == 'certain' & full_acc.load == 'low' & full_acc.cue == 'colortrial');
    s_p_cert_high_noq = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'p' & full_acc.certain == 'certain' & full_acc.load == 'high' & full_acc.cue == 'nocolortrial');
    s_p_cert_high_q = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'p' & full_acc.certain == 'certain' & full_acc.load == 'high' & full_acc.cue == 'colortrial');

    s_p_uncert_low_noq = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'p' & full_acc.certain == 'uncertain' & full_acc.load == 'low' & full_acc.cue == 'nocolortrial');
    s_p_uncert_low_q = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'p' & full_acc.certain == 'uncertain' & full_acc.load == 'low' & full_acc.cue == 'colortrial');
    s_p_uncert_high_noq = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'p' & full_acc.certain == 'uncertain' & full_acc.load == 'high' & full_acc.cue == 'nocolortrial');
    s_p_uncert_high_q = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'p' & full_acc.certain == 'uncertain' & full_acc.load == 'high' & full_acc.cue == 'colortrial');       

    s_u_cert_low_noq = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'u' & full_acc.certain == 'certain' & full_acc.load == 'low' & full_acc.cue == 'nocolortrial');
    s_u_cert_low_q = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'u' & full_acc.certain == 'certain' & full_acc.load == 'low' & full_acc.cue == 'colortrial');
    s_u_cert_high_noq = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'u' & full_acc.certain == 'certain' & full_acc.load == 'high' & full_acc.cue == 'nocolortrial');
    s_u_cert_high_q = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'u' & full_acc.certain == 'certain' & full_acc.load == 'high' & full_acc.cue == 'colortrial');

    s_u_uncert_low_noq = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'u' & full_acc.certain == 'uncertain' & full_acc.load == 'low' & full_acc.cue == 'nocolortrial');
    s_u_uncert_low_q = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'u' & full_acc.certain == 'uncertain' & full_acc.load == 'low' & full_acc.cue == 'colortrial');
    s_u_uncert_high_noq = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'u' & full_acc.certain == 'uncertain' & full_acc.load == 'high' & full_acc.cue == 'nocolortrial');
    s_u_uncert_high_q = full_acc.mean_accuracy(full_acc.wm_type == 'spatial' & full_acc.npu == 'u' & full_acc.certain == 'uncertain' & full_acc.load == 'high' & full_acc.cue == 'colortrial');       
    
    vars_acc_cell{end+1} = {subject, v_n_cert_low_noq, v_n_cert_low_q, v_n_cert_high_noq, v_n_cert_high_q, ...
                v_n_uncert_low_noq, v_n_uncert_low_q, v_n_uncert_high_noq, v_n_uncert_high_q, ...
                v_p_cert_low_noq, v_p_cert_low_q, v_p_cert_high_noq, v_p_cert_high_q, ...
                v_p_uncert_low_noq, v_p_uncert_low_q, v_p_uncert_high_noq, v_p_uncert_high_q, ...
                v_u_cert_low_noq, v_u_cert_low_q, v_u_cert_high_noq, v_u_cert_high_q, ...
                v_u_uncert_low_noq, v_u_uncert_low_q, v_u_uncert_high_noq, v_u_uncert_high_q, ... 
                s_n_cert_low_noq, s_n_cert_low_q, s_n_cert_high_noq, s_n_cert_high_q, ...
                s_n_uncert_low_noq, s_n_uncert_low_q, s_n_uncert_high_noq, s_n_uncert_high_q, ...
                s_p_cert_low_noq, s_p_cert_low_q, s_p_cert_high_noq, s_p_cert_high_q, ...
                s_p_uncert_low_noq, s_p_uncert_low_q, s_p_uncert_high_noq, s_p_uncert_high_q, ...
                s_u_cert_low_noq, s_u_cert_low_q, s_u_cert_high_noq, s_u_cert_high_q, ...
                s_u_uncert_low_noq, s_u_uncert_low_q, s_u_uncert_high_noq, s_u_uncert_high_q};

    %%% Response Time        
    %%%%% verbal        
    v_n_cert_low_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'n' & full_rt.certain == 'certain' & full_rt.load == 'low' & full_rt.cue == 'nocolortrial');
    v_n_cert_low_q = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'n' & full_rt.certain == 'certain' & full_rt.load == 'low' & full_rt.cue == 'colortrial');
    v_n_cert_high_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'n' & full_rt.certain == 'certain' & full_rt.load == 'high' & full_rt.cue == 'nocolortrial');
    v_n_cert_high_q = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'n' & full_rt.certain == 'certain' & full_rt.load == 'high' & full_rt.cue == 'colortrial');
         
    v_n_uncert_low_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'n' & full_rt.certain == 'uncertain' & full_rt.load == 'low' & full_rt.cue == 'nocolortrial');
    v_n_uncert_low_q = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'n' & full_rt.certain == 'uncertain' & full_rt.load == 'low' & full_rt.cue == 'colortrial');
    v_n_uncert_high_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'n' & full_rt.certain == 'uncertain' & full_rt.load == 'high' & full_rt.cue == 'nocolortrial');
    v_n_uncert_high_q = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'n' & full_rt.certain == 'uncertain' & full_rt.load == 'high' & full_rt.cue == 'colortrial');  
         
    v_p_cert_low_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'p' & full_rt.certain == 'certain' & full_rt.load == 'low' & full_rt.cue == 'nocolortrial');
    v_p_cert_low_q = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'p' & full_rt.certain == 'certain' & full_rt.load == 'low' & full_rt.cue == 'colortrial');
    v_p_cert_high_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'p' & full_rt.certain == 'certain' & full_rt.load == 'high' & full_rt.cue == 'nocolortrial');
    v_p_cert_high_q = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'p' & full_rt.certain == 'certain' & full_rt.load == 'high' & full_rt.cue == 'colortrial');
         
    v_p_uncert_low_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'p' & full_rt.certain == 'uncertain' & full_rt.load == 'low' & full_rt.cue == 'nocolortrial');
    v_p_uncert_low_q = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'p' & full_rt.certain == 'uncertain' & full_rt.load == 'low' & full_rt.cue == 'colortrial');
    v_p_uncert_high_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'p' & full_rt.certain == 'uncertain' & full_rt.load == 'high' & full_rt.cue == 'nocolortrial');
    v_p_uncert_high_q = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'p' & full_rt.certain == 'uncertain' & full_rt.load == 'high' & full_rt.cue == 'colortrial');       
  
    v_u_cert_low_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'u' & full_rt.certain == 'certain' & full_rt.load == 'low' & full_rt.cue == 'nocolortrial');
    v_u_cert_low_q = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'u' & full_rt.certain == 'certain' & full_rt.load == 'low' & full_rt.cue == 'colortrial');
    v_u_cert_high_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'u' & full_rt.certain == 'certain' & full_rt.load == 'high' & full_rt.cue == 'nocolortrial');
    v_u_cert_high_q = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'u' & full_rt.certain == 'certain' & full_rt.load == 'high' & full_rt.cue == 'colortrial');
         
    v_u_uncert_low_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'u' & full_rt.certain == 'uncertain' & full_rt.load == 'low' & full_rt.cue == 'nocolortrial');
    v_u_uncert_low_q = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'u' & full_rt.certain == 'uncertain' & full_rt.load == 'low' & full_rt.cue == 'colortrial');
    v_u_uncert_high_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'u' & full_rt.certain == 'uncertain' & full_rt.load == 'high' & full_rt.cue == 'nocolortrial');
    v_u_uncert_high_q = full_rt.mean_reaction_time(full_rt.wm_type == 'verbal' & full_rt.npu == 'u' & full_rt.certain == 'uncertain' & full_rt.load == 'high' & full_rt.cue == 'colortrial');       
    
    %%%%% spatial 
    s_n_cert_low_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'n' & full_rt.certain == 'certain' & full_rt.load == 'low' & full_rt.cue == 'nocolortrial');
    s_n_cert_low_q = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'n' & full_rt.certain == 'certain' & full_rt.load == 'low' & full_rt.cue == 'colortrial');
    s_n_cert_high_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'n' & full_rt.certain == 'certain' & full_rt.load == 'high' & full_rt.cue == 'nocolortrial');
    s_n_cert_high_q = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'n' & full_rt.certain == 'certain' & full_rt.load == 'high' & full_rt.cue == 'colortrial');
         
    s_n_uncert_low_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'n' & full_rt.certain == 'uncertain' & full_rt.load == 'low' & full_rt.cue == 'nocolortrial');
    s_n_uncert_low_q = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'n' & full_rt.certain == 'uncertain' & full_rt.load == 'low' & full_rt.cue == 'colortrial');
    s_n_uncert_high_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'n' & full_rt.certain == 'uncertain' & full_rt.load == 'high' & full_rt.cue == 'nocolortrial');
    s_n_uncert_high_q = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'n' & full_rt.certain == 'uncertain' & full_rt.load == 'high' & full_rt.cue == 'colortrial');  
         
    s_p_cert_low_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'p' & full_rt.certain == 'certain' & full_rt.load == 'low' & full_rt.cue == 'nocolortrial');
    s_p_cert_low_q = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'p' & full_rt.certain == 'certain' & full_rt.load == 'low' & full_rt.cue == 'colortrial');
    s_p_cert_high_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'p' & full_rt.certain == 'certain' & full_rt.load == 'high' & full_rt.cue == 'nocolortrial');
    s_p_cert_high_q = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'p' & full_rt.certain == 'certain' & full_rt.load == 'high' & full_rt.cue == 'colortrial');
         
    s_p_uncert_low_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'p' & full_rt.certain == 'uncertain' & full_rt.load == 'low' & full_rt.cue == 'nocolortrial');
    s_p_uncert_low_q = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'p' & full_rt.certain == 'uncertain' & full_rt.load == 'low' & full_rt.cue == 'colortrial');
    s_p_uncert_high_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'p' & full_rt.certain == 'uncertain' & full_rt.load == 'high' & full_rt.cue == 'nocolortrial');
    s_p_uncert_high_q = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'p' & full_rt.certain == 'uncertain' & full_rt.load == 'high' & full_rt.cue == 'colortrial');       
  
    s_u_cert_low_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'u' & full_rt.certain == 'certain' & full_rt.load == 'low' & full_rt.cue == 'nocolortrial');
    s_u_cert_low_q = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'u' & full_rt.certain == 'certain' & full_rt.load == 'low' & full_rt.cue == 'colortrial');
    s_u_cert_high_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'u' & full_rt.certain == 'certain' & full_rt.load == 'high' & full_rt.cue == 'nocolortrial');
    s_u_cert_high_q = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'u' & full_rt.certain == 'certain' & full_rt.load == 'high' & full_rt.cue == 'colortrial');
         
    s_u_uncert_low_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'u' & full_rt.certain == 'uncertain' & full_rt.load == 'low' & full_rt.cue == 'nocolortrial');
    s_u_uncert_low_q = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'u' & full_rt.certain == 'uncertain' & full_rt.load == 'low' & full_rt.cue == 'colortrial');
    s_u_uncert_high_noq = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'u' & full_rt.certain == 'uncertain' & full_rt.load == 'high' & full_rt.cue == 'nocolortrial');
    s_u_uncert_high_q = full_rt.mean_reaction_time(full_rt.wm_type == 'spatial' & full_rt.npu == 'u' & full_rt.certain == 'uncertain' & full_rt.load == 'high' & full_rt.cue == 'colortrial');       
   
    vars_rt_cell{end+1} = {subject, v_n_cert_low_noq, v_n_cert_low_q, v_n_cert_high_noq, v_n_cert_high_q, ...
                v_n_uncert_low_noq, v_n_uncert_low_q, v_n_uncert_high_noq, v_n_uncert_high_q, ...
                v_p_cert_low_noq, v_p_cert_low_q, v_p_cert_high_noq, v_p_cert_high_q, ...
                v_p_uncert_low_noq, v_p_uncert_low_q, v_p_uncert_high_noq, v_p_uncert_high_q, ...
                v_u_cert_low_noq, v_u_cert_low_q, v_u_cert_high_noq, v_u_cert_high_q, ...
                v_u_uncert_low_noq, v_u_uncert_low_q, v_u_uncert_high_noq, v_u_uncert_high_q, ... 
                s_n_cert_low_noq, s_n_cert_low_q, s_n_cert_high_noq, s_n_cert_high_q, ...
                s_n_uncert_low_noq, s_n_uncert_low_q, s_n_uncert_high_noq, s_n_uncert_high_q, ...
                s_p_cert_low_noq, s_p_cert_low_q, s_p_cert_high_noq, s_p_cert_high_q, ...
                s_p_uncert_low_noq, s_p_uncert_low_q, s_p_uncert_high_noq, s_p_uncert_high_q, ...
                s_u_cert_low_noq, s_u_cert_low_q, s_u_cert_high_noq, s_u_cert_high_q, ...
                s_u_uncert_low_noq, s_u_uncert_low_q, s_u_uncert_high_noq, s_u_uncert_high_q};    
    
end 

output_acc = vertcat(vars_acc_cell{:});
output_rt = vertcat(vars_rt_cell{:});

output_acc = cell2table(output_acc, 'VariableNames', ...
    {'subject', 'v_n_cert_low_noq', 'v_n_cert_low_q', 'v_n_cert_high_noq', 'v_n_cert_high_q', ...
                'v_n_uncert_low_noq', 'v_n_uncert_low_q', 'v_n_uncert_high_noq', 'v_n_uncert_high_q', ...
                'v_p_cert_low_noq', 'v_p_cert_low_q', 'v_p_cert_high_noq', 'v_p_cert_high_q', ...
                'v_p_uncert_low_noq', 'v_p_uncert_low_q', 'v_p_uncert_high_noq', 'v_p_uncert_high_q', ...
                'v_u_cert_low_noq', 'v_u_cert_low_q', 'v_u_cert_high_noq', 'v_u_cert_high_q', ...
                'v_u_uncert_low_noq', 'v_u_uncert_low_q', 'v_u_uncert_high_noq', 'v_u_uncert_high_q', ... 
                's_n_cert_low_noq', 's_n_cert_low_q', 's_n_cert_high_noq', 's_n_cert_high_q', ...
                's_n_uncert_low_noq', 's_n_uncert_low_q', 's_n_uncert_high_noq', 's_n_uncert_high_q', ...
                's_p_cert_low_noq', 's_p_cert_low_q', 's_p_cert_high_noq', 's_p_cert_high_q', ...
                's_p_uncert_low_noq', 's_p_uncert_low_q', 's_p_uncert_high_noq', 's_p_uncert_high_q', ...
                's_u_cert_low_noq', 's_u_cert_low_q', 's_u_cert_high_noq', 's_u_cert_high_q', ...
                's_u_uncert_low_noq', 's_u_uncert_low_q', 's_u_uncert_high_noq', 's_u_uncert_high_q'});

output_rt = cell2table(output_rt, 'VariableNames', ...
    {'subject', 'v_n_cert_low_noq', 'v_n_cert_low_q', 'v_n_cert_high_noq', 'v_n_cert_high_q', ...
                'v_n_uncert_low_noq', 'v_n_uncert_low_q', 'v_n_uncert_high_noq', 'v_n_uncert_high_q', ...
                'v_p_cert_low_noq', 'v_p_cert_low_q', 'v_p_cert_high_noq', 'v_p_cert_high_q', ...
                'v_p_uncert_low_noq', 'v_p_uncert_low_q', 'v_p_uncert_high_noq', 'v_p_uncert_high_q', ...
                'v_u_cert_low_noq', 'v_u_cert_low_q', 'v_u_cert_high_noq', 'v_u_cert_high_q', ...
                'v_u_uncert_low_noq', 'v_u_uncert_low_q', 'v_u_uncert_high_noq', 'v_u_uncert_high_q', ... 
                's_n_cert_low_noq', 's_n_cert_low_q', 's_n_cert_high_noq', 's_n_cert_high_q', ...
                's_n_uncert_low_noq', 's_n_uncert_low_q', 's_n_uncert_high_noq', 's_n_uncert_high_q', ...
                's_p_cert_low_noq', 's_p_cert_low_q', 's_p_cert_high_noq', 's_p_cert_high_q', ...
                's_p_uncert_low_noq', 's_p_uncert_low_q', 's_p_uncert_high_noq', 's_p_uncert_high_q', ...
                's_u_cert_low_noq', 's_u_cert_low_q', 's_u_cert_high_noq', 's_u_cert_high_q', ...
                's_u_uncert_low_noq', 's_u_uncert_low_q', 's_u_uncert_high_noq', 's_u_uncert_high_q'});
            
            
%% Output

% Create output folder
cd(baseDir);
if (~exist(analysisName, 'dir')); mkdir(analysisName); end
cd(analysisName);

% Export data

output_name_acc = sprintf('output_acc_%s.xlsx', datestr(now, 'yyyy-mm-dd'));
writetable(output_acc, output_name_acc);
output_name_rt = sprintf('output_rt_%s.xlsx', datestr(now, 'yyyy-mm-dd'));
writetable(output_rt, output_name_rt);