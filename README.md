# generate-ismip7-grid-files

Matlab scripts to generate grid description files used for cdo regridding.

All regridding operations in ISMIP7 are based on these grid description files.

See also https://www.climate-cryosphere.org/wiki/index.php?title=Regridding_with_CDO

Based on work by Jeremy Fyke, Andy Bliss and others.

## Main scripts for AIS and GrIS

```ISMIP6_AIS_multigrid_generator_nc.m```

```ISMIP6_GrIS_multigrid_generator_nc.m```

Will generate a number of grid description files for use with the cdo remap command (https://code.mpimet.mpg.de/projects/cdo).

## Script for BedMachine Greenland data grid
```BedMachine_GrIS_multigrid_generater_nc.m```

## Utilities

```polarstereo_inv.m```

```generate_CDO_files_nc.m```

```wnc.m```

## Produce area fraction files 

```calcphilambda_epsg3031.m```

```calcphilambda_epsg3413.m```

The resulting 'af' files can be used to compensate the grid projection error. Multiply 2D gridded variables with 'af' before spatial integration, summation or averaging.
