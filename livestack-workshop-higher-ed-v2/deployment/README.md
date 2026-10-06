# Seer Higher Education workshop data setup

The SQLcl loader is `load_seer_higher_ed.sql`. It follows the LiveStack ADMIN-to-LLUSER contract:

1. Platform setup provisions `LLUSER` and its login. The schema may contain other workshops, provided none of the Higher Education target objects or spatial metadata already exists.
2. `ADMIN.ALL_MINILM_L12_V2` is loaded and valid. The model returns 384-dimensional embeddings.
3. An enabled `GENAI` Select AI profile is configured for `LLUSER`. The loader narrows its object list to three aggregate views; Lab 7 reapplies and inspects that boundary.
4. Connect to the target ADB as `ADMIN` in SQLcl and run:

   ```text
   @load_seer_higher_ed.sql <lluser-password> <service-alias>
   ```

The loader grants the database capabilities used by the labs, connects as `LLUSER`, checks that Higher Education target object names and spatial metadata are unused, and creates the Higher Education data, views, request duality view, signal vectors, property graph, spatial metadata, and spatial indexes. It restricts the existing AI profile to aggregate views and checks the seeded lab prerequisites before reporting success. It does not drop existing objects. Run it once for an unused Higher Education namespace. Its `GENAI` object-list update will replace the prior allow-list for that profile, so other Select AI workshops using the same profile may need their allow-list restored afterward.

Labs 2, 3, 6, and 8 create their own exercise objects. The loader does not pre-create those objects. Lab 7 uses the platform-provided `GENAI` profile; model-backed Select AI calls require a working OCI AI service endpoint and credentials in the target environment.
