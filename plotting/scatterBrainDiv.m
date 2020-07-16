function handleBrain=scatterBrainDiv(data,sourcemodel,colmap,plotOpt)
% input:    data = [voxel x 1] vector with the data to plot
%           sourcemodel = fieldtrip sourcemodel struct (standard)
%           colmap = [n x 3] color map (e.g. colmap = hot(128))
%           plotOpt = struct, change marker size, filling in, see below
% 
% TO DO: include plotting of uniform regions

if nargin<4
   plotOpt.siz=30;
   plotOpt.fil='filled';
   plotOpt.scale=[0,1];
   plotOpt.type='seq';
end

% for consistency always make column vec
data=data(:);

% % adjust colmap 2 scale
% colbnd=round(plotOpt.scale.*size(colmap,1));
% if colbnd(1)<1, colbnd(1)=1; end
% 
% limscale=colbnd(1):colbnd(2);
% resscale=colmap(round( (limscale-min(limscale))./range(limscale)*(size(colmap,1)-1)+1),:);
% resscale([1,end],:)=[]; % delete maxima
% limmap  =[ones(colbnd(1),1)*colmap(1,:);
%          resscale;
%          ones(size(colmap,1)-(colbnd(2)-1),1)*colmap(end,:)];

if strcmp(plotOpt.type,'seq')
    % discretize data - this maps the entire color space
    normdat=(data-min(data))./range(data); % data 2 be plotted
    %colvec=limmap(ceil((size(colmap,1)-1).*normdat)+1,:);
    colvec=colmap(ceil((size(colmap,1)-1).*normdat)+1,:);
else strcmp(plotOpt.type,'div')
    % centre colormap on zero
    [absmax,idx]=max(abs([min(data),max(data)]));
    colrange=linspace(-absmax,absmax,(size(colmap,1)-1));
    colvec=colmap(dsearchn(colrange.',data),:);
end


if isfield(sourcemodel,'roisel') && size(data,1)==numel(sourcemodel.roisel)
handleBrain=scatter3(sourcemodel.centervox(:,1),...
                     sourcemodel.centervox(:,2),...
                     sourcemodel.centervox(:,3),...
                     plotOpt.siz,colvec,plotOpt.fil);
else
handleBrain=scatter3(sourcemodel.pos(sourcemodel.inside,1),...
                     sourcemodel.pos(sourcemodel.inside,2),...
                     sourcemodel.pos(sourcemodel.inside,3),...
                     plotOpt.siz,colvec,plotOpt.fil);
end
colormap(colmap)
axis equal, axis vis3d
axis([xlim,ylim,zlim,plotOpt.scale])
end
