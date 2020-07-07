function sourcemodel=voxLabelByAtlas(sourcemodel,atlasdir,roi)

%%% identify voxel indices of certain regions by setting ROI
% ROI={'Calcarine_L';'Calcarine_R';'Cuneus_L';'Cuneus_R';'Lingual_L';
%      'Lingual_R';'Occipital_Sup_L';'Occipital_Sup_R';'Occipital_Mid_L';
%      'Occipital_Mid_R';'Occipital_Inf_L';'Occipital_Inf_R';'Fusiform_L';
%      'Fusiform_R'};

atlas=ft_read_atlas(atlasdir);

if nargin<3 | isempty(roi)
    roi=atlas.tissuelabel;
end

%sourcemodel=ft_convert_units(sourcemodel,'mm');
sourceatlas=ft_sourceinterpolate(struct('interpmethod','nearest','parameter','tissue'),atlas,sourcemodel);
sourceatlas.coordsys='mni';
%ft_sourceplot(struct('method','ortho','funparameter','tissue','atlas',atlasdir),sourceatlas)

[~,tissueidx]=ismember(roi,atlas.tissuelabel);
for iroi=1:numel(roi)
    voxbyroi(:,iroi)=sourceatlas.tissue(:)==tissueidx(iroi);
    
    % some regional geometry:
    voxpos=sourcemodel.pos(voxbyroi(:,iroi),:);
    if isempty(voxpos)
        centervox(iroi,:)=nan;
        regradius(iroi)=nan;
    else
        centervox(iroi,:)=mean(voxpos,1);
        ctr=bsxfun(@minus,voxpos,centervox(iroi,:));
        regradius(iroi)=max(sqrt(ctr(:,1).^2+ctr(:,2).^2+ctr(:,3).^2));
    end
end
fprintf('\nMedian local radius of atlas regions = %3.3f %s\n',nanmedian(regradius),sourcemodel.unit);

% spatial scale of the atlas, expressed as fwhm (see Brookes et al. 2016, NIMG):
% fwhmSpace = 2*sqrt(2*log(2))*nanstd(regradius)

sourcemodel.voxbyroi=voxbyroi;
sourcemodel.roisel  =roi;
sourcemodel.centervox=centervox;
sourcemodel.regradius=regradius;
