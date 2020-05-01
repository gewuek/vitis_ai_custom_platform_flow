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
