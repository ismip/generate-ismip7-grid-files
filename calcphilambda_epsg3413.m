% Calculate phi, lambda and k
% for north polar aspect of stereographic projection
% Following Snyder p. 162
% Heiko Goelzer, February 2022 (heig@norceresearch.no)

%% Resolution in km

%res=5;
res=1;

%%%%%% Projection settings %% This is EPSG 3413 ISMIP Greenland grid

lat_c = 70;
lon_c = 315;
dx = -720000;
dy = -3450000;

a = 6378137;
f = 1/298.257223563;
esp = sqrt(2*f-f^2);

nx1=1681;
ny1=2881;
nx=(nx1-1)/res+1;
ny=(ny1-1)/res+1;

af2_file_name = ['af2_ISMIP6_GrIS_' sprintf('%05d',res*1000) 'm.nc'];

%%%%%%%%%%%%%%%%%%%

lat=zeros(nx,ny);
lon=zeros(nx,ny);
af=zeros(nx,ny);
af2=zeros(nx,ny);
xd=single(zeros(nx,1));
yd=single(zeros(ny,1));

g2r=pi/180;

lambda_0=g2r*lon_c;
phi_c = g2r*lat_c;
m_c = cos(phi_c)/(1-esp^2 * (sin(phi_c))^2)^0.5;
t_c = tan(pi/4-phi_c/2) / ( ((1-esp*sin(phi_c))/(1+esp*sin(phi_c)))^(esp/2) );

for ip=1:nx
    xd(ip) = (dx + (ip-1) * res*1000);
end
for jp=1:ny
    yd(jp) = (dy + (jp-1) * res*1000);
end

%%% for all grid box numbers
for ip=1:nx
  for jp=1:ny

    x = (dx + (ip-1) * res*1000);
    y = (dy + (jp-1) * res*1000);

    rho = sqrt(x^2+y^2);
    t = rho * t_c/(a * m_c);
    xi = pi/2-2*atan(t);

    phi = (xi + (esp^2/2 + 5*esp^4/24 + esp^6/12 + 13*esp^8/360) * sin(2*xi) + ...
                (7*esp^4/48 + 29*esp^6/120 + 811*esp^8/11520) * sin(4*xi) + ...
                (7*esp^6/120 + 81*esp^8/1120) * sin(6*xi) + ...
                (4279*esp^8/161280) * sin(8*xi));

    lambda = (lambda_0 + atan2(x,(-y)));

    m = cos(phi)/(1-esp^2 * (sin(phi))^2)^0.5;

    k = rho/(a*m);

    lat(ip,jp)=phi/g2r;
    lon(ip,jp)=lambda/g2r;
    af(ip,jp)=1/k;
    af2(ip,jp)=(1/k)^2;

  end
end

% wrap lon to range [0 360]
%lon(find(lon>360))=lon(find(lon>360))-360;

% pole for checking
k_0= m_c*( ((1+esp)^(1+esp)) * ((1-esp)^(1-esp)))^(1/2) /(2*t_c);
af0=1/k_0;
af20=(1/k_0)^2;

%% plotting
%figure('Position',[ 440   241   552   557])
%subplot(2,2,1)
%imagesc(lat');
%axis xy
%colorbar
%title('lat')
%subplot(2,2,2)
%imagesc(lon');
%axis xy
%colorbar
%title('lon')
%subplot(2,2,3)
%imagesc(1./af');
%axis xy
%colorbar
%title('k')
%subplot(2,2,4)
%imagesc(af2');
%axis xy
%colorbar
%title('af2')

%print -r300 -dpng NPS_AF
if exist(af2_file_name, 'file') ~= 0;
    delete(af2_file_name)
end

% Coordinates
nccreate(af2_file_name,'x','Dimensions',{'x',nx}, 'Datatype','single', 'Format','classic');
nccreate(af2_file_name,'y','Dimensions',{'y',ny}, 'Datatype','single', 'Format','classic');
ncwrite(af2_file_name,'x',xd);
ncwrite(af2_file_name,'y',yd);
ncwriteatt(af2_file_name,'x', 'units', 'm') ;
ncwriteatt(af2_file_name,'y', 'units', 'm') ;
ncwriteatt(af2_file_name,'x', 'standard_name', 'projection_x_coordinate') ;
ncwriteatt(af2_file_name,'y', 'standard_name', 'projection_y_coordinate') ;
ncwriteatt(af2_file_name,'x', 'axis', 'x') ;
ncwriteatt(af2_file_name,'y', 'axis', 'y') ;

% Data
wnc(single(af2),af2_file_name,'af2','1','projection area scale factor',{'x','y'},0,'classic')
ncwriteatt(af2_file_name,'af2','grid_mapping','mapping')

ncwriteatt(af2_file_name,'/','proj4','+init=epsg:3413')
ncwriteatt(af2_file_name,'/','Description','Area scaling factor (af2) for ISMIP6 Greenland grid. Multiply with 2D data to correct the projection error. af2=(1/k)^2, where k is the map scale factor. Calculated after Snyder (1987) by Heiko Goelzer, 2022.')

% Mapping information
mapping = 'mapping';
nccreate(af2_file_name,'mapping','Datatype','char');
ncwriteatt(af2_file_name,'mapping', 'ellipsoid', 'WGS84') ;
ncwriteatt(af2_file_name,'mapping', 'false_easting', 0.) ;
ncwriteatt(af2_file_name,'mapping', 'false_northing', 0.) ;
ncwriteatt(af2_file_name,'mapping', 'grid_mapping_name', 'polar_stereographic') ;
ncwriteatt(af2_file_name,'mapping', 'latitude_of_projection_origin', 90.) ;
ncwriteatt(af2_file_name,'mapping', 'standard_parallel', 70.) ;
ncwriteatt(af2_file_name,'mapping', 'straight_vertical_longitude_from_pole', -45) ;

