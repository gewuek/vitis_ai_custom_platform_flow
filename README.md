# vitis_ai_custom_platform
This project is trying to create a base vitis platform to run with DPU


# Vitis AI platform development
1. Vitis Platform<br />
2. Create the Vivado Hardware Component<br />
3. Create the PetaLinux Software Componemt<br />
4. Create the platform<br />
5. 

### Vitis Platform
The Vivado Design Suite is used to generate and write a second type of XSA containing a few additional IP blocks and metadata to support kernel connectivity. The following figure shows the acceleration kernel application development flow:<br />
![vitis_acceleration_flow.PNG](/pic_for_readme/vitis_acceleration_flow.PNG)

### Create the Vivado Hardware Component
1. Source <Vitis_Install_Directory>/settings64.sh, and call Vivado out by typing "vivado" in the console.<br />
2. Create a Vivado project named zcu102_custom_platform.<br />
  a. Select ***File->Project->New***.<br />
  b. Click ***Next***.<br />
  c. In Project Name dialog set Project name to ```zcu102_custom_platform```.<br />
  d. Click ***Next***.<br />
  e. Leaving all the setting to default until you goto the Default Part dialog.<br />
  f. Select ***Boards tab*** and then select ***Zynq UltraScale+ ZCU102 Evaluation Board***<br />
  g. Click ***Next***, and your project summary should like below:<br />
  ![vivado_project_summary.png](/pic_for_readme/vivado_project_summary.png)<br />
  h. Then click ***Finish***<br />
3. Create a block design named system. <br />
  a. Select Create Block Design.<br />
  b. Change the design name to ```system```.<br />
  c. Click ***OK***.<br />
4. Add MPSoC IP and run block automation to configure it.<br />
  a. Right click Diagram view and select ***Add IP***.<br />
  b. Search for ```zynq``` and then double-click the ***Zynq UltraScale+ MPSoC*** from the IP search results.<br />
  c. Click the ***Run Block Automation*** link to apply the board presets.<br />
    In the Run Block Automation dialog, ensure the following is check marked:<br />      
      * All Automation<br />
      * Zynq_ultra_ps_e_0<br />
      * Apply Board Presets<br />
  d. Click ***OK***. You should get MPSoC block configured like below:<br />
  ![block_automation_result.png](/pic_for_readme/block_automation_result.png)<br />

```At this stage, the Vivado block automation has added a Zynq UltraScale+ MPSoC block and applied all board presets for the ZCU102. Add the IP blocks and metadata to create a base hardware design that supports acceleration kernels.```<br />
5. Re-Customizing the Processor IP Block<br />
  a. Double-click the Zynq UltraScale+ MPSoC block in the IP integrator diagram.<br />
  b. Select ***Page Navigator > PS-PL Configuration***.<br />
  c. Expand ***PS-PL Configuration > PS-PL Interfaces*** by clicking the > symbol.<br />
  d. Expand Master Interface.<br />
  e. Uncheck the AXI HPM0 FPD and AXI HPM1 FPD interfaces.<br />
  f. Click OK.<br />
  g. Confirm that the IP block interfaces were removed from the Zynq UltraScale+ MPSoC symbol in your block design.<br />
  ![hp_removed.png](/pic_for_readme/hp_removed.png)<br />
 

