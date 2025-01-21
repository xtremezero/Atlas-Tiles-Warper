https://xtremezero.itch.io/atlas-tile-wrapper\
\
Atlas tile wrapper allows you to repeat tiles in a Atlas Texture in both direction (just like trim sheets)\
\
***WHY?***\
Reduce material setup time and baking multiple objects at once ,\
Reduce draw calls,\
smaller textures but better resolution after repetition.\


***How to use (Blender):***\
Create a material\
Import Atlas Textures and set them to (Closest)\
Add the NodeTree "Atlas Tile mapper" and adjust the parameters :\
Repeat = how many times will the texture repeat\
TileCountX= number of horizontal tiles\
TileCountY= number of Vertical tiles (Should equal TileCountX for now)\
Connect it as a UV vector to the textures\
Project UVs for each part in your model to the desired tile (Cube map preferred)\
Note: adjusting the scale in the UV map will reduce/increase the repetition\


***How to use (Godot):***\
Import Atlas Textures\
Create a shader material\
Add the "Atlas Tile wrapper" shader and adjust the parameters :\
AO Light Affect = Strength of the AO texture\
Emission Energy = Strength of Emission Texture\
Normal Scale = Bumpiness of the Normal Map texture\
UV1 Offset = offset to the texture (useful for Fluid/Water Atlas Textures)\
Tile Count = Number of tiles in the Atlas Texture (should be the same for now)\
Scale = Number of repetitions\
Albedo,Specular,Metalic,Roughness,Emission,Normal,AO = Atlas Textures\
Texture AO UV2 = use UV2 for a baked AO texture\
If you had artifacts Disable Filter and Mipmapping from import settings in the Atlas textures\
