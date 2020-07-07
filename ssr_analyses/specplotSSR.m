function [specdat,hspec]=specplotSSR(fr,xparam,chansel,weights,avgover,plotorder,xyscaleplot,graphcol,legtxt,plotflag,snrflag)
% function specplotSSR(fr,xparam,chansel,weights,avgover,plotorder,xyscaleplot,graphcol,legtxt,plotflag)
% analyze and plot effect - SSRs
%

if nargin<10, plotflag=true; snrflag=false; end
if nargin<11, snrflag=false; end

switch xparam
    case {'powspctrm','evospctrm'}
        %ylabunit='Power [\muV^2]';
        %ylabunit='Power [(nV*m^-1)^2]';
        ylabunit='Power [dB]';
    case {'logpow'}
        ylabunit='Power [dB]';
    case 'plvspctrm'
        ylabunit='ITC [au]';
    case 'cohspctrm'
        ylabunit='|coh|^2 [au]';
    case 'logitc'
        ylabunit='log(ITC) [au]';
    case 'cosspctrm'
        ylabunit='cs index [au]';
    otherwise
        %ylabunit='N/A';
        ylabunit='xCoh [au]';
end

if snrflag, ylabunit='SNR'; end

if isempty(chansel), chansel=1:numel(fr{1,1}.label); end
if isempty(xyscaleplot), xyscaleplot=[fr{1,1}.freq([1 end]) min(min(fr{1,1}.(xparam))) max(max(fr{1,1}.(xparam)))]; end
if isempty(legtxt), legdon=false; else legdon=true; end    

xlabunit='Frequency [Hz]';
xtickpos=xyscaleplot(1):2:xyscaleplot(2);
xyratio=[3 1 1];

if isempty(weights), weights{1}=eye(size(fr,2)); end % show spectrum for each condition
if isempty(legtxt), legtxt=cell(1,size(fr,2)); end
if isempty(plotorder)
    if norm(weights{1})==1
        plotorder=1:size(fr,2);
    else
        plotorder=1:size(weights{1},1);
    end
end
if isempty(avgover), avgover='subjects'; end % trigger different behavior, can be 'cond...s' or 'sub...s'
if isempty(graphcol), graphcol=lines(size(fr,2)); end 

%%% SOME EXAMPLES
%%% avg spectra averaged over cond
% weights{1}=[1 1 1 1]/4;
% legtxt={'\itcollapsed'};
% plotorder=1;
% avgover='subjects'; % trigger different behavior, can be 'cond...s' or 'sub...s'
% graphcol=[0 0 0];

%%% avg spectra averaged over cond, but showing single sub spectra
%weights{1}=[1 1 1 1]/4;
%legtxt={'\itcollapsed'};
%plotorder=1;
%avgover='conditions'; % trigger different behavior, can be 'cond...s' or 'sub...s'

if strcmp(fr{1}.dimord,'subj_chan_freq')
    tmp=fr;
    for icond=1:size(fr,2) % allow channel selection
        tmp{icond}.(xparam)=tmp{icond}.(xparam)(:,chansel,:);
        tmp{icond}.label=tmp{icond}.label(chansel,1);
    end
elseif strcmp(fr{1}.dimord,'chan_freq')
    cfg=[];
    cfg.parameter=xparam;
    cfg.keepindividual='yes';
    cfg.channel=chansel;
    for icond=1:size(fr,2) % avg across subs per cond
        tmp{icond} =ft_freqgrandaverage(cfg,fr{:,icond});
        if isfield(tmp{icond},'labelcmb') % intercept standard ft behavior
            tmp{icond}=rmfield(tmp{icond},'labelcmb');
        end
    end
elseif strcmp(fr{1}.dimord,'rpttap_chan_freq')
    cfg=[];
    cfg.parameter=xparam;
    cfg.keepindividual='yes';
    cfg.channel=chansel;
    for icond=1:size(fr,2) % avg across subs per cond
        for isub=1:numel(fr(:,icond))
            fr{isub,icond}.(xparam)=squeeze(mean(fr{isub,icond}.(xparam)));
            fr{isub,icond}.dimord='chan_freq';
        end
        
        tmp{icond} =ft_freqgrandaverage(cfg,fr{:,icond});
        if isfield(tmp{icond},'labelcmb') % intercept standard ft behavior
            tmp{icond}=rmfield(tmp{icond},'labelcmb');
        end
    end
else
    error('Unsupported data format!')
end

specdat=zeros([size(tmp{1}.(xparam)) size(weights{1},1)]);
for iset=1:size(weights{1},1); % keep this for easy extension
    contrast{1}=tmp{1};
    contrast{2}=tmp{1};
    contrast{3}=tmp{1};
    contrast{1}.(xparam)=zeros(size(contrast{1}.(xparam)));
    contrast{2}.(xparam)=zeros(size(contrast{2}.(xparam)));
    
    for iwght=1:size(weights{1},2)
        contrast{1}.(xparam)=contrast{1}.(xparam)+tmp{iwght}.(xparam)*weights{1}(iset,iwght);
    end
%     % implements a second order weighting if need be
%     if numel(weights)>1
%     for iwght=1:size(weights{2},2)
%         contrast{2}.(xparam)=contrast{2}.(xparam)+tmp{iwght}.(xparam)*weights{2}(ifreq,iwght);
%     end
%     end
    contrast{3}.(xparam)=contrast{1}.(xparam)-contrast{2}.(xparam);
    specdat(:,:,:,iset)=contrast{3}.(xparam);
end

if snrflag
%%%% exp code: convert spectra to SNRs
snr = deal(zeros(size(specdat)));
skipbins = 3; % "signal" center bit
numbins  = skipbins+2; % "noise"

% loop over frequencies and compute SNR
for hzi=numbins+1:length(snr)-numbins-1    
    numer = specdat(:,:,hzi,:);
    denom = mean( specdat(:,:,[hzi-numbins:hzi-skipbins hzi+skipbins:hzi+numbins],:),3 );
    snr(:,:,hzi,:) = 10*log10(numer./denom);
end
%keyboard
%specdat=bsxfun(@minus,snr,mean(snr,3)); % subtract avg of spec
specdat=bsxfun(@minus,snr,mean(snr,3)); % subtract avg of spec
%%%%
end

if plotflag
specplot=[];
if strcmp(avgover,'subjects')
    graphcol=graphcol(plotorder,:);
    specplot=squeeze(mean(mean(specdat),2));
    specerr =squeeze(std(mean(specdat,2),0,1))./sqrt(size(specdat,1));
    specplot=specplot(:,plotorder);
    specerr=specerr(:,plotorder);
    legtxt=legtxt(plotorder);
    plotsem=true;
elseif strcmp(avgover,'conditions')
    spectmp=permute(squeeze(mean(mean(specdat,4),2)),[2 1]);
    specplot(:,1)=mean(spectmp,2); % avg across subs goes first (freq x sub)
    specplot(:,2:size(spectmp,2)+1)=spectmp; % single sub spectra
    specplot(:,size(spectmp,2)+2)=mean(spectmp,2); % avg across subs again
    clear spectmp
    orig_graphcol=graphcol;
    graphcol=cat(1,[0 0 0],.7*ones(size(specplot,2)-2,3),[0 0 0]);
    legtxt={'\itAverage','\itSubjects'};
    plotsem=false;
    warning('Plotting of shaded error bars disabled!')
    %error('Not yet implemented.')
end

hspec=figure('Color',[1 1 1]);
if plotsem
    lineProps.width=3;
    if ~iscell(graphcol)
        lineProps.col=mat2cell(graphcol,ones(1,size(graphcol,1)),3);
        %lineProps.style={'-';'--'};
    else
        lineProps.col=graphcol;
        
        %lineProps.style='--';
    end
    mseb_ak(contrast{3}.freq,specplot.',specerr.',lineProps,0);
%    plot(contrast{3}.freq,specplot,'linewidth',3)
else
    plot(contrast{3}.freq,specplot,'linewidth',1)
    spechandle=get(gca);
    %set(spechandle.Children(1),'Color',[0 0 0],'LineStyle','--')
    numspec=size(specplot,2);
    for ispec=1:size(specplot,2);
        set(spechandle.Children(ispec),'Color',graphcol(numspec,:));
        numspec=numspec-1;
        %set(spechandle.Children(ispec),'LineStyle','--');
        if ismember(ispec,[1 size(specplot)])
            %keyboard
            set(spechandle.Children(ispec),'Color',orig_graphcol(1,:));
            set(spechandle.Children(ispec),'LineWidth',2);
        end
    end
end
box off
set(gca,'xtick',xtickpos);
%set(gca,'xticklabel',{'6' '8' '10|L' '12|R' '14' '16' '18' '20'})
set(gca,'LineWidth',1.5)
set(gca,'PlotBoxAspectRatio',xyratio)
set(gca,'FontSize',18)
set(gca,'yaxislocation','left')
ylabel(ylabunit,'FontSize',18)
xlabel(xlabunit,'FontSize',18)
axis(xyscaleplot)

if legdon
legend(legtxt,'location','northeast')
legend boxoff
end
else
    hspec=[];
end % plotflag