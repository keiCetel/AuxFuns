%%%% ignore this bit if you are not CK
init_pupil_analyses
subjects=subject_database('pupil');
subjects=subjects(24);
blockidx=1;

fileprfx=[sourcedir subjects(1).code subjects(1).meg_runs{blockidx}];

%% eye data
cfg=[];
cfg.dataset=[fileprfx 'track.asc'];
cfg.derivative='no';
cfg.demean='yes';
cfg.detrend='yes';
cfg.channel=[2 3]; % extract horizontal & vertical gaze
eyetrk=ft_preprocessing(cfg);

%% meg eye data

cfg=[];
cfg.headerfile=[fileprfx 'c,rfDC'];
cfg.datafile=cfg.headerfile;
cfg.continuous='yes';
cfg.channel={'X*'}; % eye channels only
data=ft_preprocessing(cfg);

cfg=[];
cfg.resamplefs=eyetrk.fsample+.057; % use a simple correction factor because eyetracking sampling does not seem to be super accurate
cfg.demean='yes';
eyemeg=ft_resampledata(cfg,data); clear data

%% crosscorr to find lag

eyemegdat=zscore(permute(eyemeg.trial{1},[2 1]));
eyetrkdat=zscore(permute(eyetrk.trial{1},[2 1]));

% eyemegdat=medfilt1(eyemegdat,4,[],2);
% eyetrkdat=medfilt1(eyetrkdat,4,[],2);

figure
subplot(2,2,1)
plot(eyemegdat(:,1),'b','linewidth',2), hold on
plot(eyemegdat(:,2),'r','linewidth',2), 
plot(-eyetrkdat(:,1)-1,'m','linewidth',2), 
plot(-eyetrkdat(:,2)-1,'c','linewidth',2), hold off
ylabel('zscore','fontsize',16)
legend({'eyemeg - X1','eyemeg - X2','eyetrk - HORZ','eyetrk VERT'})
legend('location','southeast')
title('time axis not aligned')

[siglag(:,1),~   ]=xcorr(eyetrkdat(:,1),eyemegdat(:,1));
[siglag(:,2),lags]=xcorr(eyetrkdat(:,2),eyemegdat(:,2));
subplot(2,2,2)
plot(prod(siglag,2),'k','linewidth',2)
ylabel('cross corr','fontsize',16)
legend({'~prod(xcorr)'},'location','southeast')
title('cross correlation')
cumlag=prod(siglag,2);
[val,idx]=max(cumlag(~isnan(cumlag)));

fprintf('\nlag = %d points\n',lags(idx));

subplot(2,2,[3 4])
plot([zeros(lags(idx),1);eyemegdat(:,1)],'linewidth',2), hold on
plot(eyetrkdat(:,1)-10,'k','linewidth',2), hold off
set(gca,'ytick',[-10 0],'yticklabel',{'trk','meg'})
legend({'eyemeg','eyetrk'})
legend('location','southeast')
title('time axes aligned using xcorr peak time')

% cfg=[];
% cfg.toilim=[eyetrk.time{1}(lags(idx)-40) eyetrk.time{1}(lags(idx)-51)+425];
% neyetrk=ft_redefinetrial(cfg,eyetrk)
% 
% cmb=ft_appenddata([],eyemeg,neyetrk);

% cfg=[];
% cfg.channel={'X1','X2','4'};
% cfg.chanscale=[1;1;.01];
% ft_databrowser(cfg,cmb);