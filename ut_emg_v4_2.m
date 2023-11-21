%% Code for processing EMG signal (overall T values, APS/FPS)

clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Adjust file location & number of subjects to include in the analysis
dataDir = 'G:\다른 컴퓨터\내 컴퓨터\SDC\ResearchNotes\01TUTA\01RESULTS\01EMG\results'; % directory of data files
baseDir = 'G:\다른 컴퓨터\내 컴퓨터\SDC\ResearchNotes\01TUTA\02ANALYSIS\00Analyses'; % directory for output and code
%dataDir = 'E:\작업\SDC\ResearchNotes\01TUTA\01RESULTS\01EMG\results';
%baseDir = 'E:\작업\SDC\ResearchNotes\01TUTA\02ANALYSIS\00Analyses';
analysisName = '220617'; % Name of the folder that saves results
% subsIncl = [56 62]; % change this to the subject numbers you want to include
% subsIncl = [15,23,62,63]; % change this to the subject numbers you want to include
%subsIncl = [1:63]; % change this to the subject numbers you want to include
subsIncl = [2:14, 16:18, 20:22, 24:44, 46:58, 61:63]; % change this to the subject numbers you want to include

exportQC = 1; % 1='yes', 0='no'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Import Settings

opts = delimitedTextImportOptions("NumVariables", 26);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["trialsub", "channelnametrial", "trialcount", "trialonset", "peakonset", "ttlval", "keeptrial", "blinktrial", "smoothedstdrep", "hsmoothedstdrep", "blmean", "hblmean", "blminmax", "hblminmax", "blstd", "hblstd", "rawtrialpeak", "filteredtrialpeak", "rectifiedtrialpeak", "hilberttrialpeak", "smoothedtrialpeak", "hsmoothedtrialpeak", "smootheddiff", "hsmootheddiff", "cleanraw", "tscore"];
opts.VariableTypes = ["categorical", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "trialsub", "EmptyFieldRule", "auto");
opts = setvaropts(opts, "channelnametrial", "TrimNonNumeric", true);
opts = setvaropts(opts, "channelnametrial", "ThousandsSeparator", ",");

%% Import EMG data

cd(dataDir);
path_directory=pwd; % current directory that contains EMG data
original_files=dir([path_directory '/*EMG100C.csv']);
fprintf("uploaded files:" + '\n')

nameSubfiles = {}; 
for h = subsIncl % creates list of filenames to include
    for i=1:length(original_files)
        filename=[original_files(i).name];
        if str2double(filename(2:3)) == h
            disp(filename)
            nameSubfiles{end+1} = filename;
        end
    end
end

data = {};
for k= nameSubfiles % import selected files
    data{end+1} = readtable(char(k), opts); % each table gets put into 'data'
end 
clear opts

%% Labeling
% Add label to data: subject, session, run, type
for j = 1:length(data)
    run_array = [];
    clear type_array
    
    % Create 'subject' column
    subject = str2double(extractBefore(string(data{j}.trialsub), '_0'));
    data{j} = addvars(data{j}, subject, 'Before', 'trialsub', 'NewVariableNames', {'subject'});
    
    % Create 'session' column
    session = str2double(extractBetween(string(data{j}.trialsub), '_','_run'));
    data{j} = addvars(data{j}, session, 'After', 'subject', 'NewVariableNames', {'session'});
    
    % Create 'run' column   
    if contains(string(unique(data{j}.trialsub)), 'run1')
        run = 1;
    elseif contains(string(unique(data{j}.trialsub)), 'run2')
        run = 2;
    end
    run_array(1:length(data{j}.trialsub),1)=run;
    data{j} = addvars(data{j}, run_array, 'After', 'session', 'NewVariableNames', {'run'});
 
    % Create 'type' column
    if contains(string(unique(data{j}.trialsub)), 'v')
        type = 'v';
    elseif contains(string(unique(data{j}.trialsub)), 's')
        type = 's';
    end
    type_array(1:length(data{j}.trialsub),1)=type;
    data{j} = addvars(data{j}, categorical(cellstr(type_array)), 'Before', 'ttlval', 'NewVariableNames', {'type'});

end

%% Compute new T values (T3=per session, T4=per subject)
sessionData = {};
for m = subsIncl % This loop concatenates each subject files per session (i.e., session1, session2)
    subjectIndx = [];
    fprintf("subject:" + m + '\n')
    for n = 1:length(data)
        if unique(data{n}.subject) == m
            subjectIndx(end+1) = n;
        end
    end
 
    session1indx = [];
    session2indx = [];
    for o = subjectIndx
        if unique(data{o}.session) == 1
            session1indx(end+1) = o;
        elseif unique(data{o}.session) == 2
            session2indx(end+1) = o;
        end 
    end
    sessionData{end+1} = vertcat(data{session1indx});
    sessionData{end+1} = vertcat(data{session2indx});
    %subjectData{end+1} = vertcat(data{subjectIndx});
end

toDelete = [];
for p = 1:length(sessionData) % for empty sessions (i.e., subject 19)
    if isempty(sessionData{p})
        toDelete(end+1) = p;
    end
end 

sessionData(toDelete) = []; % delete empty cell

for p = 1:length(sessionData) % This loop computes new T score using full session. (T3)
    cleanraw = sessionData{p}.cleanraw;
    tscore3 = (cleanraw-nanmean(cleanraw))/nanstd(cleanraw)*10 + 50;
    sessionData{p} = addvars(sessionData{p}, tscore3, 'After', 'tscore', 'NewVariableNames', 'tscore3');
end

subjectData = {};
for q = subsIncl % concatenate tables for each subject
    subjectIndx = [];
    for r = 1:length(sessionData)
        if unique(sessionData{r}.subject) == q
            subjectIndx(end+1) = r;
        end
    end
    subjectData{end+1} = vertcat(sessionData{subjectIndx}); 
end 

for t = 1:length(subjectData) % This loop computes new T score for each subject. (T4)
    cleanraw = subjectData{t}.cleanraw;
    tscore4 = (cleanraw-nanmean(cleanraw))/nanstd(cleanraw)*10 + 50;
    subjectData{t} = addvars(subjectData{t}, tscore4, 'After', 'tscore3', 'NewVariableNames', {'tscore4'});
end
         
%% Quality check (number of blinks, bad trials)

% Check mean blinks per subject

qc_cell ={};
for t = 1:length(subjectData)
    curSub = unique(subjectData{t}.subject); % current subject number
    meanKeeps = mean(subjectData{t}.keeptrial); % mean KeepTrials
    meanBlinks = mean(subjectData{t}.blinktrial); % mean BlinkTrials
    blinkperCond = varfun(@mean, subjectData{t}, 'InputVariables', 'blinktrial', 'GroupingVariables', {'type', 'ttlval'}).mean_blinktrial; % Mean BlinkTrials per condition (N=48)
    howmanyCond = length(blinkperCond); % how many conditions were exposed to this participant?
    blinkCutoff = 24; % cutoff piont = 0 blinks for more than 50% of all conditions (N=24)
    noBlinkCond = sum(blinkperCond(:) == 0); % how many NoBlinks per condition
    keepTrials = varfun(@mean, subjectData{t}, 'InputVariables', 'keeptrial', 'GroupingVariables', {'type', 'ttlval'}).mean_keeptrial;
    badTrials = sum(keepTrials(:) <= 0.5);
    if noBlinkCond >= blinkCutoff %| meanBlinks < 0.25 
        excludeSubject = 1; % "exclude" % subjects who have lower blinks than blinkCutoff or lower than 25% blinks overall should be considered for exclusion.
    elseif badTrials >=1 % exclude subjects who have lower than 50% good trials in any given condition.
        excludeSubject =1;
    else
        excludeSubject = 0; % "keep"
    end    
    
    qc_cell{end+1} = {curSub, meanKeeps, meanBlinks, howmanyCond, noBlinkCond, excludeSubject};
end

output_qc = vertcat(qc_cell{:});
output_qc = cell2table(output_qc, 'VariableNames', ...
    {'Subject', 'KeepTrials', 'BlinkTrials', 'Conditions', 'NoBlinkConditions', 'ExcludeSubject'});

%% Data Reduction


processedData = {};
T1_cell = {};
T3_cell = {};
T4_cell = {};
for x = 1:length(subjectData)
    T_cell = {};
    ss = subjectData{x};
    ss = ss(ss.keeptrial==1,:); % Delete NoGood trials
    
    t1_mean = varfun(@mean, ss, 'InputVariables', 'tscore', 'GroupingVariables', ["subject", "type", "ttlval"]);
    t3_mean = varfun(@mean, ss, 'InputVariables', 'tscore3', 'GroupingVariables', ["subject", "type", "ttlval"]);
    t4_mean = varfun(@mean, ss, 'InputVariables', 'tscore4', 'GroupingVariables', ["subject", "type", "ttlval"]);
    
    t1_mean = removevars(t1_mean, 'GroupCount');
    t3_mean = removevars(t3_mean, 'GroupCount');    
    t4_mean = removevars(t4_mean, 'GroupCount');
    
    t1_mean = renamevars(t1_mean, 'mean_tscore', 'mean_tscore');    
    t3_mean = renamevars(t3_mean, 'mean_tscore3', 'mean_tscore');
    t4_mean = renamevars(t4_mean, 'mean_tscore4', 'mean_tscore');
    
    T_cell = {t1_mean, t3_mean, t4_mean};

    
    for y = 1:length(T_cell)
        
        subjectID = unique(T_cell{y}.subject);
        if y == 1
            T_value = 1;
        elseif y == 2
            T_value = 3;
        elseif y== 3
            T_value = 4;
        end
        
        v_n_uncert_low_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 4);
        v_n_uncert_high_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 12);
        v_n_cert_low_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 20);
        v_n_cert_high_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 28);
        v_p_uncert_low_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 36);
        v_p_uncert_high_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 44);
        v_p_cert_low_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 52);
        v_p_cert_high_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 60);
        v_u_uncert_low_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 68);
        v_u_uncert_high_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 76);
        v_u_cert_low_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 84);
        v_u_cert_high_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 92);    
        v_n_uncert_low_q = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 132);
        v_n_uncert_high_q = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 140);
        v_n_cert_low_q = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 148);
        v_n_cert_high_q = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 156);
        v_p_uncert_low_q = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 164);
        v_p_uncert_high_q = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 172);
        v_p_cert_low_q = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 180);
        v_p_cert_high_q = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 188);
        v_u_uncert_low_q = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 196);
        v_u_uncert_high_q = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 204);
        v_u_cert_low_q = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 212);
        v_u_cert_high_q = T_cell{y}.mean_tscore(T_cell{y}.type == 'v' & T_cell{y}.ttlval == 220);
        
        s_n_uncert_low_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 4);
        s_n_uncert_high_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 12);
        s_n_cert_low_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 20);
        s_n_cert_high_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 28);
        s_p_uncert_low_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 36);
        s_p_uncert_high_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 44);
        s_p_cert_low_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 52);
        s_p_cert_high_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 60);
        s_u_uncert_low_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 68);
        s_u_uncert_high_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 76);
        s_u_cert_low_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 84);
        s_u_cert_high_noq = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 92);    
        s_n_uncert_low_q = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 132);
        s_n_uncert_high_q = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 140);
        s_n_cert_low_q = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 148);
        s_n_cert_high_q = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 156);
        s_p_uncert_low_q = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 164);
        s_p_uncert_high_q = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 172);
        s_p_cert_low_q = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 180);
        s_p_cert_high_q = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 188);
        s_u_uncert_low_q = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 196);
        s_u_uncert_high_q = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 204);
        s_u_cert_low_q = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 212);
        s_u_cert_high_q = T_cell{y}.mean_tscore(T_cell{y}.type == 's' & T_cell{y}.ttlval == 220);
        
        vANXnc_certain_low = v_u_cert_low_noq - v_n_cert_low_noq;
        vANXnc_certain_high = v_u_cert_high_noq - v_n_cert_high_noq;
        vANXnc_uncertain_low = v_u_uncert_low_noq - v_n_uncert_low_noq;
        vANXnc_uncertain_high = v_u_uncert_high_noq - v_n_uncert_high_noq;
        vANXcue_certain_low = v_u_cert_low_q - v_n_cert_low_q;
        vANXcue_certain_high = v_u_cert_high_q - v_n_cert_high_q;
        vANXcue_uncertain_low = v_u_uncert_low_q - v_n_uncert_low_q;
        vANXcue_uncertain_high = v_u_uncert_high_q - v_n_uncert_high_q;
        vFEAR_certain_low = v_p_cert_low_q - v_p_cert_low_noq;
        vFEAR_certain_high = v_p_cert_high_q - v_p_cert_high_noq;
        vFEAR_uncertain_low = v_p_uncert_low_q - v_p_uncert_low_noq;
        vFEAR_uncertain_high = v_p_uncert_high_q - v_p_uncert_high_noq;       
        
        sANXnc_certain_low = s_u_cert_low_noq - s_n_cert_low_noq;
        sANXnc_certain_high = s_u_cert_high_noq - s_n_cert_high_noq;
        sANXnc_uncertain_low = s_u_uncert_low_noq - s_n_uncert_low_noq;
        sANXnc_uncertain_high = s_u_uncert_high_noq - s_n_uncert_high_noq;
        sANXcue_certain_low = s_u_cert_low_q - s_n_cert_low_q;
        sANXcue_certain_high = s_u_cert_high_q - s_n_cert_high_q;
        sANXcue_uncertain_low = s_u_uncert_low_q - s_n_uncert_low_q;
        sANXcue_uncertain_high = s_u_uncert_high_q - s_n_uncert_high_q;
        sFEAR_certain_low = s_p_cert_low_q - s_p_cert_low_noq;
        sFEAR_certain_high = s_p_cert_high_q - s_p_cert_high_noq;
        sFEAR_uncertain_low = s_p_uncert_low_q - s_p_uncert_low_noq;
        sFEAR_uncertain_high = s_p_uncert_high_q - s_p_uncert_high_noq;       
        
        data_cell = {subjectID, T_value, v_n_cert_low_noq, v_n_cert_low_q, v_n_cert_high_noq, v_n_cert_high_q, ...
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
                s_u_uncert_low_noq, s_u_uncert_low_q, s_u_uncert_high_noq, s_u_uncert_high_q, ...
                vANXnc_certain_low, vANXnc_certain_high, vANXnc_uncertain_low, vANXnc_uncertain_high, ...
                vANXcue_certain_low, vANXcue_certain_high, vANXcue_uncertain_low, vANXcue_uncertain_high, ...
                vFEAR_certain_low, vFEAR_certain_high, vFEAR_uncertain_low, vFEAR_uncertain_high, ...
                sANXnc_certain_low, sANXnc_certain_high, sANXnc_uncertain_low, sANXnc_uncertain_high, ...
                sANXcue_certain_low, sANXcue_certain_high, sANXcue_uncertain_low, sANXcue_uncertain_high, ...
                sFEAR_certain_low, sFEAR_certain_high, sFEAR_uncertain_low, sFEAR_uncertain_high}; 
        
         % This may seem redundant, but converting a cell to a table was the easiest way to create tables with missing values.
            
         data_table = cell2table(data_cell, 'VariableNames', ...
             {'subjectID', 'T_value', 'v_n_cert_low_noq', 'v_n_cert_low_q', 'v_n_cert_high_noq', 'v_n_cert_high_q', ...
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
             's_u_uncert_low_noq', 's_u_uncert_low_q', 's_u_uncert_high_noq', 's_u_uncert_high_q', ...
             'vANXnc_certain_low', 'vANXnc_certain_high', 'vANXnc_uncertain_low', 'vANXnc_uncertain_high', ...
             'vANXcue_certain_low', 'vANXcue_certain_high', 'vANXcue_uncertain_low', 'vANXcue_uncertain_high' ...
             'vFEAR_certain_low', 'vFEAR_certain_high', 'vFEAR_uncertain_low', 'vFEAR_uncertain_high', ...
             'sANXnc_certain_low', 'sANXnc_certain_high', 'sANXnc_uncertain_low', 'sANXnc_uncertain_high', ...
             'sANXcue_certain_low', 'sANXcue_certain_high', 'sANXcue_uncertain_low', 'sANXcue_uncertain_high', ...
             'sFEAR_certain_low', 'sFEAR_certain_high', 'sFEAR_uncertain_low', 'sFEAR_uncertain_high'});       
        

        if T_value == 1
            T1_cell{end+1} = data_table;    
        elseif T_value == 3
            T3_cell{end+1} = data_table;
            
        elseif T_value == 4
            T4_cell{end+1} = data_table;
        else 
            fprintf("ERROR DURING SUBJECT: " + subjectID + '. CHECK T VALUE INDEX.' + '\n')
        end 
    end
end 

%% Output

output_T1 = vertcat(T1_cell{:});
output_T3 = vertcat(T3_cell{:});
output_T4 = vertcat(T4_cell{:}); 

% Create output folder
cd(baseDir);
if (~exist(analysisName, 'dir')); mkdir(analysisName); end
cd(analysisName);

% Export data

output_name_T1 = sprintf('output_T1_%s.xlsx', datestr(now, 'yyyy-mm-dd'));
writetable(output_T1, output_name_T1);
output_name_T3 = sprintf('output_T3_%s.xlsx', datestr(now, 'yyyy-mm-dd'));
writetable(output_T3, output_name_T3);
output_name_T4 = sprintf('output_T4_%s.xlsx', datestr(now, 'yyyy-mm-dd'));
writetable(output_T4, output_name_T4);

output_name_QC = sprintf('QualityCheck_%s.xlsx', datestr(now, 'yyyy-mm-dd'));
if exportQC == 1
    writetable(output_qc, output_name_QC);
end



