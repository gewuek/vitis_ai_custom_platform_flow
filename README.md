Select the AXI HPM0 LPD check box.# vitis_ai_custom_platform
This project is trying to create a base vitis platform to run with DPU


# Vitis AI platform development<br /><br />
1. Vitis Acceleration Platform<br />
2. Create the Vivado Hardware Component<br />
3. Configuring Platform Interface Properties and Generate XSA<br />
4. Create the PetaLinux Software Component<br />
5. Create the Vitis Platform<br />
5. 

## Vitis Acceleration Platform<br /><br />
The Vivado Design Suite is used to generate and write a second type of XSA containing a few additional IP blocks and metadata to support kernel connectivity. The following figure shows the acceleration kernel application development flow:<br />
![vitis_acceleration_flow.PNG](/pic_for_readme/vitis_acceleration_flow.PNG)

## Create the Vivado Hardware Component and Generate XSA<br /><br />
1. Source <Vitis_Install_Directory>/settings64.sh, and call Vivado out by typing "vivado" in the console.<br />
2. Create a Vivado project named zcu102_custom_platform.<br />
   a) Select ***File->Project->New***.<br />
   b) Click ***Next***.<br />
   c) In Project Name dialog set Project name to ```zcu102_custom_platform```.<br />
   d) Click ***Next***.<br />
   e) Leaving all the setting to default until you goto the Default Part dialog.<br />
   f) Select ***Boards tab*** and then select ***Zynq UltraScale+ ZCU102 Evaluation Board***<br />
   g) Click ***Next***, and your project summary should like below:<br />
   ![vivado_project_summary.png](/pic_for_readme/vivado_project_summary.png)<br />
   h) Then click ***Finish***<br />
3. Create a block design named system. <br />
   a) Select Create Block Design.<br />
   b) Change the design name to ```system```.<br />
   c) Click ***OK***.<br />
4. Add MPSoC IP and run block automation to configure it.<br />
   a) Right click Diagram view and select ***Add IP***.<br />
   b) Search for ```zynq``` and then double-click the ***Zynq UltraScale+ MPSoC*** from the IP search results.<br />
   c) Click the ***Run Block Automation*** link to apply the board presets.<br />
      In the Run Block Automation dialog, ensure the following is check marked:<br />
      - All Automation<br />
      - Zynq_ultra_ps_e_0<br />
      - Apply Board Presets<br />

   d) Click ***OK***. You should get MPSoC block configured like below:<br />
![block_automation_result.png](/pic_for_readme/block_automation_result.png)<br />

***Note: At this stage, the Vivado block automation has added a Zynq UltraScale+ MPSoC block and applied all board presets for the ZCU102. Add the IP blocks and metadata to create a base hardware design that supports acceleration kernels.***<br /><br />

5. Re-Customizing the Processor IP Block<br />
   a) Double-click the Zynq UltraScale+ MPSoC block in the IP integrator diagram.<br />
   b) Select ***Page Navigator > PS-PL Configuration***.<br />
   c) Expand ***PS-PL Configuration > PS-PL Interfaces*** by clicking the > symbol.<br />
   d) Expand Master Interface.<br />
   e) Uncheck the AXI HPM0 FPD and AXI HPM1 FPD interfaces.<br />
   f) Click OK.<br />
   g) Confirm that the IP block interfaces were removed from the Zynq UltraScale+ MPSoC symbol in your block design.<br />
   ![hp_removed.png](/pic_for_readme/hp_removed.png)<br />
  
***Note: This is a little different from traditional Vivado design flow. When trying to make AXI interfaces available in Vitis design you should disable these interface at Vivado IPI platform and enable them at platform interface properties. We will show you how to do that later***<br><br />

6. Add clock block:<br />write_hw_platform -fixed -force  -file /home/wuxian/wu_project/vitis2019.2/vitis_custom_platform_flow/zcu102_custom_platform/xsa_gen/zcu102_custom_platform.xsa
   a) Right click Diagram view and select ***Add IP***.<br />
   b) Search for and add a Clocking Wizard from the IP Search dialog.<br />
   c) Double-click the clk_wiz_0 IP block to open the Re-Customize IP dialog box.<br />
   d) Click the Output Clocks tab.<br />
   e) Enable clk_out1 through clk_out3 in the Output Clock column, rename them as ```clk_100m```, ```clk_200m```, ```clk_400m``` and set the Requested Output Freq as follows:<br />
      - clk_100m to ```100``` MHz.<br />
      - clk_200m to ```200``` MHz.<br />
      - clk_400m to ```400``` MHz.<br />

   f) At the bottom of the dialog box set the ***Reset Type*** to ***Active Low***.<br />
   g) Click ***OK*** to close the dialog.<br />
  The settings should like below:<br />#define CONFIG_SYS_BOOTM_LEN 0xF000000
  ![clock_settings.png](/pic_for_readme/clock_settings.png)<br />
***Note: So now we have set up the clock system for our design. This clock wizard use the pl_clk as input clock and geneatate clocks needed for the whole logic design. In this simple design I would like to use 100MHz clock as the axi_lite control bus clock, 200MHz clock as DPU AXI interface clock and 400MHz as DPU core clock. You can just modifiy these clocks as you like and remember we should "tell" Vitis what clock we can use. Let's do that later.***<br><br />

7. Add the Processor System Reset blocks:<br />
   a) Right click Diagram view and select ***Add IP***.<br />
   b) Search for and add a Processor System Reset from the IP Search dialog<br />
   c) Add 2 more Processor System Reset blocks, using the previous step; or select the proc_sys_reset_0 block and Copy (Ctrl-C) and Paste (Ctrl-V) it four times in the block diagram<br />
   d) Rename them as ```proc_sys_reset_100m```, ```proc_sys_reset_200m```, ```proc_sys_reset_400m```<br />
  
8. Connect Clocks and Resets: <br />
   a) Click ***Run Connection Automation***, which will open a dialog that will help connect the proc_sys_reset blocks to the clocking wizard clock outputs.<br />
   b) Enable All Automation on the left side of the Run Connection Automation dialog box.<br />
   c) Select clk_in1 on clk_wiz_0, and set the Clock Source to ***/zynq_ultra_ps_e_0/pl_clk0***.<br />
   d) For each proc_sys_reset instance, select the slowest_sync_clk, and set the Clock Source as follows:<br />
      - proc_sys_reset_100m with /clk_wiz_0/clk_100m<br />
      - proc_sys_reset_200m with /clk_wiz_0/clk_200m<br />
      - proc_sys_reset_400m with /clk_wiz_0/clk_400m<br />

   e) On each proc_sys_reset instance, select the ***ext_reset_in***, set ***Board Part Interface*** and set the ***Select Manual Source*** to ***/zynq_ultra_ps_e_0/pl_resetn0***.<br />
   f) Make sure all checkboxes are enabled, and click ***OK*** to close the dialog and create the connections.<br />
   g) Connect all the ***dcm_locked*** signals on each proc_sys_reset instance to the locked signal on ***clk_wiz_0***.<br />
   Then the connection should like below:<br />
   ![clk_rst_connection.png](/pic_for_readme/clk_rst_connection.png)<br /><br />
***Now we have added clock and reset IPs and configure and connect them. Some would be used in creating the hardware platform and some would be called in Vitis high level design***<br /><br />

9. Add Kernel Interrupt Support<br />
You can provide kernel interrupt support by adding an AXI interrupt controller to the base hardware design and connecting the output of the interrupt controller to the input of the processor block interrupt. The interrupt inputs of the AXI interrupt controller are initialized to a de-asserted state by wiring them to ground. When the v++ linker adds acceleration kernels to the base hardware design, the dynamic_postlink.tcl script is used to wire the interrupt output of the kernel to the AXI interrupt controller. <br />
   a) In the block diagram, double-click the Zynq UltraScale+ MPSoC block.<br />
   b) Select ***PS-PL Configuration > PS-PL interfaces > Master interface***.<br />
   c) Select the ***AXI HPM0 LPD*** check box, keep the ***AXI HPM0 LPD Data width*** settings as default ***32***.<br />
   d) Click ***OK*** to finsih the configuration.<br />
   e) Connect ***maxihpm0_lpd_aclk*** to ***/clk_wiz_0/clk_100m***.<br />
   f) Right click Diagram view and select ***Add IP***, search and add ***Concat*** IP.<br />
   g) Double-click the Concat block to open the Re-Customize IP dialog box.<br />
   h) Set the number of ports to ```32```.<br />
   i) Right click Diagram view and select ***Add IP***, search and add ***Constant*** IP.<br />
   j) Double-click the Constant IP, set Const Width = 1 & Const Val = 0, click ***OK***.<br />
   k) Connect the xlconstant_0 dout[0:0] output to all 32 inputs of xlconcat_0 like below:<br />
   ![concat_connection.png](/pic_for_readme/concat_connection.png)<br /><br />
   l) Select the ***xconstant_0*** IP block,in the Block Properties, General dialog box, change the name to ```xlconstant_gnd```.<br />
   m) Select the ***xlconcat_0*** IP block,in the Block Properties, General dialog box, change the name to ```xlconcat_interrupt_0```.<br />
   These names should match the ones in the dynamic_postlink.tcl script.<br />
   n) Right click Diagram view and select ***Add IP***, search and add ***AXI Interrupt Controller*** IP.<br />
   o) Double-click the AXI Interrupt Controller block, set the Interrupts type to Level by changing the button to ***Manual*** and entering ```0x0``` text field, Set the Level type to High by changing the button to ***Manual*** and entering ```0xFFFFFFFF```, Set the Interrupt Output Connection to ***Single***, click ***OK***.<br />
   The configuration of axi_intc should like below:
   ![intc_settings.png](/pic_for_readme/intc_settings.png)<br /><br />
   p) Click ***Run Connection Automation***<br />
   q) Leave the default values for Master interface and Bridge IP.
      - Master interface default is /zynq_ultra_ps_e_0/M_AXI_HPM0_LPD.
      - Bridge IP default is New AXI interconnect.

   r) For the clock source for driving Bridge IP/Slave interface/Master interface, select /clk_wiz_0/clk_100m. <br />
   You can select other clock resources if you want. But for axi_lite bus for register control i would recommend a lower frequency.
   s) Connect the interrupt_concat/dout[31:0] to the axi_intc_0/intr[0:0] input.
   t) Connect the axi_intc_0/irq output to the Zynq UltraScale+ MPSoC pl_ps_irq0[0:0] input.
   ![vivado_platform_connection.png](/pic_for_readme/vivado_platform_connection.png)<br /><br />
***Note: Now we have finished the IPI design input, let's set some platform parameters and generate the DSA***<br /><br /><br />

## Configuring Platform Interface Properties<br /><br />
1. Click ***Window->Platform interfaces*** to open the ***Platform Interfaces*** Window.<br />
2. Select ***Platform-system->zynq_ultra_ps_e_0->S_AXI_HP0_FPD***, in ***Platform interface Properties*** tab enable the ***Enabled*** option like below:<br />
![enable_s_axi_hp0_fpd.png](/pic_for_readme/enable_s_axi_hp0_fpd.png)<br /><br />
3. Select ***Options*** tab, set ***memport*** to ```S_AXI_HP``` and set ***sptag*** to ```HP0``` like below:
![set_s_axi_hp0_fpd_options.png](/pic_for_readme/set_s_axi_hp0_fpd_options.png)<br /><br />
4. Do the same operations for ***S_AXI_HP1_FPD, S_AXI_HP2_FPD, S_AXI_HP3_FPD, S_AXI_HPC0_FPD, S_AXI_HPC1_FPD*** and set ***sptag*** to ```HP1```, ```HP2```, ```HP3```, ```HPC1```, ```HPC2```. And be noticed that or HPC0/HPC1 ports the ***memport*** is set to ```S_AXI_HPC``` in default, but actually we would use these ports without data coherency function enabled to get a high performance. So please modify it into ```S_AXI_HP``` manually.
![set_s_axi_hpc0_fpd_options.png](/pic_for_readme/set_s_axi_hpc0_fpd_options.png)<br /><br />
5. Enable the M01_AXI ~ M08_AXI ports of ps8_0_axi_periph IP(The axi_interconnect between M_AXI_HPM0_LPD and axi_intc_0), and set these ports with the same ***sptag*** name to ```HPM0_LPD``` and ***memport*** type to ```M_AXI_GP```<br />
6. Enable the ***M_AXI_HPM0_FPD*** and ***M_AXI_HPM1_FPD*** ports, set ***sptag*** name to ```HPM0_FPD```, ```HPM1_FPD``` and ***memport*** to ```M_AXI_GP```.<br />
***Now we enable AXI master/slave interfaces that can be used for Vitis tools on the platform***<br /><br />

7. Create a ```xsa_gen``` folder inside your Vivado project.<br />
8. Copy the https://github.com/Xilinx/Vitis_Embedded_Platform_Source/tree/master/Xilinx_Official_Platforms/zcu102_dpu/vivado/dynamic_postlink.tcl file into that ***xsa_gen*** folder.<br />
Or you can just find this file from any of the MPSoC official platform example.<br />
9. Create a file named ```xsa.tcl``` inside the ***xsa_gen*** folder.<br />
10. Copy the following commands into the xsa.tcl file and save the file.<br />
```
# Set the platform design intent properties
set_property platform.design_intent.embedded true [current_project]
set_property platform.design_intent.server_managed false [current_project]
set_property platform.design_intent.external_host false [current_project]
set_property platform.design_intent.datacenter false [current_project]

get_property platform.design_intent.embedded [current_project]
get_property platform.design_intent.server_managed [current_project]
get_property platform.design_intent.external_host [current_project]
get_property platform.design_intent.datacenter [current_project]

# Set the platform default output type property
set_property platform.default_output_type "sd_card" [current_project]

get_property platform.default_output_type [current_project]

# Add the platform property to use dynamic_postlink.tcl during the v++ link
set_property platform.post_sys_link_tcl_hook ./dynamic_postlink.tcl [current_project]
```
11. In your Vivado project, use the ***Tcl console*** to navigate to the xsa_gen folder, and run ```source ./xsa.tcl``` command.
![run_xsa_tcl.png](/pic_for_readme/run_xsa_tcl.png)<br /><br />
12. Right-click and select ***Validate Design*** on ***IP integrator diagram***<br />
13. Select the Zynq UltraScale+ MPSoC IP block and set ***SELECTED_SIM_MODEL*** to ```tlm``` in the Block Properties view.<br />
14. Create the HDL wrapper:<br />
    a. Right-click ***system.bd*** in the Block Design, Sources view and select Create HDL Wrapper.<br />
    b. Select Let Vivado manage wrapper and ***auto-update***.<br />
    c. Click ***OK***.<br />

15. Right-click ***system.bd*** in the Block Design, Sources view and select ***Generate Output Products***.<br />
16. Select ***File->Export->Export Hardware...***<br />
17. Set ***XSA file name*** to ```zcu102_custom_platform```, set the ***Export to*** to ```<your_vivado_project_dir>/xsa_gen/```(which you generated before) and click ***OK***.<br />
Or just call the tcl command in tcl console like:<br />
```write_hw_platform -fixed -force  -file <your_vivado_project_dir>/xsa_gen/zcu102_custom_platform.xsa```<br />
18. Check the ***<your_vivado_project_dir>/xsa_gen*** folder, you should find the ***zcu102_custom_platform.xsa*** generated there.<br />

***Now we finish the Hardware platform creation flow, then we should go to the Software platform creation***<br /><br />

## Create the PetaLinux Software Component<br /><br />

A Vitis platform requires software components. For Linux, the PetaLinux tools are invoked outside of the Vitis tools by the developer to create the necessary Linux image,Executable and Linkable Format (ELF) files, and sysroot with XRT support. Yocto or third-party Linux development tools can also be used as long as they produce the same Linux output products as PetaLinux. <br />
1. source <petaLinux_tool_install_dir>/settings.sh<br />
2. Create a PetaLinux project named ***zcu102_custom_plnx*** and configure the hw with the XSA file we created before:<br />
```petalinux-create --type project --template zynqMP --name zcu102_custom_plnx```<br />
```cd zcu102_custom_plnx```<br />
```petalinux-config --get-hw-description=<you_vivado_design_dir>/xsa_gen/```<br />
3. A petalinux-cofig menu would be launched, select ***DTG Settings->MACHINE_NAME***, modify it to ```zcu102-rev1.0```.<br />
***Note: If you are using a Xilinx development board, it is recomended to modify the machine name so that the board confiugrations would be involved in the DTS auto-generation. Otherwise you would need to configure the associated settings(e.g. the PHY information DTS node) by yourself manually.***<br />
4. Add user packages for XRT support by appending the CONFIG_x lines below to the <your_petalinux_project_dir>/project-spec/meta-user/conf/user-rootfsconfig file.<br />
```
CONFIG_xrt
CONFIG_xrt-dev
CONFIG_zocl
CONFIG_opencl-clhpp-dev
CONFIG_opencl-headers-dev
CONFIG_packagegroup-petalinux-opencv
```
5. Add user packages for DPU support by adding more configurations to the <your_petalinux_project_dir>/project-spec/meta-user/conf/user-rootfsconfig file.<br />
```
CONFIG_glog
CONFIG_gtest
CONFIG_json-c
CONFIG_protobuf
CONFIG_python3-pip
CONFIG_apt
CONFIG_dpkg
```
6. Run ```petelinux-config -c rootfs``` and select ***user packages***, select name of rootfs all the libraries listed above, save and exit.
![petalinux_rootfs.png](/pic_for_readme/petalinux_rootfs.png)<br /><br />

7. Copy ***petalinux/project-spec/meta-user/recipes-ai/opencv*** folder to ***<your_petalinux_project_dir>/project-spec/meta-user/recipes-ai*** in your platform source (if not exist, users need to create this directory).<br />
8. Add custom opencv recipe. Edit ***<your_petalinux_project_dir>/project-spec/meta-user/conf/user-rootfsconfig*** and add the opencv recipe at the end:<br />
```
COFIG_opencv
```
9. Run ```petelinux-config -c rootfs``` and select ***user packages***, enable ***opencv***, save and exit.<br />
10. To generate sysroot (PetaLinux SDK) for building Vitis AI applications add more configurations to the <your_petalinux_project_dir>/project-spec/meta-user/conf/user-rootfsconfig file.<br /> 
```
CONFIG_gtest-staticdev
CONFIG_json-c-dev
CONFIG_protobuf-dev
CONFIG_protobuf-c
CONFIG_libeigen-dev
```
11. To enable native compile on target board add more configurations to the <your_petalinux_project_dir>/project-spec/meta-user/conf/user-rootfsconfig file.<br /> 
```
CONFIG_packagegroup-petalinux-self-hosted
CONFIG_cmake 
```
12. Enable some other PetaLinux groups which mentioned at DPU integration lab for Vivado flow:<br /> 
```
CONFIG_packagegroup-petalinux-x11
CONFIG_packagegroup-petalinux-v4lutils
CONFIG_packagegroup-petalinux-matchbox
```
13. Run ```petelinux-config -c rootfs``` and select ***user packages***, select name of rootfs all the libraries listed above, save and exit.<br /> 

14. Enable OpenSSH and disable dropbear<br /> 

Dropbear is the default SSH tool in Vitis Base Embedded Platform. If OpenSSH is used to replace Dropbear, it could achieve 4x times faster data transmission speed (tested on 1Gbps Ethernet environment). Since Vitis-AI applications may use remote display feature to show machine learning results, using OpenSSH can improve the display experience.<br /> 
    a) Run ```petalinux-config -c rootfs```.<br /> 
    b) Go to ***Image Features***.<br /> 
    c) Disable ***ssh-server-dropbear*** and enable ***ssh-server-openssh***.<br /> 
    ![ssh_settings.png](/pic_for_readme/ssh_settings.png)<br /><br />
    d) Go to ***Filesystem Packages-> misc->packagegroup-core-ssh-dropbear*** and disable ***packagegroup-core-ssh-dropbear**.<br />
    e) Go to ***Filesystem Packages  -> console  -> network -> openssh** and enable ***openssh***.<br />    
    
15. Increase the size allocation for CMA memory to 512 MB (optional), disable CPU IDLE in the kernel configurations as follows:<br /> 
Default CMA size in PetaLinux project and Vitis Base Platform is 256MB. But for some models, 256MB is not enough to allocate DPU instructions/parameters/data area. Unless it's clear that your 256MB is sufficient for your model, it's recommended to set cma=512M which could cover all Vitis-AI models.<br /> 
CPU IDLE would cause CPU IDLE when JTAG is connected. So it is recommended to disable the selection.<br /> 
    a) Type ```petalinux-config -c kernel```<br /> 
    b) Select ***Device Drivers > Generic Driver Options > DMA Contiguous Memory Allocator > Size in Mega Bytes***.<br />
    c) Press the ```Enter``` key and change 256 to 512.<br /> 
Ensure the following are ***TURNED OFF*** by entering 'n' in the [ ] menu selection for:<br />
       - ***CPU Power Mangement > CPU Idle > CPU idle PM support***<br />
       - ***CPU Power Management > CPU Frequency scaling > CPU Frequency scaling***<br />

16. Update the Device tree to include the zocl driver by appending the text below to the ***project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi*** file. 
```
&amba {
	zyxclmm_drm {
		compatible = "xlnx,zocl";
		status = "okay";
		interrupt-parent = <&axi_intc_0>;
		interrupts = <0  4>, <1  4>, <2  4>, <3  4>,
			     <4  4>, <5  4>, <6  4>, <7  4>,
			     <8  4>, <9  4>, <10 4>, <11 4>,
			     <12 4>, <13 4>, <14 4>, <15 4>,
			     <16 4>, <17 4>, <18 4>, <19 4>,
			     <20 4>, <21 4>, <22 4>, <23 4>,
			     <24 4>, <25 4>, <26 4>, <27 4>,
			     <28 4>, <29 4>, <30 4>, <31 4>;
	};
};

```

17. Modify the u-boot settings:<br />
Because we didn't use SD card to store the rootfs files. So that u-boot need to load a large image. We need to modify the u-boot so that it can load larger image.
Open ***project-spec/meta-user/recipes-bsp/u-boot/files/platform-top.h*** and modify:<br />

```
#define CONFIG_SYS_BOOTM_LEN 0xF000000
```
to<br />
```
#define CONFIG_SYS_BOOTM_LEN 0x80000000
#undef CONFIG_SYS_BOOTMAPSZ
```
18. From within the PetaLinux project (petalinux), type ```petalinux-build``` to build the project.<br />
19. Create a sysroot self-installer for the target Linux system:<br />
```
cd images/linux
petalinux-build --sdk
```
***Note: We would store all the necessary files for Vitis platform creation flow. Here we name it ```zcu102_dpu_pkg ```. Then we create a pfm folder inside.***<br />
20. Go back to ***<your_petalinux_dir>/images/linux*** and type ```./sdk.sh```, provide a full pathname to the output directory ***<full_pathname_to_zcu102_dpu_pkg>/pfm***(here in this example I use ***/home/wuxian/wu_project/vitis2019.2/vitis_custom_platform_flow/zcu102_dpu_pkg/pfm***) and confirm.<br />
21. After the PetaLinux build succeeds, the generated Linux software components are in the ***<your_petalinux_dir>/images/linux directory***. For our example, the ***images/linux*** directory contains the generated image and ELF files listed below. Copy these files to the ***zcu102_dpu_pkg/pfm/boot*** directory in preparation for running the Vitis platform creation flow:<br />
    - image.ub
    - zynqmp_fsbl.elf
    - pmufw.elf
    - bl31.elf
    - u-boot.elf

22. Add a BIF file (linux.bif) to the ***zcu102_dpu_pkg/pfm/boot*** directory with the contents shown below. The file names should match the contents of the boot directory. The Vitis tool expands these pathnames relative to the sw directory of the platform at v++ link time or when generating an SD card. However, if the bootgen command is used directly to create a BOOT.BIN file from a BIF file, full pathnames in the BIF are necessary. Bootgen does not expand the names between the <> symbols.<br />
```
/* linux */
 the_ROM_image:
 {
 	[fsbl_config] a53_x64
 	[bootloader] <zynqmp_fsbl.elf>
 	[pmufw_image] <pmufw.elf>
 	[destination_device=pl] <bitstream>
 	[destination_cpu=a53-0, exception_level=el-3, trustzone] <bl31.elf>
 	[destination_cpu=a53-0, exception_level=el-2] <u-boot.elf>
 }
```
***Note: Now we prepare the HW platform and SW platform, next we would create a Vitis Platform.***

## Create the Vitis Platform<br /><br />

1. Source ***<Vitis_Install_Directory>/settings64.sh***.<br />
2. Go to the ***zcu102_dpu_pkg*** folder you created: ```cd <full_pathname_to_zcu102_dpu_pkg>```.<br />
3. Launch Vitis by typing ```vits``` in the console.<br />
4. Select ***zcu102_dpu_pkg*** folder as workspace directory.<br />
![vitis_launch.png](/pic_for_readme/vitis_launch.png)<br /><br />
5. In the Vitis IDE, select ***File > New > Platform Project*** to create a platform project.<br />
6. In the Create New Platform Project dialog box, do the following:<br />
   a) Enter the project name. For this example, type ```zcu102_vai_custom```.<br />
   b) Leave the checkbox for the default location selected.<br />
   c) Click ***Next***.<br />
7. In the Platform Project dialog box, do the following:<br />
   a) Select ***Create from hardware specification (XSA)***.<br />
   b) Click ***Next***.<br />
8. In the Platform Project Specification dialog box, do the following:<br />
   a) Browse to the XSA file generated by the Vivado. In this case, it is located in ```vitis_custom_platform_flow/zcu102_custom_platform/xsa_gen/zcu102_custom_platform.xsa```.<br />
   b) Set the operating system to ***linux***.<br />
   c) Set the processor to ***psu_cortexa53***.<br />
   d) Leave the checkmark selected to generate boot components.<br />
   e) Click ***Finish***.<br />
9. In the Platform Settings view, observe the following:<br />
   - The name of the Platform Settings view matches the platform project name of ***zcu102_vai_custom***.<br />
   - A psu_cortexa53 device icon is shown, containing a Linux on psu_cortexa53 domain.<br />
   - A psu_cortexa53 device icon is shown, containing a zynqmp_fsbl BSP.<br />
   - A psu_pmu_0 device icon is shown, containing a zynqmp_pmu BSP.<br />
10. Click the linux on psu_cortexa53 domain, browse to the locations and select the directory or file needed to complete the dialog box for the following:
```
Linux Build Output:
    Browse to ***zcu102_dpu_pkg/pfm/boot*** and click OK.
Bif file:
    Browse to zcu102_dpu_pkg/pfm/boot/linux.bif file and click OK.

Image:
    Browse to zcu102_dpu_pkg/pfm/boot and click OK.

Sysroot:
    Browse to zcu102_dpu_pkg/pfm/sysroots/aarch64-xilinx-linux and click OK. 
```

