function topomap=topoplotSSR(fr,xparam,freqoi,weights,addopt,drawtopo)
% analyze and plot effect - SSRs
% topoplotSSR(fr,xparam,freqoi,weights)
% load([targetdir 'sensfft_' nametrnk '.mat'],'fr')
% xparam='powspctrm';
%freqoi=[pi 4/3*(exp(1)) 2*pi 8/3*(exp(1)) 85/5 85/6];

%%% average topos
%weights{1}=ones(numel(freqoi),size(fr,2))*(1/size(fr,2));

%%% synchrony effect - contrast
%weights{1}=[1 -1 0];

if nargin<6, drawtopo=1; end

if strcmp(fr{1}.dimord,'subj_chan_freq')
    tmp=fr;
elseif strcmp(fr{1}.dimord,'chan_freq')
    
cfg=[];
cfg.parameter=xparam;
cfg.keepindividual='yes';
for icond=1:size(fr,2) % avg across subs per cond
    tmp{icond} =ft_freqgrandaverage(cfg,fr{:,icond});
    if isfield(tmp{icond},'labelcmb') % intercept standard ft behavior
        tmp{icond}=rmfield(tmp{icond},'labelcmb');
    end
%     if numel(tmp{icond}.freq==1)
%         tmp{icond}.freq=tmp{icond}.freq+[-1 0 1];
%         tmp{icond}.(xparam)=tmp{icond}.(xparam)(:,:,[1 1 1]);
%     end
end
else
    error('Unsupported data format!')
end

hghl=false;
mark=false;
zlimset=false;
plotsubset=false;
setcmap=false;
masktopo=false;
plotcolbar=false;

if ischar(addopt)
    cfg=[];
    cfg.layout=addopt;
    %cfg.layout='BioSemi64_1020_occipital.sfp';
    lay=ft_prepare_layout(cfg,tmp{1});
elseif isstruct(addopt)
    cfg=[];
    cfg.layout=addopt.layout;
    %cfg.layout='BioSemi64_1020_occipital.sfp';
    lay=ft_prepare_layout(cfg,tmp{1});
    if isfield(addopt,'colormap'), setcmap=true; end
    if isfield(addopt,'hghlchan'), hghl=true; end
    if isfield(addopt,'marker'), mark=true; end
    if isfield(addopt,'zlim'), zlimset=true; custom_zlim=addopt.zlim; end
    if isfield(addopt,'chansubset'), plotsubset=true; chansubset=addopt.chansubset; end
    if isfield(addopt,'maskpar'), masktopo=true; maskpar=addopt.maskpar; end
    if isfield(addopt,'plotcolbar'), plotcolbar=addopt.plotcolbar; end
end

% figure
% for isub=1:12
%     subplot(3,4,isub)
%     imagesc(tmp{1}.freq(100:1200),56:60,squeeze(tmp{1}.(xparam)(isub,56:60,100:1200)));
% end

if drawtopo
    figure
    subdim=[round(sqrt(size(freqoi,1))),ceil(sqrt(size(freqoi,1)))];
    subHandles=tight_subplot(subdim(1),subdim(2));
end

for ifreq=1:size(freqoi,1)
    contrast{1}=tmp{1};
    contrast{2}=tmp{1};
    contrast{3}=tmp{1};
    contrast{1}.(xparam)=zeros(size(contrast{1}.(xparam)));
    contrast{2}.(xparam)=zeros(size(contrast{2}.(xparam)));
    
    for iwght=1:size(weights{1},2)
        contrast{1}.(xparam)=contrast{1}.(xparam)+tmp{iwght}.(xparam)*weights{1}(ifreq,iwght);
    end
    % implements a second order weighting if need be
    if numel(weights)>1
    for iwght=1:size(weights{2},2)
        contrast{2}.(xparam)=contrast{2}.(xparam)+tmp{iwght}.(xparam)*weights{2}(ifreq,iwght);
    end
    end
    contrast{3}.(xparam)=contrast{1}.(xparam)-contrast{2}.(xparam);
    
    if drawtopo
    %load fitting colormap
    
    cfg=[];
    cfg.layout=lay;
    cfg.parameter=xparam;
    %cfg.zlim=[-0.3 0.3];
    if plotsubset, cfg.channel=chansubset; end    
    if zlimset, cfg.zlim=custom_zlim; end
    cfg.gridscale=256;
    
    %cfg.style='straight';
    cfg.style='fill';
    cfg.contournum=16;
    if setcmap, cfg.colormap=addopt.colormap; end
    cfg.interactive='no';
    cfg.renderer='zbuffer';
    %if ifreq==7
    if mark, cfg.marker=addopt.marker;
        if strcmp(addopt.marker,'numbers') || strcmp(addopt.marker,'label')
        else
             cfg.markersymbol=addopt.markersymb;
             cfg.markersize  =addopt.markersize;
        end
    else cfg.marker='off';
    end
    if hghl
        cfg.highlight='on';
        cfg.highlightchannel=addopt.hghlchan;
        cfg.highlightsymbol =addopt.hghlsymb;
        cfg.highlightcolor  =addopt.hghlcolr;
        cfg.highlightsize   =addopt.hghlsize;
    end
    cfg.comment='no';

    cfg.xlim=freqoi(ifreq,:);
%    subplot(round(sqrt(size(freqoi,1))),ceil(sqrt(size(freqoi,1))),ifreq)
    axes(subHandles(ifreq))
    if masktopo,
        cfg.maskparameter=maskpar;
    end
    
    topoplot_common_CK(cfg,contrast{3});
    
    if plotcolbar
    hcbar=colorbar;
    set(hcbar,'Location','SouthOutside')
    set(hcbar,'fontsize',24)
    xbounds=get(hcbar,'XLim');
    set(hcbar,'XTick',[xbounds(1),xbounds(2)]);
    for ilab=1:2, xtl{ilab}=sprintf('%2.2f',xbounds(ilab)); end
      set(hcbar,'XTickLabel',xtl)
%     xbounds=[xbounds(1),log(1/3),log(3),xbounds(2)];
%     set(hcbar,'XTick',xbounds);
%     for ilab=1:4, xtl{ilab}=sprintf('%2.2f',xbounds(ilab)); end
%     set(hcbar,'XTickLabel',xtl)
    end
    end
    
    tmpmap=contrast{3};
%     %tmp.dimord='chan_freq';
%     freqidx=nearest(tmpmap.freq,freqoi(ifreq,:));
%     if numel(freqidx)==2 && diff(freqidx)==0
%         if size(contrast{3}.(xparam),3)==2
%             freqidx=[1 2];
%         else
%             freqidx=freqidx(1)+[-1 0 1];
%             freqidx(freqidx<1)=[];
%         end
%     end
%     %tmp.(xparam)=squeeze(mean(contrast{3}.(xparam)(:,:,freqidx)));
%     tmpmap.(xparam)=contrast{3}.(xparam)(:,:,freqidx(1):freqidx(end));
%     tmpmap.freq=tmpmap.freq(freqidx(1):freqidx(end));
    topomap{ifreq}=tmpmap; clear tmpmap
end
