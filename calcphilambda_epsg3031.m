% Calculate phi, lambda and k
% for south polar aspect of stereographic projection
% Following Snyder p. 162
% Heiko Goelzer, February 2022 (heig@norceresearch.no)

res=16;
%res=8;
%res=4;

n1=6081;
nx=(n1-1)/res+1;
phideg=71.;
dx=-3040000;


lat=zeros(nx,nx);
lon=zeros(nx,nx);
af=zeros(nx,nx);
af2=zeros(nx,nx);
xd=single(zeros(nx,1));

af2_file_name = ['af2_ISMIP6_AIS_' sprintf('%05d',res*1000) 'm.nc'];

%%%%%%%%%%%%%%%%%%%
ic = (n1-1)/res/2+1;
jc = (n1-1)/res/2+1;

labmda_0=0;
g2r=pi/180;
a = 6378137;
f = 1/298.257223563;
esp = sqrt(2*f-f^2);

sign=-1;
phi_c = g2r*phideg*sign;

m_c = cos(phi_c)/(1-esp^2 * (sin(phi_c))^2)^0.5;

% south
t_c = tan(pi/4+phi_c/2) / ( ((1+esp*sin(phi_c))/(1-esp*sin(phi_c)))^(esp/2) );

for ip=1:nx
    xd(ip) = (dx + (ip-1) * res*1000);
end

%%% for all grid box numbers
for ip=1:nx
  for jp=1:nx

    y = (ip-ic) * res*1000;
    x = (jp-jc) * res*1000;

    rho = sqrt(x^2+y^2);

    t = rho * t_c/(a * m_c);

    xi = pi/2-2*atan(t);

    phi = sign*(xi + (esp^2/2 + 5*esp^4/24 + esp^6/12 + 13*esp^8/360) * sin(2*xi) + ...
                (7*esp^4/48 + 29*esp^6/240 + 811*esp^8/11520) * sin(4*xi) + ...
                (7*esp^6/120 + 81*esp^8/1120) * sin(6*xi) + ...
                (4279*esp^8/161280) * sin(8*xi));

    % iteration
    phi1 = pi/2-2*atan(t);
    for i=1:5
      phi = pi/2-2*atan(t*((1-esp*sin(phi1))/(1+esp*sin(phi1)))^(esp/2));
      [i, phi, phi1, log(abs(phi-phi1))];
      phi1 = phi;
    end
    phi=phi*sign;

    %lambda = sign*(labmda_0 + atan(x/(-y)));
    lambda = (labmda_0 + atan2(x,(-y)));

    phi_deg = phi/g2r;
    lambda_deg = lambda/g2r+270;

    m = cos(phi)/(1-esp^2 * (sin(phi))^2)^0.5;

    k = rho/(a*m);

%    [phi_deg,lambda_deg,k,1/k]
    
    lat(ip,jp)=phi_deg;
    lon(ip,jp)=lambda_deg;
    af(ip,jp)=1/k;
    af2(ip,jp)=(1/k)^2;


  end
end

% pole
k_0= m_c*( ((1+esp)^(1+esp)) * ((1-esp)^(1-esp)))^(1/2) /(2*t_c);
lat(ic,jc)=-90;
lon(ic,jc)=0;
lon(find(lon>360))=lon(find(lon>360))-360;
af(ic,jc)=1/k_0;
af2(ic,jc)=(1/k_0)^2;



if exist(af2_file_name, 'file') ~= 0;
    delete(af2_file_name)
end

% Coordinates
nccreate(af2_file_name,'x','Dimensions',{'x',nx}, 'Datatype','single', 'Format','classic');
nccreate(af2_file_name,'y','Dimensions',{'y',nx}, 'Datatype','single', 'Format','classic');
ncwrite(af2_file_name,'x',xd);
ncwrite(af2_file_name,'y',xd);
ncwriteatt(af2_file_name,'x', 'units', 'm') ;
ncwriteatt(af2_file_name,'y', 'units', 'm') ;
ncwriteatt(af2_file_name,'x', 'standard_name', 'projection_x_coordinate') ;
ncwriteatt(af2_file_name,'y', 'standard_name', 'projection_y_coordinate') ;
ncwriteatt(af2_file_name,'x', 'axis', 'x') ;
ncwriteatt(af2_file_name,'y', 'axis', 'y') ;

% Data
wnc(single(af2),af2_file_name,'af2','1','projection area scale factor',{'x','y'},0,'classic')
ncwriteatt(af2_file_name,'af2','grid_mapping','mapping')

ncwriteatt(af2_file_name,'/','proj4','+init=epsg:3031')
ncwriteatt(af2_file_name,'/','Description','Area scaling factor (af2) for ISMIP6 Antarctic grid. Multiply with 2D data to correct the projection error. af2=(1/k)^2, where k is the map scale factor. Calculated after Snyder (1987) by Heiko Goelzer, 2022.')

% Mapping information
mapping = 'mapping';
nccreate(af2_file_name,'mapping','Datatype','char');
ncwriteatt(af2_file_name,'mapping', 'ellipsoid', 'WGS84') ;
ncwriteatt(af2_file_name,'mapping', 'false_easting', 0.) ;
ncwriteatt(af2_file_name,'mapping', 'false_northing', 0.) ;
ncwriteatt(af2_file_name,'mapping', 'grid_mapping_name', 'polar_stereographic') ;
ncwriteatt(af2_file_name,'mapping', 'latitude_of_projection_origin', -90.) ;
ncwriteatt(af2_file_name,'mapping', 'standard_parallel', -71.) ;
ncwriteatt(af2_file_name,'mapping', 'straight_vertical_longitude_from_pole', 0) ;

