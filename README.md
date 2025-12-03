# MATLAB-code-for-Onlab-Belavari-Botond-
# Kolónia-sugár mérő MATLAB szkript

Ez a szkript 2D képeken (pl. agar lemezeken növő sejtkolóniák) mér sugárértékeket úgy, hogy  
a felhasználó kijelöli a vizsgálandó területet, majd a kolóniák közepeit.  
A kód ezután automatikusan megkeresi az adott középpontokhoz tartozó **legtávolabbi fehér pixelt**,  
és kiszámolja a sugarakat.

## Fő funkciók

- Tetszőleges kép megnyitása (színes vagy grayscale).
- Interaktív téglalap kijelölés a vizsgálandó régióra.
- Interaktív középpont-kijelölés több kolóniához.
- Képfeldolgozási lépések:
  - Top-hat szűrés az egyenetlen háttér javításához.
  - Adaptív küszöbölés.
  - Morfológiai műveletek: zárás, lyukkitöltés, zajszűrés, szegélytárgyak eltávolítása.
- A középpontokhoz tartozó bináris komponens kiválasztása egy kör alakú ROI-n belül.
- Az adott komponensen belül a középponttól **legtávolabbi fehér pixel** megtalálása.
  - Több azonos távolságú pont esetén figyelmeztetést ír ki.
- Eredmények kiírása és vizuális megjelenítése.

## Követelmények

- MATLAB (ajánlott az Image Processing Toolbox).
- Képfájl (.tif, .png, .jpg, stb).

## Használat

1. Állítsd be a kép nevét a szkript elején:

   ```matlab
   filename = 'kepnev.tif';
2.Futtasd a szkriptet MATLAB-ban.

3.Az első ablakban:
 -Jelölj ki egy téglalapot a vizsgálandó terület köré.
 -Dupla kattintással zárd le a kijelölést.
 
5.A kód ezután:
 -binarizál,
 -kiválasztja az ROI-n belüli komponenst,
 -meghatározza a legtávolabbi fehér pontot,
 -kiszámolja a sugarat (R) pixelben,
 -mindent kiír a Command Window-ba.
 
6.A harmadik ábra:
 -piros kör: középpontok,
 -cián kör: legtávolabbi fehér pontok,
 -kék vonalak: sugárirányok,
 -a címben látható az átlagos sugár (Átlag R).

Modosítható paraméterek:
topHatRadius = 25;    % top-hat szűrés sugara
sens = 0.45;          % adaptív binarizálás érzékenysége
searchRadius = 170;   % keresési sugár pixelben
Nagyobb kolóniákhoz növeld, kisebbekhez csökkentsd a searchRadius értékét.
Ha a bináris kép zajos vagy gyenge, állíts a topHatRadius és sens értékén.
