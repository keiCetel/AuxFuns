function hdl=loglogspec(data,freq,xbnd,ybnd,xlabeltxt,ylabeltxt,titletxt,colmap,plotavg)

figure

set(gca,'colororder',colmap,'nextplot','replacechildren')
plot(freq,data,'linewidth',2), hold on
if plotavg
plot(freq,nanmean(data,2),'k-.','linewidth',5)
end
hold off

set(gca,'xscale','log','yscale','log','plotboxaspectratio',[1 1 1])
set(gca,'linewidth',1.6,'fontsize',16)
xlabel(xlabeltxt)
ylabel(ylabeltxt)
axis([xbnd,ybnd])
title(titletxt)

% return axes handle
hdl=gca;