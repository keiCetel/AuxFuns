function mmOctPlot(museData)
  hold on;
  #dateFormat = 'yyyy-mm-dd HH:MM:SS.FFF';
  #dateNums = datenum(museData{1,1},dateFormat);

  plot((museData{1,2}+museData{1,3}+museData{1,4}+museData{1,5})/4,'Color',[0.8,0,0]);#Delta
  plot((museData{1,6}+museData{1,7}+museData{1,8}+museData{1,9})/4,'Color',[0.6,0.2,0.8]);#Theta
  plot((museData{1,10}+museData{1,11}+museData{1,12}+museData{1,13})/4,'Color',[0,0.6,0.8]);#Alpha
  plot((museData{1,14}+museData{1,15}+museData{1,16}+museData{1,17})/4,'Color',[0.4,0.6,0]);#Beta
  plot((museData{1,18}+museData{1,19}+museData{1,20}+museData{1,21})/4,'Color',[1,0.54,0]);#Gamma

  title('Mind Monitor - Absolute Brain Waves');
  hold off;
endfunction