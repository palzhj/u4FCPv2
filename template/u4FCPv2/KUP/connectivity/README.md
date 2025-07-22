# Getting started

Vivado version: 2022.2

Open the vivado with GUI, use the tcl console. Or open the vivado without GUI by ```vivado -mode tcl```

If use the CIV device, type
```
set ::civ 1
```

then

```
cd scripts
source ./create_project.tcl
source ./run_implementation.tcl
```

All files should appear in the output folder.
