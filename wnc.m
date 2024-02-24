function wnc(var,fname,vname,uname,lname,dnames,add_singleton_time_dim,ncformat)
%%Write data from workspace to netCDF file.
%Syntax:
%wnc(var,fname,vname,uname,lname,dnames,add_singleton_time_dim,ncformat)
%var=variable array
%fname=name of netcdf file (in quotations, i.e. 'example.nc')
%vname=name of variable (also in quotations)
%uname=name of variable units (also in quotations)
%lname=long variable name
%dnames=names of dimensions
%add_singleton_time_dim=0/1 to not add/add a singleton time dimension
%ncformat=netcdf file format

if isvector(var);
    dnames={dnames};
    nDims=1;
    var_dims=length(var);
else
    nDims=ndims(var);
    var_dims=size(var);
end

%vname
%[size(dnames,2), nDims]
if size(dnames,2) ~= nDims;
   error('Dimension name list not equal in size to dimensionality of variable') 
end

for n=1:nDims
   DimInput{(n-1)*2+1} =dnames{n};
   DimInput{(n)*2}     =var_dims(n);
end

if add_singleton_time_dim
    %if no time dimension, add an unlimited time dimension
    if ~sum(strcmp(dnames,'time'))
        DimInput{end+1}='time';
        DimInput{end+1}=inf;
    else
       error('You requested to add unlimited time dim, but a time dim already exists.') 
    end
end

nccreate(fname,vname,...
         'Dimensions',DimInput,...
         'Datatype',class(var),...
         'Format',ncformat);
     
ncwrite(fname,vname,var)
ncwriteatt(fname,vname,'units',uname)
ncwriteatt(fname,vname,'long_name',lname)
