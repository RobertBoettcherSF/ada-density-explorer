with Density;
with Interfaces;

package body Density_Exports is
   use type Interfaces.Integer_32;

   Max_Out : constant := 16;
   Outs : array (1 .. Max_Out) of Long_Float := (others => 0.0);
   Used : Integer := 0;

   procedure Reset is
   begin
      Outs := (others => 0.0);
      Used := 0;
   end Reset;

   procedure Put (Index : Integer; Value : Long_Float) is
   begin
      if Index in Outs'Range then
         Outs (Index) := Value;
         if Index > Used then
            Used := Index;
         end if;
      end if;
   end Put;

   function Index_Of (Value : Long_Float) return Integer is
   begin
      if Value < 0.5 or else Value > 100.0 then
         return 0;
      end if;
      return Integer (Value);
   end Index_Of;

   function State_Code (State : Density.Matter_State) return Long_Float is
   begin
      case State is
         when Density.Floats => return 1.0;
         when Density.Sinks => return 2.0;
         when Density.Level => return 3.0;
      end case;
   end State_Code;

   function Density_Run
     (Op : Interfaces.Integer_32;
      A, B, C, D : Long_Float) return Interfaces.Integer_32
   is
      Index : Integer;
      Sample : Density.Buoyancy;
      Packed : Density.Packing;
      Pair : Density.Balance;
      View : Density.Ladder_View;
      Rung : Density.Rung_Place;
      Space : Density.Emptiness;
      Dream : Density.Imagination;
      Density_Value : Long_Float;
   begin
      Reset;

      if Op = 1 then
         Density_Value := Density.Material_Density (Index_Of (A));
         if Density_Value <= 0.0 then
            return 1;
         end if;
         Put (1, Density_Value);
         return 0;
      elsif Op = 2 then
         Density_Value := Density.Fluid_Density (Index_Of (A));
         if Density_Value <= 0.0 then
            return 1;
         end if;
         Put (1, Density_Value);
         return 0;
      elsif Op = 3 then
         Index := Index_Of (A);
         if Index >= 1 then
            Density_Value := Density.Material_Density (Index);
            if Density_Value <= 0.0 or else C <= 0.0 then
               return 1;
            end if;
            Sample := Density.Float_Tank (Density_Value, C, D);
         else
            if B <= 0.0 or else C <= 0.0 then
               return 1;
            end if;
            Sample := Density.Float_Tank (B / C, C, D);
         end if;
         if not Sample.Valid then
            return 1;
         end if;
         Put (1, Sample.Density_Obj);
         Put (2, Sample.Density_Fluid);
         Put (3, Sample.Mass_Kg);
         Put (4, Sample.Volume_M3);
         Put (5, Sample.Weight_N);
         Put (6, Sample.Buoyant_N);
         Put (7, Sample.Apparent_N);
         Put (8, Sample.Submerged);
         Put (9, Sample.Ratio);
         Put (10, State_Code (Sample.State));
         Put (11, Sample.Displaced_M3);
         Put (12, Sample.Weight_Share);
         Put (13, Sample.Buoyant_Share);
         Put (14, Sample.Volume_L);
         Put (15, Sample.Submerged * 100.0);
         return 0;
      elsif Op = 4 then
         Packed := Density.Pack_Box (A, B, C);
         if not Packed.Valid then
            return 1;
         end if;
         Put (1, Packed.Density);
         Put (2, Packed.Total_Mass);
         Put (3, Packed.Volume_M3);
         Put (4, Packed.Spacing_M);
         Put (5, Packed.Specific_Gravity);
         Put (6, Packed.Count);
         Put (7, Packed.Mass_Each);
         Put (8, Packed.Side_M);
         return 0;
      elsif Op = 5 then
         if A <= 0.0 then
            return 1;
         end if;
         for I in 1 .. Density.Material_Count loop
            Put (I, Density.Cube_Mass (Density.Material_Density (I), A));
         end loop;
         Put (9, Density.Weigh_Pair
           (Density.Material_Density (1), Density.Material_Density (1), A).Side_M);
         return 0;
      elsif Op = 6 then
         Pair := Density.Weigh_Pair
           (Density.Material_Density (Index_Of (A)),
            Density.Material_Density (Index_Of (B)),
            C);
         if not Pair.Valid then
            return 1;
         end if;
         Put (1, Pair.Mass_Left);
         Put (2, Pair.Mass_Right);
         Put (3, Pair.Tilt_Fraction);
         Put (4, Pair.Tilt_Degrees);
         Put (5, Pair.Density_Left);
         Put (6, Pair.Density_Right);
         Put (7, Pair.Side_M);
         return 0;
      elsif Op = 7 then
         Rung := Density.Place_Rung (Index_Of (A));
         if not Rung.Valid then
            return 1;
         end if;
         Put (1, Rung.Density);
         Put (2, Rung.Log10_Density);
         Put (3, Rung.Fraction);
         return 0;
      elsif Op = 8 then
         View := Density.Place_On_Ladder (A, B);
         if not View.Valid then
            return 1;
         end if;
         Put (1, View.Density);
         Put (2, View.Log10_Density);
         Put (3, View.Teaspoon.Mass_Kg);
         Put (4, Long_Float (View.Teaspoon.Anchor));
         Put (5, View.Teaspoon.Count);
         Put (6, View.Teaspoon.Anchor_Mass);
         Put (7, View.Window_Min);
         Put (8, View.Window_Max);
         Put (9, View.Marker);
         Put (10, Long_Float (View.Nearest_Rung));
         if View.Snapped then
            Put (11, 1.0);
         else
            Put (11, 0.0);
         end if;
         return 0;
      elsif Op = 9 then
         Space := Density.Empty_Zoom (A);
         if not Space.Valid then
            return 1;
         end if;
         Put (1, Space.Atom_Radius_M);
         Put (2, Space.Nucleus_Radius_M);
         Put (3, Space.Linear_Ratio);
         Put (4, Space.Volume_Fraction);
         Put (5, Space.Nuclear_Density);
         Put (6, Space.Water_Density);
         Put (7, Space.Density_Ratio);
         Put (8, Space.Earth_Radius_M);
         Put (9, Space.Compressed_Radius_M);
         Put (10, Space.Radius_Ratio);
         Put (11, Long_Float (Space.Stage));
         Put (12, Space.Blend);
         Put (13, Space.Nucleus_Draw);
         Put (14, Space.Magnification);
         Put (15, Space.Cloud_Views);
         Put (16, Space.Earth_Mass_Kg);
         return 0;
      elsif Op = 10 then
         Dream := Density.Imagine (A, B);
         if not Dream.Valid then
            return 1;
         end if;
         Put (1, Dream.Flux_Per_Cm2_S);
         Put (2, Dream.Rate_Per_S);
         Put (3, Dream.Probability);
         Put (4, Dream.One_In);
         Put (5, Dream.Cross_Section_Cm2);
         Put (6, Dream.Column_Per_Cm2);
         Put (7, Dream.Dark_Density);
         Put (8, Dream.Dark_Mass_Kg);
         Put (9, Dream.Dark_Protons);
         Put (10, Dream.Dark_Sand_Fraction);
         Put (11, Dream.Volume_M3);
         Put (12, Dream.Volume_Ml);
         Put (13, Dream.Volume_L);
         Put (14, Dream.Area_Cm2);
         Put (15, Dream.Area_M2);
         return 0;
      elsif Op = 11 then
         Put (1, Long_Float (Density.Material_Count));
         Put (2, Long_Float (Density.Fluid_Count));
         Put (3, Long_Float (Density.Rung_Count));
         Put (4, Long_Float (Density.Anchor_Count));
         Put (5, Density.Gravity);
         return 0;
      elsif Op = 12 then
         Density_Value := Density.Map_Control (Index_Of (A), B);
         if Density_Value <= 0.0 then
            return 1;
         end if;
         Put (1, Density_Value);
         return 0;
      elsif Op = 13 then
         Put (1, Density.Unmap_Control (Index_Of (A), B));
         return 0;
      elsif Op = 14 then
         Density_Value := Density.Anchor_Mass (Index_Of (A));
         if Density_Value <= 0.0 then
            return 1;
         end if;
         Put (1, Density_Value);
         return 0;
      else
         return 2;
      end if;
   end Density_Run;

   function Density_Out (Index : Interfaces.Integer_32) return Long_Float is
   begin
      if Index < 1 or else Integer (Index) > Max_Out then
         return 0.0;
      end if;
      return Outs (Integer (Index));
   end Density_Out;

   function Density_Count return Interfaces.Integer_32 is
   begin
      return Interfaces.Integer_32 (Used);
   end Density_Count;

end Density_Exports;
