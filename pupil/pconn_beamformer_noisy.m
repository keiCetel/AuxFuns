function [filt,pproj,nproj] = pconn_beamformer_noisy(dat,lf,para)

% Compute a joint filter for all conditions

% input:
% dat:    complex cross spectrum
% lf:     leadfield
% reg:    regularization parameter (default is set below)

if para.iscs
  Cf_real = real(dat);
else
 % dat is complex freq-specific data [chan x samples]
  Cf_real = real(dat*dat'/size(dat,2));
end
% regularization parameter
lambda = para.reg*sum(diag(Cf_real))/(size(Cf_real,1));

% estimate noise a la FT
% noise level in cov mat through smallest (non-zero) eig val
noise=svd(Cf_real);
noise=noise(rank(Cf_real));
% estim noise floor no less than lambda
noise=max(noise,lambda);

invCf_real = pinv(Cf_real + lambda * eye(size(Cf_real)));

clear filt

n_voxel = size(lf,2);

for ilf=1:n_voxel 
  
%   disp(sprintf('Computing filter at location %d ...',ilf));
  
  filter = jh_pinv(squeeze(lf(:,ilf,:))' * invCf_real * squeeze(lf(:,ilf,:))) * squeeze(lf(:,ilf,:))' * invCf_real; % lf cell with leadfield, lf{i} : [chan x 3]

  cf = filter*Cf_real*filter';
  
  [u,s,~] = svd(cf);
  
  % extract power
  pproj(ilf,1)=s(1,1);
  
  % projection to principal direction
  filt(ilf,:) = u(:,1)'*filter; 
  
  % NAI(ilf) = trace((squeeze(lf(:,ilf,:))'*invCf_real* squeeze(lf(:,ilf,:))).^(-1)) / trace(squeeze(lf(:,ilf,:))'*para.noisecov*squeeze(lf(:,ilf,:)));
  
  % project noise
  [~,s,~] = svd(filter*ctranspose(filter));
  nproj(ilf,1)=noise * s(1,1);
  
end

filt = filt';
