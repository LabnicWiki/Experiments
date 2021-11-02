function [rsp]=AttentionalBlink(maskingon) %or chose ISI
%When people must identify two visual stimuli in quick succession, accuracy for the second stimulus is poor if it occurs within 200 to 500 ms of the first
%in this task, target is an X, which can be either on the left or right of
%the screen
% The Attentional blink is a phenomenon that reflects temporal limitations in the ability to deploy visual attention. When people must identify two visual stimuli in quick succession, accuracy
% for the second stimulus is poor if it occurs within 200 to 500 ms of the first.
% Clear work screens

% STIM DURATION: 100ms7
%ISI --> NEEDS TO BE DEFINED SUCH THAT THE LAGS SPAN THE ATTENTIONAL BLINK
%(e.g., lag=3 means ISI*3+ stimdur*2  between T1 and T2-- and needs to be enough to generate the attentional blink)
sca;

subnum =input( 'Subject number? ');
root= pwd;  mydir={};
if ~exist([root, filesep,'sub_', num2str(subnum)], 'dir')
    mkdir(root, ['sub_', num2str(subnum)]);
    mkdir([root,filesep,'sub_', num2str(subnum), filesep, 'beh']);
else
    msg='Subject number already exists. Check to not overwrite results file!'
    error(msg)
end
mydir.sub=([root, filesep,'sub_', num2str(subnum)]);
mydir.beh=([mydir.sub,filesep, 'beh']);



% Do not keep this in experiment - preference one
Screen('Preference','SkipSyncTests',1);
Screen('Preference','VisualDebugLevel',0);
Screen('Preference','Verbosity',0);
getScreens=Screen('Screens');
chosenScreen=max(getScreens);

% Luminance values
white=WhiteIndex(chosenScreen); %255
black=BlackIndex(chosenScreen);%0
grey=128.5;white/2; % 127
red   = [255 0 0];

% Open window
screensize = [200 80 1400 800]; % 200 80 1400 800
[w,scr_rect]=PsychImaging('OpenWindow',chosenScreen, black, screensize);
[width, height]=Screen('WindowSize', w);
% [0 0 900 675] it makes the screen smaller

% Center of the screen
% [centerX, centerY]=RectCenter(scr_rect);
ifi=Screen('GetFlipInterval',w);
hertz=FrameRate(w);
stim_dur = 0.08; %stimulus time
ISI      = 0.05; % time between stimuli Raphael : isi:30ms, stimdur=70ms ,
% dur_mask =ISI; %in seconds

% Define numtrials
tottrls  = 75; %15*condition (condition defined by lag type), you can increase as long as number which can be divided by 4 and gives integer
lagstype = [2,3,4]; % lag:1 = 180ms, lag:3 = 310ms, lag:4=440ms

all_lags = [repmat(2, 1, tottrls/3), repmat(3, 1, tottrls/3), repmat(4,1, tottrls/3)];
lags_rand = all_lags(randperm(numel(all_lags)));
stream =25; %how many numbers contained in a stream (how many digits contained in a trial)
[cond_list, rsp]=deal({});
pos=[];
for t=1:tottrls
    [cond_list{t}, pos(t)]= create_stim_T1T2_one_targ(stream, lags_rand(t));
    
end


% Drawing text
Screen('TextSize',w,60);
Screen('TextFont',w,'Helvetica');

% Animation loop
for trial=1:tottrls
    
    if trial==1 % Change the introduction
        DrawFormattedText(w,'You will now see a stream of letters in rapid succession\nYou will be asked to report when you see numbers.\nRemember the numbers you saw and report them at the end\nof every trial', 'center','center',white);
        Screen('Flip',w);
        WaitSecs(1);% KbStrokeWait;
    end
    
    for digit = 1:stream
        
        %If this is the first trial we present a start screen and wait for a
        % key-press
        
        DrawFormattedText(w,cell2mat(cond_list{1,trial}(digit)), 'center','center',white);
        Screen('Flip',w);
        WaitSecs(stim_dur);
        
        %function that calls the masking - makes the masking appear for duration
        %specified in dur_mask
        %     FastNoiseCe(1, screensize(3), screensize(4), 1, 1, dur_mask, 0, w, scr_rect, hertz)
        if maskingon
            FastNoiseCe(1, width, height, 1, 1, ISI, 0, w, scr_rect, hertz)
        else
            
            %     Blank screen
            Screen('FillRect',w,0); Screen('Flip',w); WaitSecs(ISI)
        end
        
        
    end
    
    DrawFormattedText(w,'What was T1?\nPress the respective key on the keyboard\nOr press -N- if you did not see it', 'center','center',white);
    Screen('Flip',w);
    [secs, keyCode, deltaSecs] = KbWait;
    %     KbStrokeWait
    %     [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    
    
    %     if(keyIsDown)
    rsp.T1{trial} = KbName(keyCode);
    %     end
    
    DrawFormattedText(w,'What was T2?\nPress the respective key on the keyboard\nOr press -N- if you did not see it', 'center','center',white);
    Screen('Flip',w); WaitSecs(1)
    %     KbStrokeWait
    [secs, keyCode, deltaSecs] = KbWait;
    %     [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    
    %     if(keyIsDown)cc
    rsp.T2{trial} = KbName(keyCode);
    %     end
    
    DrawFormattedText(w,['TRIAL ',num2str(trial+1), '/', num2str(tottrls)] , 'center','center',white);
    Screen('Flip',w);
    
    WaitSecs(2);% KbStrokeWait;
    save([mydir.beh, filesep, 'beh_attentionalblink.mat'], 'rsp', 'cond_list', 'pos', 'lags_rand');
end
sca
end