--  Density calculations for the browser explorer.
--  Every numeric result the page shows comes from this package.
--  Constants are the values the program actually uses. Where a figure is a
--  convention or an order of magnitude, the comment says so.
package Density is

   type Matter_State is (Floats, Sinks, Level);

   type Buoyancy is record
      Density_Obj     : Long_Float := 0.0;
      Density_Fluid   : Long_Float := 0.0;
      Mass_Kg         : Long_Float := 0.0;
      Volume_M3       : Long_Float := 0.0;
      Volume_L        : Long_Float := 0.0;
      Weight_N        : Long_Float := 0.0;
      Buoyant_N       : Long_Float := 0.0;
      Apparent_N      : Long_Float := 0.0;
      --  Share of the longer arrow, so a drawing can scale without dividing.
      Weight_Share    : Long_Float := 0.0;
      Buoyant_Share   : Long_Float := 0.0;
      --  Fraction of the block under the surface once it has settled. 1.0 if
      --  it rests on the bottom.
      Submerged       : Long_Float := 0.0;
      --  rho_object / rho_fluid, which may be greater than 1.
      Ratio           : Long_Float := 0.0;
      Displaced_M3    : Long_Float := 0.0;
      State           : Matter_State := Sinks;
      Valid           : Boolean := False;
   end record;

   type Packing is record
      Density         : Long_Float := 0.0;
      Total_Mass      : Long_Float := 0.0;
      Volume_M3       : Long_Float := 0.0;
      Spacing_M       : Long_Float := 0.0;
      Specific_Gravity : Long_Float := 0.0;
      Count           : Long_Float := 0.0;
      Mass_Each       : Long_Float := 0.0;
      Side_M          : Long_Float := 0.0;
      Valid           : Boolean := False;
   end record;

   type Balance is record
      Mass_Left       : Long_Float := 0.0;
      Mass_Right      : Long_Float := 0.0;
      Density_Left    : Long_Float := 0.0;
      Density_Right   : Long_Float := 0.0;
      --  Positive when the right-hand mass is heavier (that end goes down).
      Tilt_Fraction   : Long_Float := 0.0;
      Tilt_Degrees    : Long_Float := 0.0;
      Side_M          : Long_Float := 0.0;
      Volume_M3       : Long_Float := 0.0;
      Valid           : Boolean := False;
   end record;

   type Comparison is record
      Mass_Kg         : Long_Float := 0.0;
      Anchor          : Integer := 1;
      Anchor_Mass     : Long_Float := 0.0;
      Count           : Long_Float := 0.0;
      Valid           : Boolean := False;
   end record;

   type Ladder_View is record
      Density         : Long_Float := 0.0;
      Log10_Density   : Long_Float := 0.0;
      Teaspoon        : Comparison := (others => <>);
      Window_Min      : Long_Float := 0.0;
      Window_Max      : Long_Float := 0.0;
      Marker          : Long_Float := 0.0;
      Nearest_Rung    : Integer := 1;
      Snapped         : Boolean := False;
      Valid           : Boolean := False;
   end record;

   type Rung_Place is record
      Density         : Long_Float := 0.0;
      Log10_Density   : Long_Float := 0.0;
      --  0 at the bottom of the current window, 1 at the top.
      --  Outside that range the rung is off the current zoom.
      Fraction        : Long_Float := 0.0;
      Valid           : Boolean := False;
   end record;

   type Emptiness is record
      Atom_Radius_M       : Long_Float := 0.0;
      Nucleus_Radius_M    : Long_Float := 0.0;
      Linear_Ratio        : Long_Float := 0.0;
      Volume_Fraction     : Long_Float := 0.0;
      Nuclear_Density     : Long_Float := 0.0;
      Water_Density       : Long_Float := 0.0;
      Density_Ratio       : Long_Float := 0.0;
      Earth_Mass_Kg       : Long_Float := 0.0;
      Earth_Radius_M      : Long_Float := 0.0;
      Compressed_Radius_M : Long_Float := 0.0;
      Radius_Ratio        : Long_Float := 0.0;
      --  1 object, 2 atoms, 3 nucleus. Blend is 0..1 inside that stage.
      Stage               : Integer := 1;
      Blend               : Long_Float := 0.0;
      --  Drawn nucleus radius as a fraction of the view width.
      Nucleus_Draw        : Long_Float := 0.0;
      Magnification       : Long_Float := 1.0;
      --  If the nucleus is drawn at Nucleus_Draw, how many view-widths the
      --  Bohr radius would reach.
      Cloud_Views         : Long_Float := 1.0;
      Valid               : Boolean := False;
   end record;

   type Imagination is record
      Flux_Per_Cm2_S      : Long_Float := 0.0;
      Rate_Per_S          : Long_Float := 0.0;
      Probability         : Long_Float := 0.0;
      One_In              : Long_Float := 0.0;
      Cross_Section_Cm2   : Long_Float := 0.0;
      Column_Per_Cm2      : Long_Float := 0.0;
      Dark_Density        : Long_Float := 0.0;
      Dark_Mass_Kg        : Long_Float := 0.0;
      Dark_Protons        : Long_Float := 0.0;
      Dark_Sand_Fraction  : Long_Float := 0.0;
      Volume_M3           : Long_Float := 0.0;
      Volume_Ml           : Long_Float := 0.0;
      Volume_L            : Long_Float := 0.0;
      Area_Cm2            : Long_Float := 0.0;
      Area_M2             : Long_Float := 0.0;
      Valid               : Boolean := False;
   end record;

   function Material_Count return Integer;
   function Fluid_Count return Integer;
   function Rung_Count return Integer;
   function Anchor_Count return Integer;

   --  Index is 1-based. Returns 0.0 when the index is not a preset.
   function Material_Density (Index : Integer) return Long_Float;
   function Fluid_Density (Index : Integer) return Long_Float;
   function Rung_Density (Index : Integer) return Long_Float;
   function Anchor_Mass (Index : Integer) return Long_Float;

   function Gravity return Long_Float;

   function Float_Tank
     (Object_Density, Volume_M3, Fluid_Density : Long_Float) return Buoyancy;

   function Pack_Box
     (Count, Mass_Each_Kg, Side_M : Long_Float) return Packing;

   function Cube_Mass (Density, Volume_M3 : Long_Float) return Long_Float;

   function Weigh_Pair
     (Density_Left, Density_Right, Volume_M3 : Long_Float) return Balance;

   function Teaspoon_Of (Density : Long_Float) return Comparison;

   function Place_On_Ladder
     (Log10_Density, Decades : Long_Float) return Ladder_View;

   function Place_Rung (Index : Integer) return Rung_Place;

   function Empty_Zoom (Zoom : Long_Float) return Emptiness;

   function Imagine
     (Area_Cm2, Volume_M3 : Long_Float) return Imagination;

   --  Logarithmic controls. Slider is 0 .. 1000.
   --  1 fluid density (kg/m3), 2 particle mass (kg),
   --  3 dark-matter region (m3), 4 neutrino area (cm2).
   function Map_Control (Channel : Integer; Slider : Long_Float) return Long_Float;
   function Unmap_Control (Channel : Integer; Value : Long_Float) return Long_Float;

end Density;
