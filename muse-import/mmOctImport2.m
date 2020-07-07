function [museData, museElements]=mmOctImport2(fileName)
  %Mind Monitor Import by James Clutterbuck [https://Mind-Monitor.com]
  #Usage Example: [museData, museElements] = mmOctImport2('mindMonitor_2020-04-17.csv');
  
  tempDataFilename = 'temp_museData.csv';
  tempElementsFilename = 'temp_museElements.csv';
  
  fIn = fopen(fileName,'r');
  fOutMD = fopen(tempDataFilename,'w+');
  fOutME = fopen(tempElementsFilename,'w+');
  
  dataCommaCount = 37;
  
  line = fgetl(fIn);#discard header
  fprintf(fOutMD,line);
  fprintf(fOutME,line);
  
  while(!feof(fIn))
    line = fgetl(fIn);
    commas = length(strfind(line,','));
    if (commas==dataCommaCount)
      fprintf(fOutMD,'\n%s,',line);
    else
      fprintf(fOutME,'\n%s',line);
    endif
  endwhile
  
  fclose(fIn);
  fclose(fOutMD);
  fclose(fOutME);  
  
  clear fIn;
  clear fOutMD;
  clear fOutME;
  
  #Read clean input files
  
  formatData = '%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %d %d %d %d %d %f';
  fIn = fopen(tempDataFilename,'r');
  museData = textscan(fIn,formatData,'HeaderLines',1,'Delimiter',',');
  fclose(fIn);
  clear fIn;
  
  #formatElements = '%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %d %d %d %d %d %f %s';
  formatElements = '%s %s';
  fIn = fopen(tempElementsFilename,'r');
  museElements = textscan(fIn,formatElements,'HeaderLines',1,'Delimiter',',','MultipleDelimsAsOne',1);
  fclose(fIn);
  clear fIn;
  
  delete(tempElementsFilename);
  delete(tempDataFilename);
  mmOctPlot(museData);
endfunction