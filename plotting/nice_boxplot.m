function [] = nice_boxplot(data,xlab,xtick,xticklab,ylim,ylab,graphcol)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

boxhdl=boxplot(data,'color',[.5 .5 .5],'notch','off');
set(gca,'ylim',ylim,'fontsize',20,'linewidth',1.5)
set(gca,'xtick',xtick,'xticklabel',xticklab)
set(gca,'PlotBoxAspectRatio',[1 1 1],'Box','off')
%set(gca,'color','none','gridcolor','none')
ylabel(ylab,'fontsize',20)
xlabel(xlab,'fontsize',20)

for iobj=1:size(boxhdl,2)
    set(boxhdl(1,iobj),'LineWidth',1.5,'LineStyle','-','Color',graphcol(iobj,:)) % upper whisker
    set(boxhdl(2,iobj),'LineWidth',1.5,'LineStyle','-','Color',graphcol(iobj,:)) % lower whisker
    set(boxhdl(3,iobj),'LineWidth',1.5,'LineStyle','-','Color',graphcol(iobj,:)) % adj val
    set(boxhdl(4,iobj),'LineWidth',1.5,'LineStyle','-','Color',graphcol(iobj,:)) % adj val
    origwidth=get(boxhdl(5,iobj),'XData');   
    set(boxhdl(5,iobj),'LineWidth',1.5,'LineStyle','-','XData',origwidth+[.1 .1 -.1 -.1 .1]) % body
    origwidth=get(boxhdl(6,iobj),'XData');
    set(boxhdl(6,iobj),'LineWidth',2.5,'LineStyle','-','XData',origwidth+[-.1 .1],'Color',graphcol(iobj,:)) % median line
    set(boxhdl(7,iobj),'Marker','.','MarkerSize',12,'MarkerEdgeColor',[.5 .5 .5]) % outlier
end

end