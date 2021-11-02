function posnergabor_fmri(subID)

projFolder     = pwd; % needs to be dir where prep_NFB is run from.. if run as intended this should not be a problem.
if ~exist([projFolder,filesep,'sub_',num2str(subID), filesep], 'dir')
    mkdir([projFolder,filesep,'sub_',num2str(subID),  filesep, 'beh']);
    mkdir([projFolder,filesep,'sub_',num2str(subID),  filesep, 'gabors'])
else
    msg='Subject number already exists. Check to not overwrite results file!';
    error(msg)
end

rootPathData = [projFolder,filesep,'sub_',num2str(subID), filesep, 'beh'];
Gabordir     = [projFolder,filesep,'sub_',num2str(subID), filesep, 'gabors'];

info.age  = input('subject age  ', 's');
info.hand = input('handedness [r/l]  ', 's');
info.sex  = input('gender [f/m]  ', 's');


% Do not keep this in experiment - preference one
Screen('Preference','SkipSyncTests',1);
Screen('Preference','VisualDebugLevel',0);
Screen('Preference','Verbosity',0);
getScreens=Screen('Screens');
chosenScreen=max(getScreens);

% Luminance values
white = WhiteIndex(chosenScreen); %255
black = BlackIndex(chosenScreen);%0
grey  = 128.5;white/2; % 127
red   = [255 0 0];
green = [0 255 0]

% Open window
[w,scr_rect]=PsychImaging('OpenWindow',chosenScreen,grey, []); % [50 50 900 700]If you put it like this
% [0 0 900 675] it makes the screen smaller

% Number of pixels in screen size
[screenXpixels, screenYpixels]=Screen('WindowSize',w);

% Center of the screen
[centerX, centerY]=RectCenter(scr_rect);
ifi=Screen('GetFlipInterval',w);
hertz=FrameRate(w);

topPriorityLevel = MaxPriority(w);
Priority(topPriorityLevel);

%% timings
% numtrls=150;   160; %=total of trials, half left half right gabors
% inval    = (.2*numtrls/2); val=(.8*numtrls/2);
inval =4;%30;
val = 10;%132;
numtrls = inval+val;
cond_tmp = [repmat(1,1,inval/2), repmat(2,1,inval/2), repmat(3,1,val/2), repmat(4,1,val/2)]; %1=cue left inv, 2=cue right inv, 3=cue left val, 4=cue right val
conds    = cond_tmp(randperm(numtrls));


fixation_time= .8;
a=1; b=1.2;
prep_interval= a + (b-a)*rand(1,numtrls);
stimtime     = .2;
responsetime = 1;
fbtime       = .3;

%      1= cue left inval,
%      2= cue right inval,
%      3= cue left val,
%      4= cue right val,


%% *************************    Settings for stimuli creation (gabors)  *************************************
% calculate already arrow rotations and correct responses
a1=10; b1=80; % range for right gabors
a2=280; b2=350; %range for left gabors

degrees_right = a1 + (b1-a1)*rand(1,numtrls/2); %create numtrsl/2 number of degrees from a1 to b1
degrees_left=a2 + (b2-a2)*rand(1,numtrls/2);

degrees_all = [degrees_left, degrees_right];
gabors2show = degrees_all(randperm(numtrls));

%% GABOR SETTINGS
% general settings valid for all gabors
imsize = 400;        %image size
lamda  = 40;          %wavelength in pixels
sigma  = 40;          %gaussian standard deviation in pixels
phase  = 0;           %phase 0:1
Gtheta = 0;          %global orientation in degrees (clockwise from vertical)
fdist  = 0;           %distance between target and flankes in pixels
xoff   = 0;            %horizontal offset position of gabor in pixels
yoff   = 0;            %vertical offset position of gabor in pixels
cutoff = 0;		     %if positive, applies threshold of gauss>cutoff to produce sharp edges and no smooth fading
show   = 1;            %if present, display result

% create a loop  for j = number of trials, which creates j number of gabor
% images corresponding to the degrees randomized created at the beginning
[gabors_target, gabors_target_names]=deal({});
for j=1:numel(gabors2show)
    orientation=gabors2show(j);
    
    [gabors_target{j}, gabors_target_names{j}]=create_gaborim(imsize, lamda, sigma, phase, orientation, Gtheta, fdist, xoff, yoff, cutoff, show, Gabordir);
    
end

[ gabortexturestimset1]={};
for g=1:numtrls
    % Every image has to be one texture
    gabor_targets=imread([Gabordir,filesep,gabors_target_names{1,g}]);
    gabortexturestimset1{g}=Screen('MakeTexture',w,gabor_targets);
end

[ gabortexturestimset2]={};
idx_dist = randperm(numtrls);
for g=1:numtrls
    % Every image has to be one texture
    gabor_targets=imread([Gabordir,filesep,gabors_target_names{1,idx_dist(g)}]);
    gabortexturestimset2{g}=Screen('MakeTexture',w,gabor_targets);
end


% Two textures at the same time in the screen
fignum=2;
yPos=centerY;
xPos=linspace(screenXpixels*0.2,screenXpixels*0.8,fignum);

% read in dimensions of the image
[s1, s2, s3]= size(gabors_target{1});
aspectratio=s2/s1;
heightscale=0.5;
gaborfixedHeight=screenYpixels.*heightscale;
gaborfixedWidth=gaborfixedHeight.*aspectratio;

% Put them inside a rectangle
dstRects=nan(4,fignum);
% Dimensions of the rectangle
for i=1:fignum
    Rect=[0 0 gaborfixedWidth gaborfixedHeight];
    dstRects(:,i)= CenterRectOnPointd(Rect,xPos(i),yPos);
end


Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
%%
KbName('UnifyKeyNames');
respleftKey   = '1!';
resprightKey  = '4$';%32222222222222222222222222'2@';

respRightCode = KbName(resprightKey);
respLeftCode  = KbName(respleftKey);
% activeKeys    = [KbName('LeftArrow') KbName('RightArrow')];

%%

% create matrix of correct ans
tmp=[repmat(0.1, 1,numtrls/2),repmat(1, 1,numtrls/2)];
contr_type = Shuffle(tmp);
[respvec, rsp]=deal({});

for j=1:numtrls
    switch contr_type(j)
        case 0.1
            respvec{j}=resprightKey; %decrease contrast, press 2
        case 1
            respvec{j}=respleftKey; %increase contrast, press 1
    end
    
end

%% ***************** Calibration on alpha
alpha         = 0.5;% initial alpha,  arrows contrast - changes every trial based on performance

%% *********************   Posner interleaved
Screen('TextSize',w,50);
Screen('TextFont',w,'Arial');
% Screen('TextStyle',w,1);
%% ************************** MRI SETTINGS **************************
%% wait for MRI trigger
SendTriggers=0;
usingMRI = 0;

if usingMRI
    wait4me = 0;
    while wait4me == 0
        [keyIsDown, secs, keyCode]=KbCheck;
        rspo=KbName(keyCode);
        if ~(isempty(rspo))
            if rspo=='5%'
                wait4me=1;
                startIRM=GetSecs;
            end
        end
    end
else
    startIRM=GetSecs;
end

% port

if SendTriggers
    parportAddr = hex2dec('EFD8');
    config_io;
    % Set condition code to zero:
    outp( parportAddr, 0);
    % Set automatic BIOPAC and eye tracker recording to "stop":
    outp( parportAddr+2, bitset(inp( parportAddr+2), 3, 0));
end

SendTriggers=0;

[duration_mat, ons] = deal(cell(numel(unique(conds)),1));%deal(zeros(numel(unique(conds)),simulated_data/2));

startexp = GetSecs;
%% Animation loop
for trial=1:numtrls
    
    %If this is the first trial we present a start screen and wait for a
    % key-press
    if trial==1
        DrawFormattedText(w,'Keep fixating in the middle of the screen\nonce the cue appear, prepare to respond to the indicated side\npress right or left button to indicate if the target stimulus increased\nor decreased in contrast.\nif the uncued stimulus changes contrast,\ndo not respond',...
            'center','center',white);
        Screen('Flip',w);
        %         KbPressWait([],[]);
        WaitSecs(5)
    end
    
    if trial==numtrls/2
        DrawFormattedText(w,'You are doing great, we are halfway!\n Press right or left button when ready to continue',...
            'center','center',white);
        Screen('Flip',w);
        KbPressWait([],[]);
        WaitSecs(1.5)
    end
    DrawFormattedText(w,'+',...
        'center','center',white);
    Screen('Flip',w);
    WaitSecs(fixation_time);
    
    %1=cue left inval, 2=cue right inval, 3=cue left val, 4=cue right val
    switch conds(trial)
        case num2cell([1,3])
            cue = '<+<';
        case num2cell([2,4])
            cue = '>+>';
    end
    
    DrawFormattedText(w,cue,'center','center',white);
    Screen('DrawTextures',w,gabortexturestimset1{trial}, [], dstRects(:,1), [], [],alpha);
    Screen('DrawTextures',w,gabortexturestimset2{trial}, [], dstRects(:,2), [], [],alpha);
    cue_flip=Screen('Flip',w);
    %biopac trigger
    if SendTriggers
        outp(parportAddr,conds(trial)); %index trigger value according to array from cond value in given trial
        wait(50);
        outp(parportAddr,0);
    end
    WaitSecs(prep_interval(trial));
    
    %    RestrictKeysForKbCheck(activeKeys);
    %% CONTRAST CHANGE repeat until a valid key is pressed or elapsed presentation time
    timedout=false;
    tStart = GetSecs; %this is the t start for RT!
    while (GetSecs-tStart)<stimtime %&& ~timedout % up to stim time, present the stimuli AND also check for keyboard press, breaking if key is pressed
        %present stimuli
        switch conds(trial)
            case num2cell([1,4]) %target is right dist left
                Screen('DrawTextures',w,gabortexturestimset1{trial}, [], dstRects(:,1), [], [],alpha);
                Screen('DrawTextures',w,gabortexturestimset2{trial}, [], dstRects(:,2), [], [], contr_type(trial));
                Screen('Flip',w);
                if SendTriggers
                    outp(parportAddr,9); %trigger for onset stim
                    wait(50);
                    outp(parportAddr,0);
                end
                
            case num2cell([2,3]) %target is left  distractor right
                Screen('DrawTextures',w,gabortexturestimset1{trial}, [], dstRects(:,1), [], [],contr_type(trial));
                Screen('DrawTextures',w,gabortexturestimset2{trial}, [], dstRects(:,2), [], [], alpha);
                Screen('Flip',w);
                if SendTriggers
                    outp(parportAddr,9); %trigger for onset stim
                    wait(50);
                    outp(parportAddr,0);
                end
                
        end
        fprintf(['\n\n TARGET HAS CONTRAST' num2str(contr_type(trial)) '\n\n'])
        %check for keyboard press during stimuli presentation already
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        
        if(keyIsDown)
            if SendTriggers
                outp(parportAddr,10); %trigger for response
                wait(50);
                outp(parportAddr,0);
            end
            break;
        end
    end
    
    %if keyboard not pressed during stim pres time, then flip a fixation cross
    %for the response interval duration while checking for keyboard press (and
    %breaking if key is pressed)
    if ~keyIsDown
        tStart2 = GetSecs;
        while ~timedout
            DrawFormattedText(w,'+','center','center',white);
            Screen('Flip',w);
            
            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
            
            if(keyIsDown)
                if SendTriggers
                    outp(parportAddr,10); %trigger for response
                    wait(20);
                    outp(parportAddr,0);
                end
                break;
                
            end
            
            if( (secs - tStart2) > responsetime)
                timedout = true;
                if SendTriggers
                    outp(parportAddr,11); %trigger for no response
                    wait(20);
                    outp(parportAddr,0);
                end
            end
        end
    end
    
    %save response data in matrix (if response given)
    
    if ~timedout % if key pressed
        switch conds(trial)
            case num2cell([3,4])  % valid trials, when key has to be pressed
                
                rsp.RT(trial)      = secs - tStart;
                rsp.keyName{trial} = KbName(keyCode);
                fprintf('\n RESPONSE GIVEN \n')
                
                if strcmp( rsp.keyName{trial},respvec{trial})==1
                    %             Corr_sound(1, stimuli, 1)
                    fprintf('\n correct \n')
                    rsp.iscorrect(trial)=1;
                    DrawFormattedText(w,'+','center','center',green);
                    Screen('Flip',w); WaitSecs(fbtime);
                    %             Corr_incorr_sound(1, root,[], 1)
                elseif  strcmp( rsp.keyName{trial},respvec{trial})==0
                    %             Corr_incorr_sound(1, root,[], 0)
                    fprintf('\n incorrect \n')
                    rsp.iscorrect(trial)=-1;
                    DrawFormattedText(w,'+','center','center',red);
                    Screen('Flip',w); WaitSecs(fbtime);
                end
                
            case num2cell([1,2])
                fprintf('\n incorrect \n')
                rsp.iscorrect(trial)=-1;
                DrawFormattedText(w,'+','center','center',red);
                Screen('Flip',w); WaitSecs(fbtime);
        end
    else %if no response given
        
        fprintf('\n no resp \n');
        rsp.iscorrect(trial)=0  ;
        %         Corr_incorr_sound(1, root,[], 0)
        DrawFormattedText(w,'+','center','center',red);
        Screen('Flip',w); WaitSecs(fbtime);
    end
    
    fprintf(['\nALPHA IS ', num2str(alpha), '\n']);
    
    
    %% save response variables from this subtask in subflder
    data = {};
    data.rsp        = rsp;
    data.conditions = conds;
    data.respvec    = respvec;
    data.prep_interval = prep_interval;
    ons{conds(trial)}(end+1)=cue_flip-startIRM;
    duration_mat{conds(trial)}(end+1)= num2cell(prep_interval(trial));
    
    data.ons      = ons;
    data.durations= duration_mat;
    data.info = info;
    % define current date to add to the name path
    % currentDate = datestr(now,'ddmmyy_HH:MM');
    save([rootPathData, filesep, 'beh_posner.mat'], 'data' );
    
    
    
    
end






% Clear the screen

exptime = GetSecs - startexp; % GetSecs - startIRM
fprintf(['\nExperiment duration total ', num2str(exptime) , '\n' ]);



% Closing screens
sca;

end
