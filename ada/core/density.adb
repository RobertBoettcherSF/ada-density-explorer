with Ada.Numerics.Long_Elementary_Functions;

package body Density is

   use Ada.Numerics.Long_Elementary_Functions;

   --  Conventional standard gravity, exact by definition of the constant
   --  used in ISO 80000 and the earlier CGPM conventional value.
   G : constant Long_Float := 9.80665;

   --  Preset solids, kg/m3, lightest first.
   --  Cork 240: typical composition cork; natural cork varies, often
   --  120 to 240. Pine 500: a typical softwood, species vary widely.
   --  Ice 917: ice Ih near 0 C is about 916.7 to 917, fixed here so that
   --  a block in conventional water is 91.7 percent submerged.
   --  Water 1000: the conventional teaching value. Real liquid water is
   --  999.97 kg/m3 near 4 C.
   --  Aluminium 2700, iron 7874, lead 11340, gold 19320: the usual
   --  room-temperature densities of the pure metals (CRC-style tables,
   --  2.70, 7.874, 11.34 and 19.32 g/cm3).
   Materials : constant array (1 .. 8) of Long_Float :=
     (240.0, 500.0, 917.0, 1_000.0, 2_700.0, 7_874.0, 11_340.0, 19_320.0);

   --  Preset fluids, kg/m3.
   --  Ethanol 789: ethanol near 20 C is 789.3, taken as 789.
   --  Oil 910: a typical olive oil; other oils differ.
   --  Fresh water 1000: the same conventional value as the water block.
   --  Sea water 1025: a representative surface-ocean value.
   --  Honey 1420: a typical honey; water content moves this.
   --  Mercury 13534: mercury near 25 C (13.534 g/cm3).
   Fluids : constant array (1 .. 6) of Long_Float :=
     (789.0, 910.0, 1_000.0, 1_025.0, 1_420.0, 13_534.0);

   --  Ladder rungs, kg/m3.
   --  Interstellar: about one hydrogen atom per cm3. The proton mass below
   --  times 1e6 atoms per m3. Real clouds differ by many orders.
   --  Air 1.225: International Standard Atmosphere, sea level.
   --  Rock 2700: typical granite, not a single mineral.
   --  Osmium 22590: 22.59 g/cm3, the densest stable element at room
   --  temperature.
   --  White dwarf 1e9: a representative order of magnitude. Sirius B is a
   --  few times 1e9.
   --  Neutron-star rung uses nuclear saturation density, about
   --  2.8e17 kg/m3 for 0.16 nucleons per fm3. A real neutron star averages
   --  a small multiple of that. Approximate.
   Proton_Mass : constant Long_Float := 1.6726219e-27;
   Interstellar : constant Long_Float := Proton_Mass * 1.0e6;
   Nuclear_Density : constant Long_Float := 2.8e17;

   function Rung_Table (Index : Integer) return Long_Float is
   begin
      case Index is
         when 1 => return Interstellar;
         when 2 => return 1.225;
         when 3 => return 1_000.0;
         when 4 => return 2_700.0;
         when 5 => return 11_340.0;
         when 6 => return 22_590.0;
         when 7 => return 1.0e9;
         when 8 => return Nuclear_Density;
         when others => return 0.0;
      end case;
   end Rung_Table;

   --  Masses used only for the teaspoon sentence. All of them except the
   --  proton, the bowling ball (16 lb), the Earth and the Sun are everyday
   --  round figures and are labelled approximate on the page.
   --  Earth mass 5.9722e24 kg. Earth volumetric mean radius 6371 km.
   --  Sun 1.9885e30 kg.
   --  Bowling ball 7.26 kg is the usual 16-pound ball.
   Anchors : constant array (1 .. 16) of Long_Float :=
     (Proton_Mass,
      1.0e-6,          -- grain of sand, 1 mg, coarse and approximate
      2.0e-5,          -- grain of rice, 20 mg
      1.0e-3,          -- paperclip, 1 g
      6.0e-2,          -- large egg, 60 g
      0.15,            -- apple, 150 g
      1.0,             -- litre of water, by the conventional density
      7.26,            -- bowling ball
      70.0,            -- adult person
      1_500.0,         -- small car
      6_000.0,         -- elephant
      1.4e5,           -- blue whale, 140 tonnes
      7.3e6,           -- Eiffel Tower, about 7300 tonnes
      5.75e9,          -- Great Pyramid, about 5.75 million tonnes
      5.9722e24,       -- Earth
      1.9885e30);      -- Sun

   --  Bohr radius, CODATA, metres. Proton rms charge radius 0.8414 fm,
   --  the CODATA 2018 scale. The atom has no hard edge; this pair is the
   --  Bohr-model comparison.
   Bohr_Radius : constant Long_Float := 5.29177210903e-11;
   Proton_Radius : constant Long_Float := 0.8414e-15;

   Earth_Mass : constant Long_Float := 5.9722e24;
   Earth_Radius : constant Long_Float := 6.371e6;

   --  Metric teaspoon, as asked: 5 mL.
   Teaspoon_M3 : constant Long_Float := 5.0e-6;

   --  Solar-neutrino flux at Earth, order of magnitude. The pp chain alone
   --  is about 6e10 /cm2/s in the standard solar model; 6.5e10 stands in
   --  for the total. Approximate.
   Neutrino_Flux : constant Long_Float := 6.5e10;

   --  A representative cross section for a solar-energy neutrino, cm2.
   --  Real cross sections depend strongly on energy and on the target.
   --  This is a sketch, not a measured constant for one reaction.
   Neutrino_Sigma_Cm2 : constant Long_Float := 1.0e-44;

   --  Local dark-matter density in the standard halo picture, 0.3 GeV/cm3.
   --  1 GeV/c2 = 1.78266192e-27 kg. Approximate; estimates cluster around
   --  0.3 to 0.4 GeV/cm3.
   GeV_Over_C2 : constant Long_Float := 1.78266192e-27;
   Dark_Kg_Per_M3 : constant Long_Float := 0.3 * GeV_Over_C2 * 1.0e6;

   --  How far a logarithmic slider may sit from a rung and still snap to
   --  that rung's exact density, in decades.
   Snap_Decades : constant Long_Float := 0.02;

   --  Visual tilt of the seesaw, degrees at a full imbalance.
   Max_Tilt : constant Long_Float := 22.0;

   function Log10 (X : Long_Float) return Long_Float is
   begin
      if X <= 0.0 then
         return 0.0;
      end if;
      return Log (X) / Log (10.0);
   end Log10;

   function Pow10 (X : Long_Float) return Long_Float is
   begin
      return Exp (X * Log (10.0));
   end Pow10;

   function Cube_Root (X : Long_Float) return Long_Float is
   begin
      if X <= 0.0 then
         return 0.0;
      end if;
      return Exp (Log (X) / 3.0);
   end Cube_Root;

   function Clamp01 (X : Long_Float) return Long_Float is
   begin
      if X < 0.0 then
         return 0.0;
      elsif X > 1.0 then
         return 1.0;
      else
         return X;
      end if;
   end Clamp01;

   function Material_Count return Integer is
   begin
      return Materials'Length;
   end Material_Count;

   function Fluid_Count return Integer is
   begin
      return Fluids'Length;
   end Fluid_Count;

   function Rung_Count return Integer is
   begin
      return 8;
   end Rung_Count;

   function Anchor_Count return Integer is
   begin
      return Anchors'Length;
   end Anchor_Count;

   function Material_Density (Index : Integer) return Long_Float is
   begin
      if Index in Materials'Range then
         return Materials (Index);
      end if;
      return 0.0;
   end Material_Density;

   function Fluid_Density (Index : Integer) return Long_Float is
   begin
      if Index in Fluids'Range then
         return Fluids (Index);
      end if;
      return 0.0;
   end Fluid_Density;

   function Rung_Density (Index : Integer) return Long_Float is
   begin
      return Rung_Table (Index);
   end Rung_Density;

   function Anchor_Mass (Index : Integer) return Long_Float is
   begin
      if Index in Anchors'Range then
         return Anchors (Index);
      end if;
      return 0.0;
   end Anchor_Mass;

   function Gravity return Long_Float is
   begin
      return G;
   end Gravity;

   function Float_Tank
     (Object_Density, Volume_M3, Fluid_Density : Long_Float) return Buoyancy
   is
      Result : Buoyancy;
      Mass : Long_Float;
      Longer : Long_Float;
   begin
      if Object_Density <= 0.0
        or else Volume_M3 <= 0.0
        or else Fluid_Density <= 0.0
      then
         return Result;
      end if;

      Mass := Object_Density * Volume_M3;
      Result.Density_Obj := Object_Density;
      Result.Density_Fluid := Fluid_Density;
      Result.Mass_Kg := Mass;
      Result.Volume_M3 := Volume_M3;
      Result.Volume_L := Volume_M3 * 1_000.0;
      Result.Weight_N := Mass * G;
      Result.Ratio := Object_Density / Fluid_Density;

      --  Equal densities within a hair of binary noise count as level.
      if abs (Object_Density - Fluid_Density) <= 1.0e-9 * Fluid_Density then
         Result.State := Level;
         Result.Submerged := 1.0;
         Result.Displaced_M3 := Volume_M3;
         Result.Buoyant_N := Result.Weight_N;
         Result.Apparent_N := 0.0;
      elsif Object_Density < Fluid_Density then
         Result.State := Floats;
         Result.Submerged := Result.Ratio;
         Result.Displaced_M3 := Volume_M3 * Result.Ratio;
         Result.Buoyant_N := Fluid_Density * Result.Displaced_M3 * G;
         Result.Apparent_N := 0.0;
      else
         Result.State := Sinks;
         Result.Submerged := 1.0;
         Result.Displaced_M3 := Volume_M3;
         Result.Buoyant_N := Fluid_Density * Volume_M3 * G;
         Result.Apparent_N := Result.Weight_N - Result.Buoyant_N;
         if Result.Apparent_N < 0.0 then
            Result.Apparent_N := 0.0;
         end if;
      end if;

      Longer := Result.Weight_N;
      if Result.Buoyant_N > Longer then
         Longer := Result.Buoyant_N;
      end if;
      if Longer > 0.0 then
         Result.Weight_Share := Result.Weight_N / Longer;
         Result.Buoyant_Share := Result.Buoyant_N / Longer;
      end if;
      Result.Valid := True;
      return Result;
   end Float_Tank;

   function Pack_Box
     (Count, Mass_Each_Kg, Side_M : Long_Float) return Packing
   is
      Result : Packing;
      Volume : Long_Float;
   begin
      if Count < 1.0 or else Mass_Each_Kg <= 0.0 or else Side_M <= 0.0 then
         return Result;
      end if;
      Volume := Side_M * Side_M * Side_M;
      Result.Count := Count;
      Result.Mass_Each := Mass_Each_Kg;
      Result.Side_M := Side_M;
      Result.Volume_M3 := Volume;
      Result.Total_Mass := Count * Mass_Each_Kg;
      Result.Density := Result.Total_Mass / Volume;
      Result.Spacing_M := Side_M / Cube_Root (Count);
      Result.Specific_Gravity := Result.Density / 1_000.0;
      Result.Valid := True;
      return Result;
   end Pack_Box;

   function Cube_Mass (Density, Volume_M3 : Long_Float) return Long_Float is
   begin
      if Density <= 0.0 or else Volume_M3 <= 0.0 then
         return 0.0;
      end if;
      return Density * Volume_M3;
   end Cube_Mass;

   function Weigh_Pair
     (Density_Left, Density_Right, Volume_M3 : Long_Float) return Balance
   is
      Result : Balance;
      Sum : Long_Float;
   begin
      if Density_Left <= 0.0
        or else Density_Right <= 0.0
        or else Volume_M3 <= 0.0
      then
         return Result;
      end if;
      Result.Density_Left := Density_Left;
      Result.Density_Right := Density_Right;
      Result.Volume_M3 := Volume_M3;
      Result.Mass_Left := Density_Left * Volume_M3;
      Result.Mass_Right := Density_Right * Volume_M3;
      Result.Side_M := Cube_Root (Volume_M3);
      Sum := Result.Mass_Left + Result.Mass_Right;
      if Sum > 0.0 then
         Result.Tilt_Fraction :=
           (Result.Mass_Right - Result.Mass_Left) / Sum;
      end if;
      Result.Tilt_Degrees := Result.Tilt_Fraction * Max_Tilt;
      Result.Valid := True;
      return Result;
   end Weigh_Pair;

   function Teaspoon_Of (Density : Long_Float) return Comparison is
      Result : Comparison;
      Mass : Long_Float;
      Best : Integer := 1;
      Best_Score : Long_Float := 1.0e30;
      Ratio : Long_Float;
      Score : Long_Float;
   begin
      if Density <= 0.0 then
         return Result;
      end if;
      Mass := Density * Teaspoon_M3;
      Result.Mass_Kg := Mass;
      --  The anchor whose mass is closest to the teaspoon, on a log scale,
      --  so the sentence lands near "about one" of something familiar.
      for I in Anchors'Range loop
         if Anchors (I) > 0.0 then
            Ratio := Mass / Anchors (I);
            if Ratio > 0.0 then
               Score := abs (Log (Ratio));
               if Score < Best_Score then
                  Best_Score := Score;
                  Best := I;
               end if;
            end if;
         end if;
      end loop;
      Result.Anchor := Best;
      Result.Anchor_Mass := Anchors (Best);
      Result.Count := Mass / Anchors (Best);
      Result.Valid := True;
      return Result;
   end Teaspoon_Of;

   Window_Min : Long_Float := -22.0;
   Window_Max : Long_Float := 18.0;

   procedure Set_Window (Center, Decades : Long_Float) is
      Full_Min : constant Long_Float := Log10 (Rung_Table (1)) - 0.35;
      Full_Max : constant Long_Float := Log10 (Rung_Table (8)) + 0.35;
      Half : Long_Float;
      Span : Long_Float;
   begin
      Span := Full_Max - Full_Min;
      if Decades <= 0.0 or else Decades >= Span then
         Window_Min := Full_Min;
         Window_Max := Full_Max;
         return;
      end if;
      Half := Decades / 2.0;
      Window_Min := Center - Half;
      Window_Max := Center + Half;
      if Window_Min < Full_Min then
         Window_Min := Full_Min;
         Window_Max := Full_Min + Decades;
      end if;
      if Window_Max > Full_Max then
         Window_Max := Full_Max;
         Window_Min := Full_Max - Decades;
      end if;
      if Window_Min < Full_Min then
         Window_Min := Full_Min;
      end if;
   end Set_Window;

   function Place_On_Ladder
     (Log10_Density, Decades : Long_Float) return Ladder_View
   is
      Result : Ladder_View;
      Nearest : Integer := 1;
      Nearest_Dist : Long_Float := 1.0e30;
      Dist : Long_Float;
      Log_R : Long_Float;
      Density : Long_Float;
      Span : Long_Float;
   begin
      for I in 1 .. Rung_Count loop
         Log_R := Log10 (Rung_Table (I));
         Dist := abs (Log_R - Log10_Density);
         if Dist < Nearest_Dist then
            Nearest_Dist := Dist;
            Nearest := I;
         end if;
      end loop;
      Result.Nearest_Rung := Nearest;
      if Nearest_Dist <= Snap_Decades then
         Density := Rung_Table (Nearest);
         Result.Snapped := True;
      else
         Density := Pow10 (Log10_Density);
         Result.Snapped := False;
      end if;
      Result.Density := Density;
      Result.Log10_Density := Log10 (Density);
      Result.Teaspoon := Teaspoon_Of (Density);
      Set_Window (Result.Log10_Density, Decades);
      Result.Window_Min := Window_Min;
      Result.Window_Max := Window_Max;
      Span := Window_Max - Window_Min;
      if Span > 0.0 then
         Result.Marker :=
           Clamp01 ((Result.Log10_Density - Window_Min) / Span);
      end if;
      Result.Valid := Result.Teaspoon.Valid;
      return Result;
   end Place_On_Ladder;

   function Place_Rung (Index : Integer) return Rung_Place is
      Result : Rung_Place;
      Span : Long_Float;
   begin
      if Rung_Table (Index) <= 0.0 then
         return Result;
      end if;
      Result.Density := Rung_Table (Index);
      Result.Log10_Density := Log10 (Result.Density);
      Span := Window_Max - Window_Min;
      if Span > 0.0 then
         Result.Fraction :=
           (Result.Log10_Density - Window_Min) / Span;
      end if;
      Result.Valid := True;
      return Result;
   end Place_Rung;

   function Empty_Zoom (Zoom : Long_Float) return Emptiness is
      Result : Emptiness;
      Z : Long_Float;
      Linear : Long_Float;
      Volume_Ratio : Long_Float;
      Compressed_Volume : Long_Float;
      Stage_Pos : Long_Float;
      --  Nucleus radius as a fraction of the view width when fully magnified
      --  so that a person can see it. The true ratio is far smaller.
      Drawn_Full : constant Long_Float := 0.11;
      True_Draw : Long_Float;
   begin
      Z := Clamp01 (Zoom);
      Linear := Proton_Radius / Bohr_Radius;
      Volume_Ratio := Linear * Linear * Linear;
      Result.Atom_Radius_M := Bohr_Radius;
      Result.Nucleus_Radius_M := Proton_Radius;
      Result.Linear_Ratio := Linear;
      Result.Volume_Fraction := Volume_Ratio;
      Result.Nuclear_Density := Nuclear_Density;
      Result.Water_Density := 1_000.0;
      Result.Density_Ratio := Nuclear_Density / 1_000.0;
      Result.Earth_Mass_Kg := Earth_Mass;
      Result.Earth_Radius_M := Earth_Radius;
      if Nuclear_Density > 0.0 then
         Compressed_Volume := Earth_Mass / Nuclear_Density;
         Result.Compressed_Radius_M := Cube_Root
           (3.0 * Compressed_Volume / (4.0 * Ada.Numerics.Pi));
      end if;
      if Result.Compressed_Radius_M > 0.0 then
         Result.Radius_Ratio := Earth_Radius / Result.Compressed_Radius_M;
      end if;

      if Z < 1.0 / 3.0 then
         Result.Stage := 1;
         Result.Blend := Z / (1.0 / 3.0);
      elsif Z < 2.0 / 3.0 then
         Result.Stage := 2;
         Result.Blend := (Z - 1.0 / 3.0) / (1.0 / 3.0);
      else
         Result.Stage := 3;
         Result.Blend := (Z - 2.0 / 3.0) / (1.0 / 3.0);
      end if;

      --  At the start of the nucleus stage the dot is the true fraction of
      --  an atom that fills about 0.42 of the view width (radius 0.21).
      True_Draw := 0.21 * Linear;
      Stage_Pos := 0.0;
      if Result.Stage = 3 then
         Stage_Pos := Result.Blend;
      end if;
      Result.Nucleus_Draw :=
        True_Draw + (Drawn_Full - True_Draw) * Stage_Pos;
      if True_Draw > 0.0 then
         Result.Magnification := Result.Nucleus_Draw / True_Draw;
      end if;
      --  Atom radius in view-widths once the nucleus has been enlarged.
      Result.Cloud_Views := 0.21 * Result.Magnification;
      Result.Valid := True;
      return Result;
   end Empty_Zoom;

   function Imagine
     (Area_Cm2, Volume_M3 : Long_Float) return Imagination
   is
      Result : Imagination;
      Area : Long_Float;
      Volume : Long_Float;
      --  Column of nucleons through an Earth diameter.
      Diameter : constant Long_Float := 2.0 * Earth_Radius;
      Earth_Volume : Long_Float;
      Mean_Density : Long_Float;
      Column_Kg_M2 : Long_Float;
      Nucleons_Per_M2 : Long_Float;
      Nucleons_Per_Cm2 : Long_Float;
      Sigma_M2 : Long_Float;
      Tau : Long_Float;
   begin
      if Area_Cm2 <= 0.0 or else Volume_M3 <= 0.0 then
         return Result;
      end if;
      Area := Area_Cm2;
      Volume := Volume_M3;
      Result.Area_Cm2 := Area;
      Result.Area_M2 := Area * 1.0e-4;
      Result.Flux_Per_Cm2_S := Neutrino_Flux;
      Result.Rate_Per_S := Neutrino_Flux * Area;
      Result.Cross_Section_Cm2 := Neutrino_Sigma_Cm2;

      Earth_Volume :=
        4.0 * Ada.Numerics.Pi * Earth_Radius * Earth_Radius * Earth_Radius
        / 3.0;
      Mean_Density := Earth_Mass / Earth_Volume;
      Column_Kg_M2 := Mean_Density * Diameter;
      Nucleons_Per_M2 := Column_Kg_M2 / Proton_Mass;
      Nucleons_Per_Cm2 := Nucleons_Per_M2 / 1.0e4;
      Result.Column_Per_Cm2 := Nucleons_Per_Cm2;
      Sigma_M2 := Neutrino_Sigma_Cm2 * 1.0e-4;
      Tau := Nucleons_Per_M2 * Sigma_M2;
      --  For this tiny optical depth, 1 - exp(-tau) and tau agree far past
      --  the digits we show. Use tau and say so in the page copy.
      if Tau < 0.0 then
         Tau := 0.0;
      end if;
      Result.Probability := Tau;
      if Tau > 0.0 then
         Result.One_In := 1.0 / Tau;
      end if;

      Result.Dark_Density := Dark_Kg_Per_M3;
      Result.Volume_M3 := Volume;
      Result.Volume_Ml := Volume * 1.0e6;
      Result.Volume_L := Volume * 1_000.0;
      Result.Dark_Mass_Kg := Dark_Kg_Per_M3 * Volume;
      if Proton_Mass > 0.0 then
         Result.Dark_Protons := Result.Dark_Mass_Kg / Proton_Mass;
      end if;
      if Anchors (2) > 0.0 then
         Result.Dark_Sand_Fraction := Result.Dark_Mass_Kg / Anchors (2);
      end if;
      Result.Valid := True;
      return Result;
   end Imagine;

   procedure Control_Ends
     (Channel : Integer; Lo, Hi : out Long_Float; Known : out Boolean)
   is
   begin
      Known := True;
      case Channel is
         when 1 =>
            Lo := 700.0;
            Hi := 14_000.0;
         when 2 =>
            Lo := 0.05;
            Hi := 5.0;
         when 3 =>
            Lo := 1.0e-5;
            Hi := 30.0;
         when 4 =>
            Lo := 1.0;
            Hi := 10_000.0;
         when others =>
            Lo := 1.0;
            Hi := 10.0;
            Known := False;
      end case;
   end Control_Ends;

   function Map_Control (Channel : Integer; Slider : Long_Float) return Long_Float
   is
      Lo, Hi : Long_Float;
      Known : Boolean;
      T : Long_Float;
   begin
      Control_Ends (Channel, Lo, Hi, Known);
      if not Known or else Lo <= 0.0 or else Hi <= Lo then
         return 0.0;
      end if;
      T := Slider / 1_000.0;
      T := Clamp01 (T);
      return Exp (Log (Lo) + T * (Log (Hi) - Log (Lo)));
   end Map_Control;

   function Unmap_Control (Channel : Integer; Value : Long_Float) return Long_Float
   is
      Lo, Hi : Long_Float;
      Known : Boolean;
      T : Long_Float;
   begin
      Control_Ends (Channel, Lo, Hi, Known);
      if not Known or else Value <= 0.0 or else Lo <= 0.0 or else Hi <= Lo then
         return 0.0;
      end if;
      T := (Log (Value) - Log (Lo)) / (Log (Hi) - Log (Lo));
      return Clamp01 (T) * 1_000.0;
   end Unmap_Control;

begin
   --  Open on the full ladder, centred on water, until the page asks again.
   Set_Window (3.0, 100.0);
end Density;
