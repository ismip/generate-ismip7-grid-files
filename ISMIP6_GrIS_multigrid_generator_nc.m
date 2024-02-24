% Generate a number of ISM grid files based on the same projection
% at different resolutions. Checks if integer subdivision for chosen base grid
% and resolution

clear all
close all

% for checking 
isaninteger = @(x) mod(x, 1) == 0;

%% Specify mapping information. This is EPSG 3413
proj_info.earthradius=6378137.0;
proj_info.eccentricity=0.081819190842621;
proj_info.standard_parallel=70.;
proj_info.longitude_rot=315.;
% offset of grid node centers
proj_info.falseeasting=720000;
proj_info.falsenorthing=3450000;

%% Specify output angle type (degrees or radians)
%output_data_type='radians';
output_data_type='degrees';

%% Specify various ISM grids at different resolution
%rk = [40 30 20 16 15 10 8 6 5 4 3 2 1]
%rk = 0.5;
rk = [5 1]; 
%rk = 240; % upper limit

% grid dimensions of 1 km base grid
nx_base=1681;
ny_base=2881;

% choose which output file to write
flag_nc = 1;
flag_txt = 0;
flag_xy = 0;

index=0;
for r=rk
% For any resolution but check integer grid numbers
    nx = (nx_base-1)/(r)+1;
    ny = (ny_base-1)/(r)+1;
    if(isaninteger(nx) & isaninteger(ny))
        index=index+1;
        grid(index).dx=r*1000.;
        grid(index).dy=r*1000.;
        grid(index).nx_centers=(nx_base-1)/(r)+1;
        grid(index).ny_centers=(ny_base-1)/(r)+1;
        grid(index).LatLonOutputFileName=['grid_ISMIP6_GrIS_' sprintf('%05d',r*1000) 'm.nc'];
        grid(index).CDOOutputFileName=['grid_ISMIP6_GrIS_' sprintf('%05d',r*1000) 'm.txt'];
        grid(index).xyOutputFileName=['xy_ISMIP6_GrIS_' sprintf('%05d',r*1000) 'm.nc'];
    else
        disp(['Warning: resolution ' num2str(r) ' km is not comensurable, skipped.'])
    end
end

% Create grids and write out
for g=1:length(grid)
    success = generate_CDO_files_nc(grid(g),proj_info,output_data_type,flag_nc,flag_txt,flag_xy);
end
