Select the AXI HPM0 LPD check box.# vitis_ai_custom_platform
This project is trying to create a base vitis platform to run with DPU


# Vitis AI platform development<br /><br />
1. Vitis Platform<br />
2. Create the Vivado Hardware Component<br />
3. Create the PetaLinux Software Componemt<br />
4. Create the platform<br />
5. 

## Vitis Platform<br /><br />
The Vivado Design Suite is used to generate and write a second type of XSA containing a few additional IP blocks and metadata to support kernel connectivity. The following figure shows the acceleration kernel application development flow:<br />
![vitis_acceleration_flow.PNG](/pic_for_readme/vitis_acceleration_flow.PNG)

## Create the Vivado Hardware Component<br /><br />
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
      - All Automation<br />
      - Zynq_ultra_ps_e_0<br />
      - Apply Board Presets<br />

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
   e. Enable clk_out1 through clk_out3 in the Output Clock column, rename them as ```clk_100m```, ```clk_200m```, ```clk_400m``` and set the Requested Output Freq as follows:<br />
      - clk_100m to ```100``` MHz.<br />
      - clk_200m to ```200``` MHz.<br />
      - clk_400m to ```400``` MHz.<br />

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
   a. Click ***Run Connection Automation***, which will open a dialog that will help connect the proc_sys_reset blocks to the clocking wizard clock outputs.<br />
   b. Enable All Automation on the left side of the Run Connection Automation dialog box.<br />
   c. Select clk_in1 on clk_wiz_0, and set the Clock Source to ***/zynq_ultra_ps_e_0/pl_clk0***.<br />
   d. For each proc_sys_reset instance, select the slowest_sync_clk, and set the Clock Source as follows:<br />
      - proc_sys_reset_100m with /clk_wiz_0/clk_100m<br />
      - proc_sys_reset_200m with /clk_wiz_0/clk_200m<br />
      - proc_sys_reset_400m with /clk_wiz_0/clk_400m<br />

   e. On each proc_sys_reset instance, select the ***ext_reset_in***, set ***Board Part Interface*** and set the ***Select Manual Source*** to ***/zynq_ultra_ps_e_0/pl_resetn0***.<br />
   f. Make sure all checkboxes are enabled, and click ***OK*** to close the dialog and create the connections.<br />
   g. Connect all the ***dcm_locked*** signals on each proc_sys_reset instance to the locked signal on ***clk_wiz_0***.<br />
   Then the connection should like below:<br />
   ![clk_rst_connection.png](/pic_for_readme/clk_rst_connection.png)<br /><br />
***Now we have added clock and reset IPs and configure and connect them. Some would be used in creating the hardware platform and some would be called in Vitis high level design***<br /><br />

9. Add Kernel Interrupt Support<br />
You can provide kernel interrupt support by adding an AXI interrupt controller to the base hardware design and connecting the output of the interrupt controller to the input of the processor block interrupt. The interrupt inputs of the AXI interrupt controller are initialized to a de-asserted state by wiring them to ground. When the v++ linker adds acceleration kernels to the base hardware design, the dynamic_postlink.tcl script is used to wire the interrupt output of the kernel to the AXI interrupt controller. <br />
   a. In the block diagram, double-click the Zynq UltraScale+ MPSoC block.<br />
   b. Select ***PS-PL Configuration > PS-PL interfaces > Master interface***.<br />
   c. Select the ***AXI HPM0 LPD*** check box, keep the ***AXI HPM0 LPD Data width*** settings as default ***32***.<br />
   d. Click ***OK*** to finsih the configuration.<br />
   e. Connect ***maxihpm0_lpd_aclk*** to ***/clk_wiz_0/clk_100m***.<br />
   f. Right click Diagram view and select ***Add IP***, search and add ***Concat*** IP.<br />
   g. Double-click the Concat block to open the Re-Customize IP dialog box.<br />
   h. Set the number of ports to ```32```.<br />
   i. Right click Diagram view and select ***Add IP***, search and add ***Constant*** IP.<br />
   j. Double-click the Constant IP, set Const Width = 1 & Const Val = 0, click ***OK***.<br />
   k. Connect the xlconstant_0 dout[0:0] output to all 32 inputs of xlconcat_0 like below:<br />
   ![concat_connection.png](/pic_for_readme/concat_connection.png)<br /><br />
   l. Select the ***xconstant_0*** IP block,in the Block Properties, General dialog box, change the name to ```xlconstant_gnd```.<br />
   m. Select the ***xlconcat_0*** IP block,in the Block Properties, General dialog box, change the name to ```xlconcat_interrupt_0```.<br />
   These names should match the ones in the dynamic_postlink.tcl script.<br />
   n. Right click Diagram view and select ***Add IP***, search and add ***AXI Interrupt Controller*** IP.<br />
   o. Double-click the AXI Interrupt Controller block, set the Interrupts type to Level by changing the button to ***Manual*** and entering ```0x0``` text field, Set the Level type to High by changing the button to ***Manual*** and entering ```0xFFFFFFFF```, Set the Interrupt Output Connection to ***Single***, click ***OK***.<br />
   The configuration of axi_intc should like below:
   ![intc_settings.png](/pic_for_readme/intc_settings.png)<br /><br />
   p. Click ***Run Connection Automation***<br />
   q. Leave the default values for Master interface and Bridge IP.
      - Master interface default is /zynq_ultra_ps_e_0/M_AXI_HPM0_LPD.
      - Bridge IP default is New AXI interconnect.

   r. For the clock source for driving Bridge IP/Slave interface/Master interface, select /clk_wiz_0/clk_100m. <br />
   You can select other clock resources if you want. But for axi_lite bus for register control i would recommend a lower frequency.
   s. Connect the interrupt_concat/dout[31:0] to the axi_intc_0/intr[0:0] input.
   t. Connect the axi_intc_0/irq output to the Zynq UltraScale+ MPSoC pl_ps_irq0[0:0] input.
   ![vivado_platform_connection.png](/pic_for_readme/vivado_platform_connection.png)<br /><br />
***Note: Now we have finished the IPI design input, let's set some platform parameters and generate the DSA***<br /><br /><br />

## Configuring Platform Interface Properties<br /><br />



