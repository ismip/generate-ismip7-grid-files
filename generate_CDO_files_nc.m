function [ successfully_completed ] = generate_CDO_files2(grid, proj_info, output_data_type, flag_nc, flag_txt, flag_xy)

%% Make X,Y cartesian coordinates
dx=grid.dx;
dy=grid.dy;
nx_centers=grid.nx_centers;
ny_centers=grid.ny_centers;
nsize=grid.nx_centers*grid.ny_centers;
%% Create gridded x and y
[ycenters,xcenters]=meshgrid((0:ny_centers-1).*dy , (0:nx_centers-1).*dx);


%% Write 2d xy netcdf file
if(flag_xy)
        disp(['Generating ' grid.xyOutputFileName ])

if exist(grid.xyOutputFileName, 'file') ~= 0;
    delete(grid.xyOutputFileName)
end

%% write 2D and 1d x,y
wnc(xcenters-proj_info.falseeasting,grid.xyOutputFileName,'x2','m','grid center x-coordinate',{'x','y'},0,'NETCDF4')
wnc(ycenters-proj_info.falsenorthing,grid.xyOutputFileName,'y2','m','grid center y-coordinate',{'x','y'},0,'NETCDF4')

wnc(squeeze(xcenters(:,1))-proj_info.falseeasting,grid.xyOutputFileName,'x1','m','grid center x-coordinate','x',0,'NETCDF4')
wnc(squeeze(ycenters(1,:))-proj_info.falsenorthing,grid.xyOutputFileName,'y1','m','grid center y-coordinate','y',0,'NETCDF4')

end

if(flag_nc || flag_txt)

%% Create lat,lon coordinates
[LI_grid_center_lat,LI_grid_center_lon]=polarstereo_inv(...
    xcenters(:)-proj_info.falseeasting,...
    ycenters(:)-proj_info.falsenorthing,...
    proj_info.earthradius,proj_info.eccentricity,...
    proj_info.standard_parallel,...
    proj_info.longitude_rot);
                                    
LI_grid_center_lat=reshape(LI_grid_center_lat,size(ycenters));
LI_grid_center_lon=reshape(LI_grid_center_lon,size(xcenters));

[ycorners,xcorners]=meshgrid((0:ny_centers).*dy-dy./2 , (0:nx_centers).*dx-dx./2);
[LI_grid_corner_lat,LI_grid_corner_lon]=polarstereo_inv(...
    xcorners(:)-proj_info.falseeasting,...
    ycorners(:)-proj_info.falsenorthing,...
    proj_info.earthradius,proj_info.eccentricity,...
    proj_info.standard_parallel,...
    proj_info.longitude_rot);

LI_grid_corner_lat=reshape(LI_grid_corner_lat,size(ycorners));
LI_grid_corner_lon=reshape(LI_grid_corner_lon,size(xcorners));


%% Generate 3d corner coordinates

LI_grid_center_lat_CDO_format=LI_grid_center_lat;
LI_grid_center_lon_CDO_format=LI_grid_center_lon;

LI_grid_corner_lat_CDO_format=zeros([4,size(LI_grid_center_lat_CDO_format)]);

NEcorner_lat=LI_grid_corner_lat(2:end,1:end-1);     LI_grid_corner_lat_CDO_format(1,:,:)=NEcorner_lat;
SEcorner_lat=LI_grid_corner_lat(2:end,2:end);       LI_grid_corner_lat_CDO_format(2,:,:)=SEcorner_lat;
SWcorner_lat=LI_grid_corner_lat(1:end-1,2:end);     LI_grid_corner_lat_CDO_format(3,:,:)=SWcorner_lat;
NWcorner_lat=LI_grid_corner_lat(1:end-1,1:end-1);   LI_grid_corner_lat_CDO_format(4,:,:)=NWcorner_lat;

LI_grid_corner_lon_CDO_format=zeros([4,size(LI_grid_center_lon_CDO_format)]);

NEcorner_lon=LI_grid_corner_lon(2:end,1:end-1);     LI_grid_corner_lon_CDO_format(1,:,:)=NEcorner_lon;
SEcorner_lon=LI_grid_corner_lon(2:end,2:end);       LI_grid_corner_lon_CDO_format(2,:,:)=SEcorner_lon;
SWcorner_lon=LI_grid_corner_lon(1:end-1,2:end);     LI_grid_corner_lon_CDO_format(3,:,:)=SWcorner_lon;
NWcorner_lon=LI_grid_corner_lon(1:end-1,1:end-1);   LI_grid_corner_lon_CDO_format(4,:,:)=NWcorner_lon;

%LI_grid_center_lon_CDO_format=wrapTo360(LI_grid_center_lon_CDO_format);
%LI_grid_corner_lon_CDO_format=wrapTo360(LI_grid_corner_lon_CDO_format);

if strcmp(output_data_type,'radians')
    LI_grid_center_lat_CDO_format=deg2rad(LI_grid_center_lat_CDO_format);
    LI_grid_center_lon_CDO_format=deg2rad(LI_grid_center_lon_CDO_format);
    LI_grid_corner_lat_CDO_format=deg2rad(LI_grid_corner_lat_CDO_format);
    LI_grid_corner_lon_CDO_format=deg2rad(LI_grid_corner_lon_CDO_format);
end

LI_grid_dims_CDO_format=int32(size(LI_grid_center_lat_CDO_format));
LI_grid_imask_CDO_format=zeros(LI_grid_dims_CDO_format,'int32');
LI_grid_imask_CDO_format(:,:)=1;

end

%% Write CDO grid netcdf file
if(flag_nc)
        disp(['Generating ' grid.LatLonOutputFileName ])

if exist(grid.LatLonOutputFileName, 'file') ~= 0;
    delete(grid.LatLonOutputFileName)
end

% grid centers
wnc(LI_grid_center_lat,grid.LatLonOutputFileName,'lat','degrees_north','grid center latitude',{'x','y'},0,'NETCDF4')
ncwriteatt(grid.LatLonOutputFileName,'lat','standard_name','latitude')
ncwriteatt(grid.LatLonOutputFileName,'lat','bounds','lat_bnds')

wnc(LI_grid_center_lon,grid.LatLonOutputFileName,'lon','degrees_east','grid center longitude',{'x','y'},0,'NETCDF4')
ncwriteatt(grid.LatLonOutputFileName,'lon','standard_name','longitude')
ncwriteatt(grid.LatLonOutputFileName,'lon','bounds','lon_bnds')

% bounds
wnc(LI_grid_corner_lat_CDO_format,grid.LatLonOutputFileName,'lat_bnds','degrees_north','grid corner latitude',{'nv4','x','y'},0,'NETCDF4')
wnc(LI_grid_corner_lon_CDO_format,grid.LatLonOutputFileName,'lon_bnds','degrees_east','grid corner longitude',{'nv4','x','y'},0,'NETCDF4')

% dummy needed for mapping
wnc(int8(LI_grid_center_lon*0+1),grid.LatLonOutputFileName,'dummy','1','dummy variable',{'x','y'},0,'NETCDF4')
% add lat,lon mapping
ncwriteatt(grid.LatLonOutputFileName,'dummy','coordinates','lon lat')

end


%% Write CDO grid text file
if(flag_txt)
    disp(['Generating ' grid.CDOOutputFileName ])
if exist(grid.CDOOutputFileName, 'file');
    delete(grid.CDOOutputFileName)
end

fileID = fopen(grid.CDOOutputFileName,'w');
fprintf(fileID,'%s\n','gridtype  = curvilinear');
fprintf(fileID,'%s\n',['gridsize  =' , num2str(nsize)]);
fprintf(fileID,'%s\n',['xsize  = ' , num2str(nx_centers)]);
fprintf(fileID,'%s\n',['ysize  = ' , num2str(ny_centers)]);

fprintf(fileID,'%s\n','xvals  = ');
fprintf(fileID,'%12.8f %12.8f %12.8f %12.8f\n',LI_grid_center_lon_CDO_format);
fprintf(fileID,'%s\n',' ');

fprintf(fileID,'%s\n','xbounds  = ');
fprintf(fileID,'%12.8f %12.8f %12.8f %12.8f\n',LI_grid_corner_lon_CDO_format);

fprintf(fileID,'%s\n','yvals  = ');
fprintf(fileID,'%12.8f %12.8f %12.8f %12.8f\n',LI_grid_center_lat_CDO_format);
fprintf(fileID,'%s\n',' ');

fprintf(fileID,'%s\n','ybounds  = ');
fprintf(fileID,'%12.8f %12.8f %12.8f %12.8f\n',LI_grid_corner_lat_CDO_format);

fclose(fileID);
end

successfully_completed = 1;

