function [museData, museElements]=mmOctImport(fileName)
  %Mind Monitor Import by James Clutterbuck [https://Mind-Monitor.com]
  #Usage Example: [museData, museElements] = mmOctImport('mindMonitor_2020-04-17.csv');
  
  fid = fopen(fileName);
  lines = textscan(fid,'%s','HeaderLines',1,'Delimiter',"\n"){1};
  fclose(fid);
  clear fid;
  if (length(lines)>1000)
    disp('Processing, please wait...');
  endif

  #dataColNames = {'TimeStamp','Delta_TP9','Delta_AF7','Delta_AF8','Delta_TP10','Theta_TP9','Theta_AF7','Theta_AF8','Theta_TP10','Alpha_TP9','Alpha_AF7','Alpha_AF8','Alpha_TP10','Beta_TP9','Beta_AF7','Beta_AF8','Beta_TP10','Gamma_TP9','Gamma_AF7','Gamma_AF8','Gamma_TP10','RAW_TP9','RAW_AF7','RAW_AF8','RAW_TP10','AUX_RIGHT','Accelerometer_X','Accelerometer_Y','Accelerometer_Z','Gyro_X','Gyro_Y','Gyro_Z','HeadBandOn','HSI_TP9','HSI_AF7','HSI_AF8','HSI_TP10','Battery'};
  formatData = '%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %d %d %d %d %d %f';
  dataCommaCount = 37;
  #elementColNames = {'TimeStamp','Elements'};
  formatElements = '$s %s %s';
  dateFormat = 'yyyy-mm-dd HH:MM:SS.FFF';

  museData={};
  museElements={};
  mdIndex = 0;
  meIndex = 0;
  for x=1:length(lines)
    line = lines{x};
    commas = length(strfind(line,','));
    if (commas==dataCommaCount)
      lineStrDate = textscan(line,formatData,'Delimiter',',');
      lineDate = cellfun(@(date)datenum(datevec(date,dateFormat)),lineStrDate{1});
      mdIndex += 1;
      museData{mdIndex,1} = lineDate;
      for y=2:length(lineStrDate)
        museData{mdIndex,y} = lineStrDate{y};
      endfor
    else
      lineStrDate = textscan(line,formatElements,'Delimiter',',','MultipleDelimsAsOne',1);
      lineDate = cellfun(@(date)datenum(datevec(date,dateFormat)), lineStrDate{1});
      meIndex += 1;
      museElements{meIndex,1} = lineDate(1);
      museElements{meIndex,2} = lineStrDate{2}{1};
    endif
  endfor
  if (length(lines)>1000)
    disp('done');
  endif
endfunction