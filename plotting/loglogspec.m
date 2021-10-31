function hdl=loglogspec(data,freq,xbnd,ybnd,xlabeltxt,ylabeltxt,titletxt,colmap,plotavg)

figure

set(gca,'colororder',colmap,'nextplot','replacechildren')
plot(freq,data,'linewidth',1.5), hold on
if plotavg
plot(freq,nanmean(data,2.5),'k','linewidth',3)
end
hold off

set(gca,'xscale','log','yscale','lin','plotboxaspectratio',[1 2 1])
set(gca,'linewidth',1.5,'fontsize',16)
xlabel(xlabeltxt)
ylabel(ylabeltxt)
axis([xbnd,ybnd])
title(titletxt)

% return axes handle
hdl=gca;