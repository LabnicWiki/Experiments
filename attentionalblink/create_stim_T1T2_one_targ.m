function [cond_list, pos]= create_stim_T1T2_one_targ(nstream, lag)

cond_cell = cell(1,nstream);
list = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I' 'L' 'M' 'N' 'P' 'Q' 'R' 'S' 'T'};
% listsel= {'b', 'p', 'g', 'f', 's', 'q'}; %list without targets
cond_list={};
for j=1:nstream
    cond_list{j}= list{randi(numel(list))};
end

%generate targets which have to be two random numbers
T1=(randi(9))

tmpt2 = randi(9);
if T1==tmpt2 % if i picked the same number as before or the same +1
    while T1==tmpt2
        tmpt2=randi(9);
    end

end
T2=mat2str(tmpt2)
T1= mat2str(T1)

maxpos = [nstream - lag];
tmppos=randi(maxpos);
%         
%         if tmp>maxpos % if i picked the same number as before or the same +1
%             while tmp>maxpos
%                 tmp=randi(nstream-1);
%             end
%             
%         end
%         
            
        pos=tmppos;
        cond_list{pos}  = T1;
        cond_list{pos+lag}= T2;
        
 

end