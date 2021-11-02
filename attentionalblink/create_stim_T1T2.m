function [cond_list, pos]= create_stim_T1T2(ntrls, targnr, lag)

cond_cell = cell(1,ntrls);
list = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I' 'L' 'M' 'N' 'P' 'Q' 'R' 'S' 'T'};
% listsel= {'b', 'p', 'g', 'f', 's', 'q'}; %list without targets
cond_list={};
for j=1:ntrls
    cond_list{j}= list{randi(numel(list))};
end

%generate targets which have to be two random numbers
T1= mat2str(randi(9));
tmp = randi(9);
if T1==tmp % if i picked the same number as before or the same +1
    while T1==tmp
        tmp=randi(9);
    end
    
end
T2=mat2str(tmp);
clear tmp;
% %check that already not present a-x by random generation
% for j=1:n-1
%     if cond_list{j}=='a' && cond_list{j+1}=='x'
%         cond_list{j}=listsel{randi(numel(listsel))};
%     end
% end

restot= [1:lag, -(1:lag)];
maxpos = [ntrls - lag];
[pos]=deal([]);
for k=1:targnr
    
    tmp=randi(ntrls-1);
    fprintf(['SELECTED TMP POSITION ', num2str(tmp) '\n'])
    
    if k==1
        
        if tmp>maxpos % if i picked the same number as before or the same +1
            while tmp>maxpos
                tmp=randi(ntrls-1);
            end
            
        end
        
        
        
        pos(k)=tmp;
        fprintf(['SELECTED DEF POSITION ', num2str(pos) '\n'])
        cond_list{pos(k)}  = T1;
        cond_list{pos(k)+lag}= T2;
        
    else %trials followng the first
        
        %create all restrictions in relation to 'pos'
        notpos=[pos]; %initialize including all positions then add lags
        for j=1:numel(restot)
            notpos = [notpos, pos-restot(j)];
        end
        
        
        
        if ismember(tmp,notpos) || tmp>maxpos % if i picked the same number as before or the same +1
            while ismember(tmp,notpos) || tmp>maxpos
                tmp=randi(ntrls-1);
            end
            fprintf(['SELECTED DEF POSITION ', num2str(tmp) '\n'])
        end
        
        %if you exit the loop, because you picked a new number, then assign
        %it to pos
        pos(k)=tmp;
        cond_list{pos(k)}  = T1;
        cond_list{pos(k)+lag}= T2;
        
    end
end

end