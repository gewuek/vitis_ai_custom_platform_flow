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
  a. Select File->Project->New.<br />
  b. Click Next.<br />
  c. In Project Name dialog set Project name to ```zcu102_custom_platform```.<br />
  d. Click Next.<br />
  e. Leaving all the setting to default until you goto the Default Part dialog.<br />
  f. Select Boards tab and then select "Zynq UltraScale+ ZCU102 Evaluation Board"<br />
  g. Click Next, and your project summary should like below:<br />
  ![vivado_project_summary.png](/pic_for_readme/vivado_project_summary.png)<br />
  h. Then click Finish<br />
2. Create a block design named system. <br />
  a. Select Create Block Design
  b. Change the design name to ```system```
  c. Click OK.
3. 
