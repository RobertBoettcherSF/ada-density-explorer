with Ada.Command_Line;
with Ada.Text_IO;
with Density;

procedure Density_Smoke is
   use type Density.Matter_State;
   Ok : Boolean := True;

   procedure Check (Name : String; Cond : Boolean) is
   begin
      if Cond then
         Ada.Text_IO.Put_Line ("PASS " & Name);
      else
         Ada.Text_IO.Put_Line ("FAIL " & Name);
         Ok := False;
      end if;
   end Check;

   function Near (Left, Right, Tol : Long_Float) return Boolean is
   begin
      return abs (Left - Right) <= Tol;
   end Near;

   Ice : constant Long_Float := Density.Material_Density (3);
   Water : constant Long_Float := Density.Material_Density (4);
   Ethanol : constant Long_Float := Density.Fluid_Density (1);
   Fresh : constant Long_Float := Density.Fluid_Density (3);
   Sea : constant Long_Float := Density.Fluid_Density (4);
   Mercury : constant Long_Float := Density.Fluid_Density (6);
   Iron : constant Long_Float := Density.Material_Density (6);
   Floating : Density.Buoyancy;
   Sunk : Density.Buoyancy;
   Level : Density.Buoyancy;
   Iron_Hg : Density.Buoyancy;
   Packed : Density.Packing;
   Spoon : Density.Comparison;
   Space : Density.Emptiness;
   Pair : Density.Balance;
begin
   Check ("eight materials", Density.Material_Count = 8);
   Check ("six fluids", Density.Fluid_Count = 6);
   Check ("water is 1000", Water = 1_000.0);
   Check ("ice is 917", Ice = 917.0);
   Check ("ethanol is 789", Ethanol = 789.0);
   Check ("fresh water fluid is 1000", Fresh = 1_000.0);
   Check ("sea water is 1025", Sea = 1_025.0);
   Check ("mercury is 13534", Mercury = 13_534.0);

   Floating := Density.Float_Tank (Ice, 0.001, Water);
   Check ("ice in water is valid", Floating.Valid);
   Check ("ice floats in water", Floating.State = Density.Floats);
   Check ("ice is 91.7 percent submerged",
     Near (Floating.Submerged, 0.917, 1.0e-12));
   Check ("floating buoyancy matches weight",
     Near (Floating.Buoyant_N, Floating.Weight_N, 1.0e-6));
   Check ("floating apparent weight is zero",
     Near (Floating.Apparent_N, 0.0, 1.0e-12));
   Check ("ice mass of 1 litre is 0.917 kg",
     Near (Floating.Mass_Kg, 0.917, 1.0e-12));

   Sunk := Density.Float_Tank (Ice, 0.001, Ethanol);
   Check ("ice in ethanol is valid", Sunk.Valid);
   Check ("ice sinks in ethanol", Sunk.State = Density.Sinks);
   Check ("sunk block is fully under", Near (Sunk.Submerged, 1.0, 1.0e-12));
   Check ("sunk apparent weight is positive", Sunk.Apparent_N > 0.0);
   Check ("ethanol buoyancy is less than weight", Sunk.Buoyant_N < Sunk.Weight_N);

   Level := Density.Float_Tank (Water, 0.002, Fresh);
   Check ("water in water is level", Level.State = Density.Level);

   Iron_Hg := Density.Float_Tank (Iron, 0.001, Mercury);
   Check ("iron floats in mercury", Iron_Hg.State = Density.Floats);

   Packed := Density.Pack_Box (8.0, 2.0, 1.0);
   Check ("eight particles of 2 kg in 1 m3 are 16 kg/m3",
     Near (Packed.Density, 16.0, 1.0e-9));
   Check ("those eight are spaced 0.5 m", Near (Packed.Spacing_M, 0.5, 1.0e-9));

   Pair := Density.Weigh_Pair (500.0, 500.0, 0.001);
   Check ("equal cubes do not tilt", Near (Pair.Tilt_Degrees, 0.0, 1.0e-12));
   Pair := Density.Weigh_Pair (500.0, 19_320.0, 0.001);
   Check ("gold side drops", Pair.Tilt_Degrees > 0.0);
   Check ("gold mass is density times volume",
     Near (Pair.Mass_Right, 19.32, 1.0e-9));

   Spoon := Density.Teaspoon_Of (1_000.0);
   Check ("teaspoon of water is 0.005 kg", Near (Spoon.Mass_Kg, 0.005, 1.0e-9));
   Check ("teaspoon of water matches paperclips", Spoon.Anchor = 4);

   Spoon := Density.Teaspoon_Of (Density.Rung_Density (1));
   Check ("interstellar teaspoon is a few protons", Spoon.Anchor = 1);
   Check ("about five protons", Near (Spoon.Count, 5.0, 1.0e-6));

   Spoon := Density.Teaspoon_Of (Density.Rung_Density (7));
   Check ("white-dwarf teaspoon is near an elephant", Spoon.Anchor = 11);

   Space := Density.Empty_Zoom (0.0);
   Check ("nucleus is a tiny fraction of the atom",
     Space.Volume_Fraction > 1.0e-16 and then Space.Volume_Fraction < 1.0e-13);
   Check ("Earth at nuclear density is a few hundred metres across",
     Space.Compressed_Radius_M > 100.0 and then Space.Compressed_Radius_M < 400.0);
   Check ("nuclear density is the stated 2.8e17",
     Space.Nuclear_Density = 2.8e17);

   Check ("slider round trip",
     Near (Density.Unmap_Control (4, Density.Map_Control (4, 250.0)), 250.0, 1.0e-6));

   if not Ok then
      Ada.Text_IO.Put_Line ("SMOKE FAILED");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   else
      Ada.Text_IO.Put_Line ("SMOKE PASSED");
   end if;
end Density_Smoke;
