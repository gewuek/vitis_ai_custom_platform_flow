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

***Note: At this stage, the Vivado block automation has added a Zynq UltraScale+ MPSoC block and applied all board presets for the ZCU102. Add the IP blocks and metadata to create a base hardware design that supports acceleration kernels.***<br /><br />
5. Re-Customizing the Processor IP Block<br />
  a. Double-click the Zynq UltraScale+ MPSoC block in the IP integrator diagram.<br />
  b. Select ***Page Navigator > PS-PL Configuration***.<br />
  c. Expand ***PS-PL Configuration > PS-PL Interfaces*** by clicking the > symbol.<br />
  d. Expand Master Interface.<br />
  e. Uncheck the AXI HPM0 FPD and AXI HPM1 FPD interfaces.<br />
  f. Click OK.<br />
  g. Confirm that the IP block interfaces were removed from the Zynq UltraScale+ MPSoC symbol in your block design.<br />
  ![hp_removed.png](/pic_for_readme/hp_removed.png)<br />
  
***Note: This is a little different from traditional Vivado design flow. When trying to make AXI interfaces available in Vitis design you should disable these interface at Vivado IPI platform and enable them at platform interface properties. We will show you how to do that later***<br><br />

6. Add clock block:<br />
  a. Right click Diagram view and select ***Add IP***.<br />
  b. Search for and add a Clocking Wizard from the IP Search dialog.<br />
  c. Double-click the clk_wiz_0 IP block to open the Re-Customize IP dialog box.<br />
  d. Click the Output Clocks tab.<br />
  e. Enable clk_out1 through clk_out3 in the Output Clock column, rename them as ```clk_100m```, ```clk_200m```, ```clk_400m``` and set the Requested Output Freq as follows: <br />
    * clk_100m to ```100``` MHz.<br />
    * clk_200m to ```200``` MHz.<br />
    * clk_400m to ```400``` MHz.<br />
  f. At the bottom of the dialog box set the ***Reset Type*** to ***Active Low***.<br />
  g. Click ***OK*** to close the dialog.<br />
    The settings should like below:<br />
    ![clock_settings.png](/pic_for_readme/clock_settings.png)<br />
***Note: So now we have set up the clock system for our design. This clock wizard use the pl_clk as input clock and geneatate clocks needed for the whole logic design. In this simple design I would like to use 100MHz clock as the axi_lite control bus clock, 200MHz clock as DPU AXI interface clock and 400MHz as DPU core clock. You can just modifiy these clocks as you like and remember we should "tell" Vitis what clock we can use. Let's do that later.***<br><br />

7. Add the Processor System Reset blocks:<br />
  a. Right click Diagram view and select ***Add IP***.<br />
  b. Search for and add a Processor System Reset from the IP Search dialog<br />
  c. Add 2 more Processor System Reset blocks, using the previous step; or select the proc_sys_reset_0 block and Copy (Ctrl-C) and Paste (Ctrl-V) it four times in the block diagram<br />
  d. Rename them as ```proc_sys_reset_100m```, ```proc_sys_reset_200m```, ```proc_sys_reset_400m```<br />
  
8. Connect Clocks and Resets: <br />
  a. Click Run Connection Automation, which will open a dialog that will help connect the proc_sys_reset blocks to the clocking wizard clock outputs.
  b. Enable All Automation on the left side of the Run Connection Automation dialog box.
  c. Select clk_in1 on clk_wiz_0, and set the Clock Source to /zynq_ultra_ps_e_0/pl_clk0
  d. For each proc_sys_reset instance, select the slowest_sync_clk, and set the Clock Source as follows:
    proc_sys_reset_0 with /clk_wiz_0/clk_out1
    proc_sys_reset_1 with /clk_wiz_0/clk_out2
    proc_sys_reset_2 with /clk_wiz_0/clk_out3
    proc_sys_reset_3 with /clk_wiz_0/clk_out4
    proc_sys_reset_4 with /clk_wiz_0/clk_out5


