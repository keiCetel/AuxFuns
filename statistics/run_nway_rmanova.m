function [anvtbl,stats,fdata]=run_nway_rmanova(data,factname,factlvl,runaov)
% repeated measures ANOVA
% input:
% data -        2D matrix
%               first dimension in data must be 'subjects'
%               2nd dim = (nested) conditions
% factname -    cell array with factor names, {'subj','condition1',...}
%               1st factor label is for the random factor, 'subj' (or similar)
% factlvl  -    vector with factor levels of conditions, e.g. [2 4 2 ...]
%               random factor is neglected, fixed factors only, i.e. conditions
% runaov -      Boolean flag (true/false), set to true to actually run ANOVA
%               Returns re-organised data (for e.g. use in R) only if false
         
% [1] make design matrix
% first column of design matrix is always subs (random factor)
nsub=size(data,1);
dsgn(:,1)=repmat(1:nsub,[1 size(data,2)]).';

if nargin<4, runaov=true; end

tablehd={'data',factname{:}};
switch numel(factlvl)
    case 1
        % if it's one-factorial, num cols = num factor levels
        dsgn(:,2)=sort(repmat(1:size(data,2),[1 nsub])).';
        fdata=table(data(:),dsgn(:,1),dsgn(:,2),'VariableNames',tablehd);
    case 2
        dsgn(:,2)=sort(repmat((1:factlvl(1))',[numel(data)/factlvl(1) 1]));
        dsgn(:,3)=repmat(sort(repmat((1:factlvl(2))',[numel(data)/prod(factlvl(1:2)) 1])),[factlvl(1) 1]);
        fdata=table(data(:),dsgn(:,1),dsgn(:,2),dsgn(:,3),'VariableNames',tablehd);
    case 3
        dsgn(:,2)=sort(repmat((1:factlvl(1))',[numel(data)/factlvl(1) 1]));
        dsgn(:,3)=repmat(sort(repmat((1:factlvl(2))',[numel(data)/prod(factlvl(1:2)) 1])),[factlvl(1) 1]);
        dsgn(:,4)=repmat(sort(repmat((1:factlvl(3))',[numel(data)/prod(factlvl) 1])),[prod(factlvl(1:2)) 1]);
        fdata=table(data(:),dsgn(:,1),dsgn(:,2),dsgn(:,3),dsgn(:,4),'VariableNames',tablehd);
    case 4
        dsgn(:,2)=sort(repmat((1:factlvl(1))',[numel(data)/factlvl(1) 1]));
        dsgn(:,3)=repmat(sort(repmat((1:factlvl(2))',[numel(data)/prod(factlvl(1:2)) 1])),[factlvl(1) 1]);
        dsgn(:,4)=repmat(sort(repmat((1:factlvl(3))',[numel(data)/prod(factlvl(1:3)) 1])),[prod(factlvl(1:2)) 1]);
        dsgn(:,5)=repmat(sort(repmat((1:factlvl(4))',[numel(data)/prod(factlvl) 1])),[prod(factlvl(1:3)) 1]);
        fdata=table(data(:),dsgn(:,1),dsgn(:,2),dsgn(:,3),dsgn(:,4),dsgn(:,5),'VariableNames',tablehd);
    otherwise
        warning('5- and more factorial designs not supported')
        return
end

% [2] run ANOVA
if runaov
%fdata=[];
[~,tbl,stats]=anovan(data(:),dsgn,'random',1,'varnames',factname,'model',numel(factlvl));

% add effect sizes (eta sq)
anvtbl=tbl(:,1:7);

anvtbl(:, 8)=cell(size(anvtbl,1),1);
anvtbl(:, 9)=cell(size(anvtbl,1),1);
anvtbl(:,10)=cell(size(anvtbl,1),1);
anvtbl(:,11)=cell(size(anvtbl,1),1);
inclidx=~[1;strncmp(anvtbl(2:end-2,1),factname(1),4);1;1];

% ssqtot=sum([anvtbl{inclidx,2}]);
% anvtbl(inclidx,8)=cellfun(@(x) x./ssqtot*100,anvtbl(inclidx,2),'UniformOutput',false);
ssqtot=anvtbl{strcmp(anvtbl(:,1),'Total'),2};
anvtbl(inclidx,8)=cellfun(@(x) x./ssqtot,anvtbl(inclidx,2),'UniformOutput',false);
anvtbl{1,8}='var expl% (eta-sq)';

%erridx=false(length(inclidx),1);
erridx=[];
effname=anvtbl(inclidx,1);
for ieff=1:numel(effname);
    erridx=[erridx;find(strcmp(anvtbl(:,1),['subj*' effname{ieff}]))];
end
erridx=[erridx;find(strcmp(anvtbl(:,1),'Error'))];

anvtbl(inclidx,9)=cellfun(@(x,y) x./(x+y),anvtbl(inclidx,2),anvtbl(erridx,2),'UniformOutput',false);
anvtbl{1,9}='var expl% (partial eta-sq)';

msqerr=anvtbl{strcmp(anvtbl(:,1),'Error'),5};
anvtbl(inclidx,10)=cellfun(@(x,y) (x-y*msqerr)./(ssqtot+msqerr),anvtbl(inclidx,2),anvtbl(inclidx,5),'UniformOutput',false);
anvtbl{1,10}='var expl% (omega-sq)';

anvtbl(inclidx,11)=cellfun(@(F,df) (F-1)./(F+(df*(nsub-1)+1)/df),anvtbl(inclidx,6),anvtbl(inclidx,3),'UniformOutput',false);
anvtbl{1,11}='var expl% (partial omega-sq)';

else
    anvtbl=[];
    stats=[];
end

return

%% correct p-values of non-spherical factors (main effects only for now)
% under development
nonsph=factlvl>2;
dsgn(:,1)=sort(repmat((1:factlvl(1))',[numel(data)/factlvl(1) 1]));
dsgn(:,2)=repmat(sort(repmat((1:factlvl(2))',[numel(data)/prod(factlvl(1:2)) 1])),[factlvl(1) 1]);
dsgn(:,3)=repmat(sort(repmat((1:factlvl(3))',[numel(data)/prod(factlvl) 1])),[prod(factlvl(1:2)) 1]);


