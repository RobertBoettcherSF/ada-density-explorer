with Interfaces;

--  Fixed-width exports. JavaScript passes binary64 inputs and reads binary64
--  outputs. Status 0 means the outputs are meaningful.
--
--  density_run (op, a, b, c, d) -> status
--  density_out (index)          -> value, index starting at 1
--  density_count                -> how many outputs the last run wrote
--
--  op 1  material density.  a = index.                 out1 = kg/m3
--  op 2  fluid density.     a = index.                 out1 = kg/m3
--  op 3  float tank.
--        a = material index, or 0 to use b as the mass in kg
--        b = mass kg (only when a = 0)
--        c = volume m3
--        d = fluid density kg/m3
--        out1 density   out2 fluid density   out3 mass kg   out4 volume m3
--        out5 weight N  out6 buoyant N       out7 apparent N
--        out8 submerged fraction (0 to 1)    out9 density ratio
--        out10 state (1 floats, 2 sinks, 3 level)
--        out11 displaced m3
--        out12 weight arrow share   out13 buoyant arrow share
--        out14 volume in litres     out15 submerged percent
--  op 4  pack the box. a = count, b = mass each kg, c = side m
--        out1 density  out2 total mass  out3 volume  out4 spacing m
--        out5 specific gravity  out6 count  out7 mass each  out8 side
--  op 5  every material at one volume. a = volume m3
--        out1..out8 masses kg, out9 cube side m
--  op 6  balance. a = left material, b = right material, c = volume m3
--        out1 mass left  out2 mass right  out3 tilt fraction
--        out4 tilt degrees (positive lowers the right-hand side)
--        out5 density left  out6 density right  out7 side m
--  op 7  one ladder rung, using the window from the last op 8.
--        a = index
--        out1 density  out2 log10 density  out3 fraction in the window
--  op 8  ladder. a = log10(density), b = decades visible
--        out1 density  out2 log10  out3 teaspoon kg
--        out4 anchor index  out5 how many of that anchor  out6 anchor mass
--        out7 window log min  out8 window log max  out9 marker 0..1
--        out10 nearest rung  out11 1 if snapped to a rung
--  op 9  mostly empty. a = zoom 0..1
--        out1 atom radius m     out2 nucleus radius m
--        out3 linear ratio      out4 volume fraction
--        out5 nuclear density   out6 water density   out7 density ratio
--        out8 Earth radius m    out9 compressed radius m
--        out10 Earth radius / compressed radius
--        out11 stage (1 object, 2 atoms, 3 nucleus)  out12 blend 0..1
--        out13 drawn nucleus radius / view width
--        out14 magnification    out15 electron-cloud radius in view widths
--        out16 Earth mass kg
--  op 10 imagine. a = area cm2, b = volume m3
--        out1 flux /cm2/s   out2 rate /s   out3 probability
--        out4 one-in        out5 cross section cm2   out6 column /cm2
--        out7 dark density kg/m3   out8 dark mass kg   out9 proton count
--        out10 dark mass / sand-grain mass
--        out11 volume m3  out12 volume mL  out13 volume L
--        out14 area cm2   out15 area m2
--  op 11 counts. out1 materials out2 fluids out3 rungs out4 anchors
--        out5 standard gravity
--  op 12 map a logarithmic slider. a = channel, b = slider 0..1000
--        out1 value. Channels: 1 fluid, 2 particle mass, 3 region volume, 4 area
--  op 13 inverse of op 12. a = channel, b = value. out1 slider 0..1000
--  op 14 anchor mass. a = index. out1 kg
package Density_Exports is

   function Density_Run
     (Op : Interfaces.Integer_32;
      A, B, C, D : Long_Float) return Interfaces.Integer_32
   with Export, Convention => C, External_Name => "density_run";

   function Density_Out (Index : Interfaces.Integer_32) return Long_Float
   with Export, Convention => C, External_Name => "density_out";

   function Density_Count return Interfaces.Integer_32
   with Export, Convention => C, External_Name => "density_count";

end Density_Exports;
