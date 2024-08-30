import dearpygui.dearpygui as dpg

dpg.create_context()

with dpg.window(label="Example Window"):
    dpg.add_text("Hello, world")
    dpg.add_button(label="Save")
    dpg.add_input_text(label="string", default_value="Quick brown fox")
    dpg.add_slider_float(label="float", default_value=0.273, max_value=1)


dpg.create_viewport(title='Custom Title', width=1280, height=720)
dpg.setup_dearpygui()
dpg.show_viewport()

while dpg.is_dearpygui_running():
    #print("this will run every frame")
    dpg.render_dearpygui_frame()


dpg.destroy_context()