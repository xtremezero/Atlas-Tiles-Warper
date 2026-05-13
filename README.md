[![View on itch.io](https://img.shields.io/badge/View%20on-itch.io-FA5C5C?style=for-the-badge&logo=itch.io)](https://xtremezero.itch.io/atlas-tile-wrapper)
# Atlas Tile Wrapper

The **Atlas Tile Wrapper** is a utility designed to enable seamless texture repetition for individual tiles within a single atlas. Functioning similarly to trim sheets, it allows for two-way repetition of sub-textures while maintaining the memory efficiency of a unified texture sheet.

## Core Benefits
* **Performance Optimization:** Drastically reduces draw calls by utilizing a single material for multiple objects.
* **Visual Fidelity:** Leverages repetition to achieve high-resolution results from smaller source textures.
* **Efficiency:** Accelerates baking workflows and simplifies material management for complex environments.

---

## Implementation: Blender
1.  **Preparation:** Create a material and import your Atlas Textures. Set texture interpolation to **Closest**.
2.  **Node Setup:** Add the **Atlas Tile Mapper** NodeTree and connect it to the **UV Vector** input of your textures.
3.  **Parameters:**
    * **Repeat:** Adjusts the number of texture repetitions.
    * **Tile Count:** Sets the number of tiles in the Atlas.
4.  **UV Mapping:** Project your model’s UVs to the specific tile area (Cube Projection is recommended). 
    * *Note: Scaling the UV map directly will further increase or decrease repetition density.*

---

## Implementation: Godot
1.  **Asset Import:** Import Atlas Textures. If artifacts appear, disable **Filter** and **Mipmapping** in the import settings.
2.  **Shader Setup:** Create a **ShaderMaterial** and apply the **Atlas Tile Wrapper** shader.
3.  **Parameters:**
    * **Scale:** Determines the frequency of repetitions.
    * **Tile Count:** Sets the number of tiles in the Atlas.
    * **Maps:** Assign textures to the Albedo, Specular, Metallic, Roughness, Emission, Normal, and AO slots.
4.  **Refinement:**
    * Adjust **Normal Scale**, **Emission Energy**, and **AO Light Affect** as needed.
    * Enable **Texture AO UV2** to utilize a second UV channel for baked AO.
