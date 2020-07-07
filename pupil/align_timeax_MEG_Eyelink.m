function offset=align_timeax_MEG_Eyelink(eyetrk,eyemeg,plotFlag)

% cfg=[];
% % use a simple correction factor because eyetracking sampling does not seem to be super accurate
% cfg.resamplefs=eyetrk.fsample+.057;
% cfg.demean='yes';
% eyemeg=ft_resampledata(cfg,data); clear data

%% crosscorr to find lag

eyemegdat=zscore(permute(eyemeg.trial{1},[2 1]));
eyetrkdat=zscore(permute(eyetrk.trial{1},[2 1]));

% eyemegdat=medfilt1(eyemegdat,4,[],2);
% eyetrkdat=medfilt1(eyetrkdat,4,[],2);

[siglag(:,1),~   ]=xcorr(eyetrkdat(:,1),eyemegdat(:,1));
[siglag(:,2),lags]=xcorr(eyetrkdat(:,2),eyemegdat(:,2));
cumlag=prod(siglag,2);
[val,lag]=max(cumlag(~isnan(cumlag)));

offset=lags(lag);

if plotFlag
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

subplot(2,2,2)
plot(prod(siglag,2),'k','linewidth',2)
ylabel('cross corr','fontsize',16)
legend({'~prod(xcorr)'},'location','southeast')
title('cross correlation')

fprintf('\nlag = %d points\n',offset);

subplot(2,2,[3 4])
plot([zeros(offset,1);eyemegdat(:,1)],'linewidth',2), hold on
plot(eyetrkdat(:,1)-10,'k','linewidth',2), hold off
set(gca,'ytick',[-10 0],'yticklabel',{'trk','meg'})
legend({'eyemeg','eyetrk'})
legend('location','southeast')
title('time axes aligned using xcorr peak time')
end
